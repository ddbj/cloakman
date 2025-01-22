class Account < ApplicationRecord
  validates :username, presence: true, uniqueness: true

  has_one :user, dependent: :destroy

  accepts_nested_attributes_for :user
end
