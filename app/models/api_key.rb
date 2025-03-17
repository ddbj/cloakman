class APIKey < ApplicationRecord
  has_secure_token

  validates :name, presence: true, uniqueness: true
end
