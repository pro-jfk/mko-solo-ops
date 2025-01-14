#!/bin/bash
set -e
install=(
    "amazon-ecr"
    "artifact-manager-s3"
    "basic-branch-build-strategies"
    "build-timeout"
    "cloudbees-folder"
    "command-launcher"
    "configuration-as-code"
    "copyartifact"
    "discard-old-build"
    "docker-workflow"
    "envinject"
    "favorite"
    "git-parameter"
    "github-oauth"
    "golang"
    "handy-uri-templates-2-api"
    "htmlpublisher"
    "javax-mail-api"
    "jdk-tool"
    "job-dsl"
    "kubernetes"
    "matrix-auth"
    "pipeline-github-lib"
    "pipeline-stage-view"
    "pipeline-utility-steps"
    "popper2-api"
    "rebuild"
    "role-strategy"
    "sse-gateway"
    "ssh-slaves"
    "sshd"
    "timestamper"
    "workflow-aggregator"
    "ws-cleanup"
)

uninstall=("blueocean" "javascript-gui")

for plugin in "${install[@]}"; do
    echo "Installing $plugin"
    jenkins-plugin-cli --plugins "$plugin"
done

for plugin in "${uninstall[@]}"; do
    echo "$plugin" >"/usr/share/jenkins/ref/plugins/$plugin.jpi.disabled"
    echo "Plugin '$plugin' has been unistalled"
done
