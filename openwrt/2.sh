#!/bin/bash -e
export RED_COLOR='\e[1;31m'
export GREEN_COLOR='\e[1;32m'
export YELLOW_COLOR='\e[1;33m'
export BLUE_COLOR='\e[1;34m'
export PINK_COLOR='\e[1;35m'
export SHAN='\e[1;33;5m'
export RES='\e[0m'

GROUP=
group() {
    endgroup
    echo "::group::  $1"
    GROUP=1
}
endgroup() {
    if [ -n "$GROUP" ]; then
        echo "::endgroup::"
    fi
    GROUP=
}

#####################################
#  NanoPi R4S OpenWrt Build Script  #
#####################################

# IP Location
ip_info=`curl -sk https://ip.cooluc.com`;
[ -n "$ip_info" ] && export isCN=`echo $ip_info | grep -Po 'country_code\":"\K[^"]+'` || export isCN=US

# script url
if [ "$isCN" = "CN" ]; then
    export mirror=https://raw.githubusercontent.com/gitbruc/cooluc/new
else
    export mirror=https://raw.githubusercontent.com/gitbruc/cooluc/new
fi

# github actions - caddy server
if [ "$(whoami)" = "runner" ] && [ -z "$git_password" ]; then
    export mirror=http://127.0.0.1:8080
fi

# private gitea
export gitea=git.cooluc.com

# github mirror
if [ "$isCN" = "CN" ]; then
    export github="github.com"
else
    export github="github.com"
fi

# Check root
if [ "$(id -u)" = "0" ]; then
    echo -e "${RED_COLOR}Building with root user is not supported.${RES}"
    exit 1
fi

# Start time
starttime=`date +'%Y-%m-%d %H:%M:%S'`
CURRENT_DATE=$(date +%s)

# Cpus
cores=`expr $(nproc --all) + 1`

# $CURL_BAR
if curl --help | grep progress-bar >/dev/null 2>&1; then
    CURL_BAR="--progress-bar";
fi

if [ -z "$1" ] || [ "$2" != "nanopi-r4s" -a "$2" != "nanopi-r5s" -a "$2" != "x86_64" -a "$2" != "netgear_r8500" -a "$2" != "armv8" ]; then
    echo -e "\n${RED_COLOR}Building type not specified.${RES}\n"
    echo -e "Usage:\n"
    echo -e "nanopi-r4s releases: ${GREEN_COLOR}bash build.sh rc2 nanopi-r4s${RES}"
    echo -e "nanopi-r4s snapshots: ${GREEN_COLOR}bash build.sh dev nanopi-r4s${RES}"
    echo -e "nanopi-r5s releases: ${GREEN_COLOR}bash build.sh rc2 nanopi-r5s${RES}"
    echo -e "nanopi-r5s snapshots: ${GREEN_COLOR}bash build.sh dev nanopi-r5s${RES}"
    echo -e "x86_64 releases: ${GREEN_COLOR}bash build.sh rc2 x86_64${RES}"
    echo -e "x86_64 snapshots: ${GREEN_COLOR}bash build.sh dev x86_64${RES}"
    echo -e "netgear-r8500 releases: ${GREEN_COLOR}bash build.sh rc2 netgear_r8500${RES}"
    echo -e "netgear-r8500 snapshots: ${GREEN_COLOR}bash build.sh dev netgear_r8500${RES}"
    echo -e "armsr-armv8 releases: ${GREEN_COLOR}bash build.sh rc2 armv8${RES}"
    echo -e "armsr-armv8 snapshots: ${GREEN_COLOR}bash build.sh dev armv8${RES}\n"
    exit 1
fi

# Source branch
if [ "$1" = "dev" ]; then
    export branch=openwrt-24.10
    export version=dev
elif [ "$1" = "rc2" ]; then
    latest_release="v$(curl -s $mirror/tags/v24)"
    export branch=$latest_release
    export version=rc2
fi

# lan
[ -n "$LAN" ] && export LAN=$LAN || export LAN=10.0.0.1

