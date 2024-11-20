# 自动打包镜像脚本

本脚本是为了将编译后的uboot、zImage、设备树和根文件系统打包为image文件，以便于将镜像烧录至SD卡中从而完成从SD卡启动linux
# 使用方法
1. 安装所需软件
   ```bash
   sudo apt-get install dosfstools dump parted kpartx
   ```
2. 克隆本仓库
   ```bash
   git clone https://github.com/sesame-max/imx6ull_auto_pack_image.git
   ```
3. cd 到该仓库
4. 复制 **uboot** 到本目录下 **source** 文件夹，复制 **zImage**、**设备树** 到本目录下 **source/boot** 文件夹，注意将命令中的文件位置替换成自己的文件所在位置。
   ```bash
   cp /ubootDir/u-boot.imx ./source
   cp /zImagedir/zImage ./source/boot
   cp /dtbDir/imx6ull-14x14-emmc-4.3-800x480-c.dtb ./source/boot
   ```
5. 使用自动打包脚本打包rootfs，将命令中的rootfs文件替换成自己的rootfs文件夹位置
   ```bash
   ./autoPack /rootfsDir
   ```
6. 生成镜像
   ```bash
   sudo ./autoMake ubootSize fatSize rootfsSize
   ```
   其中**ubootSize**、**fatSize**、**rootfsSize**分别为镜像中的uboot分区大小、内核和设备树分区大小、根文件系统分区大小，单位**MByte**。
   注意：分区大小要大于分区内的文件大小

   ```bash
   #镜像文件中uboot分区10M，fat分区500M，根文件系统分区500M
   sudo ./autoMake 10 500 500
   ```
7. 运行完成后在当前目录下会生成名为**imx6ull.img**的镜像

