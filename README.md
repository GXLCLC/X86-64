# OpenWrt (lede) X86_64 云编译仓库

基于 GitHub Actions 的 OpenWrt X86_64 固件全自动编译仓库。使用 lede 最新源码，内置常用插件，编译完成自动发布 Release，可直接下载使用。

## 目录结构

```
├── .github/workflows/
│   └── build-openwrt.yml          # 核心云编译工作流（GitHub Actions）
├── configs/
│   └── x86_64.config              # 固件配置文件（勾选哪些插件、驱动）
├── custom-feeds.conf             # 自定义第三方软件源地址
├── custom-packages/               # 本地额外 OpenWrt 包（可选）
├── files/                         # 固件内置文件（开机脚本、默认配置）
│   └── etc/uci-defaults/
│       └── zzz-custom-settings    # 首次启动自动执行的固件定制脚本
├── scripts/
│   └── extra.sh                   # 编译前预处理脚本（可选）
└── .gitignore
```

## 固件默认信息

| 项目 | 值 |
|------|-----|
| 管理地址（LAN IP） | `192.168.1.1` |
| 登录账号 | `root` |
| 登录密码 | `password` |
| 管理后台语言 | 简体中文 |
| 默认主题 | Argon |
| overlay 空间 | 2GB |
| 镜像格式 | 仅 IMG（BIOS + UEFI） |

> ⚠️ **首次登录后请立即修改默认密码！**

## 已集成插件

| 插件 | 说明 |
|------|------|
| luci-theme-argon | Argon 主题（默认） |
| luci-app-turboacc | 网络加速（流量分载 + BBR） |
| luci-app-smartdns | DNS 优化加速 |
| luci-app-adguardhome | 全网去广告 |
| luci-app-mwan3 | 多拨负载均衡 |
| luci-app-nlbwmon | 带宽流量监控 |
| luci-app-ddnsto + ddnsto | 内网穿透（DDNSTO） |
| luci-app-easytier + easytier | 去中心化组网（EasyTier） |
| luci-app-oaf | 应用过滤（OpenAppFilter） |
| luci-app-upnp | UPnP 自动端口映射 |
| luci-app-wol | 网络唤醒 |
| luci-app-ttyd | 网页终端 |

## 编译包含的驱动

**Intel 网卡**：e1000、e1000e、igb、igc、ixgbe
**Realtek 网卡**：r8169
**USB 网卡**：RNDIS、CDC-Ethernet、ASIX、RTL8150/8152
**USB 存储**：usb2、usb3、usb-storage
**文件系统**：NTFS、FAT32、exFAT
**虚拟网卡**：TUN（EasyTier 依赖）

## 如何使用

### 1. 触发编译

1. Fork 本仓库到自己的 GitHub
2. 进入 Actions 页面
3. 选中 **"云编译 OpenWrt X86_64 固件"**
4. 点击 **"Run workflow"** 按钮
5. 等待约 2~4 小时（GitHub 公共仓库免费，单次最长 6 小时）

### 2. 下载固件

编译完成后，在仓库 **Releases** 页面找到对应 Release，下载 `.img.gz` 文件。

### 3. 刷机

1. 解压 `.img.gz` 得到 `.img` 文件
2. 用 [Win32 Disk Imager](https://sourceforge.net/projects/win32diskimager/)、[balenaEtcher](https://etcher.balena.io/) 或 `dd` 命令写入 U 盘或虚拟机磁盘
3. 启动设备，浏览器访问 `192.168.1.1` 进入管理后台
4. 首次登录后立即修改密码

### 4. 固件镜像说明

| 文件 | 用途 |
|------|------|
| `combined-efi.img.gz` | UEFI 启动（新电脑/新虚拟机，**推荐**） |
| `combined.img.gz` | BIOS 传统启动（老主板） |

## 如何自定义

### 添加/删除插件

编辑 `configs/x86_64.config`：

```bash
# 启用插件：
CONFIG_PACKAGE_luci-app-qbittorrent=y

# 禁用插件（两种方式任选）：
# 方式 1：直接删除这一行
# 方式 2：显式设为禁用
# CONFIG_PACKAGE_luci-app-oaf is not set
```

> ⚠️ 包名必须和 OpenWrt 源里的名字**完全一致**（区分大小写和横线）。写错的话 `make defconfig` 会静默丢弃该行，导致编译出的固件缺插件。工作流有校验步骤，发现丢失会明确报错。

### 添加第三方软件源

编辑 `custom-feeds.conf`，格式：

```
src-git <源名称> <Git仓库地址>
```

例如添加一个新源：
```
src-git example https://github.com/example/openwrt-packages
```

### 修改固件默认 LAN IP / 密码 / 主题

编辑 `files/etc/uci-defaults/zzz-custom-settings`，修改其中的 `uci set` 命令参数即可。

### 添加本地额外插件

把插件目录放到 `custom-packages/` 下，然后在 `scripts/extra.sh` 里去掉相关注释，脚本会自动把它们复制进 OpenWrt 源码的 `package/` 目录。

## 注意事项

- **ubuntu-22.04 runner 将于 2026-09-17 弃用**，届时将 `build-openwrt.yml` 中 `runs-on: ubuntu-22.04` 改为 `runs-on: ubuntu-24.04` 即可
- 编译过程不使用 SSH 登录，全程在 GitHub 虚拟机上完成
- 不加任何代理插件（OpenClash、PassWall 等）
- 如果 EasyTier 预编译二进制下载失败，可以在 config 里注释掉 `CONFIG_PACKAGE_easytier=y` 和 `CONFIG_PACKAGE_luci-app-easytier=y`

## 参考资源

- [lede 源码仓库](https://github.com/coolsnowwolf/lede)
- [kenzok8 第三方源](https://github.com/kenzok8/openwrt-packages)
- [OpenAppFilter](https://github.com/destan19/OpenAppFilter)
- [EasyTier luci-app](https://github.com/EasyTier/luci-app-easytier)
- [TurboAcc](https://github.com/chenmozhijin/turboacc)