# platform
[ "$2" = "armv8" ] && export platform="armv8" toolchain_arch="aarch64_generic"
[ "$2" = "nanopi-r4s" ] && export platform="rk3399" toolchain_arch="aarch64_generic"
[ "$2" = "nanopi-r5s" ] && export platform="rk3568" toolchain_arch="aarch64_generic"
[ "$2" = "netgear_r8500" ] && export platform="bcm53xx" toolchain_arch="arm_cortex-a9"
[ "$2" = "x86_64" ] && export platform="x86_64" toolchain_arch="x86_64"

# gcc14 & 15
if [ "$USE_GCC13" = y ]; then
    export USE_GCC13=y gcc_version=13
elif [ "$USE_GCC14" = y ]; then
    export USE_GCC14=y gcc_version=14
elif [ "$USE_GCC15" = y ]; then
    export USE_GCC15=y gcc_version=15
else
    export USE_GCC13=y gcc_version=13
fi
[ "$ENABLE_MOLD" = y ] && export ENABLE_MOLD=y

# build.sh flags
export \
    ENABLE_BPF=$ENABLE_BPF \
    ENABLE_DPDK=$ENABLE_DPDK \
    ENABLE_GLIBC=$ENABLE_GLIBC \
    ENABLE_LRNG=$ENABLE_LRNG \
    KERNEL_CLANG_LTO=$KERNEL_CLANG_LTO

# print version
echo -e "\r\n${GREEN_COLOR}Building $branch${RES}\r\n"
if [ "$platform" = "x86_64" ]; then
    echo -e "${GREEN_COLOR}Model: x86_64${RES}"
elif [ "$platform" = "armv8" ]; then
    echo -e "${GREEN_COLOR}Model: armsr/armv8${RES}"
    [ "$1" = "rc2" ] && model="armv8"
elif [ "$platform" = "bcm53xx" ]; then
    echo -e "${GREEN_COLOR}Model: netgear_r8500${RES}"
    [ "$LAN" = "10.0.0.1" ] && export LAN="192.168.1.1"
elif [ "$platform" = "rk3568" ]; then
    echo -e "${GREEN_COLOR}Model: nanopi-r5s/r5c${RES}"
    [ "$1" = "rc2" ] && model="nanopi-r5s"
else
    echo -e "${GREEN_COLOR}Model: nanopi-r4s${RES}"
    [ "$1" = "rc2" ] && model="nanopi-r4s"
fi
get_kernel_version=$(curl -s $mirror/tags/kernel-6.12)
kmod_hash=$(echo -e "$get_kernel_version" | awk -F'HASH-' '{print $2}' | awk '{print $1}' | tail -1 | md5sum | awk '{print $1}')
kmodpkg_name=$(echo $(echo -e "$get_kernel_version" | awk -F'HASH-' '{print $2}' | awk '{print $1}')~$(echo $kmod_hash)-r1)
echo -e "${GREEN_COLOR}Kernel: $kmodpkg_name ${RES}"

