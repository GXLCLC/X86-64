#!/bin/bash
# ==============================================================================
# diy-part1.sh —— 编译前自定义脚本（第一部分）
# ------------------------------------------------------------------------------
# 运行时机：在 ./scripts/feeds update -a 【之前】执行（由工作流调用）
# 运行目录：OpenWrt/LEDE 源码根目录（工作流中先 cd openwrt 再执行本脚本）
# 主要作用：
#   1. 注释掉 LEDE 默认启用的 helloworld 代理插件 feed —— 本固件不含任何代理插件
#   2. 添加 DDNSTO 官方 feed 源（易有云 LinkEase 维护）
#   3. 拉取 LEDE feeds 中没有的第三方插件源码：
#      - luci-theme-argon（Argon 主题，新版 LuCI 对应 master 分支）
#      - OpenAppFilter（OFA 应用过滤，含内核模块，按官方说明放入 package/OpenAppFilter）
#      - luci-app-easytier（EasyTier 内网穿透，仓库内含核心包与 LuCI 界面包）
# 注意：SmartDNS / AdGuardHome / Turbo ACC / mwan3 / nlbwmon 已包含在
#       LEDE 自带的 packages、luci feed 中，无需额外拉取，直接在 config 中选中即可。
# ==============================================================================

set -e  # 任何命令失败立即终止，避免带病编译

# ------------------------------------------------------------------------------
# 0. 目录自检：确保脚本运行在 OpenWrt 源码根目录（该目录下应有 rules.mk 和 package/）
# ------------------------------------------------------------------------------
if [ ! -f rules.mk ] || [ ! -d package ]; then
    echo "[错误] 请在 OpenWrt/LEDE 源码根目录下运行本脚本！"
    exit 1
fi

# ------------------------------------------------------------------------------
# 1. 移除代理插件源
#    LEDE 的 feeds.conf.default 默认启用了 helloworld feed（SSR-Plus/Passwall 等
#    代理插件集合）。本固件明确不包含任何代理插件，因此直接把该行注释掉，
#    让代理软件包根本不进入 feed 索引，菜单里也看不到，从源头杜绝。
# ------------------------------------------------------------------------------
sed -i 's/^src-git helloworld /#src-git helloworld /' feeds.conf.default
echo "[diy-part1] 已注释掉 helloworld 代理插件 feed"

# ------------------------------------------------------------------------------
# 2. 添加 DDNSTO 官方 feed 源
#    - nas-packages      ：服务包源（ddnsto 核心服务在 network/services/ddnsto）
#    - nas-packages-luci ：LuCI 界面源（luci-app-ddnsto 在 luci/ 目录下）
#    写法 src-git <feed名> <git地址>;分支 ，feeds update 时会自动拉取。
# ------------------------------------------------------------------------------
echo 'src-git nas https://github.com/linkease/nas-packages.git;master' >> feeds.conf.default
echo 'src-git nas_luci https://github.com/linkease/nas-packages-luci.git;main' >> feeds.conf.default
echo "[diy-part1] 已添加 DDNSTO 官方 feed 源"

# 统一的第三方插件放置目录（package/new 是社区惯例，名字随意，编译系统会递归扫描）
mkdir -p package/new

# ------------------------------------------------------------------------------
# 3. 拉取 Argon 主题
#    重要：当前 LEDE master 使用的是 openwrt-25.x 版【新版 LuCI】（JS/ucode 界面），
#    所以必须用 jerrykuku/luci-theme-argon 的 master 分支；
#    该仓库的 18.06 分支只适用于老版 Lua LuCI，用错会导致主题不显示。
# ------------------------------------------------------------------------------
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon.git package/new/luci-theme-argon
echo "[diy-part1] 已拉取 luci-theme-argon（master 分支）"

# ------------------------------------------------------------------------------
# 4. 拉取 OFA 应用过滤（OpenAppFilter）
#    官方文档要求克隆到 package/OpenAppFilter；仓库内含三个包：
#    oaf（内核模块）、open-app-filter（守护进程）、luci-app-oaf（LuCI 界面）。
#    config 中选中 luci-app-oaf 后，defconfig 会自动选上另外两个依赖。
# ------------------------------------------------------------------------------
git clone --depth=1 https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter
echo "[diy-part1] 已拉取 OpenAppFilter（OFA 应用过滤）"

# ------------------------------------------------------------------------------
# 5. 拉取 EasyTier 内网穿透
#    仓库根目录同时包含 easytier/（核心服务包，构建时自动下载官方预编译二进制）、
#    easytier-noweb/（无 Web 控制台版本）、luci-app-easytier/（LuCI 界面包）和
#    version.mk（版本定义，被各子包 Makefile 引用），因此必须整个仓库一起克隆，
#    不能只拷贝其中一个目录。
#    LuCI 界面为 Lua 编写，其 Makefile 已声明依赖 +luci-compat（已在 config 中选中）。
# ------------------------------------------------------------------------------
git clone --depth=1 https://github.com/EasyTier/luci-app-easytier.git package/new/luci-app-easytier
echo "[diy-part1] 已拉取 luci-app-easytier（EasyTier 内网穿透）"

echo "[diy-part1] 全部执行完成 ✔"
