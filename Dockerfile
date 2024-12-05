FROM jenkins/jenkins:2.479.1-lts-jdk21

# Install Jenkins plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Disable the setup wizard as we will set up Jenkins as code
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# Copy the Configuration as Code (CasC) YAML file into the image
COPY jenkins-ldap.yaml /var/jenkins_casc/jenkins-ldap.yaml

# Tell the Jenkins Configuration as Code plugin where to find the YAML file
ENV CASC_JENKINS_CONFIG="/var/jenkins_casc/jenkins-ldap.yaml"

# Set LDAP connection
ENV LDAP_SERVER="ldap://ldap-server"
ENV LDAP_BASE_DN="dc=jenkins,dc=local"
ENV LDAP_BIND_DN="cn=bind,${LDAP__BASE_DN}"
ENV LDAP_BIND_PASSWORD="password"

ENV JENKINS_URL="http://localhost:8080"
