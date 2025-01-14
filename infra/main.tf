terraform {
  required_providers {
    minikube = {
      source  = "scott-the-programmer/minikube"
      version = "0.4.4"
    }
  }
}

provider "minikube" {
  kubernetes_version = "v1.30.0"
}

resource "minikube_cluster" "docker" {
  driver       = "docker"
  cluster_name = "minikube"
  addons = [
    "default-storageclass",
    "storage-provisioner"
  ]
}

provider "kubernetes" {
  host                   = minikube_cluster.docker.host
  client_certificate     = minikube_cluster.docker.client_certificate
  client_key             = minikube_cluster.docker.client_key
  cluster_ca_certificate = minikube_cluster.docker.cluster_ca_certificate
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx-loadbalancer"
    labels = {
      App = "Nginx-LoadBalancer"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "Nginx-LoadBalancer"
      }
    }
    template {
      metadata {
        labels = {
          App = "Nginx-LoadBalancer"
        }
      }
      spec {
        container {
          image = "nginx:latest"
          name  = "nginx"

          port {
            container_port = 80
            protocol       = "TCP"
          }

          volume_mount {
            name       = "nginx-config"
            mount_path = "/etc/nginx/conf.d"
          }
        }

        volume {
          name = "nginx-config"
          config_map {
            name = kubernetes_config_map.nginx_config.metadata[0].name
          }

        }
      }
    }
  }
}

resource "kubernetes_service" "nginx_service" {
  metadata {
    name = "nginx-service"
    labels = {
      App = "Nginx-LoadBalancer"
    }
  }

  spec {
    selector = {
      App = "Nginx-LoadBalancer"
    }

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }

    type = "NodePort"
  }
}

resource "kubernetes_config_map" "nginx_config" {
  metadata {
    name = "nginx-config"
  }

  data = {
    "default.conf" = <<-EOT
      server {
          listen 443;

          location / {
              proxy_pass http://jenkins-service:8080;

              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-Port $server_port;
              proxy_set_header X-Forwarded-Proto $scheme;

              # Rewrite the Location header in Jenkins responses
              proxy_redirect http://jenkins-service:8080/ /;
          }
      }
      EOT
  }
}

resource "kubernetes_deployment" "jenkins" {
  metadata {
    name = "jenkins"
    labels = {
      App = "Jenkins"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "Jenkins"
      }
    }
    template {
      metadata {
        labels = {
          App = "Jenkins"
        }
      }
      spec {
        service_account_name = kubernetes_service_account.jenkins.metadata[0].name
        container {
          name  = "jenkins"
          image = "projfk/jenkins:latest"

          env {
            name  = "LOCAL_DEVELOPMENT"
            value = "true"
          }
          env {
            name  = "JENKINS_ADMIN_USER"
            value = var.JENKINS_ADMIN_USER
          }

          env {
            name  = "JENKINS_ADMIN_PASSWD"
            value = var.JENKINS_ADMIN_PASSWD
          }

          env {
            name  = "KUBERNETES_CLOUD_NAME"
            value = var.KUBERNETES_CLOUD_NAME
          }

          #   env {
          #     name  = "KUBERNETES_SERVER_URL"
          #     value = var.KUBERNETES_SERVER_URL
          #   }

          port {
            container_port = 8080
          }

          port {
            container_port = 50000
          }


          resources {
            limits = {
              cpu    = "1"
              memory = "1024Mi"
            }
            requests = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
          volume_mount {
            name       = "jenkins-sa-token"
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
            read_only  = true
          }
        }

        volume {
          name = "jenkins-sa-token"

          secret {
            secret_name = kubernetes_secret.jenkins_sa_token.metadata[0].name
          }
        }
      }
    }

  }
}

resource "kubernetes_service" "jenkins" {
  metadata {
    name = "jenkins-service"
    labels = {
      App = "Jenkins"
    }
  }

  spec {
    selector = {
      App = "Jenkins"
    }

    port {
      protocol    = "TCP"
      port        = 8080
      target_port = 8080
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service_account" "jenkins" {
  metadata {
    name      = "jenkins-service-account"
    namespace = "default"
  }
}

resource "kubernetes_role" "jenkins" {
  metadata {
    name      = "jenkins-role"
    namespace = "default"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "endpoints", "configmaps", "secrets", "deployments", "pods/exec", "pods/log","persistentvolumeclaims"]
    verbs      = ["get", "list", "watch", "create", "update", "delete"]
  }
}

resource "kubernetes_role_binding" "jenkins" {
  metadata {
    name      = "jenkins-role-binding"
    namespace = "default"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.jenkins.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.jenkins.metadata[0].name
    namespace = kubernetes_service_account.jenkins.metadata[0].namespace
  }
}

resource "kubernetes_secret" "jenkins_sa_token" {
  metadata {
    name      = "jenkins-sa-token"
    namespace = "default"
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.jenkins.metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"
}
