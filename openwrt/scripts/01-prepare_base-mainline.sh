#!/bin/bash -e

#################################################################

# autocore
git clone https://$github/sbwml/autocore-arm -b openwrt-25.12 package/system/autocore

# bpf-headers - 6.12
# sed -ri "s/(PKG_PATCHVER:=)[^\"]*/\16.12/" package/kernel/bpf-headers/Makefile

# x86_64 - target 6.12
#curl -s $mirror/openwrt/patch/openwrt-6.x/x86/64/config-6.12 > target/linux/x86/64/config-6.12
#curl -s $mirror/openwrt/patch/openwrt-6.x/x86/config-6.12 > target/linux/x86/config-6.12
#mkdir -p target/linux/x86/patches-6.12
#curl -s $mirror/openwrt/patch/openwrt-6.x/x86/patches-6.12/100-fix_cs5535_clockevt.patch > target/linux/x86/patches-6.12/100-fix_cs5535_clockevt.patch
#curl -s $mirror/openwrt/patch/openwrt-6.x/x86/patches-6.12/103-pcengines_apu6_platform.patch > target/linux/x86/patches-6.12/103-pcengines_apu6_platform.patch
# x86_64 - target
#sed -ri "s/(KERNEL_PATCHVER:=)[^\"]*/\16.12/" target/linux/x86/Makefile
#sed -i '/KERNEL_PATCHVER/a\KERNEL_TESTING_PATCHVER:=6.6' target/linux/x86/Makefile
#curl -s $mirror/openwrt/patch/openwrt-6.x/x86/base-files/etc/board.d/01_leds > target/linux/x86/base-files/etc/board.d/01_leds
#curl -s $mirror/openwrt/patch/openwrt-6.x/x86/base-files/etc/board.d/02_network > target/linux/x86/base-files/etc/board.d/02_network

# wireless-regdb
#curl -s $mirror/openwrt/patch/openwrt-6.x/500-world-regd-5GHz.patch > package/firmware/wireless-regdb/patches/500-world-regd-5GHz.patch

