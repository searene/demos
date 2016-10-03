title: learn redirection the hard way
date: 2016-03-26 21:44:20
tags: [linux, zsh, shell]
categories: Coding
thumbnail: https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQeX32vzVc7vazI4vrqXC2Dy1CkeTh4ipgZJkCrRsnyCeNWV30EVw
---


It's been a long time since the last time I wrote the blog, because I'm not a fan of writing blogs. But today I solved a problem with hours' digging and trying, so I think it might be a good idea to share it.

The main idea was that I wanted to run a script at boot, which contained the following line,

```zsh
/path/to/node_modules/.bin/gulp 2>&1 > /tmp/gulp.log
```

This line just wouldn't run, and I didn't know why. What's more, the output file `/tmp/gulp.log` was totally empty. Just when I thought I could do nothing about it and I was just going to give up, I found a possible solution online, which was to put `2>&1` immediately before `&`, as follows,

```zsh
/path/to/node_modules/.bin/gulp > /tmp/gulp.log 2>&1 &
```

It worked! Then I got the error, `gulp` couldn't find `node`. I didn't know why, I guessed the script didn't source `~/.zshrc` file before running the script. So I added the following line in the script.

```zsh
source ~/.zshrc
```

It worked. The original script was executed as perfectly as one could expect. A good lesson. There's no problem that is unsolvable, the only problem is whether you have enough time and whether you want to find it.
