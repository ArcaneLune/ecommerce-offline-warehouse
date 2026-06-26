SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ========================================
-- gmall 电商数据库 — 29 张表
-- ========================================

DROP TABLE IF EXISTS `activity_info`;
CREATE TABLE `activity_info` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '活动id',
  `activity_name` varchar(200) DEFAULT NULL COMMENT '活动名称',
  `activity_type` varchar(10) DEFAULT NULL COMMENT '活动类型（1：满减，2：折扣）',
  `activity_desc` varchar(2000) DEFAULT NULL COMMENT '活动描述',
  `start_time` datetime DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '结束时间',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动表';

DROP TABLE IF EXISTS `activity_rule`;
CREATE TABLE `activity_rule` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '编号',
  `activity_id` int DEFAULT NULL COMMENT '活动id',
  `activity_type` varchar(20) DEFAULT NULL COMMENT '活动类型',
  `condition_amount` decimal(16,2) DEFAULT NULL COMMENT '满减金额',
  `condition_num` bigint DEFAULT NULL COMMENT '满减件数',
  `benefit_amount` decimal(16,2) DEFAULT NULL COMMENT '优惠金额',
  `benefit_discount` decimal(10,2) DEFAULT NULL COMMENT '优惠折扣',
  `benefit_level` bigint DEFAULT NULL COMMENT '优惠级别',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动规则表';

DROP TABLE IF EXISTS `base_category1`;
CREATE TABLE `base_category1` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '一级品类id',
  `name` varchar(10) NOT NULL COMMENT '一级品类名称',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='一级品类表';

DROP TABLE IF EXISTS `base_category2`;
CREATE TABLE `base_category2` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '二级品类id',
  `name` varchar(200) NOT NULL COMMENT '二级品类名称',
  `category1_id` bigint DEFAULT NULL COMMENT '一级品类id',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='二级品类表';

DROP TABLE IF EXISTS `base_category3`;
CREATE TABLE `base_category3` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '三级品类id',
  `name` varchar(200) NOT NULL COMMENT '三级品类名称',
  `category2_id` bigint DEFAULT NULL COMMENT '二级品类id',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='三级品类表';

