# Lab4 集群管理与运维

## 4.1 分区Leader平衡

### 场景-1

场景描述：三节点的Kafka集群，遇到某个节点故障停机，这时候kafka集群会自动会进行Leader平衡，选择可用的Leader。但是节点恢复后，需要手动平衡分区Leader,以避免数据存储不均衡。

创建一个3分区2副本的主题: lab-4

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic lab-4 --partitions 3 --replication-factor 2
Created topic lab-4.
```

查看主题信息

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9093 --describe --topic lab-4
Topic: lab-4    TopicId: DsrapAjJS0K5WpYdueS9qw PartitionCount: 3       ReplicationFactor: 2    Configs: segment.bytes=1073741824
        Topic: lab-4    Partition: 0    Leader: 1       Replicas: 1,0   Isr: 1,0
        Topic: lab-4    Partition: 1    Leader: 0       Replicas: 0,2   Isr: 0,2
        Topic: lab-4    Partition: 2    Leader: 2       Replicas: 2,1   Isr: 2,1
```

模拟Kafka集群节点宕机

```
[root@kafka-01 kafka-3.2.3]# jps
7329 Kafka
6914 Kafka
993931 Kafka
3702 QuorumPeerMain
997668 Jps
3343 QuorumPeerMain
4079 QuorumPeerMain

[root@kafka-01 kafka-3.2.3]# kill -9 7329

[root@kafka-01 kafka-3.2.3]# jps
6914 Kafka
993931 Kafka
999787 Jps
3702 QuorumPeerMain
3343 QuorumPeerMain
4079 QuorumPeerMain
```

默认Kafka集群提供自动均衡机制，可以查看主题分区Leader均衡后的信息

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9093 --describe --topic lab-4
Topic: lab-4    TopicId: DsrapAjJS0K5WpYdueS9qw PartitionCount: 3       ReplicationFactor: 2    Configs: segment.bytes=104857600
        Topic: lab-4    Partition: 0    Leader: 1       Replicas: 1,0   Isr: 1,0
        Topic: lab-4    Partition: 1    Leader: 0       Replicas: 0,2   Isr: 0
        Topic: lab-4    Partition: 2    Leader: 1       Replicas: 2,1   Isr: 1
```

模拟Kafka故障节点恢复上线

```
[root@kafka-01 kafka-3.2.3]# cd ../
[root@kafka-01 environment]# ./kafka-2.sh
```

查看主题分区信息发现并未有所变化

```
[root@kafka-01 environment]# cd kafka-3.2.3
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9093 --describe --topic lab-4
Topic: lab-4    TopicId: DsrapAjJS0K5WpYdueS9qw PartitionCount: 3       ReplicationFactor: 2    Configs: segment.bytes=104857600
        Topic: lab-4    Partition: 0    Leader: 1       Replicas: 1,0   Isr: 1,0
        Topic: lab-4    Partition: 1    Leader: 0       Replicas: 0,2   Isr: 0,2
        Topic: lab-4    Partition: 2    Leader: 1       Replicas: 2,1   Isr: 1,2
```

手动执行分区leader选举

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-leader-election.sh --bootstrap-server localhost:9093 --topic lab-4 --election-type preferred --partition 2
Successfully completed leader election (PREFERRED) for partitions lab-4-2

```

验证是否分区Leader均衡

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9093 --describe --topic lab-4
Topic: lab-4    TopicId: DsrapAjJS0K5WpYdueS9qw PartitionCount: 3       ReplicationFactor: 2    Configs: segment.bytes=1073741824
        Topic: lab-4    Partition: 0    Leader: 1       Replicas: 1,0   Isr: 1,0
        Topic: lab-4    Partition: 1    Leader: 0       Replicas: 0,2   Isr: 0,2
        Topic: lab-4    Partition: 2    Leader: 2       Replicas: 2,1   Isr: 1,2
```

### 场景-2

场景描述：早期业务数据较少，在kafka集群中已经建有3分区的partition-data-migration主题，近期业务数据增长较快，导致其所在节点存储使用量快速增长,为了避免耗尽所在节点的存储资源，需要通过增加kafka节点/分区的方式来平衡消息存储。


创建一个3分区的主题

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --create --bootstrap-server localhost:9093  --replication-factor 1 --partitions 3 --topic partition-data-migration
Created topic partition-data-migration.
```

查看当前分区数据，当前分区数据主要分布在id为0、1、2三个broker节点上

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9093 --describe --topic partition-data-migration
Topic: partition-data-migration TopicId: CTWrAToVQ5me7LPEl0BJag PartitionCount: 3       ReplicationFactor: 1    Configs: segment.bytes=104857600
        Topic: partition-data-migration Partition: 0    Leader: 2       Replicas: 2     Isr: 2
        Topic: partition-data-migration Partition: 1    Leader: 0       Replicas: 0     Isr: 0
        Topic: partition-data-migration Partition: 2    Leader: 1       Replicas: 1     Isr: 1
