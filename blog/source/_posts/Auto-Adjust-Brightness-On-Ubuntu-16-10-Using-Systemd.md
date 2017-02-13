title: Auto Adjust Brightness On Ubuntu 16.10 Using Systemd
date: 2016-12-06 22:05:27
tags: [ubuntu, linux]
categories: Coding
thumbnail: /images/brightness.jpg
---

This works on ubuntu 16.10

Create a file `brightness.service` in `/lib/systemd/system` with the following contents(Change 100 to whatever brightness you want, roughly it’s between 0 ~ 1000).

```
[Unit]
Description=Lower default brightness

[Service]
ExecStart=/usr/bin/zsh -c "echo 100 > /sys/class/backlight/intel_backlight/brightness"

[Install]
WantedBy=multi-user.target
```

Enable it.

```
sudo systemctl enable brightness.
```

Restart. It will work.
