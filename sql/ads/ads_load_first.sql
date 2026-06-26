-- ============================================================
-- ADS 层首日装载（纯 INSERT，无自引用）
-- 执行：hive --hivevar dt=YYYY-mm-dd -f ads_load_first.sql
-- ============================================================

-- ============================================================
-- 11.1.1 各渠道流量统计
-- ============================================================
INSERT OVERWRITE TABLE ads_traffic_stats_by_channel
SELECT
    '${hivevar:dt}' dt,
    recent_days,
    channel,
    CAST(COUNT(DISTINCT(mid_id)) AS BIGINT) uv_count,
    CAST(AVG(during_time_1d) / 1000 AS BIGINT) avg_duration_sec,
    CAST(AVG(page_count_1d) AS BIGINT) avg_page_count,
    CAST(COUNT(*) AS BIGINT) sv_count,
    CAST(SUM(IF(page_count_1d = 1, 1, 0)) / COUNT(*) AS DECIMAL(16, 2)) bounce_rate
FROM dws_traffic_session_page_view_1d
LATERAL VIEW EXPLODE(ARRAY(1, 7, 30)) tmp AS recent_days
WHERE dt >= date_add('${hivevar:dt}', -recent_days + 1)
GROUP BY recent_days, channel;

-- ============================================================
-- 11.1.2 路径分析
-- ============================================================
INSERT OVERWRITE TABLE ads_page_path
SELECT
    '${hivevar:dt}' dt,
    source,
    COALESCE(target, 'null'),
    COUNT(*) path_count
FROM (
    SELECT
        CONCAT('step-', rn, ':', page_id) source,
        CONCAT('step-', rn + 1, ':', next_page_id) target
    FROM (
        SELECT
            page_id,
            LEAD(page_id, 1, NULL) OVER (PARTITION BY session_id ORDER BY view_time) next_page_id,
            ROW_NUMBER() OVER (PARTITION BY session_id ORDER BY view_time) rn
        FROM dwd_traffic_page_view_inc
        WHERE dt = '${hivevar:dt}'
    ) t1
) t2
GROUP BY source, target;

-- ============================================================
-- 11.2.1 用户变动统计
-- ============================================================
INSERT OVERWRITE TABLE ads_user_change
SELECT
    churn.dt,
    user_churn_count,
    user_back_count
FROM (
    SELECT
        '${hivevar:dt}' dt,
        COUNT(*) user_churn_count
    FROM dws_user_user_login_td
    WHERE dt = '${hivevar:dt}'
      AND login_date_last = date_add('${hivevar:dt}', -7)
) churn
JOIN (
    SELECT
        '${hivevar:dt}' dt,
        COUNT(*) user_back_count
    FROM (
        SELECT
            user_id,
            login_date_last
        FROM dws_user_user_login_td
        WHERE dt = '${hivevar:dt}'
          AND login_date_last = '${hivevar:dt}'
    ) t1
    JOIN (
        SELECT
            user_id,
            login_date_last login_date_previous
        FROM dws_user_user_login_td
        WHERE dt = date_add('${hivevar:dt}', -1)
    ) t2 ON t1.user_id = t2.user_id
    WHERE datediff(login_date_last, login_date_previous) >= 8
) back ON churn.dt = back.dt;

-- ============================================================
-- 11.2.2 用户留存率
-- ============================================================
INSERT OVERWRITE TABLE ads_user_retention
SELECT
    '${hivevar:dt}' dt,
    login_date_first create_date,
    datediff('${hivevar:dt}', login_date_first) retention_day,
    SUM(IF(login_date_last = '${hivevar:dt}', 1, 0)) retention_count,
    COUNT(*) new_user_count,
    CAST(SUM(IF(login_date_last = '${hivevar:dt}', 1, 0)) / COUNT(*) * 100 AS DECIMAL(16, 2)) retention_rate
