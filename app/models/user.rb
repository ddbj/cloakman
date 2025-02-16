using LDAPAssertion

class User < LDAPEntry
  include HasSSHAPassword

  extend Enumerize

  self.base_dn        = "ou=users,#{LDAP.base_dn}"
  self.ldap_id_attr   = :uid
  self.object_classes = %w[ddbjUser ldapPublicKey posixAccount inetUser]

  self.model_to_ldap_map = {
    id:                    :uid,
    password_digest:       :userPassword,
    email:                 :mail,
    first_name:            :givenName,
    first_name_japanese:   "givenName;lang-ja",
    middle_name:           :middleName,
    last_name:             :sn,
    last_name_japanese:    "sn;lang-ja",
    full_name:             :cn,
    job_title:             :title,
    job_title_japanese:    "title;lang-ja",
    orcid:                 :orcid,
    erad_id:               :eradID,
    organization:          :o,
    organization_japanese: "o;lang-ja",
    lab_fac_dep:           :ou,
    lab_fac_dep_japanese:  "ou;lang-ja",
    organization_url:      :organizationURL,
    country:               :c,
    postal_code:           :postalCode,
    prefecture:            :st,
    city:                  :l,
    street:                :street,
    phone:                 :telephoneNumber,
    ssh_keys:              :sshPublicKey,
    jga_datasets:          :jgaDataset,
    account_type_number:   :accountTypeNumber,
    inet_user_status:      :inetUserStatus,
    uid_number:            :uidNumber,
    gid_number:            :gidNumber,
    home_directory:        :homeDirectory,
    login_shell:           :loginShell
  }

  class << self
    def search(query)
      filter = Net::LDAP::Filter.eq("objectClass", "ddbjUser")

      filter = filter & %w[uid mail commonName organizationName].map { |attr|
        Net::LDAP::Filter.contains(attr, query)
      }.inject(:|) if query.present?

      LDAP.connection.assert_call(:search, **{
        base:   base_dn,
        scope:  Net::LDAP::SearchScope_SingleLevel,
        filter:,
        size:   100
      }).map { from_entry(it) }
    end
  end

  attribute :password_confirmation, :string
  attribute :email,                 :string
  attribute :full_name,             :string
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
  attribute :jga_datasets,                    default: -> { [] }
  attribute :ssh_keys,                        default: -> { [] }
  attribute :inet_user_status,      :string
  attribute :account_type_number,   :integer
  attribute :uid_number,            :integer
  attribute :gid_number,            :integer
  attribute :home_directory,        :string
  attribute :login_shell,           :string

  enumerize :inet_user_status, in: %i[active inactive deleted]

  enumerize :account_type_number, in: {
    general:          1,
    nbdc:             2,
    ddbj:             3,
    administrator:    4,
    system_reference: 5
  }

  validates :id,               length: { minimum: 4, maximum: 24 }, format: { with: /\A[a-z][a-z0-9_]*\z/ }, allow_blank: true
  validates :password,         presence: true, confirmation: true, length: { minimum: 6, allow_blank: true }, on: :sign_up
  validates :email,            presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :first_name,       presence: true
  validates :last_name,        presence: true
  validates :organization,     presence: true
  validates :organization_url, format: { with: /\A#{URI.regexp(%w[http https])}\z/, allow_blank: true }
  validates :country,          presence: true, inclusion: { in: ISO3166::Country.codes }
  validates :city,             presence: true
  validates :orcid,            format: { with: /\A\d{4}-\d{4}-\d{4}-\d{3}[\dX]\z/, allow_blank: true }
  validates :erad_id,          format: { with: /\A\d{8}\z/, allow_blank: true }

  validate do
    errors.add :id, "is reserved" if %w[admin _pg].any? { id.include?(it) }
  end

  validate do
    exists = !ExtLDAP.connection.assert_call(:search, **{
      base:   ExtLDAP.base_dn,
      filter: Net::LDAP::Filter.eq("objectClass", "posixAccount") & Net::LDAP::Filter.eq("uid", id)
    }).empty?

    errors.add :id, "has already been taken" if exists
  end

  validate do
    exists = !LDAP.connection.assert_call(:search, **{
      base:   base_dn,
      filter: Net::LDAP::Filter.eq("mail", email) & Net::LDAP::Filter.ne("uid", id)
    }).empty?

    errors.add :email, "has already been taken" if exists
  end

  around_save do |_, block|
    REDIS.with_lock "email:#{email}", &block
  end

  before_save do
    self.full_name = [ first_name, middle_name, last_name ].compact_blank.join(" ")
  end

  before_create do
    self.inet_user_status    ||= :active
    self.account_type_number ||= :general
    self.uid_number          ||= REDIS.call(:incr, "uid_number")
    self.gid_number          ||= 61000
    self.home_directory      ||= "/submission/#{id}"
    self.login_shell         ||= "/bin/bash"
  end
end
