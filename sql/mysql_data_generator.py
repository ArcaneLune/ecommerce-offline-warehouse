#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
电商业务数据模拟生成器 —-> MySQL
输出：向 MySQL的gmall数据库的29 张表写入符合真实电商业务逻辑的模拟数据

用法：
  初始化数据：python3 mysql_data_generator.py --mode init --host hadoop101 --lines 50000
  每5秒生成50条：python3 mysql_data_generator.py --mode continuous --host hadoop101 --batch 50 --interval 5
"""

import pymysql
import random
import time
import uuid
from datetime import datetime, timedelta

# ============================================================
# 数据池 — 真实电商场景
# ============================================================
PROVINCES = [
    (1, "北京", "1", "110000"), (2, "上海", "1", "310000"),
    (3, "广东", "2", "440000"), (4, "浙江", "2", "330000"),
    (5, "江苏", "2", "320000"), (6, "四川", "3", "510000"),
    (7, "湖北", "3", "420000"), (8, "山东", "1", "370000"),
    (9, "福建", "2", "350000"),(10, "河南", "3", "410000"),
]

REGIONS = [("1", "华北"), ("2", "华东"), ("3", "华中"), ("4", "华南"), ("5", "西南"), ("6", "西北")]

CATEGORY1 = [(1, "电子产品"), (2, "服装鞋帽"), (3, "食品饮料"), (4, "家居用品"), (5, "图书音像"), (6, "个护美妆")]
CATEGORY2 = [
    (1, "手机通讯", 1), (2, "电脑办公", 1), (3, "家用电器", 1),
    (4, "男装", 2), (5, "女装", 2), (6, "运动户外", 2),
    (7, "休闲食品", 3), (8, "饮料冲调", 3), (9, "生鲜水果", 3),
    (10, "家纺", 4), (11, "厨房用品", 4), (12, "家具", 4),
    (13, "小说", 5), (14, "教育", 5), (15, "杂志", 5),
    (16, "面部护理", 6), (17, "彩妆", 6), (18, "洗发护发", 6),
]
CATEGORY3 = []
for c2 in CATEGORY2:
    for i in range(1, random.randint(2, 4) + 1):
        names = {
            1: ["智能手机", "功能手机", "手机配件"],
            2: ["笔记本电脑", "台式电脑", "平板电脑"],
            3: ["冰箱", "洗衣机", "空调", "微波炉"],
            4: ["衬衫", "夹克", "裤子", "T恤"],
            5: ["连衣裙", "半身裙", "针织衫", "外套"],
            6: ["运动鞋", "跑步装备", "户外帐篷"],
            7: ["薯片", "坚果", "饼干", "糖果"],
            8: ["咖啡", "茶叶", "果汁", "矿泉水"],
            9: ["水果", "海鲜", "肉类", "蔬菜"],
            10: ["被子", "枕头", "四件套"],
            11: ["锅具", "刀具", "餐具"],
            12: ["沙发", "床", "桌椅", "衣柜"],
            13: ["科幻", "言情", "悬疑", "武侠"],
            14: ["教材", "考试", "外语"],
            15: ["时尚", "科技", "财经"],
            16: ["面霜", "精华", "面膜", "爽肤水"],
            17: ["口红", "粉底", "眼影", "腮红"],
            18: ["洗发水", "护发素", "沐浴露"],
        }
        c3_names = names.get(c2[0], ["其它"])
        n = min(len(c3_names), i)
        cid = len(CATEGORY3) + 1
        CATEGORY3.append((cid, c3_names[n-1], c2[0]))

TRADEMARKS = {
    1: ("华为", 1), 2: ("小米", 1), 3: ("Apple", 1), 4: ("三星", 1),
    5: ("耐克", 2), 6: ("阿迪达斯", 2), 7: ("优衣库", 2), 8: ("ZARA", 2),
    9: ("良品铺子", 3), 10: ("三只松鼠", 3), 11: ("蒙牛", 3), 12: ("伊利", 3),
    13: ("宜家", 4), 14: ("无印良品", 4), 15: ("苏泊尔", 4), 16: ("九阳", 4),
}

DIC = [
    ("10", "订单状态", None, None),
    ("1001", "待支付", "10", "1"),
    ("1002", "已支付", "10", "1"),
    ("1003", "已发货", "10", "1"),
    ("1004", "已完成", "10", "1"),
    ("1005", "已取消", "10", "1"),
    ("11", "支付方式", None, None),
    ("1101", "微信", "11", "1"),
    ("1102", "支付宝", "11", "1"),
    ("12", "退款状态", None, None),
    ("1201", "待审批", "12", "1"),
    ("1202", "已退款", "12", "1"),
    ("13", "优惠券类型", None, None),
    ("1301", "满减券", "13", "1"),
    ("1302", "折扣券", "13", "1"),
]

PROMOTION_POS = [
    (1, "首页banner", "banner", "满减"),
    (2, "首页推荐位", "recommend", "满减"),
    (3, "分类页顶部", "banner", "折扣"),
    (4, "搜索结果顶部", "recommend", "折扣"),
    (5, "购物车推荐", "recommend", "满减"),
]

PROMOTION_REFER = [
    (1, "微信朋友圈"), (2, "抖音"), (3, "百度搜索"),
    (4, "小红书"), (5, "今日头条"), (6, "微博"),
]

PAYMENT_WAYS = ["微信", "支付宝"]
ORDER_STATUSES = ["1001", "1002", "1003", "1004", "1005"]

ACTIVITY_TYPES = ["满减", "折扣"]
ACTIVITY_NAMES = [
    "618年中大促", "双11狂欢节", "元旦特惠", "春季上新",
    "会员日", "品牌日", "限时秒杀", "新用户专享", "周末特惠",
]

ACTIVITY_RULES = [
    (100, 20, None, 0),    # 满100减20
    (200, 50, None, 0),    # 满200减50
    (500, 150, None, 0),   # 满500减150
    (0, 0, 8.5, 0),        # 8.5折
    (0, 0, 7.0, 0),        # 7折
]

FIRST_NAMES = ["张", "李", "王", "刘", "陈", "杨", "赵", "黄", "周", "吴", "徐", "孙", "马", "朱", "胡", "郭", "林", "何", "高", "罗"]
LAST_NAMES = ["伟", "芳", "娜", "敏", "静", "丽", "强", "磊", "军", "洋", "勇", "艳", "杰", "涛", "明", "超", "秀英", "华", "慧", "鑫"]

GENDERS = ["M", "F"]
USER_LEVELS = ["普通会员", "银卡会员", "金卡会员", "钻石会员"]

ADDRESSES = [
    ("北京市朝阳区xxx路%d号", 1), ("上海市浦东新区xxx路%d号", 2),
    ("广州市天河区xxx路%d号", 3), ("杭州市西湖区xxx路%d号", 4),
    ("南京市鼓楼区xxx路%d号", 5), ("成都市锦江区xxx路%d号", 6),
]

# ============================================================
# 工具函数
# ============================================================
def now():
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

def random_date(days_back=365):
    d = datetime.now() - timedelta(days=random.randint(0, days_back), hours=random.randint(0, 23))
    return d.strftime("%Y-%m-%d %H:%M:%S")

def random_phone():
    prefixes = ["138", "139", "150", "151", "152", "186", "187", "188", "176", "135"]
    return random.choice(prefixes) + "".join(str(random.randint(0, 9)) for _ in range(8))

def random_email(login_name):
    domains = ["qq.com", "163.com", "gmail.com", "126.com", "outlook.com"]
    return login_name + "@" + random.choice(domains)

def random_user():
    f = random.choice(FIRST_NAMES)
    l = random.choice(LAST_NAMES)
    login = "user_" + str(uuid.uuid4())[:8]
    gender = random.choice(GENDERS)
    return {
        "login_name": login,
        "nick_name": f + l,
        "passwd": "e10adc3949ba59abbe56e057f20f883e",  # 123456 md5
        "name": f + l,
        "phone_num": random_phone(),
        "email": random_email(login),
        "head_img": "",
        "user_level": random.choices(USER_LEVELS, weights=[50, 30, 15, 5])[0],
        "birthday": "199%d-%02d-%02d" % (random.randint(0, 9), random.randint(1, 12), random.randint(1, 28)),
        "gender": gender,
    }

# ============================================================
# 数据库操作
# ============================================================
class GmallDB:
    def __init__(self, host, port=3306, user="root", password="root", database="gmall"):
        self.conn = pymysql.connect(host=host, port=port, user=user, password=password,
                                     database=database, charset="utf8mb4")
        self.cursor = self.conn.cursor()

    def exec(self, sql, args=None):
        self.cursor.execute(sql, args)

    def execmany(self, sql, args):
        self.cursor.executemany(sql, args)

    def commit(self):
        self.conn.commit()

    def last_id(self):
        return self.cursor.lastrowid

    def close(self):
        self.cursor.close()
        self.conn.close()

    def count(self, table):
        self.exec("SELECT count(*) FROM %s" % table)
        return self.cursor.fetchone()[0]

    def ids(self, table, limit=None):
        sql = "SELECT id FROM %s" % table
        if limit:
            sql += " ORDER BY RAND() LIMIT %d" % limit
        self.exec(sql)
        return [r[0] for r in self.cursor.fetchall()]

def init_static_data(db):
    """初始化静态维度数据"""
    print(">>> 初始化基础数据...")

    # 地区
    db.execmany("INSERT INTO base_region (id, region_name, create_time, operate_time) VALUES (%s,%s,%s,%s)",
                [(r[0], r[1], now(), now()) for r in REGIONS])
    db.commit()
    print("  base_region: %d" % len(REGIONS))

    # 省份
    db.execmany("INSERT INTO base_province (id, name, region_id, area_code, iso_code, create_time, operate_time) VALUES (%s,%s,%s,%s,%s,%s,%s)",
                [(p[0], p[1], p[2], p[3], "CN-" + p[3][:2], now(), now()) for p in PROVINCES])
    db.commit()
    print("  base_province: %d" % len(PROVINCES))

    # 品类
    db.execmany("INSERT INTO base_category1 (id, name, create_time, operate_time) VALUES (%s,%s,%s,%s)",
                [(c[0], c[1], now(), now()) for c in CATEGORY1])
    db.commit()
    db.execmany("INSERT INTO base_category2 (id, name, category1_id, create_time, operate_time) VALUES (%s,%s,%s,%s,%s)",
                [(c[0], c[1], c[2], now(), now()) for c in CATEGORY2])
    db.commit()
    db.execmany("INSERT INTO base_category3 (id, name, category2_id, create_time, operate_time) VALUES (%s,%s,%s,%s,%s)",
                [(c[0], c[1], c[2], now(), now()) for c in CATEGORY3])
    db.commit()
    print("  base_category: 1级%d / 2级%d / 3级%d" % (len(CATEGORY1), len(CATEGORY2), len(CATEGORY3)))

    # 品牌
    tm_data = [(k, v[0], "https://logo.example.com/%d.png" % k, now(), now()) for k, v in TRADEMARKS.items()]
    db.execmany("INSERT INTO base_trademark (id, tm_name, logo_url, create_time, operate_time) VALUES (%s,%s,%s,%s,%s)", tm_data)
    db.commit()
    print("  base_trademark: %d" % len(TRADEMARKS))

    # 字典
    db.execmany("INSERT INTO base_dic (dic_code, dic_name, parent_code, parent_level, create_time, operate_time) VALUES (%s,%s,%s,%s,%s,%s)",
                [(d[0], d[1], d[2], d[3], now(), now()) for d in DIC])
    db.commit()
    print("  base_dic: %d" % len(DIC))

    # 营销坑位 + 渠道
    db.execmany("INSERT INTO promotion_pos (id, pos_location, pos_type, promotion_type, create_time, operate_time) VALUES (%s,%s,%s,%s,%s,%s)",
                [(p[0], p[1], p[2], p[3], now(), now()) for p in PROMOTION_POS])
    db.commit()
    db.execmany("INSERT INTO promotion_refer (id, refer_name, create_time, operate_time) VALUES (%s,%s,%s,%s)",
                [(r[0], r[1], now(), now()) for r in PROMOTION_REFER])
    db.commit()
    print("  promotion: pos %d / refer %d" % (len(PROMOTION_POS), len(PROMOTION_REFER)))

    # 活动 + 规则
    activity_data = []
    for i in range(20):
        t = random.choice(ACTIVITY_TYPES)
        sd = random_date(90)
        ed = (datetime.strptime(sd, "%Y-%m-%d %H:%M:%S") + timedelta(days=random.randint(3, 30))).strftime("%Y-%m-%d %H:%M:%S")
        activity_data.append((random.choice(ACTIVITY_NAMES) + str(i+1), "1" if t == "满减" else "2", "这是第%d个活动" % (i+1), sd, ed, now(), now()))
    db.execmany("INSERT INTO activity_info (activity_name, activity_type, activity_desc, start_time, end_time, create_time, operate_time) VALUES (%s,%s,%s,%s,%s,%s,%s)", activity_data)
    db.commit()
    rule_data = []
    for i in range(40):
        r = random.choice(ACTIVITY_RULES)
        aid = random.randint(1, 20)
        is_discount = r[2] is not None
        rule_data.append((
            aid,
            "折扣" if is_discount else "满减",
            r[0],                                              # condition_amount
            0,                                                  # condition_num
            r[1] if not is_discount else 0,                     # benefit_amount
            r[2] if is_discount else 0,                         # benefit_discount
            random.randint(1, 3),                               # benefit_level
            now(), now()
        ))
    db.execmany("INSERT INTO activity_rule (activity_id, activity_type, condition_amount, condition_num, benefit_amount, benefit_discount, benefit_level, create_time, operate_time) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)", rule_data)
    db.commit()
    print("  activity: info %d / rule %d" % (20, 40))

    # 优惠券
    coupon_data = []
    for i in range(50):
        ct = str(random.randint(1, 4))
        sd = random_date(90)
        ed = (datetime.strptime(sd, "%Y-%m-%d %H:%M:%S") + timedelta(days=random.randint(7, 60))).strftime("%Y-%m-%d %H:%M:%S")
        coupon_data.append(("优惠券%d" % (i+1), ct, 100 if ct in ("1","3") else 0, 2 if ct == "4" else 0,
                            random.randint(1, 20), random.randint(5, 50) if ct in ("1","3") else 0,
                            random.randint(5, 9) if ct in ("2","4") else 0, now(),
                            str(random.choice([1, 2, 3])), random.randint(100, 5000), 0, sd, ed, now(), ed))
    db.execmany("INSERT INTO coupon_info (coupon_name, coupon_type, condition_amount, condition_num, activity_id, benefit_amount, benefit_discount, create_time, range_type, limit_num, taken_count, start_time, end_time, operate_time, expire_time) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)", coupon_data)
    db.commit()
    print("  coupon_info: %d" % 50)

    # 用户
    users = [random_user() for _ in range(2000)]
    db.execmany("INSERT INTO user_info (login_name, nick_name, passwd, name, phone_num, email, head_img, user_level, birthday, gender, create_time, operate_time) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",
                [(u["login_name"], u["nick_name"], u["passwd"], u["name"], u["phone_num"],
                  u["email"], u["head_img"], u["user_level"], u["birthday"], u["gender"],
                  random_date(365), now()) for u in users])
    db.commit()
    print("  user_info: %d" % 2000)

    # SPU + SKU
    spu_data = []
    for i in range(200):
        tm_data = random.choice(list(TRADEMARKS.items()))
        c3 = random.choice(CATEGORY3)
        spu_data.append(("SPU-%s-%s" % (tm_data[1][0], c3[1]), "高品质%s" % c3[1], c3[0], tm_data[0], now(), now()))
    db.execmany("INSERT INTO spu_info (spu_name, description, category3_id, tm_id, create_time, operate_time) VALUES (%s,%s,%s,%s,%s,%s)", spu_data)
    db.commit()
    spu_ids = db.ids("spu_info")
    print("  spu_info: %d" % len(spu_ids))

    sku_data = []
    sku_attr_data = []
    sku_sale_data = []
    for spu_id in spu_ids:
        for j in range(random.randint(1, 5)):
            price = random.randint(9, 9999) if random.random() > 0.05 else random.randint(1, 9)
            sku_name = "SKU-%d-%d" % (spu_id, j+1)
            sku_data.append((spu_id, price, sku_name, "规格描述", round(random.uniform(0.1, 10), 2),
                             random.choice(list(TRADEMARKS.keys())), random.choice(CATEGORY3)[0],
                             "", 1, now(), now()))
    db.execmany("INSERT INTO sku_info (spu_id, price, sku_name, sku_desc, weight, tm_id, category3_id, sku_default_img, is_sale, create_time, operate_time) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)", sku_data)
    db.commit()
    sku_ids = db.ids("sku_info")
    print("  sku_info: %d" % len(sku_ids))

    # SKU 平台属性
    for sku_id in sku_ids[:300]:
        for attr_name in ["颜色", "内存", "尺码"]:
            val = random.choice(["黑色", "白色", "红色", "蓝色"]) if attr_name == "颜色" else \
                  random.choice(["128G", "256G", "512G"]) if attr_name == "内存" else \
                  random.choice(["S", "M", "L", "XL"])
            sku_attr_data.append((random.randint(1, 5), random.randint(1, 10), sku_id, attr_name, val, now(), now()))
    db.execmany("INSERT INTO sku_attr_value (attr_id, value_id, sku_id, attr_name, value_name, create_time, operate_time) VALUES (%s,%s,%s,%s,%s,%s,%s)", sku_attr_data)
    db.commit()
    print("  sku_attr_value: %d" % len(sku_attr_data))

    # SKU 销售属性
    for sku_id in sku_ids[:300]:
        for sattr in [("颜色", "黑色"), ("颜色", "白色"), ("版本", "标准版"), ("版本", "高配版")]:
            sku_sale_data.append((sku_id, random.choice(spu_ids), random.randint(1, 10), sattr[1], random.randint(1, 5), sattr[0], now(), now()))
    db.execmany("INSERT INTO sku_sale_attr_value (sku_id, spu_id, sale_attr_value_id, sale_attr_value_name, sale_attr_id, sale_attr_name, create_time, operate_time) VALUES (%s,%s,%s,%s,%s,%s,%s,%s)", sku_sale_data)
    db.commit()
    print("  sku_sale_attr_value: %d" % len(sku_sale_data))

    print(">>> 静态数据初始化完成\n")

def generate_transactions(db, batch_size=50):
    """生成一批交易数据"""
    user_ids = db.ids("user_info")
    sku_ids = db.ids("sku_info")
    coupon_ids = db.ids("coupon_info")

    for _ in range(batch_size):
        try:
            uid = random.choice(user_ids)
            sku_id = random.choice(sku_ids)
            price = random.randint(10, 5000)
            qty = random.randint(1, 3)
            total = round(price * qty, 2)

            # 1. 购物车
            db.exec("""INSERT INTO cart_info (user_id, sku_id, cart_price, sku_num, img_url, sku_name, is_checked, create_time, operate_time, is_ordered, order_time)
                       VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                    (str(uid), sku_id, price, qty, "", "SKU-%d" % sku_id, 1, now(), now(), 0, None))

            # 2. 订单
            addr = random.choice(ADDRESSES)
            consignee = random.choice(FIRST_NAMES) + random.choice(LAST_NAMES)
            province_id = addr[1]
            order_time = now()
            freight = round(random.uniform(0, 15), 2)
            can_refund = (datetime.now() + timedelta(days=30)).strftime("%Y-%m-%d %H:%M:%S")

            db.exec("""INSERT INTO order_info (consignee, consignee_tel, total_amount, order_status, user_id, payment_way, delivery_address, order_comment, out_trade_no, trade_body, create_time, operate_time, expire_time, process_status, tracking_no, parent_order_id, img_url, province_id, activity_reduce_amount, coupon_reduce_amount, original_total_amount, feight_fee, feight_fee_reduce, refundable_time)
                       VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                    (consignee, random_phone(), total, "1002", uid, random.choice(PAYMENT_WAYS),
                     addr[0] % random.randint(1, 999), "请尽快发货", str(uuid.uuid4()).replace("-", "")[:32],
                     "电商订单", order_time, order_time, datetime.now() + timedelta(days=1), "已支付",
                     "SF" + str(random.randint(10000000000, 99999999999)), None, "", province_id,
                     0, 0, total, freight, 0, can_refund))
            order_id = db.last_id()

            # 3. 订单明细
            db.exec("""INSERT INTO order_detail (order_id, sku_id, sku_name, img_url, order_price, sku_num, create_time, split_total_amount, split_activity_amount, split_coupon_amount, operate_time)
                       VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                    (order_id, sku_id, "SKU-%d" % sku_id, "", price, qty, order_time, total, 0, 0, order_time))

            # 4. 订单状态流水
            db.exec("""INSERT INTO order_status_log (order_id, order_status, create_time, operate_time)
                       VALUES (%s,%s,%s,%s)""",
                    (order_id, "1002", order_time, order_time))

            # 5. 支付
            db.exec("""INSERT INTO payment_info (out_trade_no, order_id, user_id, payment_type, trade_no, total_amount, subject, payment_status, create_time, callback_time, callback_content, operate_time)
                       VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                    (str(uuid.uuid4()).replace("-", "")[:32], order_id, uid,
                     random.choice(PAYMENT_WAYS), str(uuid.uuid4()).replace("-", "")[:32],
                     total, "电商订单支付", "已支付", order_time, order_time, "{}", order_time))

            # 6. 评价（70%）
            if random.random() < 0.7:
                appraise = random.choices(["1", "2", "3"], weights=[60, 30, 10])[0]
                comments = ["质量很好，推荐购买", "不错，物流快", "还可以，性价比高", "一般般吧", "不太满意",
                            "价格实惠", "包装严实", "有点小瑕疵", "非常满意", "值得购买"]
                db.exec("""INSERT INTO comment_info (user_id, nick_name, head_img, sku_id, spu_id, order_id, appraise, comment_txt, create_time, operate_time)
                           VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                        (uid, "用户%d" % uid, "", sku_id, random.choice(db.ids("spu_info", 1)),
                         order_id, appraise, random.choice(comments), now(), now()))

            # 7. 收藏（30%）
            if random.random() < 0.3:
                db.exec("""INSERT INTO favor_info (user_id, sku_id, spu_id, is_cancel, create_time, operate_time)
                           VALUES (%s,%s,%s,%s,%s,%s)""",
                        (uid, sku_id, random.choice(db.ids("spu_info", 1)), "0", now(), now()))

            # 8. 优惠券使用（20%）
            if coupon_ids and random.random() < 0.2:
                cid = random.choice(coupon_ids)
                db.exec("""INSERT INTO coupon_use (coupon_id, user_id, order_id, coupon_status, get_time, using_time, used_time, expire_time, create_time, operate_time)
                           VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                        (cid, uid, order_id, "2", random_date(30), order_time, order_time,
                         datetime.now() + timedelta(days=30), random_date(30), now()))

            # 9. 退款（8%）
            if random.random() < 0.08:
                db.exec("""INSERT INTO order_refund_info (user_id, order_id, sku_id, refund_type, refund_num, refund_amount, refund_reason_type, refund_reason_txt, refund_status, create_time, operate_time)
                           VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                        (uid, order_id, sku_id, "退货退款", 1, total, "不喜欢", "七天无理由", "1202", now(), now()))
                db.exec("""INSERT INTO refund_payment (out_trade_no, order_id, sku_id, payment_type, trade_no, total_amount, subject, refund_status, create_time, callback_time, callback_content, operate_time)
                           VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                        (str(uuid.uuid4()).replace("-", "")[:32], order_id, sku_id,
                         random.choice(PAYMENT_WAYS), str(uuid.uuid4()).replace("-", "")[:32],
                         total, "退款", "已退款", now(), now(), "{}", now()))

            db.commit()
        except Exception as e:
            print("  ERROR: %s" % e)
            db.conn.rollback()

# ============================================================
# 入口
# ============================================================
if __name__ == "__main__":
    import argparse
    p = argparse.ArgumentParser(description="电商业务数据模拟生成器")
    p.add_argument("--host", default="hadoop101")
    p.add_argument("--port", type=int, default=3306)
    p.add_argument("--user", default="root")
    p.add_argument("--password", default="root")
    p.add_argument("--database", default="gmall")
    p.add_argument("--mode", choices=["init", "continuous"], default="init")
    p.add_argument("--batch", type=int, default=50, help="每批生成的交易数")
    p.add_argument("--interval", type=float, default=5.0, help="批次间隔秒数")
    p.add_argument("--lines", type=int, default=50000, help="连续模式下总交易数(仅 init 模式忽略)")
    args = p.parse_args()

    db = GmallDB(args.host, args.port, args.user, args.password, args.database)

    if args.mode == "init":
        print("开始初始化静态数据...")
        init_static_data(db)
        print("开始生成初始交易数据...")
        generate_transactions(db, batch_size=500)
        print("完成！表数据量：")
        for t in ["user_info", "sku_info", "spu_info", "order_info", "order_detail", "payment_info"]:
            try:
                print("  %s: %d" % (t, db.count(t)))
            except:
                pass
    else:
        print("持续生成模式：每 %d 秒生成 %d 条交易 → MySQL %s:%d/%s" % (args.interval, args.batch, args.host, args.port, args.database))
        print("按 Ctrl+C 停止\n")
        total = 0
        try:
            while True:
                generate_transactions(db, batch_size=args.batch)
                total += args.batch
                print("[%s] 已生成 %d 条交易" % (datetime.now().strftime("%H:%M:%S"), total))
                time.sleep(args.interval)
        except KeyboardInterrupt:
            print("\n已停止。共生成 %d 条交易" % total)

    db.close()
