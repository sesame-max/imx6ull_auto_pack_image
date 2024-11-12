#!/bin/bash

#设置镜像大小 单位M 
#ubootSize：uboot分区大小 
#fatSize：存放zImage和dtf.dtb分区大小
#ext4Size：根文件系统rootfs分区大小
# ubootSize=10
# fatSize=500
# ext4Size=500

ubootSize=$1
fatSize=$2
ext4Size=$3

imageSize=`expr ${ubootSize} + ${fatSize} + 100 + ${ext4Size}`

echo "ubootSize is: ${ubootSize} M"
echo "fatSize is: ${fatSize} M"
echo "ext4Size is: ${ext4Size} M"
echo "imageSize is: ${imageSize} M"

#计算各分区位置
fatSatrt=`expr ${ubootSize} \* 1024`
fatEnd=`expr ${fatSatrt} + ${fatSize} \* 1024 - 1`
ext4Start=`expr ${fatEnd} + 100 \* 1024 + 1`

echo "ubootStart is: 0 sector"
echo "ubootEnd is:`expr ${ubootSize} \* 1024 - 1` sector"

echo "fatSatrt is: ${fatSatrt} sector"
echo "fatEnd is: ${fatEnd} sector"

echo "ext4Start is: ${ext4Start} sector"
echo "imageSize is: `expr ${imageSize} \* 1024` sector"

#创建image镜像

dd if=/dev/zero of=imx6ull.img bs=1024 count=`expr ${imageSize} \* 1024`
echo "imx6ull.img created!"

#对image镜像进行分区

sudo parted imx6ull.img --script -- mklabel msdos
sudo parted imx6ull.img --script -- mkpart primary fat32 ${fatSatrt}s ${fatEnd}s
sudo parted imx6ull.img --script -- mkpart primary ext4 ${ext4Start}s -1

#将镜像文件虚拟为块设备

dev=$(sudo losetup -f --show imx6ull.img)
echo "dev is: ${dev}"
sudo kpartx -va ${dev}

#格式化各分区
sudo mkfs.vfat /dev/mapper/${dev:5}p1	#建立文件系统 存放 kernel dtb
echo "fat part has created"
sudo mkfs.ext4 /dev/mapper/${dev:5}p2	#建立文件系统 存放 rootfs
echo "ext4 part has created"

#创建并挂载分区
mkdir boot root
sudo mount /dev/mapper/${dev:5}p1 ./boot/
sudo mount /dev/mapper/${dev:5}p2 ./root/

#烧录和复制对应文件
#烧录uboot
sudo dd if=./source/u-boot.imx of=${dev} bs=1024 seek=1 conv=fsync
##复制zImage和fdt.dtb
sudo cp ./source/zImage ./source/fdt.dtb ./boot/
#解压rootfs
sudo tar -xjvf ./source/rootfs.tar.bz2 -C ./root/


#取消挂载
sudo umount ./boot ./root
rm -r ./boot ./root
sudo kpartx -d ${dev}
sudo losetup -d ${dev}