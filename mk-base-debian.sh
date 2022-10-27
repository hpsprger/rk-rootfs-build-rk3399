#!/bin/bash -e

# Building a base debian system by ubuntu-build-service from linaro
# 执行命令 RELEASE=buster TARGET=desktop ARCH=${ARCH} ./mk-base-debian.sh

if [ "$RELEASE" == "stretch" ]; then
	RELEASE='stretch'
elif [ "$RELEASE" == "buster" ]; then   #用这个分支
	RELEASE='buster'
else
    echo -e "\033[36m please input the os type,stretch or buster...... \033[0m"
fi

if [ "$ARCH" == "armhf" ]; then
	ARCH='armhf'
elif [ "$ARCH" == "arm64" ]; then  #用这个分支 ARCH='arm64'
	ARCH='arm64'
else
    echo -e "\033[36m please input the os type,armhf or arm64...... \033[0m"
fi

if [ ! $TARGET ]; then   #TARGET=desktop
	TARGET='desktop'
fi

if [ -e linaro-$RELEASE-alip-*.tar.gz ]; then
	rm linaro-$RELEASE-alip-*.tar.gz
fi

# cd  Y:\rock_space\rockpi_4b\rockchip-bsp\rootfs\ubuntu-build-service\buster-desktop-arm64
cd ubuntu-build-service/$RELEASE-$TARGET-$ARCH

echo -e "\033[36m Staring Download...... \033[0m"

# 直接在 ubuntu-build-service 下构建 -- clean
make clean

# 直接在 ubuntu-build-service 下构建 -- config
./configure

# 直接在 ubuntu-build-service 下构建 -- build
make

# This will bootstrap a Debian buster image, you will get a rootfs tarball named linaro-buster-alip-xxxx.tar.gz.
if [ -e linaro-$RELEASE-alip-*.tar.gz ]; then
	sudo chmod 0666 linaro-$RELEASE-alip-*.tar.gz
	# 目标文件mv到上两层 ==> Y:\rock_space\rockpi_4b\rockchip-bsp\rootfs
	mv linaro-$RELEASE-alip-*.tar.gz ../../
else
	echo -e "\e[31m Failed to run livebuild, please check your network connection. \e[0m"
fi
