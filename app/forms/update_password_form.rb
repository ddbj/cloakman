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
    Current.user.update(password: new_password)
  end
end
