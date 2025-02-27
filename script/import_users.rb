require_relative "../config/environment"

using LDAPAssertion

users  = $stdin.each_line.map { JSON.parse(it, symbolize_names: true) }
emails = Set.new

users.each do |attrs|
  attrs => {
    id:,
    email:,
    uid_number:,
    home_directory:,
    inet_user_status:
  }

  if id.end_with?("_pg") || !id.match?(/\A[a-z][a-z0-9_\-]{2,23}\z/)
    puts "[SKIPPED] #{id}: invalid username"
    next
  end

  ext = ExtLDAP.connection.assert_call(:search, **{
    base:   ExtLDAP.base_dn,
    filter: Net::LDAP::Filter.eq("objectClass", "posixAccount") & Net::LDAP::Filter.eq("uid", id)
  }).first

  renamed = ext && ext[:uidNumber].first.to_i != uid_number
  id      = renamed ? "#{id}_db" : id

  email_missing    = !email
  email_duplicated = !email_missing && !emails.add?(email)

  email = if email_missing
    "#{id}@invalid.ddbj"
  elsif email_duplicated
    "#{email}.invalid.ddbj"
  else
    email
  end

  User.create!(
    **attrs,
    id:,
    email:,
    home_directory:   home_directory || "/submission/#{id}",
    inet_user_status: email_missing || email_duplicated ? "inactive" : inet_user_status,
  )

  print "[CREATED] #{id}"
  print " (exists in ext ldap)"              if ext
  print " (renamed from #{ext[:uid].first})" if renamed
  print " (missing email)"                   if email_missing
  print " (duplicated email)"                if email_duplicated
  puts
rescue ActiveRecord::RecordInvalid => e
  warn e.record.errors.inspect

  raise
end

REDIS.call :set, "uid_number", users.map { it[:uid_number].to_i }.max
