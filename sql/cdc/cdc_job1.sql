-- ============================================================
-- Flink Job 1: MySQL CDC → Kafka（13 张表，共 27 条 SQL）
-- ============================================================

-- 第 1 条：Kafka Sink
CREATE TABLE kafka_sink (
  table_name STRING,
  row_id     STRING,
  data       STRING,
  PRIMARY KEY (table_name, row_id) NOT ENFORCED
) WITH (
  'connector' = 'upsert-kafka',
  'topic' = 'topic_db',
  'properties.bootstrap.servers' = 'hadoop100:9092,hadoop101:9092,hadoop102:9092',
  'key.format' = 'json',
  'value.format' = 'json'
);

-- ============================================================
-- 第 2-14 条：13 个 CDC Source（按表名字母序排列）
-- ============================================================

-- 第 2 条：cart_info
CREATE TABLE cdc_cart_info (
  id BIGINT, user_id STRING, sku_id BIGINT, cart_price DECIMAL(10,2), sku_num INT,
  img_url STRING, sku_name STRING, is_checked INT, create_time TIMESTAMP,
  operate_time TIMESTAMP, is_ordered BIGINT, order_time TIMESTAMP,
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
  'connector' = 'mysql-cdc', 'hostname' = 'hadoop101', 'port' = '3306',
  'username' = 'root', 'password' = 'root', 'database-name' = 'gmall',
  'table-name' = 'cart_info', 'scan.startup.mode' = 'initial'
);

-- 第 3 条：comment_info
CREATE TABLE cdc_comment_info (
  id BIGINT, user_id BIGINT, nick_name STRING, head_img STRING, sku_id BIGINT,
  spu_id BIGINT, order_id BIGINT, appraise STRING, comment_txt STRING,
  create_time TIMESTAMP, operate_time TIMESTAMP,
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
  'connector' = 'mysql-cdc', 'hostname' = 'hadoop101', 'port' = '3306',
  'username' = 'root', 'password' = 'root', 'database-name' = 'gmall',
  'table-name' = 'comment_info', 'scan.startup.mode' = 'initial'
);

-- 第 4 条：coupon_use
CREATE TABLE cdc_coupon_use (
  id BIGINT, coupon_id BIGINT, user_id BIGINT, order_id BIGINT, coupon_status STRING,
  get_time TIMESTAMP, using_time TIMESTAMP, used_time TIMESTAMP, expire_time TIMESTAMP,
  create_time TIMESTAMP, operate_time TIMESTAMP,
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
  'connector' = 'mysql-cdc', 'hostname' = 'hadoop101', 'port' = '3306',
  'username' = 'root', 'password' = 'root', 'database-name' = 'gmall',
  'table-name' = 'coupon_use', 'scan.startup.mode' = 'initial'
);

-- 第 5 条：favor_info
CREATE TABLE cdc_favor_info (
  id BIGINT, user_id BIGINT, sku_id BIGINT, spu_id BIGINT, is_cancel STRING,
  create_time TIMESTAMP, operate_time TIMESTAMP,
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
  'connector' = 'mysql-cdc', 'hostname' = 'hadoop101', 'port' = '3306',
  'username' = 'root', 'password' = 'root', 'database-name' = 'gmall',
  'table-name' = 'favor_info', 'scan.startup.mode' = 'initial'
);

-- 第 6 条：order_detail
CREATE TABLE cdc_order_detail (
  id BIGINT, order_id BIGINT, sku_id BIGINT, sku_name STRING, img_url STRING,
  order_price DECIMAL(10,2), sku_num BIGINT, create_time TIMESTAMP,
  split_total_amount DECIMAL(16,2), split_activity_amount DECIMAL(16,2),
  split_coupon_amount DECIMAL(16,2), operate_time TIMESTAMP,
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
  'connector' = 'mysql-cdc', 'hostname' = 'hadoop101', 'port' = '3306',
  'username' = 'root', 'password' = 'root', 'database-name' = 'gmall',
  'table-name' = 'order_detail', 'scan.startup.mode' = 'initial'
);

-- 第 7 条：order_detail_activity
CREATE TABLE cdc_order_detail_activity (
  id BIGINT, order_id BIGINT, order_detail_id BIGINT, activity_id BIGINT,
  activity_rule_id BIGINT, sku_id BIGINT, create_time TIMESTAMP, operate_time TIMESTAMP,
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
  'connector' = 'mysql-cdc', 'hostname' = 'hadoop101', 'port' = '3306',
  'username' = 'root', 'password' = 'root', 'database-name' = 'gmall',
  'table-name' = 'order_detail_activity', 'scan.startup.mode' = 'initial'
);

