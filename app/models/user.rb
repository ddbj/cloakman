class User < ApplicationRecord
  has_secure_password

  belongs_to :account

  has_many :sessions, dependent: :destroy
  has_many :ssh_keys, dependent: :destroy

  validates :password,     presence: true, confirmation: true, on: :create
  validates :email,        presence: true
  validates :first_name,   presence: true
  validates :last_name,    presence: true
  validates :organization, presence: true
  validates :country,      presence: true
  validates :city,         presence: true
end
