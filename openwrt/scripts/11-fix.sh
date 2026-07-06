#!/bin/bash

# fix smartdns hash
sed -i 's/\(PKG_MIRROR_HASH:=\).*/\1skip/' feeds/packages/net/smartdns/Makefile
sed -i 's/\(MIRROR_HASH:=\).*/\1skip/' feeds/packages/net/smartdns/Makefile

# rust
#sed -i 's/$(PYTHON) $(HOST_BUILD_DIR)\/x.py/env -u CI -u GITHUB_ACTIONS $(PYTHON) $(HOST_BUILD_DIR)\/x.py --set llvm.download-ci-llvm=false/g' feeds/packages/lang/rust/Makefile

# dockerd
#sed -i 's/406f6ba2f369e384e39bebe837859a888413dd71608ace7a9b0dc7d550dbd570/f2d4d892f5439ac8b3b28a2ba03d29db1a377f8dd5d057ca941cdbba92f6ed7f/' feeds/packages/utils/dockerd/Makefile

# natflow
curl -sL $mirror/openwrt/patch/natflow/999-fix-ipset-api-kernel-6.12.patch > package/new/natflow/patches/999-fix-ipset-api-kernel-6.12.patch

# shadowsocksr-libev 忽略gcc16警告
sed -i 's/TARGET_CFLAGS += -flto/TARGET_CFLAGS += -flto -Wno-error/g' package/new/helloworld/shadowsocksr-libev/Makefile