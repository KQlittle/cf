#!/bin/bash

# 赋予脚本和下载的文件执行权限
chmod a+x ddns.sh

# 执行 ddns.sh
./ddns.sh >> /opt/ddns_log.txt

# 主循环
while true; do
    source /opt/config
    DCF_file="/root/DCF.csv"
    if [ ! -e "$DCF_file" ]; then
    exit 0;
    else
    IPnew=$(sed -n "$((x + 2)),1p" DCF.csv | awk -F, '{print $1}');
    # 使用 ping 命令检测 IP 是否可达，超时时间设置为2秒
    if ping -c 1 -W 2 "$IPnew" &> /dev/null; then
        echo -e "$(date): IP $IPnew 可正常使用...." >> /opt/ddns_log.txt
    else
        echo -e "$(date): IP $IPnew 不可用，将执行IP更新..." >> /opt/ddns_log.txt
        # 在此处执行需要执行的脚本
        ./ddns.sh >> /opt/ddns_log.txt
    fi
    # 休眠 20 分钟
    fi
    echo -e "休眠：$sltime秒"
    sleep $sltime
done
