using LDAPAssertion

class LDAPEntry
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Dirty

  class_attribute :base_dn
  class_attribute :ldap_id_attr
  class_attribute :model_to_ldap_map
  class_attribute :ldap_to_model_map
  class_attribute :object_classes

  define_model_callbacks :save, :create, :update, :destroy

  attribute :id,         :string
  attribute :persisted?, :boolean, default: false

  validates :id, presence: true

  class << self
    def create(attrs = {})
      new(attrs).tap(&:save)
    end

    def create!(attrs = {})
      new(attrs).tap(&:save!)
    end

    def all
      LDAP.connection.assert_call(:search, **{
        base:                          base_dn,
        scope:                         Net::LDAP::SearchScope_SingleLevel,
        attributes:                    ldap_to_model_map.keys,
        return_operational_attributes: true,
        filter:                        object_classes.map { Net::LDAP::Filter.eq("objectClass", it) }.inject(:&)
      }).map { from_entry(it) }
    end

    delegate :size, :count, to: :all

    def find(id)
      entry = LDAP.connection.assert_call(:search, **{
        base:                          "#{ldap_id_attr}=#{id},#{base_dn}",
        scope:                         Net::LDAP::SearchScope_BaseObject,
        attributes:                    ldap_to_model_map.keys,
        return_operational_attributes: true
      }).first

      from_entry(entry)
    end

    def destroy_all
      all.each(&:destroy)
    end

    private

    def from_entry(entry)
      new(
        persisted?: true,

        **ldap_to_model_map.map { |ldap_key, model_key|
          is_array = type_for_attribute(model_key).instance_of?(ActiveModel::Type::Value)

          [ model_key, is_array ? entry[ldap_key] : entry.first(ldap_key) ]
        }.to_h
      ).tap(&:changes_applied)
    end
  end

  def new_record? = !persisted?
  def dn          = "#{ldap_id_attr}=#{id},#{base_dn}"

  def save(validate: true, context: nil)
    update({}, validate, context)
  end

  def save!(validate: true, context: nil)
    raise ActiveRecord::RecordInvalid, self unless save(validate:, context:)
  end

  def update(attrs = {}, validate = true, context = nil)
    assign_attributes attrs

    run_callbacks :save do
      return create(validate:, context:) if new_record?

      run_callbacks :update do
        return false if validate && invalid?(context || :update)

        model_to_ldap_map.each do |model_key, ldap_key|
          next unless public_send("#{model_key}_changed?")

          if val = public_send(model_key).presence
            val = val.value if val.is_a?(Enumerize::Value)

            LDAP.connection.assert_call :replace_attribute, dn, ldap_key, Array(val).map(&:to_s)
          else
            begin
              LDAP.connection.assert_call :delete_attribute, dn, ldap_key
            rescue LDAPError::NoSuchAttribute
              # do nothing
            end
          end

          public_send "clear_#{model_key}_change"
        rescue LDAPError::ConstraintViolation => e
          if e.message.start_with?("non-unique attributes found with ")
            errors.add model_key, "has already been taken"
          else
            errors.add model_key, e.message
          end
        rescue LDAPError => e
          errors.add model_key, e.message
        end
      end
    end

    errors.empty?
  end

  def update!(attrs = {})
    raise ActiveRecord::RecordInvalid, self unless update(attrs)
  end

  def destroy!
    run_callbacks :destroy do
      LDAP.connection.assert_call(:delete, dn:)
    end
  end

  def destroy
    destroy!

    true
  rescue LDAPError
    false
  end

  private

  def create(validate:, context:)
    run_callbacks :create do
      return false if validate && invalid?(context || :create)

      LDAP.connection.assert_call :add, **{
        dn:,

        attributes: {
          objectClass: object_classes,

          **model_to_ldap_map.map { |model_key, ldap_key|
            val = public_send(model_key).presence
            val = val.value if val.is_a?(Enumerize::Value)

            [ ldap_key, Array(val).map(&:to_s) ]
          }.to_h.compact_blank
        }
      }

      assign_attributes persisted?: true

      changes_applied
    rescue LDAPError::EntryAlreadyExists
      errors.add :id, "has already been taken"

      return false
    rescue LDAPError::ConstraintViolation => e
      if e.message.start_with?("non-unique attributes found with (|(mail=")
        errors.add :email, "has already been taken"
      else
        errors.add :base, e.message
      end

      return false
    rescue LDAPError => e
      errors.add :base, e.message

      return false
    end

    true
  end
end
