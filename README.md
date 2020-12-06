# DevOps Crash Course 2020

Set up a basic CI/CD pipeline using industry standard tools like Node, Docker, Terraform, gcloud, Make.

- Create a containerized NodeJS app using Docker
- Use a web based MongoDB instance through Atlas
- Create a deployment script using Terraform
- Deploy staging and prod envs to Google Cloud using Github Actions
- Manage DNS and SSL certs through CloudFlare (Flexible - no encryption in transit)

Could be taken further by:

- Adding additional replicas
- Adding a load balancer (forward proxy)

## Installation

```sh
# Download Node application and install deps
git clone
cd storybooks
npm install
npm audit fix

# Install Docker and Docker Compose on Ubuntu 20
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce
sudo systemctl status docker
sudo usermod -aG docker ${USER}
su - ${USER}
groups OR id -nG # Confirm added to docker group
docker version # Confirm installation and check version number
docker info # show systemwide info about docker and server/VM
docker search <imagename> # Search Docker Hub for an image
docker pull ubuntu # download the official ubuntu image to your computer
docker images # See all images that have been downloaded to your computer
docker run -it ubuntu # Run an image with interactive terminal access
apt update; apt install nodejs; node -v; exit # Work inside the container and exit

# INSTALL DOCKER COMPOSE
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
ls -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version
```

### Basic Docker Commands

```sh
docker -v # Get docker version, confirm installed
docker # See a list of all commands
docker <command> --help # Show more information for a command
docker ps -a # Show all docker containers (active and inactive)
docker ps -l # Show the latest container created
docker start <container-id> # Start a container based on the id #
docker ps # Show all active containers
docker stop <container-name> # Stop a container based on name
docker commit -m "Added NodeJS" -a "jordan" <container-id> <docker-hub-username>/<reponame>
docker images # List all images, note this will include the newly commited image (local)
docker login -u jordantblakey
docker push jordantblakey/ubuntu-nodejs:<tag-name>
docker rm <container-name> # Removes a container from the server/VM
docker rmi <username>/<image-name> # Removes an image from the server/VM
docker pull <username>/<image-name>:<tag-name> # Pull the image down from Docker Hub

# MANAGEMENT COMMANDS
docker builder|config|container|context|engine|image|network|node|plugin|secret|service|stack|swarm|system|trust|volume
# COMMANDS
docker attach|build|commit|cp|create|diff|events|exec|export|history|images|import|info|inspect|kill|load|login
docker logs|pause|port|ps|pull|push|rename|restart|rm|rmi|run|save|search|start|stats|stop|tag|top|unpause|update|version|wait
```

## MongoDB Setup

```sh
docker pull mongo:3.6-xenial
docker run -p 27017:27017 -d mongo:3.6-xenial
```

## App Docker Container Setup

```sh
npm run start # start the application and test
# build a docker image with a tag from a Dockerfile in the current directory
# Now, stop the application
touch Dockerfile docker-compose.yml .dockerignore # ignore node_modules/ and terraform/
```

### Dockerfile Config

*pull*s an *image* **FROM** Docker Hub. Sets an install **WORKDIR**. **COPY** a package.json to the install dir. **RUN** npm install to get deps. **COPY** the rest of the application files to the install directory. **EXPOSE** port 3000 for Node to communicate on. Changes to **USER** node. Defines startup **CMD** for when the built *image* is run in a *container*

```dockerfile
# Pull and work FROM Docker Hub image <image-name>:<tag-name>
FROM node:14-slim
# Set a target (known as a WORKDIR) for Dockerfile operations, /usr/src/app is a convention
WORKDIR /usr/src/app
# COPY package[-lock].json from the Dockerfile location to the WORKDIR
COPY ./package*.json ./
# RUN command in the WORKDIR (install deps)
RUN npm install
# COPY repo contents from Dockerfile dir to WORKDIR
COPY . .
# Change USER to 'node'
USER node
# Expose port 3000
EXPOSE 3000
# Run this CMD from WORKDIR on startup
CMD ["npm", "start"]
```

### Create Docker Compose File to Automatically Compose Services

Sets up 2 **services** running **containers** in a server/VM by **build**ing a Node image using a **Dockerfile** and **pull**ing a MongoDB **image** from Dockerhub. Creates a **network** for them, opens the appropriate **ports** on each container, and sets up persistent storage in a **volume**. Pulls credentials into a container using an **env_file**, and manually sets **environment** variables in the other

