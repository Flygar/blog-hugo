## 劝学
半年不写, 居然忘了当初写blog的姿势了, 特此记录下  
真是业精于勤荒于嬉，共勉

## 使用姿势
```sh
# clone repo
git clone https://github.com/Flygar/blog-hugo.git
cd blog-hugo

# init and update submodule
git clone https://github.com/flysnow-org/maupassant-hugo.git themes/maupassant
git clone https://github.com/Flygar/flygar.github.io.git public


# Create a new content file and automatically set the date and title.
hugo new post/filename.md

# After edit post/filename.md
# Deploy site
# 执行脚本前还可以 rm -rf public/* , 但不要删除public目录。 然后去 xxxxx.github.io仓库的setting，添加 Custom domain(CNAME)(如果你有域名的话)。
./deploy.sh
```

## 说明
[blog-hugo](https://github.com/Flygar/blog-hugo)
- 存放源文件(blog的md文件）
- 实现新环境(例如:重装系统后)快速写blog。

submodule [public](https://github.com/Flygar/flygar.github.io)
- 生成的是最终需要发布的网站内容: https://github.com/Flygar/flygar.github.io 

submodule [themes/maupassant](https://github.com/flysnow-org/maupassant-hugo)
- 使用最新的maupassant主题

deploy.sh
- 实现自动部署与发布

