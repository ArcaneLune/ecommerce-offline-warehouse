#!/bin/bash

# ==============================================
# 日志采集集群启停脚本
# 支持：start | stop | status
# 可在集群任意节点执行，所有命令均通过 SSH 远程执行
# ==============================================

# 主机列表配置
HOST_MASTER="hadoop100"
HOST_WORKER="hadoop101"

# 用户名（根据实际情况修改，默认 hadoop）
SSH_USER="hadoop"

# 颜色输出
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m" # No Color

# 远程执行函数
remote_exec() {
    local host=$1
    shift
    ssh -o StrictHostKeyChecking=no ${SSH_USER}@${host} "$@"
}

# ==================== 启动函数 ====================
start_cluster() {
    echo -e "${GREEN}========== 启动日志采集 ==========${NC}"

    # ---------- hadoop100：启动基础设施 ----------
    echo -e "\n${YELLOW}[hadoop100] 启动 Zookeeper ...${NC}"
    remote_exec ${HOST_MASTER} "zk.sh start"

    echo -e "\n${YELLOW}[hadoop100] 启动 Hadoop 集群 ...${NC}"
    remote_exec ${HOST_MASTER} "myhadoop.sh start"

    echo -e "\n${YELLOW}[hadoop100] 启动 Kafka ...${NC}"
    remote_exec ${HOST_MASTER} "kf.sh start"

    echo -e "\n${YELLOW}[hadoop100] 启动 Hive Metastore（端口 9083 检测）...${NC}"
    remote_exec ${HOST_MASTER} "mkdir -p /opt/module/hive-3.1.3/logs && netstat -tlnp 2>/dev/null | grep -q :9083 || nohup hive --service metastore >> /opt/module/hive-3.1.3/logs/metastore.log 2>&1 < /dev/null &"
    echo -e "${GREEN}[hadoop100] Hive Metastore 已启动（若未运行）${NC}"

    # ---------- hadoop101：启动采集组件 ----------
    echo -e "\n${YELLOW}[hadoop101] 启动日志生成器 log_generator ...${NC}"
    remote_exec ${HOST_WORKER} "nohup python3 /home/hadoop/bin/log_generator.py --continuous --batch 10 --interval 2 > /home/hadoop/log_generator.log 2>&1 < /dev/null &"

    echo -e "\n${YELLOW}[hadoop101] 启动 Filebeat ...${NC}"
    remote_exec ${HOST_WORKER} "sudo systemctl start filebeat"

    echo -e "\n${YELLOW}[hadoop101] 启动 SeaTunnel ODS 采集任务 ...${NC}"
    remote_exec ${HOST_WORKER} "mkdir -p /opt/module/seatunnel-2.3.13/logs && nohup sh /opt/module/seatunnel-2.3.13/bin/seatunnel.sh --config /opt/module/seatunnel-2.3.13/config/jobs/kafka_log_to_hdfs.conf -m local > /opt/module/seatunnel-2.3.13/logs/ods_ingestion.log 2>&1 < /dev/null &"

    echo -e "\n${GREEN}========== 启动完成 ==========${NC}"
}

# ==================== 停止函数 ====================
stop_cluster() {
    echo -e "${RED}========== 停止日志采集 ==========${NC}"

    # ---------- hadoop101：先停业务组件 ----------
    echo -e "\n${YELLOW}[hadoop101] 停止 SeaTunnel 进程 ...${NC}"
    remote_exec ${HOST_WORKER} "ps -ef | grep seatunnel | grep -v grep | awk '{print \$2}' | xargs -r kill -9"
    echo -e "${GREEN}[hadoop101] SeaTunnel 已停止${NC}"

    echo -e "\n${YELLOW}[hadoop101] 停止 Filebeat ...${NC}"
    remote_exec ${HOST_WORKER} "sudo systemctl stop filebeat"

    echo -e "\n${YELLOW}[hadoop101] 停止日志生成器 log_generator ...${NC}"
    remote_exec ${HOST_WORKER} "ps -ef | grep log_generator | grep -v grep | awk '{print \$2}' | xargs -r kill -9"
    echo -e "${GREEN}[hadoop101] log_generator 已停止${NC}"

    # ---------- hadoop100：后停基础设施 ----------
    echo -e "\n${YELLOW}[hadoop100] 停止 Kafka ...${NC}"
    remote_exec ${HOST_MASTER} "kf.sh stop"

    echo -e "\n${YELLOW}[hadoop100] 停止 Hadoop 集群 ...${NC}"
    remote_exec ${HOST_MASTER} "myhadoop.sh stop"

    echo -e "\n${YELLOW}[hadoop100] 停止 Zookeeper ...${NC}"
    remote_exec ${HOST_MASTER} "zk.sh stop"

    echo -e "\n${RED}========== 已全部停止 ==========${NC}"
}

# ==================== 状态检查函数 ====================
status_cluster() {
    echo -e "${YELLOW}========== 运行状态检查 ==========${NC}"

    # ---------- hadoop100 状态 ----------
    echo -e "\n${GREEN}[hadoop100] 基础设施状态：${NC}"
    
    echo -n "  Zookeeper: "
    remote_exec ${HOST_MASTER} "zk.sh status > /dev/null 2>&1" && echo -e "${GREEN}运行中${NC}" || echo -e "${RED}未运行${NC}"

    echo -n "  Hadoop: "
    remote_exec ${HOST_MASTER} "jps | grep -q -E 'NameNode|DataNode|ResourceManager|NodeManager'" && echo -e "${GREEN}运行中${NC}" || echo -e "${RED}未运行${NC}"

    echo -n "  Kafka: "
    remote_exec ${HOST_MASTER} "jps | grep -q Kafka" && echo -e "${GREEN}运行中${NC}" || echo -e "${RED}未运行${NC}"

    echo -n "  Hive Metastore(9083): "
    remote_exec ${HOST_MASTER} "netstat -tlnp 2>/dev/null | grep -q :9083" && echo -e "${GREEN}运行中${NC}" || echo -e "${RED}未运行${NC}"

    # ---------- hadoop101 状态 ----------
    echo -e "\n${GREEN}[hadoop101] 采集组件状态：${NC}"

    echo -n "  log_generator: "
    remote_exec ${HOST_WORKER} "ps -ef | grep log_generator | grep -v grep -q" && echo -e "${GREEN}运行中${NC}" || echo -e "${RED}未运行${NC}"

    echo -n "  Filebeat: "
    remote_exec ${HOST_WORKER} "systemctl is-active --quiet filebeat" && echo -e "${GREEN}运行中${NC}" || echo -e "${RED}未运行${NC}"

    echo -n "  SeaTunnel: "
    remote_exec ${HOST_WORKER} "ps -ef | grep seatunnel | grep -v grep -q" && echo -e "${GREEN}运行中${NC}" || echo -e "${RED}未运行${NC}"

    echo -e "\n${YELLOW}========================================${NC}"
}

# ==================== 主入口 ====================
case $1 in
    start)
        start_cluster
        ;;
    stop)
        stop_cluster
        ;;
    status)
        status_cluster
        ;;
    *)
        echo "用法: $0 {start|stop|status}"
        echo "  start  - 启动整条日志采集"
        echo "  stop   - 停止整条日志采集"
        echo "  status - 查看各组件运行状态"
        exit 1
        ;;
esac