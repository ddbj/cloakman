class User < ApplicationRecord
  has_secure_password

  has_many :sessions,   dependent: :destroy
  has_many :ssh_keys,   dependent: :destroy
  has_one  :uid_number, dependent: :destroy

  validates :username,     presence: true
  validates :password,     presence: true, confirmation: true, on: :create
  validates :email,        presence: true
  validates :first_name,   presence: true
  validates :last_name,    presence: true
  validates :organization, presence: true
  validates :country,      presence: true
  validates :city,         presence: true
end
