#!/bin/sh
# 手动解包安装 netspeedtest + pushbot + Open-Box
# 绕过 ucode 版本依赖检查

echo "========================================"
echo "开始安装第三方插件..."
echo "========================================"

WORKDIR="/tmp/pkg-install"
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# 安装必要依赖（pushbot 需要）
echo ">>> 安装基础依赖..."
apk add jq iputils-arping curl 2>/dev/null || true

# ---------- 1. netspeedtest ----------
echo ">>> [1/3] 下载 luci-app-netspeedtest..."
wget -O netspeedtest.tar.gz \
  "https://gh-proxy.com/https://github.com/sirpdboy/netspeedtest/releases/download/v5.2.1/openwrt-24.10-x86_64.tar.gz"

if [ -f netspeedtest.tar.gz ]; then
  tar -xzf netspeedtest.tar.gz
  echo ">>> 解压并安装 IPK..."
  find . -type f -name "*.ipk" | while read -r pkg; do
    echo "处理: $pkg"
    TEMP=$(mktemp -d)
    cd "$TEMP"
    # 解压 ipk 外层包
    tar -xzf "$OLDPWD/$pkg" 2>/dev/null || tar -xf "$OLDPWD/$pkg" 2>/dev/null || true

    # 释放 data 部分到根目录
    if [ -f data.tar.gz ]; then
      tar -xzf data.tar.gz -C /
    elif [ -f data.tar.zst ]; then
      tar --zstd -xf data.tar.zst -C / 2>/dev/null || true
    elif [ -f data.tar.xz ]; then
      tar -xJf data.tar.xz -C /
    elif [ -f data.tar ]; then
      tar -xf data.tar -C /
    fi
    cd "$WORKDIR"
    rm -rf "$TEMP"
  done
  echo "netspeedtest 安装完成"
fi

# ---------- 2. pushbot（改用 IPK 架构，避免 Busybox tar 解不开 zstd）----------
echo ">>> [2/3] 下载 luci-app-pushbot (主程序 + 中文语言包)..."
# 采用 8 月底的纯 ucode 架构 IPK 包，Busybox tar 可以直接完美解包
wget -O pushbot-main.ipk \
  "https://gh-proxy.com/https://github.com/zzsj0928/luci-app-pushbot/releases/download/luci-app-pushbot_2026.08.28-1005_x64_IPK/luci-app-pushbot_5.17-r0_all.ipk"

wget -O pushbot-i18n.ipk \
  "https://gh-proxy.com/https://github.com/zzsj0928/luci-app-pushbot/releases/download/luci-app-pushbot_2026.08.28-1005_x64_IPK/luci-i18n-pushbot-zh-cn_5.17-r0_all.ipk.ipk"

for ipk in pushbot-main.ipk pushbot-i18n.ipk; do
  if [ -f "$ipk" ]; then
    echo "正在释放: $ipk"
    TEMP=$(mktemp -d)
    cd "$TEMP"
    tar -xzf "$WORKDIR/$ipk" 2>/dev/null || tar -xf "$WORKDIR/$ipk" 2>/dev/null || true

    if [ -f data.tar.gz ]; then
      tar -xzf data.tar.gz -C /
    elif [ -f data.tar.zst ]; then
      tar --zstd -xf data.tar.zst -C / 2>/dev/null || true
    elif [ -f data.tar ]; then
      tar -xf data.tar -C /
    fi
    cd "$WORKDIR"
    rm -rf "$TEMP"
  fi
done

# 权限与自启
if [ -f /etc/init.d/pushbot ]; then
  chmod +x /etc/init.d/pushbot
  /etc/init.d/pushbot enable 2>/dev/null || true
  echo "pushbot 服务配置完成"
fi

# ---------- 3. 刷新 LuCI ----------
echo ">>> 刷新 LuCI 缓存与服务..."
rm -rf /tmp/luci-* /tmp/luci-indexcache
/etc/init.d/rpcd restart 2>/dev/null || true
/etc/init.d/uhttpd restart 2>/dev/null || true

# ---------- 4. Open-Box ----------
echo ">>> [3/3] 安装 Open-Box (端口 3038)..."
curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/liandu2024/Open-Box/main/scripts/install.sh | sh -s -- --port 3038 || true

# 清理
cd /
rm -rf "$WORKDIR"

echo "========================================"
echo "安装完成！"
echo "请按 Ctrl+F5 强制刷新网页"
echo "Open-Box 面板：http://你的IP:3038"
echo "========================================"

# 最后检查文件是否存在
echo ""
echo ">>> 检查安装结果："
ls /usr/share/luci/menu.d/*netspeed* 2>/dev/null || echo "netspeedtest 菜单文件未找到"
ls /usr/share/luci/menu.d/*push* 2>/dev/null || echo "pushbot 菜单文件未找到"
