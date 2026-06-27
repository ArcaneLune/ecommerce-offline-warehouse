#!/bin/bash
ZK_HOME="/opt/module/zookeeper-3.7.1"
ZK_BIN="$ZK_HOME/bin/zkServer.sh"
HOSTS="hadoop100 hadoop101 hadoop102"
if [ $# -ne 1 ]; then
  echo "Usage: $0 {start|stop|status}"
  exit 1
fi
case $1 in
"start")
  for i in $HOSTS; do
    echo "---------- zookeeper $i 启动 ------------"
    ssh $i "$ZK_BIN start"
  done
  ;;
"stop")
  for i in $HOSTS; do
    echo "---------- zookeeper $i 停止 ------------"
    ssh $i "$ZK_BIN stop"
  done
  ;;
"status")
  for i in $HOSTS; do
    echo "---------- zookeeper $i 状态 ------------"
    ssh $i "$ZK_BIN status"
  done
  ;;
*)
  echo "Invalid Args! Usage: $0 {start|stop|status}"
  exit 1
  ;;
esac
