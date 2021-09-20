#!/bin/bash

# 系统环境： 
# cat /etc/lsb_release
# DISTRIB_ID=Ubuntu
# DISTRIB_RELEASE=20.04
# DISTRIB_CODENAME=focal
# DISTRIB_DESCRIPTION="Ubuntu 20.04.3 LTS"

# uname -a
# Linux timscm 5.11.0-34-generic #36~20.04.1-Ubuntu SMP Fri Aug 27 08:06:32 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux

# 官网下载 VirtualBox
# https://www.virtualbox.org/wiki/Linux_Downloads
wget https://download.virtualbox.org/virtualbox/6.1.26/virtualbox-6.1_6.1.26-145957~Ubuntu~eoan_amd64.deb

# 安装软件
sudo apt install virtualbox-6.1_6.1.26-145957~Ubuntu~eoan_amd64.deb

# Virtualbox 界面创建虚拟机
# 选择：专家模式
# 名称： myos
# 文件夹：/home/tim/vm
# 类型：Other
# 版本：Other/Unknown (64-bit)
# 内存大小：1024MB
# 虚拟硬盘：不添加虚拟硬盘(D)
VBoxManage list vms
# "myos" {41f02582-a440-4727-9518-ad4985c3a4cb}

# 创建硬盘: 100MB
dd if=/dev/zero of=hd.img bs=512 count=204800

# 格式化硬盘，需要先排除已存在的 /dev/loop 文件
sudo losetup /dev/loop9 hd.img
sudo losetup -a 
# /dev/loop9: [2057]:5240 (/home/tim/vm/myos/hd.img)

sudo mkfs.ext4 -q /dev/loop9

# 安装 grub
# 注意：挂载 hd.img, 而不是挂载 /dev/loop9 
mkdir hdisk
sudo mount -o loop ./hd.img ./hdisk/
# ./hdisk/lost+found/
mkdir ./hdisk/boot/

sudo grub-install --boot-directory=./hdisk/boot/ --force --allow-floppy /dev/loop9
# Installing for i386-pc platform.
# grub-install: warning: File system `ext2' doesn't support embedding.
# grub-install: warning: Embedding is not possible.  GRUB can only be installed in this setup by using blocklists.  However, blocklists are UNRELIABLE and their use is discouraged..
# Installation finished. No error reported.

cat > grub.cfg <<EOF
menuentry 'myos' {
    insmod part_msdos
    insmod ext2
    set root='hd0,msdos1'
    multiboot2 /boot/myos.eki
    boot
}

set timeout_style=menu
if [ "${timeout}" = 0 ]; then
    set timeout=0
fi
EOF
sudo cp -f grub.cfg hdisk/boot/grub/

# 转换虚拟硬盘
VBoxManage convertfromraw ./hd.img --format VDI ./hd.vdi

# 命令行方式将硬盘添加到虚拟机中
# 完成下面的命令，在VirtualBox 界面中，存储出现了：控制器：SATA
VBoxManage storagectl myos --name "SATA" --add sata --controller IntelAhci --portcount 1

# 下面的命令用于修改了hd.vdi 之后，清除UUID值，初始时，会报错
VBoxManage closemedium disk ./hd.vdi

# 硬盘添加到硬盘控制器
VBoxManage storageattach myos --storagectl "SATA" --port 1 --device 0 --type hdd --medium ./hd.vdi

# 命令行启动虚拟机
VBoxManage startvm myos

# GNU GRUB version 2.04
# *myos
