title: change openwrt source to UTSC
date: 2016-12-18 15:08:29
tags:
categories:
thumbnail: /images/openwrt.png
---

The following steps only apply to Netgear 4300 and openwrt 15.05.1.

Modify `/etc/opkg.conf` to the following lines.

```
dest root /
dest ram /tmp
lists_dir ext /var/opkg-lists
option overlay_root /overlay
option check_signature 1
src/gz chaos_calmer_base http://openwrt.proxy.ustclug.org/chaos_calmer/15.05.1/ar71xx/nand/packages/base
src/gz chaos_calmer_luci http://openwrt.proxy.ustclug.org/chaos_calmer/15.05.1/ar71xx/nand/packages/luci
src/gz chaos_calmer_management http://openwrt.proxy.ustclug.org/chaos_calmer/15.05.1/ar71xx/nand/packages/management
src/gz chaos_calmer_packages http://openwrt.proxy.ustclug.org/chaos_calmer/15.05.1/ar71xx/nand/packages/packages
src/gz chaos_calmer_routing http://openwrt.proxy.ustclug.org/chaos_calmer/15.05.1/ar71xx/nand/packages/routing
src/gz chaos_calmer_telephony http://openwrt.proxy.ustclug.org/chaos_calmer/15.05.1/ar71xx/nand/packages/telephony
```
