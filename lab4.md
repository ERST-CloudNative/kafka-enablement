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


