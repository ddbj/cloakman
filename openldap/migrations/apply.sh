#!/usr/bin/env bash
#
# cn=config に対してスキーマ更新 LDIF を適用する。
#
# 使い方:
#   LDAP_URI=ldap://localhost:1389 \
#   LDAP_CONFIG_ADMIN_DN='cn=admin,cn=config' \
#   LDAP_CONFIG_ADMIN_PASSWORD='...' \
#     openldap/migrations/apply.sh openldap/migrations/001_add_agd_dataset.ldif
#
# Kamal 本番/ステージングでは cloakman-openldap コンテナ内で実行する:
#   kamal accessory exec openldap -d staging --reuse \
#     "ldapmodify -H ldap://localhost:1389 -x -D \"$LDAP_CONFIG_ADMIN_USERNAME\" -w \"$LDAP_CONFIG_ADMIN_PASSWORD\" -f /schemas/../migrations/001_add_agd_dataset.ldif"
# （LDIF をコンテナにマウントするか docker cp で配置してから実行）

set -euo pipefail

: "${LDAP_URI:=ldap://localhost:1389}"
: "${LDAP_CONFIG_ADMIN_DN:=cn=admin,cn=config}"
: "${LDAP_CONFIG_ADMIN_PASSWORD:?LDAP_CONFIG_ADMIN_PASSWORD must be set}"

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <ldif> [<ldif>...]" >&2
  exit 1
fi

for ldif in "$@"; do
  echo "applying ${ldif}"
  ldapmodify -H "$LDAP_URI" -x -D "$LDAP_CONFIG_ADMIN_DN" -w "$LDAP_CONFIG_ADMIN_PASSWORD" -f "$ldif"
done
