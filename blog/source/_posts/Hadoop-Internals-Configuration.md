title: Hadoop Internals -- Configuration
date: 2017-03-09 21:49:00
tags: [hadoop, java]
categories: Coding
thumbnail: /images/hadoop.png
---

# Introduction
As what is called, `Configuration` is used to store all kinds of configurations in the hadoop platform, either they are from files(like `core-default.xml`) or from users(set via `conf.setInt("dfs.replication", 1)`). It would also warn you if you use a deprecated key. So how does it work? I will try to explain it in the source code level.

# Serialization and Deserialization
Configuration can be serialized in the file system and deserialized again into an instance. It implements the `Writable` interface to achieve this. There are only two methods in the `Writable` interface, `write` and `readFields`, just as follows.

```java
public interface Writable {
  /** 
   * Serialize the fields of this object to <code>out</code>.
   * 
   * @param out <code>DataOuput</code> to serialize this object into.
   * @throws IOException
   */
  void write(DataOutput out) throws IOException;

  /** 
   * Deserialize the fields of this object from <code>in</code>.  
   * 
   * <p>For efficiency, implementations should attempt to re-use storage in the 
   * existing object where possible.</p>
   * 
   * @param in <code>DataInput</code> to deseriablize this object from.
   * @throws IOException
   */
  void readFields(DataInput in) throws IOException;
}
```

As you can see, we call `write` when we need to serialize a `Configuration` instance into file, and we call `readFields` when we need to deserialize it from file. In fact, I wrote several lines to show how to serialize and deserialize a `Configuration` instance.

```java
package com.example;

import org.apache.hadoop.conf.Configuration;

import java.io.*;

/**
 * Created by searene on 3/7/17.
 */
public class ConfigurationInternal {
    public static void main(String[] args) throws IOException {

        String serializationFileName = "conf.ser";
        String key = "dfs.replication";

        Configuration conf = new Configuration();
        conf.setInt(key, 1);

        // serialize the configuration instance into file
        DataOutput dataOutput = new DataOutputStream(new FileOutputStream(serializationFileName));
        conf.write(dataOutput);

        // read from the serialized file into a new configuration instance
        DataInput dataInput = new DataInputStream(new FileInputStream(serializationFileName));
        Configuration confObtained = new Configuration();
        confObtained.readFields(dataInput);

        System.out.println(confObtained.getInt(key, 0));
    }
}
```

To run it, you have to create a maven project and add `hadoop-common` as a dependency.

```xml
<dependency>
    <groupId>org.apache.hadoop</groupId>
    <artifactId>hadoop-common</artifactId>
    <version>2.7.3</version>
</dependency>
```

Run it, and you will notice that a file `confi.ser` is created out of it, it stores the instance of `Configuration`, then we load it(aka deserialize it) from the file and get the instance. We can look through the source code of `write` and `readFields` implemented in `Configuration` to know more about it.

```java
public class Configuration implements Iterable<Map.Entry<String,String>>,
                                      Writable {
    ....
      @Override
  public void write(DataOutput out) throws IOException {
    Properties props = getProps();
    WritableUtils.writeVInt(out, props.size());
    for(Map.Entry<Object, Object> item: props.entrySet()) {
      org.apache.hadoop.io.Text.writeString(out, (String) item.getKey());
      org.apache.hadoop.io.Text.writeString(out, (String) item.getValue());
      WritableUtils.writeCompressedStringArray(out, 
          updatingResource.get(item.getKey()));
    }
  }
    ....
      @Override
  public void readFields(DataInput in) throws IOException {
    clear();
    int size = WritableUtils.readVInt(in);
    for(int i=0; i < size; ++i) {
      String key = org.apache.hadoop.io.Text.readString(in);
      String value = org.apache.hadoop.io.Text.readString(in);
      set(key, value); 
      String sources[] = WritableUtils.readCompressedStringArray(in);
      if(sources != null) {
        updatingResource.put(key, sources);
      }
    }
  }
    ...
}
```

As you can see, the fields that serialization and deserialization apply to are `this.properties` and `this.updateResource`, the former stores all the configurations, which is the most important field in `Configuration`, and the latter stores the mapping of key to the resource which modifies or loads the key most recently. For example, if `Configuration` loads a file `configuration.xml`, which modifies the configuration `dfs.replication`, a new item will be added to `this.updateResource`:

```java
this.updateResource.put("dfs.replication", new String[]{"configuartion.xml"});
```

