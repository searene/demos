title: Install fcitx on ubuntu 16.10
date: 2016-12-06 22:13:57
tags: [fcitx, ubuntu, linux]
categories: Coding
thumbnail: /images/input.png
---

Run the following command.

```
sudo apt-get install fcitx fcitx-table fcitx-googlepinyin fcitx-module-cloudpinyin
```

Search for `language support`, and check `Keyboard input method system` is `fcitx`

Reboot.

Go to the configuration of fcitx --> Addon --> Cloud Pinyin --> Configure --> Cloud Pinyin Source --> Change from google to baidu.
