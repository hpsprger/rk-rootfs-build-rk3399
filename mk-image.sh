#!/bin/bash -e

# 执行的命令 VERSION=debug ARCH=${ARCH} ./mk-rootfs-buster.sh  && ./mk-image.sh

# This will install Rockchip specified packages and hooks on the standard Debian rootfs and generate an ext4 format rootfs image at rootfs/linaro-rootfs.img .

TARGET_ROOTFS_DIR=./binary
MOUNTPOINT=./rootfs
ROOTFSIMAGE=linaro-rootfs.img

echo Making rootfs!

if [ -e ${ROOTFSIMAGE} ]; then 
	rm ${ROOTFSIMAGE}
fi
if [ -e ${MOUNTPOINT} ]; then 
	rm -r ${MOUNTPOINT}
fi

# Create directories
# /home/hpsp/rock_space/rockpi_4b/rockchip-bsp/rootfs/rootfs
mkdir ${MOUNTPOINT}
# 通过dd命令来创建一个镜像文件  linaro-rootfs.img  ==> /home/hpsp/rock_space/rockpi_4b/rockchip-bsp/rootfs/
dd if=/dev/zero of=${ROOTFSIMAGE} bs=1M count=0 seek=4000

finish() {
	sudo umount ${MOUNTPOINT} || true
	echo -e "\e[31m MAKE ROOTFS FAILED.\e[0m"
	exit -1
}

echo Format rootfs to ext4
# 格式化镜像文件 ==> linaro-rootfs.img
mkfs.ext4 ${ROOTFSIMAGE}

echo Mount rootfs to ${MOUNTPOINT}
# 将镜像文件 linaro-rootfs.img 挂到到  /home/hpsp/rock_space/rockpi_4b/rockchip-bsp/rootfs/rootfs
sudo mount  ${ROOTFSIMAGE} ${MOUNTPOINT}
trap finish ERR

echo Copy rootfs to ${MOUNTPOINT}
# 将 /home/hpsp/rock_space/rockpi_4b/rockchip-bsp/rootfs/binary【之前做的那个debian的文件系统】 拷贝到 已挂载的镜像文件中去  /home/hpsp/rock_space/rockpi_4b/rockchip-bsp/rootfs/rootfs
sudo cp -rfp ${TARGET_ROOTFS_DIR}/*  ${MOUNTPOINT}

echo Umount rootfs
sudo umount ${MOUNTPOINT}

echo Rootfs Image: ${ROOTFSIMAGE}

# e2fsck是检查ext2、ext3、ext4等文件系统的正确性
e2fsck -p -f ${ROOTFSIMAGE}
# resize2fs - ext2/ext3/ext4文件系统重定义大小工具
# man resize2fs ==> -M     Shrink the file system to minimize its size as much as possible, given the files stored in the file system.
resize2fs -M ${ROOTFSIMAGE}

# 到这里 rootfs目录下的 debian文件系统镜像就做好了  linaro-rootfs.img  ==> /home/hpsp/rock_space/rockpi_4b/rockchip-bsp/rootfs/ 
# 接下来再执行 build目录下的 mk-image.sh