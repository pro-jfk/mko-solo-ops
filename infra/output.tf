output "cluster_name" {
    description = "The name assigned to the k8s cluster [minikube]"
    value       = minikube_cluster.docker.cluster_name
}

output "cluster_context_hostname" {
    description = "The hostname of the k8s cluster [minikube]"
    value       = minikube_cluster.docker.host
}

output "cluster_context_cluster_ca_certificate" {
    description = "The Certificate of the k8s cluster [minikube]"
    value       = minikube_cluster.docker.cluster_ca_certificate
    sensitive   = true
}

output "cluster_context_client_certificate" {
    description = "The Client Certificate of the k8s cluster [minikube]"
    value       = minikube_cluster.docker.client_certificate
    sensitive   = true
}

output "cluster_context_client_key" {
    description = "The Client Key of the k8s cluster [minikube]"
    value       = minikube_cluster.docker.client_key
    sensitive   = true
}