#!/bin/sh

# Copyright (C) 2011 Twisted Playground

# This script is designed by Twisted Playground for use on MacOSX 10.7 but can be modified for other distributions of Mac and Linux

PROPER=`echo $2 | sed 's/\([a-z]\)\([a-zA-Z0-9]*\)/\u\1\2/g'`

HANDLE=TwistedZero
KERNELSPEC=/Volumes/android/mecha-ics-mr-3.0.16
KERNELREPO=/Users/TwistedZero/Public/Dropbox/TwistedServer/Playground/kernels
EXTRASREPO=/Volumes/android/Playground-Ext_Pack/optional/kernel
MECHAREPO=/Volumes/android/github-aosp_source/android_device_htc_mecha
ICSREPO=/Volumes/android/github-aosp_source/android_system_core
MSMREPO=/Volumes/android/github-aosp_source/android_device_htc_msm7x30-common
zipfile=$HANDLE"_leanKernel_184Mhz.zip"
#TOOLCHAIN_PREFIX=/Volumes/android/android-toolchain-eabi/bin/arm-eabi-
TOOLCHAIN_PREFIX=/Volumes/android/android-tzb_ics4.0.1/prebuilt/darwin-x86/toolchain/arm-eabi-4.4.3/bin/arm-eabi-

CPU_JOB_NUM=8

cp -R config/$2_config .config

make clean -j$CPU_JOB_NUM

make -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PREFIX

# make nsio module here for now
cd nsio*
make CROSS_COMPILE=$TOOLCHAIN_PREFIX
cd ..

if [ -e arch/arm/boot/zImage ]; then

cp .config arch/arm/configs/mecha_defconfig

if [ "$1" == "1" ]; then

cp -R $ICSREPO/rootdir/init.rc $KERNELSPEC/mkboot.aosp/boot.img-ramdisk
cp -R $ICSREPO/rootdir/ueventd.rc $KERNELSPEC/mkboot.aosp/boot.img-ramdisk
cp -R $MECHAREPO/kernel/init.mecha.rc $KERNELSPEC/mkboot.aosp/boot.img-ramdisk
cp -R $MECHAREPO/kernel/ueventd.mecha.rc $KERNELSPEC/mkboot.aosp/boot.img-ramdisk
cp -R $MSMREPO/init.htc7x30.usb.rc $KERNELSPEC/mkboot.aosp/boot.img-ramdisk

if [ `find . -name "*.ko" | grep -c ko` > 0 ]; then

find . -name "*.ko" | xargs ${TOOLCHAIN_PREFIX}strip --strip-unneeded

if [ ! -e $EXTRASREPO/system ]; then
mkdir $EXTRASREPO/system
fi
if [ ! -e $EXTRASREPO/system/lib ]; then
mkdir $EXTRASREPO/system/lib
fi
if [ ! -e $EXTRASREPO/system/lib/modules ]; then
mkdir $EXTRASREPO/system/lib/modules
else
rm -r $EXTRASREPO/system/lib/modules
mkdir $EXTRASREPO/system/lib/modules
fi

for j in $(find . -name "*.ko"); do
cp -R "${j}" $EXTRASREPO/system/lib/modules
done

else

if [ -e $EXTRASREPO/system/lib ]; then
rm -r $EXTRASREPO/system/lib
fi

fi

cp -R arch/arm/boot/zImage mkboot.aosp

cd mkboot.aosp
./img.sh

echo "updating extras package"
cp -R boot.img $EXTRASREPO

else

cp -R $ICSREPO/rootdir/init.rc $KERNELSPEC/mkboot.aosp/boot.img-ramdisk
cp -R $ICSREPO/rootdir/ueventd.rc $KERNELSPEC/mkboot.aosp/boot.img-ramdisk
cp -R $MECHAREPO/kernel/init.mecha.rc $KERNELSPEC/mkboot.aosp/boot.img-ramdisk
cp -R $MECHAREPO/kernel/ueventd.mecha.rc $KERNELSPEC/mkboot.aosp/boot.img-ramdisk
cp -R $MSMREPO/init.htc7x30.usb.rc $KERNELSPEC/mkboot.aosp/boot.img-ramdisk

if [ `find . -name "*.ko" | grep -c ko` > 0 ]; then

find . -name "*.ko" | xargs ${TOOLCHAIN_PREFIX}strip --strip-unneeded

if [ ! -e zip.aosp/system ]; then
mkdir zip.aosp/system
fi
if [ ! -e zip.aosp/system/lib ]; then
mkdir zip.aosp/system/lib
fi
if [ ! -e zip.aosp/system/lib/modules ]; then
mkdir zip.aosp/system/lib/modules
else
rm -r zip.aosp/system/lib/modules
mkdir zip.aosp/system/lib/modules
fi

for j in $(find . -name "*.ko"); do
cp -R "${j}" zip.aosp/system/lib/modules
done

else

if [ -e zip.aosp/system/lib ]; then
rm -r zip.aosp/system/lib
fi

fi

cp -R arch/arm/boot/zImage mkboot.aosp

cd mkboot.aosp
./img.sh

echo "building kernel package"
cp -R boot.img ../zip.aosp/kernel
cd ../zip.aosp
rm *.zip
zip -r $zipfile *
cp -R $KERNELSPEC/zip.aosp/$zipfile $KERNELREPO/$zipfile

fi

fi

cd $KERNELSPEC
