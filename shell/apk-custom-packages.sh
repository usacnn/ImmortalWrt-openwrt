#!/bin/bash
# ============= ImmortalWrt 25.12.x 第三方 + 官方插件 =============
# ============= 2026-09-20 整理（只保留当前实际可用的） =============
# ============= imm仓库外的第三方插件==============
# ============= 若启用 则打开注释 ================
# ============= 但此文件也可以处理仓库内的软件去留 本质上是做了一个PACKAGES字符串的拼接 ================

# 各位注意 如果你构建的固件是硬路由 此文件的注释要酌情考虑是否打开 因为硬路由的闪存空间有限 若构建出来过大或者构建失败 记得调整本文件的注释
# 考虑到istore商店的集成与否 属于高频操作 故 目前已将集成store的操作放置在 工作流的UI 选项 用户自行勾选 则集成  不勾选则不集成 以减少修改此文件的次数

# 新增Run安装器 用于快速安装makeself打包的run文件 目前和quickfile的nginx配置冲突 请勿同时集成quickfile
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-run"
# 首页和网络向导
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-quickstart-zh-cn"
# 新增非常好用的文件管理器 sbwml/luci-app-quickfile （luci 23版本不支持 勿集成）
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES bash quickfile luci-app-quickfile luci-i18n-quickfile-zh-cn"
# 高级卸载 by YT Vedio Talk
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-uninstall"
# 极光主题 by github eamonxg
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-aurora luci-app-aurora-config luci-i18n-aurora-config-zh-cn"
# 进阶设置 by sirpdboy 
# 当luci-app-advancedplus插件开启时 需排除冲突项 luci-app-argon-config和luci-i18n-argon-config-zh-cn 减号代表排除
# 若要集成此插件请注意相关issue:https://github.com/wukongdaily/ImmortalWrt-ImageBuilder/issues/521
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-advancedplus luci-i18n-advancedplus-zh-cn -luci-app-argon-config -luci-i18n-argon-config-zh-cn"

# 悟空 apk 仓库目前已支持的第三方（可选打开）以下是常用但不强制的，按需打开
#一键分区扩容插件
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-partexp luci-i18n-partexp-zh-cn"
#酷猫主题
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-kucat"
# 流量监控
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES bandix luci-app-bandix luci-i18n-bandix-zh-cn"
# 极光主题（可选）
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-aurora luci-app-aurora-config luci-i18n-aurora-config-zh-cn"

# 去广告
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-adguardhome"

# 代理（使用 passwall + 核心，目前仓库里有）
CUSTOM_PACKAGES="$CUSTOM_PACKAGES geoview xray-core sing-box hysteria luci-i18n-passwall-zh-cn"
# 如果想用 passwall2，把上面那行注释掉，改用下面这行
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES geoview xray-core sing-box hysteria kmod-nft-socket kmod-nft-tproxy luci-app-passwall2 luci-i18n-passwall2-zh-cn"

# VPN / 组网
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-proto-wireguard"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-zerotier"

# 其他官方支持
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-diskman"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-ttyd"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-ocserv"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-cloudflared"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-openlist"  # alist 现在多叫 openlist
# ---------- 以下目前 25.12 仓库还没有，暂时不要打开 ----------
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-netspeedtest"   # 包含 homebox
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-pushbot"
