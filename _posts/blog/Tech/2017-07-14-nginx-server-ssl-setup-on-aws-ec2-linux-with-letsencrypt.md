---
layout: post
title:  "Nginx Server SSL Setup on AWS EC2 Linux with Letsencrypt"
categories: Blog Tech System
tags: ["ssl", "letsencrypt", "nginx", "aws"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

This post is a followup on [my previous post on setting up an nginx server on AWS EC2 instance](https://pyliaorachel.github.io/blog/tech/system/2017/07/07/flask-app-with-gunicorn-on-nginx-server-upon-aws-ec2-linux.html), and now we are going to support HTTPS to secure our website using a free SSL certificate authority (CA) [letsencrypt](https://letsencrypt.org/).

<!--more-->
---

Before you start:

1. Obtain a domain name and set it up in your EC2 console to point to the public DNS.
2. Understand the basic mechanism of [letsencrypt](https://letsencrypt.org/how-it-works/). This is key to understanding why your setup does or does not work.
3. Remember to open up 443 port and allow source from `0.0.0.0/0` in your EC2 console so that ACME can hit on you.
4. We are going to use [certbot](https://certbot.eff.org/), which handles all the tedious works to communicate with `letsencrypt` for us. 

And here are the steps:

1. Obtain the certificate using `certbot`
2. Modify your `nginx` configuration to enable SSL

#### Obtain the Certificate

Get `certbot` first:

```shell
$ wget https://dl.eff.org/certbot-auto
$ chmod a+x certbot-auto
```

There are several plugins to use to help us retrieve the certificate. Two popular ones are [webroot](http://letsencrypt.readthedocs.io/en/latest/using.html#webroot) and [standalone](http://letsencrypt.readthedocs.io/en/latest/using.html#standalone). If you do not want to stop your server, use `webroot`; if you do not want to use existing server software, use `standalone`. We will use `standalone` below.

> ###### Using webroot
>
> To retrieve the certificate from the CA, your server needs to solve some [challenges](http://letsencrypt.readthedocs.io/en/latest/using.html#getting-certificates-and-choosing-plugins). The challenge is elaborated [here](https://letsencrypt.org/how-it-works/). If you choose to use `webroot` as the plugin, the thing to note is that the configuration of your server needs to be able to serve the files created in `${webroot}/.well-known/acme-challenge`. You might want to verify that `GET /.well-known/acme-challenge` is accessible first.

To run as standalone, remember to close your services that listen on 80 or 443 ports.

Let's write a config file first. We'll use `example.com` as our domain name. At `/etc/letsencrypt/configs/example.com.conf`:

```conf
# domains to retrieve certificate
domains = example.com

# increase key size
rsa-key-size = 4096

# the CA endpoint server
server = https://acme-v01.api.letsencrypt.org/directory

# the email to receive renewal reminders, IIRC
email = example@example.com 

# turn off the ncurses UI, we want this to be run as a cronjob
text = True
```

Run `certbot`:

```shell
$ ./certbot-auto --standalone --config /etc/letsencrypt/configs/example.com.conf certonly
```

You can skip the above config file as well:

```shell
$ ./certbot-auto --standalone -d example.com certonly
# ...Answer some config questions
```

Now you should see 

```

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at
   /etc/letsencrypt/live/example.com/fullchain.pem. Your cert will
   expire on xxxx-xx-xx. To obtain a new version of the certificate in
   the future, simply run Let's Encrypt again.
```

You can verify that the certificate and keys exist:

```
# Certificate
/etc/letsencrypt/live/example.com/cert.pem

# Full Chain 
/etc/letsencrypt/live/example.com/fullchain.pem

# Private Key 
/etc/letsencrypt/live/example.com/privkey.pem
```

#### Modify `nginx` configuration

Now you've got the certificate, we need to configure the nginx for it to take up HTTPS requests.

Open up your `/etc/nginx/nginx.conf` and modify:

```conf
...

http {

    ...

    server {
        listen 80;
        server_name  example.com;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
            # redirect to HTTPS
            return 301 https://$server_name$request_uri;
        }

        ...
    }

    # Settings for a TLS enabled server.
    server {
        listen 443 ssl;
        server_name  example.com;
        root         /usr/share/nginx/html;

        ssl_certificate "/etc/letsencrypt/live/example.com/fullchain.pem";
        ssl_certificate_key "/etc/letsencrypt/live/example.com/privkey.pem";

        # Automatically route HTTP to HTTPS
        add_header Strict-Transport-Security "max-age=31536000";
  
        include /etc/nginx/default.d/*.conf;

        location / {
            # These are esstential, or your flask app may not correctly redirect
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-Proto https;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            # Pass to our WSGI server
            proxy_pass http://unix:/home/ec2-user/myproject/myproject.sock;
        }

        ...
    }
}
```

Reload your `nginx`:

```shell
$ sudo service nginx reload
```

Now you should access your website using `https`.

Not that the certificate expires in 3 months, so you may want to refer to the nice tutorials in the reference links to set up a cron job and make the renewals.

> ###### Debug Tips 
> 1. Logs reside in `/var/log/letsencrypt/letsencrypt.log`
> 2. If there are permissoin problems, run `sudo su - nginx -s /bin/bash -c "ls /home/ec2-user/myproject/myproject.sock"` to test permission from the viewpoint of `nginx`

## References
* [Certbot Userguide](http://letsencrypt.readthedocs.io/en/latest/using.html)
* [Using the Let’s Encrypt Certbot to get HTTPS on your Amazon EC2 NGINX box](https://medium.freecodecamp.org/going-https-on-amazon-ec2-ubuntu-14-04-with-lets-encrypt-certbot-on-nginx-696770649e76)
* [Let's Encrypt on Ubuntu 14.04, nginx with webroot auth](https://gist.github.com/xrstf/581981008b6be0d2224f)
* [HTTPS with Let’s Encrypt SSL and Nginx (using certbot)](https://loune.net/2016/01/https-with-lets-encrypt-ssl-and-nginx/)
* [Installing LetsEncrypt’s free SSL on Amazon Linux](https://nouveauframework.org/blog/installing-letsencrypts-free-ssl-amazon-linux/)
