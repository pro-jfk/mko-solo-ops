# MKO-SoloOps

Getting started with industry-standard DevOps tools can be challenging for solo students, especially because:

1. Setting up a cluster or cloud platform is rarely necessary for solo projects and often adds unnecessary complexity.
2. Many tools are paid or require a credit card, and free tiers often fail to deliver a realistic, hands-on experience.

This guide is designed to lower the barrier to entry by focusing on two foundational areas of DevOps:

- GitOps
- CI/CD

The goal of this project is to make these concepts approachable by enabling you to practice almost entirely locally. While this guide doesn’t aim to be the “most efficient” or “correct” way to do things, it prioritizes hands-on learning. For example, GitOps has been chosen because it mirrors real-world workflows, where code repositories become the single source of truth for application and infrastructure changes. This practice not only simplifies deployments but also builds a strong foundation for understanding modern automation principles.

After all, running Kubernetes locally is already more than most solo projects demand—but that’s what makes it a great playground for learning.

---

This lab will walk you through the following:

1. Cluster and Service Setup: We'll set up the cluster and all necessary services to enable the steps outlined below.
2. Setup Jenkins.
3. Simulating the GitOps Flow: We’ll simulate the following workflow:
   Push to main → Build Triggered → Project Built → Artifact Pushed to its Destination.

## Kubernetes

Kubernetes (often called "K8s") is a **tool to manage applications** that are made up of multiple containers.

If you're familiar with Docker Compose, think of Kubernetes as working on the same principle, but with significantly more power and flexibility for managing complex, large-scale applications.

To run Kubernetes locally, there are several options: Minikube, Kind, and K3s.
This guide will use Minikube because it provides a straightforward setup and is highly configurable, making it suitable for beginners and advanced users alike. Minikube also offers one of the closest real-world experiences among local Kubernetes solutions, providing more features compared to Kind and K3s. However, it is worth noting that Minikube is a known resource hog.

Install steps: [Get started](https://minikube.sigs.k8s.io/docs/start/)

Kubernetes is designed to manage multiple applications at once, so automation of processes like Docker builds, testing, and artifact management is essential. This is where Pipelines come into play.

In this example, we will use Jenkins to automate these processes. Although more old, it still holds the largest market share in CI/CD solutions and is highly configurable.

### **Step 1: Set Up "Cloud" Infrastructure with Terraform**

You can use either **Terraform** or **OpenTofu** for this step. While Terraform is no longer fully open source, many users still prefer it, whereas OpenTofu is a truly open-source alternative.

#### Install Terraform or OpenTofu:

Follow the respective installation guides:

- [Terraform Installation](https://developer.hashicorp.com/terraform/install)
- [OpenTofu Installation](https://opentofu.org/)

Once installed, initialize and apply the configuration:

For Terraform:

```bash
terraform init
source .env && terraform apply
```

or

```bash
tofu init
source .env && tofu apply
```

After applying the configuration, you can use the following command to access the Minikube dashboard:

```
minikube dashboard
```

## Step 2: Start Nginx Service for Jenkins

After applying the Terraform configurations, start the Nginx service to make Jenkins accessible:

```
minikube service nginx-service --url -n jenkins

```

Environment variables and configuratins about jenkins can be found in the jenkins-config README.

## Step 3: Configure Jenkins for Cluster Access

Jenkins uses pods as builders/runners, so it requires access to the Kubernetes cluster. While all RBAC configurations are handled by Terraform, you will need to manually retrieve and enter the credentials in Jenkins.
Retrieve the Service Account Token:

Run the following command:

```
kubectl describe secret $(kubectl get secret -n jenkins | grep jenkins-service-account | awk '{print $1}') -n jenkins
```

And retrieve the server certificate from:
_~/.minikube/ca.crt_

Then convert it base64 using:

```
 cat ~/.minikube/ca.crt | base64 -w 0; echo
```

Both of these need to be added to the Cloud configuration of Jenkins.

A detailed guide can be found [here](https://plugins.jenkins.io/kubernetes/#plugin-content-configuration-on-minikube)

---

### **(Optional)Step Monitor Your Application with Prometheus and Grafana**

To manage production workloads, monitoring is crucial. If you want to include Prometheus and Grafana, add the contents of `monitoring.tf` to `main.tf`.
