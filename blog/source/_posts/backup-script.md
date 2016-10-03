title: backup script
date: 2015-12-27 22:50:08
tags: [python, linux]
categories: Coding
thumbnail: http://3.bp.blogspot.com/-K8PhVRHMmMQ/TyExkSKTRoI/AAAAAAAAFR0/zO8hnnIRykc/s1600/backup.png
---

Recently I made a backup script with python2.7, and it worked fine by now. So I think it might be a good idea to share it here.

# Install megaFuse

The first thing you need to do is to install [megaFuse](https://github.com/matteoserva/MegaFuse)

## Install additional packages:

```bash
sudo apt-get install libcrypto++-dev libcurl4-openssl-dev libdb5.1++-dev libfreeimage-dev libreadline-dev libfuse-dev
```

## Compile megaFuse

```bash
cd MegaFuse
make
```

## Fill in your mega username, password and mountpoint in `megafuse.conf`, just as follows:

```
USERNAME = username@email.com
PASSWORD = your_password
MOUNTPOINT = /media/mega
```

## Enable MegaFuse

```bash
sudo ./MegaFuse -f -o allow_other -o uid=1000
```

## Run MegaFuse at system boot

Save the following code as a bash file, e.g. `start_mega.sh`. Then run the file automatically every time the OS boots by using `Startup Applications` on ubuntu, note that you should modify `/path/to/MegaFuse` to the correct one

```bash
#!/bin/bash

sleep 100
echo "yourpassword" | sudo -S /path/to/MegaFuse/MegaFuse -c /path/to/MegaFuse/megafuse.conf -f -o allow_other -o uid=1000
```

Why do you need `sleep 100`? I don't know either. I tried to add the line `/path/to/MegaFuse -c /path/to/megafuse.conf -f -o allow_other -o uid=1000` in the file `/etc/rc.local` before, but it failed. I don't know why. And it almost caused my PC fail to boot because it output way too many errors in `/var/log/syslog` file. Finally I decided to put it in `Startup Applications`. Notice that I used `sudo` here, and you have to put your password in plaintext. This is a security risk. But I don't know to make it work without it, because you need to have root permission to mount it. If you know how to work without `sudo`, I'd like to hear your opinion.

# MegaTools

You also need [MegaTools](https://megatools.megous.com/) to run this script, I put the tools in `/usr/local/bin/` to make it work.

```
~/Development/demos$ ls /usr/local/bin|grep mega
megacopy
megadf
megadl
megaget
megals
megamkdir
megaput
megareg
megarm
```

# my python backup script

My backup script was written with python. But I think maybe bash script would be easier. Anyway, this is my backup file

```python
#!/usr/bin/env python

import subprocess
import os
import datetime
import re
import logging

if __name__ == "__main__":

    # the location in mega where you want to put your files
    BACKUP_DIRECOTORY = "Backups"

    # local location in which mega was mounted using MegaFuse
    MOUNTED_LOCATION = "/media/mega"

    # BACKUP_LIST: files you want to back up
    #     file: the file that you want to backup
    #     count: how many versions you want to keep
    #     name: backup basename
    BACKUP_LIST = [
            {'file': '/var/www/html',
             'count': 3,
             'name': 'html'},
            {'file': '/home/searene/Documents/blog/source/_posts',
             'count': 3,
             'name' : 'blog'}
            ]

    devnull = open(os.devnull, 'w')

    if not os.path.exists(os.path.join(MOUNTED_LOCATION, BACKUP_DIRECOTORY)):
        os.makedirs(os.path.join(MOUNTED_LOCATION, BACKUP_DIRECOTORY))

    for f in BACKUP_LIST:
        today = datetime.datetime.today()
        backup_path = os.path.join(MOUNTED_LOCATION, BACKUP_DIRECOTORY, f['name'])
        if not os.path.exists(backup_path):
            os.makedirs(backup_path)
        backup_name = '{}-TIME-{}.tar.gz'.format(os.path.join(backup_path, f['name']), today.strftime("%Y-%m-%d-%H-%M-%S"))

        logging.info('tar...')
        subprocess.call(['tar', '-zcvf', backup_name, f['file']], stdout=devnull)
        file_list = subprocess.check_output(['/usr/local/bin/megals', backup_path]).split('\n')
        file_list = [x for x in file_list if re.match(r'{}-TIME-.*'.format(f['name']), x)]
        if len(file_list) > f['count']:
            redundant_files = sorted(file_list, reverse=True)[f['count']:]
            for f in redundant_files:
                logging.info('{} is deprecated, removing'.format(redundant_files))
                subprocess.call(['rm', os.path.join(backup_path, f)])
```

# run the backup script every day at 5:00pm

run `crontab -e`, add the following line

```
0 17 * * * python /home/searene/Tools/backupMega.py
```
