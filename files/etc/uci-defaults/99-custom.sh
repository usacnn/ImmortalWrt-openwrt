#!/bin/sh
# 99-custom.sh 旁路由专用版本
LOGFILE="/etc/config/uci-defaults-log.txt"
echo "Starting 99-custom.sh (bypass mode) at $(date)" >>$LOGFILE

# 方便首次访问（可刷机后在防火墙里改回 REJECT）
uci set firewall.@zone[1].input='ACCEPT'

# ========== 旁路由核心配置 ==========
# LAN 静态 IP
uci set network.lan.proto='static'
uci set network.lan.ipaddr='10.10.10.230'
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.gateway='10.10.10.253'
uci set network.lan.dns='10.10.10.253'

# 关闭 DHCP（非常重要）
uci set dhcp.lan.ignore='1'

uci commit network
uci commit dhcp
# ==================================

# 设置所有网口可访问网页终端
uci delete ttyd.@ttyd[0].interface 2>/dev/null

# 设置所有网口可连接 SSH
uci set dropbear.@dropbear[0].Interface='' 2>/dev/null
uci commit

# 编译作者信息
FILE_PATH="/etc/openwrt_release"
NEW_DESCRIPTION="Packaged by wukongdaily"
sed -i "s/DISTRIB_DESCRIPTION='[^']*'/DISTRIB_DESCRIPTION='$NEW_DESCRIPTION'/" "$FILE_PATH" 2>/dev/null

# ========== 添加 kiddin9 第三方源（插件最全）==========
mkdir -p /etc/apk/repositories.d
echo "https://dl.openwrt.ai/packages-25.12/x86_64/kiddin9/" >> /etc/apk/repositories.d/customfeeds.list
echo "kiddin9 source added" >> $LOGFILE

# 给 update.sh 添加执行权限
chmod +x /root/update.sh 2>/dev/null

exit 0
