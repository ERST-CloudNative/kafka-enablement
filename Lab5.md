# Lab5 跨集群数据迁移

## 5.1 Kafka Connect部署

部署Kafka Connect组件(分布式集群模式)

```
[root@kafka-01 environment]# ./connect-0.sh
[root@kafka-01 environment]# ./connect-1.sh
[root@kafka-01 environment]# ./connect-2.sh

[root@kafka-01 environment]# jps
4337 Kafka
5201 Kafka
3492 QuorumPeerMain
4740 Kafka
5625 ConnectDistributed
3133 QuorumPeerMain
3869 QuorumPeerMain
7069 Jps
```

## 5.2 Kafka Connect基础实践

通过Kafka Connect自带的FileStreamSourceConnector连接器将指定文件的数据导入到Kafka集群的某个Topic中。

首先通过API接口查看当前支持的插件

```
[root@kafka-01 environment]# curl http://localhost:8083/connector-plugins | jq '.'
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   508  100   508    0     0   4618      0 --:--:-- --:--:-- --:--:--  4618
[
  {
    "class": "org.apache.kafka.connect.file.FileStreamSinkConnector",
    "type": "sink",
    "version": "3.2.3"
  },
  {
    "class": "org.apache.kafka.connect.file.FileStreamSourceConnector",
    "type": "source",
    "version": "3.2.3"
  },
  {
    "class": "org.apache.kafka.connect.mirror.MirrorCheckpointConnector",
    "type": "source",
    "version": "3.2.3"
  },
  {
    "class": "org.apache.kafka.connect.mirror.MirrorHeartbeatConnector",
    "type": "source",
    "version": "3.2.3"
  },
  {
    "class": "org.apache.kafka.connect.mirror.MirrorSourceConnector",
    "type": "source",
    "version": "3.2.3"
  }
]
```

创建topic

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic file-connect --partitions 3 --replication-factor 1
Created topic file-connect.
```

创建连接器

```
[root@kafka-01 kafka-3.2.3]# curl -X POST -H "Content-Type: application/json" --data @../configs/connect/connector.json http://localhost:8083/connectors
{"name":"local-file-source","config":{"connector.class":"FileStreamSource","topic":"file-connect","key.converter":"org.apache.kafka.connect.storage.StringConverter","value.converter":"org.apache.kafka.connect.storage.StringConverter","converter.internal.key.converter":"org.apache.kafka.connect.storage.StringConverter","converter.internal.value.converter":"org.apache.kafka.connect.storage.StringConverter","file":"/tmp/file-connect.txt","name":"local-file-source"},"tasks":[],"type":"source"}
```


等待输入导入到kafka集群中
```
[root@kafka-01 kafka-3.2.3]# bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic file-connect --from-beginning
123
```

另开一个终端，填充数据到文本文件中
```
[root@kafka-01 ~]# echo 123 >> /tmp/file-connect.txt
```

## 5.3 跨集群数据迁移

MirrorMaker 2.0 使用源 Kafka 集群的信息，并将其写入目标 Kafka 集群。其基于 Kafka Connect 框架，即管理集群间数据传输的连接器。MirrorMaker 2.0 MirrorSourceConnector 将源集群中的主题复制到目标集群。
将数据从一个集群镜像到另一个集群的过程是异步的。

[源集群] 创建需要迁移的topic

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic lab5 --partitions 3 --replication-factor 1
Created topic lab5.
```

[源集群] 填充模拟数据

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-verifiable-producer.sh --bootstrap-server localhost:9092 --topic lab5 --max-message 100
```

[目标集群] 查看目标集群的topic列表

```
[root@kafka-mirror-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server 152.69.203.81:9092 --list
__consumer_offsets
my-connect-cluster-config
my-connect-cluster-offset
my-connect-cluster-status
```

[源集群] 开始数据迁移与同步

```
[root@kafka-01 kafka-3.2.3]# bin/connect-mirror-maker.sh config/connect-mirror-maker.properties
```

[目标集群] 查看同步效果

```
[root@kafka-mirror-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server 152.69.203.81:9092 --list
A.checkpoints.internal
A.heartbeats
A.lab5
A.my-connect-cluster-config
A.my-connect-cluster-offset
A.my-connect-cluster-status
__consumer_offsets
heartbeats
mm2-configs.A.internal
mm2-offsets.A.internal
mm2-status.A.internal
my-connect-cluster-config
my-connect-cluster-offset
my-connect-cluster-status
```

[目标集群] 验证存量数据是否已经完成迁移

```
[root@kafka-mirror-01 kafka-3.2.3]# bin/kafka-console-consumer.sh --bootstrap-server 152.69.203.81:9092 --topic A.lab5 --from-beginning
```

[源集群] 填充增量数据

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic lab5
>Hello
>Kafka
```

[目标集群] 如果运行正常的化，应该可以看到以下的效果

```
[root@kafka-mirror-01 kafka-3.2.3]# bin/kafka-console-consumer.sh --bootstrap-server 152.69.203.81:9092 --topic A.lab5 --from-beginning
...
94
95
96
97
98
99
Hello
Kafka
```






