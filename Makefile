ifneq ($(KERNELRELEASE),)
# kbuild part of makefile
include Kbuild

else
# regular makefile
KERNEL_VERSION ?= $(shell uname -r)
KERNEL_SRC ?= /lib/modules/$(KERNEL_VERSION)/build

# This trick is only required for cs9 that still has dtb handled in
# Makefile.lib and won't handle includes and local out-of-tree overrides.
HOSTCC_FLAGS = -I $$PWD/include
ifneq ($(LLVM),)
HOSTCC	= clang $(HOSTCC_FLAGS)
else
HOSTCC	= gcc $(HOSTCC_FLAGS)
endif

.PHONY: default clean

default:
	$(MAKE) HOSTCC="$(HOSTCC) -I$$PWD/include" -C $(KERNEL_SRC) M=$$PWD

clean:
	$(MAKE) -C $(KERNEL_SRC) M=$$PWD clean

endif
