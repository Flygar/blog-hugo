---
title: Blog Backup
date: 2019-08-25T22:38:18+08:00
---
Github pages Back up
操作系统：ubuntu16.04
<!-- more -->
### 安装Hexo
```zsh
# 更新源并升级
apt update && apt upgrade 
# 安装git
apt install git -y
# 安装nvm
wget -qO- https://raw.github.com/creationix/nvm/master/install.sh | sh
# 通过nvm安装Node.js
nvm install stable
# 安装hexo部署到git page的deployer
npm install hexo-deployer-git --save && npm audit fix
# 安装hexo并初始化
npm install -g hexo-cli && hexo init blog && cd blog && npm install
```

### 同步Github
```zsh
# 创建密钥并将id_rsa.pub内容添加至github
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
# 测试
ssh -T git@github.com
# 设置用户信息
git config --global user.name "flygar"
git config --global user.email  "w871546712@gmail.com"
```
Github上新建仓库`flygar.github.io`并添加分支hexo，并置为默认
```zsh
# 初始化本地仓库
git init 
# 添加远程仓库
git remote add origin git@github.com:Flygar/Flygar.github.io.git
# 拉取并且切换到hexo分支 
git fetch && git checkout hexo 
```
修改_config.xml文件  
```zsh
deploy:
  type: git
  repo: git@github.com:Flygar/Flygar.github.io.git
  branch: master
  ```

### 应用
```zsh
hexo new "for test"
# 将改动推送到GitHub（当前分支应为hexo）
git add .
git commit -m 'for test'
git push origin hexo
# 部署发布到master分支
hexo clean && hexo d -g 
```

### 异地管理或恢复
>重装电脑后，或者在其它电脑上想同步并修改博客

```zsh
# 操作系统：ubuntu
# 安装Git
apt install git  
# 使用nvm安装Node.js
wget -qO- https://raw.github.com/creationix/nvm/master/install.sh | sh
# 安装Node.js来使用npm命令
nvm install stable  
# 将生成的id_rsa.pub放到github上去
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
# github账号及用户名 
git config --global user.name "flygar"                
git config --global user.email "w871546712@gmail.com" 
# 将仓库拷贝到本地并命名为blog
git clone git@github.com:Flygar/Flygar.github.io.git blog
# 在clone的目录下执行
npm install hexo-cli -g && npm install && npm install hexo-deployer-git && npm install hexo-filter-optimize --save && npm audit fix
# 查看数据是否同步，利用`git pull`拉取并合并
git remote show origin
#记得不要hexo init
hexo new "Test2"
# 将改动推送到GitHub（当前分支应为hexo）
git add . && git commit -m "Test2" && git push origin hexo 
# 部署发布到master分支  
hexo clean && hexo d -g               
```
### 设置主题
```zsh
cd blog 
# clone主题仓库
git clone https://github.com/theme-next/hexo-theme-next themes/next
# 删除主题下`.git`目录
rm -rf themes/next/.git
# 修改主题为next
vim _config.yml
```

### 关联域名
```zsh
# 添加域名
vim source/CNAME
```

### 管理DNS
|类型|名称|值|TTL|
|:-:|:-:|:-:|:-:|
|A|@|185.199.108.153|600 秒|
|A|@|185.199.109.153|600 秒|
|A|@|185.199.110.153|600 秒|
|A|@|185.199.111.153|600 秒|

