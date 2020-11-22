## Dockerized starter template for Laravel + Nuxt.JS project.

## Overview

* [Installation](#installation)
* [Basic usage](#basic-usage)
    * [Manual installation](#manual-installation)
* [Environment](#environment)
* [Nuxt](#nuxt)
* [Laravel](#laravel)
    * [Artisan](#artisan)
    * [File storage](#file-storage)
* [Makefile](#makefile)
* [Aliases](#aliases)
* [Database](#database)
* [Redis](#redis)
* [Mailhog](#mailhog)
* [Logs](#logs)
* [Running commands](#running-commands-from-containers)
* [List of important commands](#list-of-important-commands)
* [Reinstallation](#reinstallation-frameworks)

## Installation
**1. Make sure you have [Docker ](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04) and [Docker Compose](https://docs.docker.com/compose/install) installed**

**2. Run the installation script (it may take up to 10 minutes)**
```
make install
```
on Windows:
```
make install-win
```

**3. That's it.**

Open [http://localhost:8080](http://localhost:8080) url in your browser.

_If you see the 502 error page, just wait a bit when ```npm install && npm run dev``` process will be finished (Check the status with the command ```docker-compose logs client```)_

#### Manual installation
If you do not have available the make utility or you just want to install the project manually, you can go through the installation process running the following commands:

**Build and up docker containers (It may take up to 10 minutes)**
```
docker-compose up -d --build
```

**Install composer dependencies:**
```
docker-compose exec php composer install
```

**Copy environment files**
```
cp .env.api api/.env
cp .env.client client/.env
```

**Set up laravel permissions**
```
sudo chown -R $USER:www-data api/storage
sudo chown -R $USER:www-data api/bootstrap/cache
sudo chmod -R 775 api/storage
sudo chmod -R 775 api/bootstrap/cache
```

**Restart the client container**
```
docker-compose restart client
```

## Basic usage
Your base url is ```http://localhost:8080```. All requests to Laravel API must be sent using to the url starting with `/api` prefix. Nginx server will proxy all requests with ```/api``` prefix to the node static server which serves the Nuxt.

There is also available [http://localhost:8081](http://localhost:8081) url which is handled by Laravel and should be used for testing purposes only.

You **don't** need to configure the api to allow cross origin requests because all requests are proxied through the Nginx.

The following image demonstrates a request path going through the environment.
![Schema](docker/schema.png)

## Environment
To up all containers, run the command:
```
# Make command
make up

# Full command
docker-compose up -d
```

To shut down all containers, run the command:
```
# Make command
make down

# Full command
docker-compose down
```

## Nuxt
Your application is available at the [http://localhost:8080](http://localhost:8080) url.

Take a look at `client/.env` file. There are two variables:
```
API_URL=http://nginx:80
API_URL_BROWSER=http://localhost:8080
```
`API_URL` is the url where Nuxt sends requests during SSR process and is equal to the Nginx url inside the docker network. Take a look at the [image above](#basic-usage).

`API_URL_BROWSER` is the base application url for browsers.

Example of API request:
```
this.$axios.post('/api/register', {
    email: this.email,
    password: this.password
});
```

Async data
```
async asyncData ({ app }) {
    const [subjectsResponse, booksResponse] = await Promise.all([
      app.$axios.$get('/api/subjects'),
      app.$axios.$get('/api/books')
    ])
    return {
      subjects: subjectsResponse.data,
      books: booksResponse.data
    }
},
```

#### Dependencies
If you update or install node dependencies, you should restart the Nuxt process, which is executed automatically by the client container:
```
# Make command
make rc

# Full command
docker-compose restart client
```

## Laravel
Laravel API is available at the [http://localhost:8080/api](http://localhost:8080/api) url.

There is also available [http://localhost:8081](http://localhost:8081) url which is handled by Laravel and should be used for testing purposes only.

#### Artisan
Artisan commands can be used like this
```
docker-compose exec php php artisan migrate
```

If you want to generate a new controller or any laravel class, all commands should be executed from the current user like this, which grants all needed file permissions
```
docker-compose exec --user "$(id -u):$(id -g)" php php artisan make:controller HomeController
```

However, to make the workflow a bit simpler, there is the _aliases.sh_ file, which allows to do the same work in this way
```
artisan make:controller HomeController
```
[More about aliases.sh](#Aliases)

#### File storage
Nginx will proxy all requests with the `/storage` path prefix to the Laravel storage, so you can easily access it.
Just make sure you run the `artisan storage:link` command (Runs automatically during the `make install` process).

## Makefile
There are a lot of useful make commands you can use.
All of them you should run from the project directory where `Makefile` is located.

Examples:
```
# Up docker containers
make up

# Apply the migrations
make db-migrate

# Run tests
make test

# Down docker containers
make down
```

Feel free to explore it and add your commands if you need them.

## Aliases
Also, there is the _aliases.sh_ file which you can apply with command:
```
source aliases.sh
```
_Note that you should always run this command when you open the new terminal instance._

It helps to execute commands from different containers a bit simpler:

For example, instead of
```
docker-compose exec postgres pg_dump
```

You can use the alias `from`:
```
from postgres pg_dump
```

But the big power is `artisan` alias

If you want to generate a new controller or any Laravel class, all commands should be executed from the current user, which grants all needed file permissions
```
docker-compose exec --user "$(id -u):$(id -g)" php php artisan make:model Post
```

The `artisan` alias allows to do the same like this:
```
artisan make:model Post
```

## Database
If you want to connect to PostgreSQL database from an external tool, for example _Sequel Pro_ or _Navicat_, use the following parameters
```
HOST: localhost
PORT: 54321
DB: app
USER: app
PASSWORD: app
```

Also, you can connect to DB with CLI using docker container:
```
// Connect to container bash cli
docker-compose exec postgres bash
    // Then connect to DB cli
    psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}
```

For example, if you want to export dump file, use the command
```
docker-compose exec postgres pg_dump ${POSTGRES_USER} -d ${POSTGRES_DB} > docker/postgres/dumps/dump.sql
```

To import file into the database, put your file to docker/postgres/dumps folder, it mounts into /tmp folder inside container
```
// Connect to container bash cli
docker-compose exec postgres bash
    // Then connect to DB cli
    psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} < /tmp/dump.sql
```

## Redis
To connect to redis cli, use the command:
```
docker-compose exec redis redis-cli
```

If you want to connect with external GUI tool, use the port ```54321```

## Mailhog
If you want to check how all sent mail look, just go to [http://localhost:8026](http://localhost:8026).
It is the test mail catcher tool for SMTP testing. All sent mails will be stored here..

## Logs
All **_nginx_** logs are available inside the _docker/nginx/logs_ directory.

All **_supervisor_** logs are available inside the _docker/supervisor/logs_ directory.

To view docker containers logs, use the command:
```
# All containers
docker-compose logs

# Concrete container
docker-compose logs <container>
```

## Running commands from containers
You can run commands from inside containers' cli. To enter into the container run the following command:
```
# PHP
docker-compose exec php bash

# NODE
docker-compose exec client /bin/sh
```

## List of important commands
**Start/stop the container**
```
make up
make down
make restart
```
**Status**
```
make s
```
**List all logs**
```
make logs
```
**Live client log**
```
make logs-c
```
**Copy .env files**
```
make env-api
make env-client
```
**Composer**
```
make composer-install
make composer-update
```
**NPM**
```
make npm-update
```
**Restart client**
```
make rc
```
**Build**
```
make build
```
OR
```
make build-no-cache
```
**Container cli**
```
make php
make client
```
**DB Migrations**
```
make migrate
make rollback
make db-seed
make db-fresh
```
**Permissions**
```
make perm
```
**Apply aliases**
Have to run in every terminal instances
```
source aliases.sh
```
**Artisan commands**
With aliases
```
artisan make:controller HomeController
```
Without aliases
```
docker-compose exec --user "$(id -u):$(id -g)" php php artisan make:controller HomeController
```

## Reinstallation frameworks
If you want to reinstall Laravel OR Nuxt from scratch with a fresh version, use the following command

##### Laravel
```
make reinstall-laravel
```

##### Nuxt
```
make reinstall-nuxt
```

During the nuxt app creation select the following options:
- Choose the package manager
    - [x] Yarn
- Choose custom server framework
    - [x] None (Recommended)
- Choose rendering mode
    - [x] Universal (SSR)
- Choose Nuxt.js modules
    - [x] Axios
    - [x] DotEnv
- At other steps you can choose an option what you want
