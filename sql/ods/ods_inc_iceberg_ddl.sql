-- ============================================================
-- Iceberg 增量表建表 DDL（13 张）— Hive STORED BY 版
--
-- 架构原则：通过 Hive Metastore 的 Iceberg StorageHandler 建表
--          Flink 通过 HiveCatalog 直接 INSERT
--
-- 前置：hive-site.xml 中配置 Hive on Spark 引擎
--       Iceberg Hive Runtime JAR 在 $HIVE_HOME/lib/ 中
--
-- 执行：hive -f /opt/software/ods_inc_iceberg_ddl.sql
-- ============================================================

-- 第 1 张：cart_info
DROP TABLE IF EXISTS ods_cart_info_inc;
CREATE TABLE ods_cart_info_inc (
  id BIGINT, user_id STRING, sku_id BIGINT, cart_price DECIMAL(10,2), sku_num INT,
  img_url STRING, sku_name STRING, is_checked INT, create_time STRING, operate_time STRING,
  is_ordered BIGINT, order_time STRING
) PARTITIONED BY (dt STRING)
STORED BY 'org.apache.iceberg.mr.hive.HiveIcebergStorageHandler'
LOCATION 'hdfs://hadoop100:8020/warehouse/gmall/ods/default/ods_cart_info_inc'
TBLPROPERTIES ('write.format.default'='parquet','format-version'='2');

-- 第 2 张：comment_info
DROP TABLE IF EXISTS ods_comment_info_inc;
CREATE TABLE ods_comment_info_inc (
  id BIGINT, user_id BIGINT, nick_name STRING, head_img STRING, sku_id BIGINT,
  spu_id BIGINT, order_id BIGINT, appraise STRING, comment_txt STRING,
  create_time STRING, operate_time STRING
) PARTITIONED BY (dt STRING)
STORED BY 'org.apache.iceberg.mr.hive.HiveIcebergStorageHandler'
LOCATION 'hdfs://hadoop100:8020/warehouse/gmall/ods/default/ods_comment_info_inc'
TBLPROPERTIES ('write.format.default'='parquet','format-version'='2');

-- 第 3 张：coupon_use
DROP TABLE IF EXISTS ods_coupon_use_inc;
CREATE TABLE ods_coupon_use_inc (
  id BIGINT, coupon_id BIGINT, user_id BIGINT, order_id BIGINT, coupon_status STRING,
  get_time STRING, using_time STRING, used_time STRING, expire_time STRING,
  create_time STRING, operate_time STRING
) PARTITIONED BY (dt STRING)
STORED BY 'org.apache.iceberg.mr.hive.HiveIcebergStorageHandler'
LOCATION 'hdfs://hadoop100:8020/warehouse/gmall/ods/default/ods_coupon_use_inc'
TBLPROPERTIES ('write.format.default'='parquet','format-version'='2');

-- 第 4 张：favor_info
DROP TABLE IF EXISTS ods_favor_info_inc;
CREATE TABLE ods_favor_info_inc (
  id BIGINT, user_id BIGINT, sku_id BIGINT, spu_id BIGINT, is_cancel STRING,
  create_time STRING, operate_time STRING
) PARTITIONED BY (dt STRING)
STORED BY 'org.apache.iceberg.mr.hive.HiveIcebergStorageHandler'
LOCATION 'hdfs://hadoop100:8020/warehouse/gmall/ods/default/ods_favor_info_inc'
TBLPROPERTIES ('write.format.default'='parquet','format-version'='2');

-- 第 5 张：order_detail
DROP TABLE IF EXISTS ods_order_detail_inc;
CREATE TABLE ods_order_detail_inc (
  id BIGINT, order_id BIGINT, sku_id BIGINT, sku_name STRING, img_url STRING,
  order_price DECIMAL(10,2), sku_num BIGINT, create_time STRING,
  split_total_amount DECIMAL(16,2), split_activity_amount DECIMAL(16,2),
  split_coupon_amount DECIMAL(16,2), operate_time STRING
) PARTITIONED BY (dt STRING)
STORED BY 'org.apache.iceberg.mr.hive.HiveIcebergStorageHandler'
LOCATION 'hdfs://hadoop100:8020/warehouse/gmall/ods/default/ods_order_detail_inc'
TBLPROPERTIES ('write.format.default'='parquet','format-version'='2');

-- 第 6 张：order_detail_activity
DROP TABLE IF EXISTS ods_order_detail_activity_inc;
CREATE TABLE ods_order_detail_activity_inc (
  id BIGINT, order_id BIGINT, order_detail_id BIGINT, activity_id BIGINT,
  activity_rule_id BIGINT, sku_id BIGINT, create_time STRING, operate_time STRING
) PARTITIONED BY (dt STRING)
STORED BY 'org.apache.iceberg.mr.hive.HiveIcebergStorageHandler'
LOCATION 'hdfs://hadoop100:8020/warehouse/gmall/ods/default/ods_order_detail_activity_inc'
TBLPROPERTIES ('write.format.default'='parquet','format-version'='2');

