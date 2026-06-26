-- ============================================================
-- DIM 层每日装载（7 张全量表 + 用户拉链）
-- 执行：hive --hivevar dt=YYYY-mm-dd --hivevar yesterday=YYYY-mm-dd减去1 -f dim_load_daily.sql
-- ============================================================

-- ############################################################
-- 1. 商品维度表
-- ############################################################

INSERT OVERWRITE TABLE dim_sku_full PARTITION (dt='${hivevar:dt}')
SELECT
    sku.id, sku.price, sku.sku_name, sku.sku_desc, sku.weight, sku.is_sale,
    sku.spu_id, NVL(spu.spu_name, ''),
    sku.category3_id, NVL(c3.category3_name, ''),
    c3.category2_id, NVL(c2.category2_name, ''),
    c2.category1_id, NVL(c1.category1_name, ''),
    sku.tm_id, NVL(tm.tm_name, ''),
    NVL(attr.sku_attr_values, ARRAY(NAMED_STRUCT('attr_id','','value_id','','attr_name','','value_name',''))),
    NVL(sale_attr.sku_sale_attr_values, ARRAY(NAMED_STRUCT('sale_attr_id','','sale_attr_value_id','','sale_attr_name','','sale_attr_value_name',''))),
    sku.create_time
FROM
    (SELECT id, price, sku_name, sku_desc, weight, is_sale, spu_id, category3_id, tm_id, create_time
     FROM ods_sku_info_full WHERE dt = '${hivevar:dt}') sku
LEFT JOIN (SELECT id, spu_name FROM ods_spu_info_full WHERE dt = '${hivevar:dt}') spu ON sku.spu_id = spu.id
LEFT JOIN (SELECT id, name AS category3_name, category2_id FROM ods_base_category3_full WHERE dt = '${hivevar:dt}') c3 ON sku.category3_id = c3.id
LEFT JOIN (SELECT id, name AS category2_name, category1_id FROM ods_base_category2_full WHERE dt = '${hivevar:dt}') c2 ON c3.category2_id = c2.id
LEFT JOIN (SELECT id, name AS category1_name FROM ods_base_category1_full WHERE dt = '${hivevar:dt}') c1 ON c2.category1_id = c1.id
LEFT JOIN (SELECT id, tm_name FROM ods_base_trademark_full WHERE dt = '${hivevar:dt}') tm ON sku.tm_id = tm.id
LEFT JOIN (
    SELECT sku_id, COLLECT_SET(NAMED_STRUCT('attr_id',attr_id,'value_id',value_id,'attr_name',attr_name,'value_name',value_name)) AS sku_attr_values
    FROM ods_sku_attr_value_full WHERE dt = '${hivevar:dt}' GROUP BY sku_id
) attr ON sku.id = attr.sku_id
LEFT JOIN (
    SELECT sku_id, COLLECT_SET(NAMED_STRUCT('sale_attr_id',sale_attr_id,'sale_attr_value_id',sale_attr_value_id,'sale_attr_name',sale_attr_name,'sale_attr_value_name',sale_attr_value_name)) AS sku_sale_attr_values
    FROM ods_sku_sale_attr_value_full WHERE dt = '${hivevar:dt}' GROUP BY sku_id
) sale_attr ON sku.id = sale_attr.sku_id;

-- ############################################################
-- 2. 优惠券维度表
-- ############################################################

INSERT OVERWRITE TABLE dim_coupon_full PARTITION (dt='${hivevar:dt}')
SELECT
    c.id, c.coupon_name, c.coupon_type AS coupon_type_code, d1.dic_name AS coupon_type_name,
    c.condition_amount, c.condition_num, c.activity_id, c.benefit_amount, c.benefit_discount,
    CASE c.coupon_type
        WHEN '2001' THEN CONCAT('满', c.condition_amount, '元减', c.benefit_amount, '元')
        WHEN '2002' THEN CONCAT('满', c.condition_num, '件打', CAST(c.benefit_discount AS STRING), '折')
        WHEN '2003' THEN CONCAT('减', c.benefit_amount, '元')
    END AS benefit_rule,
    c.create_time, c.range_type AS range_type_code, d2.dic_name AS range_type_name,
    c.limit_num, c.taken_count, c.start_time, c.end_time, c.operate_time, c.expire_time
