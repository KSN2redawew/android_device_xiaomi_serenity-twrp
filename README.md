# Pitch Black Recovery device tree for Redmi A5 (serenity)

Ported from [KSN2redawew/android_device_xiaomi_serenity-twrp](https://github.com/KSN2redawew/android_device_xiaomi_serenity-twrp) to the Pitch Black Recovery Project.

## Thanks

[rtyutechstudio](https://github.com/rtyutechstudio) for patch drm

[Zyrexen](https://github.com/Zyrexen) for fstab and test twrp

[Chillax](https://github.com/Chillax1143) Big Thanks (fixed full device tree)

## Build it yourself?

```shell
mkdir pbrp && cd pbrp
repo init -u https://github.com/PitchBlackRecoveryProject/manifest_pb.git -b android-12.1
repo sync
(patch drm (bootable/recovery/minuitwrp/graphics_drm.cpp))
git clone --depth=1 https://github.com/KSN2redawew/android_device_xiaomi_serenity-twrp device/xiaomi/serenity
```

```shell
source build/envsetup.sh
lunch pb_serenity-eng
m vendorbootimage
```

If there is no error, vendor_boot.img will be found in `out/target/product/serenity/vendor_boot.img`

Note: an unofficial build prints a harmless `PB_DEVICES` warning during `vendor/pb/config/common.mk` evaluation (device is not registered in the official `pb_devices.json`), it does not break the build.

## Features

Works:

- [X] ADB
- [X] Display
- [NO] Decryption
- [IDK] Fasbootd
- [X] Flashing
- [X] MTP
- [X] Sideload
- [X] USB OTG
- [X] Touchscreen

## To use it:

```shell
fastboot flash vendor_boot_a vendor_boot.img
```
