#!/bin/bash

@ Load config
+ Execute config.sh
(cd ../start && ./config.sh > /dev/null 2> /dev/null)

@ LDAP base

+ Test organization
slapcat -F "${LDAP_CONF_PATH}" -b "${LDAP_BASE_DN}" -a "(&(objectClass=organization)(dc=${LDAP_ORGANIZATION}))" | grep "dc: devops-tools"

+ Check LDAP data path: ${LDAP_DATA_PATH}
ls "${LDAP_DATA_PATH}" | grep "data.mdb"

+ Check for memberof module
slapcat -F "${LDAP_CONF_PATH}" -b "cn=config" -a "(objectClass=olcModuleList)" | grep memberof


+ Check for for refint module
slapcat -F "${LDAP_CONF_PATH}" -b "cn=config" -a "(objectClass=olcModuleList)" | grep refint

@ LDAP initialization

+ "Starting OpenLDAP..."
slapd -h "ldapi:/// ldap:///" -F "${LDAP_CONF_PATH}" && while ! ldapsearch -H "ldapi://" -Y EXTERNAL -b "${LDAP_BASE_DN}" 2>&1; do sleep 0.1; done

+ Test if bind user can authenticate
ldapwhoami -H "ldapi://" -D "cn=${LDAP_BIND_USERNAME},${LDAP_BASE_DN}" -w "${LDAP_BIND_PASSWORD}"

+ Test if default user can authenticate
ldapwhoami -H "ldapi://" -D "cn=${LDAP_DEFAULT_USERNAME},ou=users,${LDAP_BASE_DN}" -w "${LDAP_DEFAULT_PASSWORD}"

+ Test if default user is member of admin
ldapsearch -H "ldapi://" -D "cn=${LDAP_BIND_USERNAME},${LDAP_BASE_DN}" -w "${LDAP_BIND_PASSWORD}" -b "${LDAP_BASE_DN}" "(&(objectClass=posixAccount)(uid=${LDAP_DEFAULT_USERNAME})(memberof=cn=admin,ou=groups,${LDAP_BASE_DN}))" uid | grep "uid: ${LDAP_DEFAULT_USERNAME}"

+ Stopping OpenLDAP...
pkill slapd && echo "OK"

@ test_config finished successfully!