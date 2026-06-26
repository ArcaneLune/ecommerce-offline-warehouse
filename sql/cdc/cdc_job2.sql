-- ============================================================
-- Flink Job 2: Kafka → Iceberg（13 张表，共 15 条 SQL）
-- ★ 表由 Hive 管理，Flink 只做 INSERT
-- ★ CREATE CATALOG 的 warehouse 必须与 Hive 一致
-- ============================================================

-- 第 1 条：Kafka Source
CREATE TABLE kafka_source (
  table_name STRING, row_id STRING, data STRING
) WITH (
  'connector' = 'kafka', 'topic' = 'topic_db',
  'properties.bootstrap.servers' = 'hadoop100:9092,hadoop101:9092,hadoop102:9092',
  'properties.group.id' = 'flink_iceberg_consumer',
  'format' = 'json', 'scan.startup.mode' = 'earliest-offset'
);

-- 第 2 条：HiveCatalog（warehouse 参数必须与 Spark spark-defaults.conf 一致）
CREATE CATALOG hive_iceberg WITH (
  'type' = 'iceberg',
  'catalog-type' = 'hive',
  'uri' = 'thrift://hadoop100:9083',
  'warehouse' = 'hdfs://hadoop100:8020/warehouse'
);

-- ============================================================
-- 第 3-15 条：13 条 INSERT 语句（Kafka JSON → Iceberg 表）
-- ============================================================

-- 第 3 条：cart_info
INSERT INTO `hive_iceberg`.`default`.`ods_cart_info_inc`
SELECT
  CAST(JSON_VALUE(data,'$.id') AS BIGINT),
  JSON_VALUE(data,'$.user_id'),
  CAST(JSON_VALUE(data,'$.sku_id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.cart_price') AS DECIMAL(10,2)),
  CAST(JSON_VALUE(data,'$.sku_num') AS INT),
  JSON_VALUE(data,'$.img_url'),
  JSON_VALUE(data,'$.sku_name'),
  CAST(JSON_VALUE(data,'$.is_checked') AS INT),
  JSON_VALUE(data,'$.create_time'),
  JSON_VALUE(data,'$.operate_time'),
  CAST(JSON_VALUE(data,'$.is_ordered') AS BIGINT),
  JSON_VALUE(data,'$.order_time'),
  SUBSTRING(JSON_VALUE(data,'$.create_time'),1,10)
FROM kafka_source
WHERE table_name = 'cart_info';

-- 第 4 条：comment_info
INSERT INTO `hive_iceberg`.`default`.`ods_comment_info_inc`
SELECT
  CAST(JSON_VALUE(data,'$.id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.user_id') AS BIGINT),
  JSON_VALUE(data,'$.nick_name'),
  JSON_VALUE(data,'$.head_img'),
  CAST(JSON_VALUE(data,'$.sku_id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.spu_id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.order_id') AS BIGINT),
  JSON_VALUE(data,'$.appraise'),
  JSON_VALUE(data,'$.comment_txt'),
  JSON_VALUE(data,'$.create_time'),
  JSON_VALUE(data,'$.operate_time'),
  SUBSTRING(JSON_VALUE(data,'$.create_time'),1,10)
FROM kafka_source
WHERE table_name = 'comment_info';

-- 第 5 条：coupon_use
INSERT INTO `hive_iceberg`.`default`.`ods_coupon_use_inc`
SELECT
  CAST(JSON_VALUE(data,'$.id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.coupon_id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.user_id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.order_id') AS BIGINT),
  JSON_VALUE(data,'$.coupon_status'),
  JSON_VALUE(data,'$.get_time'),
  JSON_VALUE(data,'$.using_time'),
  JSON_VALUE(data,'$.used_time'),
  JSON_VALUE(data,'$.expire_time'),
  JSON_VALUE(data,'$.create_time'),
  JSON_VALUE(data,'$.operate_time'),
  SUBSTRING(JSON_VALUE(data,'$.create_time'),1,10)
FROM kafka_source
WHERE table_name = 'coupon_use';

-- 第 6 条：favor_info
INSERT INTO `hive_iceberg`.`default`.`ods_favor_info_inc`
SELECT
  CAST(JSON_VALUE(data,'$.id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.user_id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.sku_id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.spu_id') AS BIGINT),
  JSON_VALUE(data,'$.is_cancel'),
  JSON_VALUE(data,'$.create_time'),
  JSON_VALUE(data,'$.operate_time'),
  SUBSTRING(JSON_VALUE(data,'$.create_time'),1,10)
