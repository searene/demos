title: auto save in vim
date: 2015-12-26 14:49:31
tags: [vim]
thumbnail: http://www.iconarchive.com/download/i48662/custom-icon-design/pretty-office-7/Save.ico
categories: Coding
---

I'd been using [vim-auto-save](https://github.com/vim-scripts/vim-auto-save) for a long time, but I also found that it often messed up with my buffer order because it used `silent wa` to save all buffers. And sometimes `undo` didn't work, I suspected that it had something to do with `silent wa`. After searching online for a while, I found out a way to make vim automatically save files without an extra plugin installed, just add the following lines to your `.vimrc`:

```
" save automatically when text is changed
set updatetime=200
au CursorHold * silent! update
```

It will save the current file whenever text is changed in normal mode or you leave the insert mode. It works pretty well for me. Note that it only works in vim 7.4 or above. Check out your vim version first.
