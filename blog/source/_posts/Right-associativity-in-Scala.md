title: Right associativity in Scala
date: 2017-10-07 13:07:50
tags: Scala
categories: Coding
thumbnail: /images/do-the-right-thing.jpg
---

We define two methods here, `++` and `++:`

```scala
class Foo {
  def ++(n: Int): Unit = println(n + 1)
  def ++:(n: Int): Unit = println(n + 1)
}
object ValFunctionTest {
  def main(args: Array[String]): Unit = {
    val foo = new Foo
    foo.++(1)
    foo.++:(1)
  }
}
```

Nothing special, right? Yes, for now, until we try removing the parentheses in it.

```scala
class Foo {
  def ++(n: Int): Unit = println(n + 1)
  def ++:(n: Int): Unit = println(n + 1)
}
object ValFunctionTest {
  def main(args: Array[String]): Unit = {
    val foo = new Foo
    foo ++ 1
    1 ++: foo
    
    foo ++: 1 // error
    1 ++ foo // error
  }
}
```

So the difference is, `foo` can only be placed on the *left* side when using `++`, and it can only be placed on *right* side when using `++:`. The latter is called *right associativity*, and **methods ending with : are used in the right associativity**.