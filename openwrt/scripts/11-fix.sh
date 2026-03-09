#!/bin/bash

# fix smartdns hash
sed -i 's/227eef2dfffb56445145e7b8a76f6d6fa678ce3e99aceec58f7d35564f4cfafd/232d5659bd6bda378b3b3bdb12979cd8241b16e90560ea1d16d0716995d8e695/g' feeds/packages/net/smartdns/Makefile
sed -i 's/34c85d914e01006439f5e1c9287ae96d6bfcc729ed4bcf386bf5948b938254f4/5ef82ea81d5f627f52171e3b487331ecdd270554555cbff3d291590e19f4658d/g' feeds/packages/net/smartdns/Makefile

