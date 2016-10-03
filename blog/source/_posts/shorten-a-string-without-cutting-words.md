title: shorten a string without cutting words
date: 2016-05-26 08:24:01
tags:
categories: Coding
thumbnail: http://blog.verticalresponse.com/wp-content/uploads/2015/11/words-blog2.jpg
---

# Question
How to shortening a string without cutting words? For example, I have a string called `Hello World`, whose length is 11. I want to shorten its length to less than 6, which would be `Hello W`, but `W` is not a full word, we need to remove it. So the result is ony a word `Hello`. The following code is to solve the problem, written in python.

# Code
```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-

import unittest

def break_word(src, length):
    if length <= 0:
        return ''
    elif length >= len(src):
        return src.rstrip()

    for i in range(length, -1, -1):
        if src[i] == ' ':
            return src[:i].rstrip()

    return ''

class TestBreakWord(unittest.TestCase):

    def test_breakword(self):

        # zero length
        self.assertEqual(break_word('Hello World', 0), '')

        # no word is hit
        self.assertEqual(break_word('Hello World', 2), '')

        # exactly a word
        self.assertEqual(break_word('Hello World', 5), 'Hello')

        # exactly a word plus a space
        self.assertEqual(break_word('Hello World', 6), 'Hello')

        # the second word isn't hit
        self.assertEqual(break_word('Hello World', 7), 'Hello')

        # exactly two words
        self.assertEqual(break_word('Hello World', 11), 'Hello World')

        # two spaces
        self.assertEqual(break_word('Hello  World', 5), 'Hello')
        self.assertEqual(break_word('Hello  World', 6), 'Hello')
        self.assertEqual(break_word('Hello  World', 7), 'Hello')
        self.assertEqual(break_word('Hello  World', 8), 'Hello')

        # space in the end
        self.assertEqual(break_word('Hello World ', 11), 'Hello World')
        self.assertEqual(break_word('Hello World ', 12), 'Hello World')

        # two spaces in the end
        self.assertEqual(break_word('Hello World  ', 11), 'Hello World')
        self.assertEqual(break_word('Hello World  ', 12), 'Hello World')
        self.assertEqual(break_word('Hello World  ', 13), 'Hello World')

if __name__ == '__main__':
    unittest.main()
```

# Result

``` zsh
./words.py

.
----------------------------------------------------------------------
Ran 1 test in 0.000s

OK

Process finished with exit code 0
```
