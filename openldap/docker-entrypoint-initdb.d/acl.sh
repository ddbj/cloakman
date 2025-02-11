#!/bin/sh

set -eu

. /opt/bitnami/scripts/libopenldap.sh
trap ldap_stop EXIT
ldap_start_bg

cat <<EOF > /tmp/acl.ldif
dn: olcDatabase={2}mdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {0}to * attrs=userPassword
  by * auth
olcAccess: {1}to dn.subtree="ou=users,dc=ddbj,dc=nig,dc=ac,dc=jp"
  by dn.one="ou=readers,dc=ddbj,dc=nig,dc=ac,dc=jp" read
olcAccess: {2}to *
  by * none
EOF

ldapmodify -a -Y EXTERNAL -H ldapi:/// -f /tmp/acl.ldif
rm /tmp/acl.ldif
