#!/bin/bash

# fix smartdns hash
sed -i 's/227eef2dfffb56445145e7b8a76f6d6fa678ce3e99aceec58f7d35564f4cfafd/4401734712dd034eb1088ce440d1bc64d053dfcd6f63f66c08cd48ab68593042/g' feeds/packages/net/smartdns/Makefile
sed -i 's/34c85d914e01006439f5e1c9287ae96d6bfcc729ed4bcf386bf5948b938254f4/5ef82ea81d5f627f52171e3b487331ecdd270554555cbff3d291590e19f4658d/g' feeds/packages/net/smartdns/Makefile

# fix xray-core hash
sed -i 's/6016f70297e7d63d2347e3ba0362ccc107c90a7f62b86cb4ee36ae4dab3eec42/c814c9b2e6c92e08d3db929792c56e2863a1a0e252c774ec048095efea6b67a1/g' package/new/helloworld/xray-core/Makefile
#rm -rf package/new/helloworld/luci-app-passwall

# intel-microcode
sed -i 's|mkdir $(PKG_BUILD_DIR)/intel-ucode-ipkg|mkdir -p $(PKG_BUILD_DIR)/intel-ucode-ipkg|' package/firmware/intel-microcode/Makefile