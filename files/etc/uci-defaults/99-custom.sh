#!/bin/sh
# 99-custom.sh 旁路由专用优化版本
LOGFILE="/etc/config/uci-defaults-log.txt"
echo "Starting 99-custom.sh (bypass mode) at $(date)" >> "$LOGFILE"

# ========== 1. 旁路由网络核心配置 ==========
uci set network.lan.proto='static'
uci set network.lan.ipaddr='10.10.10.230'
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.gateway='10.10.10.253'
uci set network.lan.dns='10.10.10.250'
# 禁用 LAN 口默认下发的 IPv6 前缀分配，防止与主路由冲突
uci delete network.lan.ip6assign 2>/dev/null
uci commit network

# ========== 2. 彻底关闭 DHCPv4 与 全部 IPv6 服务（解决抢占手机DNS） ==========
# 关闭 IPv4 DHCP
uci set dhcp.lan.ignore='1'

# 彻底禁用 IPv6 路由通告 (RA)、DHCPv6 和 NDP 代理 及学习路由
uci set dhcp.lan.ra='disabled'
uci set dhcp.lan.dhcpv6='disabled'
uci set dhcp.lan.ndp='disabled'
uci delete dhcp.lan.learn_routes 2>/dev/null

# 避让 53 端口给 AdGuard Home，将 dnsmasq 改为 531
uci set dhcp.@dnsmasq[0].port='531'

# 清理 dhcp 配置文件中对 odhcpd 服务的引用
uci delete dhcp.odhcpd 2>/dev/null
uci commit dhcp

# 移除 odhcpd 开机自启软链接（等效于执行 disable）
/etc/init.d/odhcpd disable 2>/dev/null

# ========== 3. 旁路由防火墙防死锁配置 ==========
# 开启 LAN 口 IP 动态伪装与 MSS 钳制（保证转发流量有去有回不丢包）
uci set firewall.@zone[0].masq='1'
uci set firewall.@zone[0].mtu_fix='1'
uci commit firewall

# ========== 4. 系统管理与访问权限 ==========
# 允许所有接口访问网页终端与 SSH
uci delete ttyd.@ttyd[0].interface 2>/dev/null
uci set dropbear.@dropbear[0].Interface='' 2>/dev/null
uci commit ttyd 2>/dev/null
uci commit dropbear

# 修改版本描述信息
FILE_PATH="/etc/openwrt_release"
NEW_DESCRIPTION="Packaged by cia"
[ -f "$FILE_PATH" ] && sed -i "s/DISTRIB_DESCRIPTION='[^']*'/DISTRIB_DESCRIPTION='$NEW_DESCRIPTION'/" "$FILE_PATH"

# 赋予升级脚本执行权限
[ -f "/root/update.sh" ] && chmod +x /root/update.sh

# ========== 5. Web 与 HTTPS 面板配置 ==========
uci -q delete uhttpd.main.listen_https
uci add_list uhttpd.main.listen_https='0.0.0.0:443'
uci add_list uhttpd.main.listen_https='[::]:443'
if [ -f "/etc/config/ssl/fa.pem" ] && [ -f "/etc/config/ssl/fa.key" ]; then
    uci set uhttpd.main.cert='/etc/config/ssl/fa.pem'
    uci set uhttpd.main.key='/etc/config/ssl/fa.key'
fi
uci commit uhttpd


# ========== 6. AdGuard Home 开机自启 ==========
[ -f "/etc/init.d/adguardhome" ] && /etc/init.d/adguardhome enable 2>/dev/null

echo "Finished 99-custom.sh at $(date)" >> "$LOGFILE"
exit 0
