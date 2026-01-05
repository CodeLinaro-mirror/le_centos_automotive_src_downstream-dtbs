ifneq ($(KERNELRELEASE),)
# kbuild part of makefile
include Kbuild

else
# regular makefile
KERNEL_VERSION ?= $(shell uname -r)
KERNEL_SRC ?= /lib/modules/$(KERNEL_VERSION)/build

ifneq ($(LLVM),)
HOSTCC	= clang
else
HOSTCC	= gcc
endif

.PHONY: default clean

default:
	$(MAKE) HOSTCC="$(HOSTCC) -I$$PWD/include" -C $(KERNEL_SRC) M=$$PWD

clean:
	$(MAKE) -C $(KERNEL_SRC) M=$$PWD clean

endif
