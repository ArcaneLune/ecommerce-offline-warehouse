-- ============================================================
-- DWS 层首日装载（全量数据，动态分区）
-- 执行：hive --hivevar dt=YYYY-mm-dd -f dws_load_first.sql
-- ============================================================

set hive.exec.dynamic.partition.mode=nonstrict;

-- ============================================================
-- 10.1.1 交易域用户商品粒度订单最近1日汇总表
-- ============================================================
INSERT OVERWRITE TABLE dws_trade_user_sku_order_1d PARTITION (dt)
SELECT
    t1.user_id,
    sku.id,
    sku.sku_name,
    sku.category1_id,
    sku.category1_name,
    sku.category2_id,
    sku.category2_name,
    sku.category3_id,
    sku.category3_name,
    sku.tm_id,
    sku.tm_name,
    t1.order_count_1d,
    t1.order_num_1d,
    t1.order_original_amount_1d,
    t1.activity_reduce_amount_1d,
    t1.coupon_reduce_amount_1d,
    t1.order_total_amount_1d,
    t1.dt
FROM (
    SELECT
        dt,
        user_id,
        sku_id,
        COUNT(*)                                          AS order_count_1d,
        SUM(sku_num)                                      AS order_num_1d,
        SUM(split_original_amount)                        AS order_original_amount_1d,
        SUM(COALESCE(split_activity_amount, CAST(0.0 AS DECIMAL(16,2)))) AS activity_reduce_amount_1d,
        SUM(COALESCE(split_coupon_amount, CAST(0.0 AS DECIMAL(16,2))))   AS coupon_reduce_amount_1d,
        SUM(split_total_amount)                           AS order_total_amount_1d
    FROM dwd_trade_order_detail_inc
    GROUP BY dt, user_id, sku_id
) t1
LEFT JOIN (
    SELECT
        id, sku_name,
        category1_id, category1_name,
        category2_id, category2_name,
        category3_id, category3_name,
        tm_id, tm_name
    FROM dim_sku_full
    WHERE dt = '${hivevar:dt}'
) sku ON t1.sku_id = sku.id;

-- ============================================================
-- 10.1.2 交易域用户粒度订单最近1日汇总表
-- ============================================================
INSERT OVERWRITE TABLE dws_trade_user_order_1d PARTITION (dt)
SELECT
    user_id,
    COUNT(DISTINCT order_id)                              AS order_count_1d,
    SUM(sku_num)                                          AS order_num_1d,
    SUM(split_original_amount)                            AS order_original_amount_1d,
    SUM(COALESCE(split_activity_amount, CAST(0.0 AS DECIMAL(16,2)))) AS activity_reduce_amount_1d,
    SUM(COALESCE(split_coupon_amount, CAST(0.0 AS DECIMAL(16,2))))   AS coupon_reduce_amount_1d,
    SUM(split_total_amount)                               AS order_total_amount_1d,
    dt
FROM dwd_trade_order_detail_inc
GROUP BY user_id, dt;

-- ============================================================
-- 10.1.3 交易域用户粒度加购最近1日汇总表
-- ============================================================
INSERT OVERWRITE TABLE dws_trade_user_cart_add_1d PARTITION (dt)
SELECT
    user_id,
    COUNT(*)     AS cart_add_count_1d,
    SUM(sku_num) AS cart_add_num_1d,
    dt
FROM dwd_trade_cart_add_inc
GROUP BY user_id, dt;

-- ============================================================
-- 10.1.4 交易域用户粒度支付最近1日汇总表
-- ============================================================
INSERT OVERWRITE TABLE dws_trade_user_payment_1d PARTITION (dt)
SELECT
    user_id,
    COUNT(DISTINCT order_id)          AS payment_count_1d,
    SUM(sku_num)                      AS payment_num_1d,
    SUM(split_payment_amount)         AS payment_amount_1d,
    dt
FROM dwd_trade_pay_detail_suc_inc
GROUP BY user_id, dt;

