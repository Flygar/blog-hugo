---
title: "vps安全指北"
date: 2020-02-29T17:02:39+08:00
url: /2018/02/24/golang-function-parameters-passed-by-value.html
---

以ubuntu系统为例,提升vps安全

```sh
# update list of available packages 
# upgrade the system by installing/upgrading packages
apt update && apt upgrade

# who 或者 w 查看当前登陆的用户
# 检查登陆日志
less /var/log/auth.log
who /var/log/wtmp

```

### 设置一个足够复杂的密码
- 不推荐使用单词或短语: superstar, magicmaster, woshiMT
- 不推荐使用生日加姓名的组合方便记忆的密码: liergou1225, trump2016, jujingyi1994
- 不推荐使用很长的字母与数字的组合: ABC12345678, qwert9876543210
- 不推荐使用如下键盘布局的密码: 1qaz@WSX, 1qw2!QW@, 1234!@#$, qwerASDF
>请大家知晓：扫描密码是由机器人软件完成，上面列举的这类密码，统统收集在密码词典里或者可以通过算法轻松合成，完全没有安全性可言，无论您自己觉得多么烧脑难记。所以，请各位设置包括大小写字母和数字在内的、尽可能没有规律的字符串做密码。足够复杂的密码，不在于变换了多少花样，而在于变换花样中找不到规律，从而让扫描软件的词典和算法失效。
- 推荐使用如下这种没有规律的密码: .TUx\42\qA

### 变更ssh端口为非22
```sh
# vim /etc/ssh/sshd_config
# 改为你想要的端口,最好在1-1024之间，防止与用户进程端口冲突
Port 998

# 应用配置
sudo service sshd restart # sudo /etc/init.d/ssh restart
```

### 禁止root用户登陆
```sh
# 在vps端创建其他用户flygar，最好不要用会被扫描命中的名字，例如：admin,test,testuser1, foobar
adduser flygar # adduser 比 useradd 命令更加友好，推荐使用

# 修改用户权限, 为了使用sudo切回root，毕竟谁会不喜欢用root用户呢
chmod +w /etc/sudoers
vim /etc/sudoers
# 添加下图的配置语句，并且保存修改
# flygar	ALL=(ALL:ALL) ALL
chmod -w /etc/sudoers

# 查看用户属性并验证是否创建成功
# 用户名:口令:用户标识号:组标识号:注释性描述:用户主目录:命令解释程序
cat /etc/passwd
su flygar

# 删除用户
deluser flygar
vim /etc/sudoers # 删除用户权限

#----------------------------------------------------
# vim /etc/ssh/sshd_config
#禁用root账户登录，非必要，但为了安全性，请配置
PermitRootLogin no

# 应用配置
sudo service sshd restart # sudo /etc/init.d/ssh restart
```

### 设置只允许使用密钥登陆
```sh
# 在客户端生成密钥
ssh-keygen -b 4096 -t rsa
# 将客户端的公钥发送给vps的自定义用户
ssh-copy-id flygar@${IP_address}

# vps端配置config
vim /etc/ssh/sshd_config

RSAAuthentication yes  #允许 RSA 密钥
PubkeyAuthentication yes    #启用公告密钥配对认证方式 
AuthorizedKeysFile  %h/.ssh/authorized_keys    #设定PublicKey文件路径
PasswordAuthentication no #禁止密码验证登录。如果启用(yes)的话,RSA认证登录就没有意义了

# 应用配置
sudo service sshd restart # sudo /etc/init.d/ssh restart
# 如果哪天你本地的密钥丢了或重置了，那只能进入vps官网使用 VNC 的方式进入服务器上传你的公钥了
```
换了端口和认证方式，降低了被扫描、探测密码的请求
![image.png](https://i.loli.net/2020/03/02/dxKW2rAg9CHynmf.png)
其实还不够安全，vps上可能还暴露了3306,9200这种端口,需要利用deyhosts实现自动屏蔽疯狂尝试请求的IP。

### 屏蔽扫描IP,拒绝成为肉鸡
保护小鸡从我做起。  

>denyhosts是Python语言写的一个程序，它会分析sshd的日志文件，当发现重复的失败登录时就会记录IP到/etc/hosts.deny文件，从而达到自动屏IP的功能。

```sh
# ssh vps
sudo su - 
apt-get update
apt-get install denyhosts

# config
vim /etc/denyhosts.conf
# -rw-r-----  1 root root   23997 Nov 24  2015 denyhosts.conf

# BLOCKPORT = 22 , 默认block所有端口，取消注释指定只 block 22 端口
# PURGE_DENY = 1w
# RESET_ON_SUCCESS = yes
# BLOCK_SERVICE  = sshd

# 应用配置
sudo /etc/init.d/denyhosts restart

# 恢复某个被阻止的IP
sed -i "/$IP/d" /etc/hosts.deny
sed -i "/$IP/d" /var/lib/denyhosts/hosts-valid
sed -i "/$IP/d" /var/lib/denyhosts/users-hosts
sed -i "/$IP/d" /var/lib/denyhosts/hosts
sed -i "/$IP/d" /var/lib/denyhosts/hosts-root
sed -i "/$IP/d" /var/lib/denyhosts/hosts-restricted
iptables -D INPUT -s $IP -j DROP 
# iptables -A INPUT -s $IP -j DROP , ban了某个IP的永久访问

# 还是不放心？还可以更无情的限制IP
# 首先修改/etc/hosts.allow文件，将可访问服务器ssh服务的客户IP加入其中，格式如下
sshd: 192.168.1.0/255.255.255.0
sshd: 202.114.23.45
sshd: 211.67.67.89
# 然后修改/etc/hosts.deny文件，加入禁用其它客户连接ssh服务
sshd: ALL
```

### 开启(安装)防火墙。关闭不必要的端口, 只开放所需端口。
```sh
# 使用netstat查看目前开放的端口及链接情况
# -n: don't resolve names 
# -t: tcp 
# -u: udp 
# -p: display PID/Program name for sockets
# -l: display listening server sockets
# -a: display all sockets

# display (default: connected) 
# sudo lsof -i -P -n | grep ESTABLISHED
netstat -ntup 

# sudo lsof -i -P -n | grep LISTEN
netstat -ntupl  

# sudo lsof -i -P -n 
netstat -ntupa

# 端口扫描工具nmap或者netcat
apt install nmap
# 扫描本地端口
nmap localhost

# 查看端口进程 
# netstat -ntupa | grep ${port}
lsof -i:${port}


# apt update && apt install ufw 
# 启用ufw(简化iptables命令)
ufw status
ufw enable # 开启后默认关了所有端口，但服务程序貌似不限制(例如 ssh, ftp)

# 先查看vps那些端口在LISTEN,然后开放它(例如 22)
netstat -ntupl
ufw allow 22  # 开放22端口
ufw allow 2290:2300/tcp # 端口范围内只允许tcp协议使用
ufw allow 2290:2300/udp # 端口范围内只允许udp协议使用

ufw allow from 192.168.0.104 # 基于IP地址的规则
ufw allow form 192.168.0.0/24 # 也可以使用子网掩码来扩宽范围
ufw allow from 192.168.0.104 proto tcp to any port 22 # 限制来自 192.168.0.104 的 IP 只能使用 tcp 协议和通过 22端口 来访问

# 注意: 开放所有端口，不监听的话就测试不了

# update配置(将开放的端口禁用，例如禁用ftp)
ufw deny ftp
ufw delete allow 22 # 删除某个规则
ufw reset  # 重置所有规则

# 关闭ufw功能
sudo ufw disable
```

todo: ssh config的 pam是扫描作用
virmach do-release-upgrade？