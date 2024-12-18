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

    account.update attributes.except("account", "password", "password_confirmation")

    account.errors.full_messages_for(:base).each do |message|
      errors.add :base, message
    end
  end
end
