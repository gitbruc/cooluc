#!/bin/bash

# fix smartdns hash
sed -i 's/227eef2dfffb56445145e7b8a76f6d6fa678ce3e99aceec58f7d35564f4cfafd/6ba61d10164ee61a16b2c7b930c9113598cbbf9595a531b372088e66546b27c3/g' feeds/packages/net/smartdns/Makefile
sed -i 's/34c85d914e01006439f5e1c9287ae96d6bfcc729ed4bcf386bf5948b938254f4/5ef82ea81d5f627f52171e3b487331ecdd270554555cbff3d291590e19f4658d/g' feeds/packages/net/smartdns/Makefile

# rtprtp2httpd hash
sed -i 's/b040c99b5fd8a2adce71a4d4b0f92c92a7a2b4c2f1fd9abad24ae7e657ec56e5/f2d42db1944b8199e3956baca1c45477a9acc9e1496f06d5347d73b72337fd2d/g' package/new/custom/rtp2httpd/Makefile

# ddns-go
#sed -i 's/^[[:space:]]\+/\t/g' package/new/ddnsgo/ddns-go/Makefile

# intel-microcode
sed -i 's/mkdir $(PKG_BUILD_DIR)\/intel-ucode-ipkg/rm -rf $(PKG_BUILD_DIR)\/intel-ucode-ipkg \&\& mkdir -p $(PKG_BUILD_DIR)\/intel-ucode-ipkg/' package/firmware/intel-microcode/Makefile

# rust
sed -i 's/$(PYTHON) $(HOST_BUILD_DIR)\/x.py/env -u CI -u GITHUB_ACTIONS $(PYTHON) $(HOST_BUILD_DIR)\/x.py --set llvm.download-ci-llvm=false/g' feeds/packages/lang/rust/Makefile

