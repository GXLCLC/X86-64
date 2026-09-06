# OpenWrt（LEDE）X86/64 云编译固件

基于 **Ubuntu 22.04** 的 GitHub Actions 全自动云编译仓库，拉取 [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede) 最新源码，**仅编译 X86/64 平台**固件。

编译过程**不使用 SSH 登录**、全程无人值守；固件**不包含任何代理插件**；编译完成后自动发布 GitHub Release，可直接下载 **IMG（.img.gz）** 镜像刷机使用。

---

## 一、固件特性

- 仅产出 **IMG（.img.gz）** 镜像（同时含传统 BIOS 与 EFI 引导），不产出 VHDX / VMDK / VDI / ISO
- **overlay（rootfs 分区）预留 2GiB 空间**（`CONFIG_TARGET_ROOTFS_PARTSIZE=2048`），可用于安装插件、存放配置
- 使用 SquashFS 文件系统，支持「恢复出厂设置」（重置 overlay）
- 默认 LAN IP：**192.168.1.1**，后台账号 **root** / 密码 **password**
- 默认主题：**Argon**（后台默认中文）
- 内置完整 **USB 驱动**与**有线/无线网卡驱动**（瑞昱 Realtek + 英特尔 Intel）
- 支持挂载 U 盘/移动硬盘（vFAT / exFAT / NTFS）

## 二、内置插件清单

> Release 发布页会根据当次编译产物自动生成「已安装插件」清单（每行一个，附版本号），以下为固件内置的主要插件：

- **luci-app-smartdns** —— SmartDNS 高性能 DNS 分流/加速（多上游并发查询，返回最快结果）
- **luci-app-ddnsto** —— DDNSTO 远程访问/内网穿透（易有云，通过 ddns.to 域名访问后台）
- **luci-app-adguardhome** —— AdGuardHome 全网广告/追踪域名拦截
- **luci-app-oaf** —— OFA 应用过滤（OpenAppFilter，基于 DPI 的应用识别与过滤，可禁游戏/视频等）
- **luci-app-turboacc** —— Turbo ACC 网络加速（flow offloading 流量分载 + BBR 拥塞控制）
- **luci-app-mwan3** —— mwan3 多 WAN 负载均衡/策略分流（多线拨号、链路冗余）
- **luci-app-nlbwmon** —— 带宽监控（按设备/时间统计流量）
- **luci-app-easytier** —— EasyTier 去中心化虚拟组网/内网穿透（带 Web 配置界面）
- **luci-theme-argon** —— Argon 主题（已设为默认主题）

> 说明：SmartDNS / AdGuardHome / Turbo ACC / mwan3 / nlbwmon 直接来自 LEDE 自带 feeds；
> DDNSTO 来自 LinkEase 官方 feed；Argon 主题、OFA、EasyTier 由 `scripts/diy-part1.sh` 自动拉取源码。

## 三、驱动支持

### USB 驱动

- USB 2.0 / 3.0 主控（OHCI/UHCI/EHCI/XHCI）
- USB 存储：U 盘、移动硬盘、UAS 高速存储
- USB 有线网卡：ASIX（AX88179 等）、瑞昱 RTL8152/8153/8156、Aquantia AQC111（2.5G/5G）
- USB 4G/5G 模组：CDC-Ether / CDC-NCM / RNDIS（含手机 USB 共享网络）
- USB 键盘鼠标、USB 声卡

### 有线网卡驱动

- **英特尔 Intel**：e1000 / e1000e（I219/I210/I350）、igb（I210/I211/I350）、igc（I225/I226 2.5G）、ixgbe（82599/X520/X540/X550 万兆）、i40e（X710/XL710）、iavf
- **瑞昱 Realtek**：r8169（通用）、r8168（官方千兆）、r8125-rss（RTL8125 2.5G）、r8126-rss（RTL8126 5G）
- **英特尔无线**：iwlwifi 驱动 + 固件（笔记本/迷你主机自带 WiFi）

## 四、固件版本信息

