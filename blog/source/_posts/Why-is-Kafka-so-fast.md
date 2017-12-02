title: Why is Kafka so fast
date: 2017-07-09 08:45:39
tags: [Big Data, Kafka]
categories: Coding
thumbnail: /images/fast.png
---

As we know that Kafka is very fast, much faster than most of its competitors. So what's the reason here?

# Avoid Random Disk Access
Kafka writes everything into disk in order and consumers fetch data in order too. So disk access always works sequentially instead of randomly. Due to characteristics of disks, sequential access is much faster than random access. Here is a comparison:

| hardware                | linear writes | random writes |
|-------------------------|---------------|---------------|
| 6 * 7200rpm SATA RAID-5 | 300MB/s       | 50KB/s        |

# Kafka Writes Everything into Disk Instead of Memory
Yes, you read that right. Kafka writes everything into disk instead of memory. Wait a moment, isn't memory supposed to be faster than disk? Typically it's the case for Random Disk Access.  But for sequential access, the difference is much smaller. Here is a comparison taken from [https://queue.acm.org/detail.cfm?id=1563874](https://queue.acm.org/detail.cfm?id=1563874)

![comparison](/images/comparison-between-disk-and-memory.jpg)

As you can see, it's not that different. But still, memory is faster than Sequential Disk Access, why not choose memory? Because Kafka runs on JVM, which gives us two disadvantages.

1. The memory overhead of objects is very high, often **doubling** the size of the data stored(or even higher).
2. Garbage Collection happens every now and then, so creating objects in memory is very expensive as in-heap data increases because we will need more time to collect useless data.

So writing to file systems may be better than writing to memory. Even better, we can utilize MMAP(memory mapped files) to make it faster.

# Memory Mapped Files
Basically MMAP(Memory Mapped Files) can map the file contents from disk into memory. And when we write something into the mapped memory, the OS will flush the change into disk some time later. So everything is faster because we are using memory here. Why not using memory directly? As we have learned previously, Kafka runs on JVM, if we write data into memory directly, the memory overhead would be high and GC would happen frequently. So we use MMAP here to avoid it.

# Zero Copy
When consumers fetch data from Kafka servers, those data will be copied from the Kernel Context into the Application Context. Then they will be sent from the Application Context to the Kernel Context while being sent to the socket, like this.

![no zero copy](/images/no-zero-copy.png)

As you can see, it's redundant to copy data between the Kernel Context and the Application Context. Can we avoid it? Yes, using Zero Copy we can copy data directly from the Kernel Context to the Kernel Context.

![zero copy](/images/zero-copy.png)

# Batch Data
Kafka only sends data when `batch.size` is reached instead of one by one. Assuming the bandwidth is 10MB/s, sending 10MB data in one go is much faster than sending 10000 messages one by one(assuming each message takes 100 bytes).

# Reference
* [https://www.slideshare.net/baniuyao/kafka-24299168](https://www.slideshare.net/baniuyao/kafka-24299168https://www.slideshare.net/baniuyao/kafka-24299168)
* [https://toutiao.io/posts/508935/app_preview](https://toutiao.io/posts/508935/app_preview)