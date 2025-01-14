#!/bin/bash
set -e

security_realm="$CASC_JENKINS_CONFIG/security-realm.yml"
local_config='{"local": {"allowsSignup": false, "enableCaptcha": false, "users": [{"id": "${JENKINS_ADMIN_USER}", "name": "${JENKINS_ADMIN_USER}", "password": "${JENKINS_ADMIN_PASSWD}"}]}}'

if [ -z "$JENKINS_ADMIN_USER" ] || [ -z "$JENKINS_ADMIN_PASSWD" ]; then

    user="admin"
    new_password=$(
        tr -dc A-Za-z0-9 </dev/urandom | head -c 13
        echo ''
    )
    local_config='{"local": {"allowsSignup": false, "enableCaptcha": false, "users": [{"id": "'$user'", "name": "'$user'", "password": "'$new_password'"}]}}'

    echo "JENKINS_ADMIN_USER and JENKINS_ADMIN_PASSWD were not set."
    echo "An admin has been created with username:$user and password:$new_password"
fi

yq ".jenkins.securityRealm += $local_config" -i "$security_realm"
echo "Added Local Credentials to security-realm.yml"