-- 第 7 张：order_detail_coupon
DROP TABLE IF EXISTS ods_order_detail_coupon_inc;
CREATE TABLE ods_order_detail_coupon_inc (
  id BIGINT, order_id BIGINT, order_detail_id BIGINT, coupon_id BIGINT,
  coupon_use_id BIGINT, sku_id BIGINT, create_time STRING, operate_time STRING
) PARTITIONED BY (dt STRING)
STORED BY 'org.apache.iceberg.mr.hive.HiveIcebergStorageHandler'
LOCATION 'hdfs://hadoop100:8020/warehouse/gmall/ods/default/ods_order_detail_coupon_inc'
TBLPROPERTIES ('write.format.default'='parquet','format-version'='2');

-- 第 8 张：order_info
DROP TABLE IF EXISTS ods_order_info_inc;
CREATE TABLE ods_order_info_inc (
  id BIGINT, consignee STRING, consignee_tel STRING, total_amount DECIMAL(10,2),
  order_status STRING, user_id BIGINT, payment_way STRING, delivery_address STRING,
  order_comment STRING, out_trade_no STRING, trade_body STRING, create_time STRING,
  operate_time STRING, expire_time STRING, process_status STRING, tracking_no STRING,
  parent_order_id BIGINT, img_url STRING, province_id INT,
  activity_reduce_amount DECIMAL(16,2), coupon_reduce_amount DECIMAL(16,2),
  original_total_amount DECIMAL(16,2), feight_fee DECIMAL(16,2),
  feight_fee_reduce DECIMAL(16,2), refundable_time STRING
) PARTITIONED BY (dt STRING)
STORED BY 'org.apache.iceberg.mr.hive.HiveIcebergStorageHandler'
LOCATION 'hdfs://hadoop100:8020/warehouse/gmall/ods/default/ods_order_info_inc'
TBLPROPERTIES ('write.format.default'='parquet','format-version'='2');

-- 第 9 张：order_refund_info
DROP TABLE IF EXISTS ods_order_refund_info_inc;
CREATE TABLE ods_order_refund_info_inc (
  id BIGINT, user_id BIGINT, order_id BIGINT, sku_id BIGINT, refund_type STRING,
  refund_num BIGINT, refund_amount DECIMAL(16,2), refund_reason_type STRING,
  refund_reason_txt STRING, refund_status STRING, create_time STRING, operate_time STRING
) PARTITIONED BY (dt STRING)
STORED BY 'org.apache.iceberg.mr.hive.HiveIcebergStorageHandler'
LOCATION 'hdfs://hadoop100:8020/warehouse/gmall/ods/default/ods_order_refund_info_inc'
TBLPROPERTIES ('write.format.default'='parquet','format-version'='2');

-- 第 10 张：order_status_log
DROP TABLE IF EXISTS ods_order_status_log_inc;
CREATE TABLE ods_order_status_log_inc (
  id BIGINT, order_id BIGINT, order_status STRING, create_time STRING, operate_time STRING
) PARTITIONED BY (dt STRING)
STORED BY 'org.apache.iceberg.mr.hive.HiveIcebergStorageHandler'
LOCATION 'hdfs://hadoop100:8020/warehouse/gmall/ods/default/ods_order_status_log_inc'
TBLPROPERTIES ('write.format.default'='parquet','format-version'='2');

-- 第 11 张：payment_info
DROP TABLE IF EXISTS ods_payment_info_inc;
CREATE TABLE ods_payment_info_inc (
  id INT, out_trade_no STRING, order_id BIGINT, user_id BIGINT, payment_type STRING,
  trade_no STRING, total_amount DECIMAL(10,2), subject STRING, payment_status STRING,
  create_time STRING, callback_time STRING, callback_content STRING, operate_time STRING
) PARTITIONED BY (dt STRING)
STORED BY 'org.apache.iceberg.mr.hive.HiveIcebergStorageHandler'
LOCATION 'hdfs://hadoop100:8020/warehouse/gmall/ods/default/ods_payment_info_inc'
TBLPROPERTIES ('write.format.default'='parquet','format-version'='2');

-- 第 12 张：refund_payment
DROP TABLE IF EXISTS ods_refund_payment_inc;
CREATE TABLE ods_refund_payment_inc (
  id INT, out_trade_no STRING, order_id BIGINT, sku_id BIGINT, payment_type STRING,
  trade_no STRING, total_amount DECIMAL(10,2), subject STRING, refund_status STRING,
  create_time STRING, callback_time STRING, callback_content STRING, operate_time STRING
) PARTITIONED BY (dt STRING)
STORED BY 'org.apache.iceberg.mr.hive.HiveIcebergStorageHandler'
LOCATION 'hdfs://hadoop100:8020/warehouse/gmall/ods/default/ods_refund_payment_inc'
TBLPROPERTIES ('write.format.default'='parquet','format-version'='2');

-- 第 13 张：user_info
DROP TABLE IF EXISTS ods_user_info_inc;
CREATE TABLE ods_user_info_inc (
  id BIGINT, login_name STRING, nick_name STRING, passwd STRING, name STRING,
  phone_num STRING, email STRING, head_img STRING, user_level STRING, birthday STRING,
  gender STRING, create_time STRING, operate_time STRING
) PARTITIONED BY (dt STRING)
STORED BY 'org.apache.iceberg.mr.hive.HiveIcebergStorageHandler'
LOCATION 'hdfs://hadoop100:8020/warehouse/gmall/ods/default/ods_user_info_inc'
TBLPROPERTIES ('write.format.default'='parquet','format-version'='2');