```yml
version: "3"
services:
  api-server:
    build: ./
    env_file: ./config/config.env
    ports:
      - "3000:3000"
    networks:
      - storybooks-app
    depends_on:
      - mongo
  mongo:
    image: mongo:3.6-xenial
    environment:
      - MONGO_INITDB_DATABASE=storybooks
    ports:
      - "27017:27017"
    networks:
      - storybooks-app
    volumes:
      - mongo-data:/data/db
networks:
  storybooks-app:
    driver: bridge
volumes:
  mongo-data:
    driver: local
```

### Create Makefile To Store Common Commands

```makefile
# Create a variable
PROJECT_ID=devops-cc-project

# Define an executable command
run-local:
  docker-compose up

create-tf-backend-bucket:
  gsutil mb -p $(PROJECT_ID) gs://$(PROJECT_ID)-terraform
```

### Install Terraform on Ubuntu 20

```sh
# Add repo GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
# Add repository for terraform releases
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update && sudo apt install terraform
terraform -help
terraform -help <command>
terraform -install-autocomplete

# COMMON COMMANDS
terraform apply # Builds or changes infrastructure
terraform console # Interactive console for Terraform interpolations
terraform destroy # Destroy Terraform-managed infrastructure
terraform env # Workspace management
terraform fmt # Rewrites config files to canonical format
terraform get # Download and install modules for the configuration
terraform graph # Create a visual graph of Terraform resources
terraform import # Import existing infrastructure into Terraform
terraform init # Initialize a Terraform working directory
terraform login # Obtain and save credentials for a remote host
terraform logout # remove locally-stored credentials for a remote host
terraform output # Read an output from a state file
terraform plan # Generate and show an execution plan
terraform providers # Prints a tree of the providers used in the configuration
terraform refresh # Update local state file against real resources
terraform show # Inspect Terraform state or plan
terraform taint # Manually mark a resource for recreation
terraform untaint # Manually unmark a resource as tainted
terraform validate # Validates the Terraform files
terraform version # Prints the Terraform version
terraform workspace # Workspace management

# Advanced Commands
terraform 0.12upgrade | 0.13upgrade | debug | force-unlock | push | state

```

### Create Terraform File to Configure Various Remote Services

Terraform knows how to use the APIs of different cloud platforms through **providers**. Typically the process of adding a platform to your configuration involves finding the provider on `terraform.io`, and adding a block to define if in our configuration files.

```terraform
terraform {
  backend "gcs" {
    bucket = "devops-cc-project"
    prefix = "/state/storybooks"
  }
}
```

```sh
export GOOGLE_APPLICATION_CREDENTIALS=$PWD/terraform/terraform-sa-key.json
echo $GOOGLE_APPLICATION_CREDENTIALS
terraform init
terraform init -reconfigure
terraform plan
```

======================================

# StoryBooks

https://storybooks.devopsdirective.com

> Create public and private stories from your life

This app uses Node.js/Express/MongoDB with Google OAuth for authentication

It uses Docker + docker-compose for local execution, Terraform to provision cloud resources, and Github actions for CI/CD.

For full tutorial, see the video I created for the [Traversy Media YouTube channel](https://www.youtube.com/c/TraversyMedia/videos).

## Local Setup

Add your mongoDB URI and Google OAuth credentials to the config.env file.

Then run:
```
make run-local
```

This will use docker-compose to build the application into a docker image and then run it alongside a Mongo DB container.

## Terraform

The terraform configuration provisions:
- GCP Compute Engine Virtual Machine
- Atlas MongoDB Cluster
- Cloudflare DNS "A" Record

Using the terraform config requires:
1) Creating a GCP project (+ service account key for TF to use)
2) Creating an Atlas project (+ API key for TF to use)
3) Creating a Cloudflare account (+ API token for TF to use)

## Github Action

`.github/workflows/build-push-deploy.yaml` contains a workflow which deploys to a staging environment on pushes to the `master` branch and to a production environment on pushes of tags of the form.

```sh
# Test CloudFlare API Token
curl -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
     -H "Authorization: Bearer yMJB4ylBJ2jY8eUTVQwu6U4sAC4HIxooeJUgIkY7" \
     -H "Content-Type:application/json"

```