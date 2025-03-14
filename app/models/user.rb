using LDAPAssertion

class User < LDAPEntry
  include ExtLDAPSync
  include HasSSHAPassword

  extend Enumerize

  self.base_dn        = Rails.application.config_for(:ldap).users_dn!
  self.ldap_id_attr   = :uid
  self.object_classes = %w[ddbjUser ldapPublicKey posixAccount inetUser]

  self.ldap_to_model_map = {
    "uid"               => :id,
    "userPassword"      => :password_digest,
    "mail"              => :email,
    "givenName"         => :first_name,
    "givenName;lang-ja" => :first_name_japanese,
    "middleName"        => :middle_name,
    "sn"                => :last_name,
    "sn;lang-ja"        => :last_name_japanese,
    "cn"                => :full_name,
    "title"             => :job_title,
    "title;lang-ja"     => :job_title_japanese,
    "orcid"             => :orcid,
    "eradID"            => :erad_id,
    "o"                 => :organization,
    "o;lang-ja"         => :organization_japanese,
    "ou"                => :lab_fac_dep,
    "ou;lang-ja"        => :lab_fac_dep_japanese,
    "organizationURL"   => :organization_url,
    "c"                 => :country,
    "postalCode"        => :postal_code,
    "st"                => :prefecture,
    "l"                 => :city,
    "street"            => :street,
    "telephoneNumber"   => :phone,
    "sshPublicKey"      => :ssh_keys,
    "jgaDataset"        => :jga_datasets,
    "accountTypeNumber" => :account_type_number,
    "inetUserStatus"    => :inet_user_status,
    "uidNumber"         => :uid_number,
    "gidNumber"         => :gid_number,
    "homeDirectory"     => :home_directory,
    "loginShell"        => :login_shell,
    "pwdLastSuccess"    => :last_sign_in_at
  }

  self.model_to_ldap_map = ldap_to_model_map.except("pwdLastSuccess").invert

  class << self
    def search(filter)
      filter = Net::LDAP::Filter.eq("objectClass", "ddbjUser") & filter

      LDAP.connection.assert_call(:search, **{
        base:                          base_dn,
        scope:                         Net::LDAP::SearchScope_SingleLevel,
        attributes:                    ldap_to_model_map.keys,
        return_operational_attributes: true,
        filter:,
        size:                          100
      }).map { from_entry(it) }
    end
  end

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
  attribute :jga_datasets,          default: -> { [] }
  attribute :ssh_keys,              default: -> { [] }
  attribute :inet_user_status,      :string,  default: -> { "active" }
  attribute :account_type_number,   :integer, default: 1
  attribute :uid_number,            :integer
  attribute :gid_number,            :integer, default: 61000
  attribute :home_directory,        :string
  attribute :login_shell,           :string,  default: -> { "/bin/bash" }
  attribute :last_sign_in_at,       :datetime

  enumerize :inet_user_status, in: %i[active inactive deleted]

  enumerize :account_type_number, in: {
    general:          1,
    nbdc:             2,
    ddbj:             3,
    administrator:    4,
    system_reference: 5
  }

  validates :id,               length: { minimum: 3, maximum: 24, allow_blank: true }, format: { with: /\A[a-z0-9][a-z0-9_\-]*\z/, allow_blank: true }
  validates :id,               format: { without: /_pg\z/, message: "cannot end with '_pg'" }
  validates :id,               format: { with: /\Ats-/, message: "must start with 'ts-'" }, if: -> { Rails.env.staging? }
  validates :id,               format: { without: /\Ats-/, message: "cannot start with 'ts-'" }, unless: -> { Rails.env.staging? }
  validates :email,            presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :first_name,       presence: true
  validates :last_name,        presence: true
  validates :organization,     presence: true
  validates :organization_url, format: { with: /\A#{URI.regexp(%w[http https])}\z/, allow_blank: true }
  validates :country,          presence: true, inclusion: { in: ISO3166::Country.codes }
  validates :city,             presence: true
  validates :orcid,            format: { with: /\A\d{4}-\d{4}-\d{4}-\d{3}[\dX]\z/, allow_blank: true }
  validates :erad_id,          format: { with: /\A\d{8}\z/, allow_blank: true }

  with_options on: :sign_up do
    validates :password,              presence: true, length: { minimum: 8, allow_blank: true }, confirmation: true
    validates :password_confirmation, presence: true
    validates :accept_terms,          acceptance: true
  end

  validate do
    next unless entry = ext_ldap_entry

    if entry[:uidNumber].first.to_i != uid_number
      errors.add :id, "has already been taken"
    end
  end

  before_save do
    self.full_name = [ first_name, middle_name, last_name ].compact_blank.join(" ")
  end

  before_create do
    self.uid_number ||= begin
      begin
        uid_number = REDIS.call(:incr, "uid_number")
      end until User.search(Net::LDAP::Filter.eq("uidNumber", uid_number)).empty?

      uid_number
    end

    self.home_directory ||= "/submission/#{id}"
  end

  def ext_ldap_entry
    return nil if id.blank?

    ExtLDAP.connection.assert_call(:search, **{
      base:   ExtLDAP.base_dn,
      filter: Net::LDAP::Filter.eq("objectClass", "posixAccount") & Net::LDAP::Filter.eq("uid", id)
    }).first
  end
end
