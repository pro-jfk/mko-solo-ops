# MKO-SoloOps

Getting started with industry-standard DevOps tools can sometimes be a challenge for solo students, especially because:
A. Setting up a cluster/cloud-platform is rarely necessary for solo projects and just adds complexity.
B. Many tools are either paid or require a credit card to access, with free tiers often falling short of delivering real-world experiences.

This guide is designed to lower the barrier to entry by focusing on two foundational areas of DevOps:

    GitOps
    CI/CD

Our goal is to make these concepts approachable by enabling you to practice almost entirely locally. While this guide doesn’t aim to be the “most efficient” or “correct” way to do things, it prioritizes hands-on learning. For example, GitOps has been chosen because it mirrors real-world workflows, where code repositories become the single source of truth for application and infrastructure changes. This practice not only simplifies deployments but also builds a strong foundation for understanding modern automation principles.

After all, running Kubernetes locally is already more than most solo projects demand—but that’s what makes it a great playground for learning.

---

## **Lab: From Code to Consumer - Deploying, Managing and Observing an app _locally_**

this basically what we'll do:

1. we'll setup the cluster and all services need to work for anyting steps further below.
2. In jenkins, when building a project a "job" must be created.
3. the gitops flow we simulate: push to main -> build gets triggered -> project gets build -> gets pushed to respective place

## Kubernetes

Kubernetes (often called "K8s") is a **tool to manage applications** that are made up of multiple containers.

If you're familiar with Docker Compose, think of Kubernetes as working on the same principle, but with significantly more power and flexibility for managing complex, large-scale applications.

To run Kubernetes locally, there are several options: Minikube, Kind, Docker Desktop, K3s, and Microk8s.
This guide will use Minikube because it offers a straightforward setup and is highly configurable, making it ideal for beginners and advanced users alike.

Install steps: [Get started](https://minikube.sigs.k8s.io/docs/start/)

Kubernetes is meant to manage multiple apps at once, so we also have to automate the Docker Build process using Pipelines.
Pipelines can be used for building, testing and pushing to any other artifact managers.

In this example we'll be using Jenkins.

1. Again highly configurable
2.

### **Step 1: Set Up Cloud Infrastructure with OpenTofu (Terraform)**

#### **1.1 Install  (Terraform)**


#### **1.3 Provision Infrastructure**

Run the following commands to initialize and apply the configuration:
```bash
terraform init
terraform apply
```
or
```bash
tofu init
tofu apply
```

After applying, you can get the Kubernetes credentials for `kubectl` access:


---

### **Step 2: Build and Publish Docker Images to Azure Container Registry**


DockerHub or GitHub registery

---


---

### **Step 4: Set Up CI/CD Pipeline**

#### **4.1 Create  Pipeline**


#### **5.1 Install Jenkins**


---

### **(OPtiONAL)Step 6: Monitor Your Application with Prometheus and Grafana**

To manage production workloads, monitoring is crucial.

#### **6.1 Install Prometheus and Grafana**

1. Install **Prometheus** and **Grafana** in your AKS cluster using Helm:

   ```bash
   helm install prometheus prometheus-community/kube-prometheus-stack
   helm install grafana grafana/grafana
   ```

2. Access Prometheus and Grafana dashboards to monitor application health, resource usage, etc.

---
