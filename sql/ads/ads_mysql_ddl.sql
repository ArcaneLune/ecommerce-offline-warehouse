-- ============================================================
-- ADS 报表导出 → MySQL gmall_report 数据库 DDL
-- ============================================================

CREATE DATABASE IF NOT EXISTS gmall_report DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
USE gmall_report;

-- 1. 各渠道流量统计
DROP TABLE IF EXISTS ads_traffic_stats_by_channel;
CREATE TABLE ads_traffic_stats_by_channel (
    dt               DATE NOT NULL COMMENT '统计日期',
    recent_days      BIGINT(20) NOT NULL COMMENT '最近天数,1:最近1天,7:最近7天,30:最近30天',
    channel          VARCHAR(16) NOT NULL COMMENT '渠道',
    uv_count         BIGINT(20) DEFAULT NULL COMMENT '访客人数',
    avg_duration_sec BIGINT(20) DEFAULT NULL COMMENT '会话平均停留时长，单位为秒',
    avg_page_count   BIGINT(20) DEFAULT NULL COMMENT '会话平均浏览页面数',
    sv_count         BIGINT(20) DEFAULT NULL COMMENT '会话数',
    bounce_rate      DECIMAL(16,2) DEFAULT NULL COMMENT '跳出率',
    PRIMARY KEY (dt, recent_days, channel)
) ENGINE=InnoDB CHARSET=utf8 COLLATE=utf8_general_ci COMMENT='各渠道流量统计' ROW_FORMAT=DYNAMIC;

-- 2. 路径分析
DROP TABLE IF EXISTS ads_page_path;
CREATE TABLE ads_page_path (
    dt         DATE NOT NULL COMMENT '统计日期',
    source     VARCHAR(64) NOT NULL COMMENT '跳转起始页面ID',
    target     VARCHAR(64) NOT NULL COMMENT '跳转终到页面ID',
    path_count BIGINT(20) DEFAULT NULL COMMENT '跳转次数',
    PRIMARY KEY (dt, source, target)
) ENGINE=InnoDB CHARSET=utf8 COLLATE=utf8_general_ci COMMENT='页面浏览路径分析' ROW_FORMAT=DYNAMIC;

-- 3. 用户变动统计（★ 修正：varchar→bigint）
DROP TABLE IF EXISTS ads_user_change;
CREATE TABLE ads_user_change (
    dt               DATE NOT NULL COMMENT '统计日期',
    user_churn_count BIGINT(20) DEFAULT NULL COMMENT '流失用户数',
    user_back_count  BIGINT(20) DEFAULT NULL COMMENT '回流用户数',
    PRIMARY KEY (dt)
) ENGINE=InnoDB CHARSET=utf8 COLLATE=utf8_general_ci COMMENT='用户变动统计' ROW_FORMAT=DYNAMIC;

-- 4. 用户留存率
DROP TABLE IF EXISTS ads_user_retention;
CREATE TABLE ads_user_retention (
    dt              DATE NOT NULL COMMENT '统计日期',
    create_date     VARCHAR(16) NOT NULL COMMENT '用户新增日期',
    retention_day   INT(20) NOT NULL COMMENT '截至当前日期留存天数',
    retention_count BIGINT(20) DEFAULT NULL COMMENT '留存用户数量',
    new_user_count  BIGINT(20) DEFAULT NULL COMMENT '新增用户数量',
    retention_rate  DECIMAL(16,2) DEFAULT NULL COMMENT '留存率',
    PRIMARY KEY (dt, create_date, retention_day)
) ENGINE=InnoDB CHARSET=utf8 COLLATE=utf8_general_ci COMMENT='用户留存率' ROW_FORMAT=DYNAMIC;

-- 5. 用户新增活跃统计
DROP TABLE IF EXISTS ads_user_stats;
CREATE TABLE ads_user_stats (
    dt                DATE NOT NULL COMMENT '统计日期',
    recent_days       BIGINT(20) NOT NULL COMMENT '最近n日,1:最近1日,7:最近7日,30:最近30日',
    new_user_count    BIGINT(20) DEFAULT NULL COMMENT '新增用户数',
    active_user_count BIGINT(20) DEFAULT NULL COMMENT '活跃用户数',
    PRIMARY KEY (dt, recent_days)
) ENGINE=InnoDB CHARSET=utf8 COLLATE=utf8_general_ci COMMENT='用户新增活跃统计' ROW_FORMAT=DYNAMIC;

-- 6. 用户行为漏斗分析
DROP TABLE IF EXISTS ads_user_action;
CREATE TABLE ads_user_action (
    dt                DATE NOT NULL COMMENT '统计日期',
    home_count        BIGINT(20) DEFAULT NULL COMMENT '浏览首页人数',
    good_detail_count BIGINT(20) DEFAULT NULL COMMENT '浏览商品详情页人数',
    cart_count        BIGINT(20) DEFAULT NULL COMMENT '加购人数',
    order_count       BIGINT(20) DEFAULT NULL COMMENT '下单人数',
    payment_count     BIGINT(20) DEFAULT NULL COMMENT '支付人数',
    PRIMARY KEY (dt)
) ENGINE=InnoDB CHARSET=utf8 COLLATE=utf8_general_ci COMMENT='用户行为漏斗分析' ROW_FORMAT=DYNAMIC;

