# Docker Image for Magento#

This repository creates a Docker image for Magento (as of this writing version 1.9.2.2).
It is not meant for production but for easy development.

It is based on [alexcheng1982/docker-magento](https://github.com/alexcheng1982/docker-magento). The main difference is that it uses a volume for hosting magento, making it posible to edit the source outside the container. 

## Usage
This image is intented to be used with 
[docker-compose](https://docs.docker.com/compose/). A sample configuration file ([docker-compose.yml]) is included in this repository. 
This file references [env](env) for it's environment.

Steps:

1. Download or create `docker-compose.yml` and `env` in a folder

2. Execute `docker-compose up -d` this starts the MySQL, Redis en PHP/Apache box

3. Execute `docker exec -it $(docker-compose ps | grep web | awk '{print $1;}') download-magento` to download Magento

4. *(Optional)* Execute `docker exec -it $(docker-compose ps | grep web | awk '{print $1;}') install-sampledata` to install the sample data. This has to be done before the Magento installation

5. Execute `docker exec -it $(docker-compose ps | grep web | awk '{print $1;}') install-magento` to run the magento installer.

## Usefull information

* The default volume mount (configured in docker-compose.yml) is ./src
* Make sure the configured host (as configured in env) is in your hostfile
* Xdebug is configured to connect back
* This box is not meant for production as it exposes the root password for MySQL as an environment variabele




