---
title: Docker
draft: false
date: 2019-08-25T22:38:18+08:00
# toc: true
---
>镜像仓库-镜像库-镜像-容器实例
>容器(container)实例的运行依赖image文件
>一个image文件可以生成多个容器(container)实例
>命令中的container可以去掉
<!--more-->

### Docker 信息查看
```zsh
# 查看docker信息
docker version
# 或者
docker info
# 查看docker状态
# service 命令的用法
sudo service docker start
# systemctl 命令的用法
sudo systemctl start docker
```
### Docker Image
```zsh
# 列出本机的所有 image 文件。
docker images
# 或者
docker image ls
# 删除 image 文件
docker image rm <imageID>
# 或者
docker rmi <imagename>
# 从机器中删除所有镜像
docker rmi $(docker images -q)
```
### Docker 实例
```zsh
# 从仓库拉取image文件
docker image pull library/hello-world
# 或者下面的命令拉取(Docker 官方提供的 image 文件，都放在library组里面，所以它的是默认组，可以省略)
docker image pull hello-world
# 运行image，生成一个正在运行的容器实例(新建容器)；如果发现本地没有指定的 image 文件，就会从仓库自动抓取;每执行一次就会产生一个Container实例
docker [container] run hello-world
# 找出上面<hello-world>的<containerID>以多次使用
docker [container] start <containerID>
# 运行image生成容器(container)实例(提供服务的imasge，会一直运行)
docker [container] run -it ubuntu   /bin/bash
# 或者以下面这种方式运行image生成容器(container)实例; --rm:在容器终止运行后自动删除容器文件; -p 8000:3000:容器的 3000 端口映射到本机的 8000 端口; -it:这是两个参数，一个是 -i：交互式操作，一个是 -t 终端,容器的 Shell 映射到当前的 Shell，然后你在本机窗口输入的命令，就会传入容器; koa-demo:image 文件的名字; /bin/bash:容器启动以后，内部第一个执行的命令。这里是启动 Bash，保证用户可以使用 Shell;
docker [container] run --rm -p 8000:3000 -it koa-demo /bin/bash
# 或者-d参数后台运行
docker run -d -p 4000:80 friendlyhello
# 对于一直运行的容器，下面的命令手动终止
docker [container] kill <containerID>
# 查看容器内部的标准输出。-f:让 docker logs 像使用 tail -f 一样来输出容器内部的标准输出。
docker logs -f <containerID>
```

### Docker 容器文件
```zsh
# 查看帮助
docker [container] --help
# 列出本机正在运行的容器
docker [container] ls
# 或者
docker ps [-a]
# 列出本机所有容器，包括终止运行的容器
docker [container] ls --all
# 或者
docker ps --all
# 运行容器
docker [container] start <containerID>
# 进入容器
docker [container] exec -it <containerID> /bin/bash
# 从正在运行的 Docker 容器里面，将文件拷贝到本机的当前目录
docker [container] cp <containID>:[/path/to/file] .
# 自行进行收尾清理工作再终止
docker [container] stop <containerID>
# 或者：对于一直运行的容器，下面的命令手动强行终止
docker [container] kill <containID>
# 终止容器仍会占用硬盘空间，使用下面命令删除
docker [container] rm <containerID>
# 从机器中删除所有容器实例
docker [container] rm $(docker ps -a -q)
# 查看 docker 容器的输出，即容器里面 Shell 的标准输出。如果docker run命令运行容器的时候，没有使用-it参数，就要用这个命令查看输出
docker [container] logs <containerID>
```

### 共享镜像
```zsh
# 登录
docker login
# 标记 <image> 以上传到镜像库
docker tag <image> <username>/<repository>:<tag>
# 将已标记的镜像上传到镜像库
docker push <username>/<repository>:<tag>
# 从远程镜像仓库中拉取并运行镜像
docker run -p 4000:80 username/repository:tag

```