using LDAPAssertion

module User::ExtLDAPSync
  extend ActiveSupport::Concern

  included do
    after_create do
      add_ext_ldap_entry
    rescue LDAPError::EntryAlreadyExists
      modify_ext_ldap_entry
    end

    after_update do
      modify_ext_ldap_entry
    rescue LDAPError::NoSuchObject
      add_ext_ldap_entry
    end

    after_destroy do
      ExtLDAPSink.connection.assert_call :delete, dn: "uid=#{id},#{ExtLDAPSink.base_dn}"
    rescue LDAPError::NoSuchObject
      # do nothing
    end
  end

  private

  def add_ext_ldap_entry
    ExtLDAPSink.connection.assert_call :add, **{
      dn: "uid=#{id},#{ExtLDAPSink.base_dn}",

      attributes: {
        objectClass:   %w[account posixAccount],
        uid:           id,
        cn:            full_name,
        userPassword:  password_digest,
        uidNumber:     uid_number.to_s,
        gidNumber:     gid_number.to_s,
        homeDirectory: home_directory,
        loginShell:    login_shell
      }
    }
  end

  def modify_ext_ldap_entry
    ExtLDAPSink.connection.assert_call :modify, **{
      dn: "uid=#{id},#{ExtLDAPSink.base_dn}",

      operations: [
        [ :replace, :cn,            full_name ],
        [ :replace, :userPassword,  password_digest ],
        [ :replace, :uidNumber,     uid_number.to_s ],
        [ :replace, :gidNumber,     gid_number.to_s ],
        [ :replace, :homeDirectory, home_directory ],
        [ :replace, :loginShell,    login_shell ]
      ]
    }
  end
end
