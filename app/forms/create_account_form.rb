class CreateAccountForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :account, default: -> { Account.new }

  attribute :account_id,            :string
  attribute :password,              :string
  attribute :password_confirmation, :string
  attribute :email,                 :string
  attribute :first_name,            :string
  attribute :middle_name,           :string
  attribute :last_name,             :string

  validates :account_id, presence: true
  validates :password,   presence: true, confirmation: true, on: :create
  validates :first_name, presence: true
  validates :last_name,  presence: true
  validates :email,      presence: true

  def save
    return false unless valid?

    account.assign_attributes attributes.except("account", "password", "password_confirmation")

    res = Keycloak.admin.post("users", **{
      headers: {
        "Content-Type": "application/json"
      },

      body: account.to_payload.merge(
        username: account_id,

        credentials: [
          type:      "password",
          temporary: false,
          value:     password
        ]
      ).to_json
    })

    account.id = res.response["Location"].split("/").last

    true
  rescue OAuth2::Error => e
    parsed = e.response.parsed

    errors.add :base, parsed[:errorMessage] || parsed[:error_description] || parsed[:error] || e.message

    false
  end
end
