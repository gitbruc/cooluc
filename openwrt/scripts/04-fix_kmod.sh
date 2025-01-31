#!/bin/bash -e

# Fix build for 6.12

# jool
curl -s $mirror/openwrt/patch/packages-patches/jool/Makefile > feeds/packages/net/jool/Makefile

# libpfring
rm -rf feeds/packages/libs/libpfring
mkdir -p feeds/packages/libs/libpfring/patches
curl -s $mirror/openwrt/patch/packages-patches/libpfring/Makefile > feeds/packages/libs/libpfring/Makefile
pushd feeds/packages/libs/libpfring/patches
  curl -Os $mirror/openwrt/patch/packages-patches/libpfring/patches/0001-fix-cross-compiling.patch
  curl -Os $mirror/openwrt/patch/packages-patches/libpfring/patches/100-fix-compilation-warning.patch
  curl -Os $mirror/openwrt/patch/packages-patches/libpfring/patches/900-fix-linux-6.6.patch
popd

# openvswitch
sed -i '/ovs_kmod_openvswitch_depends/a\\t\ \ +kmod-sched-act-sample \\' feeds/packages/net/openvswitch/Makefile

# telephony
pushd feeds/telephony
  # dahdi-linux
  rm -rf libs/dahdi-linux
  git clone https://$github/sbwml/feeds_telephony_libs_dahdi-linux libs/dahdi-linux
popd

# clang
if [ "$KERNEL_CLANG_LTO" = "y" ]; then
    # xtables-addons module
    rm -rf feeds/packages/net/xtables-addons
    git clone https://$github/sbwml/kmod_packages_net_xtables-addons feeds/packages/net/xtables-addons
    # netatop
    sed -i 's/$(MAKE)/$(KERNEL_MAKE)/g' feeds/packages/admin/netatop/Makefile
    curl -s $mirror/openwrt/patch/packages-patches/clang/netatop/900-fix-build-with-clang.patch > feeds/packages/admin/netatop/patches/900-fix-build-with-clang.patch
    # dmx_usb_module
    rm -rf feeds/packages/libs/dmx_usb_module
    git clone https://$gitea/sbwml/feeds_packages_libs_dmx_usb_module feeds/packages/libs/dmx_usb_module
    # macremapper
    curl -s $mirror/openwrt/patch/packages-patches/clang/macremapper/100-macremapper-fix-clang-build.patch | patch -p1
    # coova-chilli module
    rm -rf feeds/packages/net/coova-chilli
    git clone https://$github/sbwml/kmod_packages_net_coova-chilli feeds/packages/net/coova-chilli
fi
