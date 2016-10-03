title: map Ctrl-V as Ctrl-Q in vim
date: 2015-12-25 23:40:23
categories: Coding
thumbnail: https://blog.unasuke.com/images/2015/vimlogo-70fbd593.png
tags: [vim, linux]
---

If you want to map Ctrl-V as Ctrl-Q, you can add the following line in your `.vimrc` file

```
nnoremap <C-V> <C-Q>
```

It works in gvim, but it wouldn't work in terminal-vim. Why? I'd been confused about it for a long time until I saw [this](https://stackoverflow.com/questions/21806168/vim-use-ctrl-q-for-visual-block-mode-in-vim-gnome):

> If you want to make `<c-q>` work in your terminal vim, you need to understand the default `<C-q>` has special meaning in your terminal settings.
> 
> In your terminal, pressing `<c-q>` will sent `stty start` signal. This is important when you first `stop` your terminal output scrolling(by `ctrl-s`), and then you want to resume. That is, in terminal vim, if you pressed `C-q`, it will be captured first by terminal. You can of course change that rule, by disable the `stty start` definition. like:
> 
> `stty start undef`
>
> you could add this to your `.bashrc` file (I assume you were using bash) if you want to make it as default.
> 
> with this line executed, you can create the same mapping `nnoremap <c-q> <c-v>` in your vim, and pressing `<c-q>` in normal mode, vim is gonna enter block-wise selection mode.
> 
> After all, again, I suggest you forget the windows mapping if you work on linux box.

In short, add the following line in your `.bashrc` file, and the map will work after that.

```
stty start undef
```
