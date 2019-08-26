---
title: Git
date: 2019-08-25T22:38:18+08:00
---

>add：追踪并添加到暂存区  
>commit：提交到git仓库(用来保存项目的元数据和对象数据库)  
---
### 配置信息
```zsh
# 查看用户信息
cat ~/.gitconfig
# 查看配置
git config --list
```
---
<!-- more -->
### 获取git仓库
```zsh
# 获取远程git仓库并在本地将仓库命名为blog
git clone git@github.com:Flygar/Flygar.github.io.git blog 
```
---
### 文件比较
```zsh
# 查看工作目录与暂存区的文件差异(尚未暂存的文件更新内容)
git diff
# 查看暂存区文件更新的内容与上次提交的内容差异
git diff --staged
# 跳过使用暂存区域，自动把所有已经跟踪过(add提交过)的文件暂存起来一并提交，从而跳过 git add 步骤
git commit -a -m '...'
```
---
### 删除
```zsh
# 删除git仓库及本地文件
git rm file.log
# 从Git仓库中删除,保留本地文件(常用于将已跟踪文件添加至.gitingore)
git rm --cached file.log
```
---
### 撤销
```zsh
git commit -m 'initial commit'
git add forgotten_file
git commit --amend # 将forgotten_file提交信息为"initial commit"
git reset HEAD file.md # 取消暂存
git checkout -- <file> # 撤销修改
```
---
### 提交历史
```zsh
git log 
git log -p -2 # 显示最近2次提交的内容差异
git log --stat # 简略统计
git log --pretty=oneline # 格式化放在一行显示
git log -1 HEAD # 查看最后一次提交
git log --oneline --decorate --graph
```
### 标签
```zsh
# 列出标签
git tag 
# 打标签
git tag -a v1.0 -m 'my version 1.0'
git show v1.0 
# 后期打标签
git tag -a v1.2 9fceb02 
# 推送标签
git push origin --tags 
```
---
### 远程仓库
```zsh
git remote -v # 查看远程仓库简写及对应的URL
git remote add pb https://github.com/paulboone/ticgit # 添加远程仓库并设置简写为pb，可以使用pb来代替整个URL
git fetch pb # 更新本地数据：拉取pb中有但你本地没有的数据，可以将它合并到自己的某个分支(并不会自动合并或修改你当前的工作)
git pull # 自动的抓取然后合并远程分支到当前分支.默认情况下，git clone 命令会自动设置本地 master 分支跟踪克隆的远程仓库的 master 分支（或不管是什么名字的默认分支）。 运行 git pull 通常会从最初克隆的服务器上抓取数据并自动尝试合并到当前所在的分支。
git remote show origin  # 查看远程仓库详细信息，远程仓库的 URL 与跟踪分支的信息，执行 git pull 时哪些分支会自动合并
git remote rename pb paul # 将 远程仓库pb重命名为paul
# 移除远程仓库 paul
git remote rm paul
```
---
### 分支
```zsh
# 创建
git branch testing 
# 切换
git checkout testing 
# 获取当前分支
git branch 
# 删除
git branch -d testing 
# 创建并切换分支
git checkout -b iss53 
# 将当前分支合并到test2
git merge test2 
# 查看每个分支的最后一次提交
git branch -v 
# 更新本地数据
git fetch origin 
# 更新本地数据：拉取pb中有但你本地没有的数据，可以将它合并到自己的某个分支
git fetch pb  
# 查看合并的分支
git branch --merged
# 查看未合并的分支
git branch --no-merged
```
---
### 变基
```zsh
# 将提交到当前分支上的所有修改移至master分支
git rebase master 
# 将server变基至master
git rebase master server 
```

