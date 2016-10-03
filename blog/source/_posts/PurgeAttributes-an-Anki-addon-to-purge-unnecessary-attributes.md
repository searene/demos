title: 'PurgeAttributes, an Anki addon to purge unnecessary attributes'
date: 2016-02-14 11:14:36
tags: [python, anki]
categories: Coding
---

# Introduction
PurgeAttributes is used to purge the `font-size` attribute originally. But you can purge any attribute defined in something like `style='font-size: 100px; color: red'`.

# Install

Put [PurgeAttributes.py](https://raw.githubusercontent.com/searene/Anki-Addons/master/PurgeAttributes/PurgeAttributes.py) in your anki addon directory and restart.

# Usage
Put all the files under `PurgeAttributes`(including `PurgeAttributes.py` and `PurgeAttribues` folder which contains `bs4`) into your Anki add-ons folder.

# Effects
It will purge the four attributes by default:

* font-family
* font-size
* background-color
* line-height

If you are running Anki with a high-resolution like me, and you didn't strip the html when pasting like me, you may encounter something like this:

![without PurgeAttributes](http://i.imgur.com/jQTDGaG.png)

If you use the addon, it will remove the yellow background and remove the `font-size` attribute, because the font size here is small. The result is like this:

![with PurgeAttributes](http://i.imgur.com/wdbtrFa.png)

Now it's not hard to see, right?

# Configuration

To choose which attribute you need to remove, edit the `purgeAttributes.py` file from menu `Tools --> Add-ons --> PurgeAttributes --> Edit`, and modify the variable `REMOVE_ATTRIBUTES` at will.
