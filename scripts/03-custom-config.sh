#!/bin/bash
# ============================================================
# 03-custom-config.sh
# 在加载 .config 之后做一些额外的配置调整
# 工作目录：openwrt/
# 可在此处通过 sed 修改 .config，或添加自定义配置项
# ============================================================
set -e

echo "==> 自定义配置处理"

# 确保使用 zram-swap（提升低内存设备性能）
# sed -i 's/# CONFIG_PACKAGE_zram-swap is not set/CONFIG_PACKAGE_zram-swap=y/' .config

# 关闭不需要的开发/调试包以减小体积
# sed -i 's/CONFIG_PACKAGE_gdb=y/# CONFIG_PACKAGE_gdb is not set/' .config
# sed -i 's/CONFIG_PACKAGE_strace=y/# CONFIG_PACKAGE_strace is not set/' .config

# 移除 lede 默认的某些插件（按需取消注释）
# ./scripts/feeds uninstall luci-app-vsftpd

# 设置默认 LAN IP（lede 默认 192.168.1.1，如需修改可取消注释并改值）
# sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

echo "==> 自定义配置处理完成"
