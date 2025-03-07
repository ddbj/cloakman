require_relative "../config/environment"

using LDAPAssertion

users  = $stdin.each_line.map { JSON.parse(it, symbolize_names: true) }
emails = Hash.new(0)

users.each do |attrs|
  attrs => {
    id:,
    email:,
    uid_number:,
    home_directory:,
    inet_user_status:
  }

  ext = ExtLDAP.connection.assert_call(:search, **{
    base:   ExtLDAP.base_dn,
    filter: Net::LDAP::Filter.eq("objectClass", "posixAccount") & Net::LDAP::Filter.eq("uid", id)
  }).first

  if ext && ext[:uidNumber].first.to_i != uid_number
    puts "[SKIPPED] #{id}: uidNumber mismatch"

    puts JSON.generate(
      uid:       ext[:uid].first,
      uidNumber: ext[:uidNumber].first,
      gidNumber: ext[:gidNumber].first,
      cn:        ext[:cn].first
    )

    next
  end

  email_num = email ? emails[email] += 1 : 1

  email = if !email
    "#{id}@invalid.ddbj"
  elsif email_num > 1
    "#{email}.invalid.ddbj.#{email_num}"
  else
    email
  end

  User.create!(
    **attrs,
    id:,
    email:,
    home_directory:   home_directory || "/submission/#{id}",
    inet_user_status: !email || email_num > 1 ? "inactive" : inet_user_status,
  )

  print "[CREATED] #{id}"
  print " (exists in ext ldap)" if ext
  print " (missing email)"      unless email
  print " (duplicated email)"   if email_num > 1
  puts

  puts JSON.generate(
    uid:       ext[:uid].first,
    uidNumber: ext[:uidNumber].first,
    gidNumber: ext[:gidNumber].first,
    cn:        ext[:cn].first
  ) if ext
rescue ActiveRecord::RecordInvalid => e
  warn e.record.errors.inspect

  raise
end

REDIS.call :set, "uid_number", users.map { it[:uid_number].to_i }.max
