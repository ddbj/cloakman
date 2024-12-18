class CreateSSHKeyForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :account

  attribute :ssh_key, :string

  validates :ssh_key, presence: true

  def self.from(account)
    new(account:, **account.attributes.slice(*attribute_names))
  end

  def save
    return false unless valid?

    (account.ssh_keys ||= []) << ssh_key

    Keycloak.admin.put "users/#{account.id}", **{
      headers: {
        "Content-Type": "application/json"
      },

      body: account.to_payload.to_json
    }

    true
  rescue OAuth2::Error => e
    parsed = e.response.parsed

    errors.add :base, parsed[:errorMessage] || parsed[:error_description] || parsed[:errpr] || e.message

    false
  end
end
