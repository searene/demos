title: The difference between wait and sleep
date: 2017-09-09 16:29:09
tags: java
categories: Coding
thumbnail: /images/sleep.jpg
---

`wait` and `sleep` can both be used to put a thread into sleep and wait for a while. So what's the difference? To find it out, we need to figure out how to use them first.

# Wait
To use wait, you have to put `mon.wait()` and `mon.notify()` inside the `synchronized` block, where `mon` is the monitor object. `mon` is used such that only one thread can enter the `synchronized` block. It's easier to see it with the code.

```java
package com.example;

public class WaitTest {

    private static final Object mon = new Object();

    private static volatile boolean stopWaiting = false;

    public static void main(String[] args) throws InterruptedException {

        final Thread boyThread = new Thread(new Runnable() {
            public void run() {
                synchronized (mon) {
                    System.out.println("I'm waiting for the girl to show up");
                    try {
                        while(!stopWaiting) mon.wait();
                        System.out.println("The girl showed up, I can stop waiting now.");
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        });

        Thread girlThread = new Thread(new Runnable() {
            public void run() {
                try {
                    System.out.println("I'm wearing make-ups, the boy need to wait for me for 5 seconds.");
                    Thread.sleep(5 * 1000);
                    System.out.println("Make-up is completed, I'm going to see the boy and stop him from waiting");

                    stopWaiting = true;
                    synchronized (mon) {
                        mon.notify();
                    }
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });

        boyThread.start();
        girlThread.start();

        boyThread.join();
        girlThread.join();

        System.out.println("The test is completed.");
    }
}
```

Output:

```bash
I'm waiting for the girl to show up
I'm wearing make-ups, the boy need to wait for me for 5 seconds.
Make-up is completed, I'm going to see the boy and stop him from waiting
The girl showed up, I can stop waiting now.
The test is completed.
```

Here the girl needs to wear the make-up before going out to see the boy. When she finishes, `mon.notify()` is called and the boy stops waiting, and they meet in the end.

# Sleep
`sleep` can also be used to put a thread into sleep for a while, and you can use `thread.interrupt()` to cancel the sleep and put the thread into running. Let's see an example.

```java
package com.example;

public class SleepTest {
    public static void main(String[] args) throws InterruptedException {
        final Thread boyThread = new Thread(new Runnable() {
            public void run() {
                try {
                    System.out.println("I'm going to sleep for 5 seconds. If the girl wouldn't show up after 5 second, I'll stop waiting.");
                    Thread.sleep(5 * 1000);
                    System.out.println("The girl didn't show up, bummer.");
                } catch (InterruptedException e) {
                    System.out.println("The girl showed up, great!");
                }
            }
        });

        Thread girlThread = new Thread(new Runnable() {
            public void run() {
                System.out.println("I'm going to wear make-ups, which will take 3 seconds");
                try {
                    Thread.sleep(3 * 1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                System.out.println("I'm done, going to see my boy and stop him from waiting");
                boyThread.interrupt();
            }
        });

        boyThread.start();
        girlThread.start();

        boyThread.join();
        girlThread.join();

        System.out.println("The test is completed.");
    }
}
```

Output:

```bash
I'm going to sleep for 5 seconds. If the girl wouldn't show up after 5 second, I'll stop waiting.
I'm going to wear make-ups, which will take 3 seconds
I'm done, going to see my boy and stop him from waiting
The girl showed up, great!
The test is completed.
```

The girl takes 3 seconds to wear her make-up, and when it's done, she tells the boy to stop sleeping by calling `boyThread.interrupt()`, the boy stops sleeping and they meet in the end.

# Difference
So what's the difference?

1. `wait` should be used in a `synchronized` block, while `sleep` doesn't need to.
2. `wait` belongs to `java.lang.Object` and is an instance method, while `sleep` belongs to `java.lang.Thread` and is a static method.
3. `wait` can be woken by `notify`, `notifyAll` and `interrupt`, while `sleep` can only be woken by `interrupt`.
4. `wait` and `notify` release the lock, which means you can enter the `synchronized` block for multiple times as long as those threads call `wait`, while `sleep` doesn't release the lock.

# Use Cases
`sleep` is a normal way to put the thread into sleep for a pre-defined time, and `interrupt` is only a way to cancel the sleep.

`wait` is a normal way for inter-thread communication, and usually you can build a publish-subscribe system by it. notify => publish, wait => subscribe. When you call `notify`, it means some messages are available, and one thread will be woken to consume those messages.