-- 第 8 条：order_detail_coupon
CREATE TABLE cdc_order_detail_coupon (
  id BIGINT, order_id BIGINT, order_detail_id BIGINT, coupon_id BIGINT,
  coupon_use_id BIGINT, sku_id BIGINT, create_time TIMESTAMP, operate_time TIMESTAMP,
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
  'connector' = 'mysql-cdc', 'hostname' = 'hadoop101', 'port' = '3306',
  'username' = 'root', 'password' = 'root', 'database-name' = 'gmall',
  'table-name' = 'order_detail_coupon', 'scan.startup.mode' = 'initial'
);

-- 第 9 条：order_info
CREATE TABLE cdc_order_info (
  id BIGINT, consignee STRING, consignee_tel STRING, total_amount DECIMAL(10,2),
  order_status STRING, user_id BIGINT, payment_way STRING, delivery_address STRING,
  order_comment STRING, out_trade_no STRING, trade_body STRING, create_time TIMESTAMP,
  operate_time TIMESTAMP, expire_time TIMESTAMP, process_status STRING, tracking_no STRING,
  parent_order_id BIGINT, img_url STRING, province_id INT,
  activity_reduce_amount DECIMAL(16,2), coupon_reduce_amount DECIMAL(16,2),
  original_total_amount DECIMAL(16,2), feight_fee DECIMAL(16,2),
  feight_fee_reduce DECIMAL(16,2), refundable_time TIMESTAMP,
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
  'connector' = 'mysql-cdc', 'hostname' = 'hadoop101', 'port' = '3306',
  'username' = 'root', 'password' = 'root', 'database-name' = 'gmall',
  'table-name' = 'order_info', 'scan.startup.mode' = 'initial'
);

-- 第 10 条：order_refund_info
CREATE TABLE cdc_order_refund_info (
  id BIGINT, user_id BIGINT, order_id BIGINT, sku_id BIGINT, refund_type STRING,
  refund_num BIGINT, refund_amount DECIMAL(16,2), refund_reason_type STRING,
  refund_reason_txt STRING, refund_status STRING, create_time TIMESTAMP, operate_time TIMESTAMP,
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
  'connector' = 'mysql-cdc', 'hostname' = 'hadoop101', 'port' = '3306',
  'username' = 'root', 'password' = 'root', 'database-name' = 'gmall',
  'table-name' = 'order_refund_info', 'scan.startup.mode' = 'initial'
);

-- 第 11 条：order_status_log
CREATE TABLE cdc_order_status_log (
  id BIGINT, order_id BIGINT, order_status STRING, create_time TIMESTAMP, operate_time TIMESTAMP,
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
  'connector' = 'mysql-cdc', 'hostname' = 'hadoop101', 'port' = '3306',
  'username' = 'root', 'password' = 'root', 'database-name' = 'gmall',
  'table-name' = 'order_status_log', 'scan.startup.mode' = 'initial'
);

-- 第 12 条：payment_info
CREATE TABLE cdc_payment_info (
  id INT, out_trade_no STRING, order_id BIGINT, user_id BIGINT, payment_type STRING,
  trade_no STRING, total_amount DECIMAL(10,2), subject STRING, payment_status STRING,
  create_time TIMESTAMP, callback_time TIMESTAMP, callback_content STRING, operate_time TIMESTAMP,
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
  'connector' = 'mysql-cdc', 'hostname' = 'hadoop101', 'port' = '3306',
  'username' = 'root', 'password' = 'root', 'database-name' = 'gmall',
  'table-name' = 'payment_info', 'scan.startup.mode' = 'initial'
);

-- 第 13 条：refund_payment
CREATE TABLE cdc_refund_payment (
  id INT, out_trade_no STRING, order_id BIGINT, sku_id BIGINT, payment_type STRING,
  trade_no STRING, total_amount DECIMAL(10,2), subject STRING, refund_status STRING,
  create_time TIMESTAMP, callback_time TIMESTAMP, callback_content STRING, operate_time TIMESTAMP,
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
  'connector' = 'mysql-cdc', 'hostname' = 'hadoop101', 'port' = '3306',
  'username' = 'root', 'password' = 'root', 'database-name' = 'gmall',
  'table-name' = 'refund_payment', 'scan.startup.mode' = 'initial'
);

-- 第 14 条：user_info
CREATE TABLE cdc_user_info (
  id BIGINT, login_name STRING, nick_name STRING, passwd STRING, name STRING,
  phone_num STRING, email STRING, head_img STRING, user_level STRING, birthday STRING,
  gender STRING, create_time TIMESTAMP, operate_time TIMESTAMP,
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
  'connector' = 'mysql-cdc', 'hostname' = 'hadoop101', 'port' = '3306',
  'username' = 'root', 'password' = 'root', 'database-name' = 'gmall',
  'table-name' = 'user_info', 'scan.startup.mode' = 'initial'
);