DROP TABLE IF EXISTS `base_dic`;
CREATE TABLE `base_dic` (
  `dic_code` varchar(10) NOT NULL COMMENT '编号',
  `dic_name` varchar(100) DEFAULT NULL COMMENT '编码名称',
  `parent_code` varchar(10) DEFAULT NULL COMMENT '父编号',
  `parent_level` varchar(10) DEFAULT NULL COMMENT '父级别',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`dic_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='字典表';

DROP TABLE IF EXISTS `base_province`;
CREATE TABLE `base_province` (
  `id` bigint DEFAULT NULL COMMENT '省份id',
  `name` varchar(20) DEFAULT NULL COMMENT '省份名称',
  `region_id` varchar(20) DEFAULT NULL COMMENT '地区id',
  `area_code` varchar(20) DEFAULT NULL COMMENT '地区编码',
  `iso_code` varchar(20) DEFAULT NULL COMMENT 'iso编码',
  `iso_3166_2` varchar(20) DEFAULT NULL COMMENT 'iso3166_2编码',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='省份表';

DROP TABLE IF EXISTS `base_region`;
CREATE TABLE `base_region` (
  `id` varchar(20) DEFAULT NULL COMMENT '地区id',
  `region_name` varchar(20) DEFAULT NULL COMMENT '地区名称',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='地区表';

DROP TABLE IF EXISTS `base_trademark`;
CREATE TABLE `base_trademark` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '品牌id',
  `tm_name` varchar(100) DEFAULT NULL COMMENT '品牌名称',
  `logo_url` varchar(200) DEFAULT NULL COMMENT '品牌logo',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='品牌表';

DROP TABLE IF EXISTS `coupon_info`;
CREATE TABLE `coupon_info` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '购物券编号',
  `coupon_name` varchar(100) DEFAULT NULL COMMENT '购物券名称',
  `coupon_type` varchar(10) DEFAULT NULL COMMENT '购物券类型 1现金券 2折扣券 3满减券 4满件打折券',
  `condition_amount` decimal(10,2) DEFAULT NULL COMMENT '满额数',
  `condition_num` bigint DEFAULT NULL COMMENT '满件数',
  `activity_id` bigint DEFAULT NULL COMMENT '活动编号',
  `benefit_amount` decimal(16,2) DEFAULT NULL COMMENT '减免金额',
  `benefit_discount` decimal(10,2) DEFAULT NULL COMMENT '折扣',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `range_type` varchar(10) DEFAULT NULL COMMENT '范围类型 1商品(spuid) 2品类 3品牌',
  `limit_num` int NOT NULL DEFAULT 0 COMMENT '最多领用次数',
  `taken_count` int NOT NULL DEFAULT 0 COMMENT '已领用次数',
  `start_time` datetime DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '结束时间',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  `expire_time` datetime DEFAULT NULL COMMENT '过期时间',
  `range_desc` varchar(500) DEFAULT NULL COMMENT '范围描述',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='优惠券信息表';

DROP TABLE IF EXISTS `promotion_pos`;
CREATE TABLE `promotion_pos` (
  `id` bigint NOT NULL COMMENT '营销坑位id',
  `pos_location` varchar(200) DEFAULT NULL COMMENT '营销坑位位置',
  `pos_type` varchar(20) DEFAULT NULL COMMENT '营销坑位类型',
  `promotion_type` varchar(20) DEFAULT NULL COMMENT '营销类型',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='营销坑位表';

DROP TABLE IF EXISTS `promotion_refer`;
CREATE TABLE `promotion_refer` (
  `id` bigint NOT NULL COMMENT '外部营销渠道id',
  `refer_name` varchar(200) DEFAULT NULL COMMENT '外部营销渠道名称',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='营销渠道表';

DROP TABLE IF EXISTS `sku_attr_value`;
CREATE TABLE `sku_attr_value` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `attr_id` bigint DEFAULT NULL COMMENT '平台属性id',
  `value_id` bigint DEFAULT NULL COMMENT '平台属性值id',
  `sku_id` bigint DEFAULT NULL COMMENT 'skuid',
  `attr_name` varchar(30) DEFAULT NULL COMMENT '平台属性名称',
  `value_name` varchar(30) DEFAULT NULL COMMENT '平台属性值名称',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='sku平台属性值关联表';

DROP TABLE IF EXISTS `sku_sale_attr_value`;
CREATE TABLE `sku_sale_attr_value` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `sku_id` bigint DEFAULT NULL COMMENT 'skuid',
  `spu_id` bigint DEFAULT NULL COMMENT 'spuid',
  `sale_attr_value_id` bigint DEFAULT NULL COMMENT '销售属性值id',
  `sale_attr_value_name` varchar(30) DEFAULT NULL COMMENT '销售属性值名称',
  `sale_attr_id` bigint DEFAULT NULL COMMENT '销售属性id',
  `sale_attr_name` varchar(30) DEFAULT NULL COMMENT '销售属性名称',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='sku销售属性值关联表';

DROP TABLE IF EXISTS `sku_info`;
CREATE TABLE `sku_info` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'skuid',
  `spu_id` bigint DEFAULT NULL COMMENT 'spuid',
  `price` decimal(10,0) DEFAULT NULL COMMENT '价格',
  `sku_name` varchar(200) DEFAULT NULL COMMENT 'sku名称',
  `sku_desc` varchar(2000) DEFAULT NULL COMMENT '商品规格描述',
  `weight` decimal(10,2) DEFAULT NULL COMMENT '重量',
  `tm_id` bigint DEFAULT NULL COMMENT '品牌id',
  `category3_id` bigint DEFAULT NULL COMMENT '三级品类id',
  `sku_default_img` varchar(300) DEFAULT NULL COMMENT '图片地址',
  `is_sale` tinyint NOT NULL DEFAULT 0 COMMENT '是否在售（1是 0否）',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='sku表';

DROP TABLE IF EXISTS `spu_info`;
CREATE TABLE `spu_info` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'spuid',
  `spu_name` varchar(200) DEFAULT NULL COMMENT 'spu名称',
  `description` varchar(1000) DEFAULT NULL COMMENT '描述',
  `category3_id` bigint DEFAULT NULL COMMENT '三级品类id',
  `tm_id` bigint DEFAULT NULL COMMENT '品牌id',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='spu表';

DROP TABLE IF EXISTS `cart_info`;
CREATE TABLE `cart_info` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` varchar(200) DEFAULT NULL COMMENT '用户id',
  `sku_id` bigint DEFAULT NULL COMMENT 'skuid',
  `cart_price` decimal(10,2) DEFAULT NULL COMMENT '价格',
  `sku_num` int DEFAULT NULL COMMENT '数量',
  `img_url` varchar(200) DEFAULT NULL COMMENT '图片地址',
  `sku_name` varchar(200) DEFAULT NULL COMMENT 'sku名称',
  `is_checked` int DEFAULT NULL COMMENT '是否选中',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  `is_ordered` bigint DEFAULT NULL COMMENT '是否已下单',
  `order_time` datetime DEFAULT NULL COMMENT '下单时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='购物车表';

DROP TABLE IF EXISTS `comment_info`;
CREATE TABLE `comment_info` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint DEFAULT NULL COMMENT '用户id',
  `nick_name` varchar(20) DEFAULT NULL COMMENT '用户昵称',
  `head_img` varchar(200) DEFAULT NULL,
  `sku_id` bigint DEFAULT NULL COMMENT 'skuid',
  `spu_id` bigint DEFAULT NULL COMMENT 'spuid',
  `order_id` bigint DEFAULT NULL COMMENT '订单编号',
  `appraise` varchar(10) DEFAULT NULL COMMENT '评价 1好评 2中评 3差评',
  `comment_txt` varchar(2000) DEFAULT NULL COMMENT '评价内容',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品评论表';

DROP TABLE IF EXISTS `coupon_use`;
CREATE TABLE `coupon_use` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `coupon_id` bigint DEFAULT NULL COMMENT '购物券ID',
  `user_id` bigint DEFAULT NULL COMMENT '用户ID',
  `order_id` bigint DEFAULT NULL COMMENT '订单ID',
  `coupon_status` varchar(10) DEFAULT NULL COMMENT '购物券状态（1未使用 2已使用）',
  `get_time` datetime DEFAULT NULL COMMENT '获取时间',
  `using_time` datetime DEFAULT NULL COMMENT '使用时间',
  `used_time` datetime DEFAULT NULL COMMENT '支付时间',
  `expire_time` datetime DEFAULT NULL COMMENT '过期时间',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='优惠券领用表';

DROP TABLE IF EXISTS `favor_info`;
CREATE TABLE `favor_info` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint DEFAULT NULL COMMENT '用户id',
  `sku_id` bigint DEFAULT NULL COMMENT 'skuid',
  `spu_id` bigint DEFAULT NULL COMMENT 'spuid',
  `is_cancel` varchar(1) DEFAULT NULL COMMENT '是否已取消 0正常 1已取消',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品收藏表';

DROP TABLE IF EXISTS `order_detail`;
CREATE TABLE `order_detail` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `sku_id` bigint DEFAULT NULL COMMENT 'sku_id',
  `sku_name` varchar(200) DEFAULT NULL COMMENT 'sku名称',
  `img_url` varchar(200) DEFAULT NULL COMMENT '图片链接',
  `order_price` decimal(10,2) DEFAULT NULL COMMENT '购买价格',
  `sku_num` bigint DEFAULT NULL COMMENT '购买个数',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `split_total_amount` decimal(16,2) DEFAULT NULL,
  `split_activity_amount` decimal(16,2) DEFAULT NULL,
  `split_coupon_amount` decimal(16,2) DEFAULT NULL,
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单明细表';

DROP TABLE IF EXISTS `order_detail_activity`;
CREATE TABLE `order_detail_activity` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `order_detail_id` bigint DEFAULT NULL COMMENT '订单明细id',
  `activity_id` bigint DEFAULT NULL COMMENT '活动id',
  `activity_rule_id` bigint DEFAULT NULL COMMENT '活动规则id',
  `sku_id` bigint DEFAULT NULL COMMENT 'skuid',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单明细活动关联表';

DROP TABLE IF EXISTS `order_detail_coupon`;
CREATE TABLE `order_detail_coupon` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `order_detail_id` bigint DEFAULT NULL COMMENT '订单明细id',
  `coupon_id` bigint DEFAULT NULL COMMENT '购物券id',
  `coupon_use_id` bigint DEFAULT NULL COMMENT '购物券领用id',
  `sku_id` bigint DEFAULT NULL COMMENT 'skuid',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单明细优惠券关联表';

DROP TABLE IF EXISTS `order_info`;
CREATE TABLE `order_info` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `consignee` varchar(100) DEFAULT NULL COMMENT '收货人',
  `consignee_tel` varchar(20) DEFAULT NULL COMMENT '收件人电话',
  `total_amount` decimal(10,2) DEFAULT NULL COMMENT '总金额',
  `order_status` varchar(20) DEFAULT NULL COMMENT '订单状态',
  `user_id` bigint DEFAULT NULL COMMENT '用户id',
  `payment_way` varchar(20) DEFAULT NULL COMMENT '付款方式',
  `delivery_address` varchar(1000) DEFAULT NULL COMMENT '送货地址',
  `order_comment` varchar(200) DEFAULT NULL COMMENT '订单备注',
  `out_trade_no` varchar(50) DEFAULT NULL COMMENT '订单交易编号',
  `trade_body` varchar(200) DEFAULT NULL COMMENT '订单描述',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '操作时间',
  `expire_time` datetime DEFAULT NULL COMMENT '失效时间',
  `process_status` varchar(20) DEFAULT NULL COMMENT '进度状态',
  `tracking_no` varchar(100) DEFAULT NULL COMMENT '物流单编号',
  `parent_order_id` bigint DEFAULT NULL COMMENT '父订单编号',
  `img_url` varchar(200) DEFAULT NULL COMMENT '图片链接',
  `province_id` int DEFAULT NULL COMMENT '省份id',
  `activity_reduce_amount` decimal(16,2) DEFAULT NULL COMMENT '活动减免金额',
  `coupon_reduce_amount` decimal(16,2) DEFAULT NULL COMMENT '优惠券减免金额',
  `original_total_amount` decimal(16,2) DEFAULT NULL COMMENT '原始总金额',
  `feight_fee` decimal(16,2) DEFAULT NULL COMMENT '运费金额',
  `feight_fee_reduce` decimal(16,2) DEFAULT NULL COMMENT '运费减免金额',
  `refundable_time` datetime DEFAULT NULL COMMENT '可退款时间（签收后30天）',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';

DROP TABLE IF EXISTS `order_refund_info`;
CREATE TABLE `order_refund_info` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint DEFAULT NULL COMMENT '用户id',
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `sku_id` bigint DEFAULT NULL COMMENT 'skuid',
  `refund_type` varchar(20) DEFAULT NULL COMMENT '退款类型',
  `refund_num` bigint DEFAULT NULL COMMENT '退货件数',
  `refund_amount` decimal(16,2) DEFAULT NULL COMMENT '退款金额',
  `refund_reason_type` varchar(200) DEFAULT NULL COMMENT '原因类型',
  `refund_reason_txt` varchar(20) DEFAULT NULL COMMENT '原因内容',
  `refund_status` varchar(10) DEFAULT NULL COMMENT '退款状态（0待审批 1已退款）',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='退单表';

DROP TABLE IF EXISTS `order_status_log`;
CREATE TABLE `order_status_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `order_status` varchar(11) DEFAULT NULL COMMENT '订单状态',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单状态流水表';

DROP TABLE IF EXISTS `payment_info`;
CREATE TABLE `payment_info` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '编号',
  `out_trade_no` varchar(50) DEFAULT NULL COMMENT '对外业务编号',
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `user_id` bigint DEFAULT NULL COMMENT '用户id',
  `payment_type` varchar(20) DEFAULT NULL COMMENT '支付类型（微信 支付宝）',
  `trade_no` varchar(50) DEFAULT NULL COMMENT '交易编号',
  `total_amount` decimal(10,2) DEFAULT NULL COMMENT '支付金额',
  `subject` varchar(200) DEFAULT NULL COMMENT '交易内容',
  `payment_status` varchar(20) DEFAULT NULL COMMENT '支付状态',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `callback_time` datetime DEFAULT NULL COMMENT '回调时间',
  `callback_content` text COMMENT '回调信息',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='支付信息表';

DROP TABLE IF EXISTS `refund_payment`;
CREATE TABLE `refund_payment` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '编号',
  `out_trade_no` varchar(50) DEFAULT NULL COMMENT '对外业务编号',
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `sku_id` bigint DEFAULT NULL COMMENT 'skuid',
  `payment_type` varchar(20) DEFAULT NULL COMMENT '支付类型',
  `trade_no` varchar(50) DEFAULT NULL COMMENT '交易编号',
  `total_amount` decimal(10,2) DEFAULT NULL COMMENT '退款金额',
  `subject` varchar(200) DEFAULT NULL COMMENT '交易内容',
  `refund_status` varchar(30) DEFAULT NULL COMMENT '退款状态',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `callback_time` datetime DEFAULT NULL COMMENT '回调时间',
  `callback_content` text COMMENT '回调信息',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='退款支付表';

DROP TABLE IF EXISTS `user_info`;
CREATE TABLE `user_info` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `login_name` varchar(200) DEFAULT NULL COMMENT '用户名称',
  `nick_name` varchar(200) DEFAULT NULL COMMENT '用户昵称',
  `passwd` varchar(200) DEFAULT NULL COMMENT '用户密码',
  `name` varchar(200) DEFAULT NULL COMMENT '用户姓名',
  `phone_num` varchar(200) DEFAULT NULL COMMENT '手机号',
  `email` varchar(200) DEFAULT NULL COMMENT '邮箱',
  `head_img` varchar(200) DEFAULT NULL COMMENT '头像',
  `user_level` varchar(200) DEFAULT NULL COMMENT '用户级别',
  `birthday` varchar(200) DEFAULT NULL COMMENT '用户生日',
  `gender` varchar(1) DEFAULT NULL COMMENT '性别 M男 F女',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';
