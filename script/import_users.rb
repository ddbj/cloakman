require_relative "../config/environment"

max_uid_number = -1

$stdin.each do |line|
  next if line.blank?

  attrs      = JSON.parse(line, symbolize_names: true)
  uid_number = attrs[:uid_number].to_i

  max_uid_number = uid_number if uid_number > max_uid_number

  next unless attrs[:id]

  User.create! attrs

  puts "User #{attrs[:id]} created"
rescue ActiveRecord::RecordInvalid => e
  if e.record.errors[:id].include?("has already been taken")
    warn "User #{attrs[:id]} already exists"
  else
    p e.record.errors

    raise
  end
end

REDIS.call :set, "uid_number", max_uid_number
