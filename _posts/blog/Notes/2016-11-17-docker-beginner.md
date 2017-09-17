---
layout: post
title:  "Docker Beginner"
categories: Blog Notes Docker
tags: ["docker"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Basics
	1. Terminologies
	2. Commands
2. Docker Images
	1. Image Types
	2. Create Images
3. Docker Compose
	1. `docker-compose.yml`
	2. Run Application

<!--more-->
---
## Basics

### Terminologies

- __Images__: the __file system and configuration of an application__ used to __create containers__
	- `docker inspect image-name`
- __Containers__: __running instances of Docker images__
	- Run the actual applications; includes an application and all of its dependencies 
	- Share the kernel with other containers
	- Run as an isolated process in user space on the host OS 
	- A container created by `docker run`
- __Docker daemon__: the background service running on the host that __manages building, running and distributing Docker containers__
- __Docker client__: the command line tool that allows the user to interact with the Docker daemon
- __Docker Hub__: a registry of Docker images

### Commands

`docker login` login to docker hub  
`docker ps` list current running containers  
	- `docker ps -a` list containers ran before  
`docker images` list images  
`docker pull image-name` pull image from hub  
	- `image-name:version` specify version e.g. `ubuntu:12.04`, `ubuntu:latest`
`docker push USERNAME/image-name` push image to hub  
`docker run image-name [command]` executes commands in container  
	- `docker pull` if image not exists
	- `-it` iterative mode; will not exit container  
	- `-d` detached mode; detach running container from terminal
	- `-P` publish all the exposed container ports to random ports on the Docker host
	- `-p` specify port number e.g. `-p 8888:80` link 8888 on container to 80 on host
	- `-e` pass environment variables
		- e.g. `-e AUTHOR="name"`
	- `--name` specify container name
`docker stop container-name` stop running container  
`docker rm container1-name container2-name ...` remove containers  
	- `-f` remove running containers 
`docker port container-name` port of running container
`docker search image-name` search for images  

## Docker Images

### Image Types

- Base images v.s. child images
	- __Base image__: no parent images, usually images with an OS
	- __Child image__: build on base images and add additional functionality
- Official images v.s. user images
	- __Official image__: no prefix
	- __User image__: `user/image-name`; based on _base image_

### Create Images

#### Steps

1. Create an app
2. Write a Dockerfile
3. Build the image
4. Run your image
5. Dockerfile commands summary

#### Dockerfile

List of commands the Docker daemon calls while creating an image.

- Base Docker image to run from
- Location of your project code
- Dependencies
- Commands to run at start-up

```
# specify base image
FROM alpine:latest # username/imagename:version

# copying files & installing dependencies
RUN apk add --update py-pip # install Python pip package to the alpine linux distribution # RUN add new layers

# install required Python packages & copy files
COPY requirements.txt /usr/src/app/
RUN pip install --no-cache-dir -r /usr/src/app/requirements.txt
COPY app.py /usr/src/app/
COPY templates/index.html /usr/src/app/templates/

# specify port number
EXPOSE 5000

# run application; one CMD per Dockerfile/Image
CMD ["python", "/usr/src/app/app.py"] # which command to run by default when started
```
#### Build Images

`docker build -t <USERNAME>/appname [path-to-dockerfile]`  
	- `-t` optional tag name

## Docker Compose

Define & run multi-container apps.

### `docker-compose.yml`

Describe containers & volumes you want.

```yml
version: "2"

services:
  vote:
    build: ./vote
    command: python app.py
    volumes:
     - ./vote:/app
    ports:
      - "5000:80"
    networks:
      - front-tier
      - back-tier

  result:
    build: ./result
    command: nodemon --debug server.js
    volumes:
      - ./result:/app
    ports:
      - "5001:80"
      - "5858:5858"
    networks:
      - front-tier
      - back-tier

  worker:
    build: ./worker
    networks:
      - back-tier

  redis:
    image: redis:alpine
    container_name: redis
    ports: ["6379"]
    networks:
      - back-tier

  db:
    image: postgres:9.4
    container_name: db
    volumes:
      - "db-data:/var/lib/postgresql/data"
    networks:
      - back-tier

volumes:
  db-data:

networks:
  front-tier:
  back-tier:
```

- __Networks__: containers can communicate with others in the same network

### Run Application

`docker-compose up -d` start all containers in `docker-compose.yml`  
	- `-d` run in daemon mode in background

Then build & push to hub.





