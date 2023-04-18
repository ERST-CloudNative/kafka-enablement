## 在OCI上部署社区版本的Kafka集群


Kafka集群服务部署框图如下：

![image](https://user-images.githubusercontent.com/4653664/232767152-355e0114-0daa-41b2-8928-317549b44b4c.png)



### 1. 创建虚拟机

这里供需要创建3台虚拟机，每台虚拟机配置为2OCPU/8GB/50GB, 虚拟机名称依次为`kafka-01`,`kafka-02`,`kafka-03`

>其中，虚拟机配置根据实际项目需求进行调整。

虚拟机名称

<img width="630" alt="1681807480968" src="https://user-images.githubusercontent.com/4653664/232723495-c238079d-6765-41c4-b77b-4f33d7565488.png">


虚拟机镜像和规格选型

<img width="627" alt="1681807514231" src="https://user-images.githubusercontent.com/4653664/232723619-1334b7d8-01c6-4f8e-a17a-1507aca8115d.png">


网络配置

<img width="620" alt="1681807540112" src="https://user-images.githubusercontent.com/4653664/232723751-0c542f5d-f93d-4aec-9020-ebbbc586e5c6.png">


其它

<img width="654" alt="1681807573463" src="https://user-images.githubusercontent.com/4653664/232723892-9b7d64f3-f369-4998-ad3f-67a752e04c61.png">

### 2. 域名规划配置

虚拟机创建就绪后，可以查看相应的私网IP地址

<img width="764" alt="1681807681346" src="https://user-images.githubusercontent.com/4653664/232724351-98ae74d3-932c-44ad-a6c4-59e0a0e4690b.png">

为了便于管理，这里私有OCI DNS对kafka节点的域名进行统一规划。

首先，创建一个`Private Zone`

<img width="862" alt="1681807808075" src="https://user-images.githubusercontent.com/4653664/232724956-17cbde99-abb8-4afd-820d-584a840251fe.png">

接下来，添加`record`

<img width="959" alt="1681807917074" src="https://user-images.githubusercontent.com/4653664/232725423-e58cb90d-c4eb-45b3-9002-668e552e2a84.png">

将以下红框内的域名全部添加进来

<img width="797" alt="1681807979543" src="https://user-images.githubusercontent.com/4653664/232725705-c43098b8-106d-4dc0-83d9-60b28461f679.png">

添加完成后，选中添加的`record`，然后点击`Publish changes`

<img width="795" alt="1681808038993" src="https://user-images.githubusercontent.com/4653664/232725995-67f5f8c7-d3e3-43fb-9352-936b067f199a.png">

至此，域名规划部分完成。


### 3. 虚拟机操作系统配置

3.1 安装open-jdk

```
# yum install -y java-17-openjdk java-17-openjdk-devel

# java -version
```

3.2 禁用`RAM` `swap`

```
# swapoff -a
# sed -i '/ swap / s/^/#/' /etc/fstab

```

3.3 禁用`firewalld`防火墙(可选)

```
# systemctl stop firewalld

# systemctl disable firewalld
```

### 4. kafka集群部署

#### 4.1 获取安装包

```
# wget http://mirror.cogentco.com/pub/apache/kafka/2.8.2/kafka_2.12-2.8.2.tgz

# tar -xvf kafka_2.12-2.8.2.tgz

# mv kafka_2.12-2.8.2 /opt/kafka
```

#### 4.2 为kafka和zookeeper创建新的目录

```
# mkdir -p /data/kafka
# mkdir -p /data/zookeeper
# mkdir -p /opt/scripts/
```

#### 4.3 为每个Zookeeper Server指定一个ID

```
# echo "1" > /data/zookeeper/myid
```

```
# echo "2" > /data/zookeeper/myid
```

```
# echo "3" > /data/zookeeper/myid
```

#### 4.4 更新kafka和Zookeeper配置文件

每台虚拟机上kafka的配置如下：

```
[kafka-01]# cat /opt/kafka/config/server.properties

# change this for each broker
broker.id=0
# change this to the hostname of each broker
advertised.listeners=PLAINTEXT://kafka-01.kafkacluster.myoci:9092
# The ability to delete topics
delete.topic.enable=true
# Where logs are stored
log.dirs=/data/kafka
# default number of partitions
num.partitions=8
# default replica count based on the number of brokers
default.replication.factor=3
# to protect yourself against broker failure
min.insync.replicas=2
# logs will be deleted after how many hours
log.retention.hours=168
# size of the log files
log.segment.bytes=1073741824
# check to see if any data needs to be deleted
log.retention.check.interval.ms=300000
# location of all zookeeper instances and kafka directory
zookeeper.connect=zk-01.kafkacluster.myoci:2181,zk-02.kafkacluster.myoci:2181,zk-02.kafkacluster.myoci:2181/kafka

# timeout for connecting with zookeeper
zookeeper.connection.timeout.ms=6000
# automatically create topics
auto.create.topics.enable=true
````

```
[rkafka-02]# cat /opt/kafka/config/server.properties

# change this for each broker
broker.id=1
# change this to the hostname of each broker
advertised.listeners=PLAINTEXT://kafka-02.kafkacluster.myoci:9092
# The ability to delete topics
delete.topic.enable=true
# Where logs are stored
log.dirs=/data/kafka
# default number of partitions
num.partitions=8
# default replica count based on the number of brokers
default.replication.factor=3
# to protect yourself against broker failure
min.insync.replicas=2
# logs will be deleted after how many hours
log.retention.hours=168
# size of the log files
log.segment.bytes=1073741824
# check to see if any data needs to be deleted
log.retention.check.interval.ms=300000
# location of all zookeeper instances and kafka directory
zookeeper.connect=zk-01.kafkacluster.myoci:2181,zk-02.kafkacluster.myoci:2181,zk-02.kafkacluster.myoci:2181/kafka
# timeout for connecting with zookeeper
zookeeper.connection.timeout.ms=6000
# automatically create topics
auto.create.topics.enable=true

```

```
[kafka-03]# cat /opt/kafka/config/server.properties

# change this for each broker
broker.id=2
# change this to the hostname of each broker
advertised.listeners=PLAINTEXT://kafka-03.kafkacluster.myoci:9092
# The ability to delete topics
delete.topic.enable=true
# Where logs are stored
log.dirs=/data/kafka
# default number of partitions
num.partitions=8
# default replica count based on the number of brokers
default.replication.factor=3
# to protect yourself against broker failure
min.insync.replicas=2
# logs will be deleted after how many hours
log.retention.hours=168
# size of the log files
log.segment.bytes=1073741824
# check to see if any data needs to be deleted
log.retention.check.interval.ms=300000
# location of all zookeeper instances and kafka directory
zookeeper.connect=zk-01.kafkacluster.myoci:2181,zk-02.kafkacluster.myoci:2181,zk-02.kafkacluster.myoci:2181/kafka

# timeout for connecting with zookeeper
zookeeper.connection.timeout.ms=6000
# automatically create topics
auto.create.topics.enable=true

```


每台虚拟机上kzookeeper的配置如下:

```
[kafka-0x]# cat /opt/kafka/config/zookeeper.properties

# the directory where the snapshot is stored.
dataDir=/data/zookeeper
# the port at which the clients will connect
clientPort=2181
# setting number of connections to unlimited
maxClientCnxns=0
# keeps a heartbeat of zookeeper in milliseconds
tickTime=2000
# time for initial synchronization
initLimit=10
# how many ticks can pass before timeout
syncLimit=5
# define servers ip and internal ports to zookeeper
server.1=zk-01.kafkacluster.myoci:2888:3888
server.2=zk-02.kafkacluster.myoci:2888:3888
server.3=zk-03.kafkacluster.myoci:2888:3888

```

#### 4.5 创建Zookeeper的systemd服务

```
[kafka-0x]# cat /opt/scripts/zookeeper

#!/bin/bash
#/etc/init.d/zookeeper
DAEMON_PATH=/opt/kafka/bin
DAEMON_NAME=zookeeper
# Check that networking is up.
#[ ${NETWORKING} = "no" ] && exit 0

PATH=$PATH:$DAEMON_PATH

case "$1" in
start)
# Start daemon.
pid=`ps ax | grep -i 'org.apache.zookeeper' | grep -v grep | awk '{print $1}'`
if [ -n "$pid" ]
then
echo "Zookeeper is already running";
else
$DAEMON_PATH/zookeeper-server-start.sh -daemon /opt/kafka/config/zookeeper.properties;
echo $?
echo "Starting $DAEMON_NAME";
fi
;;
stop)
echo "Shutting down $DAEMON_NAME";
$DAEMON_PATH/zookeeper-server-stop.sh
;;
restart)
$0 stop
sleep 2
$0 start
;;
status)
pid=`ps ax | grep -i 'org.apache.zookeeper' | grep -v grep | awk '{print $1}'`
if [ -n "$pid" ]
then
echo "Zookeeper is Running as PID: $pid"
else
echo "Zookeeper is not Running"
fi
;;
*)
echo "Usage: $0 {start|stop|restart|status}"
exit 1
esac

