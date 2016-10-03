title: Specify Port For Hexo Git Deployment
date: 2015-12-17 21:11:12
tags: [hexo, git]
thumbnail: https://avatars2.githubusercontent.com/u/6375567?v=3&s=400
categories: Coding
---

Usually if you want to deploy your hexo posts with git, you can add the following lines to your _config.yml file:

```
# Deployment
## Docs: http://hexo.io/docs/deployment.html
deploy:
  type: git
  repo: git@example.com:blog.git
  branch: master
  message:
```

And hexo would deploy your posts if you run `hexo deploy`, and it will use port 22 (because git uses ssh or https protocal to access server, and hexo will use `git under ssh` by default). What if the ssh port of your server is not 22? Say it's port 20000, what can you do? You can change the contents to the following lines:

```
# Deployment
## Docs: http://hexo.io/docs/deployment.html
deploy:
  type: git
  repo: ssh://git@example.com:20000/home/git/blog.git
  branch: master
  message:
```

Run `hexo deploy`, and it works too. Hooray!