-- 7. 新增下单用户统计
DROP TABLE IF EXISTS ads_new_order_user_stats;
CREATE TABLE ads_new_order_user_stats (
    dt                   DATE NOT NULL COMMENT '统计日期',
    recent_days          BIGINT(20) NOT NULL COMMENT '最近n日,1:最近1日,7:最近7日,30:最近30日',
    new_order_user_count BIGINT(20) DEFAULT NULL COMMENT '新增下单用户数',
    PRIMARY KEY (recent_days, dt)
) ENGINE=InnoDB CHARSET=utf8 COLLATE=utf8_general_ci COMMENT='新增下单用户统计' ROW_FORMAT=DYNAMIC;

-- 8. 最近7日内连续3日下单用户数
DROP TABLE IF EXISTS ads_order_continuously_user_count;
CREATE TABLE ads_order_continuously_user_count (
    dt                            DATE NOT NULL COMMENT '统计日期',
    recent_days                   BIGINT(20) NOT NULL COMMENT '最近天数,7:最近7天',
    order_continuously_user_count BIGINT(20) DEFAULT NULL COMMENT '连续3日下单用户数',
    PRIMARY KEY (dt, recent_days)
) ENGINE=InnoDB CHARSET=utf8 COLLATE=utf8_general_ci COMMENT='最近7日内连续3日下单用户数统计' ROW_FORMAT=DYNAMIC;

-- 9. 最近30日各品牌复购率
DROP TABLE IF EXISTS ads_repeat_purchase_by_tm;
CREATE TABLE ads_repeat_purchase_by_tm (
    dt                DATE NOT NULL COMMENT '统计日期',
    recent_days       BIGINT(20) NOT NULL COMMENT '最近天数,30:最近30天',
    tm_id             VARCHAR(16) NOT NULL COMMENT '品牌ID',
    tm_name           VARCHAR(32) DEFAULT NULL COMMENT '品牌名称',
    order_repeat_rate DECIMAL(16,2) DEFAULT NULL COMMENT '复购率',
    PRIMARY KEY (dt, recent_days, tm_id)
) ENGINE=InnoDB CHARSET=utf8 COLLATE=utf8_general_ci COMMENT='最近30日各品牌复购率统计' ROW_FORMAT=DYNAMIC;

-- 10. 各品牌商品下单统计
DROP TABLE IF EXISTS ads_order_stats_by_tm;
CREATE TABLE ads_order_stats_by_tm (
    dt               DATE NOT NULL COMMENT '统计日期',
    recent_days      BIGINT(20) NOT NULL COMMENT '最近天数,1:最近1天,7:最近7天,30:最近30天',
    tm_id            VARCHAR(16) NOT NULL COMMENT '品牌ID',
    tm_name          VARCHAR(32) DEFAULT NULL COMMENT '品牌名称',
    order_count      BIGINT(20) DEFAULT NULL COMMENT '下单数',
    order_user_count BIGINT(20) DEFAULT NULL COMMENT '下单人数',
    PRIMARY KEY (dt, recent_days, tm_id)
) ENGINE=InnoDB CHARSET=utf8 COLLATE=utf8_general_ci COMMENT='各品牌商品下单统计' ROW_FORMAT=DYNAMIC;

-- 11. 各品类商品下单统计
DROP TABLE IF EXISTS ads_order_stats_by_cate;
CREATE TABLE ads_order_stats_by_cate (
    dt             DATE NOT NULL COMMENT '统计日期',
    recent_days    BIGINT(20) NOT NULL COMMENT '最近天数',
    category1_id   VARCHAR(16) NOT NULL COMMENT '一级品类ID',
    category1_name VARCHAR(64) DEFAULT NULL COMMENT '一级品类名称',
    category2_id   VARCHAR(16) NOT NULL COMMENT '二级品类ID',
    category2_name VARCHAR(64) DEFAULT NULL COMMENT '二级品类名称',
    category3_id   VARCHAR(16) NOT NULL COMMENT '三级品类ID',
    category3_name VARCHAR(64) DEFAULT NULL COMMENT '三级品类名称',
    order_count    BIGINT(20) DEFAULT NULL COMMENT '下单数',
    order_user_count BIGINT(20) DEFAULT NULL COMMENT '下单人数',
    PRIMARY KEY (dt, recent_days, category1_id, category2_id, category3_id)
) ENGINE=InnoDB CHARSET=utf8 COLLATE=utf8_general_ci COMMENT='各品类商品下单统计' ROW_FORMAT=DYNAMIC;

