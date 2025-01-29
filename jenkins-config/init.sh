#!/bin/bash

/var/scripts/authentication_config.sh

exec /usr/bin/tini -- /usr/local/bin/jenkins.sh
