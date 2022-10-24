# Lab3 集群管理与维护

## 3.1 配置管理-Topic

查看lab-2 topic的当前配置
```
[root@kafka-01 kafka-3.2.3]# bin/kafka-configs.sh --bootstrap-server localhost:9092  --describe --entity-type topics --entity-name lab-2
Dynamic configs for topic lab-2 are:
```

添加两个配置参数`flush.messages=3,max.message.bytes=20240`

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type topics --entity-name lab-2 --alter --add-config flush.messages=3,max.message.bytes=20240
Completed updating config for topic lab-2.
```

验证参数是否配置就绪

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-configs.sh --bootstrap-server localhost:9092  --describe --entity-type topics --entity-name lab-2
Dynamic configs for topic lab-2 are:
  flush.messages=3 sensitive=false synonyms={DYNAMIC_TOPIC_CONFIG:flush.messages=3, DEFAULT_CONFIG:log.flush.interval.messages=9223372036854775807}
  max.message.bytes=20240 sensitive=false synonyms={DYNAMIC_TOPIC_CONFIG:max.message.bytes=20240, DEFAULT_CONFIG:message.max.bytes=1048588}
```

删除配置参数

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type topics --entity-name lab-2 --alter --delete-config flush.messages,max.message.bytes
Completed updating config for topic lab-2.
```

查看配置

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-configs.sh --bootstrap-server localhost:9092  --describe --entity-type topics --entity-name lab-2
Dynamic configs for topic lab-2 are:
```


## 3.2 配置管理-Broker

查看broker 2 的动态配置
```
[root@kafka-01 kafka-3.2.3]# bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type brokers --entity-name 2 --describe
Dynamic configs for broker 2 are:
```

添加配置

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type brokers --entity-name 2 --alter --add-config follower.replication.throttled.rate=10485760,leader.replication.throttled.rate=10485760
Completed updating config for broker 2.
```
查看配置

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type brokers --entity-name 2 --describe
Dynamic configs for broker 2 are:
  leader.replication.throttled.rate=10485760 sensitive=false synonyms={DYNAMIC_BROKER_CONFIG:leader.replication.throttled.rate=10485760}
  follower.replication.throttled.rate=10485760 sensitive=false synonyms={DYNAMIC_BROKER_CONFIG:follower.replication.throttled.rate=10485760}
```

删除配置

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type brokers --entity-name 2 --alter --delete-config follower.replication.throttled.rate,leader.replication.throttled.rate
Completed updating config for broker 2.
```

验证配置已删除

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type brokers --entity-name 2 --describe
Dynamic configs for broker 2 are:
```


## 3.3 配置管理之客户端/用户级别配置

为用户loren设置限流配置
```
[root@kafka-01 kafka-3.2.3]# bin/kafka-configs.sh --bootstrap-server localhost:9092 --alter --add-config 'producer_byte_rate=1024,consumer_byte_rate=2048' --entity-type useoren
Completed updating config for user loren.
```

```
[root@kafka-01 kafka-3.2.3]# export KAFKA_OPTS="-Djava.security.auth.login.config=../configs/kafka/jaas.config"
[root@kafka-01 kafka-3.2.3]# bin/zookeeper-shell.sh localhost:2181 --help
Connecting to localhost:2181
Welcome to ZooKeeper!
JLine support is disabled

WATCHER::

WatchedEvent state:SyncConnected type:None path:null

WATCHER::

WatchedEvent state:SaslAuthenticated type:None path:null
```

查看用户配置

```
get /config/users/loren
{"version":1,"config":{"producer_byte_rate":"1024","consumer_byte_rate":"2048"}}
```


## 3.4 修改Kafka Topic的分区信息

查看Kafka Topic lab-2的配置
```
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic lab-2
Topic: lab-2    TopicId: oPXTeDrQS4OdoM4gjFDhpg PartitionCount: 3       ReplicationFactor: 1    Configs: segment.bytes=104857600
        Topic: lab-2    Partition: 0    Leader: 1       Replicas: 1     Isr: 1
        Topic: lab-2    Partition: 1    Leader: 0       Replicas: 0     Isr: 0
        Topic: lab-2    Partition: 2    Leader: 2       Replicas: 2     Isr: 2
```

修改lab-2 Topic的分区数为5

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --alter --bootstrap-server localhost:9092 --topic lab-2 --partitions 5
```

验证配置是否生效

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic lab-2
Topic: lab-2    TopicId: oPXTeDrQS4OdoM4gjFDhpg PartitionCount: 5       ReplicationFactor: 1    Configs: segment.bytes=104857600
        Topic: lab-2    Partition: 0    Leader: 1       Replicas: 1     Isr: 1
        Topic: lab-2    Partition: 1    Leader: 0       Replicas: 0     Isr: 0
        Topic: lab-2    Partition: 2    Leader: 2       Replicas: 2     Isr: 2
        Topic: lab-2    Partition: 3    Leader: 1       Replicas: 1     Isr: 1
        Topic: lab-2    Partition: 4    Leader: 2       Replicas: 2     Isr: 2
```
