#!/bin/bash
set -e
dynamic_credentials="$CASC_JENKINS_CONFIG/dynamic-credentials.yml"

prefix_str_cred="JENKINS_CREDENTIALS_"
prefix_gh_app_id="GH_APP_ID"
prefix_gh_app_token="GH_APP_TOKEN"
IFS=',' read -ra gh_apps <<<"$GH_APPS"

for var in $(env | grep "^$prefix_str_cred" | cut -d= -f1); do
    var_name="${var#$prefix_str_cred}"
    id=$(echo "$var" | tr '[:upper:]' '[:lower:]')
    secret="${!var}"

    credential_string_type="[{\"string\": {\"id\": \"$id\", \"secret\": \"$secret\", \"scope\": \"GLOBAL\"}}]"

    if yq -i ".credentials.system.domainCredentials[0].credentials += $credential_string_type" "$dynamic_credentials"; then
        echo "Added $var_name, id: $id, secret: $secret to $dynamic_credentials"
    else
        echo "Failed to add $var_name, id: $id, secret: $secret to $dynamic_credentials"
    fi

done

for app_name in "${gh_apps[@]}"; do
    name_uppercase=$(echo "$app_name" | tr '[:lower:]' '[:upper:]')
    app_id="${prefix_gh_app_id}_${name_uppercase}"
    app_token="${prefix_gh_app_token}_${name_uppercase}"

    credential_gh_app_type="[{\"gitHubApp\": {\"appID\": \"${!app_id}\", \"description\": \"Github app connected to $app_name\", \"id\": \"${app_name}_github\", \"privateKey\": \"${!app_token}\"}}]"

    if yq eval ".credentials.system.domainCredentials[0].credentials += $credential_gh_app_type" -i "$dynamic_credentials"; then
        echo "Added $app_name Github App to $dynamic_credentials"
    else
        echo "Failed to add $app_name Github App"
    fi
done
