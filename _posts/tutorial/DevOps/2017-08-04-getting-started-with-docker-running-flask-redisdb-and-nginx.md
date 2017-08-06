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
3. _Hands On Time: A Flask Project on Docker_

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
    Think of __image__ as a certain static environment configuration, and __containers__ are created once you load and run the environment; there can be many container instances running a certain image, but one image defines only one environment.
4. [Service](https://docs.docker.com/engine/swarm/how-swarm-mode-works/services/)
    - __An image for a microservice in the context of some larger applications which you with to run in distributed environment__. You can scale services by starting a set of replicated containers. Docker compose is used to define a set of services.
5. [Volume](https://docs.docker.com/engine/tutorials/dockervolumes/#data-volumes)
    - __A directory providing persistent and sharable data__.
    With out volumes, data will be destroyed once the container is removed.
6. [Dockerfile](https://docs.docker.com/get-started/part2/#dockerfile)
    - __An environment configuration file for starting your container.__ 
    The file is composed of a set of instructions related to setting up the environment, 
    such as _move this and that to docker_, _make this and that port accessible_, _run this and that commands when starting_, etc.
7. [Docker Network](https://docs.docker.com/engine/userguide/networking/)
    - __A mechanism for a cluster of containers to communicate with each other.__ 
    For a single project, it may contain several containers, one for web app, one for database, one for proxy server, etc.
    Docker network provides a way for them to communicate with each other, while different docker networks remain isolated. More conveniently, while the IP address of each container is dynamic, the name of it in a network is static, hence provide a way to access, for example, container `example` with port `8080` published, via `http://example:8080`.
8. [Docker Compose](https://docs.docker.com/compose/overview/)
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
    docker run --rm <image-name>
        
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

## Hands On Time: A Flask Project on Docker

[Source code](https://github.com/pyliaorachel/docker-flask-redis-nginx-ssl).

In this tutorial, we will create a network first so that containers can communicate within this network. Then we create and test the 3 containers, flask app, redis db, and nginx server, one by one. Finally, we demonstrate how to use docker compose to start the 3 services all at once.

#### Init Project

1. Create project named `example` with the structure below. Different services are seperated into different folders, each running a container (or serveral containers, if you want to scale).
    ```shell
    .
    ├── README.md
    └── src
        ├── docker-compose.yml                      # docker compose configuration
        ├── flaskapp                                # Service 1
        │   ├── Dockerfile                            # image configuration
        │   ├── __init__.py
        │   ├── example
        │   │   ├── __init__.py
        │   │   ├── app.py                            # flask app entry
        │   │   ├── db.py                             # APIs to redis db
        │   │   └── wsgi.py                           # WSGI server entry
        │   ├── requirements.txt                      # dependency information (production)
        │   └── setup.py                              # dependency information (development)
        ├── nginx                                   # Service 2
        │   ├── Dockerfile                            # image configuration
        │   ├── __init__.py
        │   └── nginx.conf                            # nginx server configuration
        └── redisdb                                 # Service 3
            ├── Dockerfile                            # image configuration
            ├── __init__.py
            └── redis.conf                            # redis server configuration
    ```
2. Create `virtualenv` for each container. Since only `flaskapp` need a python environment, we only create this one.
    ```shell
    $ cd src/flaskapp
    $ virtualenv venv
    ```
3. Install Packages in `virtualenv`.
    ```shell
    $ cd src/flaskapp
    $ source venv/bin/activate
    (venv) $ pip3 install -e . # dev mode
    (venv) $ deactivate
    ```

Note that `virtualenv` is optional. It can help you test your project in isolated python environment before you deploy it on docker.

#### Create Docker Network

Create a [Docker network](https://docs.docker.com/engine/userguide/networking/) for communication between the 3 containers below. We will name the network `example`, which is the same as our project name.

```shell
$ docker network create example
```

- Test
  ```shell
  $ docker network ls
  > NETWORK ID          NAME                DRIVER              SCOPE
  > ...
  > abcdefghijkl        example             bridge              local
  > ...
  ```

#### Flask App Container 

The following assumes `venv` in `src/flaskapp` is activated.

###### Add Flask App & Gunicorn

See `src/flaskapp/example/app.py` and `src/flaskapp/example/wsgi.py`.

- Test
    ```shell
    (venv) $ cd src/flaskapp
    (venv) $ gunicorn --bind 0.0.0.0:8080 example.wsgi
    
    # Open browser and go to `localhost:8080`. You should see `Hello World!`.
    ```
- Freeze dependencies into `requirements.txt`
    ```shell
    (venv) $ pip3 freeze | grep -v 'exampleflask' > requirements.txt # ignore dependency on itself
    ```

###### [Deploy on Docker](https://www.smartfile.com/blog/dockerizing-a-python-flask-application/)

See `src/flaskapp/Dockerfile`. `venv` is made ignored by adding it in `.dockerignore`.

- Build image with tag `yourusername/exampleflask`
    ```shell
    $ cd src/flaskapp
    $ docker build -t yourusername/exampleflask .
    ```
- Run container on image `yourusername/exampleflask` with name `exampleflask`, publish port `8080`
    ```shell
    $ docker run -d --rm -p 8080:8080 --name exampleflask yourusername/exampleflask
    ```
- Test
    - Open browser and go to `localhost:8080`. You should see `Hello World!`.
    
#### Redis DB Container 

The following assumes `venv` in `src/flaskapp` is activated.

###### Add Redis DB to Flask App

See `src/flaskapp/example/db.py`.

- Test
    - Install [redis-server](https://redis.io/topics/quickstart) on your local machine first for testing
    ```shell
    # Start the server on default port `6397`
    $ redis-server

    # Start the flask app
    (venv) $ cd src/flaskapp
    (venv) $ gunicorn --bind 0.0.0.0:8080 example.wsgi

    # Open browser and go to `localhost:8080/<your-name>`. You should see `Hello <your-name>!`.
    ```

###### [Deploy on Docker](https://docs.docker.com/samples/redis/#start-a-redis-instance)

See `src/redisdb/Dockerfile` and `src/redisdb/redis.conf`.

- Build image with tag `yourusername/exampleredis`
    ```shell
    $ cd redisdb
    $ docker build -t yourusername/exampleredis .
    ```
- Run container on image `yourusername/exampleredis` with name `exampleredis`, publish port `6379`
    ```shell
    $ docker run -d --rm -p 6379:6379 --name exampleredis yourusername/exampleredis
    ```
- Test
    ```shell
    $ redis-cli
    > 127.0.0.1:6379>

    # This is wrong
    > not connected>
    ```
- Stop the containers, now run `flaskapp` and `redisdb` in docker network `example` for communication
    ```shell
    $ docker stop exampleflask exampleredis

    # No need to publish port for redis, 
    # as the port is `EXPOSE`d in `Dockerfile` to other containers in the same docker network
    $ docker run -d --rm --net example --name exampleredis yourusername/exampleredis
    $ docker run -d --rm -p 8080:8080 --net example --name exampleflask yourusername/exampleflask
    ```
- Test
    - Open browser and go to `localhost:8080/<your-name>`. You should see `Hello <your-name>!`.

_Note_ that `Dockerfile` is needed only when you want to use your customized redis server configuration written in `redis.conf`. 
If you don't need a customized configuration, you don't need to build a new image yourself and can simply use the base image of `redis`:

```shell
$ docker run -d --rm --net example --name exampleredis redis redis-server
```

Then modify `docker-compose.yml` accordingly.

```yml
...
  redis:
    image: redis
    container_name: exampleredis
```

_Note_ that `bind 127.0.0.1` in the `redis.conf` file __SHOULD__ be changed into `bind 0.0.0.0` or else other containers still cannot access the redis server.

#### NGINX Container 

###### Setup an NGINX Server

For `HTTP` requests, see `src/nginx/nginx.conf.sample` and follow [this tutorial](https://pyliaorachel.github.io/blog/tech/system/2017/07/07/flask-app-with-gunicorn-on-nginx-server-upon-aws-ec2-linux.html).

For `HTTPS `requests, see `src/nginx/nginx-ssl.conf.sample` and follow [this tutoiral](https://pyliaorachel.github.io/blog/tech/system/2017/07/14/nginx-server-ssl-setup-on-aws-ec2-linux-with-letsencrypt.html). Make sure that you have used [letsencrypt](https://letsencrypt.org/) or other means to retrieve the certificate and keys.

Choose either of them, modify the `<your-domain-name>` (and `your.domain.name` for `HTTPS`) in the `*.sample` file, and name it `nginx.conf`. For HTTPS, if you did not use `letsencrypt`, also change the `ssl_certificate` and `ssl_certificate_key` to the corresponding paths.

###### [Deploy on Docker](https://hub.docker.com/_/nginx/)

See `src/nginx/Dockerfile`.

- Build image with tag `yourusername/examplenginx`
    ```shell
    $ cd src/nginx
    $ docker build -t yourusername/examplenginx .
    ```
- Run container on image `yourusername/examplenginx` with name `examplenginx`, publish port `80` (and `443` for `HTTPS`). (_Note that -p 8080:8080 is not needed anymore in starting the flask app container, as we will not access this port directly from the browser anymore but instead access this nginx proxy server_)
    ```shell
    # HTTP
    $ docker run -d --rm --net example -p 80:80 --name examplenginx yourusername/examplenginx

    # HTTPS, share the directory containing SSL certificate with -v
    $ docker run -d --rm --net example -p 80:80 -p 443:443 -v /etc/letsencrypt:/etc/letsencrypt --name examplenginx yourusername/examplenginx
    ```
- Test
    - `HTTP`
        - Open browser and go to `http://localhost`. You should see `Hello World!`.
    - `HTTPS`
        - Open browser and go to `https://localhost`. You should see `Hello World!`.


#### Wrap up the Project with Docker Compose

After testing individual containers, you can wrap all the commands up into a single `docker-compose.yml` file, and everything can be started in a single command. All the parameters passed in to the commands when you started the containers are now specified in `docker-compose.yml`. 

_Docker network is not needed anymore, as docker compose creates a default network for all its services. But to build up a more complex network topology, you can create your custom networks in the `docker-compose.yml` file as well._

###### [Deploy with Docker Compose](https://runnable.com/docker/docker-compose-networking)

See `src/docker-compose.yml`.

- Start docker compose
    ```shell
    $ cd src
    $ docker-compose up
    ```
- Test
    - `HTTP`
        - Open browser and go to `http://localhost`. You should see `Hello World!`.
    - `HTTPS`
        - Open browser and go to `https://localhost`. You should see `Hello World!`.

> #### Debug Tips
>
> 1. Use `-it` to run containers in interactive mode so that you can test, view logs, curl other containers, etc. under the environment the app is run in
>   ```shell
>   $ docker run -it --rm -p 8080:8080 --net example --name exampleflask yourusername/exampleflask /bin/bash
>   > root@abcdefghijkl:~#
> 
>   # try curl other containers in the same network
>   $ root@abcdefghijkl:~# apt-get -qq update && apt-get -yqq install curl
>   $ root@abcdefghijkl:~# curl <other-container>:<port>
>   > ...
>   
>   # list networks
>   $ root@abcdefghijkl:~# cat /etc/hosts
>   > ...
>   ```
> 2. Print the logs of a container
>   ```shell
>   $ docker logs exampleflask
>   > ...
>   ```
> 3. List the running containers to ensure they didn't encounter errors
>   ```shell
>   $ docker ps
>   CONTAINER ID        IMAGE                       COMMAND                  CREATED             STATUS              PORTS                    NAMES
>   abcdefghijkl        yourusername/exampleflask   "gunicorn --bind 0..."   some time ago       Up some time        0.0.0.0:8080->8080/tcp   exampleflask
>   mnopqrstuvwx        yourusername/exampleredis   "docker-entrypoint..."   some time ago       Up some time        6379/tcp                 exampleredis
>   ```
> 4. List information of the network to ensure the containers are run within
>   ```shell
>   $ docker network inspect example
>   > [
>       {
>           "Name": "example",
>           "Id": "...",
>           "Created": "...",
>           "Scope": "local",
>           "Driver": "bridge",
>           "EnableIPv6": false,
>           // ...other properties
>           "Containers": {
>               "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx": {
>                   "Name": "exampleredis",
>                   "EndpointID": "yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy",
>                   "MacAddress": "aa:bb:cc:dd:ee:ff",
>                   "IPv4Address": "w.x.y.z/a",
>                   "IPv6Address": ""
>               },
>               // ...other container info
>           },
>           // ...other properties
>        }
>    ]
>   ```

## References

- [Official Doc](https://docs.docker.com/)
- [How to Configure NGINX for a Flask Web Application](http://www.patricksoftwareblog.com/how-to-configure-nginx-for-a-flask-web-application/)
- [Orchestrate Containers for Development with Docker Compose](https://blog.codeship.com/orchestrate-containers-for-development-with-docker-compose/)
- [Dockerizing a Python Flask Application](https://www.smartfile.com/blog/dockerizing-a-python-flask-application/)
- [Docker Redis Samples](https://docs.docker.com/samples/redis/)
- [Docker Compose Networking](https://runnable.com/docker/docker-compose-networking)








