#!/bin/bash -e

#################################################################

# autocore
git clone https://$github/sbwml/autocore-arm -b openwrt-25.12 package/system/autocore

# kernel modules
rm -rf package/kernel/linux
git checkout package/kernel/linux
pushd package/kernel/linux/modules
    rm -f [a-z]*.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/block.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/bluetooth.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/can.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/crypto.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/firewire.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/fs.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/gpio.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/hwmon.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/i2c.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/iio.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/input.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/leds.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/lib.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/multiplexer.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/netdevices.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/netfilter.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/netsupport.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/nls.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/other.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/pcmcia.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/rtc.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/sound.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/spi.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/usb.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/video.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/virt.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/w1.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/wpan.mk
popd

# wireless-regdb
curl -s $mirror/openwrt/patch/openwrt-6.x/500-world-regd-5GHz.patch > package/firmware/wireless-regdb/patches/500-world-regd-5GHz.patch
