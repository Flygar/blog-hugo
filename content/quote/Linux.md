---
title: Linux
date: 2019-08-25T22:38:18+08:00
---
<!-- ### Test for asciicast
**need break GFW**
<script src="https://asciinema.org/a/192824.js" id="asciicast-192824" async></script> -->
### Linux 别名快捷登录
`vim /etc/ssh/ssh_config`添加如下配置
```zsh
Host dv
	HostName example.com
	User domainuser
```
终端里执行`ssh dv`,相当于`ssh domainuser@example.com`

<!-- more  -->

### Linux history
```zsh
# ~/.bashrc
# HISTSIZE 定义了 history 命令输出的记录数.
HISTSIZE=10000
# HISTFILESIZE 定义了在 ~/.bash_history 中保存命令的记录总数.
HISTFILESIZE=10000
# 记录空格开头的命，并且去除重复行
HISTCONTROL=ignoredups
# 由于bash的history文件默认是覆盖，如果存在多个终端，最后退出的会覆盖以前历史记录，改为追加形式
shopt -s histappend
# 当前终端的命令实时追加至 ~/.bash_history
PROMPT_COMMAND="history -a"
# 记录时间
HISTTIMEFORMAT='%F %T '

# 执行上一条命令
!!
# 执行上一条命令
!-2
# 找出最近一次以go开头的命令,并执行
!<go>
# 使用history的编号重复执行先前的命令
!<ID>
# 将第<ID>条命令中的第一个<string1>替换成<string2>，并执行
!<ID>:s/<string1>/<string2>/
# 全部替换
!<ID>:gs/<string1>/<string2>/
# 利用 ctrl + r 进行模糊搜索使用过的命令，优先显示最近的结果,再次 ctrl + r 向<ID>小的方向搜索(向后搜索)
ctrl+r
```
### Linux screen
```zsh
# screen待补充
# 终端1新建服务
screen -S test
# 终端2同步终端1
screen -x test
```
### Linux 默认本地化设置
```zsh
echo "export LC_ALL=C">>~/.bashrc && source ~/.bashrc
```

### Linux 免密登陆
```zsh
# 如果没有共钥，则生成. 加密方式rsa，字节4096
ssh-keygen -t rsa -b 4096
# 方式1
ssh-copy-id user@host
# 方式2
ssh user@host 'mkdir -p .ssh && cat >> .ssh/authorized_keys' < ~/.ssh/id_rsa.pub
```
### Linux systemctl
```zsh
# 重启系统
sudo systemctl reboot
# 显示当前主机的信息
hostnamectl
# 设置主机名。
sudo hostnamectl set-hostname 「hostname」
# 查看本地化设置
localectl
# 立即启动一个服务
sudo systemctl start docker
# 立即停止一个服务
sudo systemctl stop docker
# 重启一个服务
sudo systemctl restart docker
# 杀死一个服务的所有子进程
sudo systemctl kill docker
# 重新加载一个服务的配置文件
「sudo systemctl reload docker」
「/etc/init.d/ssh restart」
「sudo service ssh restart」
「sudo systemctl reload ssh」
# 重载所有修改过的配置文件
sudo systemctl daemon-reload
```
### Linux visudo
```zsh
# 切换默认编辑器
sudo update-alternatives --config editor
# 设置visudo默认编辑器
sudo select-editor
# vim /etc/sudoers
visudo
# root    ALL=(ALL:ALL) ALL
# flygar  ALL=(ALL) NOPASSWD: ALL
```
### Linux 设置指令别名
```zsh
vim ~/.bash_aliases
#---
alias pyspark='/opt/modules/spark-2.2.1-bin-without-hadoop/bin/pyspark'
#---
source ~/.bash_aliases
```

### Linux 快捷键
```zsh
# shell交互界面
ctrl+& # 撤销
ctrl+r # 进入历史查找命令记录， 输入关键字。 多次按返回下一个匹配项

ctrl+w # 删除前一个单词
ctrl+y # 将删除的单词粘贴出来

ctrl+u # 删除至行首
ctrl+k # 删除至行尾

ctrl+h # 删除光标前一个字符
ctrl+d # 删除光标后一个字符

# vim界面保留原始缩进
:set paste # 拷贝前「命令模式」下输入「set paste」取消自动缩进
:set nopaste # 关闭取消自动缩进

# 普通模式
0 # 本行开头
$ # 本行末尾
^ # 本行第一个非空字符处
w # 向后移动一个word
5w # 向后移动5个word
W # 向后移动至空格处
b # 向前移动一个word
5b # 向前移动5个word
B # 向前移动至空格处
# 插入文本
R # 覆写模式
A # 在行末插入文本
a # 在光标后插入文本
# 删除文本
x # 删除光标处字符
3dw # 向后删除3个词
2db # 向前删除2个单词
5s # 删除并插入
d0 # 删除至行首
d$ # 删除至行尾
d^ # 删除至行首空格
d) # 删除至句末
dgg # 删除至文件开头
dG # 删除至文件末尾
3dd # 删除3行 
# 复制
3yy # 复制光标下3行
p # 光标下粘贴
P # 光标上粘贴 
# 变量搜索
shift+\# # 或者 :?<variable>
shift+* # 或者 :/<variable>
u # 撤销
ctrl+r # 反向撤销
v # 逐字可视模式
V # 逐行可视模式

# 命令模式
# 设置快捷键或者添加到`/etc/vim/vimrc`
:ab rst result
:ab info my name is flygar
# 水平（垂直）切分来编辑新的文件。ctrl+w切换页面
:split test2.go
:vsplit test3.go
# 强制保存
:w !sudo tee %
# 用new_name作为文件名保存文件
:w new_name
# 进入交互shell，exit退出返回vim界面
:sh
# 跳转到第5行
:5


# 插入模式
# 关键字补全
ctrl+n
ctrl+p
```
### Linux sshd_config
```zsh
sudo vim /etc/ssh/sshd_config
# 修改端口号 「ssh -p22960 root@ip」
Port 22960
# 是否允许作为root用户登录(yes/no)
PermitRootLogin yes 
# 是否需要密码认证(yes/no)
PasswordAuthentication yes 
# 
UseLogin yes

# 重启服务 sudo service ssh restart
sudo systemctl reload sshd
```

### Linux 
```zsh
# 查看文件信息
stat filetest
# 查看文件描述
file filetest
# 对比文件
diff filetest1 filetest2
# 查看未释放的文件句柄
lsof | grep deleted
```