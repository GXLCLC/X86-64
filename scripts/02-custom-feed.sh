#!/bin/bash
# ============================================================
# 02-custom-feed.sh
# 在 feeds 更新后做一些额外的自定义处理
# 例如：修改源码、替换补丁、删除冲突包等
# 工作目录：openwrt/
# ============================================================
set -e

echo "==> 自定义 feeds 处理"

# 示例：如果需要修改某个包的 Makefile 或源码，可在这里操作
# 例如：cd package/lean/xxx && git apply $GITHUB_WORKSPACE/patches/xxx.patch

# 示例：移除与自定义源冲突的包（按需取消注释）
# rm -rf feeds/packages/net/sing-box
# rm -rf feeds/luci/applications/luci-app-passwall

# 示例：对 lede 源码打补丁
# if [ -d "$GITHUB_WORKSPACE/patches" ]; then
#   echo "==> 应用自定义补丁"
#   for p in "$GITHUB_WORKSPACE"/patches/*.patch; do
#     [ -f "$p" ] && echo "应用: $p" && patch -p1 < "$p"
#   done
# fi

echo "==> feeds 自定义处理完成"
