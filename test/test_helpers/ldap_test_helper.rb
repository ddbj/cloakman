using LDAPAssertion

module LDAPTestHelper
  def reset_ldap
    User.all.each(&:destroy!)
    Reader.all.each(&:destroy!)
  end

  def reset_ext_ldap
    ExtLDAP.connection.assert_call(:search, **{
      base:   ExtLDAP.base_dn,
      filter: Net::LDAP::Filter.eq('objectClass', 'account')
    }).each do |entry|
      ExtLDAP.connection.assert_call :delete, dn: entry.dn
    end
  end
end
