title: kafka in a nutshell
date: 2017-05-18 21:51:28
tags: [kafka]
categories: Coding
thumbnail: /images/kafka-logo-wide.png
---

# Introduction
Kafka is a distributed publish-subscribe messaging system that is designed to be fast, scalable and reliable. It can be used in data analysis, stream processing and other similar tasks. This article gives a brief introduction on its components and how these components work together to make Kafka an amazing program.

# Basic Model
Basically you have to provide two things in order to use Kafka: producer and consumer. Producer is used to generate data constantly and write those data to Kafka servers, then consumer reads data from kafka servers and dispatch those data to downstream systems for further processing.

![producer-consumer model](/images/producer-consumer.svg)

Notice that you can provide multiple producers and multiple consumers to ensure fast data delivery. Usually there are also multiple kafka servers. In this case, same data will be replicated across multiple servers so that Kafka would still work even if one of those servers goes offline.

There are some keywords you need to about first before getting into some details of Kafka.

**Topic**: When you are sending data to Kafka using producers, you have to tell producers, "Hey, could you please send these data to *that place* in the Kafka server?" Here *that place* should be replaced with *topic*. Topics are just like directories in your computer, different directories store different files. The same goes to Kafka. You may have three different Kafka topics, *game*, *website* and *log*, they are used to stream gaming, website and log data respectively. Typically different producers write data to different topics, but notice that one topic can be fed by multiple producers at the same time.

**Partition**: A topic is divided into multiple partitions, so that if you have multiple producers for a topic, they can write to different partitions concurrently, likewise, consumers can also read from different partitions at the same time, which makes the whole streaming process much faster.

**Offset**: Each message sent by producer will be stored by Kafka servers, and marked with a unique number for each partition, this number is called offset. Just as the name implies, *offset* starts from 0 and increases by one each time a message is received from producers.

![topic-partition-offset](/images/topic-partition-offset.svg)

**Broker**: Each server in Kafka is called a *broker*.

**Leader & Follower**: The data stored in a topic will be replicated across multiple servers. Since a topic is made up of partitions, it's safe to say that the same partition is replicated across multiple servers. One of those partitions is called *leader*, and others are called *follower*.

Suppose we have three brokers, and we mark leader partitions in red, follower partitions in blue, the whole picture is like this:

![leader and follower](/images/leader and follower.svg)

# Producer

When producers write data to Kafka, they first write to the leader partition, then the data is replicated into the first follower, then the second follower...until all followers have the same data as the leader.

![replicate](/images/replicate.svg)

Each broker has its own commit log. When data is successfully stored in its respective partition in one broker, a new record will be written into the broker's commit log. When a message is replicated across all leader and followers for that partition, i.e. we have committed the message in all brokers, we take it that the message has been committed in its respective partition.

![commit log](/images/commit-log.svg)

So when should the producer consider the message has been written into Kafka successfully? After the message is committed in leader, or in all brokers? In fact, producers have three choices.

1. Producer returns immediately right after the message is written into the leader, don't wait for commit.

  ![no confirm](/images/return-immediately.svg)

2. Producer waits for confirm from the leader, which means the message has been committed in the leader partitionbs.reload.

  ![wait for leader](/images/wait-for-leader.svg)

3. Producer waits for confirm from all brokers, which means the message has been committed in both leader and follower partitions.

  ![wait for all](/images/wait-for-all.svg)

# Consumer
Consumers in Kafka use the `poll()` function to fetch data from Kafka servers. Every once in a while, consumers need to commit messages which they receive. The commit log is stored in a special Kafka topic. So how do consumers commit and when? Basically there are three modes for consumers to choose from.

1. Commit At Most Once

  You have to set the following properties to use this mode:
  
  ```
  enable.auto.commit = true
  auto.commit.interval.ms = 15
  ```

  The value of `auto.commit.interval.ms` could be any number. Now let's talk about what these properties mean and how the mode works.
  
  The following steps will be proceeded if this mode is turned on:

  1. Consumer fetches some data from Kafka.
  2. Consumer checks whether `auto.commit.interval.ms` is up. If so, it commits offset fetched between the last commit time and now. The commit is done automatically by Kafka, this is also what `enable.auto.commit` means.
  3. Consumer processes the fetched data.
  4. Repeat above steps.

  Let's use a picture to illustrate the process.

  ![commit at most once](/images/commit-at-most-once.svg)

  Regarding the above diagram, what will happen if error occurs while processing data?

  ![commit at most once exception](/images/commit-at-most-once-exception.svg)

  Well, as you see, data from offset 10 ~ 14 will be lost because these unsuccessfully-processed data has been committed, when the consumer recovers from the crash, it will continue to fetch and process data from offset 15, which is the next number from the last commit offset.

2. Commit At Least Once

  You have to set the following properties to turn on this mode.

  ```
  enable.auto.commit = false
  ```

  As you can see, `enable.auto.commit` is set `false`, which means that you have to manually commit offsets. There are the steps to be proceeded if the mode is turned on.

  1. Consumer fetches some data from Kafka.
  2. Consumer processes those data.
  3. Consumer commit offsets regarding those data manually.
  4. Repeat above steps.

  Here is a picture to illustrate the process.

  ![commit at least once](/images/commit-at-least-once.svg)

  What if an exception occurs while we are processing data, just like the last mode mentioned before?

  ![commit at least once exception](/images/commit-at-least-once-exception.svg)

  Well, as you can see, nothing is lost here because we haven't committed those data at the time of processing. The worst thing for us is that some duplicated data will be appeared in the downstream system. That's totally fine as long as we have a proper filter system to filter out those duplicated data.

  Since this mode is safer than the last one, we often choose to use `commit at least once` in Kafka to fetch data.

  There's also another mode called `commit exactly once`, where the committed messages and offsets will get through a transaction system. It's even safer than `commit at least once` but costs much more resources. Most of the time the second mode would be fine, we will not talk about it in detail for now.
