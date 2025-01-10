FROM jenkins/jenkins:lts-jdk17


USER root
ARG yq_utility=https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64

RUN apt-get update && apt-get install -y \
    wget \
    neovim \
    nano

RUN wget ${yq_utility} -O /usr/bin/yq && \
    chmod +x /usr/bin/yq

USER jenkins

COPY --chown=jenkins:jenkins ./scripts /var/scripts

RUN echo 2.0 >/usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
RUN /var/scripts/plugins_config.sh

ARG CASC_JENKINS_CONFIG=/var/jenkins_casc
ENV CASC_JENKINS_CONFIG=${CASC_JENKINS_CONFIG}
ENV CASC_MERGE_STRATEGY=errorOnConflict
COPY --chown=jenkins:jenkins ./jcasc ${CASC_JENKINS_CONFIG}

COPY --chown=jenkins:jenkins ./docker-resources/bootstrap.sh /var/bootstrap.sh
ENTRYPOINT ["/var/bootstrap.sh"]
