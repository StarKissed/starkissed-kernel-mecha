#!/bin/sh

# Copyright (C) 2011 Twisted Playground

# This script is designed by Twisted Playground for use on MacOSX 10.7 but can be modified for other distributions of Mac and Linux

PROPER=`echo $2 | sed 's/\([a-z]\)\([a-zA-Z0-9]*\)/\u\1\2/g'`

HANDLE=TwistedZero
KERNELSPEC=/Volumes/android/mecha-ics-mr-3.0.16
KERNELREPO=/Users/TwistedZero/Public/Dropbox/TwistedServer/Playground/kernels
#TOOLCHAIN_PREFIX=/Volumes/android/android-toolchain-eabi/bin/arm-eabi-
TOOLCHAIN_PREFIX=/Volumes/android/android-tzb_ics4.0.1/prebuilt/darwin-x86/toolchain/arm-eabi-4.4.3/bin/arm-eabi-
GOOSERVER=loungekatt@upload.goo.im:public_html
PUNCHCARD=`date "+%m-%d-%Y_%H.%M"`

CPU_JOB_NUM=8

cp -R config/$2_config .config

if [ -e $KERNELSPEC/mkboot.aosp/boot.img ]; then
    rm -R $KERNELSPEC/mkboot.aosp/boot.img
fi
if [ -e $KERNELSPEC/mkboot.aosp/newramdisk.cpio.gz ]; then
    rm -R $KERNELSPEC/mkboot.aosp/newramdisk.cpio.gz
fi
if [ -e $KERNELSPEC/mkboot.aosp/zImage ]; then
    rm -R $KERNELSPEC/mkboot.aosp/zImage
fi

make clean -j$CPU_JOB_NUM

make -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PREFIX

# make nsio module here for now
cd nsio*
make CROSS_COMPILE=$TOOLCHAIN_PREFIX
cd ..

if [ -e arch/arm/boot/zImage ]; then

    cp .config arch/arm/configs/mecha_defconfig

if [ "$1" == "1" ]; then
    KERNELOUT=zip.aosp
else
    KERNELOUT=AnyKernel
fi

    if [ `find . -name "*.ko" | grep -c ko` > 0 ]; then

        find . -name "*.ko" | xargs ${TOOLCHAIN_PREFIX}strip --strip-unneeded

        if [ ! -d $KERNELOUT/system ]; then
            mkdir $KERNELOUT/system
        fi
        if [ ! -d $KERNELOUT/system/lib ]; then
            mkdir $KERNELOUT/system/lib
        fi
        if [ ! -d $KERNELOUT/system/lib/modules ]; then
            mkdir $KERNELOUT/system/lib/modules
        else
            rm -r $KERNELOUT/system/lib/modules
            mkdir $KERNELOUT/system/lib/modules
        fi

        for j in $(find . -name "*.ko"); do
            cp -R "${j}" $KERNELOUT/system/lib/modules
        done

    else

        if [ -e $KERNELOUT/system/lib ]; then
            rm -r $KERNELOUT/system/lib
        fi

    fi

    if [ "$1" == "1" ]; then

        zipfile=$HANDLE"_StarKissed_184Mhz-Full.zip"
        KENRELZIP="StarKissed-184Mhz_$PUNCHCARD-Full.zip"

        cp -R arch/arm/boot/zImage mkboot.aosp

        cd mkboot.aosp
        ./img.sh

        echo "building boot package"
        cp -R boot.img ../$KERNELOUT/kernel

        cd ../$KERNELOUT

    else

        zipfile=$HANDLE"_StarKissed_184Mhz-Core.zip"
        KENRELZIP="StarKissed-184Mhz_$PUNCHCARD-Core.zip"

        echo "building kernel package"
        cp -R arch/arm/boot/zImage $KERNELOUT/kernel

        cd $KERNELOUT

    fi

    rm *.zip
    zip -r $zipfile *
    cp -R $KERNELSPEC/$KERNELOUT/$zipfile $KERNELREPO/$zipfile

    if [ -e $KERNELREPO/$zipfile ]; then
        cp -R $KERNELREPO/$zipfile $KERNELREPO/gooserver/$KENRELZIP
        scp -P 2222 $KERNELREPO/gooserver/$KENRELZIP  $GOOSERVER/thunderbolt
        rm -R $KERNELREPO/gooserver/$KENRELZIP
    fi

fi

cd $KERNELSPEC
