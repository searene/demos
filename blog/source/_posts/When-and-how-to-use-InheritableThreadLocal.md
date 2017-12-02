title: When and how to use InheritableThreadLocal
date: 2017-10-02 22:02:51
tags: multi-thread, java, scala
categories: Coding
thumbnail: /images/inherit.jpg
---

Today I was reading Spark's source code, and found `InheritableThreadLocal` in it. Little information could be found online about this class, so I decided to write a blog to illustrate how to use it, based on the experiments I did.

# ThreadLocal

Before diving into `InheritableThreadLocal`, we need to understand `ThreadLocal`. `ThreadLocal` is used to create separate variables for each thread, as follows.

```scala
class PrintRunnable extends Runnable {
  val number = new ThreadLocal[Double]

  override def run(): Unit = {
    number.set(Math.random())
    println(number.get())
  }
}

object SimpleApp {
  def main(args: Array[String]): Unit = {
    val printRunnable = new PrintRunnable

    val thread1 = new Thread(printRunnable)
    val thread2 = new Thread(printRunnable)

    thread1.start()
    thread2.start()

    thread1.join()
    thread2.join()
  }
}
```

**Output**

```
0.5157676349493098
0.37557496403907353
```

The above code is written in Scala.

As you can see, `thread1` and `thread2` have different values for `number`, because we use `ThreadLocal` here, so the result is different.

# InheritableThreadLocal

Now we decided to start a child thread within thread1/thread2, obtain the value of `number` and print it, can we achieve it?

```scala
class PrintRunnable extends Runnable {
  val number = new ThreadLocal[Double]

  override def run(): Unit = {
    number.set(Math.random())
    println(number.get())
    
    val childThread = new Thread(new Runnable {
      override def run(): Unit = {
        println(number.get())
      }
    })
    childThread.start()
    childThread.join()
  }
}

object SimpleApp {
  def main(args: Array[String]): Unit = {
    val printRunnable = new PrintRunnable

    val thread1 = new Thread(printRunnable)
    val thread2 = new Thread(printRunnable)

    thread1.start()
    thread2.start()

    thread1.join()
    thread2.join()
  }
}
```

**Output**

```
0.5475226099407153
0.8376546404552231
null
null
```

No, we cannot, because threadLocal cannot be passed into child threads. But what if we want it to do so? Just use `InheritableThreadLocal`!

```scala
class PrintRunnable extends Runnable {
  val number = new InheritableThreadLocal[Double]

  override def run(): Unit = {
    number.set(Math.random())
    println(number.get())

    val childThread = new Thread(new Runnable {
      override def run(): Unit = {
        println(number.get())
      }
    })
    childThread.start()
    childThread.join()
  }
}

object SimpleApp {
  def main(args: Array[String]): Unit = {
    val printRunnable = new PrintRunnable

    val thread1 = new Thread(printRunnable)
    val thread2 = new Thread(printRunnable)

    thread1.start()
    thread2.start()

    thread1.join()
    thread2.join()
  }
}
```

**Output**

```
0.006425375134899158
0.021932306310074368
0.006425375134899158
0.021932306310074368
```

Notice that we cannot set the value of InheritableThreadLocal in the child thread.

```scala
class PrintRunnable extends Runnable {
  val number = new InheritableThreadLocal[Double]

  override def run(): Unit = {
    number.set(Math.random())
    println(number.get())

    val childThread = new Thread(new Runnable {
      override def run(): Unit = {
        println(number.get())
        number.set(0.1)
      }
    })
    childThread.start()
    childThread.join()
    println(number.get())
  }
}

object SimpleApp {
  def main(args: Array[String]): Unit = {
    val printRunnable = new PrintRunnable
    val thread1 = new Thread(printRunnable)
    thread1.start()
    thread1.join()
  }
}
```

**Output**

```
0.7413853012849937
0.7413853012849937
0.7413853012849937
```

As you can see, setting the value of `InheritableThreadLocal` doesn't have any effect.