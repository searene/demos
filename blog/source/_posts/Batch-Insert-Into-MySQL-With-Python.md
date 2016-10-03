title: Batch Insert Into MySQL With Python
date: 2015-12-07 19:50:29
categories: Coding
tags: [mysql, python]
thumbnail: https://upload.wikimedia.org/wikipedia/en/thumb/6/62/MySQL.svg/1280px-MySQL.svg.png
---

I have a database in mysql which called `testdb`, wherein lies a table named `log`, the structure of the table is as followed.

```
MariaDB [testdb]> describe log;
+---------+-------------+------+-----+---------+----------------+
| Field   | Type        | Null | Key | Default | Extra          |
+---------+-------------+------+-----+---------+----------------+
| id      | int(11)     | NO   | PRI | NULL    | auto_increment |
| name    | varchar(50) | YES  |     | NULL    |                |
| logtime | datetime    | YES  |     | NULL    |                |
+---------+-------------+------+-----+---------+----------------+
3 rows in set (0.03 sec)
```

So basically what I want do is to insert millions of records into the table to test the speed and stuff. Since it's impossible for me to achieve this goal manually, I have to write a python script. This is what the script is like.

```python
import datetime, random, string, MySQLdb, multiprocessing, timeit

def worker():
    conn = MySQLdb.connect(host="localhost",
                           user="root",
                           passwd="123",
                           db="testdb")
    c = conn.cursor()
    c.execute("""select count(*) from log""")
    num = c.fetchone()[0]

    for i in range(100000):
        year = random.choice([y for y in range(2010, 2015)])  # the generated year is from 2010 to 2015
        month = random.choice([m for m in range(1, 13)])
        day = random.choice([d for d in range(1, 29)])
        hour = random.choice([h for h in range(0, 24)])
        minute = random.choice([m for m in range(0, 60)])
        second = random.choice([s for s in range(0, 60)])

        name = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(10))
        t = datetime.datetime(year, month, day, hour, minute, second).strftime('%Y%m%d%H%M%S')

        try:
            c.execute("""INSERT INTO log (name, logtime) VALUES (%s,%s)""", (name, t))
            conn.commit()
            num = num + 1
            # the num here is not the accurate current record number, it's just roughly right because of poor multiprocessing mishandling. The num is not very important here, so just take it easy.
            print num, "name = {}, logtime = {}".format(name, t)
        except:
            conn.rollback()
    conn.close()

if __name__ == '__main__':
    jobs = []
    start = timeit.default_timer()
    for i in range(10):
        p = multiprocessing.Process(target=worker)
        jobs.append(p)
        p.start()
```

The above script could insert 100000 * 10 = 1000000 records into the table. To use this script, you have to install `mysqldb` module, this is the way to install it(from [stackoverflow](https://stackoverflow.com/questions/454854/no-module-named-mysqldb)).

> easy_install mysql-python (mix os) pip install mysql-python (mix os)
> apt-get install python-mysqldb (Linux Ubuntu, ...) cd
> /usr/ports/databases/py-MySQLdb && make install clean (FreeBSD) yum
> install MySQL-python (Linux Fedora, CentOS ...)
