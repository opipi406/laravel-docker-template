CP = cp
RM = rm
RM_RF = rm -rf
MV = mv
ifeq ($(OS),Windows_NT)
    CP = copy
		RM = del
		RM_RF = rd /s /q
		MV = move
endif

# Laravel初期インストール
install-laravel:
	docker compose exec app composer create-project --prefer-dist "laravel/laravel=" .
	docker compose exec app cp .env.example .env

# JetStreamのインストール (Inertia)
install-jetstream:
	docker compose exec app composer require laravel/jetstream
	docker compose exec app php artisan jetstream:install inertia

# 初期化
init-laravel:
	docker compose exec app php artisan key:generate
	docker compose exec app php artisan storage:link
	docker compose exec app chmod -R 777 storage bootstrap/cache

# dockerコンテナ操作
up:
	docker compose up -d
build:
	docker compose build
destroy:
	docker compose down --rmi all --volumes --remove-orphans

# MySQLへ接続
sql:
	docker compose exec db bash -c 'mysql -u user -pqweqwe laravel'

# マイグレーション実行
migrate:
	docker compose exec app php artisan migrate
fresh:
	docker compose exec app php artisan migrate:fresh
	
