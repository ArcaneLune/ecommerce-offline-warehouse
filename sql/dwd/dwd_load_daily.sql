-- ============================================================
-- DWD 层每日装载（增量，写入当日分区）
-- 执行：hive --hivevar dt=YYYY-mm-dd -f dwd_load_daily.sql
-- ============================================================

set hive.exec.dynamic.partition.mode=nonstrict;

-- 9.1 加购
INSERT OVERWRITE TABLE dwd_trade_cart_add_inc PARTITION (dt='${hivevar:dt}')
SELECT CAST(id AS STRING), CAST(user_id AS STRING), CAST(sku_id AS STRING),
    date_format(create_time,'yyyy-MM-dd'), create_time,
    CAST(sku_num AS BIGINT)
FROM ods_cart_info_inc WHERE SUBSTRING(create_time,1,10) = '${hivevar:dt}';

-- 9.2 下单
INSERT OVERWRITE TABLE dwd_trade_order_detail_inc PARTITION (dt='${hivevar:dt}')
SELECT CAST(od.id AS STRING), CAST(od.order_id AS STRING), CAST(oi.user_id AS STRING),
    CAST(od.sku_id AS STRING), CAST(oi.province_id AS STRING),
    CAST(act.activity_id AS STRING), CAST(act.activity_rule_id AS STRING),
    CAST(cou.coupon_id AS STRING),
    date_format(od.create_time,'yyyy-MM-dd'), od.create_time, od.sku_num,
    CAST(od.sku_num AS DECIMAL(16,2))*od.order_price,
    COALESCE(od.split_activity_amount,CAST(0.0 AS DECIMAL(16,2))),
    COALESCE(od.split_coupon_amount,CAST(0.0 AS DECIMAL(16,2))),
    od.split_total_amount
FROM ods_order_detail_inc od
LEFT JOIN ods_order_info_inc oi ON od.order_id=oi.id
LEFT JOIN ods_order_detail_activity_inc act ON od.id=act.order_detail_id
LEFT JOIN ods_order_detail_coupon_inc cou ON od.id=cou.order_detail_id
WHERE SUBSTRING(od.create_time,1,10) = '${hivevar:dt}';

-- 9.3 支付成功
INSERT OVERWRITE TABLE dwd_trade_pay_detail_suc_inc PARTITION (dt='${hivevar:dt}')
SELECT CAST(od.id AS STRING), CAST(od.order_id AS STRING), CAST(oi.user_id AS STRING),
    CAST(od.sku_id AS STRING), CAST(oi.province_id AS STRING),
    CAST(act.activity_id AS STRING), CAST(act.activity_rule_id AS STRING),
    CAST(cou.coupon_id AS STRING),
    pi.payment_type, pay_dic.dic_name,
    date_format(pi.callback_time,'yyyy-MM-dd'), pi.callback_time, od.sku_num,
    CAST(od.sku_num AS DECIMAL(16,2))*od.order_price,
    COALESCE(od.split_activity_amount,CAST(0.0 AS DECIMAL(16,2))),
    COALESCE(od.split_coupon_amount,CAST(0.0 AS DECIMAL(16,2))),
    od.split_total_amount
FROM ods_order_detail_inc od
JOIN (SELECT order_id,user_id,payment_type,callback_time FROM ods_payment_info_inc WHERE payment_status='1602') pi ON od.order_id=pi.order_id
LEFT JOIN ods_order_info_inc oi ON od.order_id=oi.id
LEFT JOIN ods_order_detail_activity_inc act ON od.id=act.order_detail_id
LEFT JOIN ods_order_detail_coupon_inc cou ON od.id=cou.order_detail_id
LEFT JOIN (SELECT dic_code,dic_name FROM ods_base_dic_full WHERE dt='${hivevar:dt}' AND parent_code='11') pay_dic ON pi.payment_type=pay_dic.dic_code
WHERE SUBSTRING(pi.callback_time,1,10) = '${hivevar:dt}';

-- 9.4 购物车快照
INSERT OVERWRITE TABLE dwd_trade_cart_full PARTITION (dt='${hivevar:dt}')
SELECT id,user_id,sku_id,sku_name,sku_num
FROM ods_cart_info_full WHERE dt='${hivevar:dt}' AND is_ordered='0';

