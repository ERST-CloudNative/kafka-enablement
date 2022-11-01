# Lab4 集群管理与运维

## 4.1 分区Leader平衡


```
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic lab-4 --partitions 3 --replication-factor 2
Created topic lab-4.
```

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9093 --describe --topic lab-4
Topic: lab-4    TopicId: DsrapAjJS0K5WpYdueS9qw PartitionCount: 3       ReplicationFactor: 2    Configs: segment.bytes=1073741824
        Topic: lab-4    Partition: 0    Leader: 1       Replicas: 1,0   Isr: 1,0
        Topic: lab-4    Partition: 1    Leader: 0       Replicas: 0,2   Isr: 0,2
        Topic: lab-4    Partition: 2    Leader: 2       Replicas: 2,1   Isr: 2,1
```

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
```

```
[root@kafka-01 kafka-3.2.3]# jps
6914 Kafka
993931 Kafka
999787 Jps
3702 QuorumPeerMain
3343 QuorumPeerMain
4079 QuorumPeerMain
```

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9093 --describe --topic lab-4
Topic: lab-4    TopicId: DsrapAjJS0K5WpYdueS9qw PartitionCount: 3       ReplicationFactor: 2    Configs: segment.bytes=104857600
        Topic: lab-4    Partition: 0    Leader: 1       Replicas: 1,0   Isr: 1,0
        Topic: lab-4    Partition: 1    Leader: 0       Replicas: 0,2   Isr: 0
        Topic: lab-4    Partition: 2    Leader: 1       Replicas: 2,1   Isr: 1
```

```
[root@kafka-01 kafka-3.2.3]# cd ../
[root@kafka-01 environment]# ./kafka-2.sh
```

```
[root@kafka-01 environment]# cd kafka-3.2.3
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9093 --describe --topic lab-4
Topic: lab-4    TopicId: DsrapAjJS0K5WpYdueS9qw PartitionCount: 3       ReplicationFactor: 2    Configs: segment.bytes=104857600
        Topic: lab-4    Partition: 0    Leader: 1       Replicas: 1,0   Isr: 1,0
        Topic: lab-4    Partition: 1    Leader: 0       Replicas: 0,2   Isr: 0,2
        Topic: lab-4    Partition: 2    Leader: 1       Replicas: 2,1   Isr: 1,2
```

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-leader-election.sh --bootstrap-server localhost:9093 --topic lab-4 --election-type preferred --partition 2
Successfully completed leader election (PREFERRED) for partitions lab-4-2

```

```
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9093 --describe --topic lab-4
Topic: lab-4    TopicId: DsrapAjJS0K5WpYdueS9qw PartitionCount: 3       ReplicationFactor: 2    Configs: segment.bytes=1073741824
        Topic: lab-4    Partition: 0    Leader: 1       Replicas: 1,0   Isr: 1,0
        Topic: lab-4    Partition: 1    Leader: 0       Replicas: 0,2   Isr: 0,2
        Topic: lab-4    Partition: 2    Leader: 2       Replicas: 2,1   Isr: 1,2
```

## 4.1 分区消息数据平衡


[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --create --bootstrap-server localhost:9093  --replication-factor 1 --partitions 1 --topic partition-data-migration
Created topic partition-data-migration.

[root@kafka-01 kafka-3.2.3]# bin/kafka-verifiable-producer.sh --bootstrap-server localhost:9093 --topic partition-data-migration --max-message 100

[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9093 --describe --topic partition-data-migration
Topic: partition-data-migration TopicId: CTWrAToVQ5me7LPEl0BJag PartitionCount: 1       ReplicationFactor: 1    Configs: segment.bytes=104857600
        Topic: partition-data-migration Partition: 0    Leader: 2       Replicas: 2     Isr: 2

[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --alter --bootstrap-server localhost:9092 --topic partition-data-migration --partitions 3
[root@kafka-01 kafka-3.2.3]# bin/kafka-topics.sh --bootstrap-server localhost:9093 --describe --topic partition-data-migration
Topic: partition-data-migration TopicId: CTWrAToVQ5me7LPEl0BJag PartitionCount: 3       ReplicationFactor: 1    Configs: segment.bytes=104857600
        Topic: partition-data-migration Partition: 0    Leader: 2       Replicas: 2     Isr: 2
        Topic: partition-data-migration Partition: 1    Leader: 0       Replicas: 0     Isr: 0
        Topic: partition-data-migration Partition: 2    Leader: 1       Replicas: 1     Isr: 1

[root@kafka-01 kafka-3.2.3]# bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic partition-data-migration --partition 1 --from-beginning
^CProcessed a total of 0 messages

[root@kafka-01 kafka-3.2.3]# bin/kafka-reassign-partitions.sh --bootstrap-server localhost:9092 --topics-to-move-json-file ../configs/topics-to-move.json --broker-list "0,1" --generate
Current partition replica assignment
{"version":1,"partitions":[{"topic":"partition-data-migration","partition":0,"replicas":[2],"log_dirs":["any"]},{"topic":"partition-data-migration","partition":1,"replicas":[0],"log_dirs":["any"]},{"topic":"partition-data-migration","partition":2,"replicas":[1],"log_dirs":["any"]}]}

Proposed partition reassignment configuration
{"version":1,"partitions":[{"topic":"partition-data-migration","partition":0,"replicas":[0],"log_dirs":["any"]},{"topic":"partition-data-migration","partition":1,"replicas":[1],"log_dirs":["any"]},{"topic":"partition-data-migration","partition":2,"replicas":[0],"log_dirs":["any"]}]}

[root@kafka-01 kafka-3.2.3]# bin/kafka-reassign-partitions.sh --bootstrap-server localhost:9092 --reassignment-json-file ../configs/partitions-reassignment.json --execute
Current partition replica assignment

{"version":1,"partitions":[{"topic":"partition-data-migration","partition":0,"replicas":[2],"log_dirs":["any"]},{"topic":"partition-data-migration","partition":1,"replicas":[0],"log_dirs":["any"]},{"topic":"partition-data-migration","partition":2,"replicas":[1],"log_dirs":["any"]}]}

Save this to use as the --reassignment-json-file option during rollback
Successfully started partition reassignments for partition-data-migration-0,partition-data-migration-1,partition-data-migration-2


[root@kafka-01 kafka-3.2.3]# bin/kafka-reassign-partitions.sh --bootstrap-server localhost:9092 --reassignment-json-file ../configs/partitions-reassignment.json --verify
Status of partition reassignment:
Reassignment of partition partition-data-migration-0 is complete.
Reassignment of partition partition-data-migration-1 is complete.
Reassignment of partition partition-data-migration-2 is complete.

Clearing broker-level throttles on brokers 0,1,2
Clearing topic-level throttles on topic partition-data-migration




[root@kafka-01 kafka-3.2.3]# bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic partition-data-migration --partition 2 --from-beginning
0
1
2
3
4
5
6








