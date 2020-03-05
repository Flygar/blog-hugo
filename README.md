## 
妈的，半年不写。居然忘了当初写blog的正确姿势了，特此记录下  
真是业精于勤荒于嬉，共勉

blog-hugo这个仓库
1. 存放源文件(blog的md文件）， 实现新环境(例如:重装系统后)快速写blog。 操作如下

github.io仓库
1. 存放最终发布的网站内容(就是blog-hugo它生成的放在了public下的东西)

deploy.sh 脚本实现自动部署和发布
过于简单，不做赘述，除非我痴呆了

## 使用姿势

```sh

```
git init
git remote add origin git@github.com:Flygar/blog-hugo.git
git branch --set-upstream-to=origin/master master