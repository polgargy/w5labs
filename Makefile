include .env

#-----------------------------------------------------------
# Docker
#-----------------------------------------------------------

# Wake up docker containers
up:
	docker-compose up -d

# Shut down docker containers
down:
	docker-compose down

# Show a status of each container
status:
	docker-compose ps

# Status alias
s: status

# Show logs of each container
logs:
	docker-compose logs

# Watch client output
logs-c:
	docker logs -f ${CLIENT_CONTAINER}

# Restart all containers
restart: down up

# Restart the client container
restart-client:
	docker-compose restart client

# Restart the client container alias
rc: restart-client

# Show the client logs
logs-client:
	docker-compose logs client

# Show the client logs alias
lc: logs-client

# Build and up docker containers
build:
	docker-compose up -d --build

# Build containers with no cache option
build-no-cache:
	docker-compose build --no-cache

# Build and up docker containers
rebuild: down build

deploy: rebuild composer-install-t migrate-force restart-client

# Run terminal of the php container
php:
	docker-compose exec php bash

# Run terminal of the client container
c:
	docker-compose exec client /bin/sh


#-----------------------------------------------------------
# Logs
#-----------------------------------------------------------

# Clear file-based logs
logs-clear:
	sudo rm docker/${DOCKER_ENV}/nginx/logs/*.log
	sudo rm docker/${DOCKER_ENV}/supervisor/logs/*.log
	sudo rm api/storage/logs/*.log


#-----------------------------------------------------------
# Database
#-----------------------------------------------------------

# Run database migrations
db-migrate:
	docker-compose exec php php artisan migrate

# Migrate alias
migrate: db-migrate

migrate-force:
	docker-compose exec -T php php artisan migrate --force

# Run migrations rollback
db-rollback:
	docker-compose exec php php artisan migrate:rollback

# Rollback alias
rollback: db-rollback

# Run seeders
db-seed:
	docker-compose exec php php artisan db:seed

# Fresh all migrations
db-fresh:
	docker-compose exec php php artisan migrate:fresh

# Dump database into file
db-dump:
	docker-compose exec postgres pg_dump -U app -d app > docker/postgres/dumps/dump.sql


#-----------------------------------------------------------
# Redis
#-----------------------------------------------------------

redis:
	docker-compose exec redis redis-cli

redis-flush:
	docker-compose exec redis redis-cli FLUSHALL

redis-install:
	docker-compose exec php composer require predis/predis


#-----------------------------------------------------------
# Queue
#-----------------------------------------------------------

# Restart queue process
queue-restart:
	docker-compose exec php php artisan queue:restart


#-----------------------------------------------------------
# Testing
#-----------------------------------------------------------

# Run phpunit tests
test:
	docker-compose exec php vendor/bin/phpunit --order-by=defects --stop-on-defect

# Run all tests ignoring failures.
test-all:
	docker-compose exec php vendor/bin/phpunit --order-by=defects

# Run phpunit tests with coverage
coverage:
	docker-compose exec php vendor/bin/phpunit --coverage-html tests/report

# Run phpunit tests
dusk:
	docker-compose exec php php artisan dusk

# Generate metrics
metrics:
	docker-compose exec php vendor/bin/phpmetrics --report-html=api/tests/metrics api/app

php-fix: phpcbf
phpcs:
	docker-compose exec php vendor/bin/phpcs -n

phpcbf:
	docker-compose exec php vendor/bin/phpcbf -n


#-----------------------------------------------------------
# Dependencies
#-----------------------------------------------------------

# Install composer dependencies
composer-install:
	docker-compose exec php composer install

composer-install-t:
	docker-compose exec -T php composer install

# Update composer dependencies
composer-update:
	docker-compose exec php composer update

# Update npm dependencies
npm-update:
	docker-compose exec client npm update

# Update all dependencies
dependencies-update: composer-update npm-update

# Show composer outdated dependencies
composer-outdated:
	docker-compose exec npm outdated

# Show npm outdated dependencies
npm-outdated:
	docker-compose exec npm outdated

# Show all outdated dependencies
outdated: npm-update composer-outdated


#-----------------------------------------------------------
# Tinker
#-----------------------------------------------------------

# Run tinker
tinker:
	docker-compose exec php php artisan tinker


#-----------------------------------------------------------
# Installation
#-----------------------------------------------------------

# Copy the Laravel API environment file
env-api:
	cp .env.api api/.env

# Copy the NuxtJS environment file
env-client:
	cp .env.client client/.env

# Add permissions for Laravel cache and storage folders
permissions:
	sudo chown -R $$USER:www-data api/storage
	sudo chown -R $$USER:www-data api/bootstrap/cache
	sudo chmod -R 775 api/bootstrap/cache
	sudo chmod -R 775 api/storage

# Permissions alias
perm: permissions

# Generate a Laravel + JWT key
key:
	docker-compose exec php php artisan key:generate --ansi

# Generate a Laravel storage symlink
storage:
	docker-compose exec php php artisan storage:link

# PHP composer autoload command
autoload:
	docker-compose exec php composer dump-autoload

# Install the environment
# install: build env-api env-client composer-install key storage permissions migrate rc
# install-win: build env-api env-client composer-install key storage migrate rc
install: build env-api env-client composer-install key storage permissions rc
install-win: build env-api env-client composer-install key storage rc


#-----------------------------------------------------------
# Reinstallation
#-----------------------------------------------------------

# Laravel
reinstall-laravel:
	docker-compose down
	sudo rm -rf api
	mkdir api
	docker-compose up -d
	docker-compose exec php composer create-project --prefer-dist laravel/laravel .
	sudo chown ${USER}:${USER} -R api
	sudo chmod -R 777 api/bootstrap/cache
	sudo chmod -R 777 api/storage
	sudo rm api/.env
	cp .env.api api/.env
	docker-compose exec php php artisan key:generate --ansi
	docker-compose exec php composer require predis/predis
	docker-compose exec php php artisan --version

# Nuxt.JS
reinstall-nuxt:
	docker-compose down
	sudo rm -rf client
	mkdir client
	docker-compose restart
	docker-compose run client npm create nuxt-app .
	sudo chown ${USER}:${USER} -R client
	cp .env.client client/.env
	sed -i "1i require('dotenv').config()" client/nuxt.config.js
	docker-compose restart client
	docker-compose exec client npm info nuxt version


#-----------------------------------------------------------
# Clearing
#-----------------------------------------------------------

# Shut down and remove all volumes
remove-volumes:
	docker-compose down --volumes

# Remove all existing networks (useful if network already exists with the same attributes)
prune-networks:
	docker network prune
