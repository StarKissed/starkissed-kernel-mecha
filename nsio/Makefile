obj-m += nsio.o

# Provide path to your kernel source here
KERNEL_SOURCE = ../

# Edit as needed for architecture
ARCH            = arm
CROSS_COMPILE	?= /Volumes/android/android-toolchain-eabi/bin/arm-eabi-
CROSS_COMPILE	?= $(CONFIG_CROSS_COMPILE:"%"=%)

all:
	make -C $(KERNEL_SOURCE) M=$(PWD) modules
clean:
	make -C $(KERNEL_SOURCE) M=$(PWD) clean
