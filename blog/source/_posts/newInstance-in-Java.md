title: newInstance in Java
date: 2017-10-03 17:03:53
tags: Java, Scala
categories: Coding
thumbnail: /images/new-bingo-sites.png
---

# Introduction

`newInstance` is used to instantiate an instance of a class dynamically. Here is an example written in Scala.

```scala
class Printer() {
  def print(): Unit = {
    println(s"print something")
  }
}
object ScalaTest {
  def main(args: Array[String]): Unit = {
    val testClass = Class.forName("Printer").newInstance().asInstanceOf[Printer]
    testClass.print()
  }
}
```

**Output**

```
print something
```

By the way, `asInstanceOf[Printer]` is used for casting in Scala, it's just like `(Printer) Class.forName("Printer").newInstance()` in Java.

What if we want to call Printer's constructor with arguments? We can use `getDeclaredConstructor`

```scala
class Printer(val name: String, val description: String) {
  def print(): Unit = {
    println(s"product name: $name, description: $description")
  }
}
object ScalaTest {
  def main(args: Array[String]): Unit = {
    val testClass = Class.forName("Printer")
      .getDeclaredConstructor(classOf[String], classOf[String])
      .newInstance("kindle", "used for reading")
      .asInstanceOf[Printer]
    testClass.print()
  }
}
```

**Output**

```
product name: kindle, description: used for reading
```