# Detect Deprecated Keys
When `Configuartion` is loaded, a default list of deprecated keys will be loaded into `defaultDeprecations` too.

```java
  private static DeprecationDelta[] defaultDeprecations = 
    new DeprecationDelta[] {
      new DeprecationDelta("topology.script.file.name", 
        CommonConfigurationKeys.NET_TOPOLOGY_SCRIPT_FILE_NAME_KEY),
      new DeprecationDelta("topology.script.number.args", 
        CommonConfigurationKeys.NET_TOPOLOGY_SCRIPT_NUMBER_ARGS_KEY),
      new DeprecationDelta("hadoop.configured.node.mapping", 
        CommonConfigurationKeys.NET_TOPOLOGY_CONFIGURED_NODE_MAPPING_KEY),
      new DeprecationDelta("topology.node.switch.mapping.impl", 
        CommonConfigurationKeys.NET_TOPOLOGY_NODE_SWITCH_MAPPING_IMPL_KEY),
      new DeprecationDelta("dfs.df.interval", 
        CommonConfigurationKeys.FS_DF_INTERVAL_KEY),
      new DeprecationDelta("hadoop.native.lib", 
        CommonConfigurationKeys.IO_NATIVE_LIB_AVAILABLE_KEY),
      new DeprecationDelta("fs.default.name", 
        CommonConfigurationKeys.FS_DEFAULT_NAME_KEY),
      new DeprecationDelta("dfs.umaskmode",
        CommonConfigurationKeys.FS_PERMISSIONS_UMASK_KEY),
      new DeprecationDelta("dfs.nfs.exports.allowed.hosts",
          CommonConfigurationKeys.NFS_EXPORTS_ALLOWED_HOSTS_KEY)
    };
```

When you try to set a configuration via something like `configuration.set("name", "value")`, it will first check if the key provided is deprecated, and if it is, it will store both deprecated and new keys in itself with the given value, and warn once to the user that the key should not be used.

```java
  public void set(String name, String value, String source) {
    Preconditions.checkArgument(
        name != null,
        "Property name must not be null");
    Preconditions.checkArgument(
        value != null,
        "The value of property " + name + " must not be null");
    name = name.trim();
    DeprecationContext deprecations = deprecationContext.get();
    if (deprecations.getDeprecatedKeyMap().isEmpty()) {
      getProps();
    }
    getOverlay().setProperty(name, value);
    getProps().setProperty(name, value);
    String newSource = (source == null ? "programatically" : source);

    if (!isDeprecated(name)) {
      updatingResource.put(name, new String[] {newSource});
      String[] altNames = getAlternativeNames(name);
      if(altNames != null) {
        for(String n: altNames) {
          if(!n.equals(name)) {
            getOverlay().setProperty(n, value);
            getProps().setProperty(n, value);
            updatingResource.put(n, new String[] {newSource});
          }
        }
      }
    }
    else {
      String[] names = handleDeprecation(deprecationContext.get(), name);
      String altSource = "because " + name + " is deprecated";
      for(String n : names) {
        getOverlay().setProperty(n, value);
        getProps().setProperty(n, value);
        updatingResource.put(n, new String[] {altSource});
      }
    }
  }
```

# Load Default Configuration files
When `Configuration` is loaded, it will try to find two files in the classpath: `core-default.xml` and `core-site.xml`, then load them if they are found.

```java
  static{
    //print deprecation warning if hadoop-site.xml is found in classpath
    ClassLoader cL = Thread.currentThread().getContextClassLoader();
    if (cL == null) {
      cL = Configuration.class.getClassLoader();
    }
    if(cL.getResource("hadoop-site.xml")!=null) {
      LOG.warn("DEPRECATED: hadoop-site.xml found in the classpath. " +
          "Usage of hadoop-site.xml is deprecated. Instead use core-site.xml, "
          + "mapred-site.xml and hdfs-site.xml to override properties of " +
          "core-default.xml, mapred-default.xml and hdfs-default.xml " +
          "respectively");
    }
    addDefaultResource("core-default.xml");
    addDefaultResource("core-site.xml");
  }
  
    ...
    
    public static synchronized void addDefaultResource(String name) {
    if(!defaultResources.contains(name)) {
      defaultResources.add(name);
      for(Configuration conf : REGISTRY.keySet()) {
        if(conf.loadDefaults) {
          conf.reloadConfiguration();
        }
      }
    }
  }
```
