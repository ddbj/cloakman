using LDAPAssertion

class User
  include ActiveModel::Model
  include ActiveModel::Attributes

  extend Enumerize

  class << self
    def users_dn = "ou=users,#{LDAP.base_dn}"

    def search(query)
      filter = Net::LDAP::Filter.eq("objectClass", "ddbjUser")

      filter = filter & %w[uid mail commonName organizationName].map { |attr|
        Net::LDAP::Filter.contains(attr, query)
      }.inject(:|) if query.present?

      LDAP.connection.assert_call(:search, **{
        base:   users_dn,
        scope:  Net::LDAP::SearchScope_SingleLevel,
        filter:,
        size:   100
      }).map { from_entry(it) }
    end

    def find(username)
      entry = LDAP.connection.assert_call(:search, **{
        base:  "uid=#{username},#{users_dn}",
        scope: Net::LDAP::SearchScope_BaseObject
      }).first

      from_entry(entry)
    rescue LDAPError::NoSuchObject
      raise ActiveRecord::RecordNotFound
    end

    def from_entry(entry)
      new(
        persisted?:            true,
        username:              entry.first(:uid),
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
        account_type_number:   entry.first(:accountTypeNumber),
        inet_user_status:      entry.first(:inetUserStatus)
      )
    end
  end

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
  attribute :ssh_keys,                        default: -> { [] }
  attribute :inet_user_status,      :string,  default: "active"
  attribute :account_type_number,   :integer, default: 1

  enumerize :inet_user_status, in: %i[active inactive deleted]

  enumerize :account_type_number, in: {
    general:          1,
    nbdc:             2,
    ddbj:             3,
    administrator:    4,
    system_reference: 5
  }

  validates :username,     presence: true
  validates :password,     presence: true, confirmation: true, on: :create
  validates :email,        presence: true
  validates :first_name,   presence: true
  validates :last_name,    presence: true
  validates :organization, presence: true
  validates :country,      presence: true
  validates :city,         presence: true

  delegate :users_dn, to: :class

  def new_record? = !persisted?
  def to_param    = username
  def dn          = "uid=#{username},#{users_dn}"
  def full_name   = [ first_name, middle_name, last_name ].compact_blank.join(" ")

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
        full_name:                 :commonName,
        email:                     :mail,
        first_name:                :givenName,
        first_name_japanese:       "givenName;lang-ja",
        middle_name:               :middleName,
        last_name:                 :surname,
        last_name_japanese:        "surname;lang-ja",
        job_title:                 :title,
        job_title_japanese:        "title;lang-ja",
        orcid:                     :orcid,
        erad_id:                   :eradID,
        organization:              :organizationName,
        organization_japanese:     "organizationName;lang-ja",
        lab_fac_dep:               :organizationalUnitName,
        lab_fac_dep_japanese:      "organizationalUnitName;lang-ja",
        organization_url:          :organizationURL,
        country:                   :countryName,
        postal_code:               :postalCode,
        prefecture:                :stateOrProvinceName,
        city:                      :localityName,
        street:                    :streetAddress,
        phone:                     :telephoneNumber,
        ssh_keys:                  :sshPublicKey,
        account_type_number_value: :accountTypeNumber,
        inet_user_status:          :inetUserStatus
      }.each do |model_key, ldap_key|
        if val = public_send(model_key).presence
          LDAP.connection.assert_call :replace_attribute, dn, ldap_key, val.to_s
        else
          begin
            LDAP.connection.assert_call :delete_attribute, dn, ldap_key
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

  def destroy!
    LDAP.connection.assert_call(:delete, dn:)
  end

  def update_password(new_password:, current_password: nil)
    LDAP.connection.assert_call(:password_modify,  dn:, new_password:, old_password: current_password)
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
        LDAP.connection.assert_call(:add, **{
          dn:,

          attributes: {
            objectClass: %w[
              ddbjUser
              ldapPublicKey
              posixAccount
              inetUser
            ],

            uid:                              username,
            commonName:                       full_name,
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
            accountTypeNumber:                account_type_number_value.to_s,
            uidNumber:                        uid_number.to_s,
            gidNumber:                        "61000",
            homeDirectory:                    "/submission/#{username}",
            loginShell:                       "/bin/bash",
            inetUserStatus:                   inet_user_status
          }.compact_blank
        })
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
    !ExtLDAP.connection.assert_call(:search, **{
      base:   ExtLDAP.base_dn,
      filter: Net::LDAP::Filter.eq("objectClass", "posixAccount") & Net::LDAP::Filter.eq("uid", username)
    }).empty?
  end

  def email_exists?
    !LDAP.connection.assert_call(:search, **{
      base:   users_dn,
      filter: Net::LDAP::Filter.eq("mail", email) & Net::LDAP::Filter.ne("uid", username)
    }).empty?
  end
end
