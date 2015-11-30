LOCAL_PATH := $(call my-dir)

## Don't change anything under here. The variables are named A11_whatever
## on purpose, to avoid conflicts with similarly named variables at other
## parts of the build environment

## Imported from the original makefile...
KERNEL_CONFIG := $(KERNEL_OUT)/.config
A11_DTS_NAMES := msm8926

A11_DTS_FILES = $(wildcard $(TOP)/$(TARGET_KERNEL_SOURCE)/arch/arm/boot/dts/msm8926-a11*.dts)
A11_DTS_FILE = $(lastword $(subst /, ,$(1)))
DTB_FILE = $(addprefix $(KERNEL_OUT)/arch/arm/boot/,$(patsubst %.dts,%.dtb,$(call A11_DTS_FILE,$(1))))
ZIMG_FILE = $(addprefix $(KERNEL_OUT)/arch/arm/boot/,$(patsubst %.dts,%-zImage,$(call A11_DTS_FILE,$(1))))
KERNEL_ZIMG = $(KERNEL_OUT)/arch/arm/boot/zImage
DTC = $(KERNEL_OUT)/scripts/dtc/dtc
DTBTAGNAME := "htc,project-id = <"

define append-a11-dtb
mkdir -p $(KERNEL_OUT)/arch/arm/boot;\
$(foreach A11_DTS_NAME, $(A11_DTS_NAMES), \
   $(foreach d, $(A11_DTS_FILES), \
      $(DTC) -p 1024 -O dtb -o $(call DTB_FILE,$(d)) $(d); \
      cat $(KERNEL_ZIMG) $(call DTB_FILE,$(d)) > $(call ZIMG_FILE,$(d));))
endef


## Build and run dtbtool
#DTBTOOL := $(HOST_OUT_EXECUTABLES)/dtbToolCM$(HOST_EXECUTABLE_SUFFIX)
INSTALLED_DTIMAGE_TARGET := $(PRODUCT_OUT)/dtb
PREBUILT_DTIMAGE := device/htc/a11/dtb

#$(INSTALLED_DTIMAGE_TARGET): $(DTBTOOL) $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr $(INSTALLED_KERNEL_TARGET)
#	@echo -e ${CL_CYN}"Start DT image: $@"${CL_RST}
#	$(call append-a11-dtb)
#	$(call pretty,"Target dt image: $(INSTALLED_DTIMAGE_TARGET)")
#	$(DTBTOOL) -o $(INSTALLED_DTIMAGE_TARGET) -s $(BOARD_KERNEL_PAGESIZE) -d $(DTBTAGNAME) -p $(KERNEL_OUT)/scripts/dtc/ $(KERNEL_OUT)/arch/arm/boot/
#	@echo -e ${CL_CYN}"Made DT image: $@"${CL_RST}


## Overload bootimg generation: Same as the original, + --dt arg
$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES) $(PREBUILT_DTIMAGE)
	$(call pretty,"Target boot image: $@")
	$(hide) $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --dt $(PREBUILT_DTIMAGE) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_BOOTIMAGE_PARTITION_SIZE),raw)
	@echo -e ${CL_CYN}"Made boot image: $@"${CL_RST}

## Overload recoveryimg generation: Same as the original, + --dt arg
$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) $(PREBUILT_DTIMAGE) \
		$(recovery_ramdisk) \
		$(recovery_kernel)
	$(call build-recoveryimage-target, $@)
	$(hide) $(MKBOOTIMG) $(INTERNAL_RECOVERYIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --dt $(PREBUILT_DTIMAGE) --output $@

