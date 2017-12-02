title: Let hexo support mathjax
date: 2016-10-01 15:12:19
tags: [hexo, mathjax]
categories: Coding
thumbnail: /images/mathjax.png
---

# Update

The original answer fails on some mathjax expressions. So don't use it. Currently changing `marked.js` works for me. Just use the method below. It works for me.

First introduce `mathjax` into our blog.  Create a new file called `mathjax.ejs` in `themes/hueman/layout/plugin`, and add the following contents in it.

``` html
<!-- mathjax config similar to math.stackexchange -->

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({
    tex2jax: {
      inlineMath: [ ['$','$'], ["\\(","\\)"] ],
      processEscapes: true
    }
  });
</script>

<script type="text/x-mathjax-config">
    MathJax.Hub.Config({
      tex2jax: {
        skipTags: ['script', 'noscript', 'style', 'textarea', 'pre', 'code']
      }
    });
</script>

<script type="text/x-mathjax-config">
    MathJax.Hub.Queue(function() {
        var all = MathJax.Hub.getAllJax(), i;
        for(i=0; i < all.length; i += 1) {
            all[i].SourceElement().parentNode.className += ' has-jax';
        }
    });
</script>

<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>
```

Then add the following line before the end of the last `div` tag in `themes/hueman/layout/layout.ejs`

``` html
<%- partial('plugin/mathjax') %>
```

The whole `layout.ejs` file looks like this:

``` html
<%- partial('common/head') %>
<body>
    <div id="wrap">
        <%- partial('common/header', null, {cache: !config.relative_link}) %>
        <div class="container">
            <div class="main-body container-inner">
                <div class="main-body-inner">
                    <section id="main">
                        <%- partial('common/content-title') %>
                        <div class="main-body-content">
                            <%- body %>
                        </div>
                    </section>
                    <%- partial('common/sidebar') %>
                </div>
            </div>
        </div>
        <%- partial('common/footer', null, {cache: !config.relative_link}) %>
        <%- partial('common/scripts') %>
        <%- partial('plugin/mathjax') %>
    </div>
</body>
</html>
```

Open `./node_modules/marked/lib/marked.js` in your blog's root directory

Replace 

``` shell
escape: /^\\([\\`*{}\[\]()# +\-.!_>])/,
```

with

``` shell
escape: /^\\([`*\[\]()# +\-.!_>])/,
```

The above step is used to avoid the escaping of `\\`, `\{`, `\}`. Then replace

``` shell
em: /^\b_((?:[^_]|__)+?)_\b|^\*((?:\*\*|[\s\S])+?)\*(?!\*)/,
```

with

``` shell
em: /^\*((?:\*\*|[\s\S])+?)\*(?!\*)/,
```

to remove the conversion of `_`

Then run the following command to deploy your blog

``` shell
hexo clean && hexo g -d
```

It should work now.

But today I found a new problem. You cannot write two successive curly braces.

I guess it's because hexo tries to takes curly braces as part of a tag. I don't have enough time to figure out how to let hexo accept it as a math expression rather than a tag. Currently I will just add a space between two curly braces. Just like `{ {`. It works great. If you have better idea how to deal with it, you can leave it in the comment below.

# Original answer
Hexo doesn't support mathjax by default. To make it work, we need to introduce mathjax to our theme. Take my current theme `hueman` as an example.

Create a new file called `mathjax.ejs` in `themes/hueman/layout/plugin`, and add the following contents in it.

``` html
<!-- mathjax config similar to math.stackexchange -->

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({
    tex2jax: {
      inlineMath: [ ['$','$'], ["\\(","\\)"] ],
      processEscapes: true
    }
  });
</script>

<script type="text/x-mathjax-config">
    MathJax.Hub.Config({
      tex2jax: {
        skipTags: ['script', 'noscript', 'style', 'textarea', 'pre', 'code']
      }
    });
</script>

<script type="text/x-mathjax-config">
    MathJax.Hub.Queue(function() {
        var all = MathJax.Hub.getAllJax(), i;
        for(i=0; i < all.length; i += 1) {
            all[i].SourceElement().parentNode.className += ' has-jax';
        }
    });
</script>

<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>
```

Then add the following line before the end of the last `div` tag in `themes/hueman/layout/layout.ejs`

``` html
<%- partial('plugin/mathjax') %>
```

The whole `layout.ejs` file looks like this:

``` html
<%- partial('common/head') %>
<body>
    <div id="wrap">
        <%- partial('common/header', null, {cache: !config.relative_link}) %>
        <div class="container">
            <div class="main-body container-inner">
                <div class="main-body-inner">
                    <section id="main">
                        <%- partial('common/content-title') %>
                        <div class="main-body-content">
                            <%- body %>
                        </div>
                    </section>
                    <%- partial('common/sidebar') %>
                </div>
            </div>
        </div>
        <%- partial('common/footer', null, {cache: !config.relative_link}) %>
        <%- partial('common/scripts') %>
        <%- partial('plugin/mathjax') %>
    </div>
</body>
</html>
```

Then mathjax would be introduced into our blog. Our work should be done. But unfortunately this is not the case, because the default markdown rendering engine would accidently render some of our mathjax code, which would of course disturb the rendering of mathjax later on. To solve this problem, we need to replace hexo's rendering engine as `pandoc`. First install pandoc on your system. I'm using arch, so the command is

``` shell
sudo pacman -S pandoc
```

Then install `hexo-render-pandoc`. Run the following command in your blog's root directory.

``` shell
npm install hexo-renderer-pandoc --save
```

OK, everything is done. Write a blog containing any mathjax formula and run the following command to deploy it to your server.

``` shell
hexo clean && hexo g -d
```

# Reference

1. [搭建一个支持LaTEX的hexo博客](http://blog.csdn.net/emptyset110/article/details/50123231)
