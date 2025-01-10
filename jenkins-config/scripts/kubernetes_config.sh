#! /bin/bash
set -e
casc="$CASC_JENKINS_CONFIG/base_kubernetes.yml"
base_kubernetes_config='.jenkins.clouds[0].kubernetes += {"name": "kubernetes", "namespace": "jenkins", "serverUrl": "minikube", "credentialsId": "kubernetes-agent"}'

if [ -z "$KUBERNETES_CLOUD_NAME" ] || [ -z "$KUBERNETES_NAMESPACE" ] || [ -z "$KUBERNETES_SERVER_URL" ] || [ -z "$KUBERNETES_SA_TOKEN" ] || [ -z "$KUBERNETES_SERVER_CERT_KEY" ]; then
    truncate -s 0 "$casc"
    yq eval "$base_kubernetes_config" -i "$casc"
    echo "Added base credentials for the Kubernetes Plugin"
fi
