#!/bin/bash

# fix smartdns hash
sed -i 's/227eef2dfffb56445145e7b8a76f6d6fa678ce3e99aceec58f7d35564f4cfafd/4401734712dd034eb1088ce440d1bc64d053dfcd6f63f66c08cd48ab68593042/g' feeds/packages/net/smartdns/Makefile
sed -i 's/609fec024396a3a26278ef9fe7bd49aeca478e3163fc53c699a5f402fa0320f0/f8bfb91ae0992dd62392ebb2b7d968d514f7cbc3cc6a5d975dafdd6b27bf0a0c/g' feeds/packages/net/smartdns/Makefile

# fix xray-core hash
sed -i 's/6016f70297e7d63d2347e3ba0362ccc107c90a7f62b86cb4ee36ae4dab3eec42/c814c9b2e6c92e08d3db929792c56e2863a1a0e252c774ec048095efea6b67a1/g' package/new/helloworld/xray-core/Makefile
rm -rf package/new/helloworld/luci-app-passwall