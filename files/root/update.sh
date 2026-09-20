#!/bin/sh
# 刷机后网络通了再运行： sh /root/update.sh
# 从 kiddin9 源安装 netspeedtest + pushbot，并安装 Open-Box

echo "========================================"
echo "开始安装第三方插件..."
echo "========================================"

# 更新软件源
echo ">>> 更新软件源..."
apk update

# ---------- 1. 从源安装 netspeedtest ----------
echo ">>> 安装 luci-app-netspeedtest..."
apk add luci-app-netspeedtest luci-i18n-netspeedtest-zh-cn 2>/dev/null || \
opkg install luci-app-netspeedtest luci-i18n-netspeedtest-zh-cn 2>/dev/null || true

# ---------- 2. 从源安装 pushbot ----------
echo ">>> 安装 luci-app-pushbot..."
apk add luci-app-pushbot luci-i18n-pushbot-zh-cn 2>/dev/null || \
opkg install luci-app-pushbot luci-i18n-pushbot-zh-cn 2>/dev/null || true

# ---------- 3. 安装 Open-Box（免交互，端口 3036）----------
echo ">>> 安装 Open-Box（默认端口 3036）..."
curl -fsSL https://raw.githubusercontent.com/liandu2024/Open-Box/main/scripts/install.sh | sh -s -- --port 3036

echo "========================================"
echo "全部安装完成！"
echo "请刷新网页查看菜单。"
echo "Open-Box 面板地址：http://你的IP:3036"
echo "========================================"
