title: WriteToDisk -- An Anki Addon to avoid losing data
date: 2016-04-13 09:21:40
tags: [anki, python]
thumbnail: https://upload.wikimedia.org/wikipedia/commons/thumb/9/92/Gnome-document-save.svg/2000px-Gnome-document-save.svg.png
categories: Coding
---

Anki wouldn't save the cards you added or reviewed if anki or system crashes while anki is running. The addon solves the problem. 

After installing the addon, when you add or review a card, the data is immediately written to disk, so you wouldn't lose it no matter what happens. 

It does have a side-effect, undo card deletion doesn't work because the deletion works immediately.

Try it if you want to avoid losing data.

github: https://github.com/searene/Anki-Addons
ankiweb: https://ankiweb.net/shared/info/657538072
