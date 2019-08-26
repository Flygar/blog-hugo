---
title: "Go Magic"
date: 2019-08-26T19:44:53+08:00
draft: true
---
Go Tips
<!--more-->
```go
a := "hello"
b := 123
//%后的副词[n]告诉Print函数使用第n个操作数
fmt.Printf("%[2]d, %[1]s, %[1]T, %[2]T, %[1]q", a, b)
```
