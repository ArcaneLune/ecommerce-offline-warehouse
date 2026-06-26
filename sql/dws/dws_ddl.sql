-- ============================================================
-- DWS 层建表 DDL（12 张）
-- 执行：hive -f /opt/software/dws_ddl.sql
-- ============================================================

-- ============================================================
-- 交易域
-- ============================================================

-- 10.1.1 交易域用户商品粒度订单最近1日汇总表
CREATE TABLE IF NOT EXISTS dws_trade_user_sku_order_1d (
    user_id                   STRING COMMENT '用户ID',
    sku_id                    STRING COMMENT 'SKU_ID',
    sku_name                  STRING COMMENT 'SKU名称',
    category1_id              STRING COMMENT '一级品类ID',
    category1_name            STRING COMMENT '一级品类名称',
    category2_id              STRING COMMENT '二级品类ID',
    category2_name            STRING COMMENT '二级品类名称',
    category3_id              STRING COMMENT '三级品类ID',
    category3_name            STRING COMMENT '三级品类名称',
    tm_id                     STRING COMMENT '品牌ID',
    tm_name                   STRING COMMENT '品牌名称',
    order_count_1d            BIGINT COMMENT '最近1日下单次数',
    order_num_1d              BIGINT COMMENT '最近1日下单商品件数',
    order_original_amount_1d  DECIMAL(16, 2) COMMENT '最近1日下单原始金额',
    activity_reduce_amount_1d DECIMAL(16, 2) COMMENT '最近1日活动优惠金额',
    coupon_reduce_amount_1d   DECIMAL(16, 2) COMMENT '最近1日优惠券优惠金额',
    order_total_amount_1d     DECIMAL(16, 2) COMMENT '最近1日下单最终金额'
) COMMENT '交易域用户商品粒度订单最近1日汇总事实表'
PARTITIONED BY (dt STRING)
STORED AS ORC
LOCATION '/warehouse/gmall/dws/dws_trade_user_sku_order_1d/'
TBLPROPERTIES ('orc.compress'='snappy');

-- 10.1.2 交易域用户粒度订单最近1日汇总表
CREATE TABLE IF NOT EXISTS dws_trade_user_order_1d (
    user_id                   STRING COMMENT '用户ID',
    order_count_1d            BIGINT COMMENT '最近1日下单次数',
    order_num_1d              BIGINT COMMENT '最近1日下单商品件数',
    order_original_amount_1d  DECIMAL(16, 2) COMMENT '最近1日下单原始金额',
    activity_reduce_amount_1d DECIMAL(16, 2) COMMENT '最近1日活动优惠金额',
    coupon_reduce_amount_1d   DECIMAL(16, 2) COMMENT '最近1日优惠券优惠金额',
    order_total_amount_1d     DECIMAL(16, 2) COMMENT '最近1日下单最终金额'
) COMMENT '交易域用户粒度订单最近1日汇总事实表'
PARTITIONED BY (dt STRING)
STORED AS ORC
LOCATION '/warehouse/gmall/dws/dws_trade_user_order_1d/'
TBLPROPERTIES ('orc.compress'='snappy');

-- 10.1.3 交易域用户粒度加购最近1日汇总表
CREATE TABLE IF NOT EXISTS dws_trade_user_cart_add_1d (
    user_id           STRING COMMENT '用户ID',
    cart_add_count_1d BIGINT COMMENT '最近1日加购次数',
    cart_add_num_1d   BIGINT COMMENT '最近1日加购商品件数'
) COMMENT '交易域用户粒度加购最近1日汇总事实表'
PARTITIONED BY (dt STRING)
STORED AS ORC
LOCATION '/warehouse/gmall/dws/dws_trade_user_cart_add_1d/'
TBLPROPERTIES ('orc.compress'='snappy');

-- 10.1.4 交易域用户粒度支付最近1日汇总表
CREATE TABLE IF NOT EXISTS dws_trade_user_payment_1d (
    user_id            STRING COMMENT '用户ID',
    payment_count_1d   BIGINT COMMENT '最近1日支付次数',
    payment_num_1d     BIGINT COMMENT '最近1日支付商品件数',
    payment_amount_1d  DECIMAL(16, 2) COMMENT '最近1日支付金额'
) COMMENT '交易域用户粒度支付最近1日汇总事实表'
PARTITIONED BY (dt STRING)
STORED AS ORC
LOCATION '/warehouse/gmall/dws/dws_trade_user_payment_1d/'
TBLPROPERTIES ('orc.compress'='snappy');

