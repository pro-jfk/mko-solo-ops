# harborn-jenkins

Repository containing the configuration for Jenkins

## _JCASC_ (Jenkins-Configuration-as-Code)

[Jenkins Configuration as Code](https://github.com/jenkinsci/configuration-as-code-plugin/blob/master/README.md) provides the ability to define a whole Jenkins configuration as a simple, human-friendly, plain text yaml syntax. To use _JCasC_ a there are a few prerequisites:

- The [Configuration as Code plugin](https://plugins.jenkins.io/configuration-as-code/) must be installed in the Jenkins instance
- The plugin looks for the `CASC_JENKINS_CONFIG` environment variable (which is already set in the Jenkins Dockerfile). The variable points to a comma-separated list of any of the following:
  - Path to a folder containing a set of config files. For example, /var/jenkins_home/casc_configs.
  - A full path to a single file. For example, /var/jenkins_home/casc_configs/jenkins.yml.
  - A URL pointing to a file served on the web. For example, https://utilities.harborn.com/jenkins.yaml.

This repository contains a `jcasc` directory, housing configuration files that each manage different aspects of Jenkins. Files with a `base` prefix are not configured with scripts.

### User Access Control

Jenkins offers various methods for user access control, but Harborn Jenkins leverages _Role-based access control_ (RBAC). RBAC is configured through _JCasC_ and utilizes environment variables (_JENKINS_DEVELOPERS_, \_JENKINS_MAINTAINERS), via pattern recognition, to assign roles to the appropriate users. These users are managed through the GitHub OAuth App. The `dynamic-rbac.yml` configuration file handles RBAC.

Currently these roles are defined:  
**_admin_** : Harborn Digital's **sudo** user.  
**_developers_** : Harborn Digital's developers.  
**_maintainers_**: Members of Team Infra & Platform (and any other concerned parties)

### Credentials

To ensure that Jenkins can seamlessly interact with various integrations like DockerHub and Terraform Cloud, it's essential to configure the appropriate credentials. The configuration is facilitated through the `dynamic_credentials.yml`-file (_JCasC_). These credentials need to be correctly set (before startup) as system variables to ensure Jenkins can access them.

When adding a new credential to Jenkins, follow these steps:

1. Create a new environment variable with the prefix **JENKINS_CREDENTIALS**. For example, **JENKINS_CREDENTIALS_HARBORN_SECRET=password123**.

2. After the environment variable is added, Jenkins will need to be redeployed. This triggers the `credentials_config.sh` script, which in turn adds the new credentials to `dynamic_credentials.yml`.

## Environment Variables

Harborn Jenkins is fully customized through environment variables, including access control and credentials. Below is a reference table containing the essential environment variables:

| Environment Variables               | Description                                                                                                                                                                                                                                                                                                                                                                   |
| :---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| LOCAL_DEVELOPMENT                   | If set to true, it generates an admin user with JENKINS_ADMIN_USERNAME and JENKINS_ADMIN_PASSWD as login credentials. If set to false, it configures Jenkins the use GitHub App. The GITHUB_OAUTH_CLIENT_ID and GITHUB_OAUTH_SECRET environment variables need to be set. By default, when this variable isn't set, Jenkins will be configured to use a GitHub App for OAuth. |
| JENKINS_ADMIN_USERNAME              | The username for the local Jenkins User.                                                                                                                                                                                                                                                                                                                                      |
| JENKINS_ADMIN_PASSWD                | The password for the local Jenkins User.                                                                                                                                                                                                                                                                                                                                      |
| GITHUB_OAUTH_CLIENT_ID              | GitHub OAuth Client ID (Settings/Developer Settings on GitHub).                                                                                                                                                                                                                                                                                                               |
| GITHUB_OAUTH_SECRET                 | GitHub OAuth secret (Settings/Developer Settings on GitHub).                                                                                                                                                                                                                                                                                                                  |
| GITHUB_APP_ID                       | App ID from the GitHub App (Settings/Developer Settings on GitHub).                                                                                                                                                                                                                                                                                                           |
| GITHUB_APP_TOKEN                    | The secret from the GitHub App (Settings/Developer Settings on GitHub). Note that this token is in a `.pem` format, so proper formatting is crucial for its utility. In **Kubernetes** this token needs to be added as an _Opaque Secret_ (where the key, for example, is 'github-token' and the value is the private key itself).                                            |
| JENKINS_ADMINS                      | Comma seperated list of users or groups that will be added with admin privileges. For example: "_Harborn-digital\*team-infra_", "_harborn-deploy_"                                                                                                                                                                                                                            |
| JENKINS_DEVELOPERS                  | Comma seperated list of users or groups that will be added with developer privileges.                                                                                                                                                                                                                                                                                         |
| JENKINS_MAINTAINERS                 | Comma seperated list of users or groups that will be added with maintainer privileges.                                                                                                                                                                                                                                                                                        |
| AWS_CREDENTIALS_S3_ARTIFACTS_KEY    | Amazon S3-bucket access key                                                                                                                                                                                                                                                                                                                                                   |
| AWS_CREDENTIALS_S3_ARTIFACTS_SECRET | Amazon S3-bucket secret key                                                                                                                                                                                                                                                                                                                                                   |
| TFE_TOKEN                           | Terraform Cloud Token                                                                                                                                                                                                                                                                                                                                                         |
| PRIVATE_PYPI_SECRET                 | PyPi Server secret for Harborn user                                                                                                                                                                                                                                                                                                                                           |
| PRIVATE_PYPI_USER                   | PyPi Server user for Harborn user                                                                                                                                                                                                                                                                                                                                             |
| KUBERNETES_CLOUD_NAME               | Within Jenkins, the name of the cloud. Default is _kubernetes_                                                                                                                                                                                                                                                                                                                |
| KUBERNETES_SERVER_URL               | Kubernetes API address.                                                                                                                                                                                                                                                                                                                                                       |
| KUBERNETES_NAMESPACE                | The namespace in which the pods will be created.                                                                                                                                                                                                                                                                                                                              |
| KUBERNETES_SA_TOKEN                 | The token for the Kubernetes Service Account                                                                                                                                                                                                                                                                                                                                  |
| KUBERNETES_SERVER_CERT_KEY          | The server certificate stored in Amazon EKS                                                                                                                                                                                                                                                                                                                                   |

## Build utilities

### Agents/Slaves/Builders

Using the [_kubernetes_](https://plugins.jenkins.io/kubernetes/)-plugin, Jenkins Agents will be launched as Pods. The [_jenkins-builder-library_](https://github.com/Harborn-digital/jenkins-builder-library) houses all the configuration for these agents (including the pod templates). Currently there is a terraform, serverless and kaniko agent.  
This plugin also has some prerequisites for it to work correctly:

- A Service Account with sufficient privileges, that are defined by a _Role(binding)_ (example at: kubernetes-examples/resources.yml)
- `KUBERNETES_CLOUD_NAME`, `KUBERNETES_SERVER_URL`, `KUBERNETES_NAMESPACE`, `KUBERNETES_SA_TOKEN` and `KUBERNETES_SERVER_CERT_KEY` all must be set.

**_Note_** The kaniko agent expects the DockerHub/ECR credentials (config.json) to be mounted as a file at `/kaniko/.docker`. In Kubernetes, this done through a ConfigMap.

config.json:

```
{
    "auths": {

        "https://index.docker.io/v1/": {
            "auth": "harborn:123 -> base64 encoded",
            "password": "123",
            "username": "harborn"
          }
        },
        "credStore": "ecr-login"
    }
```

This repository contains a _kubernetes-examples_ folder that houses some examples containing the use of dynamic agents. It also has a dedicated _base_kubernetes.yml_ file in _JCasC_ that configures the plugin and the necessary information.

#### Build Tools

Pods that are responsible for building images require a build tool. Typically this would be Docker (Buildkit), but for it to work in pods (or any other containerized environment), the host Docker daemon needs to be mounted into the pods. This method poses significant security risks and is not considered a best practice.

To address this concern, an alternative has been found, [kaniko](https://github.com/GoogleContainerTools/kaniko/). _kaniko_ doesn't depend on a Docker daemon and executes each command within a Dockerfile completely in userspace. _kaniko_ is meant to be run as a container itself and builds images from a Dockerfile, inside a container or Kubernetes cluster.
From the documentation:

> The kaniko executor image is responsible for building an image from a Dockerfile and pushing it to a registry. Within the executor image, we extract the filesystem of the base image (the FROM image in the Dockerfile). We then execute the commands in the Dockerfile, snapshotting the filesystem in userspace after each one. After each command, we append a layer of changed files to the base image (if there are any) and update image metadata.

## Local Development

To develop locally you need to create a `.env` file based on the `env.dist`-file and add the correct credentials. Note that **_not_** all of them may be required for your build. Below, you'll find a reference table:

| Environment Variables               | Locally Mandatory |
| :---------------------------------- | ----------------: |
| LOCAL_DEVELOPMENT                   |               YES |
| JENKINS_ADMIN_USERNAME              |               YES |
| JENKINS_ADMIN_PASSWD                |               YES |
| GITHUB_OAUTH_CLIENT_ID              |                NO |
| GITHUB_OAUTH_SECRET                 |                NO |
| GITHUB_APP_TOKEN                    |                NO |
| GITHUB_APP_ID                       |                NO |
| JENKINS_ADMIN_GROUP                 |                NO |
| JENKINS_DEVELOPERS_GROUP            |                NO |
| JENKINS_MAINTAINERS_GROUP           |                NO |
| AWS_CREDENTIALS_S3_ARTIFACTS_KEY    |                NO |
| AWS_CREDENTIALS_S3_ARTIFACTS_SECRET |                NO |
| TFE_TOKEN                           |                NO |
| PRIVATE_PYPI_USER                   |                NO |
| KUBERNETES_SERVER_CERT_KEY          |                NO |
| KUBERNETES_CLOUD_NAME               |                NO |
| KUBERNETES_SERVER_URL               |                NO |
| KUBERNETES_NAMESPACE                |                NO |
| KUBERNETES_SA_TOKEN                 |                NO |

To ensure a smooth setup, _docker-compose_ is advised. After installing it and configuring the necessary environment variables, run `docker compose up`. If `JENKINS_ADMIN_USERNAME` and `JENKINS_ADMIN_PASSWD` are not provided, a random admin user will be generated and it's credentials can be found in the logs or in the `/var/jenkins_casc/security-realm.yml` file.

#### Kubernetes

If you also want to make use of dynamic agents using Kubernetes locally:

1. Install [minikube](https://minikube.sigs.k8s.io/docs/start/) or any other tool to use Kubernetes locally.
2. Create a kubernetes namespace using `kubectl create namespace <namespace>`. Replace `<namespace>` with an actual name.
3. The kubernetes folder contains some preconfigured resources, apply them using `kubectl apply -f kubernetes/resources.yml -n <namespace>`
4. Retrieve your token using `kubectl describe secrets -n jenkins | grep token:` and add it to the `KUBERNETES_SA_TOKEN ` environment variable.
5. Update your `.env`-file:
   - KUBERNETES_CLOUD_NAME=kubernetes
   - KUBERNETES_SERVER_URL=https://minikube:8443
   - KUBERNETES_NAMESPACE=`<namespace>`
   - JENKINS_URL=http://jenkins:8080 (normally this isn't necessary, but it's included here to ensure proper functionality in this setup.)
     The reason for this configuration is explained in the next step.
6. As _docker-compose_ and _minikube_ run on different networks, they can't communicate. To resolve this, you can add the _jenkins_ container (after running `docker compose up`) to the _minikube_ network using `docker network connect minikube jenkins`.

Some things to watch out for when testing _kaniko_ locally:

- When using local build contexts (instead of GitHub repositories), mount the local directory into the host.
- Secrets have to be added through `kubectl create secret ...` (DockerHub, GitHub) and added as a volume. For example: DockerHub  
  The command: `kubectl create secret docker-registry docker-credentials --docker-username=[userid] --docker-password=[Docker Hub access token] --docker-email=[user email address]`
  ```
    apiVersion: v1
    kind: Pod
    metadata:
        name: kaniko
    spec:
        containers:
         - name: kaniko
           image: gcr.io/kaniko-project/executor:debug
           volumeMounts:
             - name: kaniko-secret
               mountPath: /kaniko/.docker
        volumes:
          - name: kaniko-secret
            secret:
                secretName: docker-credentials
                items:
                  - key: .dockerconfigjson
                    path: config.json
  ```

## JENKINS LTS

Every 12 weeks LTS get **released/chosen** by the Jenkins Maintainers. Once a version is selected as the LTS baseline, a feature freeze is imposed. This means that no new features are added to the LTS baseline. This freeze helps maintain stability.  
During the LTS cycle, focus shifts to maintenance and backporting of important bug fixes, security patches, and critical updates from the mainline Jenkins releases. This process ensures that the LTS version remains secure and reliable.

Harborn Jenkins will keep up with this LTS and that automatically.

_Note_: Although an LTS gets chosen every 12 weeks, there will also be biweekly patches to maintain and enhance it.

## Plugins

Jenkins can be fully customized using plugins to extend its functionality. To provision the plugins that Harborn needs, the `plugins_config.sh` script is provided. When adding a plugin, please ensure that you use its ID rather than the name of the plugin. You can find the plugin ID at https://plugins.jenkins.io/plugin-name. Here's how to use it:

Installing Plugins: To add a plugin, simply include it as a string in the `install` list in the script.

Uninstalling Plugins: If you need to remove a plugin that was installed as an extra, add it to the `uninstall` list in the script.
