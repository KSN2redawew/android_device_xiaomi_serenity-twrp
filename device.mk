#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := device/xiaomi/serenity

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=erofs \
    POSTINSTALL_OPTIONAL_system=true

# Boot control HAL
PRODUCT_PACKAGES += \
    android.hardware.boot@1.2-service \
    vendor.sprd.hardware.boot@1.2-service

# Health HAL
PRODUCT_PACKAGES += \
    android.hardware.health@2.0-impl \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-service

# Runtime dependency of the prebuilt Trusty Gatekeeper service.
PRODUCT_PACKAGES += \
    libgatekeeper

# First-stage init loads the stock list from /lib/modules/modules.load.recovery.
# Defining TW_LOAD_VENDOR_MODULES here would also inject the list into a C++
# compiler macro and duplicate the module-loading path.
 
# Boot control HAL
PRODUCT_PACKAGES += \
    android.hardware.boot@1.2-impl \
    android.hardware.boot@1.2-impl.recovery \
    vendor.sprd.hardware.boot@1.2-impl \
    vendor.sprd.hardware.boot@1.2-impl.recovery

PRODUCT_PACKAGES += \
    bootctrl.recovery \
    unisoc.bootctrl

PRODUCT_PACKAGES += \
    bootctrl.ums9230
    
ENABLE_VIRTUAL_AB := true
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)

PRODUCT_PACKAGES_DEBUG += \
    update_engine_client 

PRODUCT_PACKAGES += \
    otapreopt_script \
    cppreopts.sh \
    update_engine \
    update_verifier \
    update_engine_sideload

# Dynamic partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

PRODUCT_PACKAGES += \
    mkfs.erofs.recovery \
    dump.erofs.recovery \
    fsck.erofs.recovery

# VNDK
PRODUCT_TARGET_VNDK_VERSION := 32
PRODUCT_SHIPPING_API_LEVEL := 32

PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.0-impl-mock \
    fastbootd

# This helper is invoked directly by init.recovery.common.rc.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/system/bin/create_splloader_dual_slot_byname_path.sh:recovery/root/system/bin/create_splloader_dual_slot_byname_path.sh \
    $(LOCAL_PATH)/recovery/root/system/etc/vintf/manifest.xml:recovery/root/system/etc/vintf/manifest.xml

# PBRP's generated recovery ramdisk can omit /twres when recovery resources
# are moved into vendor_boot.  Without the base theme, splash.xml and ui.xml
# fail to load and the GUI later dereferences an empty page package.  Copy the
# selected theme explicitly so both the splash screen and main UI are present.
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,bootable/recovery/gui/theme/common/fonts,recovery/root/twres/fonts) \
    $(call find-copy-subdir-files,*,bootable/recovery/gui/theme/common/languages,recovery/root/twres/languages) \
    bootable/recovery/gui/theme/common/portrait.xml:recovery/root/twres/portrait.xml \
    $(call find-copy-subdir-files,*,bootable/recovery/gui/theme/portrait_hdpi,recovery/root/twres)