exit 0

```

```
[kafka-0x]# cat /etc/systemd/system/zookeeper.service

[Unit]
Description = zookeeper service for kafaka cluster
After = network.target

[Service]
Type=forking
ExecStart = /opt/scripts/zookeeper restart

[Install]
WantedBy = multi-user.target
```


```
[kafka-0x]# chmod +x /opt/scripts/zookeeper
```

#### 4.6 创建kafka的systemd服务

```
[kafka-0x]# cat /opt/scripts/kafka

#!/bin/bash
#/etc/init.d/kafka
DAEMON_PATH=/opt/kafka/bin
DAEMON_NAME=kafka
# Check that networking is up.
#[ ${NETWORKING} = "no" ] && exit 0

PATH=$PATH:$DAEMON_PATH

# See how we were called.
case "$1" in
start)
# Start daemon.
pid=`ps ax | grep -i 'kafka.Kafka' | grep -v grep | awk '{print $1}'`
if [ -n "$pid" ]
then
echo "Kafka is already running"
else
echo "Starting $DAEMON_NAME"
$DAEMON_PATH/kafka-server-start.sh -daemon /opt/kafka/config/server.properties
fi
;;
stop)
echo "Shutting down $DAEMON_NAME"
$DAEMON_PATH/kafka-server-stop.sh
;;
restart)
$0 stop
sleep 2
$0 start
;;
status)
pid=`ps ax | grep -i 'kafka.Kafka' | grep -v grep | awk '{print $1}'`
if [ -n "$pid" ]
then
echo "Kafka is Running as PID: $pid"
else
echo "Kafka is not Running"
fi
;;
*)
echo "Usage: $0 {start|stop|restart|status}"
exit 1
esac

