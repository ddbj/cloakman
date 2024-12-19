class CreateSSHKeyForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :account

  attribute :ssh_key, :string

  validates :ssh_key, presence: true

  validate do
    SSHData::PublicKey.parse_openssh ssh_key
  rescue SSHData::DecodeError
    errors.add :ssh_key, "Key is invalid. You must supply a key in OpenSSH public key format."
  end

  def self.from(account)
    new(account:, **account.attributes.slice(*attribute_names))
  end

  def save
    return false unless valid?

    (account.ssh_keys ||= []) << ssh_key

    account.save
  end
end
