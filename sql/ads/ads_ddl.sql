-- ============================================================
-- ADS 层建表 DDL
-- 格式：TextFile TAB分隔，供 DataX 导出 MySQL
-- 执行：hive -f /opt/software/ads_ddl.sql
-- ============================================================

-- ============================================================
-- 11.1 流量主题
-- ============================================================

-- 11.1.1 各渠道流量统计
CREATE TABLE IF NOT EXISTS ads_traffic_stats_by_channel (
    dt               STRING COMMENT '统计日期',
    recent_days      BIGINT COMMENT '最近天数,1:最近1天,7:最近7天,30:最近30天',
    channel          STRING COMMENT '渠道',
    uv_count         BIGINT COMMENT '访客人数',
    avg_duration_sec BIGINT COMMENT '会话平均停留时长，单位为秒',
    avg_page_count   BIGINT COMMENT '会话平均浏览页面数',
    sv_count         BIGINT COMMENT '会话数',
    bounce_rate      DECIMAL(16, 2) COMMENT '跳出率'
) COMMENT '各渠道流量统计'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/gmall/ads/ads_traffic_stats_by_channel/';

-- 11.1.2 路径分析
CREATE TABLE IF NOT EXISTS ads_page_path (
    dt          STRING COMMENT '统计日期',
    source      STRING COMMENT '跳转起始页面ID',
    target      STRING COMMENT '跳转终到页面ID',
    path_count  BIGINT COMMENT '跳转次数'
) COMMENT '页面浏览路径分析'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/gmall/ads/ads_page_path/';

-- ============================================================
-- 11.2 用户主题
-- ============================================================

-- 11.2.1 用户变动统计
CREATE TABLE IF NOT EXISTS ads_user_change (
    dt               STRING COMMENT '统计日期',
    user_churn_count BIGINT COMMENT '流失用户数',
    user_back_count  BIGINT COMMENT '回流用户数'
) COMMENT '用户变动统计'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/gmall/ads/ads_user_change/';

-- 11.2.2 用户留存率
CREATE TABLE IF NOT EXISTS ads_user_retention (
    dt              STRING COMMENT '统计日期',
    create_date     STRING COMMENT '用户新增日期',
    retention_day   INT COMMENT '截至当前日期留存天数',
    retention_count BIGINT COMMENT '留存用户数量',
    new_user_count  BIGINT COMMENT '新增用户数量',
    retention_rate  DECIMAL(16, 2) COMMENT '留存率'
) COMMENT '用户留存率'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/gmall/ads/ads_user_retention/';

-- 11.2.3 用户新增活跃统计
CREATE TABLE IF NOT EXISTS ads_user_stats (
    dt                STRING COMMENT '统计日期',
    recent_days       BIGINT COMMENT '最近n日,1:最近1日,7:最近7日,30:最近30日',
    new_user_count    BIGINT COMMENT '新增用户数',
    active_user_count BIGINT COMMENT '活跃用户数'
) COMMENT '用户新增活跃统计'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/gmall/ads/ads_user_stats/';

-- 11.2.4 用户行为漏斗分析
CREATE TABLE IF NOT EXISTS ads_user_action (
    dt                STRING COMMENT '统计日期',
    home_count        BIGINT COMMENT '浏览首页人数',
    good_detail_count BIGINT COMMENT '浏览商品详情页人数',
    cart_count        BIGINT COMMENT '加购人数',
    order_count       BIGINT COMMENT '下单人数',
    payment_count     BIGINT COMMENT '支付人数'
) COMMENT '用户行为漏斗分析'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/gmall/ads/ads_user_action/';

-- 11.2.5 新增下单用户统计
CREATE TABLE IF NOT EXISTS ads_new_order_user_stats (
    dt                   STRING COMMENT '统计日期',
    recent_days          BIGINT COMMENT '最近天数,1:最近1天,7:最近7天,30:最近30天',
    new_order_user_count BIGINT COMMENT '新增下单人数'
) COMMENT '新增下单用户统计'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/gmall/ads/ads_new_order_user_stats/';

-- 11.2.6 最近7日内连续3日下单用户数
CREATE TABLE IF NOT EXISTS ads_order_continuously_user_count (
    dt                            STRING COMMENT '统计日期',
    recent_days                   BIGINT COMMENT '最近天数,7:最近7天',
    order_continuously_user_count BIGINT COMMENT '连续3日下单用户数'
) COMMENT '最近7日内连续3日下单用户数统计'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/gmall/ads/ads_order_continuously_user_count/';

-- ============================================================
-- 11.3 商品主题
-- ============================================================

-- 11.3.1 最近30日各品牌复购率
CREATE TABLE IF NOT EXISTS ads_repeat_purchase_by_tm (
    dt                STRING COMMENT '统计日期',
    recent_days       BIGINT COMMENT '最近天数,30:最近30天',
    tm_id             STRING COMMENT '品牌ID',
    tm_name           STRING COMMENT '品牌名称',
    order_repeat_rate DECIMAL(16, 2) COMMENT '复购率'
) COMMENT '最近30日各品牌复购率统计'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/gmall/ads/ads_repeat_purchase_by_tm/';