-- ============================================================
-- 第 15-27 条：13 条 INSERT 语句（CDC 数据序列化 → Kafka）
-- ============================================================

-- 第 15 条
INSERT INTO kafka_sink
SELECT 'cart_info', CAST(id AS STRING),
  JSON_OBJECT('id' VALUE id, 'user_id' VALUE user_id, 'sku_id' VALUE sku_id,
    'cart_price' VALUE cart_price, 'sku_num' VALUE sku_num,
    'img_url' VALUE img_url, 'sku_name' VALUE sku_name,
    'is_checked' VALUE is_checked,
    'create_time' VALUE CAST(create_time AS STRING),
    'operate_time' VALUE CAST(operate_time AS STRING),
    'is_ordered' VALUE is_ordered,
    'order_time' VALUE CAST(order_time AS STRING))
FROM cdc_cart_info;

-- 第 16 条
INSERT INTO kafka_sink
SELECT 'comment_info', CAST(id AS STRING),
  JSON_OBJECT('id' VALUE id, 'user_id' VALUE user_id, 'nick_name' VALUE nick_name,
    'head_img' VALUE head_img, 'sku_id' VALUE sku_id, 'spu_id' VALUE spu_id,
    'order_id' VALUE order_id, 'appraise' VALUE appraise,
    'comment_txt' VALUE comment_txt,
    'create_time' VALUE CAST(create_time AS STRING),
    'operate_time' VALUE CAST(operate_time AS STRING))
FROM cdc_comment_info;

-- 第 17 条
INSERT INTO kafka_sink
SELECT 'coupon_use', CAST(id AS STRING),
  JSON_OBJECT('id' VALUE id, 'coupon_id' VALUE coupon_id, 'user_id' VALUE user_id,
    'order_id' VALUE order_id, 'coupon_status' VALUE coupon_status,
    'get_time' VALUE CAST(get_time AS STRING),
    'using_time' VALUE CAST(using_time AS STRING),
    'used_time' VALUE CAST(used_time AS STRING),
    'expire_time' VALUE CAST(expire_time AS STRING),
    'create_time' VALUE CAST(create_time AS STRING),
    'operate_time' VALUE CAST(operate_time AS STRING))
FROM cdc_coupon_use;

-- 第 18 条
INSERT INTO kafka_sink
SELECT 'favor_info', CAST(id AS STRING),
  JSON_OBJECT('id' VALUE id, 'user_id' VALUE user_id, 'sku_id' VALUE sku_id,
    'spu_id' VALUE spu_id, 'is_cancel' VALUE is_cancel,
    'create_time' VALUE CAST(create_time AS STRING),
    'operate_time' VALUE CAST(operate_time AS STRING))
FROM cdc_favor_info;

-- 第 19 条
INSERT INTO kafka_sink
SELECT 'order_detail', CAST(id AS STRING),
  JSON_OBJECT('id' VALUE id, 'order_id' VALUE order_id, 'sku_id' VALUE sku_id,
    'sku_name' VALUE sku_name, 'img_url' VALUE img_url,
    'order_price' VALUE order_price, 'sku_num' VALUE sku_num,
    'create_time' VALUE CAST(create_time AS STRING),
    'split_total_amount' VALUE split_total_amount,
    'split_activity_amount' VALUE split_activity_amount,
    'split_coupon_amount' VALUE split_coupon_amount,
    'operate_time' VALUE CAST(operate_time AS STRING))
FROM cdc_order_detail;

-- 第 20 条
INSERT INTO kafka_sink
SELECT 'order_detail_activity', CAST(id AS STRING),
  JSON_OBJECT('id' VALUE id, 'order_id' VALUE order_id,
    'order_detail_id' VALUE order_detail_id, 'activity_id' VALUE activity_id,
    'activity_rule_id' VALUE activity_rule_id, 'sku_id' VALUE sku_id,
    'create_time' VALUE CAST(create_time AS STRING),
    'operate_time' VALUE CAST(operate_time AS STRING))
FROM cdc_order_detail_activity;

-- 第 21 条
INSERT INTO kafka_sink
SELECT 'order_detail_coupon', CAST(id AS STRING),
  JSON_OBJECT('id' VALUE id, 'order_id' VALUE order_id,
    'order_detail_id' VALUE order_detail_id, 'coupon_id' VALUE coupon_id,
    'coupon_use_id' VALUE coupon_use_id, 'sku_id' VALUE sku_id,
    'create_time' VALUE CAST(create_time AS STRING),
    'operate_time' VALUE CAST(operate_time AS STRING))
FROM cdc_order_detail_coupon;