echo -e "${GREEN_COLOR}Date: $CURRENT_DATE${RES}\r\n"
echo -e "${GREEN_COLOR}GCC VERSION: $gcc_version${RES}"
[ -n "$LAN" ] && echo -e "${GREEN_COLOR}LAN: $LAN${RES}" || echo -e "${GREEN_COLOR}LAN: 10.0.0.1${RES}"
[ "$ENABLE_GLIBC" = "y" ] && echo -e "${GREEN_COLOR}Standard C Library:${RES} ${BLUE_COLOR}glibc${RES}" || echo -e "${GREEN_COLOR}Standard C Library:${RES} ${BLUE_COLOR}musl${RES}"
[ "$ENABLE_OTA" = "y" ] && echo -e "${GREEN_COLOR}ENABLE_OTA: true${RES}" || echo -e "${GREEN_COLOR}ENABLE_OTA:${RES} ${YELLOW_COLOR}false${RES}"
[ "$ENABLE_DPDK" = "y" ] && echo -e "${GREEN_COLOR}ENABLE_DPDK: true${RES}" || echo -e "${GREEN_COLOR}ENABLE_DPDK:${RES} ${YELLOW_COLOR}false${RES}"
[ "$ENABLE_MOLD" = "y" ] && echo -e "${GREEN_COLOR}ENABLE_MOLD: true${RES}" || echo -e "${GREEN_COLOR}ENABLE_MOLD:${RES} ${YELLOW_COLOR}false${RES}"
[ "$ENABLE_BPF" = "y" ] && echo -e "${GREEN_COLOR}ENABLE_BPF: true${RES}" || echo -e "${GREEN_COLOR}ENABLE_BPF:${RES} ${RED_COLOR}false${RES}"
[ "$ENABLE_LTO" = "y" ] && echo -e "${GREEN_COLOR}ENABLE_LTO: true${RES}" || echo -e "${GREEN_COLOR}ENABLE_LTO:${RES} ${RED_COLOR}false${RES}"
[ "$ENABLE_LRNG" = "y" ] && echo -e "${GREEN_COLOR}ENABLE_LRNG: true${RES}" || echo -e "${GREEN_COLOR}ENABLE_LRNG:${RES} ${RED_COLOR}false${RES}"
[ "$ENABLE_LOCAL_KMOD" = "y" ] && echo -e "${GREEN_COLOR}ENABLE_LOCAL_KMOD: true${RES}" || echo -e "${GREEN_COLOR}ENABLE_LOCAL_KMOD: false${RES}"
[ "$BUILD_FAST" = "y" ] && echo -e "${GREEN_COLOR}BUILD_FAST: true${RES}" || echo -e "${GREEN_COLOR}BUILD_FAST:${RES} ${YELLOW_COLOR}false${RES}"
[ "$ENABLE_CCACHE" = "y" ] && echo -e "${GREEN_COLOR}ENABLE_CCACHE: true${RES}" || echo -e "${GREEN_COLOR}ENABLE_CCACHE:${RES} ${YELLOW_COLOR}false${RES}"
[ "$MINIMAL_BUILD" = "y" ] && echo -e "${GREEN_COLOR}MINIMAL_BUILD: true${RES}" || echo -e "${GREEN_COLOR}MINIMAL_BUILD: false${RES}"
[ "$KERNEL_CLANG_LTO" = "y" ] && echo -e "${GREEN_COLOR}KERNEL_CLANG_LTO: true${RES}\r\n" || echo -e "${GREEN_COLOR}KERNEL_CLANG_LTO:${RES} ${YELLOW_COLOR}false${RES}\r\n"

# Compile
if [ "$BUILD_TOOLCHAIN" = "y" ]; then
    echo -e "\r\n${GREEN_COLOR}Building Toolchain ...${RES}\r\n"
    make -j$cores toolchain/compile || make -j$cores toolchain/compile V=s || exit 1
    mkdir -p toolchain-cache
    [ "$ENABLE_GLIBC" = "y" ] && LIBC=glibc || LIBC=musl
    tar -I "zstd -19 -T$(nproc --all)" -cf toolchain-cache/toolchain_${LIBC}_${toolchain_arch}_gcc-${gcc_version}${tools_suffix}.tar.zst ./{build_dir,dl,staging_dir,tmp}
    echo -e "\n${GREEN_COLOR} Build success! ${RES}"
    exit 0
else
    echo -e "\r\n${GREEN_COLOR}Building OpenWrt ...${RES}\r\n"
    sed -i "/BUILD_DATE/d" package/base-files/files/usr/lib/os-release
    sed -i "/BUILD_ID/aBUILD_DATE=\"$CURRENT_DATE\"" package/base-files/files/usr/lib/os-release
    make -j$(nproc) V=w IGNORE_ERRORS="n m"
    make package/network/utils/xdp-tools V=s || true
fi

# Compile time
endtime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);
SEC=$((end_seconds-start_seconds));

if [ -f bin/targets/*/*/sha256sums ]; then
    echo -e "${GREEN_COLOR} Build success! ${RES}"
    echo -e " Build time: $(( SEC / 3600 ))h,$(( (SEC % 3600) / 60 ))m,$(( (SEC % 3600) % 60 ))s"
else
    echo -e "\n${RED_COLOR} Build error... ${RES}"
    echo -e " Build time: $(( SEC / 3600 ))h,$(( (SEC % 3600) / 60 ))m,$(( (SEC % 3600) % 60 ))s"
    echo
    exit 1
fi

