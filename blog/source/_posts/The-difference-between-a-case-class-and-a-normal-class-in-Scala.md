title: The difference between a case class and a normal class in Scala
date: 2017-10-06 09:03:48
tags: Scala
categories: Coding
thumbnail: /images/scala-logo.png
---

# What is a case class like

```scala
case class Person(name: String)

object CaseClassTest {
  def main(args: Array[String]): Unit = {
    val person = Person("John")
    println(person.toString)
  }
}
```

# Can be Instantiated without the new keyword

Case classes have prebuilt companion objects with `apply()` implemented, so a case class can be instantiated without using `new`.

```scala
case class Person(name: String)

object CaseClassTest {
  def main(args: Array[String]): Unit = {

    // Both ways have the same effect
    val person1 = Person("John")
    val person2 = new Person("John")
  }
}
```

Why removing the `new` keyword? Because case classes are often used to implement [algebraic data types](https://en.wikipedia.org/wiki/Algebraic_data_type), it's more elegant to do so without the `new` keyword.

# Default equals and hashCode implementation

Case classes have default equals and hashCode implementations. Let's pick `equals` and talk about it in this part, because it's easier to verify.

```scala
case class Person(name: String)

object CaseClassTest {
  def main(args: Array[String]): Unit = {
    val person1 = Person("John")
    val person2 = Person("John")
    println(person1 == person2) // true
  }
}
```

Because Case classes have default `equals` implementation, so although `person1` and `person2` are different objects(I'm talking about their references), they are still equal because Scala only checks field values(`name` in this case) for case classes.

The result is different if we use a normal class, which compares equality by references.

```scala
class Person(name: String)

object CaseClassTest {
  def main(args: Array[String]): Unit = {
    val person1 = new Person("John")
    val person2 = new Person("John")
    println(person1 == person2) // false
  }
}
```

# Serializable

Case classes can be serialized.

```scala
import java.io.{FileOutputStream, ObjectOutputStream}

case class Person(name: String)

object CaseClassTest {
  def main(args: Array[String]): Unit = {

    // creat an instance
    val person = Person("John")

    // serialize
    val oos = new ObjectOutputStream(new FileOutputStream("/tmp/person"))
    oos.writeObject(person)
    oos.close()
  }
}
```

A normal class cannot be serialized by default.

```scala
class Person(name: String)

object CaseClassTest {
  def main(args: Array[String]): Unit = {

    // creat an instance
    val person = new Person("John")

    // serialize
    val oos = new ObjectOutputStream(new FileOutputStream("/tmp/person"))
    oos.writeObject(person) // Exception in thread "main" java.io.NotSerializableException: com.example.Person
    oos.close()
  }
}
```

# Better toString

```scala
package com.example

case class Person(name: String)
class Animal(name: String)

object CaseClassTest {
  def main(args: Array[String]): Unit = {

    val person = Person("John")
    val animal = new Animal("Dog")

    println(person.toString) // Person(John)
    println(animal.toString) // com.example.Animal@5a39699c
  }
}
```

# Pattern Matching

Case classes support pattern matching.

```scala
package com.example

abstract class Animal
case class Dog() extends Animal
case class Cat() extends Animal

object CaseClassTest {
  def main(args: Array[String]): Unit = {
    val animal = Dog()
    printType(animal)
  }
  def printType(animal: Animal): Unit = {
    animal match {
      case Dog() => println("It's a dog.")
      case Cat() => println("It's a cat.")
    }
  }
}
```

Can we achieve pattern matching using a normal class? Of course, just implement the `unapply` method, here is an example.

```scala
package com.example

abstract class Animal
class Dog() extends Animal
class Cat() extends Animal
object Dog {
  def apply(): Dog = new Dog()
  def unapply(arg: Animal): Boolean = arg.isInstanceOf[Dog]
}
object Cat {
  def apply(): Cat = new Cat()
  def unapply(arg: Animal): Boolean = arg.isInstanceOf[Cat]
}

object CaseClassTest {
  def main(args: Array[String]): Unit = {
    val animal = Dog()
    printType(animal)
  }
  def printType(animal: Animal): Unit = {
    animal match {
      case Dog() => println("It's a dog.")
      case Cat() => println("It's a cat.")
    }
  }
}
```

So we can use pattern matching with normal classes, but with case classes, we don't need to write those boilerplate code any more.

# Case classes extend the Product class

Case classes extend the `Product` class, so it has some methods inherited from it, like `productArity`

```scala
case class Person(name: String, address: String)
object CaseClassTest {
  def main(args: Array[String]): Unit = {
    val person = Person("John", "Earth")
    println(person.productArity) // 2, the size of the product, i.e. the number of arguments
  }
}
```

# Other Interesting stuff

Case classes also have other interesting stuff, e.g. we can copy a case class by calling `copy` on it.

```scala
case class Person(name: String, address: String)
object CaseClassTest {
  def main(args: Array[String]): Unit = {
    val person = Person("John", "Earth")

    val copiedPerson = person.copy()
    println(copiedPerson) // Person(John,Earth)

    val copiedPersonWithModifiedName = person.copy("Johnson")
    println(copiedPersonWithModifiedName) // Person(Johnson,Earth)
  }
}
```

I think I've covered almost all the interesting parts of case classes, you can check the official Scala docs for more details.