title: install flash plugin in firefox on arch linux
date: 2016-06-15 07:06:33
tags: [linux, firefox]
categories: Coding
thumbnail: https://www.mozilla.org/media/img/firefox/firefox-256.e2c1fc556816.jpg
---

First, install `flashplugin`.

``` shell
sudo pacman -S flashplugin
```

Then if you launch firefox, you will find out that there's no sound when playing flash in it. Launch it from the terminal, you will find out the reason.

``` shell
Failed to open VDPAU backend libvdpau_va_gl.so: cannot open shared object file: No such file or directory
```

So you need to install `libvdpau-va-gl`

``` shell
sudo pacman -S libvdpau-va-gl
```

Launch again, everything is fine now.
