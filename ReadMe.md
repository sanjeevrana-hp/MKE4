## MKE4 CLuster Installation

## Pre-requsite on the Machine/Laptop from where you execute.
Export the AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_SESSION_TOKEN 

## Edit the default config file, under the /MKE4 and enter the cluster detail if you want your desired requirement.

```
cluster_name = "k0s-cluster-ofh"
controller_count = 1
worker_count = 1
cluster_flavor = "t2.large"
region = "ap-northeast-1
```

## If you want to build the container, then pull the code
docker build --no-cache -t ubuntu22-mke4 .

## Run the container in detach mode
docker run -it -d --name mke4-container ubuntu22-mke4

## Exec into the container
docker exec -it mke4-container /bin/bash

## Else, pull the container image

## Run the container in detach mode
docker run -it -d --name mke4-container ubuntu22-mke4

## Exec into the container
docker exec -it mke4-container /bin/bash


## Step4: To deploy the lab, and install the MKE4 cluster
t deploy lab

## Step: To destroy the lab, and MKE cluster 
t destroy lab


## other options
t reset lab # To reset the MKE cluster
t apply lab # To apply the MKE cluster, if any changes made in mke4.yaml

