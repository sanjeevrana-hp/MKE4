# Use the official Ubuntu image
FROM ubuntu:22.04

# Update package list and install required packages (Git, yq, jq)
RUN apt-get update && apt-get install -y \
    git \
    jq \
    curl \
    apt-transport-https \
    ca-certificates \
    lsb-release \
    vim \
    sudo \
    unzip \
    dnsutils \
    bash \
    gpg \
    software-properties-common \
    gnupg2 \
    iputils-ping

# Install mkectl 
# Download the script first
RUN curl -fsSL -o /tmp/mke-install.sh https://raw.githubusercontent.com/MirantisContainers/mke-release/refs/heads/main/install.sh


# Install yq (latest version)
RUN curl -sL https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o /usr/local/bin/yq && chmod +x /usr/local/bin/yq

# Installing aws-cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install && rm awscliv2.zip 


# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin/kubectl

# Install Helm
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Terraform
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && apt-get install -y terraform

# Install Flux CLI (Latest Version)
RUN curl -s https://fluxcd.io/install.sh | bash

# Create the MKE4 directory and clone the GitHub repository
RUN mkdir /MKE4 && git clone https://github.com/Mirantis/mke-docs.git /MKE4/mke-docs

# Define the terraform directory path
ENV TERRAFORM_DIR="/MKE4/mke-docs/content/docs/tutorials/k0s-in-aws/terraform"

# Copy terraform.tfvars.example to terraform.tfvars
RUN cp ${TERRAFORM_DIR}/terraform.tfvars.example ${TERRAFORM_DIR}/terraform.tfvars

# Create a soft link named "config" pointing to terraform.tfvars
RUN ln -s ${TERRAFORM_DIR}/terraform.tfvars /MKE4/config

# Modify terraform.tfvars with required values
RUN cat <<EOF > /MKE4/config
cluster_name = "k0s-cluster-$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 3 | head -n 1)"
controller_count = 1
worker_count = 1
cluster_flavor = "t2.large"
region = "ap-northeast-1"
EOF

RUN cd $TERRAFORM_DIR && \
    /bin/terraform init -input=false

# Set the working directory
WORKDIR /MKE4

# Copy apply.sh to /usr/local/bin/t
COPY apply.sh /usr/local/bin/t

# Set execute permission for the script
RUN chmod +x /usr/local/bin/t

# Set up aliases
RUN echo "alias k='kubectl'" >> ~/.bashrc && \
    echo 'export KUBECONFIG=/root/.mke/mke.kubeconf' >> /root/.bashrc

# Keep the container running
ENTRYPOINT ["/bin/bash"]