-- 11.3.2 各品牌商品下单统计
CREATE TABLE IF NOT EXISTS ads_order_stats_by_tm (
    dt               STRING COMMENT '统计日期',
    recent_days      BIGINT COMMENT '最近天数,1:最近1天,7:最近7天,30:最近30天',
    tm_id            STRING COMMENT '品牌ID',
    tm_name          STRING COMMENT '品牌名称',
    order_count      BIGINT COMMENT '下单数',
    order_user_count BIGINT COMMENT '下单人数'
) COMMENT '各品牌商品下单统计'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/gmall/ads/ads_order_stats_by_tm/';

-- 11.3.3 各品类商品下单统计
CREATE TABLE IF NOT EXISTS ads_order_stats_by_cate (
    dt               STRING COMMENT '统计日期',
    recent_days      BIGINT COMMENT '最近天数,1:最近1天,7:最近7天,30:最近30天',
    category1_id     STRING COMMENT '一级品类ID',
    category1_name   STRING COMMENT '一级品类名称',
    category2_id     STRING COMMENT '二级品类ID',
    category2_name   STRING COMMENT '二级品类名称',
    category3_id     STRING COMMENT '三级品类ID',
    category3_name   STRING COMMENT '三级品类名称',
    order_count      BIGINT COMMENT '下单数',
    order_user_count BIGINT COMMENT '下单人数'
) COMMENT '各品类商品下单统计'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/gmall/ads/ads_order_stats_by_cate/';

-- 11.3.4 各品类商品购物车存量Top3
CREATE TABLE IF NOT EXISTS ads_sku_cart_num_top3_by_cate (
    dt             STRING COMMENT '统计日期',
    category1_id   STRING COMMENT '一级品类ID',
    category1_name STRING COMMENT '一级品类名称',
    category2_id   STRING COMMENT '二级品类ID',
    category2_name STRING COMMENT '二级品类名称',
    category3_id   STRING COMMENT '三级品类ID',
    category3_name STRING COMMENT '三级品类名称',
    sku_id         STRING COMMENT 'SKU_ID',
    sku_name       STRING COMMENT 'SKU名称',
    cart_num       BIGINT COMMENT '购物车中商品数量',
    rk             BIGINT COMMENT '排名'
) COMMENT '各品类商品购物车存量Top3'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/gmall/ads/ads_sku_cart_num_top3_by_cate/';

-- 11.3.5 各品牌商品收藏次数Top3
CREATE TABLE IF NOT EXISTS ads_sku_favor_count_top3_by_tm (
    dt          STRING COMMENT '统计日期',
    tm_id       STRING COMMENT '品牌ID',
    tm_name     STRING COMMENT '品牌名称',
    sku_id      STRING COMMENT 'SKU_ID',
    sku_name    STRING COMMENT 'SKU名称',
    favor_count BIGINT COMMENT '被收藏次数',
    rk          BIGINT COMMENT '排名'
) COMMENT '各品牌商品收藏次数Top3'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/gmall/ads/ads_sku_favor_count_top3_by_tm/';

-- ============================================================
-- 11.4 交易主题
-- ============================================================

-- 11.4.1 下单到支付时间间隔平均值
CREATE TABLE IF NOT EXISTS ads_order_to_pay_interval_avg (
    dt                        STRING COMMENT '统计日期',
    order_to_pay_interval_avg BIGINT COMMENT '下单到支付时间间隔平均值,单位为秒'
) COMMENT '下单到支付时间间隔平均值统计'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/gmall/ads/ads_order_to_pay_interval_avg/';

-- 11.4.2 各省份交易统计
CREATE TABLE IF NOT EXISTS ads_order_by_province (
    dt                 STRING COMMENT '统计日期',
    recent_days        BIGINT COMMENT '最近天数,1:最近1天,7:最近7天,30:最近30天',
    province_id        STRING COMMENT '省份ID',
    province_name      STRING COMMENT '省份名称',
    area_code          STRING COMMENT '地区编码',
    iso_code           STRING COMMENT '旧版国际标准地区编码',
    iso_code_3166_2    STRING COMMENT '新版国际标准地区编码',
    order_count        BIGINT COMMENT '订单数',
    order_total_amount DECIMAL(16, 2) COMMENT '订单金额'
) COMMENT '各省份交易统计'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/gmall/ads/ads_order_by_province/';

-- ============================================================
-- 11.5 优惠券主题
-- ============================================================

-- 11.5.1 优惠券使用统计
CREATE TABLE IF NOT EXISTS ads_coupon_stats (
    dt              STRING COMMENT '统计日期',
    coupon_id       STRING COMMENT '优惠券ID',
    coupon_name     STRING COMMENT '优惠券名称',
    used_count      BIGINT COMMENT '使用次数',
    used_user_count BIGINT COMMENT '使用人数'
) COMMENT '优惠券使用统计'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/gmall/ads/ads_coupon_stats/';
