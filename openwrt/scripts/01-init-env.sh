#!/bin/bash
# ============================================================
# 01-init-env.sh
# 初始化 OpenWrt 编译环境（Ubuntu 22.04）
# ============================================================
set -e

echo "==> 更新 apt 源并安装编译依赖"
sudo -E apt-get -qq update
sudo -E apt-get -qq install -y \
    ack antlr3 asciidoc autoconf automake autopoint \
    binutils binutils-aarch64-linux-gnu binutils-bpf \
    binutils-arm-linux-gnueabihf binutils-mips-linux-gnu \
    bison build-essential bzip2 ccache cmake cpio \
    curl device-tree-compiler dwarves ecj fastjar \
    flex gawk gcc-multilib g++-multilib gettext git gperf \
    haveged help2man intltool jq libc6-dev-i386 libelf-dev \
    libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev \
    libmpfr-dev libncurses5-dev libncursesw5-dev \
    libpython3-dev libreadline-dev libssl-dev libtool \
    lrzsz mkisofs msmtp nano ninja-build p7zip p7zip-full \
    patch pkgconf python3 python3-pyelftools python3-setuptools \
    qemu-utils rsync scons squashfs-tools subversion swig \
    texinfo uglifyjs unzip upx-ucl vim wget xmlto xxd zlib1g-dev \
    zstd

echo "==> 清理不需要的软件以释放空间"
sudo -E apt-get -qq purge -y azure-cli google-cloud-cli hhvm \
    google-chrome-stable firefox powershell mono-devel \
    libgl1-mesa-dri >/dev/null 2>&1 || true
sudo -E apt-get -qq autoremove --purge -y >/dev/null 2>&1 || true
sudo -E apt-get -qq clean

echo "==> 当前磁盘空间："
df -h /

echo "==> 环境初始化完成"