FROM kafka_source
WHERE table_name = 'favor_info';

-- 第 7 条：order_detail
INSERT INTO `hive_iceberg`.`default`.`ods_order_detail_inc`
SELECT
  CAST(JSON_VALUE(data,'$.id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.order_id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.sku_id') AS BIGINT),
  JSON_VALUE(data,'$.sku_name'),
  JSON_VALUE(data,'$.img_url'),
  CAST(JSON_VALUE(data,'$.order_price') AS DECIMAL(10,2)),
  CAST(JSON_VALUE(data,'$.sku_num') AS BIGINT),
  JSON_VALUE(data,'$.create_time'),
  CAST(JSON_VALUE(data,'$.split_total_amount') AS DECIMAL(16,2)),
  CAST(JSON_VALUE(data,'$.split_activity_amount') AS DECIMAL(16,2)),
  CAST(JSON_VALUE(data,'$.split_coupon_amount') AS DECIMAL(16,2)),
  JSON_VALUE(data,'$.operate_time'),
  SUBSTRING(JSON_VALUE(data,'$.create_time'),1,10)
FROM kafka_source
WHERE table_name = 'order_detail';

-- 第 8 条：order_detail_activity
INSERT INTO `hive_iceberg`.`default`.`ods_order_detail_activity_inc`
SELECT
  CAST(JSON_VALUE(data,'$.id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.order_id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.order_detail_id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.activity_id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.activity_rule_id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.sku_id') AS BIGINT),
  JSON_VALUE(data,'$.create_time'),
  JSON_VALUE(data,'$.operate_time'),
  SUBSTRING(JSON_VALUE(data,'$.create_time'),1,10)
FROM kafka_source
WHERE table_name = 'order_detail_activity';

-- 第 9 条：order_detail_coupon
INSERT INTO `hive_iceberg`.`default`.`ods_order_detail_coupon_inc`
SELECT
  CAST(JSON_VALUE(data,'$.id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.order_id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.order_detail_id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.coupon_id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.coupon_use_id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.sku_id') AS BIGINT),
  JSON_VALUE(data,'$.create_time'),
  JSON_VALUE(data,'$.operate_time'),
  SUBSTRING(JSON_VALUE(data,'$.create_time'),1,10)
FROM kafka_source
WHERE table_name = 'order_detail_coupon';

-- 第 10 条：order_info
INSERT INTO `hive_iceberg`.`default`.`ods_order_info_inc`
SELECT
  CAST(JSON_VALUE(data,'$.id') AS BIGINT),
  JSON_VALUE(data,'$.consignee'),
  JSON_VALUE(data,'$.consignee_tel'),
  CAST(JSON_VALUE(data,'$.total_amount') AS DECIMAL(10,2)),
  JSON_VALUE(data,'$.order_status'),
  CAST(JSON_VALUE(data,'$.user_id') AS BIGINT),
  JSON_VALUE(data,'$.payment_way'),
  JSON_VALUE(data,'$.delivery_address'),
  JSON_VALUE(data,'$.order_comment'),
  JSON_VALUE(data,'$.out_trade_no'),
  JSON_VALUE(data,'$.trade_body'),
  JSON_VALUE(data,'$.create_time'),
  JSON_VALUE(data,'$.operate_time'),
  JSON_VALUE(data,'$.expire_time'),
  JSON_VALUE(data,'$.process_status'),
  JSON_VALUE(data,'$.tracking_no'),
  CAST(JSON_VALUE(data,'$.parent_order_id') AS BIGINT),
  JSON_VALUE(data,'$.img_url'),
  CAST(JSON_VALUE(data,'$.province_id') AS INT),
  CAST(JSON_VALUE(data,'$.activity_reduce_amount') AS DECIMAL(16,2)),
  CAST(JSON_VALUE(data,'$.coupon_reduce_amount') AS DECIMAL(16,2)),
  CAST(JSON_VALUE(data,'$.original_total_amount') AS DECIMAL(16,2)),
  CAST(JSON_VALUE(data,'$.feight_fee') AS DECIMAL(16,2)),
  CAST(JSON_VALUE(data,'$.feight_fee_reduce') AS DECIMAL(16,2)),
  JSON_VALUE(data,'$.refundable_time'),
  SUBSTRING(JSON_VALUE(data,'$.create_time'),1,10)
FROM kafka_source
WHERE table_name = 'order_info';

