#!/bin/bash -e

#################################################################

# autocore
git clone https://$github/gitbruc/autocore-arm -b openwrt-25.12 package/system/autocore

## x86_64 - target 6.12
# curl -s $mirror/openwrt/patch/openwrt-6.x/x86/64/config-6.12 > target/linux/x86/64/config-6.12
# curl -s $mirror/openwrt/patch/openwrt-6.x/x86/config-6.12 > target/linux/x86/config-6.12
curl -s $mirror/openwrt/patch/openwrt-6.x/x86/64/64.12 >> target/linux/x86/64/config-6.12
mkdir -p target/linux/x86/patches-6.12
curl -s $mirror/openwrt/patch/openwrt-6.x/x86/patches-6.12/100-fix_cs5535_clockevt.patch > target/linux/x86/patches-6.12/100-fix_cs5535_clockevt.patch
curl -s $mirror/openwrt/patch/openwrt-6.x/x86/patches-6.12/103-pcengines_apu6_platform.patch > target/linux/x86/patches-6.12/103-pcengines_apu6_platform.patch

# x86_64 - target
curl -s $mirror/openwrt/patch/openwrt-6.x/x86/base-files/etc/board.d/01_leds > target/linux/x86/base-files/etc/board.d/01_leds
curl -s $mirror/openwrt/patch/openwrt-6.x/x86/base-files/etc/board.d/02_network > target/linux/x86/base-files/etc/board.d/02_network

# kernel modules
rm -rf package/kernel/linux
git checkout package/kernel/linux
pushd package/kernel/linux/modules
    rm -f fs.mk other.mk rtc.mk netsupport.mk
    #curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/block.mk
    #curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/bluetooth.mk
    #curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/can.mk
    #curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/crypto.mk
    #curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/firewire.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/fs.mk
    #curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/gpio.mk
    #curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/hwmon.mk
    #curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/i2c.mk
    #curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/iio.mk
    #curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/input.mk
    #curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/leds.mk
    #curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/lib.mk
    #curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/multiplexer.mk
    #curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/netdevices.mk
    #curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/netfilter.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/netsupport.mk
    #curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/nls.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/other.mk
    #curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/pcmcia.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/rtc.mk
    #curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/sound.mk
    #curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/spi.mk
    #curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/usb.mk
    #curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/video.mk
    #curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/virt.mk
    #curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/w1.mk
    #curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/wpan.mk
popd

# wireless-regdb
curl -s $mirror/openwrt/patch/openwrt-6.x/500-world-regd-5GHz.patch > package/firmware/wireless-regdb/patches/500-world-regd-5GHz.patch

# BBRv3 - linux-6.12
pushd target/linux/generic/backport-6.12
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0001-net-tcp_bbr-broaden-app-limited-rate-sample-detectio.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0002-net-tcp_bbr-v2-shrink-delivered_mstamp-first_tx_msta.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0003-net-tcp_bbr-v2-snapshot-packets-in-flight-at-transmi.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0004-net-tcp_bbr-v2-count-packets-lost-over-TCP-rate-samp.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0005-net-tcp_bbr-v2-export-FLAG_ECE-in-rate_sample.is_ece.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0006-net-tcp_bbr-v2-introduce-ca_ops-skb_marked_lost-CC-m.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0007-net-tcp_bbr-v2-adjust-skb-tx.in_flight-upon-merge-in.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0008-net-tcp_bbr-v2-adjust-skb-tx.in_flight-upon-split-in.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0009-net-tcp-add-new-ca-opts-flag-TCP_CONG_WANTS_CE_EVENT.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0010-net-tcp-re-generalize-TSO-sizing-in-TCP-CC-module-AP.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0011-net-tcp-add-fast_ack_mode-1-skip-rwin-check-in-tcp_f.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0012-net-tcp_bbr-v2-record-app-limited-status-of-TLP-repa.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0013-net-tcp_bbr-v2-inform-CC-module-of-losses-repaired-b.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0014-net-tcp_bbr-v2-introduce-is_acking_tlp_retrans_seq-i.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0015-tcp-introduce-per-route-feature-RTAX_FEATURE_ECN_LOW.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0016-net-tcp_bbr-v3-update-TCP-bbr-congestion-control-mod.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0017-net-tcp_bbr-v3-ensure-ECN-enabled-BBR-flows-set-ECT-.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0018-tcp-export-TCPI_OPT_ECN_LOW-in-tcp_info-tcpi_options.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0019-x86-cfi-bpf-Add-tso_segs-and-skb_marked_lost-to-bpf_.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0020-net-tcp_bbr-v3-silence-Wconstant-logical-operand.patch
popd