FROM (
    SELECT
        user_id,
        login_date_last,
        login_date_first
    FROM dws_user_user_login_td
    WHERE dt = '${hivevar:dt}'
      AND login_date_first >= date_add('${hivevar:dt}', -7)
      AND login_date_first < '${hivevar:dt}'
) t1
GROUP BY login_date_first;

-- ============================================================
-- 11.2.3 用户新增活跃统计
-- ============================================================
INSERT OVERWRITE TABLE ads_user_stats
SELECT
    '${hivevar:dt}' dt,
    recent_days,
    SUM(IF(login_date_first >= date_add('${hivevar:dt}', -recent_days + 1), 1, 0)) new_user_count,
    COUNT(*) active_user_count
FROM dws_user_user_login_td
LATERAL VIEW EXPLODE(ARRAY(1, 7, 30)) tmp AS recent_days
WHERE dt = '${hivevar:dt}'
  AND login_date_last >= date_add('${hivevar:dt}', -recent_days + 1)
GROUP BY recent_days;

-- ============================================================
-- 11.2.4 用户行为漏斗分析
-- ============================================================
INSERT OVERWRITE TABLE ads_user_action
SELECT
    '${hivevar:dt}' dt,
    home_count,
    good_detail_count,
    cart_count,
    order_count,
    payment_count
FROM (
    SELECT
        1 recent_days,
        SUM(IF(page_id = 'home', 1, 0)) home_count,
        SUM(IF(page_id = 'good_detail', 1, 0)) good_detail_count
    FROM dws_traffic_page_visitor_page_view_1d
    WHERE dt = '${hivevar:dt}'
      AND page_id IN ('home', 'good_detail')
) page
JOIN (
    SELECT 1 recent_days, COUNT(*) cart_count
    FROM dws_trade_user_cart_add_1d
    WHERE dt = '${hivevar:dt}'
) cart ON page.recent_days = cart.recent_days
JOIN (
    SELECT 1 recent_days, COUNT(*) order_count
    FROM dws_trade_user_order_1d
    WHERE dt = '${hivevar:dt}'
) ord ON page.recent_days = ord.recent_days
JOIN (
    SELECT 1 recent_days, COUNT(*) payment_count
    FROM dws_trade_user_payment_1d
    WHERE dt = '${hivevar:dt}'
) pay ON page.recent_days = pay.recent_days;

-- ============================================================
-- 11.2.5 新增下单用户统计
-- ============================================================
INSERT OVERWRITE TABLE ads_new_order_user_stats
SELECT
    '${hivevar:dt}' dt,
    recent_days,
    COUNT(*) new_order_user_count
FROM dws_trade_user_order_td
LATERAL VIEW EXPLODE(ARRAY(1, 7, 30)) tmp AS recent_days
WHERE dt = '${hivevar:dt}'
  AND order_date_first >= date_add('${hivevar:dt}', -recent_days + 1)
GROUP BY recent_days;

-- ============================================================
-- 11.2.6 最近7日内连续3日下单用户数
-- ============================================================
INSERT OVERWRITE TABLE ads_order_continuously_user_count
SELECT
    '${hivevar:dt}',
    7,
    COUNT(DISTINCT(user_id))
FROM (
    SELECT
        user_id,
        datediff(LEAD(dt, 2, '9999-12-31') OVER (PARTITION BY user_id ORDER BY dt), dt) diff
    FROM dws_trade_user_order_1d
    WHERE dt >= date_add('${hivevar:dt}', -6)
) t1
WHERE diff = 2;

-- ============================================================
-- 11.3.1 最近30日各品牌复购率
-- ============================================================
INSERT OVERWRITE TABLE ads_repeat_purchase_by_tm
SELECT
    '${hivevar:dt}',
    30,
    tm_id,
    tm_name,
    CAST(SUM(IF(order_count >= 2, 1, 0)) / SUM(IF(order_count >= 1, 1, 0)) AS DECIMAL(16, 2))
FROM (
    SELECT
        user_id,
        tm_id,
        tm_name,
        SUM(order_count_30d) order_count
    FROM dws_trade_user_sku_order_nd
    WHERE dt = '${hivevar:dt}'
    GROUP BY user_id, tm_id, tm_name
) t1
GROUP BY tm_id, tm_name;