-- 第 11 条：order_refund_info
INSERT INTO `hive_iceberg`.`default`.`ods_order_refund_info_inc`
SELECT
  CAST(JSON_VALUE(data,'$.id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.user_id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.order_id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.sku_id') AS BIGINT),
  JSON_VALUE(data,'$.refund_type'),
  CAST(JSON_VALUE(data,'$.refund_num') AS BIGINT),
  CAST(JSON_VALUE(data,'$.refund_amount') AS DECIMAL(16,2)),
  JSON_VALUE(data,'$.refund_reason_type'),
  JSON_VALUE(data,'$.refund_reason_txt'),
  JSON_VALUE(data,'$.refund_status'),
  JSON_VALUE(data,'$.create_time'),
  JSON_VALUE(data,'$.operate_time'),
  SUBSTRING(JSON_VALUE(data,'$.create_time'),1,10)
FROM kafka_source
WHERE table_name = 'order_refund_info';

-- 第 12 条：order_status_log
INSERT INTO `hive_iceberg`.`default`.`ods_order_status_log_inc`
SELECT
  CAST(JSON_VALUE(data,'$.id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.order_id') AS BIGINT),
  JSON_VALUE(data,'$.order_status'),
  JSON_VALUE(data,'$.create_time'),
  JSON_VALUE(data,'$.operate_time'),
  SUBSTRING(JSON_VALUE(data,'$.create_time'),1,10)
FROM kafka_source
WHERE table_name = 'order_status_log';

-- 第 13 条：payment_info
INSERT INTO `hive_iceberg`.`default`.`ods_payment_info_inc`
SELECT
  CAST(JSON_VALUE(data,'$.id') AS INT),
  JSON_VALUE(data,'$.out_trade_no'),
  CAST(JSON_VALUE(data,'$.order_id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.user_id') AS BIGINT),
  JSON_VALUE(data,'$.payment_type'),
  JSON_VALUE(data,'$.trade_no'),
  CAST(JSON_VALUE(data,'$.total_amount') AS DECIMAL(10,2)),
  JSON_VALUE(data,'$.subject'),
  JSON_VALUE(data,'$.payment_status'),
  JSON_VALUE(data,'$.create_time'),
  JSON_VALUE(data,'$.callback_time'),
  JSON_VALUE(data,'$.callback_content'),
  JSON_VALUE(data,'$.operate_time'),
  SUBSTRING(JSON_VALUE(data,'$.create_time'),1,10)
FROM kafka_source
WHERE table_name = 'payment_info';

-- 第 14 条：refund_payment
INSERT INTO `hive_iceberg`.`default`.`ods_refund_payment_inc`
SELECT
  CAST(JSON_VALUE(data,'$.id') AS INT),
  JSON_VALUE(data,'$.out_trade_no'),
  CAST(JSON_VALUE(data,'$.order_id') AS BIGINT),
  CAST(JSON_VALUE(data,'$.sku_id') AS BIGINT),
  JSON_VALUE(data,'$.payment_type'),
  JSON_VALUE(data,'$.trade_no'),
  CAST(JSON_VALUE(data,'$.total_amount') AS DECIMAL(10,2)),
  JSON_VALUE(data,'$.subject'),
  JSON_VALUE(data,'$.refund_status'),
  JSON_VALUE(data,'$.create_time'),
  JSON_VALUE(data,'$.callback_time'),
  JSON_VALUE(data,'$.callback_content'),
  JSON_VALUE(data,'$.operate_time'),
  SUBSTRING(JSON_VALUE(data,'$.create_time'),1,10)
FROM kafka_source
WHERE table_name = 'refund_payment';

-- 第 15 条：user_info
INSERT INTO `hive_iceberg`.`default`.`ods_user_info_inc`
SELECT
  CAST(JSON_VALUE(data,'$.id') AS BIGINT),
  JSON_VALUE(data,'$.login_name'),
  JSON_VALUE(data,'$.nick_name'),
  JSON_VALUE(data,'$.passwd'),
  JSON_VALUE(data,'$.name'),
  JSON_VALUE(data,'$.phone_num'),
  JSON_VALUE(data,'$.email'),
  JSON_VALUE(data,'$.head_img'),
  JSON_VALUE(data,'$.user_level'),
  JSON_VALUE(data,'$.birthday'),
  JSON_VALUE(data,'$.gender'),
  JSON_VALUE(data,'$.create_time'),
  JSON_VALUE(data,'$.operate_time'),
  SUBSTRING(JSON_VALUE(data,'$.create_time'),1,10)
FROM kafka_source
WHERE table_name = 'user_info';
