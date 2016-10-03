title: Fix The Font Rendering Problem On Pycharm
date: 2015-12-21 21:39:27
categories: Coding
thumbnail: https://fontbundles.net/images/products/bWcQX41Hgr_Ddw.jpg
tags: [pycharm, java]
---

Almost all the java desktop apps running on PC/Mac have a common problem: font rendering. The font rendering in pycharm was so crappy that I couldn't live with it any more. So I began to search for a way to fix it. Luckily I found a solution [here](https://www.reddit.com/r/Python/comments/1ez6ro/fixing_pycharms_font_rendering_in_linux_64bit/)

I added these lines to my ../pycharm/bin/pycharm64.vmoptions file:

> -Dawt.useSystemAAFontSettings=on
> -Dswing.aatext=true
> -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel 

To make it even more clear, this is my complete `pycharm64.vmoptions` file:

> -Xms128m
> -Xmx750m
> -XX:MaxPermSize=350m
> -XX:ReservedCodeCacheSize=225m
> -XX:+UseConcMarkSweepGC
> -XX:SoftRefLRUPolicyMSPerMB=50
> -ea
> -Dsun.io.useCanonCaches=false
> -Djava.net.preferIPv4Stack=true
> -Dawt.useSystemAAFontSettings=on
> -Dswing.aatext=true
> -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel

Now the font rendering is much better now. Great! By the way, I love the default font-rendering method on ubuntu, it is much better than that on Windows.
