#!/bin/bash
KF_HOME="/opt/module/kafka-3.6.2"
KF_BIN="$KF_HOME/bin/kafka-server-start.sh"
KF_STOP="$KF_HOME/bin/kafka-server-stop.sh"
CONFIG="$KF_HOME/config/server.properties"
HOSTS="hadoop100 hadoop101 hadoop102"
if [ $# -ne 1 ]; then
  echo "Usage: $0 {start|stop}"
  exit 1
fi
case $1 in
"start")
  for i in $HOSTS; do
    echo "---------- kafka $i 启动 ------------"
    ssh $i "$KF_BIN -daemon $CONFIG"
  done
  ;;
"stop")
  for i in $HOSTS; do
    echo "---------- kafka $i 停止 ------------"
    ssh $i "$KF_STOP"
  done
  ;;
*)
  echo "Invalid Args! Usage: $0 {start|stop}"
  exit 1
  ;;
esac