# Lab3 集群管理与维护


## 修改Kafka Topic

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
