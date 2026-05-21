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

if [ -z "$JAVA_OPTS" ]; then
  export JAVA_OPTS="-Xms64m -Xmx512m -Xss256k -XX:+UseG1GC"
fi

echo "JAVA_OPTS=$JAVA_OPTS"

while :
do
    java $JAVA_OPTS \
      -XX:+UseStringDeduplication \
      -XX:+UseCompactObjectHeaders \
      -XX:TieredStopAtLevel=1 \
      -XX:+IgnoreUnrecognizedVMOptions \
      --enable-native-access=ALL-UNNAMED \
      --add-opens=java.base/java.net=ALL-UNNAMED \
      --add-opens=java.base/sun.net.www.protocol.https=ALL-UNNAMED \
      -Dfile.encoding=UTF-8 \
      -jar $JAR_FILE \
      --gui&
    wait $!
    if [ $? -ne 0 ]; then
      break
    fi
done

exit 0