-- ============================================================
-- 11.3.2 各品牌商品下单统计
-- ============================================================
INSERT OVERWRITE TABLE ads_order_stats_by_tm
SELECT
    '${hivevar:dt}' dt,
    recent_days,
    tm_id,
    tm_name,
    order_count,
    order_user_count
FROM (
    SELECT
        1 recent_days,
        tm_id,
        tm_name,
        SUM(order_count_1d) order_count,
        COUNT(DISTINCT(user_id)) order_user_count
    FROM dws_trade_user_sku_order_1d
    WHERE dt = '${hivevar:dt}'
    GROUP BY tm_id, tm_name
    UNION ALL
    SELECT
        recent_days,
        tm_id,
        tm_name,
        SUM(order_count),
        COUNT(DISTINCT(IF(order_count > 0, user_id, NULL)))
    FROM (
        SELECT
            recent_days,
            user_id,
            tm_id,
            tm_name,
            CASE recent_days
                WHEN 7 THEN order_count_7d
                WHEN 30 THEN order_count_30d
            END order_count
        FROM dws_trade_user_sku_order_nd
        LATERAL VIEW EXPLODE(ARRAY(7, 30)) tmp AS recent_days
        WHERE dt = '${hivevar:dt}'
    ) t1
    GROUP BY recent_days, tm_id, tm_name
) odr;

-- ============================================================
-- 11.3.3 各品类商品下单统计
-- ============================================================
INSERT OVERWRITE TABLE ads_order_stats_by_cate
SELECT
    '${hivevar:dt}' dt,
    recent_days,
    category1_id,
    category1_name,
    category2_id,
    category2_name,
    category3_id,
    category3_name,
    order_count,
    order_user_count
FROM (
    SELECT
        1 recent_days,
        category1_id,
        category1_name,
        category2_id,
        category2_name,
        category3_id,
        category3_name,
        SUM(order_count_1d) order_count,
        COUNT(DISTINCT(user_id)) order_user_count
    FROM dws_trade_user_sku_order_1d
    WHERE dt = '${hivevar:dt}'
    GROUP BY category1_id, category1_name,
             category2_id, category2_name,
             category3_id, category3_name
    UNION ALL
    SELECT
        recent_days,
        category1_id,
        category1_name,
        category2_id,
        category2_name,
        category3_id,
        category3_name,
        SUM(order_count),
        COUNT(DISTINCT(IF(order_count > 0, user_id, NULL)))
    FROM (
        SELECT
            recent_days,
            user_id,
            category1_id,
            category1_name,
            category2_id,
            category2_name,
            category3_id,
            category3_name,
            CASE recent_days
                WHEN 7 THEN order_count_7d
                WHEN 30 THEN order_count_30d
            END order_count
        FROM dws_trade_user_sku_order_nd
        LATERAL VIEW EXPLODE(ARRAY(7, 30)) tmp AS recent_days
        WHERE dt = '${hivevar:dt}'
    ) t1
    GROUP BY recent_days,
             category1_id, category1_name,
             category2_id, category2_name,
             category3_id, category3_name
) odr;

-- ============================================================
-- 11.3.4 各品类商品购物车存量Top3
-- ============================================================
SET hive.mapjoin.optimized.hashtable = false;

INSERT OVERWRITE TABLE ads_sku_cart_num_top3_by_cate
SELECT
    '${hivevar:dt}' dt,
    category1_id,
    category1_name,
    category2_id,
    category2_name,
    category3_id,
    category3_name,
    sku_id,
    sku_name,
    cart_num,
    rk
