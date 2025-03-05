# MKE4 Cluster Installation  

## Step 1: Prerequisites  
Ensure your machine or laptop has the necessary AWS credentials before executing the installation:  

```sh
export AWS_ACCESS_KEY_ID=<your-access-key>
export AWS_SECRET_ACCESS_KEY=<your-secret-key>
export AWS_SESSION_TOKEN=<your-session-token>
```

### Edit the Configuration File  
Modify the default config file located in `/MKE4` to specify your desired cluster settings:  

```ini
cluster_name = "k0s-cluster-ofh"
controller_count = 1
worker_count = 1
cluster_flavor = "t2.large"
region = "ap-northeast-1"
```

---

## Step 2: Build and Run the Container  

### Option 1: Build the Container from Source  
Clone the repository and build the container:  

```sh
docker build --no-cache -t ubuntu22-mke4 .
```

Run the container in detached mode:  

```sh
docker run -it -d --name mke4-container ubuntu22-mke4
```

Access the container shell:  

```sh
docker exec -it mke4-container /bin/bash
```

### Option 2: Pull the Prebuilt Container Image  
If you prefer to use a prebuilt image, pull it and run:  

```sh
docker pull sanjeevranahp/mke4:latest
docker run -it -d --name mke4-container sanjeevranahp/mke4
docker exec -it mke4-container /bin/bash
```

---

## Step 3: Deploy the Lab and Install the MKE4 Cluster  
Run the following command to deploy the infrastructure and install the MKE4 cluster:  

```sh
t deploy lab
```

---

## Step 4: Destroy the Lab and MKE4 Cluster  
To tear down the infrastructure and remove the cluster:  

```sh
t destroy lab
```

---

## Additional Commands  

- **Reset the MKE4 cluster** (delete only the cluster, but keep the infrastructure):  
  
  ```sh
  t reset lab
  ```  

- **Apply changes to the MKE4 cluster** (if modifications were made in `mke4.yaml`):  
  
  ```sh
  t apply lab
  ```

---

## Notes  
- Ensure you have **Docker installed** before running the commands.  
- Modify the `mke4.yaml` file as needed before applying changes.  
