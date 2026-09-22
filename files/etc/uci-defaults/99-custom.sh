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

# 彻底禁用 IPv6 路由通告 (RA)、DHCPv6 和 NDP 代理
uci set dhcp.lan.ra='disabled'
uci set dhcp.lan.dhcpv6='disabled'
uci set dhcp.lan.ndp='disabled'

# 关闭全局 IPv6 管理服务
uci delete dhcp.odhcpd 2>/dev/null
uci commit dhcp

# ========== 3. 旁路由防火墙防死锁配置 ==========
# 开启 LAN 口 IP 动态伪装与 MSS 钳制（保证转发流量有去有回不丢包）
uci set firewall.@zone[0].masq='1'
uci set firewall.@zone[0].mtu_fix='1'
uci commit firewall

# ========== 4. 系统管理与访问权限 ==========
# 允许所有接口访问网页终端与 SSH
uci delete ttyd.@ttyd[0].interface 2>/dev/null
uci set dropbear.@dropbear[0].Interface='' 2>/dev/null
uci commit

# 修改版本描述信息
FILE_PATH="/etc/openwrt_release"
NEW_DESCRIPTION="Packaged by cia"
[ -f "$FILE_PATH" ] && sed -i "s/DISTRIB_DESCRIPTION='[^']*'/DISTRIB_DESCRIPTION='$NEW_DESCRIPTION'/" "$FILE_PATH"

# 赋予升级脚本执行权限
[ -f "/root/updata.sh" ] && chmod +x /root/updata.sh

# ========== 5. Web 与 HTTPS 面板配置 ==========
uci -q delete uhttpd.main.listen_https
uci add_list uhttpd.main.listen_https='0.0.0.0:443'
uci add_list uhttpd.main.listen_https='[::]:443'
uci set uhttpd.main.cert='/etc/config/ssl/fa.pem'
uci set uhttpd.main.key='/etc/config/ssl/fa.key'
uci commit uhttpd

# 开启 AdGuard Home 自启（如果存在服务文件）
[ -f "/etc/init.d/adguardhome" ] && /etc/init.d/adguardhome enable

echo "Finished 99-custom.sh at $(date)" >> "$LOGFILE"
exit 0
