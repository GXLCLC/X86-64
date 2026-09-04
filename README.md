# OpenWrt x86/64 云编译

基于 [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede) 的 OpenWrt x86/64 自动云编译仓库，通过 GitHub Actions 自动构建并发布 Release，开箱即用。

## ✨ 特性

- 仅编译 **x86/64** 平台（物理机 / 虚拟机均可）
- 自动拉取 lede 源码并合并常用插件源
- 配置文件化，增删插件只需改 `config/` 下文件
- 编译完成自动发布到 GitHub Release
- Release 页自动附带 **管理 IP、默认账号、插件清单、固件文件列表**

## 📁 目录结构

```
.
├── .github/workflows/
│   └── build-openwrt.yml      # GitHub Actions 编译工作流
├── config/
│   ├── x86-64.config          # x86/64 基础配置（平台+驱动+基础包）
│   └── custom.config          # 自定义插件配置（按需取消注释）
├── scripts/
│   ├── 01-init-env.sh         # 初始化编译环境（装依赖）
│   ├── 02-custom-feed.sh      # feeds 自定义处理（补丁/删冲突包）
│   ├── 03-custom-config.sh    # .config 自定义调整
│   └── 04-gen-release-info.sh # 生成 Release 发布页信息
├── feeds.conf.default         # 软件源配置（lede + 常用插件源）
└── README.md
```

## 🚀 使用方法

### 1. Fork 本仓库

点击右上角 **Fork**，复制到你自己的 GitHub 账号下。

### 2. 自定义插件

打开 [config/custom.config](config/custom.config)，把需要的插件前面的 `#` 去掉即可，例如启用 `passwall`：

```
# CONFIG_PACKAGE_luci-app-passwall=y        # 注释 = 不安装
CONFIG_PACKAGE_luci-app-passwall=y          # 取消注释 = 安装
```

如需更多插件，可按 `CONFIG_PACKAGE_luci-app-xxx=y` 的格式自行添加。

### 3. 添加/切换软件源

编辑 [feeds.conf.default](feeds.conf.default)，默认已启用：

- `coolsnowwolf` 官方源（packages / luci / routing / telephony）
- `kenzok8/openwrt-packages` + `kenzok8/small`（passwall、ssr-plus、bypass 等）

如需 `openclash`、`homeproxy`、`immortalwrt` 源等，取消对应行注释即可。

### 4. 触发编译

在你的仓库页面：

- **手动触发**：Actions → `Build OpenWrt (x86/64)` → `Run workflow`
- 可选参数：
  - `ssh`：填 `true` 可在编译前通过 SSH 连接到 Actions 调试（需配置 Telegram token）
  - `version`：指定 lede 版本 tag，留空则使用最新 master

编译大约需要 **2~4 小时**，取决于插件数量。

### 5. 下载固件

编译完成后进入仓库 **Releases** 页面，最新版本中包含：

- `openwrt-x86-64-generic-squashfs-combined-efi.img.gz` — EFI 引导通用镜像
- `...-combined.img.gz` — Legacy BIOS 引导镜像
- `.vmdk` / `.vdi` / `.vhdx` — 虚拟机镜像
- 以及 Release 正文里的 **管理 IP、插件清单**

## 🌐 默认管理信息

| 项目 | 值 |
| --- | --- |
| 管理地址 | `http://192.168.1.1` |
| 用户名 | `root` |
| 密码 | `password` |

> 首次登录后请立即修改密码。

## 🛠 常见问题

**Q：如何修改默认 IP？**
A：编辑 `scripts/03-custom-config.sh`，取消注释并修改 `192.168.1.1` 为你想要的地址。

**Q：如何添加补丁？**
A：在仓库根目录新建 `patches/` 文件夹放入 `.patch` 文件，并在 `scripts/02-custom-feed.sh` 中取消注释补丁应用代码。

**Q：编译失败怎么办？**
A：触发 workflow 时把 `ssh` 设为 `true`，通过 SSH 进入 Actions 环境手动排错。

## 📝 说明

本仓库仅供学习交流，固件由 GitHub Actions 自动编译，请勿用于非法用途。
