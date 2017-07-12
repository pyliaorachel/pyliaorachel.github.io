---
layout: post
title:  "Flask App with Gunicorn on Nginx Server upon AWS EC2 Linux"
categories: Blog Tech System
tags: ["flask", "gunicorn", "nginx", "aws"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

The whole setup is modified from this [tutorial](https://www.digitalocean.com/community/tutorials/how-to-serve-flask-applications-with-gunicorn-and-nginx-on-ubuntu-14-04),
with the pain and gain from the alternative deployment on an AWS EC2 Linux server.

1. Setup Environment
2. Creating a Flask App
3. Binding with Gunicorn
4. Creating an Upstart Script for Running Gunicorn Server
5. Running with Nginx on AWS EC2

<!--more-->
---

#### Setup Environment

Install python development tools & `nginx`.

```shell
$ sudo yum update
$ sudo yum install python-pip python-dev nginx
```

Install `virtualenv` from `pip` so that the python packages for the flask app will be in isolation.

```shell
$ sudo pip install virtualenv
```

Create the project & setup the virtual environment.

```shell
# create project
$ mkdir myproject
$ cd myproject

# create virtualenv
$ virtualenv venv

# activate virtualenv
$ source ./venv/bin/activate
```

Now the prompt should look like:

```shell
(venv)user@host:~/myproject$ 
```

#### Creating a Flask App

Install the dependencies under your virtualenv.

```shell
(venv)user@host:~/myproject$ pip install gunicorn flask
```

Create the app entry file `~/myproject/app.py` and write the simplest flask app:

```python
from flask import Flask
application = Flask(__name__)

@application.route("/")
def index():
    return "Hello World!"

if __name__ == "__main__":
    application.run(host='0.0.0.0', port='8080')
```

_Note that you need to make sure your app is run on an allowed port of the EC2 instance. 
Check which ports are allowed under `AWS EC2 Dashboard > Instances > (select your instance) > Security groups > view inbound rules`._

Test your flask app.

```shell
(venv)user@host:~/myproject$ python app.py
```

Go to your browser and enter the url to your server, appending the port number you specified in `app.py`. 
You should see `Hello World!` displayed.

#### Binding with Gunicorn

Create the WSGI entrypoint `~/myproject/wsgi.py`.

```python
from app import application

if __name__ == "__main__":
    application.run()
```

Test it.

```shell
(venv)user@host:~/myproject$ gunicorn --bind 0.0.0.0:8080 wsgi
```

_If you didn't name your app as `application`, for example as `app`, 
use `wsgi:app` instead of `wsgi`, since `application` is the name to be picked up by default._

Go to your browser again and read the `Hello World!` response.

#### Creating an Upstart Script for Running Gunicorn Server

Now let's make Linux automatically start the server upon booting by providing the upstart script.

Create a configuration file:

```shell
$ sudo vim /etc/init/myproject.conf
```

Write a little more complicated version than the original tutorial to help you debug:

```conf
description "Gunicorn application server running myproject"

start on runlevel [2345]
stop on runlevel [!2345]

respawn

env PATH=/home/ec2-user/myproject/venv/bin
env PROGRAM_NAME="myproject"
env USERNAME="ec2-user"

# Main script to be run
script
    echo "[`date -u +%Y-%m-%dT%T.%3NZ`] (sys) Ready to run..." >> /var/log/$PROGRAM_NAME.sys.log

    export HOME="/home/ec2-user"
    echo $$ > /var/run/$PROGRAM_NAME.pid

    cd /home/ec2-user/myproject
    # exec sudo -u ec2-user gunicorn --workers 3 --bind unix:myproject.sock -m 000 wsgi >> /var/log/$PROGRAM_NAME.sys.log 2>&1
    # exec su -s /bin/sh -c 'exec "$0" "$@"' ec2-user -- gunicorn --workers 3 --bind unix:myproject.sock -m 000 wsgi >> /var/log/$PROGRAM_NAME.sys.log 2>&1
    exec gunicorn --workers 3 --bind unix:myproject.sock -m 000 wsgi >> /var/log/$PROGRAM_NAME.sys.log 2>&1
end script

# Script for debug purpose, run before starting
pre-start script
    echo "[`date -u +%Y-%m-%dT%T.%3NZ`] (sys) Starting" >> /var/log/$PROGRAM_NAME.sys.log
end script

# Script for debug purpose, run before stopping
pre-stop script
    rm /var/run/$PROGRAM_NAME.pid/
    echo "[`date -u +%Y-%m-%dT%T.%3NZ`] (sys) Stopping" >> /var/log/$PROGRAM_NAME.sys.log
end script
```

Notes here:

1. `PATH` is for running the server under our virtual environment
2. Note the commented out `exec` scripts that produce errors; 
I intended to switch user by doing that, since `setuid` and `setgid` is not supported on EC2 Linux instance. 
These commands are from [these](https://www.thedevopsdoctors.com/blog/2016/4/8/init-scripts-for-web-apps-on-linux-and-why-you-should-be-using-them) [places](https://deepumohan.com/tech/setting-up-apache-airflow-on-aws-ec2-instance/) and [here](https://serverfault.com/questions/357060/how-should-i-use-sudo-from-an-upstart-script). Feel free to provide a correct version...
So now the server is run under `root`.
3. `-m` flag is the umask; for umask value `000`, the permission would be `777`. This is insecure though, but since I have not found a way to set the access right to a specific user and group, the hooking with nginx only works when the permission is allowed for all users (as the nginx server we will set up later runs as user `nginx`).
4. Echos and `>>` are for debugging; see the logs at `/var/log/myproject.sys.log` if you cannot start your server.

Test it.

```shell
# reload configuration files from /etc/init/*.conf
$ sudo initctl reload-configuration

# see if the new job is listed
$ sudo initctl list

# try start your server (job); the job name is without the '.conf' extension
$ sudo initctl start myproject

# if job is not listed, or error displays and says 'myproject' is not known, there's probably errors in the conf file
# fix them and go on

# check if it's actually running
$ sudo initctl status myproject
> myproject start/running, process xxxx

# or check with
$ ps aux | grep gunicorn

# if the job is not running, see the log at '/var/log/myproject.sys.log'
# you can echo more messages in the conf file for your own debug purpose

# you should also notice a socket file created at '/home/ec2-user/myproject/myproject.sock'
```

#### Running with Nginx on AWS EC2

Now setup the nginx server to redirect the traffic received at port 80 (http) to the WSGI (Gunicorn) server running at the unix socket.

Open the `/etc/nginx/nginx.conf` file, find the section and write:

```conf
...
server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  <your-domain-name>;                                    # <- replace with your own one
        root         /usr/share/nginx/html;

        ...

        location / {
            proxy_pass http://unix:/home/ec2-user/myproject/myproject.sock; # <- add this
        }

        ...
```

This will route the traffic to the specified socket.

Test it.

```shell
$ sudo nginx -t
```

If ok, start the server:

```shell
$ sudo service nginx restart
```

Go to the browser, and without specifying the port number now (default to 80). The request will hit the nginx proxy server, and the nginx server will pass it to the WSGI server, which talks to the flask app. Check if it successfully returns `Hello World!`.

If not, there may be multiple reasons. The one that I encountered is solved by changing the permission of the home directory:

```shell
$ chmod 711 /home/ec2-user
```

Remember to restart.

> ###### Debug Methods
>
> 1. Echo message to `/var/log/xxx.sys.log`
> 2. `tail -f /var/log/nginx/access.log` to check nginx logs
> 3. `netstat -anp | less` to show network status

## References
* [How To Serve Flask Applications with Gunicorn and Nginx on Ubuntu 14.04](https://www.digitalocean.com/community/tutorials/how-to-serve-flask-applications-with-gunicorn-and-nginx-on-ubuntu-14-04)
