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

    account.save
  end
end
