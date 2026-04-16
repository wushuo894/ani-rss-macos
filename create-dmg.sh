#!/bin/sh

# 定义颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

cd $(dirname $0)

JAR_FILE="ani-rss.app/Contents/MacOS/ani-rss.jar"

if [ ! -e ${JAR_FILE} ]; then
    echo "${RED}ani-rss.jar 不存在${NC}"
    exit 1
fi

# 设置应用程序权限
chmod -R 755 ani-rss.app
# 移除隔离属性
xattr -cr ani-rss.app

! which create-dmg && brew install create-dmg

test -f ./ani-rss.dmg && rm ./ani-rss.dmg

create-dmg \
    --volname "ANI-RSS Installer" \
    --background "background.svg" \
    --window-pos 400 200 \
    --window-size 660 400 \
    --icon "ani-rss.app" 160 185 \
    --hide-extension "ani-rss.app" \
    --app-drop-link 500 185 \
    "ani-rss.dmg" \
    "ani-rss.app/"
