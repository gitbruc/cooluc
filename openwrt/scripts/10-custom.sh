#!/bin/bash
# smartdns
rm -rf feeds/packages/net/smartdns
rm -rf feeds/luci/applications/luci-app-smartdns
git clone https://github.com/pymumu/openwrt-smartdns.git feeds/packages/net/smartdns
git clone https://github.com/pymumu/luci-app-smartdns.git package/new/luci-app-smartdns
# fix hash
sed -i 's/227eef2dfffb56445145e7b8a76f6d6fa678ce3e99aceec58f7d35564f4cfafd/4401734712dd034eb1088ce440d1bc64d053dfcd6f63f66c08cd48ab68593042/g' feeds/packages/net/smartdns/Makefile
sed -i 's/609fec024396a3a26278ef9fe7bd49aeca478e3163fc53c699a5f402fa0320f0/f8bfb91ae0992dd62392ebb2b7d968d514f7cbc3cc6a5d975dafdd6b27bf0a0c/g' feeds/packages/net/smartdns/Makefile


# fanchmwrt
# 1. 克隆 fanchmwrt 仓库到临时目录 (使用 --depth 1 减少下载量)
git clone --depth 1 https://github.com/fanchmwrt/fanchmwrt.git /tmp/fanchmwrt
# 2. 复制 fcm
cp -r /tmp/fanchmwrt/package/fcm package/
# 3. 清理临时文件
rm -rf /tmp/fanchmwrt
# 4. (可选) 修正权限，防止脚本没有执行权限
chmod -R 755 package/fcm
# patch
curl -s https://raw.githubusercontent.com/fanchmwrt/fanchmwrt/fanchmwrt-24.10.4/target/linux/generic/hack-6.6/980-nf-contrack-support-fwx-data.patch > target/linux/generic/pending-6.12/999-fwx-kernel-hook.patch
# fanchmwrt-packages
git clone https://github.com/fanchmwrt/fanchmwrt-packages.git package/new/fanchmwrt-packages


# wrtbwmon
#git clone https://github.com/gitbruc/openwrt-wrtbwmon.git package/new/luci-app-wrtbwmon
# onliner
git clone https://github.com/gitbruc/luci-onliner.git package/new/luci-app-onliner
# ddns-go
git clone https://github.com/sirpdboy/luci-app-ddns-go package/new/ddnsgo
# wechatpush
git clone https://github.com/tty228/luci-app-wechatpush.git package/new/luci-app-wechatpush
# bbrswitch
git clone https://github.com/gitbruc/openwrt-BBR.git package/new/luci-app-bbrswitch
# passwall
rm -rf package/new/helloworld/{luci-app-passwall,patch-luci-app-passwall.patch}
git clone https://github.com/xiaorouji/openwrt-passwall.git package/new/helloworld/luci-app-passwall
# luci-app-taskplan
git clone https://github.com/sirpdboy/luci-app-taskplan.git package/new/luci-app-taskplan
# control-watchcat
sed -i 's|admin/services|admin/control|' "feeds/luci/applications/luci-app-watchcat/root/usr/share/luci/menu.d/luci-app-watchcat.json"
# control-wol
sed -i 's|admin/services|admin/control|' "feeds/luci/applications/luci-app-wol/root/usr/share/luci/menu.d/luci-app-wol.json"
# control-openappfilter
sed -i 's|"admin", "services"|"admin", "control"|g' "package/new/OpenAppFilter/luci-app-oaf/luasrc/controller/appfilter.lua"
# control-nftqos
sed -i 's|"admin", "services"|"admin", "control"|g' "feeds/luci/applications/luci-app-nft-qos/luasrc/controller/nft-qos.lua"
# nas-samba4
sed -i 's|admin/services|admin/nas|' "feeds/luci/applications/luci-app-samba4/root/usr/share/luci/menu.d/luci-app-samba4.json"
# change luci
perl -pi -e "s/hostname='OpenWrt'/hostname='XiaomanWrt'/g" package/base-files/files/bin/config_generate
node insert.js
mv 1.png package/new/luci-theme-argon/luci-theme-argon/htdocs/luci-static/argon/background/
# 自定义脚本