FROM (
    SELECT
        sku_id,
        sku_name,
        category1_id,
        category1_name,
        category2_id,
        category2_name,
        category3_id,
        category3_name,
        cart_num,
        RANK() OVER (PARTITION BY category1_id, category2_id, category3_id ORDER BY cart_num DESC) rk
    FROM (
        SELECT
            sku_id,
            SUM(sku_num) cart_num
        FROM dwd_trade_cart_full
        WHERE dt = '${hivevar:dt}'
        GROUP BY sku_id
    ) cart
    LEFT JOIN (
        SELECT
            id,
            sku_name,
            category1_id,
            category1_name,
            category2_id,
            category2_name,
            category3_id,
            category3_name
        FROM dim_sku_full
        WHERE dt = '${hivevar:dt}'
    ) sku ON cart.sku_id = sku.id
) t1
WHERE rk <= 3;

SET hive.mapjoin.optimized.hashtable = true;

-- ============================================================
-- 11.3.5 各品牌商品收藏次数Top3
-- ============================================================
INSERT OVERWRITE TABLE ads_sku_favor_count_top3_by_tm
SELECT
    '${hivevar:dt}' dt,
    tm_id,
    tm_name,
    sku_id,
    sku_name,
    favor_add_count_1d,
    rk
FROM (
    SELECT
        sku.tm_id,
        sku.tm_name,
        fav.sku_id,
        sku.sku_name,
        fav.favor_add_count_1d,
        RANK() OVER (PARTITION BY sku.tm_id ORDER BY fav.favor_add_count_1d DESC) rk
    FROM dws_interaction_sku_favor_add_1d fav
    LEFT JOIN (
        SELECT id, sku_name, tm_id, tm_name
        FROM dim_sku_full
        WHERE dt = '${hivevar:dt}'
    ) sku ON fav.sku_id = sku.id
    WHERE fav.dt = '${hivevar:dt}'
) t1
WHERE rk <= 3;

-- ============================================================
-- 11.4.1 下单到支付时间间隔平均值
-- ============================================================
INSERT OVERWRITE TABLE ads_order_to_pay_interval_avg
SELECT
    '${hivevar:dt}',
    CAST(AVG(unix_timestamp(payment_time) - unix_timestamp(order_time)) AS BIGINT)
FROM dwd_trade_trade_flow_acc
WHERE dt IN ('9999-12-31', '${hivevar:dt}')
  AND payment_date_id = '${hivevar:dt}';

-- ============================================================
-- 11.4.2 各省份交易统计
-- ============================================================
INSERT OVERWRITE TABLE ads_order_by_province
SELECT
    '${hivevar:dt}' dt,
    1 recent_days,
    province_id,
    province_name,
    area_code,
    iso_code,
    iso_3166_2,
    order_count_1d,
    order_total_amount_1d
FROM dws_trade_province_order_1d
WHERE dt = '${hivevar:dt}'
UNION
SELECT
    '${hivevar:dt}' dt,
    recent_days,
    province_id,
    province_name,
    area_code,
    iso_code,
    iso_3166_2,
    SUM(order_count_1d) order_count,
    SUM(order_total_amount_1d) order_total_amount
FROM dws_trade_province_order_1d
LATERAL VIEW EXPLODE(ARRAY(7, 30)) tmp AS recent_days
WHERE dt >= date_add('${hivevar:dt}', -recent_days + 1)
  AND dt <= '${hivevar:dt}'
GROUP BY recent_days, province_id, province_name, area_code, iso_code, iso_3166_2;

-- ============================================================
-- 11.5.1 优惠券使用统计
-- ============================================================
INSERT OVERWRITE TABLE ads_coupon_stats
SELECT
    '${hivevar:dt}' dt,
    t1.coupon_id,
    cou.coupon_name,
    CAST(COUNT(*) AS BIGINT) used_count,
    CAST(COUNT(DISTINCT t1.user_id) AS BIGINT) used_user_count
FROM dwd_tool_coupon_used_inc t1
LEFT JOIN (
    SELECT id AS coupon_id, coupon_name
    FROM dim_coupon_full
    WHERE dt = '${hivevar:dt}'
) cou ON t1.coupon_id = cou.coupon_id
WHERE t1.dt = '${hivevar:dt}'
GROUP BY t1.coupon_id, cou.coupon_name;
