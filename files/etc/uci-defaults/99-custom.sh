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
NEW_DESCRIPTION="Packaged by cia"
sed -i "s/DISTRIB_DESCRIPTION='[^']*'/DISTRIB_DESCRIPTION='$NEW_DESCRIPTION'/" "$FILE_PATH" 2>/dev/null

# 给 update.sh 添加执行权限
chmod +x /root/updata.sh 2>/dev/null

# 1. 自动将 dnsmasq 默认端口固定为 531
uci set dhcp.@dnsmasq[0].port='531'
# 3. 启用 AdGuard Home 开机自启
/etc/init.d/adguardhome enable
# 4. 开启 uHTTPd 的 HTTPS 443 支持
uci add_list uhttpd.main.listen_https='0.0.0.0:443'
uci add_list uhttpd.main.listen_https='[::]:443'
uci set uhttpd.main.cert='/etc/config/ssl/fa.pem'
uci set uhttpd.main.key='/etc/config/ssl/fa.key'
uci commit uhttpd


exit 0
