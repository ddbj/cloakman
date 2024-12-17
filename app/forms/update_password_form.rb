class UpdatePasswordForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :account

  attribute :password,              :string
  attribute :password_confirmation, :string
end