-- 第 22 条
INSERT INTO kafka_sink
SELECT 'order_info', CAST(id AS STRING),
  JSON_OBJECT('id' VALUE id, 'consignee' VALUE consignee,
    'consignee_tel' VALUE consignee_tel, 'total_amount' VALUE total_amount,
    'order_status' VALUE order_status, 'user_id' VALUE user_id,
    'payment_way' VALUE payment_way, 'delivery_address' VALUE delivery_address,
    'order_comment' VALUE order_comment, 'out_trade_no' VALUE out_trade_no,
    'trade_body' VALUE trade_body, 'create_time' VALUE CAST(create_time AS STRING),
    'operate_time' VALUE CAST(operate_time AS STRING),
    'expire_time' VALUE CAST(expire_time AS STRING),
    'process_status' VALUE process_status, 'tracking_no' VALUE tracking_no,
    'parent_order_id' VALUE parent_order_id, 'img_url' VALUE img_url,
    'province_id' VALUE province_id,
    'activity_reduce_amount' VALUE activity_reduce_amount,
    'coupon_reduce_amount' VALUE coupon_reduce_amount,
    'original_total_amount' VALUE original_total_amount,
    'feight_fee' VALUE feight_fee, 'feight_fee_reduce' VALUE feight_fee_reduce,
    'refundable_time' VALUE CAST(refundable_time AS STRING))
FROM cdc_order_info;

-- 第 23 条
INSERT INTO kafka_sink
SELECT 'order_refund_info', CAST(id AS STRING),
  JSON_OBJECT('id' VALUE id, 'user_id' VALUE user_id, 'order_id' VALUE order_id,
    'sku_id' VALUE sku_id, 'refund_type' VALUE refund_type,
    'refund_num' VALUE refund_num, 'refund_amount' VALUE refund_amount,
    'refund_reason_type' VALUE refund_reason_type,
    'refund_reason_txt' VALUE refund_reason_txt,
    'refund_status' VALUE refund_status,
    'create_time' VALUE CAST(create_time AS STRING),
    'operate_time' VALUE CAST(operate_time AS STRING))
FROM cdc_order_refund_info;

-- 第 24 条
INSERT INTO kafka_sink
SELECT 'order_status_log', CAST(id AS STRING),
  JSON_OBJECT('id' VALUE id, 'order_id' VALUE order_id,
    'order_status' VALUE order_status,
    'create_time' VALUE CAST(create_time AS STRING),
    'operate_time' VALUE CAST(operate_time AS STRING))
FROM cdc_order_status_log;

-- 第 25 条
INSERT INTO kafka_sink
SELECT 'payment_info', CAST(id AS STRING),
  JSON_OBJECT('id' VALUE id, 'out_trade_no' VALUE out_trade_no,
    'order_id' VALUE order_id, 'user_id' VALUE user_id,
    'payment_type' VALUE payment_type, 'trade_no' VALUE trade_no,
    'total_amount' VALUE total_amount, 'subject' VALUE subject,
    'payment_status' VALUE payment_status,
    'create_time' VALUE CAST(create_time AS STRING),
    'callback_time' VALUE CAST(callback_time AS STRING),
    'callback_content' VALUE callback_content,
    'operate_time' VALUE CAST(operate_time AS STRING))
FROM cdc_payment_info;

-- 第 26 条
INSERT INTO kafka_sink
SELECT 'refund_payment', CAST(id AS STRING),
  JSON_OBJECT('id' VALUE id, 'out_trade_no' VALUE out_trade_no,
    'order_id' VALUE order_id, 'sku_id' VALUE sku_id,
    'payment_type' VALUE payment_type, 'trade_no' VALUE trade_no,
    'total_amount' VALUE total_amount, 'subject' VALUE subject,
    'refund_status' VALUE refund_status,
    'create_time' VALUE CAST(create_time AS STRING),
    'callback_time' VALUE CAST(callback_time AS STRING),
    'callback_content' VALUE callback_content,
    'operate_time' VALUE CAST(operate_time AS STRING))
FROM cdc_refund_payment;

-- 第 27 条
INSERT INTO kafka_sink
SELECT 'user_info', CAST(id AS STRING),
  JSON_OBJECT('id' VALUE id, 'login_name' VALUE login_name, 'nick_name' VALUE nick_name,
    'passwd' VALUE passwd, 'name' VALUE name, 'phone_num' VALUE phone_num,
    'email' VALUE email, 'head_img' VALUE head_img, 'user_level' VALUE user_level,
    'birthday' VALUE birthday, 'gender' VALUE gender,
    'create_time' VALUE CAST(create_time AS STRING),
    'operate_time' VALUE CAST(operate_time AS STRING))
FROM cdc_user_info;