if [ "$platform" = "x86_64" ]; then
    if [ "$NO_KMOD" != "y" ]; then
        cp -a bin/targets/x86/*/packages $kmodpkg_name
        rm -f $kmodpkg_name/Packages*
        cp -a bin/packages/x86_64/base/rtl88*a-firmware*.ipk $kmodpkg_name/
        cp -a bin/packages/x86_64/base/natflow*.ipk $kmodpkg_name/
        [ "$ENABLE_DPDK" = "y" ] && {
            cp -a bin/packages/x86_64/base/*dpdk*.ipk $kmodpkg_name/ || true
            cp -a bin/packages/x86_64/base/*numa*.ipk $kmodpkg_name/ || true
        }
        bash kmod-sign $kmodpkg_name
        tar zcf x86_64-$kmodpkg_name.tar.gz $kmodpkg_name
        rm -rf $kmodpkg_name
    fi
    # OTA json
    if [ "$1" = "rc2" ]; then
        mkdir -p ota
        if [ "$MINIMAL_BUILD" = "y" ]; then
            OTA_URL="https://x86.cooluc.com/d/minimal/openwrt-24.10"
        else
            OTA_URL="https://github.com/sbwml/builder/releases/download"
        fi
        VERSION=$(sed 's/v//g' version.txt)
        SHA256=$(sha256sum bin/targets/x86/64*/*-generic-squashfs-combined-efi.img.gz | awk '{print $1}')
        cat > ota/fw.json <<EOF
{
  "x86_64": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256",
      "url": "$OTA_URL/v$VERSION/openwrt-$VERSION-x86-64-generic-squashfs-combined-efi.img.gz"
    }
  ]
}
EOF
    fi
    # Backup download cache
    if [ "$isCN" = "CN" ] && [ "$1" = "rc2" ]; then
        rm -rf dl/geo* dl/go-mod-cache
        tar cf ../dl.gz dl
    fi
    exit 0
elif [ "$platform" = "armv8" ]; then
    if [ "$NO_KMOD" != "y" ]; then
        cp -a bin/targets/armsr/armv8*/packages $kmodpkg_name
        rm -f $kmodpkg_name/Packages*
        cp -a bin/packages/aarch64_generic/base/rtl88*a-firmware*.ipk $kmodpkg_name/
        cp -a bin/packages/aarch64_generic/base/natflow*.ipk $kmodpkg_name/
        [ "$ENABLE_DPDK" = "y" ] && {
            cp -a bin/packages/aarch64_generic/base/*dpdk*.ipk $kmodpkg_name/ || true
            cp -a bin/packages/aarch64_generic/base/*numa*.ipk $kmodpkg_name/ || true
        }
        bash kmod-sign $kmodpkg_name
        tar zcf armv8-$kmodpkg_name.tar.gz $kmodpkg_name
        rm -rf $kmodpkg_name
    fi
    # OTA json
    if [ "$1" = "rc2" ]; then
        mkdir -p ota
        VERSION=$(sed 's/v//g' version.txt)
        SHA256=$(sha256sum bin/targets/armsr/armv8*/*-generic-squashfs-combined-efi.img.gz | awk '{print $1}')
        cat > ota/fw.json <<EOF
{
  "armsr,armv8": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256",
      "url": "https://github.com/sbwml/builder/releases/download/v$VERSION/openwrt-$VERSION-armsr-armv8-generic-squashfs-combined-efi.img.gz"
    }
  ]
}
EOF
    fi
    exit 0
