class UpdatePasswordForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :account

  attribute :current_password,          :string
  attribute :new_password,              :string
  attribute :new_password_confirmation, :string

  validates :current_password, presence: true
  validates :new_password,     presence: true, confirmation: true

  def persisted? = true

  def save
    return false unless valid?

    begin
      Keycloak.client.password.get_token(account.account_id, current_password)
    rescue OAuth2::Error
      errors.add :current_password, "is invalid"

      return false
    end

    Keycloak.admin.put "users/#{account.id}/reset-password", **{
      headers: {
        "Content-Type": "application/json"
      },

      body: {
        type:      "password",
        temporary: false,
        value:     new_password
      }.to_json
    }

    true
  end

  private

  def client
  end
end
