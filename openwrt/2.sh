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

############################
#  OpenWrt Build Script  #
############################

# IP Location
ip_info=`curl -sk https://ip.cooluc.com`;
[ -n "$ip_info" ] && export isCN=`echo $ip_info | grep -Po 'country_code\":"\K[^"]+'` || export isCN=US

# script url
export mirror=https://raw.githubusercontent.com/gitbruc/myopenwrt/new

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
    export FORCE_UNSAFE_CONFIGURE=1 FORCE=1
fi

# Start time
starttime=`date +'%Y-%m-%d %H:%M:%S'`
CURRENT_DATE=$(date +%s)

# Cpus
cores=`expr $(nproc) + 1`

# $CURL_BAR
if curl --help | grep progress-bar >/dev/null 2>&1; then
    CURL_BAR="--progress-bar";
fi

if [ -z "$1" ] || [ "$2" != "x86_64" -a "$2" != "armv8" ]; then
    echo -e "\n${RED_COLOR}Building type not specified.${RES}\n"
    echo -e "Usage:\n"
    echo -e "x86_64 releases: ${GREEN_COLOR}bash build.sh rc2 x86_64${RES}"
    echo -e "x86_64 snapshots: ${GREEN_COLOR}bash build.sh dev x86_64${RES}"
    echo -e "armsr-armv8 releases: ${GREEN_COLOR}bash build.sh rc2 armv8${RES}"
    echo -e "armsr-armv8 snapshots: ${GREEN_COLOR}bash build.sh dev armv8${RES}\n"
    exit 1
fi

# Source branch
if [ "$1" = "dev" ]; then
    export branch=openwrt-25.12
    export version=dev
elif [ "$1" = "rc2" ]; then
    latest_release="v$(curl -s $mirror/tags/v25)"
    export branch=$latest_release
    export version=rc2
fi

# lan
[ -n "$LAN" ] && export LAN=$LAN || export LAN=10.0.0.1

# platform
[ "$2" = "armv8" ] && export platform="armv8" toolchain_arch="aarch64_generic"
[ "$2" = "x86_64" ] && export platform="x86_64" toolchain_arch="x86_64"

# gcc14 & 15
if [ "$USE_GCC13" = y ]; then
    export USE_GCC13=y gcc_version=13
elif [ "$USE_GCC14" = y ]; then
    export USE_GCC14=y gcc_version=14
elif [ "$USE_GCC15" = y ]; then
    export USE_GCC15=y gcc_version=15
elif [ "$USE_GCC16" = y ]; then
    export USE_GCC16=y gcc_version=16
else
    export USE_GCC15=y gcc_version=15
fi
[ "$ENABLE_MOLD" = y ] && export ENABLE_MOLD=y

# build.sh flags
export \
    ENABLE_BPF=$ENABLE_BPF \
    ENABLE_DPDK=$ENABLE_DPDK \
    ENABLE_LRNG=$ENABLE_LRNG \
    KERNEL_CLANG_LTO=$KERNEL_CLANG_LTO \
    ROOT_PASSWORD=$ROOT_PASSWORD

# print version
echo -e "\r\n${GREEN_COLOR}Building $branch${RES}\r\n"
if [ "$platform" = "x86_64" ]; then
    echo -e "${GREEN_COLOR}Model: x86_64${RES}"
elif [ "$platform" = "armv8" ]; then
    echo -e "${GREEN_COLOR}Model: armsr/armv8${RES}"
    [ "$1" = "rc2" ] && model="armv8"
else
   # This should not happen because of the previous validation, but it's good to have a fallback
   echo -e "${RED_COLOR}Unexpected error: Platform is unexpectedly invalid after validation.$RES"
   exit 1
fi

# print build opt
echo -e "${GREEN_COLOR}Date: $CURRENT_DATE${RES}\r\n"
echo -e "${GREEN_COLOR}SCRIPT_URL:${RES} ${BLUE_COLOR}$mirror${RES}\r\n"
echo -e "${GREEN_COLOR}GCC VERSION: $gcc_version${RES}"
print_status() {
    local name="$1"
    local value="$2"
    local true_color="${3:-$GREEN_COLOR}"
    local false_color="${4:-$YELLOW_COLOR}"
    local newline="${5:-}"
    if [ "$value" = "y" ]; then
        echo -e "${GREEN_COLOR}${name}:${RES} ${true_color}true${RES}${newline}"
    else
        echo -e "${GREEN_COLOR}${name}:${RES} ${false_color}false${RES}${newline}"
    fi
}
[ -n "$LAN" ] && echo -e "${GREEN_COLOR}LAN:${RES} $LAN" || echo -e "${GREEN_COLOR}LAN:${RES} 10.0.0.1"
[ -n "$ROOT_PASSWORD" ] \
    && echo -e "${GREEN_COLOR}Default Password:${RES} ${BLUE_COLOR}$ROOT_PASSWORD${RES}" \
    || echo -e "${GREEN_COLOR}Default Password:${RES} (${YELLOW_COLOR}No password${RES})"
