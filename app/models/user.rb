using LDAPAssertion

class User
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :persisted?,            :boolean, default: false
  attribute :username,              :string
  attribute :password,              :string
  attribute :password_confirmation, :string
  attribute :email,                 :string
  attribute :first_name,            :string
  attribute :middle_name,           :string
  attribute :last_name,             :string
  attribute :first_name_japanese,   :string
  attribute :last_name_japanese,    :string
  attribute :job_title,             :string
  attribute :job_title_japanese,    :string
  attribute :orcid,                 :string
  attribute :erad_id,               :string
  attribute :organization,          :string
  attribute :organization_japanese, :string
  attribute :lab_fac_dep,           :string
  attribute :lab_fac_dep_japanese,  :string
  attribute :organization_url,      :string
  attribute :country,               :string
  attribute :postal_code,           :string
  attribute :prefecture,            :string
  attribute :city,                  :string
  attribute :street,                :string
  attribute :phone,                 :string
  attribute :ssh_keys,              default: -> { [] }
  attribute :account_type_number,   :integer, default: 1

  validates :username,     presence: true
  validates :password,     presence: true, confirmation: true, on: :create
  validates :email,        presence: true
  validates :first_name,   presence: true
  validates :last_name,    presence: true
  validates :organization, presence: true
  validates :country,      presence: true
  validates :city,         presence: true

  def self.search(query)
    filter = if query.present?
      Net::LDAP::Filter.eq("objectClass", "ddbjUser") & (
        %w[cn mail givenName middleName sn o].map { Net::LDAP::Filter.contains(it, query) }.inject(:|)
      )
    else
      Net::LDAP::Filter.eq("objectClass", "ddbjUser")
    end

    LDAP.connection.search(
      base:   LDAP.users_dn,
      filter:,
      size:   100
    ).map { from_entry(it) }
  end

  def self.find(username)
    entries = LDAP.connection.search(base: "cn=#{username},#{LDAP.users_dn}")

    raise ActiveRecord::RecordNotFound unless entries

    from_entry(entries.first)
  end

  def self.from_entry(entry)
    new(
      persisted?:            true,
      username:              entry.first(:cn),
      email:                 entry.first(:mail),
      first_name:            entry.first(:givenName),
      middle_name:           entry.first(:middleName),
      last_name:             entry.first(:sn),
      first_name_japanese:   entry.first("givenName;lang-ja"),
      last_name_japanese:    entry.first("sn;lang-ja"),
      organization:          entry.first(:o),
      organization_japanese: entry.first("o;lang-ja"),
      lab_fac_dep:           entry.first(:ou),
      lab_fac_dep_japanese:  entry.first("ou;lang-ja"),
      organization_url:      entry.first(:organizationURL),
      country:               entry.first(:c),
      postal_code:           entry.first(:postalCode),
      prefecture:            entry.first(:st),
      city:                  entry.first(:l),
      street:                entry.first(:street),
      phone:                 entry.first(:telephoneNumber),
      job_title:             entry.first(:title),
      job_title_japanese:    entry.first("title;lang-ja"),
      orcid:                 entry.first(:orcid),
      erad_id:               entry.first(:eradID),
      ssh_keys:              entry[:sshPublicKey],
      account_type_number:   entry.first(:accountTypeNumber)
    )
  end

  def new_record? = !persisted?

  def to_param
    username
  end

  def save
    update
  end

  def save!
    raise ActiveRecord::RecordInvalid, self unless update
  end

  def update(attrs = {})
    assign_attributes attrs

    return create if new_record?

    return false unless valid?(:update)

    REDIS.with_lock "email:#{email}" do
      if email_exists?
        errors.add :email, "has already been taken"

        return false
      end

      {
        email:                 :mail,
        first_name:            :givenName,
        first_name_japanese:   "givenName;lang-ja",
        middle_name:           :middleName,
        last_name:             :surname,
        last_name_japanese:    "surname;lang-ja",
        job_title:             :title,
        job_title_japanese:    "title;lang-ja",
        orcid:                 :orcid,
        erad_id:               :eradID,
        organization:          :organizationName,
        organization_japanese: "organizationName;lang-ja",
        lab_fac_dep:           :organizationalUnitName,
        lab_fac_dep_japanese:  "organizationalUnitName;lang-ja",
        organization_url:      :organizationURL,
        country:               :countryName,
        postal_code:           :postalCode,
        prefecture:            :stateOrProvinceName,
        city:                  :localityName,
        street:                :streetAddress,
        phone:                 :telephoneNumber,
        ssh_keys:              :sshPublicKey,
        account_type_number:   :accountTypeNumber
      }.each do |model_key, ldap_key|
        if val = public_send(model_key).presence
          LDAP.connection.replace_attribute(dn, ldap_key, val.to_s).assert
        else
          begin
            LDAP.connection.delete_attribute(dn, ldap_key).assert
          rescue LDAPError::NoSuchAttribute
            # do nothing
          end
        end
      rescue LDAPError => e
        errors.add model_key, e.message
      end
    end

    errors.empty?
  end

  def update_password(new_password:, current_password: nil)
    LDAP.connection.password_modify(dn:, new_password:, old_password: current_password).assert
  end

  def dn
    "cn=#{username},#{LDAP.users_dn}"
  end

  def admin?
    account_type_number == 3
  end

  private

  def create
    return false unless valid?(:create)

    if user_exists_in_ext_ldap?
      errors.add :username, "has already been taken"

      return false
    end

    REDIS.with_lock "email:#{email}" do
      if email_exists?
        errors.add :email, "has already been taken"

        return false
      end

      uid_number = REDIS.call(:incr, "uid_number")

      begin
        LDAP.connection.add(
          dn:,

          attributes: {
            objectclass: %w[
              ddbjUser
              ldapPublicKey
              posixAccount
              inetUser
            ],

            cn:                               username,
            mail:                             email,
            givenName:                        first_name,
            "givenName;lang-ja":              first_name_japanese,
            middleName:                       middle_name,
            surname:                          last_name,
            "surname;lang-ja":                last_name_japanese,
            title:                            job_title,
            "title;lang-ja":                  job_title_japanese,
            orcid:                            orcid,
            eradID:                           erad_id,
            organizationName:                 organization,
            "organizationName;lang-ja":       organization_japanese,
            organizationalUnitName:           lab_fac_dep,
            "organizationalUnitName;lang-ja": lab_fac_dep_japanese,
            organizationURL:                  organization_url,
            countryName:                      country,
            postalCode:                       postal_code,
            stateOrProvinceName:              prefecture,
            localityName:                     city,
            streetAddress:                    street,
            telephoneNumber:                  phone,
            sshPublicKey:                     ssh_keys,
            accountTypeNumber:                account_type_number.to_s,
            uid:                              username,
            uidNumber:                        uid_number.to_s,
            gidNumber:                        "61000",
            homeDirectory:                    "/submission/#{username}",
            loginShell:                       "/bin/bash",
            inetUserStatus:                   "active"
          }.compact_blank
        ).assert
      rescue LDAPError => e
        errors.add :base, e.message

        return false
      end
    end

    begin
      update_password new_password: password
    rescue LDAPError => e
      LDAP.connection.delete dn

      errors.add :password, e.message

      return false
    end

    true
  end

  def user_exists_in_ext_ldap?
    ExtLDAP.connection.search(
      base:  "cn=#{username},#{ExtLDAP.users_dn}",
      scope: Net::LDAP::SearchScope_BaseObject
    ).present?
  end

  def email_exists?
    LDAP.connection.search(
      base:   LDAP.users_dn,
      filter: Net::LDAP::Filter.eq("mail", email) & Net::LDAP::Filter.ne("cn", username),
      scope:  Net::LDAP::SearchScope_SingleLevel
    ).present?
  end
end
