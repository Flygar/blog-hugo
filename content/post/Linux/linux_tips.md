---
title: "linux 命令"
date: 2020-02-01T20:32:34+08:00
comment: false
url: /2020/02/01/linux-tips.html
tags: []
categories: ["Linux"]
---

linux 命令记录
<!--more-->

## 端口传输测试
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

### zsh
```sh
# 安装zsh
apt update && apt upgrade && apt install zsh
# 变更shell
chsh -s $(which zsh)
# 查看当前shell
echo $SHELL

# 安装 oh-my-zsh 
# git
apt install git
# oh-my-zsh
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 安装插件
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/paulirish/git-open.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/git-open

# config, 选择适合自已的插件
vim ~/.zshrc
# HIST_STAMPS="yyyy-mm-dd"
# plugins=(git git-open z history zsh-syntax-highlighting zsh-autosuggestions)
# export LANG=en_US.UTF-8
# export TERM="xterm-256color"

source ~/.zshrc
```

## 命令大全
```sh
# 测速 
# macOS
brew install speedtest 
# linux
bash <(curl -Lso- https://git.io/superspeed) # github: https://github.com/ernisn/superspeed
# 常用 server 列表
# 26352) China Telecom JiangSu 5G (Nanjing, China) 
# 27249) China Mobile jiangsu 5G (Nanjing, China) [
# 17320) China Mobile JiangSu 5G (ZhenJiang, China) [
# 21005) China Unicom (Shanghai, China) 
# 13704) China Unicom (Nanjing, China) 
# 4647) China Mobile Group Zhejiang Co.,Ltd (Hangzhou, China) 
# 7509) China Telecom ZheJiang Branch (Hangzhou, China)

# docker
# 官方docker一键部署脚本
wget -qO- get.docker.com | bash # curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
# 设置开机自启
systemctl list-unit-files --type=service | grep docker
systemctl enable docker
service docker status

# dig
dig WWW.EXAMPLE.COM +nostats +nocomments +nocmd
dig EXAMPLE.COM +noall +answer
```
