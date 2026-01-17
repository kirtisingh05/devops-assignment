FROM jenkins/jenkins:lts
USER root

# Install basic tools
RUN apt-get update && apt-get install -y wget unzip sudo

# --- Install Terraform ---
RUN wget https://releases.hashicorp.com/terraform/1.9.0/terraform_1.9.0_linux_amd64.zip \
    && unzip terraform_1.9.0_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_1.9.0_linux_amd64.zip

# --- Install Trivy (Security Scanner) ---
RUN wget https://github.com/aquasecurity/trivy/releases/download/v0.50.0/trivy_0.50.0_Linux-64bit.deb \
    && dpkg -i trivy_0.50.0_Linux-64bit.deb \
    && rm trivy_0.50.0_Linux-64bit.deb

USER jenkins