title: the machanism of garbage collectors in Java
date: 2017-05-07 22:01:33
tags: [java, jvm]
categories: Coding
thumbnail: /images/Blog_Trash-1.jpg
---

There are several garbage collectors in Java, each has its specific usage scenario. To understand garbage collection, we first have to understand how heaps are divided in Java.

Heaps are divided into two parts in Java, one is called the Young Generation, and the other one is called the Old Generation. You may have seen something called the Permanent Generation in other tutorials/documentations. It exists in Java 7 and before, Oracle removed it in Java 8.

The Young Generation is also divided into three parts:

1.  Eden Area
2.  Survivor Space 1
3.  Survivor Space 2

The whole picture in Heap is as follows.

![JVM heap memory](/images/The-Machanism-of-Garbage-Collectors-in-Java.png)

Basically, there are two types of garbage collections for most collectors:

1.  Young Generation Collection
2.  Old Generation Collection

Young Generation Collection is meant to be time-efficient and frequent, this is different from the Old Generation Collection, which could take a long time, and it’s done less frequently. The Old Generation usually has larger heap space.

## Serial Collector

**Young Generation Collection Using the Serial Collector**
    When you `new` an object in the Java code, the space for that object will be allocated in the Eden Area. After a while, the Eden Area may be filled up, so live objects in it will be copied into one of the Survivor Space, let’s say it’s Survivor Space 1\. Some large objects that won’t be fit in the Survivor Space will be copies into the Old Generation.

![young generation in the Serial Collector - 1](/images/The-Machanism-of-Garbage-Collectors-in-Java-1.png)

After a while, some live objects in Survivor Space 1 become dead, i.e., they are not referenced by any other objects anymore, and some more space is allocated in the Eden Area for newly initiated objects.

Now you can see, objects exist in Eden and Survivor Space 1, and Survivor Space 2 is empty. This is where the interesting thing begins. Because from now on, what the Young Generation does is to repeat the following process.

When the Eden Area is filled up again. live objects in it will be copied into Survivor Space 2(Some large objects that are too large to fit in Survivor Space will be copied into the Old Generation). The live objects that are relatively young are copied into the Survivor Space 2, live objects that are relatively old(i.e., they survived through several Young Generation Collections) are copied into the Old Generation.

![young generation in the Serial Collector - 2](/images/The-Machanism-of-Garbage-Collectors-in-Java-3.png)

Then all dead objects in the Eden and Survivor Space 1 will be garbage collected, the two survivor spaces swap roles, the Survivor Space 1 is empty while the Survivor Space 2 is not, and the above process will be repeated.

**Old Generation Collection Using the Serial Collector**

Old Generation Collection is divided into three steps, mark-sweep-compact. In the mark phase, the collector identifies live objects, the sweep phase sweeps over the generation and frees space taken by dead objects. Then the collector moves all live objects to the beginning of the old generation, which is called compaction. The compaction is for quick space allocation in the old generation later on.

**When to Use the Serial Collector**

The Serial Collector is done in a single-threaded way, so it’s meant to be run on client-style machines that do not require low pause times. And since it only takes a small amount of memory, the serial collector can perform very well with only 64MB heaps in most cases.

## Parallel Collector

**Young Generation Collection Using the Parallel Collector**

Young Generation collection in the parallel collector is the same as the Serial Collector, except that it’s done in parallel. The Parallel Collector fully utilizes the power of multiple threads and make the process of Young Generation Collection faster. Although the Young Generation Collection is still a stop-the-world action, the process would take less time and make less impact to the running program.

**Old Generation Collection Using the Parallel Collector**

Old Generation Collection using the Parallel Collector is the same as the Serial Collector.

**When to Use the Parallel Collector**

You can use the Parallel Collector when you have multiple CPU cores, whose power could be unleashed and utilized by it. But also notice that the Parallel Collector wouldn’t help you a lot if you need a much shorter pause time in GC, because it still takes a long time to finish the Old Generation Collection, which is done in a single-threaded way in the Parallel Collector.

## Parallel Compacting Collector

**Young Generation Collection Using the Parallel Collector**

Young Generation Collection using the Parallel Compacting Collector is the same as the Parallel Collector.

**Old Generation Collection Using the Parallel Collector**

Old Generation Collection in the Parallel Compacting Collector is done in a multi-threaded way, this is different from the Parallel Collector, whose uses only a single thread to complete Old Generation Collection.

There are in total three phases regarding Old Generation Collection.

**1. Mark(multi-thread)**

First of all, the old generation is divided into several regions of the same fixed sizes. Then live objects that are directly reachable from the code are divided equally among multiple threads. Those threads work concurrently to mark all live objects in the old generation, storing the size and location of each live object.

**2. Summary(single-thread)**

Due to previous compactions, some portions on the left side of the old generation are typically denser than those on the right side of it. So the collector will search from the left side, calculate the density of live objects in each region until it reaches a point where the density is small enough to be considered eligible for garbage collection. All the regions to the left of the point are not worth garbage collecting, and they will not be moved, those regions are called *dense prefix*. All the regions to the right of the point will be garbage collected. After collection, the collector will store the location of the first live object in each region, which would be helpful in the compaction phase.

**3. Compaction(multi-thread)**

