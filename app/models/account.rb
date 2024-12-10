class Account
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :account_id,            :string
  attribute :password,              :string
  attribute :password_confirmation, :string
  attribute :email,                 :string
  attribute :first_name,            :string
  attribute :middle_name,           :string
  attribute :last_name,             :string

  validates :account_id, presence: true
  validates :password,   presence: true, confirmation: true
  validates :email,      presence: true
  validates :first_name, presence: true
  validates :last_name,  presence: true

  def save
    valid?
  end
end
