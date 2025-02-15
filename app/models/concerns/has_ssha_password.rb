using GenerateSSHA

module HasSSHAPassword
  extend ActiveSupport::Concern

  included do
    attribute :password,        :string
    attribute :password_digest, :string

    before_save do
      self.password_digest = password.generate_ssha if password
    end
  end
end
