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

# Install Docker on Ubuntu 20
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
docker run -p 27017:27017 -d mongo:3.6-xenial
```