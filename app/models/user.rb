using LDAPAssertion

class User < LDAPEntry
  include ExtLDAPSync
  include HasSSHAPassword

  extend Enumerize

  self.base_dn        = Rails.application.config_for(:ldap).users_dn!
  self.ldap_id_attr   = :uid
  self.object_classes = %w[ddbjUser ldapPublicKey posixAccount inetUser]

  self.model_to_ldap_map = {
    id:                    'uid',
    password_digest:       'userPassword',
    email:                 'mail',
    first_name:            'givenName',
    middle_name:           'middleName',
    last_name:             'sn',
    first_name_japanese:   'givenName;lang-ja',
    last_name_japanese:    'sn;lang-ja',
    full_name:             'cn',
    job_title:             'title',
    job_title_japanese:    'title;lang-ja',
    orcid:                 'orcid',
    erad_id:               'eradID',
    organization:          'o',
    organization_japanese: 'o;lang-ja',
    lab_fac_dep:           'ou',
    lab_fac_dep_japanese:  'ou;lang-ja',
    organization_url:      'organizationURL',
    country:               'c',
    postal_code:           'postalCode',
    prefecture:            'st',
    city:                  'l',
    street:                'street',
    phone:                 'telephoneNumber',
    ssh_keys:              'sshPublicKey',
    jga_datasets:          'jgaDataset',
    account_type_number:   'accountTypeNumber',
    inet_user_status:      'inetUserStatus',
    uid_number:            'uidNumber',
    gid_number:            'gidNumber',
    home_directory:        'homeDirectory',
    login_shell:           'loginShell'
  }

  self.ldap_to_model_map = model_to_ldap_map.invert.merge(
    'pwdLastSuccess' => :last_sign_in_at
  )

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
  attribute :inet_user_status,      :string,  default: -> { 'active' }
  attribute :account_type_number,   :integer, default: 1
  attribute :uid_number,            :integer
  attribute :gid_number,            :integer, default: -> { Rails.application.config_for(:app).submitter_gid_number! }
  attribute :home_directory,        :string
  attribute :login_shell,           :string,  default: -> { '/bin/bash' }
  attribute :last_sign_in_at,       :datetime

  enumerize :inet_user_status, in: %i[active inactive deleted]

  enumerize :account_type_number, in: {
    general:          1,
    nbdc:             2,
    ddbj:             3,
    administrator:    4,
    system_reference: 5
  }

  validates :id, length: {minimum: 3, maximum: 24}, format: {with: /\A[a-z0-9][a-z0-9_\-]*\z/}, allow_blank: true
  validates :id, format: {without: /_pg\z/, message: "can't end with '_pg'"}
  validates :id, format: {with:    /\Ats-/, message: "must start with 'ts-'"},  if:     -> { Rails.env.staging? }
  validates :id, format: {without: /\Ats-/, message: "can't start with 'ts-'"}, unless: -> { Rails.env.staging? }

  ascii_only = {with: /\A[[:ascii:]]+\z/, allow_blank: true, message: :ascii_only}

  validates :email,            presence: true, format: {with: URI::MailTo::EMAIL_REGEXP, allow_blank: true}
  validates :first_name,       presence: true, format: ascii_only
  validates :middle_name,                      format: ascii_only
  validates :last_name,        presence: true, format: ascii_only
  validates :job_title,                        format: ascii_only
  validates :orcid,                            format: {with: /\A\d{4}-\d{4}-\d{4}-\d{3}[\dX]\z/, allow_blank: true}
  validates :erad_id,                          format: {with: /\A\d{8}\z/, allow_blank: true}
  validates :organization,     presence: true, format: ascii_only
  validates :lab_fac_dep,                      format: ascii_only
  validates :organization_url,                 format: {with: /\A#{URI.regexp(%w[http https])}\z/, allow_blank: true}
  validates :country,          presence: true, inclusion: {in: ISO3166::Country.codes, allow_blank: true}
  validates :postal_code,                      format: ascii_only
  validates :prefecture,                       format: ascii_only
  validates :city,             presence: true, format: ascii_only
  validates :street,                           format: ascii_only
  validates :phone,                            format: ascii_only

  with_options on: :sign_up do
    validates :password,              presence: true, length: {minimum: 8, allow_blank: true}, confirmation: true
    validates :password_confirmation, presence: true
    validates :accept_terms,          acceptance: true
  end

  validate do
    next unless entry = ext_ldap_entry

    if entry[:uidNumber].first.to_i != uid_number
      errors.add :id, 'has already been taken'
    end
  end

  before_save do
    self.full_name = [first_name, middle_name, last_name].compact_blank.join(' ')
  end

  before_create do
    self.uid_number ||= begin
      begin
        uid_number = REDIS.call(:incr, 'uid_number')
      end until User.search(Net::LDAP::Filter.eq('uidNumber', uid_number)).empty?

      uid_number
    end

    self.home_directory ||= "/submission/#{id}"
  end

  def self.search(filter)
    filter = Net::LDAP::Filter.eq('objectClass', 'ddbjUser') & filter

    LDAP.connection.assert_call(:search, **{
      base:                          base_dn,
      scope:                         Net::LDAP::SearchScope_SingleLevel,
      attributes:                    ldap_to_model_map.keys,
      return_operational_attributes: true,
      filter:,
      size:                          100
    }).map { from_entry(it) }
  end

  def ext_ldap_entry
    return nil if id.blank?

    ExtLDAP.connection.assert_call(:search, **{
      base:   ExtLDAP.base_dn,
      filter: Net::LDAP::Filter.eq('objectClass', 'posixAccount') & Net::LDAP::Filter.eq('uid', id)
    }).first
  end
end
