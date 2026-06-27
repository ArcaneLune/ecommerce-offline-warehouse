#!/bin/bash

# ==============================================
# 全量同步集群启停脚本
# 支持：start |  status
# 所有命令均通过 SSH 远程执行，可在集群任意节点运行
# 全流程严格串行执行，避免压垮集群资源
# ==============================================

# 主机配置
HOST_MASTER="hadoop100"
HOST_WORKER="hadoop101"

# SSH 用户名
SSH_USER="hadoop"

# 全量表名列表（统一维护，避免多处重复）
FULL_TABLES=(
    activity_info activity_rule base_trademark
    base_category1 base_category2 base_category3
    coupon_info sku_attr_value sku_sale_attr_value
    base_dic sku_info base_province
    spu_info base_region promotion_pos promotion_refer
)

# 颜色输出
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m"

# 阻塞式远程执行函数：执行完成才返回，天然保证串行
remote_exec() {
    local host=$1
    shift
    ssh -o StrictHostKeyChecking=no ${SSH_USER}@${host} "$@"
}

# ==================== 启动函数（严格串行执行） ====================
start_cluster() {
    echo -e "${GREEN}========== 启动全量同步流水线 ==========${NC}"
    local dt=$(date +%Y-%m-%d)
    local table_str="${FULL_TABLES[*]}"
    echo -e "${YELLOW}本次同步日期：${dt}${NC}\n"

    # ---------- 阶段1：hadoop100 启动底层基础设施 ----------
    echo -e "${YELLOW}[1/6] [hadoop100] 启动 Zookeeper ...${NC}"
    remote_exec ${HOST_MASTER} "zk.sh start"
    echo -e "${GREEN}    Zookeeper 启动完成${NC}\n"

    echo -e "${YELLOW}[2/6] [hadoop100] 启动 Hadoop 集群 ...${NC}"
    remote_exec ${HOST_MASTER} "myhadoop.sh start"
    echo -e "${GREEN}    Hadoop 集群启动完成${NC}\n"

    echo -e "${YELLOW}[3/6] [hadoop100] 启动 Kafka ...${NC}"
    remote_exec ${HOST_MASTER} "kf.sh start"
    echo -e "${GREEN}    Kafka 启动完成${NC}\n"

    # ---------- 阶段2：hadoop100 启动 Hive 服务 ----------
    echo -e "${YELLOW}[4/6] [hadoop100] 启动 Hive Metastore（端口 9083 检测）...${NC}"
    remote_exec ${HOST_MASTER} "mkdir -p /opt/module/hive-3.1.3/logs && netstat -tlnp 2>/dev/null | grep -q :9083 || nohup hive --service metastore >> /opt/module/hive-3.1.3/logs/metastore.log 2>&1 < /dev/null &"
    echo -e "${GREEN}    Hive Metastore 启动完成${NC}\n"

    echo -e "${YELLOW}[5/6] [hadoop100] 启动 HiveServer2 ...${NC}"
    remote_exec ${HOST_MASTER} "mkdir -p /opt/module/hive-3.1.3/logs && nohup hive --service hiveserver2 >> /opt/module/hive-3.1.3/logs/hiveserver2.log 2>&1 < /dev/null &"
    
    # 等待 HiveServer2 端口就绪，避免后续 beeline 连接失败
    echo -e "${YELLOW}    等待 HiveServer2 端口 10000 就绪 ...${NC}"
    while ! remote_exec ${HOST_MASTER} "netstat -tlnp 2>/dev/null | grep -q :10000"; do
        sleep 2
    done
    echo -e "${GREEN}    HiveServer2 端口就绪${NC}\n"

    # ---------- 阶段3：hadoop101 启动 MySQL ----------
    echo -e "${YELLOW}[6/6] [hadoop101] 启动 MySQL 服务 ...${NC}"
    remote_exec ${HOST_WORKER} "sudo systemctl start mysqld"
    echo -e "${GREEN}    MySQL 启动完成${NC}\n"

    # ---------- 阶段4：hadoop101 创建 HDFS 分区目录 ----------
    echo -e "${YELLOW}========== 创建 HDFS 全量表分区目录 ==========${NC}"
    remote_exec ${HOST_WORKER} "
        for t in ${table_str}; do
            hdfs dfs -mkdir -p /warehouse/gmall/ods/ods_\${t}_full/dt=${dt}
        done
    "
    echo -e "${GREEN}    所有 HDFS 分区目录创建完成${NC}\n"

    # ---------- 阶段5：hadoop101 串行执行 DataX 同步 ----------
    echo -e "${YELLOW}========== 开始串行执行 DataX 全量同步（单任务执行，不并发）==========${NC}"
    remote_exec ${HOST_WORKER} "
        for job in /opt/module/datax/job/import/gmall.*.json; do
            tbl=\$(basename \"\$job\" .json | sed 's/gmall\\.//')
            echo \">>> 开始同步表：\${tbl}\"
            python /opt/module/datax/bin/datax.py -p\"-Dtargetdir=/warehouse/gmall/ods/ods_\${tbl}_full/dt=${dt}\" \"\$job\"
            if [ \$? -ne 0 ]; then
                echo \"!!! 警告：表 \${tbl} 同步失败，继续执行后续任务\"
            fi
            echo \"--- 表 \${tbl} 同步完成 ---\"
        done
    "
    echo -e "${GREEN}    DataX 全量同步任务全部执行完毕${NC}\n"

    # ---------- 阶段6：hadoop100 注册 Hive 分区 ----------
    echo -e "${YELLOW}========== 注册 Hive 分区（MSCK REPAIR）==========${NC}"
    remote_exec ${HOST_MASTER} "
        for t in ${table_str}; do
            echo \">>> 修复表：ods_\${t}_full\"
            beeline -u jdbc:hive2://hadoop100:10000 -n hadoop --silent=true -e \"MSCK REPAIR TABLE ods_\${t}_full\"
        done
    "
    echo -e "${GREEN}    所有表分区注册完成${NC}\n"

    echo -e "${GREEN}========== 全量同步执行完成 ==========${NC}"
}


# ==================== 状态检查函数 ====================
status_cluster() {
    echo -e "${YELLOW}========== 全量同步流水线运行状态 ==========${NC}\n"

    # hadoop100 基础设施状态
    echo -e "${GREEN}[hadoop100] 基础组件状态：${NC}"
    
    echo -n "  Zookeeper: "
    remote_exec ${HOST_MASTER} "zk.sh status > /dev/null 2>&1" && echo -e "${GREEN}运行中${NC}" || echo -e "${RED}未运行${NC}"

    echo -n "  Hadoop: "
    remote_exec ${HOST_MASTER} "jps | grep -q -E 'NameNode|DataNode|ResourceManager|NodeManager'" && echo -e "${GREEN}运行中${NC}" || echo -e "${RED}未运行${NC}"

    echo -n "  Kafka: "
    remote_exec ${HOST_MASTER} "jps | grep -q Kafka" && echo -e "${GREEN}运行中${NC}" || echo -e "${RED}未运行${NC}"

    echo -n "  Hive Metastore(9083): "
    remote_exec ${HOST_MASTER} "netstat -tlnp 2>/dev/null | grep -q :9083" && echo -e "${GREEN}运行中${NC}" || echo -e "${RED}未运行${NC}"

    echo -n "  HiveServer2(10000): "
    remote_exec ${HOST_MASTER} "netstat -tlnp 2>/dev/null | grep -q :10000" && echo -e "${GREEN}运行中${NC}" || echo -e "${RED}未运行${NC}"

    # hadoop101 业务组件状态
    echo -e "\n${GREEN}[hadoop101] 同步组件状态：${NC}"

    echo -n "  MySQL: "
    remote_exec ${HOST_WORKER} "systemctl is-active --quiet mysqld" && echo -e "${GREEN}运行中${NC}" || echo -e "${RED}未运行${NC}"

    echo -n "  DataX 同步任务: "
    remote_exec ${HOST_WORKER} "ps -ef | grep datax.py | grep -v grep -q" && echo -e "${GREEN}运行中${NC}" || echo -e "${RED}未运行${NC}"

    echo -e "\n${YELLOW}========================================${NC}"
}

# ==================== 主入口 ====================
case $1 in
    start)
        start_cluster
        ;;
    status)
        status_cluster
        ;;
    *)
        echo "用法: $0 {start|stop|status}"
        echo "  start  - 串行执行全量同步全流程（基建→建目录→同步→注册分区）"
        echo "  status - 查看各组件运行状态"
        exit 1
        ;;
esac