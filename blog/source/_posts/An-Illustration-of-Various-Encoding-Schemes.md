title: An Illustration of Various Encoding Schemes
date: 2017-05-13 22:04:58
tags: encoding
categories: Coding
thumbnail: /images/green-lit-numbers.jpg
---

## What are encoding schemes?

Encoding schemes are ways to store and retrieve characters in computers. For example, in `ISO-8859-1`(which is one of various encoding schemes), we use `01100001` to denote `a`, and `00111111` to denote `?`. Because computers only know how to store and fetch `0` and `1`, we must have a way to store other characters like alphabets, or even Chinese characters.

## Some of the frequently used encoding schemes

**ISO-8859-1**

ISO-8859-1 is also called LATIN-1, which is a deprecated encoding scheme. It can only store the 256 characters in the ASCII table.

For example, let’s write a text file with the following contents:

```
&1231208ABCabc中文
```

Let’s see how the computer stores it. Type the command `xxd -b resources/test/ASCII.txt` to display the real contents the computer stores.

```
00000000: 00100110 00110001 00110010 00110011 00110001 00110010 &12312
00000006: 00110000 00111000 01000001 01000010 01000011 01100001 08ABCa
0000000c: 01100010 01100011 00111111 00111111 bc??
```

We can see that `&` was stored as `00100110`, and `1` was stored as `00110001`. This is exactly how ISO-8859-1 processes characters. It maps each character to a unique byte. Refer to the code page displayed in [Wikipedia](https://en.wikipedia.org/wiki/ISO/IEC*8859-1) to see the map. Because ISO-8859-1 doesn’t have a way to store Chinese characters, we can see that 中文 are mapped to

Because ISO-8859-1 doesn’t have a way to store Chinese characters, we can see that 中文 are mapped to `00111111 00111111`, which are just two question marks in ISO-8859-1.

**Unicode**

You may notice that ISO-8859-1 can only store 256 characters, this is not enough. How can we store Chinese characters, which include way more characters than 256? Here comes *Unicode*.  
Unicode is a computing industry standard that is able to store millions of characters in computers. Basically it’s just a huge map, which maps every character in this world to a number, which takes 1 ~ 4 bytes depending on what the character is.

For example, `A` is mapped to `0x41`, `w` is mapped to `ox77`, `中` is mapped to `0x4E2D`. Each character in this world has its number mapped. You can find the whole mapping table in [here](https://unicode-table.com/en/#control-character).

**UTF-8**

*Unicode* may have solved the problem, right? Why would we need *UTF-8*, and what is *UTF-8*? To find out the reason, first we need to find out if *Unicode* could solve our problem directly.

Say I want to store `AA` on my disk. In Unicode, `A` is mapped to `0x41`, so what I need to do is just store `0x4141` in my computer, right? No, it’s not going to work. How can we know what `0x4141` is if we try to decode it? Is it `AA`, or just a character whose mapping number is exactly `0x4141`? Because a Unicode character takes 1 ~ 4 bytes, you will never know the boundary of each character if you store it directly on the disk.

How can we solve the problem? The simplest method is to store each character in 4 bytes, if a character’s mapping number is less than 4 bytes, left padding it with zeros, so `A` would become `0x00000041` instead of just `0x41`, that’s a way, it would work, but since most characters take less than 4 bytes in Unicode, it would waste a lot of space if we use this method. So here comes UTF-8.

In UTF-8, the first 128 characters in the ASCII table take only 1 byte each.  
For those characters, the first bit in each byte is 0\. When we need to denote a character that is not one of those characters, like `中`, which takes 2 bytes in Unicode, we set the first bit of its first byte to 1, and set the rest bits according to the Unicode Standard. More detailed can be seen from [here](https://en.wikipedia.org/wiki/UTF-8#Description).

**So we can say that Unicode is just a standard, UTF-8 is a way to implement the standard, which specifies in detail how to store the Unicode number onto disk.**
