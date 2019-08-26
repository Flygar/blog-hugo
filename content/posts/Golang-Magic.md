---
title: "Golang Magic"
date: 2018-08-12 20:14:03
tags: [ "Go" ]
topics: ["Go" ]
---

诡异的操作

<!-- more -->
```go
a:="hello"
b:=123
//%后的副词[n]告诉Print函数使用第n个操作数
fmt.Printf("%[2]d, %[1]s, %[1]T, %[2]T, %[1]q",a,b)
```