-- 12. 各品类商品购物车存量Top3
DROP TABLE IF EXISTS ads_sku_cart_num_top3_by_cate;
CREATE TABLE ads_sku_cart_num_top3_by_cate (
    dt             DATE NOT NULL COMMENT '统计日期',
    category1_id   VARCHAR(16) NOT NULL COMMENT '一级品类ID',
    category1_name VARCHAR(64) DEFAULT NULL COMMENT '一级品类名称',
    category2_id   VARCHAR(16) NOT NULL COMMENT '二级品类ID',
    category2_name VARCHAR(64) DEFAULT NULL COMMENT '二级品类名称',
    category3_id   VARCHAR(16) NOT NULL COMMENT '三级品类ID',
    category3_name VARCHAR(64) DEFAULT NULL COMMENT '三级品类名称',
    sku_id         VARCHAR(16) NOT NULL COMMENT 'SKU_ID',
    sku_name       VARCHAR(128) DEFAULT NULL COMMENT 'SKU名称',
    cart_num       BIGINT(20) DEFAULT NULL COMMENT '购物车中商品数量',
    rk             BIGINT(20) DEFAULT NULL COMMENT '排名',
    PRIMARY KEY (dt, sku_id, category1_id, category2_id, category3_id)
) ENGINE=InnoDB CHARSET=utf8 COLLATE=utf8_general_ci COMMENT='各品类商品购物车存量Top3' ROW_FORMAT=DYNAMIC;

-- 13. 各品牌商品收藏次数Top3
DROP TABLE IF EXISTS ads_sku_favor_count_top3_by_tm;
CREATE TABLE ads_sku_favor_count_top3_by_tm (
    dt          DATE NOT NULL COMMENT '统计日期',
    tm_id       VARCHAR(20) NOT NULL COMMENT '品牌ID',
    tm_name     VARCHAR(128) DEFAULT NULL COMMENT '品牌名称',
    sku_id      VARCHAR(20) NOT NULL COMMENT 'SKU_ID',
    sku_name    VARCHAR(128) DEFAULT NULL COMMENT 'SKU名称',
    favor_count BIGINT(20) DEFAULT NULL COMMENT '被收藏次数',
    rk          BIGINT(20) DEFAULT NULL COMMENT '排名',
    PRIMARY KEY (dt, tm_id, sku_id)
) ENGINE=InnoDB CHARSET=utf8 COLLATE=utf8_general_ci COMMENT='各品牌商品收藏次数Top3' ROW_FORMAT=DYNAMIC;

-- 14. 下单到支付时间间隔平均值
DROP TABLE IF EXISTS ads_order_to_pay_interval_avg;
CREATE TABLE ads_order_to_pay_interval_avg (
    dt                        DATE NOT NULL COMMENT '统计日期',
    order_to_pay_interval_avg BIGINT(20) DEFAULT NULL COMMENT '下单到支付时间间隔平均值',
    PRIMARY KEY (dt)
) ENGINE=InnoDB CHARSET=utf8 COLLATE=utf8_general_ci COMMENT='下单到支付时间间隔平均值统计' ROW_FORMAT=DYNAMIC;

-- 15. 各省份交易统计
DROP TABLE IF EXISTS ads_order_by_province;
CREATE TABLE ads_order_by_province (
    dt                 DATE NOT NULL COMMENT '统计日期',
    recent_days        BIGINT(20) NOT NULL COMMENT '最近天数',
    province_id        VARCHAR(16) NOT NULL COMMENT '省份ID',
    province_name      VARCHAR(16) DEFAULT NULL COMMENT '省份名称',
    area_code          VARCHAR(16) DEFAULT NULL COMMENT '地区编码',
    iso_code           VARCHAR(16) DEFAULT NULL COMMENT '旧版国际标准地区编码',
    iso_code_3166_2    VARCHAR(16) DEFAULT NULL COMMENT '新版国际标准地区编码',
    order_count        BIGINT(20) DEFAULT NULL COMMENT '订单数',
    order_total_amount DECIMAL(16,2) DEFAULT NULL COMMENT '订单金额',
    PRIMARY KEY (dt, recent_days, province_id)
) ENGINE=InnoDB CHARSET=utf8 COLLATE=utf8_general_ci COMMENT='各省份交易统计' ROW_FORMAT=DYNAMIC;

-- 16. 优惠券使用统计
DROP TABLE IF EXISTS ads_coupon_stats;
CREATE TABLE ads_coupon_stats (
    dt              DATE NOT NULL COMMENT '统计日期',
    coupon_id       VARCHAR(20) NOT NULL COMMENT '优惠券ID',
    coupon_name     VARCHAR(128) NOT NULL COMMENT '优惠券名称',
    used_count      BIGINT(20) DEFAULT NULL COMMENT '使用次数',
    used_user_count BIGINT(20) DEFAULT NULL COMMENT '使用人数',
    PRIMARY KEY (dt, coupon_id)
) ENGINE=InnoDB CHARSET=utf8 COLLATE=utf8_general_ci COMMENT='优惠券使用统计' ROW_FORMAT=DYNAMIC;
