title: Ubuntu crashes when entering or exiting fullscreen while watching youtube videos
date: 2015-12-04 15:48:31
tags: linux
categories: Coding
---

### Preface

After I installed ubuntu 15.10, something weird happened from time to time. Ubuntu often crashed when I entered or exited fullscreen mode while watching youtube videos. Sometimes I could get away with it by punching the `Super` button to bring up another app, in which I could run some commands to terminate google-chrome. Or I could jumped to tty1 to `pkill chrome` or `sudo pkill Xorg`. But sometimes nothing worked. And the most important thing is, it's extremely annoying, so I decided to solve the problem.

### Solution

After searching for the solution online for a while, I found an answer, it's pretty simple, just disable `hardware accelerator` in chrome, as followed.

![](http://i.imgur.com/Efu0Flw.png)

### Result

I haven't encountered the `crash` phenomenon since I disabled `hardware accelerator`. So I guess it worked. Whether it's a bug of google-chrome or ubuntu, I don't know. But now I can safely enter or exit fullscreen mode without worrying a crash might happen. Hooray!
