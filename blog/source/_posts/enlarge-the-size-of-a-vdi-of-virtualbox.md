title: enlarge the size of a vdi of virtualbox
date: 2015-12-03 18:45:54
categories: Coding
tags: virtualbox
---

I'm more accustomed to Linux compared with Windows, but some apps are not accessible in Linux, e.g. QQ. And sometimes I have to use Visual Studio, which is a cumbersome, slow developing tool. I don't like that. But I have to use that sometimes. So I use a virtual machine to access Windows, which could help to access those windows apps. For example, today my classmate asked for help, which was about building a client-server app with windows socket. But I didn't install C++ development environment in my Visual Studio, so I have to install them. But one afternoon passed, and I found that I've got no place to install any extra packages any more, since Visual Studio installed a lot of tools on my virtual machine before C++ development tools were installed. Anyway, this is just some bullshit. I know this paragraph has little to do with the title, you can skip the paragraph if you want. But I guess you've finished reading it, so, anyway. :)

The way to enlarge a vdi is unbelievably simple, it's just like this:

```bash
VBoxManage modifyhd ~/VirtualBox\ VMs/win7/win7.vdi --resize 61440 #61440MB = 60GB
```

Then you will find the output like this:

```
0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
```

It's very fast, no more than 1 second. Then you can find that the size of the disk has been enlarged to 60GB

![](http://i.imgur.com/FUCOGNn.png)

But when you start Virtual Machine, you will find that the size of the disk doesn't change in the system, This is because you haven't extended the volume in the System.

![](http://i.imgur.com/DAYxcvh.png)

Open `Control Panel`, and search `disk` in it. Click on `Create and format hard disk partiton` to open `Disk Management`. 

![](https://i.imgur.com/EIW1UBv.png)

You will find 10GB or whatever the size is that is not allocated yet. Click on the disk that you want to extend, click on `extend volume`.

![](http://i.imgur.com/8Y81k4V.png)

Then next, next... All done!