FROM (SELECT * FROM ods_coupon_info_full WHERE dt = '${hivevar:dt}') c
LEFT JOIN (SELECT dic_code, dic_name FROM ods_base_dic_full WHERE dt = '${hivevar:dt}') d1 ON c.coupon_type = d1.dic_code
LEFT JOIN (SELECT dic_code, dic_name FROM ods_base_dic_full WHERE dt = '${hivevar:dt}') d2 ON c.range_type = d2.dic_code;

-- ############################################################
-- 3. 活动维度表
-- ############################################################

INSERT OVERWRITE TABLE dim_activity_full PARTITION (dt='${hivevar:dt}')
SELECT
    rule.id AS activity_rule_id, rule.activity_id, info.activity_name,
    info.activity_type AS activity_type_code, dic.dic_name AS activity_type_name,
    info.activity_desc, info.start_time, info.end_time, info.create_time,
    rule.condition_amount, rule.condition_num, rule.benefit_amount, rule.benefit_discount,
    CASE info.activity_type
        WHEN '3101' THEN CONCAT('满', rule.condition_amount, '元减', rule.benefit_amount, '元')
        WHEN '3102' THEN CONCAT('满', rule.condition_num, '件打', CAST(rule.benefit_discount AS STRING), '折')
        WHEN '3103' THEN CONCAT('减', rule.benefit_amount, '元')
    END AS benefit_rule,
    rule.benefit_level
FROM (SELECT * FROM ods_activity_rule_full WHERE dt = '${hivevar:dt}') rule
LEFT JOIN (SELECT id, activity_name, activity_type, activity_desc, start_time, end_time, create_time
           FROM ods_activity_info_full WHERE dt = '${hivevar:dt}') info ON rule.activity_id = info.id
LEFT JOIN (SELECT dic_code, dic_name FROM ods_base_dic_full WHERE dt = '${hivevar:dt}') dic ON info.activity_type = dic.dic_code;

-- ############################################################
-- 4. 地区维度表
-- ############################################################

INSERT OVERWRITE TABLE dim_province_full PARTITION (dt='${hivevar:dt}')
SELECT p.id, p.name AS province_name, p.area_code, p.iso_code, p.iso_3166_2, p.region_id, r.region_name
FROM (SELECT * FROM ods_base_province_full WHERE dt = '${hivevar:dt}') p
LEFT JOIN (SELECT id, region_name FROM ods_base_region_full WHERE dt = '${hivevar:dt}') r ON p.region_id = r.id;

-- ############################################################
-- 5. 营销坑位维度表
-- ############################################################

INSERT OVERWRITE TABLE dim_promotion_pos_full PARTITION (dt='${hivevar:dt}')
SELECT id, pos_location, pos_type, promotion_type, create_time, operate_time
FROM ods_promotion_pos_full WHERE dt = '${hivevar:dt}';

-- ############################################################
-- 6. 营销渠道维度表
-- ############################################################

INSERT OVERWRITE TABLE dim_promotion_refer_full PARTITION (dt='${hivevar:dt}')
SELECT id, refer_name, create_time, operate_time
FROM ods_promotion_refer_full WHERE dt = '${hivevar:dt}';

-- ############################################################
-- 7. 用户拉链表每日装载
-- ############################################################

set hive.exec.dynamic.partition.mode=nonstrict;

INSERT OVERWRITE TABLE dim_user_zip PARTITION (dt)
SELECT id, name, phone_num, email, user_level, birthday, gender,
       create_time, operate_time, start_date, end_date,
       IF(rn = 1, '9999-12-31', '${hivevar:yesterday}') AS dt
FROM (
    SELECT id, name, phone_num, email, user_level, birthday, gender,
           create_time, operate_time, start_date, end_date,
           ROW_NUMBER() OVER (PARTITION BY id ORDER BY start_date DESC) AS rn
    FROM (
        SELECT CAST(id AS STRING) AS id,
            CONCAT(SUBSTR(name, 1, 1), '*') AS name,
            CASE WHEN phone_num REGEXP '^[1][3-9][0-9]{9}$'
                 THEN CONCAT(SUBSTR(phone_num, 1, 3), '*****') ELSE NULL END AS phone_num,
            CASE WHEN email REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$'
                 THEN CONCAT('*****', SUBSTR(email, INSTR(email, '@'))) ELSE NULL END AS email,
            user_level, birthday, gender, create_time, operate_time,
            '${hivevar:dt}' AS start_date, '9999-12-31' AS end_date
        FROM ods_user_info_inc
        UNION ALL
        SELECT id, name, phone_num, email, user_level, birthday, gender,
               create_time, operate_time, start_date, end_date
        FROM dim_user_zip WHERE dt = '9999-12-31'
    ) t2
) t3;
