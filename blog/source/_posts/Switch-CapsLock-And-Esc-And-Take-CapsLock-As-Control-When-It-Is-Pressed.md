title: Switch CapsLock And Esc And Take CapsLock As Control When It Is Pressed
date: 2015-12-16 23:10:56
tags: [vim, linux]
categories: Coding
---

# Edit 1

Sometimes the method mentioned below just stops working, and I don't know why. For now I just switch Esc and CapsLock, and leave Control part behind. It's quite easy if you just want to switch Esc and CapsLock, all you need to do is install `gnome-tweak-tool` and find `CapsLock key behavior` under `Typing`, and choose `Swap Esc and Caps Lock`, just as shown below:

![gnome-tweak-tool](http://i.imgur.com/qfmc5A0.png)

---

# Edit 2

I found a way to make it work. First, open `gnome-tweak-tool` and find `CapsLock key behavior` under `Typing`, and choose `Make Caps Lock an additional Ctrl`

![gnome-tweak-tool](http://i.imgur.com/LrpiLjH.png)

Then add the following line in your `~/.bashrc` file:

```bash
xcape -e 'Caps_Lock=Escape'
```

It works for me. The only problem is that you don't have a CapsLock key anymore. But I guess you can map another key with `gnome-tweak-tool`. I don't use that key a lot, so I haven't done that yet. By the way, you don't have to see the method below, it doesn't work properly, at least for me.

---

# Preface

I've been using vim for years, and I've been using `Esc` for years. A few days before, I heard about an idea that I could switch `Caps Lock` and `Esc` to make vim more convenient, because you know, `Caps Lock` is nearer than `Esc`. This is interesting, but lately I heard about a even more convenient idea, which not only includes switching `Caps Lock` and `Esc`, but also taking `Caps Lock` as `Control` when it's pressed. So in this way, `Caps Lock` has two distinct functionalities, one is to be used as `Esc` when punched, the other is to be used as `Control` when pressed, what a great idea! Let's get started to make it real.

# Installation

I'm using ubuntu 15.10, so I can only guarantee it works in linux. First thing you need to do is to install xcape.

```bash
sudo apt-get install xcape
```

# Script

After that, create a new file called `xmodmaprc`, let's put it under `~/Tools` (or wherever you want, ~ denotes your home folder). The contents of `xmodmaprc` are as follows:

```bash
!
! make caps_lock an additional control
clear Lock
! NOTE: this keycode may need to be changed for your control
keycode 66 = Control_L
add Control = Control_L

!
! make escape be caps_lock
keysym Escape = Caps_Lock
add Lock = Caps_Lock

!
! make a fake escape key (so we can map it with xcape)
keycode 999 = Escape
```

Create another file called `switch.sh`, put it under `~/Tools` too.

```bash
#!/bin/sh
# keyboard settings need the desktop to be fully loaded, so we let it sleep for 15s to wait for it.
sleep 15

xmodmap $HOME/Tools/xmodmaprc
xcape -e 'Control_L=Escape'
```

Add permission to make it executable

```bash
chmod +x ~/Tools/switch.sh
```

Now if you run `~/Tools/switch.sh`, you will find that it's already working

# Startup

Of course you don't want to run `~/Tools/switch.sh` manually every time a session starts. Open `Startup Applications` in unity dash and add a new entry:

![Startup Applications](http://i.imgur.com/FWQ1gkg.png)

Now reboot, and you will find that you don't have to run the command manually any more. `Startup Applications` does this for you automatically. Enjoy.

# Reference

[super-caps](https://github.com/cmatheson/super-caps)
