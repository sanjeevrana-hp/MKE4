#!/bin/bash
# Author: Sanjeev Rana
# Version: 1.0

# Main script for creating Infrastructure and managing MKE4

#if [ $# -ne 2 ]; then
#    echo "Usage: $0 <destroy|reset|apply|deploy> <service>"
#    exit 1
#fi

action=$1
service=$2

case "$action" in
  destroy)
    case "$service" in
      lab)
        echo "Running terraform destroy..."
        cd /MKE4/mke-docs/content/docs/tutorials/k0s-in-aws/terraform || exit 1
        terraform destroy --auto-approve
        ;;
      *)
        echo "Invalid option"
        exit 1
        ;;
    esac
    ;;

  reset)
    case "$service" in
      lab)
        echo "Running mkectl reset..."
        cd /MKE4/mke-docs/content/docs/tutorials/k0s-in-aws/terraform || exit 1
        mkectl reset -f mke4.yaml
        ;;
      *)
        echo "Invalid option"
        exit 1
        ;;
    esac
    ;;

  apply)
    case "$service" in
      lab)
        echo "Running mkectl apply..."
        cd /MKE4/mke-docs/content/docs/tutorials/k0s-in-aws/terraform || exit 1
        mkectl apply -f mke4.yaml
        ;;
      *)
        echo "Invalid option"
        exit 1
        ;;
    esac
    ;;

  deploy)
    case "$service" in
      lab)
        echo "Deploying mkectl, k0sctl..."
        if [ -f /tmp/mke-install.sh ]; then
            chmod +x /tmp/mke-install.sh
            sh /tmp/mke-install.sh
        else
            echo "File not found. Please install mkectl, k0sctl manually."
            echo 'Reference: sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/MirantisContainers/mke-release/refs/heads/main/install.sh)"'
            exit 1
        fi

        echo "Changing to Terraform directory..."
        cd /MKE4/mke-docs/content/docs/tutorials/k0s-in-aws/terraform || exit 1

        echo " Initializing Terraform..."
        terraform init

        echo "Applying Terraform configuration..."
        terraform apply -auto-approve

        echo "Extracting k0s cluster details..."
        terraform output --raw k0s_cluster > VMs.yaml

        echo "Initializing MKE configuration..."
        mkectl init > mke4.yaml

        echo "Updating hosts in mke4.yaml..."
        yq -i '.spec.hosts = (load("VMs.yaml") | .spec.kubernetes.infra.hosts)' mke4.yaml

        echo "Retrieving Load Balancer DNS Name..."
        LB_DNS_NAME=$(terraform output -raw lb_dns_name)
        if [ -n "$LB_DNS_NAME" ]; then
            echo "Updating externalAddress in mke4.yaml with $LB_DNS_NAME..."
            yq -i ".spec.apiServer.externalAddress = \"$LB_DNS_NAME\"" mke4.yaml
        else
            echo "Error: Failed to retrieve Load Balancer DNS Name"
            exit 1
        fi

        echo " Applying MKE configuration..."
        mkectl apply -f mke4.yaml -l debug

        echo "Terraform and MKE configuration applied successfully."
        echo "======================================================="
        echo "Load Balancer URL for MKE Dashboard:"
        echo "-----------------------------------------------------"
        terraform output -raw lb_dns_name
        echo "\n-----------------------------------------------------"
        ;;
      *)
        echo "Invalid Option"
        exit 1
        ;;
    esac
    ;;

  *)
    echo "Invalid option. Please use the -h to know the right options"
    ;;
esac



Help()
{
   echo "Here's the options:"
   echo "------------------------"
   echo "------------------------"
   echo "t deploy lab   Deploy the infrastructure and install a fresh MKE4 cluster."
   echo "t delete lab   Delete the infrastructure along with the MKE4 cluster."
   echo "t apply lab    Apply new changes from mke4.yaml, and create a MKE4 cluster."
   echo "t reset lab    Reset the MKE4 cluster (delete the cluster but keep the infrastructure)."
}

while getopts ":h" option; do
   case $option in
      h) # display Help
         Help
         exit;;
   esac
done
