#!/bin/bash
# smartdns
rm -rf feeds/packages/net/smartdns
rm -rf feeds/luci/applications/luci-app-smartdns
git clone https://github.com/pymumu/openwrt-smartdns.git feeds/packages/net/smartdns
git clone https://github.com/pymumu/luci-app-smartdns.git package/new/luci-app-smartdns

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
git clone https://github.com/gitbruc/fanchmwrt-packages package/new/fanchmwrt-packages

# eqosplus
git clone https://github.com/sirpdboy/luci-app-eqosplus.git package/new/luci-app-eqosplus
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
git clone https://github.com/Openwrt-Passwall/openwrt-passwall.git package/new/helloworld/luci-app-passwall
# luci-app-taskplan
git clone https://github.com/sirpdboy/luci-app-taskplan.git package/new/luci-app-taskplan
# control-sqm
sed -i 's|admin/network|admin/control|' "feeds/luci/applications/luci-app-sqm/root/usr/share/luci/menu.d/luci-app-sqm.json"
# control-nlbw
sed -i 's|admin/services|admin/control|g' feeds/luci/applications/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
sed -i 's|admin/services|admin/control|g' feeds/luci/applications/luci-app-nlbwmon/htdocs/luci-static/resources/view/nlbw/config.js
# control-banip
sed -i 's|admin/services|admin/control|' "feeds/luci/applications/luci-app-banip/root/usr/share/luci/menu.d/luci-app-banip.json"
# control-watchcat
sed -i 's|admin/services|admin/control|' "feeds/luci/applications/luci-app-watchcat/root/usr/share/luci/menu.d/luci-app-watchcat.json"
# control-wol
sed -i 's|admin/services|admin/control|' "feeds/luci/applications/luci-app-wol/root/usr/share/luci/menu.d/luci-app-wol.json"
# control-openappfilter---
sed -i 's|"admin", "services"|"admin", "control"|g' "package/new/OpenAppFilter/luci-app-oaf/luasrc/controller/appfilter.lua"
sed -i 's|"admin", "services"|"admin", "control"|g' "package/new/OpenAppFilter/luci-app-oaf/luasrc/model/cbi/appfilter/dev_status.lua"
sed -i 's|admin/services|admin/control|g' "package/new/OpenAppFilter/luci-app-oaf/luasrc/view/admin_network/app_filter.htm"
# nas-samba4
sed -i 's|admin/services|admin/nas|' "feeds/luci/applications/luci-app-samba4/root/usr/share/luci/menu.d/luci-app-samba4.json"
# nas-webdav
sed -i 's|admin/services/webdav|admin/nas/webdav|g' package/new/luci-app-webdav/root/usr/share/luci/menu.d/luci-app-webdav.json
# change luci
perl -pi -e "s/hostname='OpenWrt'/hostname='XiaomanWrt'/g" package/base-files/files/bin/config_generate
node insert.js
mv 1.png package/new/luci-theme-argon/luci-theme-argon/htdocs/luci-static/argon/background/
# 自定义脚本
