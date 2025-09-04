require_relative '../config/environment'

using LDAPAssertion

User.all.each do |user|
  next unless user.ext_ldap_entry

  ExtLDAPSink.connection.assert_call :delete, dn: "uid=#{user.id},#{ExtLDAPSink.base_dn}"
end