# LRNG - 6.12
pushd target/linux/generic/hack-6.12
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/011-LRNG-0001-LRNG-Entropy-Source-and-DRNG-Manager.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/011-LRNG-0002-LRNG-allocate-one-DRNG-instance-per-NUMA-node.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/011-LRNG-0003-LRNG-proc-interface.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/011-LRNG-0004-LRNG-add-switchable-DRNG-support.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/011-LRNG-0005-LRNG-add-common-generic-hash-support.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/011-LRNG-0006-crypto-DRBG-externalize-DRBG-functions-for-LRNG.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/011-LRNG-0007-LRNG-add-SP800-90A-DRBG-extension.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/011-LRNG-0008-LRNG-add-kernel-crypto-API-PRNG-extension.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/011-LRNG-0009-LRNG-add-atomic-DRNG-implementation.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/011-LRNG-0010-LRNG-add-common-timer-based-entropy-source-code.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/011-LRNG-0011-LRNG-add-interrupt-entropy-source.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/011-LRNG-0012-scheduler-add-entropy-sampling-hook.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/011-LRNG-0013-LRNG-add-scheduler-based-entropy-source.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/011-LRNG-0014-LRNG-add-SP800-90B-compliant-health-tests.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/011-LRNG-0015-LRNG-add-random.c-entropy-source-support.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/011-LRNG-0016-LRNG-CPU-entropy-source.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/011-LRNG-0017-LRNG-add-Jitter-RNG-fast-noise-source.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/011-LRNG-0018-LRNG-add-option-to-enable-runtime-entropy-rate-confi.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/011-LRNG-0019-LRNG-add-interface-for-gathering-of-raw-entropy.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/011-LRNG-0020-LRNG-add-power-on-and-runtime-self-tests.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/011-LRNG-0021-LRNG-sysctls-and-proc-interface.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/011-LRNG-0022-LRMG-add-drop-in-replacement-random-4-API.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/011-LRNG-0023-LRNG-add-kernel-crypto-API-interface.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/011-LRNG-0024-LRNG-add-dev-lrng-device-file-support.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/011-LRNG-0025-LRNG-add-hwrand-framework-interface.patch
popd

# linux-rt - i915
pushd target/linux/generic/hack-6.12
    curl -Os $mirror/openwrt/patch/kernel-6.12/linux-rt/012-0001-drm-i915-Use-preempt_disable-enable_rt-where-recomme.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/linux-rt/012-0002-drm-i915-Don-t-disable-interrupts-on-PREEMPT_RT-duri.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/linux-rt/012-0003-drm-i915-Don-t-check-for-atomic-context-on-PREEMPT_R.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/linux-rt/012-0004-drm-i915-Disable-tracing-points-on-PREEMPT_RT.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/linux-rt/012-0005-drm-i915-gt-Use-spin_lock_irq-instead-of-local_irq_d.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/linux-rt/012-0006-drm-i915-Drop-the-irqs_disabled-check.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/linux-rt/012-0007-drm-i915-guc-Consider-also-RCU-depth-in-busy-loop.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/linux-rt/012-0008-Revert-drm-i915-Depend-on-PREEMPT_RT.patch
popd

# linux-firmware
# rm -rf package/firmware/linux-firmware
# git clone https://$github/sbwml/package_firmware_linux-firmware package/firmware/linux-firmware

# kernel patch
# btf: silence btf module warning messages
curl -s $mirror/openwrt/patch/kernel-6.12/btf/990-btf-silence-btf-module-warning-messages.patch > target/linux/generic/hack-6.12/990-btf-silence-btf-module-warning-messages.patch
# cpu model
curl -s $mirror/openwrt/patch/kernel-6.12/arm64/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch > target/linux/generic/hack-6.12/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch
# fullcone
curl -s $mirror/openwrt/patch/kernel-6.12/net/952-net-conntrack-events-support-multiple-registrant.patch > target/linux/generic/hack-6.12/952-net-conntrack-events-support-multiple-registrant.patch
# bcm-fullcone
curl -s $mirror/openwrt/patch/kernel-6.12/net/982-add-bcm-fullcone-support.patch > target/linux/generic/hack-6.12/982-add-bcm-fullcone-support.patch
curl -s $mirror/openwrt/patch/kernel-6.12/net/983-add-bcm-fullcone-nft_masq-support.patch > target/linux/generic/hack-6.12/983-add-bcm-fullcone-nft_masq-support.patch
# shortcut-fe
#curl -s $mirror/openwrt/patch/kernel-6.12/net/601-netfilter-export-udp_get_timeouts-function.patch > target/linux/generic/hack-6.12/601-netfilter-export-udp_get_timeouts-function.patch
#curl -s $mirror/openwrt/patch/kernel-6.12/net/953-net-patch-linux-kernel-to-support-shortcut-fe.patch > target/linux/generic/hack-6.12/953-net-patch-linux-kernel-to-support-shortcut-fe.patch
