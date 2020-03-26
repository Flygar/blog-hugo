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
# 本地验证
make test

# 执行脚本前还可以先执行 make clear 来清空 public 目录, 会自动生成CNAME文件
# make clear

# Deploy site, 等同于: make build && make public && make hugo
make all

# 调试
# clear: make -n name="example.com" clear -f Makefile
# build: make -n build -f Makefile
# public: make -n msg="commit message" public -f Makefile
# hugo: make -n msg="commit message" hugo -f Makefile
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
- ~~实现自动部署与发布~~ 使用Makefile代替

DNS设置
- example.com 称为裸域名，www.example.com, blog.example.com...为它的二级域名
注意: 不要在您的DNS设置中使用实际域名，可以使用@表示域名
- 记录类型A: 将域名指向IP
- 记录类型CANME: 别名记录，也被称为规范名字。一般用来把域名解析到别的域名上，当需要将域名指向另一个域名，再由另一个域名提供 ip 地址，就需要添加 CNAME 记录。