elif [ "$platform" = "bcm53xx" ]; then
    if [ "$NO_KMOD" != "y" ]; then
        cp -a bin/targets/bcm53xx/generic/packages $kmodpkg_name
        rm -f $kmodpkg_name/Packages*
        cp -a bin/packages/arm_cortex-a9/base/rtl88*a-firmware*.ipk $kmodpkg_name/
        cp -a bin/packages/arm_cortex-a9/base/natflow*.ipk $kmodpkg_name/
        bash kmod-sign $kmodpkg_name
        tar zcf bcm53xx-$kmodpkg_name.tar.gz $kmodpkg_name
        rm -rf $kmodpkg_name
    fi
    # OTA json
    if [ "$1" = "rc2" ]; then
        mkdir -p ota
        if [ "$MINIMAL_BUILD" = "y" ]; then
            OTA_URL="https://r8500.cooluc.com/d/minimal/openwrt-24.10"
        else
            OTA_URL="https://github.com/sbwml/builder/releases/download"
        fi
        VERSION=$(sed 's/v//g' version.txt)
        SHA256=$(sha256sum bin/targets/bcm53xx/generic/*-bcm53xx-generic-netgear_r8500-squashfs.chk | awk '{print $1}')
        cat > ota/fw.json <<EOF
{
  "netgear,r8500": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256",
      "url": "$OTA_URL/v$VERSION/openwrt-$VERSION-bcm53xx-generic-netgear_r8500-squashfs.chk"
    }
  ]
}
EOF
    fi
    exit 0
else
    if [ "$NO_KMOD" != "y" ] && [ "$platform" != "rk3399" ]; then
        cp -a bin/targets/rockchip/armv8*/packages $kmodpkg_name
        rm -f $kmodpkg_name/Packages*
        cp -a bin/packages/aarch64_generic/base/rtl88*a-firmware*.ipk $kmodpkg_name/
        cp -a bin/packages/aarch64_generic/base/natflow*.ipk $kmodpkg_name/
        [ "$ENABLE_DPDK" = "y" ] && {
            cp -a bin/packages/aarch64_generic/base/*dpdk*.ipk $kmodpkg_name/ || true
            cp -a bin/packages/aarch64_generic/base/*numa*.ipk $kmodpkg_name/ || true
        }
        bash kmod-sign $kmodpkg_name
        tar zcf aarch64-$kmodpkg_name.tar.gz $kmodpkg_name
        rm -rf $kmodpkg_name
    fi
    # OTA json
    if [ "$1" = "rc2" ]; then
        mkdir -p ota
        OTA_URL="https://github.com/sbwml/builder/releases/download"
        VERSION=$(sed 's/v//g' version.txt)
        if [ "$model" = "nanopi-r4s" ]; then
            [ "$MINIMAL_BUILD" = "y" ] && OTA_URL="https://r4s.cooluc.com/d/minimal/openwrt-24.10"
            SHA256=$(sha256sum bin/targets/rockchip/armv8*/*-squashfs-sysupgrade.img.gz | awk '{print $1}')
            cat > ota/fw.json <<EOF
{
  "friendlyarm,nanopi-r4s": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256",
      "url": "$OTA_URL/v$VERSION/openwrt-$VERSION-rockchip-armv8-friendlyarm_nanopi-r4s-squashfs-sysupgrade.img.gz"
    }
  ]
}
EOF
        elif [ "$model" = "nanopi-r5s" ]; then
            [ "$MINIMAL_BUILD" = "y" ] && OTA_URL="https://r5s.cooluc.com/d/minimal/openwrt-24.10"
            SHA256_R5C=$(sha256sum bin/targets/rockchip/armv8*/*-r5c-squashfs-sysupgrade.img.gz | awk '{print $1}')
            SHA256_R5S=$(sha256sum bin/targets/rockchip/armv8*/*-r5s-squashfs-sysupgrade.img.gz | awk '{print $1}')
            cat > ota/fw.json <<EOF
{
  "friendlyarm,nanopi-r5c": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256_R5C",
      "url": "$OTA_URL/v$VERSION/openwrt-$VERSION-rockchip-armv8-friendlyarm_nanopi-r5c-squashfs-sysupgrade.img.gz"
    }
  ],
  "friendlyarm,nanopi-r5s": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256_R5S",
      "url": "$OTA_URL/v$VERSION/openwrt-$VERSION-rockchip-armv8-friendlyarm_nanopi-r5s-squashfs-sysupgrade.img.gz"
    }
  ]
}
EOF
        fi
    fi
    # Backup download cache
    if [ "$isCN" = "CN" ] && [ "$version" = "rc2" ]; then
        rm -rf dl/geo* dl/go-mod-cache
        tar -cf ../dl.gz dl
    fi
    exit 0
fi

# 很少有人会告诉你为什么要这样做，而是会要求你必须要这样做。