-- 10.1.5 交易域省份粒度订单最近1日汇总表
CREATE TABLE IF NOT EXISTS dws_trade_province_order_1d (
    province_id                STRING COMMENT '省份ID',
    province_name              STRING COMMENT '省份名称',
    area_code                  STRING COMMENT '地区编码',
    iso_code                   STRING COMMENT '旧版ISO编码',
    iso_3166_2                 STRING COMMENT '新版ISO编码',
    region_id                  STRING COMMENT '地区ID',
    region_name                STRING COMMENT '地区名称',
    order_count_1d             BIGINT COMMENT '最近1日下单次数',
    order_num_1d               BIGINT COMMENT '最近1日下单商品件数',
    order_original_amount_1d   DECIMAL(16, 2) COMMENT '最近1日下单原始金额',
    activity_reduce_amount_1d  DECIMAL(16, 2) COMMENT '最近1日活动优惠金额',
    coupon_reduce_amount_1d    DECIMAL(16, 2) COMMENT '最近1日优惠券优惠金额',
    order_total_amount_1d      DECIMAL(16, 2) COMMENT '最近1日下单最终金额'
) COMMENT '交易域省份粒度订单最近1日汇总事实表'
PARTITIONED BY (dt STRING)
STORED AS ORC
LOCATION '/warehouse/gmall/dws/dws_trade_province_order_1d/'
TBLPROPERTIES ('orc.compress'='snappy');

-- ============================================================
-- 流量域
-- ============================================================

-- 10.1.6 流量域会话粒度页面浏览最近1日汇总表
CREATE TABLE IF NOT EXISTS dws_traffic_session_page_view_1d (
    session_id        STRING COMMENT '会话ID',
    mid_id            STRING COMMENT '设备ID',
    brand             STRING COMMENT '手机品牌',
    model             STRING COMMENT '手机型号',
    operate_system    STRING COMMENT '操作系统',
    version_code      STRING COMMENT 'APP版本号',
    channel           STRING COMMENT '渠道',
    during_time_1d    BIGINT COMMENT '最近1日访问时长',
    page_count_1d     BIGINT COMMENT '最近1日访问页面数'
) COMMENT '流量域会话粒度页面浏览最近1日汇总事实表'
PARTITIONED BY (dt STRING)
STORED AS ORC
LOCATION '/warehouse/gmall/dws/dws_traffic_session_page_view_1d/'
TBLPROPERTIES ('orc.compress'='snappy');

-- 10.1.7 流量域访客页面粒度页面浏览最近1日汇总表
CREATE TABLE IF NOT EXISTS dws_traffic_page_visitor_page_view_1d (
    mid_id            STRING COMMENT '设备ID',
    brand             STRING COMMENT '手机品牌',
    model             STRING COMMENT '手机型号',
    operate_system    STRING COMMENT '操作系统',
    page_id           STRING COMMENT '页面ID',
    during_time_1d    BIGINT COMMENT '最近1日浏览时长',
    view_count_1d     BIGINT COMMENT '最近1日访问次数'
) COMMENT '流量域访客页面粒度页面浏览最近1日汇总事实表'
PARTITIONED BY (dt STRING)
STORED AS ORC
LOCATION '/warehouse/gmall/dws/dws_traffic_page_visitor_page_view_1d/'
TBLPROPERTIES ('orc.compress'='snappy');

-- ============================================================
-- 工具域
-- ============================================================

-- 10.1.8 工具域优惠券使用最近1日汇总表
CREATE TABLE IF NOT EXISTS dws_tool_coupon_used_1d (
    coupon_id        STRING COMMENT '优惠券ID',
    coupon_name      STRING COMMENT '优惠券名称',
    coupon_type      STRING COMMENT '优惠券类型',
    benefit_amount   DECIMAL(16, 2) COMMENT '优惠金额',
    used_count_1d    BIGINT COMMENT '最近1日使用次数'
) COMMENT '工具域优惠券使用最近1日汇总事实表'
PARTITIONED BY (dt STRING)
STORED AS ORC
LOCATION '/warehouse/gmall/dws/dws_tool_coupon_used_1d/'
TBLPROPERTIES ('orc.compress'='snappy');

-- ============================================================
-- 互动域
-- ============================================================

-- 10.1.9 互动域商品收藏最近1日汇总表
CREATE TABLE IF NOT EXISTS dws_interaction_sku_favor_add_1d (
    sku_id             STRING COMMENT 'SKU_ID',
    sku_name           STRING COMMENT 'SKU名称',
    favor_add_count_1d BIGINT COMMENT '最近1日收藏次数'
) COMMENT '互动域商品收藏最近1日汇总事实表'
PARTITIONED BY (dt STRING)
STORED AS ORC
LOCATION '/warehouse/gmall/dws/dws_interaction_sku_favor_add_1d/'
TBLPROPERTIES ('orc.compress'='snappy');

