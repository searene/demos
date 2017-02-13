title: Start Shadowsocks Automatically On Ubuntu 16.10 Using Systemd
date: 2016-12-06 21:58:26
tags: [ubuntu, linux]
categories: Coding
thumbnail: /images/systemd.jpg
---

Install `shadowsocks` globally(You have to add `sudo` here)

```
sudo pip install shadowsocks
```

Create a new file called `shadowsocks@.service` in `/lib/systemd/system`

```
[Unit]
Description=Shadowsocks Client Service
After=network.target

[Service]
Type=simple
User=nobody
ExecStart=/usr/local/bin/sslocal -c /etc/shadowsocks/%i.json

[Install]
WantedBy=multi-user.target
```

Put all your shadowsocks config files in /etc/shadowsocks, like this.

```
ls /etc/shadowsocks
bandwagonhost.json  tencent.json  vultr.json
```

Start

```
sudo systemctl start shadowsocks@bandwagonhost.service
sudo systemctl start shadowsocks@tencent.service
sudo systemctl start shadowsocks@vultr.service
```

Then enable all of them.

```
sudo systemctl enable shadowsocks@bandwagonhost.service
sudo systemctl enable shadowsocks@tencent.service
sudo systemctl enable shadowsocks@vultr.service
```
