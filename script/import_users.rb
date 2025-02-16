require_relative "../config/environment"

users  = $stdin.each_line.map { JSON.parse(it, symbolize_names: true) }
emails = Set.new

users.each do |attrs|
  attrs => {id:, email:}

  next if %w[admin _pg].any? { id.include?(it) }
  next unless id.match?(/\A[a-z][a-z0-9_]{3,23}\z/)
  next unless email
  next unless emails.add?(email)

  User.create! attrs

  puts "User #{id} created"
rescue ActiveRecord::RecordInvalid => e
  if e.record.errors[:id].include?("has already been taken")
    warn "User #{id} already exists"
  else
    p e.record.errors

    raise
  end
end

REDIS.call :set, "uid_number", users.map { it[:uid_number].to_i }.max
