#!/bin/bash
# ============================================================
# 04-gen-release-info.sh
# 生成 GitHub Release 发布页信息（IP + 插件清单 + 文件列表）
# 输出目录：${GITHUB_WORKSPACE}/release-info/
#   - release-body.md  : Release 正文
#   - plugins.txt      : 插件纯文本清单
# ============================================================
set -e

WORKSPACE="${GITHUB_WORKSPACE:-$(pwd)}"
OPENWRT_DIR="${WORKSPACE}/openwrt"
OUTPUT_DIR="${WORKSPACE}/release-info"
mkdir -p "$OUTPUT_DIR"

# ---------- 默认 IP ----------
# lede 默认 LAN IP 为 192.168.1.1
DEFAULT_IP="192.168.1.1"
# 如果修改过 config_generate 中的 IP，这里同步读取
if [ -f "$OPENWRT_DIR/package/base-files/files/bin/config_generate" ]; then
  CUSTOM_IP=$(grep -oP '192\.168\.\d+\.\d+' \
    "$OPENWRT_DIR/package/base-files/files/bin/config_generate" 2>/dev/null | head -1 || true)
  [ -n "$CUSTOM_IP" ] && DEFAULT_IP="$CUSTOM_IP"
fi

# ---------- 编译信息 ----------
BUILD_DATE="$(date '+%Y-%m-%d %H:%M:%S %Z')"
OPENWRT_REV="unknown"
if [ -f "$OPENWRT_DIR/.git/HEAD" ]; then
  OPENWRT_REV="$(cd "$OPENWRT_DIR" && git rev-parse --short HEAD 2>/dev/null || echo unknown)"
fi

KERNEL_VER="$(grep -oP 'CONFIG_LINUX_KERNEL_VERSION="\K[^"]+' \
  "$OPENWRT_DIR/.config" 2>/dev/null || echo 'unknown')"

# ---------- 提取已启用的插件 ----------
# 只取以 luci-app- 开头的包名，去掉前缀和后缀，整理为列表
PLUGINS_RAW=$(grep -oP 'CONFIG_PACKAGE_\Kluci-app-[a-zA-Z0-9_-]+(?==y)' \
  "$OPENWRT_DIR/.config" 2>/dev/null | sed 's/luci-app-//' | sort -u || true)

# 插件名称友好化（简单映射，未知则原样）
declare -A PLUGIN_NAME=(
  [passwall]="PassWall"
  [passwall2]="PassWall2"
  [ssr-plus]="ShadowSocksR Plus+"
  [openclash]="OpenClash"
  [homeproxy]="HomeProxy"
  [turboacc]="Turbo ACC 网络加速"
  [adguardhome]="AdGuard Home"
  [smartdns]="SmartDNS"
  [mosdns]="MosDNS"
  [frpc]="Frp 客户端"
  [frps]="Frp 服务端"
  [nps]="NPS 内网穿透"
  [zerotier]="ZeroTier"
  [wireguard]="WireGuard"
  [aria2]="Aria2 下载"
  [qbittorrent]="qBittorrent"
  [transmission]="Transmission"
  [jellyfin]="Jellyfin"
  [alist]="AList"
  [samba4]="Samba4 文件共享"
  [vsftpd]="vsFTPd"
  [ddns]="DDNS 动态域名"
  [upnp]="UPnP"
  [ipsec-vpnd]="IPSec VPN"
  [openvpn-server]="OpenVPN 服务端"
  [statistics]="系统监控"
  [nlbwmon]="带宽监控"
  [argon]="Argon 主题"
  [edge]="Edge 主题"
  [design]="Design 主题"
  [dockerman]="Docker 管理"
  [filetransfer]="文件传输"
  [rclone]="Rclone"
  [minidlna]="MiniDLNA"
  [usb-printer]="USB 打印"
  [wol]="网络唤醒"
)

PLUGIN_LIST=""
PLUGIN_TEXT=""
if [ -n "$PLUGINS_RAW" ]; then
  while IFS= read -r p; do
    [ -z "$p" ] && continue
    display="${PLUGIN_NAME[$p]:-$p}"
    PLUGIN_LIST+="- \`$p\` — ${display}\n"
    PLUGIN_TEXT+="${display} (luci-app-${p})\n"
  done <<< "$PLUGINS_RAW"
else
  PLUGIN_LIST="- （无额外插件）"
  PLUGIN_TEXT="（无额外插件）"
fi

# ---------- 固件文件列表 ----------
FIRMWARE_DIR="$OPENWRT_DIR/bin/targets/x86/64"
FILE_LIST=""
if [ -d "$FIRMWARE_DIR" ]; then
  FILE_LIST="| 文件名 | 大小 |\n| --- | --- |\n"
  for f in "$FIRMWARE_DIR"/*; do
    [ -f "$f" ] || continue
    name="$(basename "$f")"
    size="$(du -h "$f" | cut -f1)"
    FILE_LIST+="| \`${name}\` | ${size} |\n"
  done
else
  FILE_LIST="（编译产物目录不存在）"
fi

# ---------- 写入 release-body.md ----------
cat > "$OUTPUT_DIR/release-body.md" <<EOF
# OpenWrt x86/64 固件发布

## 📋 固件信息

| 项目 | 值 |
| --- | --- |
| 源码 | [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede) |
| Commit | \`${OPENWRT_REV}\` |
| 内核版本 | ${KERNEL_VER} |
| 架构 | x86_64 |
| 编译时间 | ${BUILD_DATE} |

## 🌐 默认管理信息

- **管理地址（LAN IP）**：\`http://${DEFAULT_IP}\`
- **默认用户名**：\`root\`
- **默认密码**：\`password\`（首次登录后请立即修改）
- **SSH 端口**：\`22\`

> 首次刷机后请将电脑网卡设为同网段（如 \`${DEFAULT_IP%.*}.2\`），浏览器访问上述地址登录管理后台。

## 📦 已安装插件

${PLUGIN_LIST}

## 💾 固件文件

${FILE_LIST}

## 🔧 刷机说明

1. 下载对应格式固件（虚拟机推荐 \`combined-efi.img.gz\` 或 \`.vmdk\`）。
2. 物理机可用 \`balenaEtcher\` / \`rufus\` 写入 U 盘后引导安装。
3. 虚拟机直接挂载 \`.vmdk\` / \`.vdi\` / \`.vhdx\` 镜像即可。
4. 首次启动后通过 \`http://${DEFAULT_IP}\` 进入管理界面。

---

> 本固件由 GitHub Actions 自动编译，仅供学习交流使用。
EOF

# ---------- 写入插件纯文本清单 ----------
echo -e "${PLUGIN_TEXT}" > "$OUTPUT_DIR/plugins.txt"

echo "==> Release 信息已生成：$OUTPUT_DIR"
ls -lh "$OUTPUT_DIR"
