#!/bin/bash

set -eu

. /opt/bitnami/scripts/libopenldap.sh
trap ldap_stop EXIT
ldap_start_bg

ldapmodify -a -Y EXTERNAL -H ldapi:/// -f /docker-entrypoint-initdb.d/ldifs/acl.ldif
ldapmodify -a -Y EXTERNAL -H ldapi:/// -f /docker-entrypoint-initdb.d/ldifs/lastbind.ldif
ldapmodify -a -Y EXTERNAL -H ldapi:/// -f /docker-entrypoint-initdb.d/ldifs/unique.ldif
