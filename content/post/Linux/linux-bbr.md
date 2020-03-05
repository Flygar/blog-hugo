---
title: "Ubuntu 16.04 下启用 TCP BBR 拥塞控制算法"
date: 2020-01-05T20:32:34+08:00
commentDisabled: true
url: /2020/01/05/linux-bbr.html
tags: [ "Ubuntu", "Linux", "BBR"]
categories: ["Linux"]
---

### 为 Ubuntu 16.04 安装 4.10 + 新内核
BBR 只能配合 Linux Kernel 4.10 以上内核才能使用
推荐使用 HWE 版本的内核，它就在官方源里。HWE，即: HareWare Enablement，是专门为在老的系统上支持新的硬件而推出的内核。  

不推荐手动下载安装的新内核，无法保证后续能得到及时的安全更新。

```sh
# 像安装其他软件包一样在 Ubuntu 16.04 里安装HWE
sudo apt-get install linux-generic-hwe-16.04

# sudo reboot 重启vps应用内核更新
uname -r
```
### 启用bbr
```sh
# 装载bbr模块
modprobe tcp_bbr
echo "tcp_bbr" | tee --append /etc/modules-load.d/modules.conf

# 查看当前 Linux 内核可以使用的 TCP 拥堵控制算法 | 验证是否装载成功
sysctl net.ipv4.tcp_available_congestion_control

# 正式启用bbr
echo "net.core.default_qdisc=fq" | tee --append /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" | tee --append /etc/sysctl.conf
sysctl -p

# 确认当前使用的控制算法为bbr
sysctl net.ipv4.tcp_congestion_control
```
