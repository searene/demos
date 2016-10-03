title: set up a git server to deploy with hexo
date: 2015-12-05 09:52:25
tags: [git]
categories: Coding
thumbnail: https://dab1nmslvvntp.cloudfront.net/wp-content/uploads/2016/03/1458791372git.png
---

# Preface

I used `rsync` to deploy my website for the past few days, but it seemed that there were some bugs with `hexo rsync deployment`, I could only use rsync by running `rsync -a localfiles username@server:/remote/path` manually instead of simply `hexo deploy`. Instead of looking for the reason why `rsync` doesn't work in hexo, I decided to set up a git server for deployment, because git provides an extra version control feature, which might come in handy sometime in the future. It actually took me a lot of time to do this because there were little information on the Internet regarding it, so writing a blog to record this process is important, I think.

# Nginx

First we need to set up an nginx on the server, I use `centos`, so the command works for me

```
sudo yum install nginx
```

If you are using ubuntu, the following command would work for you

```
sudo apt-get install nginx
```

When the installation finishes, start your nginx

```bash
sudo service nginx start
```

You can test whether `nginx` works or not by typing in your server's IP address on your client.

# Git Server

## Create A User Name On The Server For Git Sync

To set up a git server, the first thing we need to do is to create a username for it, let's call it `git`, you should run this command on your server.

```bash
useradd git
```

It will prompt you for a password.

## Create A SSH Key Pair To Avoid Typing In Password Every Time

To avoid typing in the password every time we use `git`, we need to set up a ssh key pair. Run the command on your client.

```bash
ssh-keygen -t rsa
```

Just punch `enter` when a prompt shows up. Then you will find a file called `id_rsa.pub` in `.ssh` folder of your home directory, this is the public key. Now turn to the server, switch your username to git.

```bash
su git
```

create a `.ssh` foler in your git home directory

```bash
mkdir ~/.ssh
```

create a file named `authorized_keys` to save the accepted public keys

```bash
touch ~/.ssh/authorized_keys
```

Now turn to your client side, run the following command to add your client's public key to your server, notice that you should replace the IP address with yours.

```bash
cat .ssh/id_rsa.pub | ssh user@123.45.56.78 "cat >> ~/.ssh/authorized_keys"
```

Change the permissions to avoid others modifying your ssh key pair

```bash
chmod 700 ~/.ssh && chmod 400 ~/.ssh/authorized_keys
```

## Set Up A Bare Local Repository On The Server

OK, the next time you log on to your server with the user name `git`, you won't need the password anymore. Now Let's turn to the server side and set up a bare local repository

```bash
git init --bare website.git
```

## Use The Remote Repository On The Client

Now turn to your client, go to the hexo directory, install hexo-deployer-git

```bash
npm install hexo-deployer-git --save
```

Then find the `_config.yml` file and open it. Add the following lines at the end of the file. Notice that you should replace the IP address with your server's. If there is other deployment setting in your file like this, please remove it.

```
deploy:
  type: git
  repo: git@123.456.78.90:website.git
  branch: master
  message:
```

Let's use git to sync our website to the server

```bash
hexo generate && hexo deploy
```

If nothing error occurs, you're successful till now.



## Use Git Hook To Deploy Your Website Automatically On Your Server

Now that you've synced your website to the server, but you cannot find these files on your server, why? In fact, it took me a lot of time to search for my website in the `website.git` folder, but I just couldn't find it. After gleaning information on the Internet, I realized that my website is still on my server, but not in the way it is stored on my client. Those website files are stored as the `object` in the `git bare repository`, you cannot *see* those files, but you can `pull` or `clone` them.

So what we need do is deploy these synced files to our web server's root directory. Go to your nginx's root directory (it's usually `/usr/share/nginx/html`, but I noticed that it's `/var/www/html` on ubuntu 15.10), set up a git repository and add the remote server(localhost, actually)

```bash
git init /usr/share/nginx/html && git remote add origin git@localhost:website.git
```

To enable `git` user the permission to modify our website, we need to change the ownership of those files to `git`

```bash
chown git:git /usr/share/nginx/html -R
```

Set up the git hook for deployment, it will automatically sync your files from `website.git` to `/usr/share/nginx/html` every time it receives a `push` operation.

```bash
su git
cd ~/website.git/hooks/
cat <<EOT > post-receive
#!/bin/sh

unset $(git rev-parse --local-env-vars)
cd /usr/share/nginx/html
git fetch origin
git reset --hard origin/master
EOT
```

To avoid the authorization issue, add the public key of `root` to the `authorized_keys` of user `git`

```bash
su # switch to user root
cat ~/.ssh/id_rsa.pub >> /home/git/.ssh/authorized_keys
```


# Test The Result

OK, now we are ready to go. Turn to the client side and deploy your files with hexo-git-deployer

```bash
cd /path/to/your/hexo/root/directory
rm .deploy_git #remove the previous deployment info
hexo generate && hexo deploy
```

Then check your website on your server.

# Conclusion

This is a long story for me. So there might be something that I didn't mention, or you get confused about something in the post. If so, please leave a comment below to let me know, I'd like to help you.
