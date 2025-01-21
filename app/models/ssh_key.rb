class SSHKey < ApplicationRecord
  belongs_to :user

  validates :key, presence: true

  validates_each :key do |record, attr, value|
    SSHData::PublicKey.parse_openssh value
  rescue SSHData::DecodeError
    record.errors.add attr, "is invalid. You must supply a key in OpenSSH public key format."
  end

  before_validation :extract_title, if: -> { title.blank? && key.present? }

  private

  def extract_title
    self.title = key.split(/\s+/, 3).last
  end
end
