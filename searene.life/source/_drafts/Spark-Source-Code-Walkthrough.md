title: Spark Source Code Walkthrough
draft: true
date: 2017-10-05 09:27:34
tags: Spark
categories: Coding
thumbnail:
---

# load-spark-env.sh

It loads all the variables in `spark-env.sh` and set `SPARK_SCALA_VERSION` based on which scala library exists in the spark directory. To avoid mistake, we create a new file `spark-env.sh` in `${SPARK_HOME}/conf` and set this variable.

```bash
SPARK_SCALA_VERSION=2.11
```

If we don't set it, it will probably use `2.10` as the Scala version.

# spark-class

Run `org.apache.spark.launcher.Main`, which outputs a command to be execute later.

```bash
build_command() {
  "$RUNNER" -Xmx128m -cp "$LAUNCH_CLASSPATH" org.apache.spark.launcher.Main "$@"
  printf "%d\0" $?
}

...

exec "${CMD[@]}"
```

For example, if we submit the jar like this.

```bash
spark-submit --master yarn --deploy-mode cluster target/scala-2.11/spark-test_2.11-0.1.jar
```

It run this run command in `build_command()`

```bash
java -Xmx128m -cp '/home/searene/apps/spark-2.2.0-bin-hadoop2.7/jars/*' org.apache.spark.launcher.Main org.apache.spark.deploy.SparkSubmit --master yarn --deploy-mode cluster target/scala-2.11/spark-test_2.11-0.1.jar
```

This command will probably end up giving the following outputs, each separated by `\0`

1. /usr/lib/jvm/java-8-openjdk/jre/bin/java
2. -cp
3. /home/searene/apps/spark-2.2.0-bin-hadoop2.7/conf/:/home/searene/apps/spark-2.2.0-bin-hadoop2.7/jars/*:/home/searene/config/hadoop/conf/
4. org.apache.spark.deploy.SparkSubmit
5. --master
6. yarn
7. --deploy-mode
8. cluster

Then `spark-load` will concatenate those outputs into a complete command and execute it.

```bash
exec /usr/lib/jvm/java-8-openjdk/jre/bin/java -cp '/home/searene/apps/spark-2.2.0-bin-hadoop2.7/conf/:/home/searene/apps/spark-2.2.0-bin-hadoop2.7/jars/*:/home/searene/config/hadoop/conf/' org.apache.spark.deploy.SparkSubmit --master yarn --deploy-mode cluster target/scala-2.11/spark-test_2.11-0.1.jar
```

# org.apache.spark.launcher.Main

**Run**

Before running the `Main` class, we need to setup some environment variables first.

```bash
export SPARK_HOME=~/apps/spark-2.2.0-bin-hadoop2.7
export SPARK_SCALA_VERSION=2.11
```

Then go to ${spark_project}/launcher, run the `Main` class.

```bash
mvn exec:java -Dexec.mainClass=org.apache.spark.launcher.Main -Dexec.args="org.apache.spark.deploy.SparkSubmit --master yarn --deploy-mode cluster target/scala-2.11/spark-test_2.11-0.1.jar"
```

Output:

```bash
/usr/lib/jvm/java-8-jdk/jre/bin/java -cp /home/searene/apps/spark-2.2.0-bin-hadoop2.7/conf/:/home/searene/apps/spark-2.2.0-bin-hadoop2.7/jars/* org.apache.spark.deploy.SparkSubmit --master yarn --deploy-mode cluster target/scala-2.11/spark-test_2.11-0.1.jar
```

Notice that the output is a combination of multiple strings, separated by the null(`\0`) character. But some shells may omit these null characters. It would be better if you run it in Intellij, the null character is very obvious in the output window.

![main-class-output](/images/main-class-output.png)

**What it does**

Basically the class checks if the options provided by the user are valid, and add some other parameters to the output argument list(e.g. classpath)