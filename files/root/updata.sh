#!/bin/sh
set -e

echo "========================================"
echo "开始安装第三方插件..."
echo "========================================"

WORKDIR="/tmp/pkg-install"
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# ---------- 1. netspeedtest 手动解压兼容安装 ----------
echo ">>> [1/3] 下载并解压 luci-app-netspeedtest..."
wget -O netspeedtest.tar.gz \
  "https://gh-proxy.com/https://github.com/sirpdboy/netspeedtest/releases/download/v5.2.1/openwrt-24.10-x86_64.tar.gz"

if [ -f netspeedtest.tar.gz ]; then
  tar -xzf netspeedtest.tar.gz
  echo ">>> 释放 IPK 文件到系统根目录..."
  find . -type f -name "*.ipk" | while read -r pkg; do
    echo "正在释放: $pkg"
    TEMP_DIR=$(mktemp -d)
    tar -xzf "$pkg" -C "$TEMP_DIR" 2>/dev/null || tar -xf "$pkg" -C "$TEMP_DIR" 2>/dev/null || true
    if [ -f "$TEMP_DIR/data.tar.gz" ]; then
      tar -xzf "$TEMP_DIR/data.tar.gz" -C /
    elif [ -f "$TEMP_DIR/data.tar.zst" ]; then
      tar --zstd -xf "$TEMP_DIR/data.tar.zst" -C /
    elif [ -f "$TEMP_DIR/data.tar" ]; then
      tar -xf "$TEMP_DIR/data.tar" -C /
    fi
    rm -rf "$TEMP_DIR"
  done
fi

# ---------- 2. pushbot 手动解包安装（绕过 ucode 版本冲突） ----------
echo ">>> [2/3] 下载并安装 luci-app-pushbot..."
wget -O pushbot.apk \
  "https://gh-proxy.com/https://github.com/zzsj0928/luci-app-pushbot/releases/download/luci-app-pushbot_2026.09.19-1249_x64_APK/luci-app-pushbot-5.17-r24.apk"

if [ -f pushbot.apk ]; then
  echo "正在解压 pushbot.apk..."
  PUSHBOT_TEMP=$(mktemp -d)
  # 解压 apk 包本身
  tar -xzf pushbot.apk -C "$PUSHBOT_TEMP" 2>/dev/null || tar -xf pushbot.apk -C "$PUSHBOT_TEMP" 2>/dev/null || true
  
  # 释放数据包到系统根目录
  if [ -f "$PUSHBOT_TEMP/data.tar.gz" ]; then
    tar -xzf "$PUSHBOT_TEMP/data.tar.gz" -C /
  elif [ -f "$PUSHBOT_TEMP/data.tar.zst" ]; then
    tar --zstd -xf "$PUSHBOT_TEMP/data.tar.zst" -C /
  elif [ -f "$PUSHBOT_TEMP/data.tar" ]; then
    tar -xf "$PUSHBOT_TEMP/data.tar" -C /
  fi
  rm -rf "$PUSHBOT_TEMP"
  rm -f pushbot.apk

  # 赋予启动脚本权限并设置开机自启
  if [ -f /etc/init.d/pushbot ]; then
    chmod +x /etc/init.d/pushbot
    /etc/init.d/pushbot enable 2>/dev/null || true
  fi
  echo "pushbot 文件已释放完成！"
fi

# ---------- 3. 刷新 LuCI 菜单与后台服务 ----------
echo ">>> 刷新 LuCI 缓存与系统服务..."
rm -rf /tmp/luci-*
/etc/init.d/rpcd restart 2>/dev/null || true
/etc/init.d/uhttpd restart 2>/dev/null || true

# ---------- 4. Open-Box（端口已改为 3038 防冲突） ----------
echo ">>> [3/3] 安装 Open-Box..."
curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/liandu2024/Open-Box/main/scripts/install.sh | sh -s -- --port 3038 || true

# 清理工作目录
cd /
rm -rf "$WORKDIR"

echo "========================================"
echo "全部安装完成！"
echo "请按 Ctrl+F5 强制刷新网页后台查看菜单。"
echo "Open-Box 面板地址：http://你的路由器IP:3038"
echo "========================================"