- **源码**：coolsnowwolf/lede master 分支最新代码（每周五自动编译一次）
- **内核版本**：跟随 LEDE master（当前为 Linux 6.12 系列），每次 Release 页面会标注当次实际内核版本
- **固件版本/插件版本**：以 Release 发布页自动生成的清单为准（从编译产物 `.manifest` 提取，保证与实际固件完全一致）

## 五、仓库目录结构

```
openwrt-build/
├── .github/
│   └── workflows/
│       └── build-openwrt.yml   # GitHub Actions 工作流（核心，每步含中文注释）
│
├── config/
│   └── x86-64.config           # X86/64 编译配置种子文件（可自行增删插件）
│
├── files/                      # 自定义文件，编译时原样覆盖进固件
│   └── etc/
│       ├── config/             # 自定义默认配置文件
│       └── uci-defaults/
│           └── 99-custom-settings  # 首启脚本：root密码/LAN IP/中文/Argon主题
│
├── scripts/
│   ├── diy-part1.sh            # feeds 更新前：添加 DDNSTO 源、拉取第三方插件
│   └── diy-part2.sh            # feeds 安装后：替换默认主题为 Argon 等
│
├── patches/                    # 自定义补丁目录（可选，放 .patch 文件）
│
├── .gitignore
└── README.md
```

## 六、如何使用

### 1. 直接下载固件（推荐普通用户）

1. 进入本仓库的 **[Releases](../../releases)** 页面；
2. 下载最新 Release 中的 `.img.gz` 镜像文件（与 `sha256sums.txt` 校验文件）；
3. 刷机步骤见下方「刷机说明」。

> Release 页面包含：固件版本、内核版本、LAN IP、后台账号密码、镜像格式说明，
> 以及**每行一个**的已安装插件清单（含版本号）。

### 2. 自己触发云编译（推荐自定义用户）

1. Fork 本仓库到你的 GitHub 账号；
2. 进入仓库 **Actions** 页面 → 左侧选择「编译 LEDE X86-64 固件」→ 点击 **Run workflow**；
3. 等待约 1~3 小时编译完成，固件会自动发布到你仓库的 Releases 页面；
4. 此外每周五（UTC 16:25）会自动定时编译一次；修改 `config/`、`scripts/` 等文件推送后也会自动触发。

### 3. 自定义插件 / 配置

编辑 [`config/x86-64.config`](config/x86-64.config) 种子文件：

- 增加插件：添加一行 `CONFIG_PACKAGE_插件名=y`（依赖项由 `make defconfig` 自动补全）；
- 去掉插件：删除对应行，或改为 `# CONFIG_PACKAGE_插件名 is not set`；
- 修改 overlay 大小：调整 `CONFIG_TARGET_ROOTFS_PARTSIZE=` 的值（单位 MiB，2048 = 2GiB）；
- 修改默认 IP / 密码：编辑 [`files/etc/uci-defaults/99-custom-settings`](files/etc/uci-defaults/99-custom-settings)，
  同时同步修改工作流 `env` 中的 `LAN_IP` / `LOGIN_PASS`（保证 Release 页面说明一致）。

提交后在 Actions 页面手动触发编译即可。

## 七、刷机说明

1. 下载 `.img.gz` 后解压得到 `.img`（balenaEtcher 等工具也可直接识别 `.gz`）；
2. **UEFI 启动**的机器选择文件名带 **combined-efi** 的镜像；**传统 BIOS** 选择 **combined** 镜像；
3. 使用 balenaEtcher / Rufus / physdiskwrite 等工具将 IMG 写入硬盘、电子盘或 CF 卡；
4. 刷机后网线接 **LAN 口**，浏览器访问 `http://192.168.1.1`；
5. 使用账号 `root` / 密码 `password` 登录，**首次登录后请立即在「系统 - 管理权」修改默认密码**。

## 八、注意事项

- 本固件**不包含任何代理插件**（helloworld / SSR-Plus / Passwall 等 feed 已在编译前移除）；
- 编译流程**不接入 SSH/tmate 调试**，全自动完成；
- 仅适用于 X86/64 架构（64 位软路由、迷你主机、虚拟机）；
- 虚拟机使用时：请自行用 IMG 转换，或直接把 IMG 挂载为虚拟磁盘（本仓库不产出 VMDK/VHDX）。
