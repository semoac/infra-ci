FROM debian:buster

# SO Software
RUN apt update && apt install -y awscli wget unzip git vim curl make && apt clean all
RUN wget https://github.com/mozilla/sops/releases/download/v3.5.0/sops_3.5.0_amd64.deb \
    && dpkg -i sops_3.5.0_amd64.deb \
    && apt install -f \
    && rm sops_3.5.0_amd64.deb \
    && apt clean all

## Terraform
ENV PATH="/opt/tfenv/bin:$PATH"
RUN git clone --depth=1  https://github.com/tfutils/tfenv.git /opt/tfenv

## Helm
ENV HELMFILE_HELM3=1
COPY --from=alpine/helm:3.0.2 /usr/bin/helm /usr/local/bin/helm
COPY --from=quay.io/roboll/helmfile:helm3-v0.98.2 /usr/local/bin/helmfile /usr/local/bin/helmfile
RUN helm plugin install https://github.com/databus23/helm-diff --version master
RUN helm plugin install https://github.com/futuresimple/helm-secrets
RUN helm plugin install https://github.com/hypnoglow/helm-s3.git
RUN helm plugin install https://github.com/aslafy-z/helm-git.git

## KUBECTL
COPY --from=bitnami/kubectl:1.14 /opt/bitnami/kubectl/bin/kubectl /usr/local/bin/kubectl

## KUSTOMIZE
RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
RUN mv kustomize /usr/local/bin/kustomize

## KUBEVAL
ADD https://github.com/instrumenta/kubeval/releases/download/0.14.0/kubeval-linux-amd64.tar.gz /tmp/
RUN tar zxvf /tmp/kubeval-linux-amd64.tar.gz kubeval && mv kubeval /usr/local/bin/kubeval

## AWS-AUTH
ADD https://amazon-eks.s3-us-west-2.amazonaws.com/1.12.9/2019-06-21/bin/linux/amd64/aws-iam-authenticator /usr/local/bin/aws-iam-authenticator
RUN chmod +x /usr/local/bin/aws-iam-authenticator
