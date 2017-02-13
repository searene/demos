title: Super CapsLock On Ubuntu 16.10
date: 2016-12-06 22:02:35
tags: [ubuntu, linux]
categories: Coding
thumbnail: /images/capslock.jpg
---

On ubuntu 16.10, make CapsLock act as Esc when it is hit, and as Ctrl when it is held.

To make it work, modify /etc/default/keyboard, change

```
XKBOPTIONS=""
```

to

```
XKBOPTIONS="caps:ctrl_modifier"
```

Then add the following line in `~/.xsessionrc`

``` shell
#!/usr/bin/env zsh

/usr/bin/xcape -e 'Caps_Lock=Escape'
```

Reboot.