-- ============================================================
-- 10.1.5 交易域省份粒度订单最近1日汇总表
-- ============================================================
INSERT OVERWRITE TABLE dws_trade_province_order_1d PARTITION (dt)
SELECT
    t1.province_id,
    pro.province_name,
    pro.area_code,
    pro.iso_code,
    pro.iso_3166_2,
    pro.region_id,
    pro.region_name,
    t1.order_count_1d,
    t1.order_num_1d,
    t1.order_original_amount_1d,
    t1.activity_reduce_amount_1d,
    t1.coupon_reduce_amount_1d,
    t1.order_total_amount_1d,
    t1.dt
FROM (
    SELECT
        dt,
        province_id,
        COUNT(DISTINCT order_id)                              AS order_count_1d,
        SUM(sku_num)                                          AS order_num_1d,
        SUM(split_original_amount)                            AS order_original_amount_1d,
        SUM(COALESCE(split_activity_amount, CAST(0.0 AS DECIMAL(16,2)))) AS activity_reduce_amount_1d,
        SUM(COALESCE(split_coupon_amount, CAST(0.0 AS DECIMAL(16,2))))   AS coupon_reduce_amount_1d,
        SUM(split_total_amount)                               AS order_total_amount_1d
    FROM dwd_trade_order_detail_inc
    GROUP BY dt, province_id
) t1
LEFT JOIN (
    SELECT
        id,
        province_name,
        area_code,
        iso_code,
        iso_3166_2,
        region_id,
        region_name
    FROM dim_province_full
    WHERE dt = '${hivevar:dt}'
) pro ON t1.province_id = pro.id;

-- ============================================================
-- 10.1.6 流量域会话粒度页面浏览最近1日汇总表
-- ============================================================
INSERT OVERWRITE TABLE dws_traffic_session_page_view_1d PARTITION (dt)
SELECT
    session_id,
    mid_id,
    brand,
    model,
    operate_system,
    version_code,
    channel,
    SUM(during_time) AS during_time_1d,
    COUNT(*)         AS page_count_1d,
    dt
FROM dwd_traffic_page_view_inc
GROUP BY dt, session_id, mid_id, brand, model, operate_system, version_code, channel;

-- ============================================================
-- 10.1.7 流量域访客页面粒度页面浏览最近1日汇总表
-- ============================================================
INSERT OVERWRITE TABLE dws_traffic_page_visitor_page_view_1d PARTITION (dt)
SELECT
    mid_id,
    brand,
    model,
    operate_system,
    page_id,
    SUM(during_time) AS during_time_1d,
    COUNT(*)         AS view_count_1d,
    dt
FROM dwd_traffic_page_view_inc
GROUP BY dt, mid_id, brand, model, operate_system, page_id;

-- ============================================================
-- 10.1.8 工具域优惠券使用最近1日汇总表
-- ============================================================
INSERT OVERWRITE TABLE dws_tool_coupon_used_1d PARTITION (dt)
SELECT
    t1.coupon_id,
    cou.coupon_name,
    cou.coupon_type,
    cou.benefit_amount,
    t1.used_count_1d,
    t1.dt
FROM (
    SELECT
        dt,
        coupon_id,
        COUNT(*) AS used_count_1d
    FROM dwd_tool_coupon_used_inc
    GROUP BY dt, coupon_id
) t1
LEFT JOIN (
    SELECT
        id               AS coupon_id,
        coupon_name,
        coupon_type_name AS coupon_type,
        benefit_amount
    FROM dim_coupon_full
    WHERE dt = '${hivevar:dt}'
) cou ON t1.coupon_id = cou.coupon_id;

-- ============================================================
-- 10.1.9 互动域商品收藏最近1日汇总表
-- ============================================================
INSERT OVERWRITE TABLE dws_interaction_sku_favor_add_1d PARTITION (dt)
SELECT
    t1.sku_id,
    sku.sku_name,
    t1.favor_add_count_1d,
    t1.dt
