#!/bin/bash
#------------------------------------------
#   Laravelデプロイ用シェルスクリプト
#------------------------------------------

source ./.env

if [ $APP_ENV = "local" ]; then
    echo "[ERROR] ローカル環境のため実行不可"; exit 1
elif [ $APP_ENV = "development" ] || [ $APP_ENV = "develop" ]; then
    echo "[INFO] Develop環境"
    BRANCH=develop
elif [ $APP_ENV = "production" ]; then
    echo "[INFO] Production環境"
    BRANCH=main
else
    echo "[ERROR] 不正なAPP_ENV"; exit 1
fi

echo -n "[INFO] デプロイを実行してもよろしいですか？ (対象ブランチ: ${BRANCH}) [y/n] "; read ANSWER
if [ "$ANSWER" != "y" ]; then
    exit 1
fi

echo "[INFO] ${BRANCH}ブランチにcheckout & pull"
git checkout ${BRANCH} && git pull

echo -n "[INFO] npm install を実行しますか？ [y/n] "; read ANSWER
if [ "$ANSWER" = "y" ]; then
    npm install
fi

echo "[INFO] ビルド開始"
npm run build

echo -n "[INFO] php artisan migrate を実行しますか？ [y/n] "; read ANSWER
if [ "$ANSWER" = "y" ]; then
    php artisan migrate
fi

echo "[INFO] キャッシュクリア"

php artisan cache:clear \
    && php artisan config:clear \
    && php artisan route:clear \
    && php artisan view:clear

echo "[INFO] デプロイ完了"
