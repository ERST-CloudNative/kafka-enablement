
# Lab 2  集群管理与维护

## 1. 查看kafka集群信息

通过Zookeeper查看集群信息


```
[root@kafka-01 ~]# cd kafka-enablement/environment/kafka-3.2.3/
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

