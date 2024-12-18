#!/bin/bash
set -e

if [ ! -f "./bash-test.sh" ]; then
  curl -s "https://raw.githubusercontent.com/danielaauriema/bash-tools/master/lib/bash-test.sh" > "/opt/test/bash-test.sh"
fi
if [ ! -f "./bash-wait.sh" ]; then
  curl -s "https://raw.githubusercontent.com/danielaauriema/bash-tools/master/lib/bash-wait.sh" > "/opt/test/bash-wait.sh"
fi

. /opt/test/bash-wait.sh
. /opt/test/bash-test.sh

bash_test_header "jenkins-ldap :: wait for connection"
bash_wait_for_uri "${JENKINS_URL}" 30

bash_test_header "jenkins-ldap :: wait for ping"
bash_wait_for "curl -s -k -u ${LDAP_DEFAULT_USERNAME}:${LDAP_DEFAULT_PASSWORD} ${JENKINS_URL}/metrics/currentUser/ping | grep -q pong" 60

bash_test_header "All tests has finished successfully!!"