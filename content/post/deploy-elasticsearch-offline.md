---
title: "离线环境下利用 docker 部署 Elasticsearch 集群"
date: 2019-08-26T10:18:11+08:00
# comment: false
url: /2019/08/26/deploy-elasticsearch-offline.html
tags: [ "CentOS", "Elasticsearch", "Docker", "Linux", "Createrepo" ]
categories: ["Linux"]
---
在3台CentOS上离线安装docker并通过docker-compose部署Elasticsearch集群
<!--more-->

- 在每台CentOS上离线安装docker
- 在每台CentOS上通过 `docker-compose` 拉起ES官方镜像及 `kibana` 的Container

最终效果
![image.png](https://i.loli.net/2019/08/26/yW3KPqBtos412Ve.png)

## 1. 离线安装docker
### 1.1 制作docker本地安装源
>createrepo 命令用于创建yum源（软件仓库），即为存放于本地特定位置的众多rpm包建立索引，描述各包所需依赖信息，并形成元数据

在线机器执行
```bash
# 创建离线包存放目录,并赋予读写权限
sudo mkdir -p /home/docker/local 
sudo chmod -R 777 /home/docker/local

# 仅下载需要用到的离线包
sudo yum install --downloadonly --downloaddir=/home/docker/local \
  yum-utils \
  device-mapper-persistent-data \
  lvm2 \
  createrepo

# Install using the repository and createrepo
sudo yum install -y \
  yum-utils \
  device-mapper-persistent-data \
  lvm2 \
  createrepo

# set up the stable repository.
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

# cache data to the /var/cache/yum directory
sudo yum clean all
sudo yum makecache

# 下载离线docker-ce包
sudo yumdownloader --resolve --destdir=/home/docker/local \
  docker-ce \
  docker-ce-cli \
  containerd.io

# 初始化安装源repodata库
createrepo /home/docker/local 
# createrepo --update /home/docker/local

# 打包导出安装源,docker-local.tar.gz这个文件，就是我们制作好的离线安装源。其他CentOS下的安装源一样的方法制作
cd /home/docker/local
tar -zcvf docker-local.tar.gz *

```
### 1.2 安装并验证
每台离线机器上执行
```bash
# 创建目录上传 docker-local.tar.gz 并解压 
mkdir -p /home/docker/local
tar -zxvf docker-local.tar.gz -C /home/docker/local
cd /home/docker/local

# 安装createrepo; 如果报错需要依赖则安装,都在/home/docker/local/目录下
# rpm -ivh deltarpm-3.6-3.el7.x86_64.rpm
# rpm -ivh libxml2-python-2.9.1-6.el7_2.3.x86_64.rpm
# rpm -ivh python-deltarpm-3.6-3.el7.x86_64.rpm
rpm -ivh createrepo-0.9.9-28.el7.noarch.rpm

# Backup repository folder.
cp -rv /etc/yum.repos.d /etc/yum.repos.d-bak
# Delete all online repository files.
rm -rf /etc/yum.repos.d/*
# Create locate repository file.
# enabled=1 开启该仓库; gpgcheck=0 不做gpg检查;
cat << EOF > /etc/yum.repos.d/docker-ce-local.repo
[docker]
name=docker local
baseurl=file:///home/docker/local/
enabled=1
gpgcheck=0
EOF

# Now update the local repository.
createrepo /home/docker/local/
# Now enable the local repository.
yum clean all
yum makecache

# List repository
yum repolist

# 安装docekr-ce, 如果之前装过docker，则执行 `yum update` 来更新docker
yum install -y docker-ce docker-ce-cli containerd.io

# ----------------------------------------------
# 检查是否安装成功
systemctl start docker
docker version

# 还原repo修改
rm -rf /etc/yum.repos.d
mv /etc/yum.repos.d-bak /etc/yum.repos.d

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

# 下载docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
每台离线机器执行
```bash
# 将elasticsearch670.tar.gz, kibana670.tar.gz镜像上传至离线机器并load镜像
docker load < elasticsearch670.tar.gz
docker load < kibana670.tar.gzd

# 打tag
# docker tag a19f604cdxxx elasticsearch:6.7.0
# docker tag a19f604cdxxx kibana:6.7.0

# 查看镜像
docker images ls

# The vm.max_map_count kernel setting needs to be set to at least 262144 for production use.
echo 'vm.max_map_count=262144' >> /etc/sysctl.conf && sysctl -p

# 安装docker-compose
# 将docker-compose上传为/usr/local/bin/docker-compose文件，检查是否可用
docker-compose --version
```

## 3. 拉起container
### 3.1 配置
到每台离线机器上创建指定目录下的 `es.yaml` , 并修改 `network.publish_host` 和 `discovery.zen.ping.unicast.hosts` 的值为设置了 `node.master: true` node 的IP:9300端口。
#### 3.1.1 离线机器node-01
node1 机器上执行 `vim /home/soft/elasticsearch/config/elasticsearch.yml`, 修改IP
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
data目录映射: 数据持久化
```bash
mkdir -p /home/soft/elasticsearch/data
chmod g+rwx /home/soft/elasticsearch/data
chown 1000:1000 /home/soft/elasticsearch/data
```
插件目录映射: 1. 避免进入docker安装插件 2. 预防 docker recreate

```sh
mkdir -p /home/soft/elasticsearch/plugins
```

安装 kibana

```bash
# mkdir -p /home/soft/Kibana/config/
cat <<EOF > /home/soft/Kibana/config/kibana.yml
server.host: 0.0.0.0
elasticsearch.hosts:
  - http://elasticsearch:9200
xpack.monitoring.enabled: false
EOF
```
通过 `docker-compose` 拉起container

```bash
# mkdir -p /home/soft/docker-compose
# cd /home/soft/docker-compose && vim /home/soft/docker-compose/docker-compose.yml

# 内容如下
version: "2.2"
services:
  elasticsearch:
    image: elasticsearch:6.7.0
    container_name: es-01
    environment:
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms4g -Xmx4g"
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - /home/soft/elasticsearch/data:/usr/share/elasticsearch/data
      - /home/soft/elasticsearch/plugins:/usr/share/elasticsearch/plugins
      - /home/soft/elasticsearch/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml
    ports:
      - 9200:9200
      - 9300:9300
    networks:
      - esnet

  kibana:
    image: kibana:6.7.0
    ports:
      - 5601:5601
    volumes:
      - /home/soft/Kibana/config/kibana.yml:/usr/share/kibana/config/kibana.yml
    networks:
      - esnet

networks:
  esnet:
```
执行 `docker-compose up -d` 拉起 container，可以看到es和kibana容器。

执行 `docker ps` 容器正常运行不退出。

#### 3.1.2 离线机器node-02

node2 机器上执行 `vim /home/soft/elasticsearch/config/elasticsearch.yml` , 修改IP
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
数据目录映射, 插件目录映射
```bash
mkdir -p /home/soft/elasticsearch/{data,plugins}
chmod g+rwx /home/soft/elasticsearch/data
chown 1000:1000 /home/soft/elasticsearch/data
```
通过 `docker-compose` 拉起container
```bash
# mkdir -p /home/soft/docker-compose
# cd /home/soft/docker-compose && vim /home/soft/docker-compose/docker-compose.yml

# 内容如下
version: "2.2"
services:
  elasticsearch:
    image: elasticsearch:6.7.0
    container_name: es-02
    environment:
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms4g -Xmx4g"
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - /home/soft/elasticsearch/data:/usr/share/elasticsearch/data
      - /home/soft/elasticsearch/plugins:/usr/share/elasticsearch/plugins
      - /home/soft/elasticsearch/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml
    ports:
      - 9200:9200
      - 9300:9300
    networks:
      - esnet

networks:
  esnet:
```
执行 `docker-compose up -d` 拉起 container，可以看到一个es容器.

执行 `docker ps` 容器正常运行不退出。

#### 3.1.3 离线机器node-03

node3 机器上执行 `vim /home/soft/elasticsearch/config/elasticsearch.yml` , 修改IP
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
数据目录映射,插件目录映射
```bash
mkdir -p /home/soft/elasticsearch/{data,plugins}
chmod g+rwx /home/soft/elasticsearch/data
chown 1000:1000 /home/soft/elasticsearch/data
```
通过 `docker-compose` 拉起container
```bash
# mkdir -p /home/soft/docker-compose
# cd /home/soft/docker-compose && vim /home/soft/docker-compose/docker-compose.yml

# 内容如下
version: "2.2"
services:
  elasticsearch:
    image: elasticsearch:6.7.0
    container_name: es-03
    environment:
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms4g -Xmx4g"
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - /home/soft/elasticsearch/data:/usr/share/elasticsearch/data
      - /home/soft/elasticsearch/plugins:/usr/share/elasticsearch/plugins
      - /home/soft/elasticsearch/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml
    ports:
      - 9200:9200
      - 9300:9300
    networks:
      - esnet

networks:
  esnet:
```
执行 `docker-compose up -d` 拉起 container，可以看到一个es容器.

执行 `docker ps` 容器正常运行不退出。

### 3.2 集群验证

任意一台机器上执行
```bash
# 节点数: 3个
curl localhost:9200/_cat/nodes

# 健康: green
curl localhost:9200/_cat/health

# 查看存储 
curl localhost:9200/_cat/allocation?v

# node-01机器上执行, 返回 302 found 正常
curl -I localhost:5601
```
## 4. 安装插件

以安装ik分词插件为例，每台离线机器上操作

```bash
# 解压到指定目录
tar -zxvf plugins-ik.tgz -C /home/soft/elasticsearch/plugins/
ll /home/soft/elasticsearch/plugins/ 

# 拷贝配置做映射, 1. 便于修改 2. 让es识别解压后的插件
mkdir /home/soft/elasticsearch/config/plugins-config
mv /home/soft/elasticsearch/plugins/analysis-ik/config/ /home/soft/elasticsearch/config/plugins-config/analysis-ik

# 新增映射
vim /home/soft/docker-compose/docker-compose.yml
# /home/soft/elasticsearch/config/plugins-config/analysis-ik:/usr/share/elasticsearch/config/analysis-ik
```

![image.png](https://i.loli.net/2019/08/28/gmtLnsiAkTMyUfZ.png)

重建container

```bash
# 重启docker
docker restart $(docker ps -qa)
cd /home/soft/docker-compose/
docker-compose up -d


# 验证这个节点插件是否安装
curl localhost:9200/_cat/plugins
```

![image.png](https://i.loli.net/2019/08/28/g8Z3xKiMhoqjHNW.png)



参考连接：

https://docs.docker.com/install/linux/docker-ce/centos/

https://blog.csdn.net/hello_junz/article/details/79882602
