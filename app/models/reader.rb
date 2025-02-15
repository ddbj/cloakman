using GenerateSSHA
using LDAPAssertion

class Reader
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Dirty

  class << self
    def endpoint   = ENV.fetch("LDAP_INTERNAL_ENDPOINT", "ldap://localhost:1389")
    def readers_dn = "ou=readers,#{LDAP.base_dn}"

    def all
      LDAP.connection.assert_call(:search, **{
        base:   readers_dn,
        scope:  Net::LDAP::SearchScope_SingleLevel,
        filter: Net::LDAP::Filter.eq("objectClass", "account")
      }).map { from_entry(it) }
    end

    def find(username)
      entry = LDAP.connection.assert_call(:search, **{
        base:  "uid=#{username},#{readers_dn}",
        scope: Net::LDAP::SearchScope_BaseObject
      }).first

      from_entry(entry)
    rescue LDAPError::NoSuchObject
      raise ActiveRecord::RecordNotFound
    end

    def from_entry(entry)
      new(
        persisted?: true,
        username:   entry.first(:uid)
      ).tap(&:changes_applied)
    end
  end

  attribute :persisted?, :boolean, default: false
  attribute :username,   :string
  attribute :password,   :string,  default: -> { Base58.binary_to_base58(SecureRandom.random_bytes) }

  validates :username, presence: true
  validates :password, presence: true

  delegate :readers_dn, to: :class

  def new_record? = !persisted?
  def to_param    = username
  def dn          = "uid=#{username},#{readers_dn}"

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

    {
      username: :uid,
      password: :userPassword
    }.each do |model_key, ldap_key|
      next unless public_send("#{model_key}_changed?")

      if val = public_send(model_key).presence
        LDAP.connection.assert_call :replace_attribute, dn, ldap_key, val.to_s
      else
        begin
          LDAP.connection.assert_call :delete_attribute, dn, ldap_key
        rescue LDAPError::NoSuchAttribute
          # do nothing
        end
      end

      public_send "clear_#{model_key}_change"
    rescue LDAPError => e
      errors.add model_key, e.message
    end

    errors.empty?
  end

  def update!(attrs = {})
    raise ActiveRecord::RecordInvalid, self unless update(attrs)
  end

  def destroy!
    LDAP.connection.assert_call(:delete, dn:)
  end

  private

  def create
    return false unless valid?(:create)

    LDAP.connection.assert_call :add, **{
      dn:,

      attributes: {
        objectClass: %w[
          account
          simpleSecurityObject
        ],

        uid:          username,
        userPassword: password.generate_ssha
      }.compact_blank
    }

    changes_applied

    true
  rescue LDAPError => e
    errors.add :base, e.message

    false
  end
end
