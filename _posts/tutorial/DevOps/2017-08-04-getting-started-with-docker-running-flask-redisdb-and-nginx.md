---
layout: post
title:  "Getting Started with Docker Running Flask, RedisDB, and NGINX"
categories: Tutorial DevOps Docker
tags: ["docker", "flask", "redisdb", "nginx"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

__Docker__ is a trending term nowadays. 
The concept is called container, which provides isolation for different applications and
makes possible for the application to be shipped and run on a diversity of platforms.

In this tutorial, the basic concepts of Docker will be covered, some basic commands introduced, and finally a tutorial on
how to deploy a __Flask__ app connected to a __Redis__ database and served on __NGINX__ with docker network will be covered.

<!--more-->

## Content

1. Introducing Docker & Setup
2. Basic Commands
3. _Tutorial: A Flask Project on Docker_

## Introducing Docker

#### The Purpose of Containers

For biginners, you can think of __container__ as a __virtual machine__, or even just a machine. 
The underlying infrastructure and mechanism is of course not the same, but you will know the purpose of using containers: __running applications independently__.

For developers, you often bump into the problem when you want to ship a single application to a different platform 
-- everything regarding the environment might need to be reconfigured again, which means another round of pain. 
With docker, all the dependencies are packed together with the code into a single container, which you can just lift and go.

Unlike bulky VMs, which include the entire OS kernel, containers are more lightweight and require less resource.

<p align="center">
  <img src="https://www.docker.com/sites/default/files/Container%402x.png" alt="container infrastructure" width="300px" height="300px" />
  <img src="https://www.docker.com/sites/default/files/VM%402x.png" alt="vm infrastructure" width="300px" height="300px" />
</p>

#### Setup

1. [Install & Setup Docker](https://docs.docker.com/get-started/#setup) 
3. [Install Docker Compose](https://docs.docker.com/compose/install/)
  
#### Glossary

1. [DockerHub](https://hub.docker.com/)
    - __A place for sharing images__.
    Share your image, or pull existing images from here.
2. [Image](https://docs.docker.com/engine/userguide/storagedriver/imagesandcontainers/)
    - __A package including code, libraries, environment variables, and config files that can be run__.
    Think of it as a set of configurations for a single environment. Hence images can be created, downloaded, shared, etc.
    All it waits for is to be executed, which becomes a container.
3. [Container](https://docs.docker.com/engine/userguide/storagedriver/imagesandcontainers/)
    - __A running instance of an image__.
    Images are configurations residing in storage, and containers bring them into memory.
    If thinking of an __image__ as Windows 10, then __container__ is probably a running machine running Windows 10. 
    There can be many machines in the world running Windows 10, but there will be only 1 Windows 10.
4. [Volume](https://docs.docker.com/engine/tutorials/dockervolumes/#data-volumes)
    - __A directory providing persistent and sharable data__.
    With out volumes, data will be destroyed once the container is removed.
5. [Dockerfile](https://docs.docker.com/get-started/part2/#dockerfile)
    - __An environment configuration file for starting your container.__ 
    The file is composed of a set of instructions related to setting up the environment, 
    such as _move this and that to docker_, _make this and that port accessible_, _run this and that commands when starting_, etc.
6. [Docker Network](https://docs.docker.com/engine/userguide/networking/)
    - __A mechanism for a cluster of containers to communicate with each other.__ 
    For a single project, it may contain several containers, one for web app, one for database, one for proxy server, etc.
    Docker network provides a way for them to communicate with each other, while different docker networks remain isolated.
7. [Docker Compose](https://docs.docker.com/compose/overview/)
    - __A tool for defining and running a cluster of containers.__
    For the single project consisting of serveral containers, you may have to `docker run` them individually to start the single service.
    Docker compose lets you create and run your services with a single command. Definitions are written in `docker-compose.yml`.

#### Don't Mix Up...

1. [`ENTRYPOINT` v.s. `CMD`](https://stackoverflow.com/questions/21553353/what-is-the-difference-between-cmd-and-entrypoint-in-a-dockerfile)
    - Both somehow specify which commands to run when started. 
    The default `ENTRYPOINT`, or `entrypoint` in `docker-compose.yml`, is `/bin/sh -c`; the default `CMD` is `bash`. 
    Consider the command `docker run -it some-image /bin/bash`; everything after `some-image` is the `CMD` (in this case `/bin/bash`). 
    Running this command will run `ENTRYPOINT + CMD`, i.e. `/bin/sh -c /bin/bash`.
    E.g. if you specify the `ENTRYPOINT` as `ls` and `CMD` as `.`, the full command looks like `docker run --entrypoint="ls" some-image .`.
2. [`EXPOSE` v.s. `-p`](https://stackoverflow.com/questions/22111060/difference-between-expose-and-publish-in-docker)
    - `EXPOSE`, or `expose` in `docker-compose.yml`, is for inter-container communications, e.g. using docker network; 
    the port exposed won't be accessible to outside of the docker. 
    `-p`, or `ports` in `docker-compose.yml`, publishes the port to the world, including all other containers.

## Basic Commands

1. [Image](https://docs.docker.com/engine/reference/commandline/image/)
    ```shell
    # List the current images you have and their details
    docker images
    
    # Download/upload an image from registry
    docker pull <image-name>[:<tag>]
        * docker pull nginx:latest
        * docker pull someuser/his-image
        
    docker push <image-name>[:<tag>]
        * docker push me/my-image
        
    # Remove images
    docker rmi <image-name|image-id|image-tag>
        
    # Remove all images
    docker rmi $(docker images -q)
    
    # Create image using Dockerfile under specified path
    docker build -t <image-name>[:<tag>] <path-to-directory-containing-dockerfile>
        * docker build -t me/my-image .
    ```
2. [Container](https://docs.docker.com/engine/reference/run/)
    ```shell
    # List all running containers
    docker ps
    
    # Show container details
    docker inspect <container-name|container-id>
    
    # Run an image
    docker run <image-name>
        
    # Run an image with container name assigned
    docker run --name <container-name> <image-name>
    
    # Run an image in interative mode, interact with the bash shell created in the container
    docker run -it <image-name> /bin/bash
        
    # Run an image in detached mode, i.e. in background
    docker run -d <image-name>
        
    # Automatically remove the container when it exits
    docker run -rm <image-name>
        
    # Run an image on published port, mapping the port exposed by the container to the host port on my machine
    docker run -p <host-port>:<container-exposed-port> <image-name>
        * docker run -p 80:8080 nginx
        
    # Run an image with volume specified, sharing the directory in the user's path to the container's path
    docker run -v <user-path>:<container-path> <image-name>
        * docker run -v /etc/nginx:/etc/nginx nginx
        
    # Stop a container
    docker stop <container-name>
    
    # Remove a container
    docker rm <container-name|container-id>
    
    # Remove all containers
    docker rm $(docker ps -a -q)
    ```
3. [Docker Network](https://docs.docker.com/engine/reference/commandline/network/)
    ```shell
    # List all networks
    docker network ls
    
    # Create a network
    docker network create <network-name>
        
    # Connect a network to a container
    docker network connect <network-name> <container-name>
    
    # Or, run a container with network specified
    docker run --net <network-name> <image-name>
    
    # Show network details
    docker network inspect <network-name>
        
    # Remove a network
    docker network rm <network-name>
    
    # Disconnet a container from a network
    docker network disconnect <network-name> <container-name>
    ```
4. [Docker Compose](https://docs.docker.com/compose/reference/overview/)
    ```shell
    # (Re)create and run the service
    docker-compose up
    
    # Remove stopped services
    docker-compose rm
    ```









