title: Something About Dnsmasq On Ubuntu 15.10
date: 2015-12-17 19:37:39
tags: [linux, dnsmasq]
thumbnail: http://recursostic.educacion.es/observatorio/web/images/upload/ccam0040/dnslinux/Servidor-DNS-con-dnsmasq_html_m6de5e09c.png
categories: Coding
---

# Preface

There are something confusing about dnsmasq on ubuntu 15.10. I would like to write them down here, in case I might forget down the road.

# How Dnsmasq Starts On Ubuntu 15.10

You can find the answer in the file `/etc/NetworkManager/NetworkManager.conf`:

```bash
[main]
plugins=ifupdown,keyfile,ofono
dns=dnsmasq

[ifupdown]
managed=false
```

If you notice the line `dns=dnsmasq`, you may figure out that it is `network-manager` that starts dnsmasq. So if you run `sudo service network-manager restart`, `dnsmasq` will get retarted too.

# Configure Network-Manager Not To Use Dnsmasq

How to let network-manager not use dnsmasq, but use the dns servers specified in the file `/etc/resolv.conf` instead? Just comment the line `dns=dnsmasq` in `/etc/NetworkManager/NetworkManager.conf` would be fine, as follows:

```bash
[main]
plugins=ifupdown,keyfile,ofono
#dns=dnsmasq

[ifupdown]
managed=false
```

Then edit `/etc/resolv.conf`, add your dns server:

```bash
namesever 8.8.8.8
```

Finally restart network-manager, you will find out the dns server has changed.

```bash
sudo service network-manager restart
```
