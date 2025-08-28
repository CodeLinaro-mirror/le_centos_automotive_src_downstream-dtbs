KERNEL_VERSION ?= $(shell uname -r)
KERNEL_SRC ?= /lib/modules/$(KERNEL_VERSION)/build
ARCH ?= $(shell uname -m | sed -e s/aarch64.*/arm64/)

ifneq ($(LLVM),)
HOSTCC = clang
else
HOSTCC = gcc
endif
DTC = $(KERNEL_SRC)/scripts/dtc/dtc
DTC_INCLUDE := include $(KERNEL_SRC)/include
DTC_FLAGS += -Wno-interrupt_provider -Wno-unit_address_vs_reg -Wno-unique_unit_address
dtc_cpp_flags = -nostdinc $(addprefix -I,$(dir $<) $(DTC_INCLUDE)) -undef -D__DTS__

%.dts.tmp: %.dts
	$(HOSTCC) -E $(dtc_cpp_flags) -x assembler-with-cpp -o $@ $<

%.dtb: %.dts.tmp
	$(DTC) -o $@ -b 0 $(addprefix -i,$(DTC_INCLUDE)) $(DTC_FLAGS) $<

dtstree := arch/$(ARCH)/boot/dts

ifeq ($(ARCH),arm64)
dtb-y += qcom/sa8775p-ride-fw-managed.dtb
dtb-y += qcom/sa8255p-ride.dtb
endif

PHONY += dtbs
dtbs:
	$(if $(dtb-y),$(MAKE) $(addprefix $(dtstree)/,$(dtb-y)))

INSTALL_PATH ?= /boot
INSTALL_DTBS_PATH ?= $(INSTALL_PATH)/dtbs/$(KERNEL_VERSION)

define gen_install_rules
$(INSTALL_DTBS_PATH)/$(1): $(addprefix $(dtstree)/,$(1))
	install -D -m 644 $$< $$@
endef
$(foreach d,$(dtb-y),$(eval $(call gen_install_rules,$(d))))

PHONY += dtbs_install
dtbs_install: $(addprefix $(INSTALL_DTBS_PATH)/,$(dtb-y))

PHONY += clean
clean:
	rm -rf $(addprefix $(dtstree)/,$(dtb-y)) \
		$(addsuffix .tmp, $(addprefix $(dtstree)/,$(dtb-y:.dtb=.dts)))