exit 0
```

```
[kafka-0x]# cat /etc/systemd/system/kafka.service

[Unit]
Description = zookeeper service for kafaka cluster
After = zookeeper.target

[Service]
Type=forking
ExecStart = /opt/scripts/kafka restart

[Install]
WantedBy = multi-user.target

```


```
[kafka-0x]# chmod +x /opt/scripts/kafka
```

#### 4.7 运行kafka集群

依次在每台虚拟机上执行以下命令行：

运行zookeeper集群

```
# systemctl restart zookeeper
# systemctl enable zookeeper
```

运行kafka集群
```
# systemctl restart kafka
# systemctl enable kafka
```

验证zookeeper和kafka进程是否正常运行

```
[kafka-0x]# jps

75059 Kafka
90013 Jps
74079 QuorumPeerMain
```


#### 4.8 测试验证

创建一个`topic`

```
[kafka-01 ~]# /opt/kafka/bin/kafka-topics.sh --zookeeper zk-01.kafkacluster.myoci:2181/kafka --create --topic demo --replication-factor 1 --partitions 3
```

生产消息

```
[kafka-01 ~]# /opt/kafka/bin/kafka-console-producer.sh --bootstrap-server kafka-01.kafkacluster.myoci:9092 --topic demo
>1
>2
>3
>hello
>kafka

```

消费消息

```
[kafka-01 ~]# /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server kafka-01.kafkacluster.myoci:9092 --topic demo --from-beginning
3
kafka
1
2
hello

```
