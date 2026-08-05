# Pitch Black Recovery device tree for Redmi A5 (serenity)

Ported from [KSN2redawew/android_device_xiaomi_serenity-twrp](https://github.com/KSN2redawew/android_device_xiaomi_serenity-twrp) to the Pitch Black Recovery Project.

## Thanks

[rtyutechstudio](https://github.com/rtyutechstudio) for patch drm

[Zyrexen](https://github.com/Zyrexen) for fstab and test twrp

[Chillax](https://github.com/Chillax1143) Big Thanks (fixed full device tree and porting to PBRP)

[danilaim](https://github.com/danilaim) Tester

## Build it yourself

### 1. Download the PBRP source and device tree

```shell
mkdir -p ~/pbrp
cd ~/pbrp

repo init -u https://github.com/PitchBlackRecoveryProject/manifest_pb.git -b android-12.1
repo sync

git clone --depth=1 https://github.com/KSN2redawew/android_device_xiaomi_serenity-twrp device/xiaomi/serenity
```

All commands below must be run from the Android source root (`~/pbrp`), not
from inside `device/xiaomi/serenity`.

### 2. Install the recovery patches

The device tree contains one replacement source file and four patches:

- `graphics_drm.cpp` adds the DRM/minui changes required by this display.
- `libcxx_verbose_abort.patch` provides the newer libc++ ABI symbol required
  by the stock Android 15 KeyMint libraries.
- `vold_android15_keyblob.patch` enables KeyMint key-blob upgrades and fixes
  handling of a successful operation that did not return an upgraded blob.
- `vold_recovery_fscrypt_keyring.patch` creates the missing recovery fscrypt
  session keyring so that FBE keys are not incorrectly retried as wrapped keys.
- `pbrp_theme_xml.patch` repairs malformed XML in the upstream PBRP theme so
  Android's checked `PRODUCT_COPY_FILES` rules can package `/twres`.

Apply them in this order:

```shell
cd ~/pbrp

cp device/xiaomi/serenity/patch/graphics_drm.cpp bootable/recovery/minuitwrp/graphics_drm.cpp

git apply --check device/xiaomi/serenity/patch/libcxx_verbose_abort.patch
git apply device/xiaomi/serenity/patch/libcxx_verbose_abort.patch

git apply --check device/xiaomi/serenity/patch/vold_android15_keyblob.patch
git apply device/xiaomi/serenity/patch/vold_android15_keyblob.patch

git apply --check device/xiaomi/serenity/patch/vold_recovery_fscrypt_keyring.patch
git apply device/xiaomi/serenity/patch/vold_recovery_fscrypt_keyring.patch

git apply --check device/xiaomi/serenity/patch/pbrp_theme_xml.patch
git apply device/xiaomi/serenity/patch/pbrp_theme_xml.patch
```

Do not apply a patch twice. To check whether all three patches are already
installed, run:

```shell
cd ~/pbrp

git apply --reverse --check device/xiaomi/serenity/patch/libcxx_verbose_abort.patch &&
    echo "libcxx patch: applied"

git apply --reverse --check device/xiaomi/serenity/patch/vold_android15_keyblob.patch &&
    echo "Android 15 vold patch: applied"

git apply --reverse --check device/xiaomi/serenity/patch/vold_recovery_fscrypt_keyring.patch &&
    echo "fscrypt keyring patch: applied"

git apply --reverse --check device/xiaomi/serenity/patch/pbrp_theme_xml.patch &&
    echo "PBRP theme XML patch: applied"

cmp device/xiaomi/serenity/patch/graphics_drm.cpp \
    bootable/recovery/minuitwrp/graphics_drm.cpp &&
    echo "DRM source: installed"
```

If `git apply --check` fails but the matching `git apply --reverse --check`
succeeds, that patch is already installed. If both checks fail, the upstream
source changed and the patch must be rebased instead of being forced.

### 3. Build vendor_boot

```shell
cd ~/pbrp
source build/envsetup.sh
lunch pb_serenity-eng
m vendorbootimage
```

The resulting image is:

```text
out/target/product/serenity/vendor_boot.img
```

Before flashing, verify both the recovery executable and the PBRP theme.
The recovery executable must be a non-empty ARM64 ELF file; otherwise init
fails with `Exec format error` and the phone remains on the Mi logo:

```shell
test -s out/target/product/serenity/recovery/root/system/bin/recovery
file out/target/product/serenity/recovery/root/system/bin/recovery
test -f out/target/product/serenity/recovery/root/twres/splash.xml
test -f out/target/product/serenity/recovery/root/twres/ui.xml
test -f out/target/product/serenity/recovery/root/twres/languages/en.xml
```

The `file` command must report an `ELF 64-bit ... ARM aarch64` executable and
all four `test` commands must finish without an error. Missing `/twres` files
cause the GUI process to crash and restart.

If the recovery executable is empty after an interrupted build or a WSL
filesystem error, regenerate the installed files from the already-built
intermediates and repack `vendor_boot.img`:

```shell
cd ~/pbrp
source build/envsetup.sh
lunch pb_serenity-eng
m installclean
m vendorbootimage
```

Run the checks above again before flashing. `m installclean` does not perform a
full source rebuild; it removes stale installed output so it can be recreated
from valid intermediates.

An unofficial build may print a harmless `PB_DEVICES` warning while evaluating
`vendor/pb/config/common.mk`. The device is not registered in the official
`pb_devices.json`, but this warning does not break the build.

### Updating an existing source tree

After replacing `device/xiaomi/serenity` with a newer copy, install the DRM
source again and use the checks above before applying patches. `repo sync`
normally preserves local changes in `external/libcxx` and `system/vold`; do not
blindly reapply the patches after every sync.

## Features

Works:

- [X] ADB
- [X] Display
- [X] Decryption
- [X] Fastbootd
- [X] Flashing
- [X] MTP
- [X] Sideload
- [X] USB OTG
- [X] Touchscreen

## To use it:

```shell
fastboot getvar current-slot
# If the current slot is a:
fastboot flash vendor_boot_a vendor_boot.img
# If the current slot is b:
fastboot flash vendor_boot_b vendor_boot.img
```

Flash the partition matching the current slot. Flashing only `vendor_boot_a`
while the device is booting slot `b` leaves the old recovery image active.

## Verify a new build

After booting the newly flashed image, verify that the board-specific init file
and the crypto services are active:

```shell
adb shell getprop ro.hardware
adb shell getprop ro.boot.slot_suffix
adb shell ps -A | grep -E "keymint|gatekeeper|keystore2"
adb shell service check android.hardware.security.keymint.IKeyMintDevice/default
adb shell lshal | grep -i gatekeeper
```

`ro.hardware` must be `serenity`. Save fresh logs before debugging decryption:

```shell
adb shell logcat -b all -d > logcat-new.txt
adb shell dmesg > dmesg-new.txt
```
