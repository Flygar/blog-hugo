---
title: Map and Reduce
---
Python records
<!-- more -->
### Map
`map`的用法：
```py
map(function, sequence)
```
>对 sequence 中的 item 依次执行 function(item)，并将结果组成一个 `List` 返回

```py
>>> list(map(lambda x:x**2,[1,3,2,4]))
[1, 9, 4, 16]
>>> list(map(str,[1,3,2,4]))
['1', '3', '2', '4']
>>> list(map(int,['1', '3', '2', '4']))
[1, 3, 2, 4]
```
```py
def double(x):
    return 2 * x

def triple(x):
    return 3 * x

def square(x):
    return x * x

# 列表元素是函数对象
funcs = [double, triple, square]  

# 相当于 [double(4), triple(4), square(4)]
value = list(map(lambda f: f(4), funcs))

print(value)
# output
[8, 12, 16]
```

### Reduce
`reduce`的用法：
```py
reduce(function, sequence[item1,item2,item3...], initial)
>>> sum = lambda x, y : x + y
>>> sum(4,5)
9
```
>先将 sequence 的前两个 item 传给 function，即 function(item1, item2)，函数的返回值和 sequence 的下一个 item 再传给 function，即 function(function(item1, item2), item3)，如此迭代，直到 sequence 没有元素，如果有 initial，则作为初始值调用。

```py
>>> from functools import reduce
>>> reduce(lambda x, y: x * y, [1, 2, 3, 4])  # 相当于 ((1 * 2) * 3) * 4
24
>>> reduce(lambda x, y: x * y, [1, 2, 3, 4], 5)  # ((((5 * 1) * 2) * 3)) * 4
120
>>> reduce(lambda x, y: x / y, [2, 3, 4], 72)  # (((72 / 2) / 3)) / 4
3.0
>>> reduce(lambda x, y: x + y, [1, 2, 3, 4], 5)  # ((((5 + 1) + 2) + 3)) + 4
15
>>> reduce(lambda x, y: x - y, [8, 5, 1], 20)  # ((20 - 8) - 5) - 1
6
```
### Exercise
1. 求`l=[5,8,1,10]`列表元素中的最大值，最小值，累加，累积，累除  
2. 判断元素`'7'`是否为列表`l`中的最大值，并输出最大值。
```py
>>> from functools import reduce
# 两两比较，取最大值
>>> f = lambda a, b: a if (a > b) else b  
>>> reduce(f, l, 7)
10
>>> reduce(f, [5, 4, 1, 6],7)
7
```
3. 元素`800`除以`l`中每个元素后的值的和
```py
>>> reduce(lambda x, y: x + y, map(lambda x: 800 / x, l))
1140.0
```
4. 将列表`'l'`转换为整数`58110`
```py
>>> int(reduce(lambda x, y: x + y, map(str, l)))
58110
```
5. 利用map()函数，把用户输入的不规范的英文名字，变为首字母大写，其他小写的规范名字。输入：`['adam', 'LISA', 'barT']`，输出：`['Adam', 'Lisa', 'Bart']`
```py
>>> l2 = ['adam', 'LISA', 'barT']
>>> list(map(lambda x: x.capitalize(), l2))
['Adam', 'Lisa', 'Bart']
```
6. 把字符串`'123.456'`转换成浮点数`123.456`
```py
>>> float('123.456')
123.456
```

{% note danger  %} **参考**: [Python Course](https://www.python-course.eu/python3_lambda.php) {% endnote %}

