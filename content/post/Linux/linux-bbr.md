---
title: "Ubuntu 16.04 下启用 TCP BBR 拥塞控制算法"
date: 2020-01-05T20:32:34+08:00
# comment: false
url: /2020/01/05/linux-bbr.html
tags: [ "Ubuntu", "Linux", "BBR"]
categories: ["Linux"]
---
TCP BBR（Bottleneck Bandwidth and Round-trip propagation time）是由Google设计，于2016年发布的拥塞算法。以往大部分拥塞算法是基于丢包来作为降低传输速率的信号，而BBR则基于模型主动探测。该算法使用网络最近出站数据分组当时的最大带宽和往返时间来创建网络的显式模型。数据包传输的每个累积或选择性确认用于生成记录在数据包传输过程和确认返回期间的时间内所传送数据量的采样率。该算法认为随着网络接口控制器逐渐进入千兆速度时，分组丢失不应该被认为是识别拥塞的主要决定因素，所以基于模型的拥塞控制算法能有更高的吞吐量和更低的延迟，可以用BBR来替代其他流行的拥塞算法，例如CUBIC。Google在YouTube上应用该算法，将全球平均的YouTube网络吞吐量提高了4%，在一些国家超过了14%。
<!--more-->

BBR 只能配合 Linux Kernel 4.10 以上内核才能使用
## 为 Ubuntu 16.04 安装 4.10 + 新内核
推荐使用 HWE 版本的内核，它就在官方源里。  
HWE，即: HareWare Enablement，是专门为在老的系统上支持新的硬件而推出的内核。  
不推荐手动下载安装的新内核，无法保证后续能得到及时的安全更新。

```sh
# 像安装其他软件包一样在 Ubuntu 16.04 里安装HWE
apt install --install-recommends linux-generic-hwe-16.04
# 删除旧内核（可选）
sudo apt autoremove

# sudo reboot 重启vps应用内核更新
uname -r
```

## 启用bbr
对于 Linux Kernel 4.10 以上内核 直接启用
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
