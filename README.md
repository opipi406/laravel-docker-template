# Laravel & Vue & JetStream 環境構築用テンプレート（Docker環境）
Laravel & Vue & JetStream 環境構築用テンプレート

# Installation
```bash
git clone https://github.com/opipi406/laravel-docker-template.git <プロジェクト名>
```

## イメージ・コンテナの作成
```bash
docker compose up -d
```
|container|port|
|-|-|
|nginxコンテナ|localhost:8080|
|phpMyAdminコンテナ|localhost:8089|
|MailHog|localhost:8025|

ユーザ名: root  
パスワード: qweqwe  

## Laravelプロジェクトの構築
### 新規プロジェクトを構築する場合
```bash
docker compose exec app composer create-project --prefer-dist "laravel/laravel=" .
docker compose exec app cp .env.example .env
```
JetStreamとInertiaを利用する場合は以下のコマンドを入力
```bash
docker compose exec app composer require laravel/jetstream
docker compose exec app php artisan jetstream:install inertia
npm --prefix ./src install ./src
```
### 既存プロジェクトを利用する場合
```bash
git clone <URL> src
docker compose exec app cp .env.example .env
```
パッケージ類のインストール
```bash
docker compose exec app composer install
```
```bash
cd src
npm install
```

## Laravelの初期設定
```bash
docker compose exec app php artisan key:generate
docker compose exec app php artisan storage:link
docker compose exec app chmod -R 777 storage bootstrap/cache
```

## DB環境変数を修正
```bash
# MySQL設定
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=root
DB_PASSWORD=qweqwe

# MailHogテスト用のメール設定
MAIL_DRIVER=smtp
MAIL_HOST=mail
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
```

## DB初期化 & マイグレーション
```bash
docker compose exec app php artisan migrate:fresh
```
```bash
docker compose exec app php artisan db:seed
```

## 開発用サーバー起動
```bash
cd src
npm run dev
```

# Deployment
エックスサーバーでサブドメイン配下にLaravelをデプロイするための備忘録
## 任意のディレクトリでclone
```bash
# ~/xxx.com/public_html/project
git clone <URL> .
```
## パッケージ類のインストール
```bash
npm install
composer install
```

## プロジェクト直下に.htaccessを配置
```
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteRule ^(.*)$ /public/$1 [QSA,L]
</IfModule>
```

## 環境変数の配置
```bash
vim .env
```

## Laravelの初期設定
```bash
php artisan key:generate
php artisan storage:link
chmod -R 777 storage bootstrap/cache
```

## マイグレーション実行
```bash
php artisan migrate --seed
```

## 2回目以降のデプロイ
```bash
git checkout main
git pull

# パッケージに変更があれば実行
npm install
composer install

# DBに変更があれば実行
php artisan migrate
```

# ディレクトリ構成
```bash
├── docker
│   ├── db  # MySQLコンテナ設定用
│   │   ├── Dockerfile
│   │   ├── data
│   │   └── my.conf
│   ├── php # phpコンテナ設定用
│   │   ├── Dockerfile
│   │   └── php.ini
│   └── web # nginxコンテナ設定用
│       ├── Dockerfile
│       └── default.conf
│
├── Makefile
├── docker-compose.yml
└── src # Laravelのソースコードがここに入る
```

# Tips
## Dockerコンテナ上でnode.js環境を構築したい場合
[phpコンテナのDockerfile](./docker/php/Dockerfile) 33行目のコメントアウトを外してください。  
下記コマンドでnode.jsを実行できるようになります。
```bash
docker compose exec app node
```