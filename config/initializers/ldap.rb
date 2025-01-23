LDAP = Net::LDAP.new(
  host: "localhost",
  port: 1389,

  auth: {
    method:   :simple,
    username: "cn=admin,dc=ddbj,dc=nig,dc=ac,dc=jp",
    password: "adminpassword"
  }
)
