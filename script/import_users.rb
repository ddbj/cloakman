require_relative "../config/environment"

using LDAPAssertion

max_uid_number = -1

$stdin.each do |line|
  next if line.blank?

  user       = JSON.parse(line, symbolize_names: true)
  uid_number = user[:uid_number].to_i

  max_uid_number = uid_number if uid_number > max_uid_number

  LDAP.connection.assert_call :add, **{
    dn: "uid=#{user[:username]},#{User.users_dn}",

    attributes: {
      objectclass: %w[
        ddbjUser
        ldapPublicKey
        posixAccount
        inetUser
      ],

      uid:                              user[:username],
      userPassword:                     user[:password],
      mail:                             user[:email],
      givenName:                        user[:first_name],
      "givenName;lang-ja":              user[:first_name_japanese],
      middleName:                       user[:middle_name],
      surname:                          user[:last_name],
      "surname;lang-ja":                user[:last_name_japanese],
      cn:                               user.values_at(:first_name, :middle_name, :last_name).compact_blank.join(" "),
      title:                            user[:job_title],
      "title;lang-ja":                  user[:job_title_japanese],
      orcid:                            user[:orcid],
      eradID:                           user[:erad_id],
      organizationName:                 user[:organization],
      "organizationName;lang-ja":       user[:organization_japanese],
      organizationalUnitName:           user[:lab_fac_dep],
      "organizationalUnitName;lang-ja": user[:lab_fac_dep_japanese],
      organizationURL:                  user[:organization_url],
      countryName:                      user[:country],
      postalCode:                       user[:postal_code],
      stateOrProvinceName:              user[:prefecture],
      localityName:                     user[:city],
      streetAddress:                    user[:street],
      telephoneNumber:                  user[:phone],
      sshPublicKey:                     user[:ssh_keys],
      accountTypeNumber:                user[:account_type_number],
      uidNumber:                        user[:uid_number],
      gidNumber:                        user[:gid_number],
      homeDirectory:                    user[:home_directory],
      loginShell:                       user[:login_shell],
      inetUserStatus:                   user[:inet_user_status]
    }.compact_blank
  }

  puts "User #{user[:username]} created"
rescue LDAPError::EntryAlreadyExists
  warn "User #{user[:username]} already exists"
end

REDIS.call :set, "uid_number", max_uid_number
