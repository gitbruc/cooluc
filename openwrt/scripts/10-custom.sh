#!/bin/bash
# onliner
git clone https://github.com/gitbruc/luci-onliner.git package/new/luci-app-onliner
# ddns-go
git clone https://github.com/sirpdboy/luci-app-ddns-go package/new/ddnsgo
# wechatpush
git clone https://github.com/tty228/luci-app-wechatpush.git package/new/luci-app-wechatpush
#git clone https://github.com/gitbruc/luci-app-wechatpush.git package/new/luci-app-wechatpush
#passwall
rm -rf package/new/helloworld/{luci-app-passwall,patch-luci-app-passwall.patch}
git clone https://github.com/xiaorouji/openwrt-passwall.git package/new/helloworld/luci-app-passwall
# 自定义脚本