Live objects on the right side will be moved to the left side of the old generation, leaving a huge chunk of contiguous free memory on the right side. This process is called compaction.

**When to Use the Parallel Compacting Collector**

You can use the Parallel Compacting Collector if you have multiple CPU cores that could be utilized. The collector will take advantage of those CPU cores and make the total pause time shorter.

## Concurrent Mark-Sweep(CMS) Collector

**Young Generation Collection Using the CMS Collector**

Young Generation Collection using the CMS Collector is the same as the Parallel Collector.

**Old Generation Collection Using the CMS Collector**

There are four phases in total in the Old Generation Collection using the CMS Collector.

**1. Initial Mark(single thread)**

All live objects that are directly reachable from the code are marked as alive. It takes a short pause to do it.

**2. Concurrent Mark(multi-thread)**

While the application is running, the collector marks live objects that are transitively reachable from the above set obtained from the *Initial Mark*.

**3. Remark(multi-thread)**

Because the *Concurrent Mark* is conducted while the application is still running, some live objects cannot be detected in the second phase. So the application stops for a while, and the collector checks all objects that are modified during the *Concurrent Mark* phase, and mark all objects that turned garbage during the previous phase. After the *Remark* phase, all live objects are marked.

**4. Sweep(multi-thread)**

The collector conducts a *Sweep* operation to eliminate all garbage in the Old Generation.

**Disadvantages of the CMS Collector**

The *CMS Collector* is the only collector that has no *compact* phase, which means it cannot use the *bump-the-pointer* strategy(see reference below) to find free space.

<div style="background-color: #fff5cc; border-color: #ffe273; padding: 10px; border-left: 10px solid #ffe273">**bump-the-pointer** strategy: This is a strategy used to allocate new space in the Old Generation. With this strategy, you only need to store the position of the last live object after each Old Generation Collection. When you need to allocate a space to store a new object, what you need to do is just to allocate the space right after the position and update the position to the new one. There are no live objects after that position because the Old Generation has been compacted before. The strategy is used in all above collectors except the *CMS Collector* because the *CMS Collector* doesn’t compact the Old Generation.</div>

So how does the *CMS Collector* find new space to allocate? Basically, it maintains a linked list internally, which connects all free space together. When an allocation is needed, the collector will traverse through the list and find the appropriate region to allocate the space.

Another disadvantage of the *CMS Collector* is that it needs a bigger heap size because the *Concurrent Mark* phase proceeds while the application is still running, which means more space needs to be allocated when some garbage cannot be collected in time. So enough heap size must be prepared to store both uncollected garbage and newly allocated space.

**When to Use the CMS Collector**

The *CMS Collector* is typically used in the server side application, where large heap size and multiple CPU cores could be utilized. Those applications usually require a smaller pause time, which is exactly what *the CMS Collector* is good at.

## G1(Garbage First) Collector

G1 Collector is different from previous collectors. All the previous collectors have a young generation and an old generation of fixed-size. This is the not the case for the G1 Collector. For the G1 Collector, the entire heap is divided into approximately 2000 areas, the size of each area is around 1MB ~ 32MB. The type of these areas may be different, it may be eden, survivor area, or the old generation. The whole picture is as follows.

![the CMS Collector](/images/The-Machanism-of-Garbage-Collectors-in-Java-4.png)

Although the size of each region is the same in the above picture, in reality, this may not be the case. The size of each region usually depends on how the collector optimizes the collection algorithm, and they are changing constantly.

Notice that *Humongous Region* is used to store objects that are larger than 50% of the normal region size. Currently, no optimization is applied to this type of region, so avoid using objects that are too large.

**Young Generation Collection Using the G1 Collector**

1.  Live objects in eden areas are copied into survivor areas.
2.  Some live objects that are out of the time threshold are copied into old generations.
3.  “Accounting” process is performed, which determines how much time is needed for the next Young GC based on the current stats and the predefined pause time.
4.  Resize eden/survivor regions based on the information obtained above.

**Old Generation Collection Using the G1 Collector**

1.  Initial Mark: mark all survivor regions which may have references to objects in old generations. This step is done concurrently with Young GC. So although it’s still a stop-the-world operation(because the entire Young GC is a stop-the-world operation), it doesn’t take extra time to complete.
2.  Root region Scan: scan survivor regions for references into the old generation. It happens when the application is still running.
3.  Concurrent Mark: mark all live objects across the entire heap, this is done while the application is still running.
4.  Remark: stop the world and complete the marking process.
5.  Cleanup: 
  * Perform accounting on live objects and completely free regions.(stop-the-world)
  * Scrubs Remembered Sets.(stop-the-world)
  * Reset empty regions and return them to the free list.(concurrent)
6.  Copy: copy live objects from to new regions. This is a stop-the-world step. It can be seen as a kind of compaction.

## Reference

*   [http://www.oracle.com/technetwork/java/javase/memorymanagement-whitepaper-150215.pdf](http://www.oracle.com/technetwork/java/javase/memorymanagement-whitepaper-150215.pdf)
*   [http://www.oracle.com/technetwork/tutorials/tutorials-1876574.html](http://www.oracle.com/technetwork/tutorials/tutorials-1876574.html)
*   [http://stackoverflow.com/a/19303535/1031769](http://stackoverflow.com/a/19303535/1031769)
