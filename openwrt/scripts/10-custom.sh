#!/bin/bash
# onliner
git clone https://github.com/gitbruc/luci-onliner.git package/new/luci-app-onliner
# ddns-go
git clone https://github.com/sirpdboy/luci-app-ddns-go package/new/ddnsgo
# wechatpush
git clone https://github.com/tty228/luci-app-wechatpush.git package/new/luci-app-wechatpush
#git clone https://github.com/gitbruc/luci-app-wechatpush.git package/new/luci-app-wechatpush
# passwall
rm -rf package/new/helloworld/{luci-app-passwall,patch-luci-app-passwall.patch}
git clone https://github.com/xiaorouji/openwrt-passwall.git package/new/helloworld/luci-app-passwall
# autotimeset
git clone https://github.com/sirpdboy/luci-app-autotimeset.git package/new/luci-app-autotimeset
# change luci
perl -pi -e "s/hostname='OpenWrt'/hostname='XiaomanWrt'/g" package/base-files/files/bin/config_generate
awk -v new_text="$(cat insert.js)" '/return table;/ {print new_text; print $0; next}1' feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js > temp.js && mv temp.js feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js
mv 1.png package/new/luci-theme-argon/luci-theme-argon/htdocs/luci-static/argon/background/
# 自定义脚本
