#!/bin/bash
# ==========================================================================
#  编译前预处理脚本（extra.sh）
# --------------------------------------------------------------------------
#  这个脚本做什么：
#    在 OpenWrt 源码拉取完毕后、正式编译开始前，执行一些"准备性"工作，
#    比如：grep 排查依赖、给源码打补丁、修改特定源文件内容等。
#
#  什么时候执行：
#    工作流会在"应用固件定制"步骤之后、"更新并安装软件源"之前调用本脚本。
#    如果不需要任何预处理，可以保持为空脚本（只输出一行提示即可）。
#
#  怎么用：
#    1. 工作流会把 OpenWrt 源码目录作为第一个参数传进来
#    2. 在脚本里用 cd "$1" 进入源码目录，然后随便折腾
#    3. 结束时 exit 0 表示成功，非 0 会让工作流报错停止
#
#  常见用途举例：
#    - sed 修改某个 package 的 Makefile（比如换版本号）
#    - git apply 打补丁
#    - 复制 custom-packages/ 下的本地包进源码 package/
#    - 修改 feeds.conf.default 追加源（但建议直接改 custom-feeds.conf）
# ==========================================================================

# 获取工作流传入的 OpenWrt 源码目录路径（第一个参数）
OPENWRT_DIR="${1:-openwrt}"

echo "======================================================"
echo " extra.sh 编译前预处理开始"
echo " OpenWrt 源码目录: $OPENWRT_DIR"
echo "======================================================"

# ---- 示例 1：检查关键依赖包是否在 feeds 里存在 ----
# 原理：用 grep 在 feeds/ 目录下搜索包名对应的 Makefile 目录
# 如果缺失就提前报错，避免编译到一半才发现
# （工作流本身也有"校验插件"步骤，这里是更早的一层检查）
check_package() {
    local pkg_name="$1"
    # 在 feeds/ 和 package/ 目录下搜索，找到 Makefile 就算存在
    if find "$OPENWRT_DIR/feeds" "$OPENWRT_DIR/package" -maxdepth 3 -name Makefile \
           -path "*/${pkg_name}/*" 2>/dev/null | grep -q .; then
        echo "  [OK] 包存在: $pkg_name"
    else
        echo "  [WARN] 包未找到: $pkg_name  (可能在 feeds install 之后才会出现)"
    fi
}

echo "--- 检查关键插件包 ---"
cd "$OPENWRT_DIR" || exit 1

# 这些插件的 Makefile 目录名和包名不完全一致，需手动列一下
# （feeds install 之后它们会出现在 feeds/luci/applications/ 或 feeds/packages/net/ 下）
echo "注意：以下检查在 feeds install 之前执行，部分包还未注册是正常的"
check_package "luci-app-turboacc"
check_package "luci-app-adguardhome"
check_package "luci-app-smartdns"
check_package "ddnsto"
check_package "luci-app-ddnsto"
check_package "luci-app-oaf"
check_package "luci-app-mwan3"
check_package "mwan3"
check_package "luci-app-nlbwmon"
check_package "luci-theme-argon"

# ---- 示例 2：如果有 custom-packages/ 下的本地包，复制进源码 ----
# （当前仓库 custom-packages/ 目录是空的，下面只是示例，需要时去掉注释）
# if [ -d "$GITHUB_WORKSPACE/custom-packages" ]; then
#     echo "--- 复制 custom-packages/ 下的本地包进源码 ---"
#     for pkg_dir in "$GITHUB_WORKSPACE/custom-packages"/*/; do
#         [ -d "$pkg_dir" ] || continue
#         pkg_name=$(basename "$pkg_dir")
#         echo "  复制 $pkg_name -> package/$pkg_name"
#         cp -rf "$pkg_dir" "$OPENWRT_DIR/package/$pkg_name"
#     done
# fi

# ---- 示例 3：给源码打补丁 ----
# 如果某个插件有 bug 需要修，可以把 .patch 文件放到 scripts/patches/
# 然后在这里用 git apply 或 patch -p1 打进去
# if [ -f "scripts/patches/my-fix.patch" ]; then
#     cd "$OPENWRT_DIR"
#     git apply "$GITHUB_WORKSPACE/scripts/patches/my-fix.patch" && echo "补丁应用成功"
# fi

echo "======================================================"
echo " extra.sh 预处理完毕"
echo "======================================================"

exit 0
