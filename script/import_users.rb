require_relative "../config/environment"

users  = $stdin.each_line.map { JSON.parse(it, symbolize_names: true) }
emails = Set.new

users.each do |attrs|
  attrs => {id:, email:}

  if %w[admin _pg].any? { id.include?(it) } || !id.match?(/\A[a-z][a-z0-9_]{3,23}\z/) || !email || !emails.add?(email)
    puts "[SKIPPED] #{id}: invalid"
    next
  end

  User.create! attrs

  puts "[CREATED] #{id}"
rescue ActiveRecord::RecordInvalid => e
  if e.record.errors[:id].include?("has already been taken")
    puts "[SKIPPED] #{id}: already exists"
  else
    p e.record.errors

    raise
  end
end

REDIS.call :set, "uid_number", users.map { it[:uid_number].to_i }.max
