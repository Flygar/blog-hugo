---
title: "离线安装docker并部署elasticsearch组成集群"
date: 2019-08-26T10:18:11+08:00
draft: true
toc: true
commentDisabled: false
tags: [ "Operation", "CentOS", "Elasticsearch", "Docker", "LInux", "Createrepo" ]
topics: [ "Operation", "Linux", "Elasticsearch", "Docker" ]
---

在3台CentOS上离线安装Docker并部署Elasticsearch组成集群
<!--more-->
- 在每台CentOS上离线安装docker
- 在每台CentOS上拉起ES官方镜像的Container
- 将3台CentOS上的Container组成ES集群

最终效果
![image.png](https://i.loli.net/2019/08/26/yW3KPqBtos412Ve.png)

## 1. 离线安装docker
### 1.1 制作docker本地安装源
>createrepo 命令用于创建yum源（软件仓库），即为存放于本地特定位置的众多rpm包建立索引，描述各包所需依赖信息，并形成元数据

在线机器执行
```bash
# 更新并升级
yum update
yum upgrade

# 卸载老版本docker
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

# 创建离线包存放目录,并赋予读写权限
mkdir -p /home/docker/local 
chmod -R 777 /home/docker/local

# 仅下载离线包到指定目录
sudo yum install --downloadonly --downloaddir=/home/docker/local yum-utils \
  device-mapper-persistent-data \
  lvm2 \
  createrepo
# Install using the repository and createrepo
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2 \
  createrepo

# set up the stable repository.
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

# 跟新yum源索引 （官方没做，为啥要做？验证下）
# yum makecache fast

# 下载离线docker-ce包
sudo yum install --downloadonly --downloaddir=/home/docker/local docker-ce docker-ce-cli containerd.io

# 下载密钥文件
more /etc/yum.repos.d/docker-ce.repo
cd /home/docker/local
wget https://download.docker.com/linux/centos/gpg

# 初始化安装源repodata库
createrepo -pdo /home/docker/local /home/docker/local
createrepo --update /home/docker/local

# 打包导出安装源,docker-local.tar.gz这个文件，就是我们制作好的离线安装源。其他CentOS下的安装源一样的方法制作
cd /home/docker/local
tar -zcvf docker-local.tar.gz *

```
### 1.2 安装并验证
每台离线机器上执行
```bash
# 创建目录上传 docker-local.tar.gz 并解压 
mkdir -p /home/docker/local
cd /home/docker/local
tar -zxvf docker-local.tar.gz

# 安装createrepo; 如果报错需要依赖则安装,都在/home/docker/local/目录下
# rpm -ivh deltarpm-3.6-3.el7.x86_64.rpm
# rpm -ivh libxml2-python-2.9.1-6.el7_2.3.x86_64.rpm
# rpm -ivh python-deltarpm-3.6-3.el7.x86_64.rpm
cd /home/docker/local
rpm -ivh createrepo-0.9.9-28.el7.noarch.rpm

# 备份安装源
cd /etc/yum.repos.d/
mkdir repobak
mv * repobak/

# 配置离线安装源
# enabled=1 开启该仓库; gpgcheck=0 不做gpg检查; gpgkey 可以去掉;
cat << EOF >> /etc/yum.repos.d/docker-ce-local.repo
[docker]
name=docker local
baseurl=file:///home/docker/local/
gpgcheck=0
enabled=1
gpgkey=file:///home/docker/local/gpg"
EOF

# 构建本地安装源
createrepo -d /home/docker/local/repodata
# yum clean all (清除缓存)
# yum makecache (创建缓存)

# 检查本地是否安装成功
yum repolist
# 安装docekr-ce
yum install docker-ce docker-ce-cli containerd.io

# 检查是否安装成功
systemctl start docker
docker version

# 还原修改
cd /etc/yum.repos.d/
mv repobak/* ./
mv docker-ce-local.repo repobak/

# 创建docker用户组
groupadd docker
# 将指定用户（比如ittest）加入docker用户组
usermod -aG docker  ittest
# 重启docker
systemctl restart docker
```


## 2. 加载elasticsearch和kibana镜像
拉取官方es镜像或通过dockerfile构建es镜像

在线机器执行
```bash
# 在线机器获取官方es和kibana镜像
docker pull elasticsearch:6.7.0
docker pull kibana:6.7.0

# 查看镜像
docker images

# 保存至本地,镜像文件必须tar.gz结尾
docker save elasticsearch:6.7.0 > elasticsearch670.tar.gz
docker save kibana:6.7.0 > kibana670.tar.gz

# The vm.max_map_count kernel setting needs to be set to at least 262144 for production use.
echo 'vm.max_map_count=262144' >> /etc/sysctl.conf && sysctl -p
```
每台离线机器执行
```bash
# 将elasticsearch670.tar.gz和kibana670.tar.gz镜像上传至离线机器并load镜像
docker load < elasticsearch670.tar.gz
docker load < kibana670.tar.gz

# 查看镜像
docker images ls
```

## 3. 拉起container
### 3.1 配置
到每台离线机器上创建指定目录下的 `es.yaml` , 并修改 `network.publish_host` 和 `discovery.zen.ping.unicast.hosts` 的值为设置了 `node.master: true` node 的IP:9300端口。
#### 3.1.1 离线机器node1
node1 机器上执行 `vim /home/soft/ES/config/es.yml`, 修改IP
```bash
# node1 
cluster.name: elasticsearch-cluster
node.name: es-node-01
network.bind_host: 0.0.0.0
network.publish_host: 192.168.0.126
http.port: 9200
transport.tcp.port: 9300
http.cors.enabled: true
http.cors.allow-origin: "*"
node.master: true 
node.data: true  
discovery.zen.ping.unicast.hosts: ["192.168.0.126:9300","192.168.0.127:9300","192.168.0.128:9300"]
discovery.zen.minimum_master_nodes: 2
```
数据目录映射
```bash
mkdir -p /home/soft/ES/data
chmod g+rwx /home/soft/ES/data
chown 1000:1000 /home/soft/ES/data
```
配置kibana
```bash
# mkdir -p /home/soft/Kibana/config/
cat <<EOF > /home/soft/Kibana/config/kibana.yml
server.host: 0.0.0.0
elasticsearch.hosts:
  - http://elasticsearch:9200
xpack.monitoring.enabled: false
EOF
```
拉起container
```bash
# 执行docker命令后 ， 执行 `docker ps` 容器状态正常 
docker run -e ES_JAVA_OPTS="-Xms4g -Xmx4g" -d -p 9200:9200 -p 9300:9300 -v /home/soft/ES/config/es.yml:/usr/share/elasticsearch/config/elasticsearch.yml -v /home/soft/ES/data:/usr/share/elasticsearch/data --name ES01 elasticsearch-aws

# 拉起kibana
docker run -d --link <es_containerID>:elasticsearch -v /home/soft/Kibana/config/kibana.yml:/usr/share/kibana/config/kibana.yml -p 5601:5601 kibana:6.7.0
```
#### 3.1.2 离线机器node2
node2 机器上执行 `vim /home/soft/ES/config/es.yml`, 修改IP
```bash
# node2
cluster.name: elasticsearch-cluster
node.name: es-node-02
network.bind_host: 0.0.0.0
network.publish_host: 192.168.0.127
http.port: 9200
transport.tcp.port: 9300
http.cors.enabled: true
http.cors.allow-origin: "*"
node.master: true 
node.data: true  
discovery.zen.ping.unicast.hosts: ["192.168.0.126:9300","192.168.0.127:9300","192.168.0.128:9300"]
discovery.zen.minimum_master_nodes: 2
```
数据目录映射
```bash
mkdir -p /home/soft/ES/data
chmod g+rwx /home/soft/ES/data
chown 1000:1000 /home/soft/ES/data
```
配置kibana
```bash
# mkdir -p /home/soft/Kibana/config/
cat <<EOF > /home/soft/Kibana/config/kibana.yml
server.host: 0.0.0.0
elasticsearch.hosts:
  - http://elasticsearch:9200
xpack.monitoring.enabled: false
EOF
```
拉起container
```bash
# 执行docker命令后 ， 执行 `docker ps` 容器状态正常 
docker run -e ES_JAVA_OPTS="-Xms4g -Xmx4g" -d -p 9200:9200 -p 9300:9300 -v /home/soft/ES/config/es.yml:/usr/share/elasticsearch/config/elasticsearch.yml -v /home/soft/ES/data:/usr/share/elasticsearch/data --name ES02 elasticsearch-aws

# 拉起kibana
docker run -d --link <es_containerID>:elasticsearch -v /home/soft/Kibana/config/kibana.yml:/usr/share/kibana/config/kibana.yml -p 5601:5601 kibana:6.7.0
```
#### 3.1.3 离线机器node3
node3 机器上执行 `vim /home/soft/ES/config/es.yml`, 修改IP
```bash
# node3
cluster.name: elasticsearch-cluster
node.name: es-node-03
network.bind_host: 0.0.0.0
network.publish_host: 192.168.0.128
http.port: 9200
transport.tcp.port: 9300
http.cors.enabled: true
http.cors.allow-origin: "*"
node.master: true 
node.data: true  
discovery.zen.ping.unicast.hosts: ["192.168.0.126:9300","192.168.0.127:9300","192.168.0.128:9300"]
discovery.zen.minimum_master_nodes: 2
```
数据目录映射
```bash
mkdir -p /home/soft/ES/data
chmod g+rwx /home/soft/ES/data
chown 1000:1000 /home/soft/ES/data
```
配置kibana
```bash
# mkdir -p /home/soft/Kibana/config/
cat <<EOF > /home/soft/Kibana/config/kibana.yml
server.host: 0.0.0.0
elasticsearch.hosts:
  - http://elasticsearch:9200
xpack.monitoring.enabled: false
EOF
```
拉起container
```bash
# 执行docker命令后 ， 执行 `docker ps` 容器状态正常 
docker run -e ES_JAVA_OPTS="-Xms4g -Xmx4g" -d -p 9200:9200 -p 9300:9300 -v /home/soft/ES/config/es.yml:/usr/share/elasticsearch/config/elasticsearch.yml -v /home/soft/ES/data:/usr/share/elasticsearch/data --name ES03 elasticsearch-aws

# 拉起kibana
docker run -d --link <es_containerID>:elasticsearch -v /home/soft/Kibana/config/kibana.yml:/usr/share/kibana/config/kibana.yml -p 5601:5601 kibana:6.7.0
```
## 3.1 集群验证
任意一台机器上执行
```bash
# 节点数: 3个
curl localhost:9200/_cat/nodes

# 健康: green
curl localhost:9200/_cat/health

# kibana: 返回 302 found
curl -I localhost:5601
```
参考连接：

https://docs.docker.com/install/linux/docker-ce/centos/

https://blog.csdn.net/hello_junz/article/details/79882602




