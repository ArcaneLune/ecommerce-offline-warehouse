#!/bin/bash
case $1 in
"start")
    source /opt/module/superset-env/bin/activate
    if ps -ef | grep -v grep | grep -q "gunicorn.*superset"; then
        echo "Superset 已在运行"
    else
        gunicorn --workers 3 --timeout 120 --bind 0.0.0.0:8088 \
          --daemon "superset.app:create_app()"
        echo "Superset 已启动"
    fi
;;
"stop")
    ps -ef | grep "gunicorn.*superset" | grep -v grep | awk '{print $2}' | xargs kill -9 2>/dev/null
    echo "Superset 已停止"
;;
"status")
    if ps -ef | grep -v grep | grep -q "gunicorn.*superset"; then
        echo "Superset 运行中"
    else
        echo "Superset 未运行"
    fi
;;
*)
    echo "用法: superset.sh {start|stop|status}"
;;
esac