title: GoldenDictMedia
date: 2016-02-14 11:19:57
categories: Coding
tags: [python, anki]
---

# Introduction

[GoldenDict](http://goldendict.org/) is an excellent dictionary management software. It can handle most dictionary formats, some of these dictionaries contain audios and/or images. This addon can import the images and audios pasted from Goldendict when adding new cards in Anki

# Usage

## 1. Unzip the media file

Every dictionary containing audios or images in goldendict comes with a media folder, the filename of the media file often ends with `.files.zip`. The size of the file is usually huge, 100MB+ or even 1GB+. Unzip the file, and you will get a directory containing all the audios and images a dictionary need. You have to do this for every dictionary you need.

## 2. Turn off Strip-HTML

The addon cannot paste images from goldendict if you turn on Strip-HTML. If you only want to import audios from goldendict, then you can skip this step.

Open Anki, go to `Tools --> Preferences` and uncheck `Strip HTML when pasting text` to turn it off.

## 3. Copy and paste

Go to goldendict, copy something containing audios / images in **a** dictionary. Go to Anki, adding new cards, then paste it. GoldenDictMedia will notice that the text is pasted from a GoldenDict dictionary, and it will ask you for the media path of it, like this:

![Specify media location](http://i.imgur.com/F10sOiV.png)

## 4. Specify the location of the media directory

Click on the `...` button, find the media directory you unzipped earlier from the `zip` file, and select it. Notice that selecting the directory is fine, you don't need go in the directory. Click on `OK`, and GoldenDictMedia will import the dictionary media for you. You only need to do this once for each dictionary. Copy another audios / images from this dictionary, GoldenDictMedia will import the media automatically.

# Configurations

## Ignore the dictionary

If there are any of the dictionaries you don't want the addon to process, check `ignore the dictionary and never prompt for it again`, GoldenDictMedia will not process it. If you only want to ignore it once, just click on `Cancel` will do the trick.

## Check GoldenDict Media

By default GoldenDictMedia will check if there's any new dictionary added when pasting, if you have added enough dictionaries and you don't want GoldenDictMedia to detect it again, you can turn it off by uncheck `Check goldendict media everytime it pastes` in `Tools --> GoldenDictMedia`. Usually you don't have to turn it off unless there's something wrong with it.

## Reset

Reset will delete all the dictionary data and configurations in GoldenDictMedia, it will make the addon just as the when you install it the first time. You can do a reset by clicking on `Reset` in `Tools --> GoldenDictMedia`.

# Known Issues

1. Images cannot imported when Strip-HTML is on.
2. I didn't look through the source code of GoldenDict. But I think that this process should be totally automatic. The file path used in GoldenDict should be reversible, the addon should be able to reverse GoldenDict file path to the real file path in system and get the media from the `zip` file. So anyone with a good knowledge of how GoldenDict media works is welcomed to improve the addon to make it automatic.

# Bug Report

There are two ways to report a bug or offering a suggestion.

1. Open an issue on [my github repository](https://github.com/searene/Anki-Addons)
2. Leave a comment below [my blog](http://searene.me/2016/02/14/GoldenDictMedia/)
