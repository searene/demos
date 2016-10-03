title: rc.local stopped running when an error occurred
date: 2015-12-03 15:07:46
tags: [linux, shell]
categories: Coding
thumbnail: https://monovm.com/images/unzip-centos.png
---

Today I found out that `/etc/rc.local` didn't execute all of my commands that were written in the file. The content of the `/etc/rc.local` is like this:

```bash
#!/bin/bash -e
command1
command2
command3

exit 0
```

I tried to execute `/etc/rc.local` manually, then I found that `command1` failed in the middle of running and `/etc/rc.local` detected this phenomenon and it stopped running too, without considering the feelings of `command2` and `command3`. This is weird, because normally a bash file will execute every command in its file no matter one of the command fails or not. After searching for a while on the Internet. I found that it was `-e` option that made this happen. `-e` will make sure the script stop running when an error occurrs. It is essential for PC booting, because if a command fails, there's no guarantee that other commands will be running normally. But I don't need this, I just want every command to be executed no matter what happens. so I removed the `-e` option. Then Everything is fine. Now even when `command1` fails, `command2` and `command3` will still get to be executed.