-- ============================================================
-- N日汇总表（基于1日表聚合）
-- ============================================================

-- 10.2.1 交易域用户商品粒度订单最近N日汇总表
CREATE TABLE IF NOT EXISTS dws_trade_user_sku_order_nd (
    user_id                      STRING COMMENT '用户ID',
    sku_id                       STRING COMMENT 'SKU_ID',
    sku_name                     STRING COMMENT 'SKU名称',
    category1_id                 STRING COMMENT '一级品类ID',
    category1_name               STRING COMMENT '一级品类名称',
    category2_id                 STRING COMMENT '二级品类ID',
    category2_name               STRING COMMENT '二级品类名称',
    category3_id                 STRING COMMENT '三级品类ID',
    category3_name               STRING COMMENT '三级品类名称',
    tm_id                        STRING COMMENT '品牌ID',
    tm_name                      STRING COMMENT '品牌名称',
    order_count_7d               BIGINT COMMENT '最近7日下单次数',
    order_num_7d                 BIGINT COMMENT '最近7日下单商品件数',
    order_original_amount_7d     DECIMAL(16, 2) COMMENT '最近7日下单原始金额',
    activity_reduce_amount_7d    DECIMAL(16, 2) COMMENT '最近7日活动优惠金额',
    coupon_reduce_amount_7d      DECIMAL(16, 2) COMMENT '最近7日优惠券优惠金额',
    order_total_amount_7d        DECIMAL(16, 2) COMMENT '最近7日下单最终金额',
    order_count_30d              BIGINT COMMENT '最近30日下单次数',
    order_num_30d                BIGINT COMMENT '最近30日下单商品件数',
    order_original_amount_30d    DECIMAL(16, 2) COMMENT '最近30日下单原始金额',
    activity_reduce_amount_30d   DECIMAL(16, 2) COMMENT '最近30日活动优惠金额',
    coupon_reduce_amount_30d     DECIMAL(16, 2) COMMENT '最近30日优惠券优惠金额',
    order_total_amount_30d       DECIMAL(16, 2) COMMENT '最近30日下单最终金额'
) COMMENT '交易域用户商品粒度订单最近N日汇总事实表'
PARTITIONED BY (dt STRING)
STORED AS ORC
LOCATION '/warehouse/gmall/dws/dws_trade_user_sku_order_nd/'
TBLPROPERTIES ('orc.compress'='snappy');

-- ============================================================
-- 历史至今汇总表（TD = To Date）
-- ============================================================

-- 10.3.1 交易域用户粒度订单历史至今汇总表
CREATE TABLE IF NOT EXISTS dws_trade_user_order_td (
    user_id                    STRING COMMENT '用户ID',
    order_date_first           STRING COMMENT '首次下单日期',
    order_date_last            STRING COMMENT '末次下单日期',
    order_count_td             BIGINT COMMENT '历史至今下单次数',
    order_num_td               BIGINT COMMENT '历史至今下单商品件数',
    order_original_amount_td   DECIMAL(16, 2) COMMENT '历史至今下单原始金额',
    activity_reduce_amount_td  DECIMAL(16, 2) COMMENT '历史至今活动优惠金额',
    coupon_reduce_amount_td    DECIMAL(16, 2) COMMENT '历史至今优惠券优惠金额',
    order_total_amount_td      DECIMAL(16, 2) COMMENT '历史至今下单最终金额'
) COMMENT '交易域用户粒度订单历史至今汇总事实表'
PARTITIONED BY (dt STRING)
STORED AS ORC
LOCATION '/warehouse/gmall/dws/dws_trade_user_order_td/'
TBLPROPERTIES ('orc.compress'='snappy');

-- 10.3.2 用户域用户粒度登录历史至今汇总表
CREATE TABLE IF NOT EXISTS dws_user_user_login_td (
    user_id          STRING COMMENT '用户ID',
    login_date_first STRING COMMENT '首次登录日期',
    login_date_last  STRING COMMENT '末次登录日期',
    login_count_td   BIGINT COMMENT '历史至今登录次数'
) COMMENT '用户域用户粒度登录历史至今汇总事实表'
PARTITIONED BY (dt STRING)
STORED AS ORC
LOCATION '/warehouse/gmall/dws/dws_user_user_login_td/'
TBLPROPERTIES ('orc.compress'='snappy');
