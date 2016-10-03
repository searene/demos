title: 'django.db.utils.IntegrityError: duplicate key value violates unique constraint'
date: 2016-01-10 13:23:57
tags: [python, django]
categories: Coding
thumbnail: http://blog.djangostars.com/content/images/2015/12/maxresdefault.jpg
---

# Error
Recently I ran into a problem, which bugged me for days. I'm using django and spirit to build a website, there's a model called category in spirit, which is like this

```python
class Category(models.Model):
		...
    title = models.CharField(_("title"), max_length=75)
    description = models.CharField(_("description"), max_length=255, blank=True)
		...
```

The only thing you need to know is that, there's no such thing as an `id` in the model, which means django and postgresql will take care of the primary key. It seems fine, right? Until I ran a test, which created a category:

```python
class UserViewTest(TestCase):

    def setUp(self):
        cache.clear()
        self.category = utils.create_category()

    def simple_test(self):
        self.assertEqual(1, 1)
```

This is a very simple test, `create_category` is only responsible for creating a brand new category. Everything should work fine. Then I got an error:

```
django.db.utils.IntegrityError: duplicate key value violates unique constraint "spirit_category_category_pkey"
DETAIL:  Key (id)=(1) already exists.
```

# Try to find the reason
Is there an already existing `Key (id)=(1)`? I leafed through the migration file, and found this:

```python
if not Category.objects.filter(pk=settings.ST_TOPIC_PRIVATE_CATEGORY_PK).exists():
		Category.objects.create(
				pk=settings.ST_TOPIC_PRIVATE_CATEGORY_PK,
				title="Private",
				slug="private",
				is_private=True
		)

if not Category.objects.filter(pk=settings.ST_UNCATEGORIZED_CATEGORY_PK).exists():
		Category.objects.create(
				pk=settings.ST_UNCATEGORIZED_CATEGORY_PK,
				title="Uncategorized",
				slug="uncategorized"
		)
```

So django will create two default categories due to the migration file. OK, that's fine. But why did postgresql insert a record with a `Key (id)=(1)` instead of `Key (id)=(3)`? Maybe it's django's fault? Maybe django was trying to insert a specified record with `Key (id)=(1)`? To find out the reason, I debugged all the way to this part:

```python
def execute(self, sql, params=None):
	self.db.validate_no_broken_transaction()
	with self.db.wrap_database_errors:
		if params is None:
			return self.cursor.execute(sql)
		else:
			return self.cursor.execute(sql, params)
```

This was where the insert happened. I checked the sql and params, which was:

```python
sql = 'INSERT INTO "spirit_category_category" ("parent_id", "title", "slug", "description", "is_global", "is_closed", "is_removed", "is_private") VALUES (%s, %s, %s, %s, %s, %s, %s, %s) RETURNING "spirit_category_category"."id"'
params = (None, 'category_foo2', 'categoryfoo2', '', True, False, False, False)
```

So django didn't include the `id` part, but why didn't postgresql auto increment the `id`? After searching online for a long time, I found [this website](http://centoshowtos.org/web-services/django-and-postgres-duplicate-key/). I followed its process and ran the following code to find out the `last_value` of the `id` sequence(the primary key is usually a sequence in postgresql if you use django to generate the tables automatically)

```SQL
SELECT last_value from spirit_category_category_id_seq;
```

And the answer I got was `1`. It's ONE! What does it mean? It means the next `id` to be generated will be `1`. This is so not what we want. This is why the error happened.

# Fix the problem
Let's alter it to `3`.

```SQL
alter sequence spirit_category_category_id_seq restart with 3
```

Continue the test, and you will pass it. Wait, this is a test, right? So the next time you run the test, it will create all kinds of brand new tables again in order to start a fresh test. So it's meaningless to alter the sequence, because it would be flushed. Don't believe it? Run the test again, and it will fail.

# Fix it for a test
So how to fix this? Just remove the line which `id` was specified in the migration file, i.e. let postgresql handle the primary key for us. Don't insert the primary key manually, don't try to calculate the next avaible id number, you will mess it up. In my case, I just need to remove the following two lines in file `0002_auto_20150728_0442.py`

```python
pk=settings.ST_TOPIC_PRIVATE_CATEGORY_PK,
pk=settings.ST_UNCATEGORIZED_CATEGORY_PK,
```

Run the test again, it will pass.

# Conclusion
It's a long story, I've debugged for days to find out the reason, but it's totally fine. Though the solution is quite simple, I have to fight all the way to find. During the process, I read a lot of django source code, I learned a lot of python features. I learned how postgresql's sequence worked. It's very helpful to me.
