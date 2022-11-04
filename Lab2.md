
# Lab 2  集群管理与维护

## 1. 查看kafka集群信息

通过Zookeeper查看集群信息


```
[root@kafka-01 ~]# cd kafka-enablement/environment/kafka-3.2.3/
[root@kafka-01 kafka-3.2.3]# export KAFKA_OPTS="-Djava.security.auth.login.config=../configs/kafka/jaas.config"
[root@kafka-01 kafka-3.2.3]# bin/zookeeper-shell.sh localhost:2181
Connecting to localhost:2181
Welcome to ZooKeeper!
JLine support is disabled

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
```

依次输入以下命令行查看集群信息

```
ls /
get /controller
ls /brokers
ls /brokers/ids
get /brokers/ids/0
ls /brokers/topics
```

参考示例结果如下：

```
[root@kafka-01 ~]# cd kafka-enablement/environment/kafka-3.2.3/
[root@kafka-01 kafka-3.2.3]# bin/zookeeper-shell.sh localhost:2181
Connecting to localhost:2181
Welcome to ZooKeeper!
JLine support is disabled

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
ls /
[admin, brokers, cluster, config, consumers, controller, controller_epoch, feature, isr_change_notification, latest_producer_id_block, log_dir_event_notification, zookeeper]

get /controller
{"version":1,"brokerid":0,"timestamp":"1666342423892"}

ls /brokers
[ids, seqid, topics]

ls /brokers/ids
[0, 1, 2]

get /brokers/ids/0
{"listener_security_protocol_map":{"INSECURE":"PLAINTEXT","ENCRYPTED":"SSL","REPLICATION":"SASL_PLAINTEXT","AUTHENTICATED":"SASL_PLAINTEXT"},"endpoints":["INSECURE://localhost:9092","ENCRYPTED://localhost:19092","REPLICATION://localhost:29092","AUTHENTICATED://localhost:39092"],"jmx_port":-1,"features":{},"host":"localhost","timestamp":"1666342423700","port":9092,"version":5}

ls /brokers/topics
[]

```


## 2. Topic

2.1 创建Kafka Topic

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic lab-2 --partitions 3 --replication-factor 1
Created topic lab-2.

```

查看Kafka Topic 详情

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9092 --list --topic lab-2
lab-2

[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic lab-2
Topic: lab-2    TopicId: Hso8PfrASnqwSlqg7_w8NA PartitionCount: 3       ReplicationFactor: 1    Configs: segment.bytes=104857600
        Topic: lab-2    Partition: 0    Leader: 2       Replicas: 2     Isr: 2
        Topic: lab-2    Partition: 1    Leader: 1       Replicas: 1     Isr: 1
        Topic: lab-2    Partition: 2    Leader: 0       Replicas: 0     Isr: 0

```

2.2 发送消息

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic lab-2
>1
>2
>3
>4
>5
>6
```

2.3 接收消息

消费整个topic的消息
```
[root@kafka-01 kafka-3.2.3]#  bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic lab-2 --from-beginning
3
4
1
2
5
6
```

> kafka只能保证Partition内部的有序，不能保证全局的有序性。 严格的全局有序可以将Partition数设为1， 所有数据写到同一个Partition中， 保证了有序性， 但是牺牲了kafka的性能。

接下来，我们可以通过消费每个partition的消息验证其是否可以实现同一个分区内部是有序的。

```
[root@kafka-01 kafka-3.2.3]#  bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic lab-2 --partition 0 --from-beginning
1
2
5
[root@kafka-01 kafka-3.2.3]#  bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic lab-2 --partition 1 --from-beginning
3
4
[root@kafka-01 kafka-3.2.3]#  bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic lab-2 --partition 2 --from-beginning
6
```

查看Kafka Topic lab-2的详细信息

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic lab-2
Topic: lab-2    TopicId: oPXTeDrQS4OdoM4gjFDhpg PartitionCount: 3       ReplicationFactor: 1    Configs: segment.bytes=104857600
        Topic: lab-2    Partition: 0    Leader: 1       Replicas: 1     Isr: 1
        Topic: lab-2    Partition: 1    Leader: 0       Replicas: 0     Isr: 0
        Topic: lab-2    Partition: 2    Leader: 2       Replicas: 2     Isr: 2
```

2.4 删除Kafka Topic

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9092 --delete --topic lab-2
```

## 3. consumer groups

### 3.1 查看消费组

打开三个终端，依次设置如下：

终端-1 发送消息

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic lab-2
>1
>2
>3
>4
>5
>
```

终端-2 消费消息

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic lab-2
1
2
3
4
5

```
终端-3 查看消费组

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list
console-consumer-10591
```

### 3.2 消费多个Topic

打开三个终端，依次设置如下：

终端-1 创建Kafka Topic cg1,并分别发送两条消息

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic cg1 --partitions 3 --replication-factor 1
Created topic cg1.

[root@kafka-01 kafka-3.2.3]# bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic cg1
>1
>2

```
终端-2 创建Kafka Topic cg2,并分别发送两条消息

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic cg2 --partitions 3 --replication-factor 1
Created topic cg2.

[root@kafka-01 kafka-3.2.3]# bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic cg2
>3
>4
```


终端-3 使用白名单机制，消费这两个Topic的消息

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --consumer-property group.id=consumer-multi-topic --whitelist "cg1|cg2"
1
2
3
4
```

### 3.3 单播

当生产者发送一条信息时，每次消费组中只有一个消费者能收到信息。


打开三个终端，依次设置如下：

终端-1 消费者-1

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic lab-2 --consumer-property group.id=single-consumer-group


```

终端-2 消费者-2

```
[root@kafka-01 kafka-3.2.3]#  bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic lab-2 --consumer-property group.id=single-consumer-group


```

终端-3 生产者，并依次输入以下数据

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic lab-2
>1
>2
>3
>4
>5
>6
>7
>8
>9
>
```


#### 3.4 多播

一条消息可以被多个消费者消费的模式

打开三个终端，依次设置如下：

终端-1 消费者-1

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic lab-2 --consumer-property group.id=multi-consumer-group-1

```

终端-2 消费者-2

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic lab-2 --consumer-property group.id=multi-consumer-group-2

```

终端-3 生产者，并一次输入以下数据

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic lab-2
>1
>2
>3
>4
>5
>6
>7
>8
>9
>
```


