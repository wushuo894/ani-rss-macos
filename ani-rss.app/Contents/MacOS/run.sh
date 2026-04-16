#!/bin/sh

export LANG=C.UTF-8
export LC_ALL=C.UTF-8

cd $(dirname $0)/../

MacOSFolder=$PWD/MacOS

JAR_FILE_NAME="ani-rss.jar"
JAR_FILE="$MacOSFolder/$JAR_FILE_NAME"

message() {
  osascript -e "tell application \"System Events\" to display dialog \"$1\" with title \"ani-rss\"  buttons {\" OK \"} default button 1"
}

if ! java -version 2>&1 > /dev/null; then
  message "你需要在Mac中安装Java运行环境！"
  exit 1
fi

stop() {
  PID=$(pgrep -f "$JAR_FILE_NAME")
  if [ -n "$PID" ]; then
      echo "Stopping process $PID - $JAR_FILE_NAME"
      kill "$PID"
      wait "$PID"
  fi
}

stop

sigterm_handler() {
    stop
}

trap 'sigterm_handler' 15

while :
do
    java -Xms60m -Xmx1g -Xss256k \
      -Dfile.encoding=UTF-8 \
      -Xgcpolicy:gencon \
      -Xshareclasses:none \
      -Xquickstart -Xcompressedrefs \
      -XX:+UseStringDeduplication \
      -XX:-ShrinkHeapInSteps \
      -XX:TieredStopAtLevel=1 \
      -XX:+IgnoreUnrecognizedVMOptions \
      -XX:+UseCompactObjectHeaders \
      --enable-native-access=ALL-UNNAMED \
      --add-opens=java.base/java.net=ALL-UNNAMED \
      --add-opens=java.base/sun.net.www.protocol.https=ALL-UNNAMED \
      -jar $JAR_FILE \
      --gui&
    wait $!
    if [ $? -ne 0 ]; then
      break
    fi
done

exit 0