FROM (
    SELECT
        dt,
        sku_id,
        COUNT(*) AS favor_add_count_1d
    FROM dwd_interaction_favor_add_inc
    GROUP BY dt, sku_id
) t1
LEFT JOIN (
    SELECT id, sku_name
    FROM dim_sku_full
    WHERE dt = '${hivevar:dt}'
) sku ON t1.sku_id = sku.id;

-- ============================================================
-- 10.2.1 交易域用户商品粒度订单最近N日汇总表（7d + 30d）
-- ============================================================
INSERT OVERWRITE TABLE dws_trade_user_sku_order_nd PARTITION (dt)
SELECT
    user_id,
    sku_id,
    sku_name,
    category1_id,
    category1_name,
    category2_id,
    category2_name,
    category3_id,
    category3_name,
    tm_id,
    tm_name,
    SUM(IF(dt >= date_add('${hivevar:dt}', -6), order_count_1d, 0))            AS order_count_7d,
    SUM(IF(dt >= date_add('${hivevar:dt}', -6), order_num_1d, 0))              AS order_num_7d,
    SUM(IF(dt >= date_add('${hivevar:dt}', -6), order_original_amount_1d, 0))  AS order_original_amount_7d,
    SUM(IF(dt >= date_add('${hivevar:dt}', -6), activity_reduce_amount_1d, 0)) AS activity_reduce_amount_7d,
    SUM(IF(dt >= date_add('${hivevar:dt}', -6), coupon_reduce_amount_1d, 0))   AS coupon_reduce_amount_7d,
    SUM(IF(dt >= date_add('${hivevar:dt}', -6), order_total_amount_1d, 0))     AS order_total_amount_7d,
    SUM(IF(dt >= date_add('${hivevar:dt}', -29), order_count_1d, 0))           AS order_count_30d,
    SUM(IF(dt >= date_add('${hivevar:dt}', -29), order_num_1d, 0))             AS order_num_30d,
    SUM(IF(dt >= date_add('${hivevar:dt}', -29), order_original_amount_1d, 0)) AS order_original_amount_30d,
    SUM(IF(dt >= date_add('${hivevar:dt}', -29), activity_reduce_amount_1d, 0)) AS activity_reduce_amount_30d,
    SUM(IF(dt >= date_add('${hivevar:dt}', -29), coupon_reduce_amount_1d, 0))  AS coupon_reduce_amount_30d,
    SUM(IF(dt >= date_add('${hivevar:dt}', -29), order_total_amount_1d, 0))    AS order_total_amount_30d,
    '${hivevar:dt}'
FROM dws_trade_user_sku_order_1d
GROUP BY user_id, sku_id, sku_name,
    category1_id, category1_name,
    category2_id, category2_name,
    category3_id, category3_name,
    tm_id, tm_name;

-- ============================================================
-- 10.3.1 交易域用户粒度订单历史至今汇总表
-- ============================================================
INSERT OVERWRITE TABLE dws_trade_user_order_td PARTITION (dt = '${hivevar:dt}')
SELECT
    user_id,
    MIN(dt)           AS order_date_first,
    MAX(dt)           AS order_date_last,
    SUM(order_count_1d)            AS order_count_td,
    SUM(order_num_1d)              AS order_num_td,
    SUM(order_original_amount_1d)  AS order_original_amount_td,
    SUM(activity_reduce_amount_1d) AS activity_reduce_amount_td,
    SUM(coupon_reduce_amount_1d)   AS coupon_reduce_amount_td,
    SUM(order_total_amount_1d)     AS order_total_amount_td
FROM dws_trade_user_order_1d
GROUP BY user_id;

-- ============================================================
-- 10.3.2 用户域用户粒度登录历史至今汇总表
-- ============================================================
INSERT OVERWRITE TABLE dws_user_user_login_td PARTITION (dt = '${hivevar:dt}')
SELECT
    user_id,
    MIN(date_id)  AS login_date_first,
    MAX(date_id)  AS login_date_last,
    COUNT(*)      AS login_count_td
FROM dwd_user_login_inc
GROUP BY user_id;
