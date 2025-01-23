class LDAPError < StandardError
  MAPPINGS = Net::LDAP.constants.grep(/ResultCode[A-Z]/).without(:ResultCodeSuccess).map { |name|
    [
      Net::LDAP.const_get(name),
      name.to_s.delete_prefix("ResultCode")
    ]
  }.to_h

  MAPPINGS.values.each do |name|
    const_set name, Class.new(self)
  end

  def self.from_result(result)
    const_get(MAPPINGS.fetch(result.code)).new(result)
  end

  def initialize(result)
    super result.error_message.presence || result.message

    @result = result
  end

  attr_reader :result
end
