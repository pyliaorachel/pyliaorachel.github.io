---
layout: post
title:  "Django SQLite DB Cleanup"
categories: Blog Tech Django
tags: ["django", "sqlite"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

To beginners of Django, you may want to play with the sqlite db configuration commands before you actually implement something related to your project. The cleanup afterwards may be harmful due to the lack of clear instructions found online, and many cleanup should be done manually. Some useful commands and solutions to weird issues will be addressed.

<!--more-->
#### DB Commands

###### [Migrations](https://docs.djangoproject.com/en/1.10/topics/migrations/)

`python manage.py makemigrations`: creating new migrations based on the changes you have made to your models  
`python manage.py migrate`: applying & unapplying migrations

- Issues
    - [table not exists errors](http://stackoverflow.com/questions/9373871/django-migrate-table-forum-user-already-exists) occur
        - Run `python manage.py migrate --fake` instead
    - [column not exists errors](http://stackoverflow.com/questions/21457563/operationalerror-no-such-column) occur
        - Probably due to schema changes not synced with DB tables; check schema with `python manage.py inspectdb`
        - Suggest cleaning up the entire database in the following section

###### Clean Up

This is only used when you want to clean up the __entire database__, e.g. you're playing with your DB and wants to start implementing real things now.

1. Dump all data in the DB: `python manage.py flush` 
2. [Reset migrations](https://simpleisbetterthancomplex.com/tutorial/2016/07/26/how-to-reset-migrations.html):  
  `find . -path "*/migrations/*.py" -not -name "__init__.py" -delete`  
  `find . -path "*/migrations/*.pyc"  -delete`  
3. [Discard current schema](https://www.techiediaries.com/how-to-reset-migrations-in-django-17-18-19-and-110/): `rm db.sqlite3`
4. Run migrations again

Now all things should be reset.