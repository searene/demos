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
             'name' : 'blog'},
            {'file':'/home/searene/Documents/life_blog/source/_posts',
             'count': 3,
             'name': 'life_blog'},
            {'file': '/home/searene/Development',
             'count': 10,
             'name': 'Development'},
            {'file': '/home/searene/.vimrc',
             'count': 3,
             'name': 'vimrc'},
            {'file': '/home/searene/.virtualenvs',
             'count': 3,
             'name': 'virtualenvs'},
            {'file': '/home/searene/Tools/backupMega.py',
             'count': 3,
             'name': 'backupMega'},
            {'file': '/home/searene/Music',
             'count': 10,
             'name': 'Music'}
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
