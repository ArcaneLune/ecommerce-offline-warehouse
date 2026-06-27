#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
电商用户行为日志模拟生成器
输出格式：每行一个完整 JSON 对象（页面日志或启动日志）
输出的字段名、类型必须与 ods_log_inc 建表 DDL 完全一致

用法：
  python3 log_generator.py --lines 10000
  python3 log_generator.py --lines 5000 --page-ratio 0.8 --dir /data/logs/app
"""

import json
import random
import time
import os
import uuid
from datetime import datetime

# ====== 模拟数据池（电商真实场景） ======
BRANDS       = ["iPhone", "Huawei", "Xiaomi", "Honor", "Samsung", "OPPO", "vivo"]
CHANNELS     = ["Appstore", "wandoujia", "huawei", "xiaomi", "samsung", "oppo", "vivo", "web"]
OS_LIST      = ["iOS 16.1", "iOS 15.7", "Android 13.0", "Android 12.0", "Android 11.0"]
MODELS       = {
    "iPhone":   ["iPhone 14 Pro", "iPhone 13", "iPhone 12"],
    "Huawei":   ["Mate 50", "P60", "Nova 11"],
    "Xiaomi":   ["Mi 13", "Redmi Note 12", "Mi 12s"],
    "Honor":    ["Honor 90", "Honor 80", "Honor X50"],
    "Samsung":  ["Galaxy S23", "Galaxy A54", "Galaxy Z Flip5"],
    "OPPO":     ["Find X6", "Reno 10", "A2 Pro"],
    "vivo":     ["X90 Pro", "S17", "Y78"]
}

PAGE_IDS      = ["home", "good_detail", "search", "cart", "order", "login", "payment", "category"]
ACTION_IDS    = ["favor_add", "comment", "cart_add", "order", "share", "click", "good_detail"]
DISPLAY_TYPES = ["query", "promotion", "recommend", "activity"]
ENTRY_TYPES   = ["icon", "notice", "install"]
ERROR_CODES   = [0, 0, 0, 0, 0, 1001, 2001, 3001, 4001]  # 大部分正常
ITEM_TYPES    = ["sku_id", "spu_id", "coupon_id", "activity_id"]
REFER_IDS     = ["1", "2", "3", "4", "5"]
PROVINCES     = list(range(1, 35))  # 省份 ID 1-34

def random_mid():
    """生成随机设备 ID"""
    return str(uuid.uuid4()).replace("-", "")[:16]

def random_session_id():
    """生成随机会话 ID"""
    return str(uuid.uuid4())

def random_uid():
    """生成随机用户 ID（1-5000）"""
    return str(random.randint(1, 5000))

def gen_common(is_new_day=None):
    """生成 common 环境信息"""
    brand = random.choice(BRANDS)
    return {
        "ar": str(random.choice(PROVINCES)),
        "ba": brand,
        "ch": random.choice(CHANNELS),
        "is_new": str(is_new_day if is_new_day is not None else random.choice(["0", "0", "0", "1"])),
        "md": random.choice(MODELS[brand]),
        "mid": random_mid(),
        "os": random.choice(OS_LIST),
        "sid": random_session_id(),
        "uid": random_uid(),
        "vc": "v" + str(random.randint(2, 3)) + "." + str(random.randint(0, 9)) + "." + str(random.randint(100, 199))
    }

def gen_actions(count=None):
    """生成 actions 动作数组"""
    if count is None:
        count = random.randint(0, 3)
    return [{
        "action_id": random.choice(ACTION_IDS),
        "item": str(random.randint(1, 500)),
        "item_type": random.choice(ITEM_TYPES),
        "ts": int(time.time() * 1000) - random.randint(0, 300000)
    } for _ in range(count)]

def gen_displays(count=None):
    """生成 displays 曝光数组"""
    if count is None:
        count = random.randint(0, 5)
    return [{
        "display_type": random.choice(DISPLAY_TYPES),
        "item": str(random.randint(1, 500)),
        "item_type": random.choice(ITEM_TYPES),
        "pos_seq": str(i + 1),
        "pos_id": str(random.randint(1, 6))
    } for i in range(count)]

def gen_page():
    """生成 page 页面信息"""
    return {
        "during_time": str(random.randint(1000, 60000)),
        "item": str(random.randint(1, 500)),
        "item_type": random.choice(ITEM_TYPES),
        "last_page_id": random.choice(PAGE_IDS),
        "page_id": random.choice(PAGE_IDS),
        "from_pos_id": str(random.randint(1, 10)),
        "from_pos_seq": str(random.randint(1, 10)),
        "refer_id": random.choice(REFER_IDS)
    }

def gen_start():
    """生成 start 启动信息"""
    entry = random.choice(ENTRY_TYPES)
    loading_time = random.randint(500, 30000)
    open_ad_id = random.randint(0, 20)
    open_ad_ms = random.randint(0, 5000) if open_ad_id > 0 else 0
    open_ad_skip_ms = random.randint(0, open_ad_ms) if open_ad_ms > 0 else 0
    return {
        "entry": entry,
        "first_open": 1 if random.random() < 0.3 else 0,
        "loading_time": loading_time,
        "open_ad_id": open_ad_id,
        "open_ad_ms": open_ad_ms,
        "open_ad_skip_ms": open_ad_skip_ms
    }

def gen_err():
    """生成 err 错误信息（大部分无错误）"""
    code = random.choice(ERROR_CODES)
    if code == 0:
        return {"error_code": 0, "msg": ""}
    return {
        "error_code": code,
        "msg": "mock error {}: {}".format(code, random.choice(["timeout", "network", "server", "data"]))
    }

def gen_page_log():
    """生成一条页面日志"""
    return {
        "common": gen_common(),
        "actions": gen_actions(),
        "displays": gen_displays(),
        "page": gen_page(),
        "err": gen_err(),
        "ts": int(time.time() * 1000)
    }

def gen_startup_log():
    """生成一条启动日志"""
    return {
        "common": gen_common(is_new_day=random.choice(["0", "1"])),
        "start": gen_start(),
        "err": gen_err(),
        "ts": int(time.time() * 1000)
    }

def generate_logs(output_dir, total_lines=10000, page_ratio=0.7):
    """
    一次性生成 N 条日志
    total_lines: 总日志行数
    page_ratio: 页面日志占比（0.7 = 70%为页面日志，30%为启动日志）
    """
    os.makedirs(output_dir, exist_ok=True)

    today = datetime.now().strftime("%Y-%m-%d")
    filename = os.path.join(output_dir, "app_{}.log".format(today))

    page_count = 0
    startup_count = 0

    print("开始生成 {} 条日志 → {}".format(total_lines, filename))

    with open(filename, "w", encoding="utf-8") as f:
        for i in range(total_lines):
            if random.random() < page_ratio:
                log = gen_page_log()
                page_count += 1
            else:
                log = gen_startup_log()
                startup_count += 1

            f.write(json.dumps(log, ensure_ascii=False) + "\n")

            if (i + 1) % 1000 == 0:
                print("  已生成 {}/{} 条...".format(i + 1, total_lines))

    file_size = os.path.getsize(filename)
    print("完成！页面日志 {} 条，启动日志 {} 条".format(page_count, startup_count))
    print("文件大小：{:.2f} MB".format(file_size / 1024 / 1024))
    return filename


def generate_continuously(output_dir, batch_size=10, interval=2, page_ratio=0.7):
    """
    持续生成日志，模拟实时数据流
    batch_size: 每批生成条数
    interval: 每批之间的间隔（秒）
    page_ratio: 页面日志占比
    """
    os.makedirs(output_dir, exist_ok=True)

    today = datetime.now().strftime("%Y-%m-%d")
    filename = os.path.join(output_dir, "app_{}.log".format(today))

    page_count = 0
    startup_count = 0
    batch_num = 0

    print("持续生成模式：每 {} 秒生成 {} 条日志 → {}".format(interval, batch_size, filename))
    print("按 Ctrl+C 停止")
    print()

    try:
        while True:
            batch_num += 1
            with open(filename, "a", encoding="utf-8") as f:
                for _ in range(batch_size):
                    if random.random() < page_ratio:
                        log = gen_page_log()
                        page_count += 1
                    else:
                        log = gen_startup_log()
                        startup_count += 1
                    f.write(json.dumps(log, ensure_ascii=False) + "\n")

            total = page_count + startup_count
            print("[批次 {}] 已生成 {} 条（页面: {}, 启动: {}），等待 {} 秒...".format(
                batch_num, total, page_count, startup_count, interval))
            time.sleep(interval)

    except KeyboardInterrupt:
        print()
        file_size = os.path.getsize(filename)
        print("已停止。共生成 {} 条（页面日志 {}，启动日志 {}）".format(total, page_count, startup_count))
        print("文件大小：{:.2f} MB".format(file_size / 1024 / 1024))
        print("文件路径：{}".format(filename))

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="电商用户行为日志模拟生成器")
    parser.add_argument("--dir", default="/data/logs/app", help="输出目录")
    parser.add_argument("--lines", type=int, default=10000, help="一次性生成日志行数（默认 10000）")
    parser.add_argument("--page-ratio", type=float, default=0.7, help="页面日志占比（默认 0.7）")
    parser.add_argument("--continuous", action="store_true", help="持续生成模式（模拟实时数据流）")
    parser.add_argument("--batch", type=int, default=10, help="持续模式下每批生成条数（默认 10）")
    parser.add_argument("--interval", type=float, default=2.0, help="持续模式下每批间隔秒数（默认 2）")
    args = parser.parse_args()

    if args.continuous:
        generate_continuously(args.dir, args.batch, args.interval, args.page_ratio)
    else:
        generate_logs(args.dir, args.lines, args.page_ratio)
