---
title: "linux tips"
date: 2020-02-01T20:32:34+08:00
# comment: false
url: /2020/02/01/linux-tips.html
tags: [ "Ubuntu", "Linux"]
categories: ["Linux"]
---

## tools
```sh
# 测速 
brew install speedtest 
bash <(curl -Lso- https://git.io/superspeed) # github: https://github.com/ernisn/superspeed

# 官方docker一键部署脚本
wget -qO- get.docker.com | bash
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
systemctl list-unit-files --type=service | grep docker
systemctl enable docker
service docker status

# 


```
## linux commands

### zsh
```sh
# 安装zsh
apt update && apt upgrade && apt install zsh
# 变更shell
chsh -s $(which zsh)
# 查看当前shell
echo $SHELL

# git
apt install git
# oh-my-zsh
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# 安装插件
apt install zsh-syntax-highlighting
apt install zsh-autosuggestions

# config, 选择适合自已的插件
vim ~/.zshrc
# HIST_STAMPS="yyyy-mm-dd"
# plugins=(git z)
# export LANG=en_US.UTF-8
# source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
```
### 端口传输测试
Netcat 号称 TCP/IP 的瑞士军刀
```sh
# -v: verbose
# -n: Suppress name/port resolutions 不解析域名，避免解析域名浪费时间
# -z: Zero-I/O mode [used for scanning] 不发送数据
# -w secs Timeout for connects and final net reads 设置超时时间
# -l: Listen mode, for inbound connects 开启监听
# -k: Keep inbound sockets open for multiple connects 监听不断，持续工作
# -u: UDP mode

# vps端开启监听(默认tcp, -u 指定UDP mode) 8080
nc -l -k 8080

# clinet连接测试，利用netcat代替telnet探测端口
nc -vzw5 104.168.94.186 8080
# 两次 -v 是让它报告更详细的内容(结束时会统计接收和发送多少字节), 设置超时时间3s, 探测端口范围 8080-8083
nc -v -v -w3 -z 104.168.94.186 8080-8083

```

## nmap
## netstat
## dig
```sh
dig WWW.EXAMPLE.COM +nostats +nocomments +nocmd
dig EXAMPLE.COM +noall +answer
```



26352) China Telecom JiangSu 5G (Nanjing, China) [76.73 km]
27249) China Mobile jiangsu 5G (Nanjing, China) [74.00 km]
17320) China Mobile JiangSu 5G (ZhenJiang, China) [26.16 km]

21005) China Unicom (Shanghai, China) [202.50 km]
13704) China Unicom (Nanjing, China) [74.00 km]

4647) China Mobile Group Zhejiang Co.,Ltd (Hangzhou, China) [202.35 km]
7509) China Telecom ZheJiang Branch (Hangzhou, China) [202.35 km]
