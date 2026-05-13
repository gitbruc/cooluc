#!/bin/bash -e

# Fix build for 6.12

### BROKEN
sed -i 's/^\([[:space:]]*DEPENDS:=.*\)$/\1 @BROKEN/' package/kernel/rtl8812au-ct/Makefile

# openvswitch
sed -i '/ovs_kmod_openvswitch_depends/a\\t\ \ +kmod-sched-act-sample \\' feeds/packages/net/openvswitch/Makefile

# clang
if [ "$KERNEL_CLANG_LTO" = "y" ]; then
    # xtables-addons module
    rm -rf feeds/packages/net/xtables-addons
    git clone https://$github/gitbruc/kmod_packages_net_xtables-addons feeds/packages/net/xtables-addons -b openwrt-25.12
    # netatop
    sed -i 's/$(MAKE)/$(KERNEL_MAKE)/g' feeds/packages/admin/netatop/Makefile
    curl -s $mirror/openwrt/patch/packages-patches/clang/netatop/900-fix-build-with-clang.patch > feeds/packages/admin/netatop/patches/900-fix-build-with-clang.patch
    # dmx_usb_module
    rm -rf feeds/packages/libs/dmx_usb_module
    git clone https://github.com/gitbruc/feeds_packages_libs_dmx_usb_module feeds/packages/libs/dmx_usb_module
    # macremapper
    curl -s $mirror/openwrt/patch/packages-patches/clang/macremapper/100-macremapper-fix-clang-build.patch | patch -p1
    # coova-chilli module
    rm -rf feeds/packages/net/coova-chilli
    git clone https://$github/gitbruc/kmod_packages_net_coova-chilli feeds/packages/net/coova-chilli
fi