```

增加两个kafka节点，broker id分别为3和4.

```
[root@kafka-01 environment]# ./kafka-3.sh
[root@kafka-01 environment]# ./kafka-4.sh
[root@kafka-01 environment]# jps
6914 Kafka
993931 Kafka
1000347 Kafka
3449232 Kafka
3702 QuorumPeerMain
3449647 Kafka
3450074 Jps
3343 QuorumPeerMain
4079 QuorumPeerMain
```

扩容2个分区，下面的数据显示扩容的数据依然落盘在id为0、1、2三个broker节点上，依然不能实现均衡数据存储的目标。

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --alter --bootstrap-server localhost:9092 --topic partition-data-migration --partitions 5
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9093 --describe --topic partition-data-migration
Topic: partition-data-migration TopicId: CTWrAToVQ5me7LPEl0BJag PartitionCount: 5       ReplicationFactor: 1    Configs: segment.bytes=1073741824
        Topic: partition-data-migration Partition: 0    Leader: 4       Replicas: 4     Isr: 4
        Topic: partition-data-migration Partition: 1    Leader: 0       Replicas: 0     Isr: 0
        Topic: partition-data-migration Partition: 2    Leader: 1       Replicas: 1     Isr: 1
        Topic: partition-data-migration Partition: 3    Leader: 2       Replicas: 2     Isr: 2
        Topic: partition-data-migration Partition: 4    Leader: 3       Replicas: 3     Isr: 3
```

要将数据分区落盘新的kafka节点，则需要更新分区数据分配方案，这里通过工具产生分配方案，实现分区数据均衡分布在多个kafka节点上。

> 需要将提议的分区分配方案写入到../configs/partitions-reassignment.json文件中

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-reassign-partitions.sh --bootstrap-server localhost:9092 --topics-to-move-json-file ../configs/topics-to-move.json --broker-list "0,1,2,3,4" --generate
Current partition replica assignment
{"version":1,"partitions":[{"topic":"partition-data-migration","partition":0,"replicas":[2],"log_dirs":["any"]},{"topic":"partition-data-migration","partition":1,"replicas":[0],"log_dirs":["any"]},{"topic":"partition-data-migration","partition":2,"replicas":[1],"log_dirs":["any"]},{"topic":"partition-data-migration","partition":3,"replicas":[0],"log_dirs":["any"]},{"topic":"partition-data-migration","partition":4,"replicas":[1],"log_dirs":["any"]}]}

Proposed partition reassignment configuration
{"version":1,"partitions":[{"topic":"partition-data-migration","partition":0,"replicas":[4],"log_dirs":["any"]},{"topic":"partition-data-migration","partition":1,"replicas":[0],"log_dirs":["any"]},{"topic":"partition-data-migration","partition":2,"replicas":[1],"log_dirs":["any"]},{"topic":"partition-data-migration","partition":3,"replicas":[2],"log_dirs":["any"]},{"topic":"partition-data-migration","partition":4,"replicas":[3],"log_dirs":["any"]}]}
```

执行分配方案

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-reassign-partitions.sh --bootstrap-server localhost:9092 --reassignment-json-file ../configs/partitions-reassignment.json --execute
Current partition replica assignment

{"version":1,"partitions":[{"topic":"partition-data-migration","partition":0,"replicas":[2],"log_dirs":["any"]},{"topic":"partition-data-migration","partition":1,"replicas":[0],"log_dirs":["any"]},{"topic":"partition-data-migration","partition":2,"replicas":[1],"log_dirs":["any"]},{"topic":"partition-data-migration","partition":3,"replicas":[0],"log_dirs":["any"]},{"topic":"partition-data-migration","partition":4,"replicas":[1],"log_dirs":["any"]}]}

Save this to use as the --reassignment-json-file option during rollback
Successfully started partition reassignments for partition-data-migration-0,partition-data-migration-1,partition-data-migration-2,partition-data-migration-3,partition-data-migration-4

```

验证操作进度

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-reassign-partitions.sh --bootstrap-server localhost:9092 --reassignment-json-file ../configs/partitions-reassignment.json --verify
Status of partition reassignment:
Reassignment of partition partition-data-migration-0 is complete.
Reassignment of partition partition-data-migration-1 is complete.
Reassignment of partition partition-data-migration-2 is complete.
Reassignment of partition partition-data-migration-3 is complete.
Reassignment of partition partition-data-migration-4 is complete.

Clearing broker-level throttles on brokers 0,1,2,3,4
Clearing topic-level throttles on topic partition-data-migration

```

验证新的分区方案是否配置就绪，可以看到部分分区已经分配到新的kafka节点。

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9093 --describe --topic partition-data-migration
Topic: partition-data-migration TopicId: CTWrAToVQ5me7LPEl0BJag PartitionCount: 5       ReplicationFactor: 1    Configs: segment.bytes=1073741824
        Topic: partition-data-migration Partition: 0    Leader: 4       Replicas: 4     Isr: 4
        Topic: partition-data-migration Partition: 1    Leader: 0       Replicas: 0     Isr: 0
        Topic: partition-data-migration Partition: 2    Leader: 1       Replicas: 1     Isr: 1
        Topic: partition-data-migration Partition: 3    Leader: 2       Replicas: 2     Isr: 2
        Topic: partition-data-migration Partition: 4    Leader: 3       Replicas: 3     Isr: 3

```



