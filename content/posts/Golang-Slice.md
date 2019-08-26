---
title: Golang Slice
---
Golang入门计划
<!-- more -->
```go
//slice「easySlice1」的slice. [1:3]左闭右开. cap 为[1:]. len 为2. 引用传递
easySlice1 := [][]int{{1, 2}, {3, 4}, {5, 6, 7, 8}, {9, 10}, {99, 100}}[1:3]
fmt.Println(easySlice1)
fmt.Println(cap(easySlice1))
//change easySlice1
easySlice1[0][1] = int(44)
easySlice1[1] = []int{1, 2, 3, 4}
fmt.Println(easySlice1)

//将数组转为切片
//报错：slice of unaddressable value; 需要先赋值给一个变量
easyArray = [5][5]int{{1, 2}, {3, 4, 5, 6, 7}}[:]
//正确操作
easyArray := [5][5]int{{1, 2}, {3, 4, 5, 6, 7}}
easySlice2 := easyArray[:]
fmt.Println(easySlice2)

//slice and map
mapResults := make(map[int]string)
// var arrResults [][]string
arrResults := make([][]string, 0)
const LOOPCOUNT = 3
for i := 0; i < LOOPCOUNT; i++ {
	valueStr := fmt.Sprintf("this is %d\n", i)
	mapResults[i] = valueStr
	tmpArr := make([]string, 0)
	for j := 0; j < 5; j++ {
		tmpArr = append(tmpArr, strconv.Itoa(j))
	}
	arrResults = append(arrResults, tmpArr)
}
//test
sliceB := [][]string{{"test11", "test12", "test13"}, {"test21"}}
// add slice
arrResults = append(arrResults, sliceB...)
arrResults = append(arrResults, []string{"hello", "world"})
// arrResults = append(arrResults[:1], sliceB...)
arrResults = append(arrResults[:1], append([][]string{{"hello", "world"}}, arrResults[1:]...)...)
fmt.Println(mapResults)
fmt.Println(arrResults)
```

**Slice的坑**
>Slice作为引用类型，操作会直接影响到原slice

```go
// slice是引用类型，操作可能会影响原slice
s := []int{1, 2, 3, 4, 5, 6}
a := s[1:3]                      //  左闭右开 a返回[2 3]
fmt.Println("s1: ", s)           // [1 2 3 4 5 6]
fmt.Println("a's len: ", len(a)) // 长度 2
fmt.Println("a's cap: ", cap(a)) // 容量 5
fmt.Println("a: ", a[:cap(a)])   // 输出容量，返回[2 3 4 5 6]

a[1] = 33                       //尝试改变a中的元素值，容量cap中的值不可修改
fmt.Println("a[cap]: ", a[2:5]) //查看容量cap目前存的什么值 [4 5 6]
fmt.Println("ss: ", s)          // 可以看到原s也做出了改变 [1 2 33 4 5 6] , 引用类型

fmt.Println("----------------")
b := append(a, s[1:3]...)      // 返回[2 33 2 33]
fmt.Println("a: ", a[:cap(a)]) // 输出容量，返回[2 33 2 33 6]
fmt.Println("b: ", b)          // 返回 [2 33 2 33]
fmt.Println("s2: ", s)         // slice s 变成 [1 2 33 2 33 6]

c := append(s[1:3], 0)             // 返回 [1 2 0]
fmt.Println("c-cap: ", c[:cap(c)]) // 查看容量cap中目前存的什么值
fmt.Println("s3: ", s)             // 返回 [1 2 33 0 33 6]

```