[ "$ENABLE_GLIBC" = "y" ] && echo -e "${GREEN_COLOR}Standard C Library:${RES} ${BLUE_COLOR}glibc${RES}" || echo -e "${GREEN_COLOR}Standard C Library:${RES} ${BLUE_COLOR}musl${RES}"
print_status "ENABLE_DPDK"       "$ENABLE_DPDK"
print_status "ENABLE_MOLD"       "$ENABLE_MOLD"
print_status "ENABLE_BPF"        "$ENABLE_BPF" "$GREEN_COLOR" "$RED_COLOR"
print_status "ENABLE_LTO"        "$ENABLE_LTO" "$GREEN_COLOR" "$RED_COLOR"
print_status "ENABLE_LRNG"       "$ENABLE_LRNG" "$GREEN_COLOR" "$RED_COLOR"
print_status "ENABLE_LOCAL_KMOD" "$ENABLE_LOCAL_KMOD"
print_status "BUILD_FAST"        "$BUILD_FAST"
print_status "ENABLE_CCACHE"     "$ENABLE_CCACHE"
print_status "MINIMAL_BUILD"     "$MINIMAL_BUILD"
print_status "ENABLE_ISTORE"     "$ENABLE_ISTORE"
print_status "KERNEL_CLANG_LTO"  "$KERNEL_CLANG_LTO" "$GREEN_COLOR" "$YELLOW_COLOR" "\n"


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
    make -j1 V=s IGNORE_ERRORS="n m"
    #make -j$cores IGNORE_ERRORS="n m"
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
        cp -a bin/targets/x86/*/packages kmodpkg
        rm -f kmodpkg/Packages*
        cp -a bin/packages/x86_64/base/rtl88*a-firmware*.apk kmodpkg/ || true
        cp -a bin/packages/x86_64/base/natflow*.apk kmodpkg/ || true
        [ "$OPENWRT_CORE" = "y" ] && {
            cp -a bin/packages/x86_64/base/*3ginfo*.apk kmodpkg/ || true
            cp -a bin/packages/x86_64/base/*modemband*.apk kmodpkg/ || true
            cp -a bin/packages/x86_64/base/*sms-tool*.apk kmodpkg/ || true
            cp -a bin/packages/x86_64/base/*quectel*.apk kmodpkg/ || true
        }
        [ "$ENABLE_DPDK" = "y" ] && {
            cp -a bin/packages/x86_64/base/*dpdk*.apk kmodpkg/ || true
            cp -a bin/packages/x86_64/base/*numa*.apk kmodpkg/ || true
        }
        bash kmod-sign kmodpkg
        tar zcf x86_64-kmodpkg.tar.gz kmodpkg
        rm -rf kmodpkg
    fi
    # Backup download cache
    if [ "$isCN" = "CN" ] && [ "$1" = "rc2" ]; then
        rm -rf dl/geo* dl/go-mod-cache
        tar cf ../dl.gz dl
    fi
    exit 0
elif [ "$platform" = "armv8" ]; then
    if [ "$NO_KMOD" != "y" ]; then
        cp -a bin/targets/armsr/armv8*/packages kmodpkg
        rm -f kmodpkg/Packages*
        cp -a bin/packages/aarch64_generic/base/rtl88*a-firmware*.apk kmodpkg/ || true
        cp -a bin/packages/aarch64_generic/base/natflow*.apk kmodpkg/ || true
        [ "$OPENWRT_CORE" = "y" ] && {
            cp -a bin/packages/aarch64_generic/base/*3ginfo*.apk kmodpkg/ || true
            cp -a bin/packages/aarch64_generic/base/*modemband*.apk kmodpkg/ || true
            cp -a bin/packages/aarch64_generic/base/*sms-tool*.apk kmodpkg/ || true
            cp -a bin/packages/aarch64_generic/base/*quectel*.apk kmodpkg/ || true
        }
        [ "$ENABLE_DPDK" = "y" ] && {
            cp -a bin/packages/aarch64_generic/base/*dpdk*.apk kmodpkg/ || true
            cp -a bin/packages/aarch64_generic/base/*numa*.apk kmodpkg/ || true
        }
        bash kmod-sign kmodpkg
        tar zcf armv8-kmodpkg.tar.gz kmodpkg
        rm -rf kmodpkg
    fi
    exit 0
fi

# 很少有人会告诉你为什么要这样做，而是会要求你必须要这样做。
