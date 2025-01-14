#!/bin/bash

/var/scripts/authentication_config.sh
/var/scripts/kubernetes_config.sh

exec /usr/bin/tini -- /usr/local/bin/jenkins.sh
