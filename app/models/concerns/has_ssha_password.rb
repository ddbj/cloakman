using GenerateSSHA

module HasSSHAPassword
  extend ActiveSupport::Concern

  included do
    attribute :password,        :string
    attribute :password_digest, :string

    validates :password, presence: true, on: :create, unless: :password_digest

    before_save do
      self.password_digest = password.generate_ssha if password
    end
  end
end
