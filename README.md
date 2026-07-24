# TWRP device tree for Redmi A5

## Thanks

[rtyutechstudio](https://github.com/rtyutechstudio) for patch drm

[Zyrexen](https://github.com/Zyrexen) for fstab and test twrp

## Build it yourself?

```shell
mkdir twrp && cd twrp
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1
repo sync
(patch drm (bootable/recovery/minuitwrp/graphics_drm.cpp))
git clone --depth=1 https://github.com/KSN2redawew/android_device_xiaomi_serenity-twrp device/xiaomi/serenity
```

```shell
source build/envsetup.sh
lunch twrp_serenity-eng
m vendorbootimage
```

If there is no error, vendor_boot.img will be found in `out/target/product/serenity/vendor_boot.img`

## Features

Works:

- [NO] ADB
- [X] Display
- [NO] Decryption
- [NO] Fasbootd 
- [X] Flashing
- [NO] MTP
- [NO] Sideload 
- [IDK] USB OTG
- [X] Touchscreen

## To use it:

```shell
fastboot flash vendor_boot_a vendor_boot.img
```
