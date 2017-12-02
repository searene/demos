title: Serialization and Deserialization in Java
date: 2017-05-10 10:01:24
tags: Java
categories: Coding
thumbnail: /images/serialization.jpg
---

## Introduction

**Serialization:** a process which converts a Java instance into a bunch of bytes, so it can be stored in disk/database or transferred through network.

**Deserialization:** the opposite of *Serialization*, in which a Java instance is extracted and recovered from disk/database/network.

## How to serialize and deserialize?

To make the *Serialization* and *Deserialization* work for a Java class, you only need to *implement Serializable* in most cases.

In the following example, we will create a class called `Address`, serialize it using `WriteObject` and deserialize it using `ReadObject`.

```java
package com.example;

import java.io.Serializable;

public class Address implements Serializable {

  private String street;
  private String country;

  public void setStreet(String street) {
    this.street = street;
  }

  public void setCountry(String country) {
    this.country = country;
  }

  public String getStreet() {
    return this.street;
  }

  public String getCountry() {
    return this.country;
  }

  @Override
    public String toString() {
      return " Street : " +
        this.street +
        " Country : " +
        this.country;
    }
}
```

```java
package com.example;

import java.io.FileOutputStream;
import java.io.ObjectOutputStream;

public class WriteObject{

  public static void main (String args[]) {

    Address address = new Address();
    address.setStreet("wall street");
    address.setCountry("united states");

    try{

      FileOutputStream fout = new FileOutputStream("c:\\address.ser");
      ObjectOutputStream oos = new ObjectOutputStream(fout);
      oos.writeObject(address);
      oos.close();
      System.out.println("Done");

    }catch(Exception ex){
      ex.printStackTrace();
    }
  }
}
```

```java
package com.example;

import java.io.FileInputStream;
import java.io.ObjectInputStream;

public class ReadObject{

  public static void main (String args[]) {

    Address address;

    try{

      FileInputStream fin = new FileInputStream("c:\\address.ser");
      ObjectInputStream ois = new ObjectInputStream(fin);
      address = (Address) ois.readObject();
      ois.close();

      System.out.println(address);

    }catch(Exception ex){
      ex.printStackTrace();
    }
  }
}
```

First, run `WriteObject` to *Serialize* `Address` into `C:\address.ser`, you can change it to another path if you use *Linux* or *Mac**OS*.

Then run `readObject` to *Deserialize* `Address` from `C:\address.ser`. And you can see from the console that we have obtained the serialized data in `C:\address.ser`.

```
Street : wall street Country : united states
```

The whole process is illustrated as follows.

#### Serialization

![Serialization](/images/Serialization-and-Deserialization-in-Java.svg)

#### Deserialization

![Deserialization](/images/Serialization-and-Deserialization-in-Java-1.svg)

What happened in the background was that Java serialized each field in `address`(aka. `street` and `country`) into disk and read it when the deserialization was done. But does Java know how to serialize/deserialize `street` and `country`? Yes, because they are of type *String*, which also *implements Serializable*, and Java has its own rules to convert a String instance into a stream of bytes, so they can be written into disk.

Everything seems to be working fine, right? No, because you forgot to add `serialVersionUID` in `Address`. The correct version is this.

```java
package com.example;

import java.io.Serializable;

public class Address implements Serializable{

  // NOTICE HERE!
  private static final long serialVersionUID = 1L;

  private String street;
  private String country;

  public void setStreet(String street){
    this.street = street;
  }

  public void setCountry(String country){
    this.country = country;
  }

  public String getStreet(){
    return this.street;
  }

  public String getCountry(){
    return this.country;
  }

  @Override
    public String toString() {
      return " Street : " +
        this.street +
        " Country : " +
        this.country;
    }
}
```

What is `serialVersionUID`? and why should I add it? Basically `serialVersionUID` is simply a number that is written into disk along with the serialized instance. And in the process of deserialization, Java checks whether the serialized `serialVersionUID` is the same as the one declared in class. If not, an exception will be thrown and deserialization will fail. It is used to make sure the serialized instance is compatible with the current class.

#### Where Can I Get serialVersionUID?

`serialVersionUID` can be set manually by the programmer with any number, or you can generate one using *serialver* provided by Oracle.

#### What Will Happen If I Don’t Set serialVersionUID?

Java will generate one for you based on class name, implemented interfaces, etc. But this is **highly discouraged**. Quote from Oracle doc:

> It is strongly recommended that all serializable classes explicitly declare `serialVersionUID` values, since the default `serialVersionUID` computation is highly sensitive to class details that may vary depending on compiler implementations, and can thus result in unexpected `serialVersionUID` conflicts during deserialization, causing deserialization to fail.

For example, if you don’t set `serialVersionUID` manually, Java may generate a `serialVersionUID = 12345` for you in the process of serialization. However, the deserializing program may use a different JVM and the `serialVersionUID` it gets may be `123456`, which is different because of different calculation algorithms. Then the program finds that the two `serialVersionUIDs` don’t match and throws an exception to tell the user that the deserialization fails.

#### When should I update the serialVersionUID value?

You should update `serialVersionUID` when some incompatible fields are added to the class and it’s no longer possible to be support the old version.

That’s it. Below are some links that I found helpful when I was writing the article.

*   [https://www.mkyong.com/java-best-practices/understand-the-serialversionuid/](https://www.mkyong.com/java-best-practices/understand-the-serialversionuid/)
*   [http://stackoverflow.com/questions/285793/what-is-a-serialversionuid-and-why-should-i-use-it](http://stackoverflow.com/questions/285793/what-is-a-serialversionuid-and-why-should-i-use-it)
