#!/bin/bash

# fix smartdns hash
sed -i 's/227eef2dfffb56445145e7b8a76f6d6fa678ce3e99aceec58f7d35564f4cfafd/6ba61d10164ee61a16b2c7b930c9113598cbbf9595a531b372088e66546b27c3/g' feeds/packages/net/smartdns/Makefile
sed -i 's/34c85d914e01006439f5e1c9287ae96d6bfcc729ed4bcf386bf5948b938254f4/5ef82ea81d5f627f52171e3b487331ecdd270554555cbff3d291590e19f4658d/g' feeds/packages/net/smartdns/Makefile

# intel-microcode
sed -i 's/mkdir $(PKG_BUILD_DIR)\/intel-ucode-ipkg/rm -rf $(PKG_BUILD_DIR)\/intel-ucode-ipkg \&\& mkdir -p $(PKG_BUILD_DIR)\/intel-ucode-ipkg/' package/firmware/intel-microcode/Makefile

# rust
sed -i 's/$(PYTHON) $(HOST_BUILD_DIR)\/x.py/env -u CI -u GITHUB_ACTIONS $(PYTHON) $(HOST_BUILD_DIR)\/x.py --set llvm.download-ci-llvm=false/g' feeds/packages/lang/rust/Makefile

# dockerd
sed -i 's/6850b0e5d07bed32b3613d4c7da50e0fc36542239a5ff5188b524494e9edda75/f2d4d892f5439ac8b3b28a2ba03d29db1a377f8dd5d057ca941cdbba92f6ed7f/' feeds/packages/utils/dockerd/Makefile