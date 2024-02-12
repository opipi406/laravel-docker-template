#!/usr/bin/env bash

UNAMEOUT="$(uname -s)"
BASE_DIR=$(
    cd $(dirname $0)
    pwd
)

# Verify operating system is supported...
case "${UNAMEOUT}" in
Linux*) MACHINE=linux ;;
Darwin*) MACHINE=mac ;;
*) MACHINE="UNKNOWN" ;;
esac

if [ "$MACHINE" == "UNKNOWN" ]; then
    exit 1
fi

# Determine if stdout is a terminal...
if test -t 1; then
    # Determine if colors are supported...
    ncolors=$(tput colors)

    if test -n "$ncolors" && test "$ncolors" -ge 8; then
        BOLD="$(tput bold)"
        RED="$(tput setaf 1)"
        GREEN="$(tput setaf 2)"
        YELLOW="$(tput setaf 3)"
        BLUE="$(tput setaf 4)"
        PURPLE="$(tput setaf 5)"
        WATER="$(tput setaf 6)"
        GRAY="$(tput setaf 8)"
        NC="$(tput sgr0)"
    fi
fi

# Function that prints the available commands...
function display_help {
    echo "Laravel deploy script"
    echo
    echo "${YELLOW}Usage:${NC}" >&2
    echo "  bash deploy.sh"
    exit
}

if [ $# -ge 0 ]; then
    if [ "$1" == "help" ] || [ "$1" == "-h" ] || [ "$1" == "-help" ] || [ "$1" == "--help" ]; then
        display_help
    fi
fi

###################################################################################################
source ./.env

if [ "$APP_ENV" = "local" ]; then
    echo "${RED}[ERROR] ローカル環境のため実行不可${NC}"
    exit 1

elif [ "$APP_ENV" = "development" ] || [ "$APP_ENV" = "develop" ]; then
    echo
    echo "${BLUE}=== Deployment to develop${NC}"
    echo
    BRANCH=develop

elif [ "$APP_ENV" = "production" ]; then
    echo "$RED"
    echo "■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■"
    echo "■               DEPLOYMENT TO PRODUCTION                ■"
    echo "■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■"
    echo "$NC"
    BRANCH=main
else
    echo "${RED}[ERROR] 不正なAPP_ENV${NC}"
    exit 1
fi

echo -n "${WATER}?${NC} デプロイを実行してもよろしいですか? (branch: ${BRANCH}) ${GRAY}[y/N]${NC} "

read -r ANSWER
if [ "$ANSWER" != "y" ]; then
    exit
fi

if [ "$BRANCH" != "$(git branch --show-current)" ]; then
    git checkout ${BRANCH}
fi

git pull
if [ $? = 1 ]; then
    echo "{$RED}[ERROR] git pullに失敗しました{$NC}"
    exit 1
fi

echo -n "${WATER}?${NC} ${YELLOW}npm ci${NC} を実行しますか? ${GRAY}[y/N]${NC} "
read -r ANSWER
if [ "$ANSWER" = "y" ]; then
    node -v
    # npm ci
fi
if [ $? = 1 ]; then
    echo "{$RED}[ERROR] npm ciに失敗しました{$NC}"
    exit 1
fi

echo -n "${WATER}?${NC} ${YELLOW}composer update${NC} を実行しますか? ${GRAY}[y/N]${NC} "
read -r ANSWER
if [ "$ANSWER" = "y" ]; then
    composer --version
    # composer update
fi
if [ $? = 1 ]; then
    echo "{$RED}[ERROR] composer updateに失敗しました{$NC}"
    exit 1
fi

echo
echo "${BLUE}=== Start build...${NC}"
# npm run build
if [ $? = 1 ]; then
    echo "{$RED}[ERROR] ビルドに失敗しました{$NC}"
    exit 1
fi

echo -n "${WATER}?${NC} ${YELLOW}php artisan migrate${NC} を実行しますか? ${GRAY}[y/N]${NC} "
read -r ANSWER
if [ "$ANSWER" = "y" ]; then
    php artisan migrate
fi

echo
echo "${BLUE}=== Cache clear...${NC}"

php artisan cache:clear &&
    php artisan config:clear &&
    php artisan route:clear &&
    php artisan view:clear

echo
echo "${GREEN}Deployment completed!${NC}"
