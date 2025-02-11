module GenerateSSHA
  refine String do
    def generate_ssha
      salt    = SecureRandom.random_bytes(4)
      digest  = Digest::SHA1.digest(self + salt)
      encoded = Base64.strict_encode64(digest + salt)

      "{SSHA}#{encoded}"
    end
  end
end