-- 9.5 交易流程累积
INSERT OVERWRITE TABLE dwd_trade_trade_flow_acc PARTITION (dt)
SELECT CAST(oi.id AS STRING), CAST(oi.user_id AS STRING), CAST(oi.province_id AS STRING),
    date_format(oi.create_time,'yyyy-MM-dd'), oi.create_time,
    date_format(pi.callback_time,'yyyy-MM-dd'), pi.callback_time,
    date_format(log.create_time,'yyyy-MM-dd'), log.create_time,
    oi.original_total_amount, oi.activity_reduce_amount, oi.coupon_reduce_amount, oi.total_amount,
    COALESCE(pi.total_amount,CAST(0.0 AS DECIMAL(16,2))),
    COALESCE(date_format(log.create_time,'yyyy-MM-dd'),'9999-12-31')
FROM ods_order_info_inc oi
LEFT JOIN (SELECT order_id,callback_time,total_amount FROM ods_payment_info_inc WHERE payment_status='1602') pi ON oi.id=pi.order_id
LEFT JOIN (SELECT order_id,create_time FROM ods_order_status_log_inc WHERE order_status='1004') log ON oi.id=log.order_id
WHERE SUBSTRING(oi.create_time,1,10) = '${hivevar:dt}';

-- 9.6 优惠券使用
INSERT OVERWRITE TABLE dwd_tool_coupon_used_inc PARTITION (dt='${hivevar:dt}')
SELECT CAST(id AS STRING), CAST(coupon_id AS STRING), CAST(user_id AS STRING),
    CAST(order_id AS STRING), date_format(used_time,'yyyy-MM-dd'), used_time
FROM ods_coupon_use_inc WHERE used_time IS NOT NULL AND SUBSTRING(used_time,1,10)='${hivevar:dt}';

-- 9.7 收藏
INSERT OVERWRITE TABLE dwd_interaction_favor_add_inc PARTITION (dt='${hivevar:dt}')
SELECT CAST(id AS STRING), CAST(user_id AS STRING), CAST(sku_id AS STRING),
    date_format(create_time,'yyyy-MM-dd'), create_time
FROM ods_favor_info_inc WHERE SUBSTRING(create_time,1,10)='${hivevar:dt}';

-- 9.8 页面浏览
set hive.cbo.enable=false;
INSERT OVERWRITE TABLE dwd_traffic_page_view_inc PARTITION (dt='${hivevar:dt}')
SELECT common.ar,common.ba,common.ch,common.is_new,common.md,common.mid,common.os,common.uid,common.vc,
    page.item,page.item_type,page.last_page_id,page.page_id,page.from_pos_id,page.from_pos_seq,page.refer_id,
    date_format(from_utc_timestamp(ts,'GMT+8'),'yyyy-MM-dd'),
    date_format(from_utc_timestamp(ts,'GMT+8'),'yyyy-MM-dd HH:mm:ss'),
    common.sid,page.during_time
FROM ods_log_inc WHERE dt='${hivevar:dt}' AND page IS NOT NULL;
set hive.cbo.enable=true;

-- 9.9 用户注册
INSERT OVERWRITE TABLE dwd_user_register_inc PARTITION (dt='${hivevar:dt}')
SELECT CAST(ui.id AS STRING), date_format(ui.create_time,'yyyy-MM-dd'), ui.create_time,
    log.channel,log.province_id,log.version_code,log.mid_id,log.brand,log.model,log.operate_system
FROM ods_user_info_inc ui
LEFT JOIN (
    SELECT common.ar province_id,common.ba brand,common.ch channel,common.md model,
        common.mid mid_id,common.os operate_system,common.uid user_id,common.vc version_code
    FROM ods_log_inc WHERE dt='${hivevar:dt}' AND page.page_id='register' AND common.uid IS NOT NULL
) log ON CAST(ui.id AS STRING)=log.user_id
WHERE SUBSTRING(ui.create_time,1,10)='${hivevar:dt}';

-- 9.10 用户登录
INSERT OVERWRITE TABLE dwd_user_login_inc PARTITION (dt='${hivevar:dt}')
SELECT user_id, date_format(from_utc_timestamp(ts,'GMT+8'),'yyyy-MM-dd'),
    date_format(from_utc_timestamp(ts,'GMT+8'),'yyyy-MM-dd HH:mm:ss'),
    channel,province_id,version_code,mid_id,brand,model,operate_system
FROM (
    SELECT common.uid user_id,common.ch channel,common.ar province_id,common.vc version_code,
        common.mid mid_id,common.ba brand,common.md model,common.os operate_system,ts,
        ROW_NUMBER() OVER(PARTITION BY common.sid ORDER BY ts) rn
    FROM ods_log_inc WHERE dt='${hivevar:dt}' AND page IS NOT NULL AND common.uid IS NOT NULL
) t1 WHERE rn=1;
