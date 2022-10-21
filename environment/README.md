# Lab 1

## 环境准备

在开始正式实验之前，需要在您的VM上安装以下软件:

* Java 8
* OpenSSL
* CFSSL

其中，如果需要重新产生自己证书，则OpenSSL 和 CFSSL是需要安装的， 默认SSL证书配置已经在environment目录中提供，不需要再安装这两个工具.

## Lab实操

获取实验素材

```
[root@kafka-01 ~]# git@github.com:ERST-CloudNative/kafka-enablement.git
[root@kafka-01 ~]# cd kafka-enablement/environment/
[root@kafka-01 environment]# ls
configs       connect-1.sh  environment.sh  kafka-0.sh  kafka-2.sh   README.md  zookeeper-0.sh  zookeeper-2.sh
connect-0.sh  connect-2.sh  include.sh      kafka-1.sh  kafka-3.2.3  ssl        zookeeper-1.sh
```

部署Zookeeper集群

```
[root@kafka-01 environment]# ./zookeeper-0.sh
Creating myid file
[root@kafka-01 environment]# ./zookeeper-1.sh
Creating myid file
[root@kafka-01 environment]# ./zookeeper-2.sh
Creating myid file
```
部署Kafka集群

```
[root@kafka-01 environment]# ./kafka-0.sh
[root@kafka-01 environment]# ./kafka-1.sh
[root@kafka-01 environment]# ./kafka-2.sh
```

查看部署情况

```
[root@kafka-01 environment]# jps
16401 QuorumPeerMain
16771 QuorumPeerMain
30564 Kafka
26518 Kafka
32678 Jps
28731 Kafka
17148 QuorumPeerMain
```


