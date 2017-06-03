---
comments: true
date: 2017-05-23
tags:
- Golang
title: '"Go" to Study: fmt'
categories:
- 读书笔记
toc: true
---


**fmt**包含有格式化I/O函数，类似于C语言的`printf`和`scanf`。
格式字符串的规则来源于C但更简单一些。

## print.go

### func Errorf
```go
    func Errorf(format string, a ...interface{}) error
```
`Errorf`根据格式说明符格式，并将字符串返回为满足错误的值。

### func Print
```go
    func Print(a ...interface{}) (n int, err error)
``` 
`Print` 使用默认的格式将参数转换为字符串并写入到标准输出中。如果参数是非字符串时会在中间添加空格。它返回写入的字节数和遇到的任何写入错误。

### func Println
```go
    func Println(a ...interface{}) (n int, err error)
```
`Println`格式使用其操作数的默认格式并写入标准输出。 总是在操作数之间添加空格，并附加换行符。 它返回写入的字节数和遇到的任何写入错误。

### func Printlf
```go
    func Printf(format string, a ...interface{}) (n int, err error)
```
`Printf`根据格式说明符格式化并写入标准输出，它返回写入的字节数和遇到的任何写入错误。

### func Fprint | Fprintf | Fprintln
```go
    func Fprint(w io.Writer, a ...interface{}) (n int, err error)
    func Fprintln(w io.Writer, a ...interface{}) (n int, err error)
    func Fprintf(w io.Writer, format string, a ...interface{}) (n int, err error)
```
功能与`Print` 、 `Printf` 、`Println`类似，只不过将转换结果写入到 `w` 中。

### func Sprint, Sprintf, Sprintln
```go
    func Sprint(a ...interface{}) string
    func Sprintln(a ...interface{}) string
    func Sprintf(format string, a ...interface{}) string
```
同上面函数，函数结果返回字符串。

### 示例
```go
func main() {
	fmt.Print("a", "b", 11, 22, "\n")
	// ab11 22
	fmt.Printf("aaa %d %d %d aaa \n", 1, 2, 3)
	// aaa 1 2 3 aaa
	fmt.Println("a", "b", 1, 2, 3, "c", "d")
	//a b 1 2 3 c d
    fmt.Print(fmt.Errorf("%08b\n", 32)) 
    // 00100000
	fmt.Print("\n")
	fmt.Fprint(os.Stdout, "Hello", "\n")
	fmt.Fprintf(os.Stdout, "%08b\n", 32)
	fmt.Fprintln(os.Stdout, 32)
	//Hello
	//00100000
	//32
	fmt.Print("\n")
	fmt.Fprint(os.Stdout, "A")
	fmt.Print("B")
	fmt.Print(fmt.Sprint("C"))
	// ABC
}
```

### type Formatter

`Formatter`实现对象的自定义格式输出。格式的实现可能会调`用Sprint（f）`或`Fprint（f）`等来生成其输出。

```go
type Formatter interface {
    Format(f State, c rune)
}
```
`State`用来获取占位符的状态。
```go
type State interface {
        // Write 是调用发送格式化的输出打印的函数
        Write(b []byte) (n int, err error)
        // Width 返回 width 选项的值，以及是否已设置。
        Width() (wid int, ok bool)
        // Precision 返回精度选项的值以及是否已设置。
        Precision() (prec int, ok bool)

        // Flag 是否已经设置了标志c.
        Flag(c int) bool
}
```

**代码示例：[github](https://github.com/mjyi/go-package-fmt/blob/master/goFormatter.go)**

## sacn.go

### func Scan | Scanln | Scanf 
```go
    func Scan(a ...interface{}) (n int, err error)
    func Scanln(a ...interface{}) (n int, err error)
    func Scanf(format string, a ...interface{}) (n int, err error)
```

- Scan 从标准输入中读取数据，并将数据用空白分割并解析后存入 a 提供的变量中（换行符会被当作空白处理），变量必须以指针传入。当读到 EOF 或所有变量都填写完毕则停止扫描。返回成功解析的参数数量。

- Scanln 和 Scan 类似，遇到换行符就停止扫描。

- Scanf 从标准输入中读取数据，并根据格式字符串 format 对数据进行解析，将解析结果存入参数 a 所提供的变量中，变量必须以指针传入。输入端的换行符必须和 format 中的换行符相对应（如果格式字符串中有换行符，则输入端必须输入相应的换行符）。占位符 %c 总是匹配下一个字符，包括空白，比如空格符、制表符、换行符。返回成功解析的参数数量。

### func Fscan | Fscanf | Fscanln
```go
    func Fscan(r io.Reader, a ...interface{}) (n int, err error)
    func Fscanln(r io.Reader, a ...interface{}) (n int, err error)
    func Fscanf(r io.Reader, format string, a ...interface{}) (n int, err error)
```
作用同 `Scan`,`Scanf`, `Scanln`.但是是从 `r` 中读取数据。


### func Sscan | Sscanln | Sscanf 
```go
    func Sscan(str string, a ...interface{}) (n int, err error)
    func Sscanln(str string, a ...interface{}) (n int, err error)
    func Sscanf(str string, format string, a ...interface{}) (n int, err error)
```
作用同 `Scan`,`Scanf`, `Scanln`。 但是是从 `str` 中读取数据


### 示例

```go
// 对于 Scan 而言，回车视为空白
func main() {
	a, b, c := "", 0, false
	fmt.Scan(&a, &b, &c)
	fmt.Println(a, b, c)
	// 在终端执行后，输入 abc 1 回车 true 回车
	// 结果 abc 1 true
}

// 对于 Scanln 而言，回车结束扫描
func main() {
	a, b, c := "", 0, false
	fmt.Scanln(&a, &b, &c)
	fmt.Println(a, b, c)
	// 在终端执行后，输入 abc 1 true 回车
	// 结果 abc 1 true
}

// 格式字符串可以指定宽度
func main() {
	a, b, c := "", 0, false
	fmt.Scanf("%4s%d%t", &a, &b, &c)
	fmt.Println(a, b, c)
	// 在终端执行后，输入 1234567true 回车
	// 结果 1234 567 true
}
```

### Scanner 

`canner` 由自定义类型实现，用于实现该类型的自定义扫描过程。当扫描器需要解析该类型的数据时，会调用其 `Scan` 方法
```go
type Scanner interface {
	// state 用于获取占位符中的宽度信息，也用于从扫描器中读取数据进行解析。
	// verb 是占位符中的动词
    Scan(state ScanState, verb rune) error
}
```

由扫描器（Scan 之类的函数）实现，用于给自定义扫描过程提供数据和信息。
```go
type ScanState interface {
	// ReadRune 从扫描器中读取一个字符，如果用在 Scanln 类的扫描器中，
	// 则该方法会在读到第一个换行符之后或读到指定宽度之后返回 EOF。
	// 返回“读取的字符”和“字符编码所占用的字节数”
	ReadRune() (r rune, size int, err error)
	// UnreadRune 撤消最后一次的 ReadRune 操作，
	// 使下次的 ReadRune 操作得到与前一次 ReadRune 相同的结果。
	UnreadRune() error
	// SkipSpace 为 Scan 方法提供跳过开头空白的能力。
	// 根据扫描器的不同（Scan 或 Scanln）决定是否跳过换行符。
	SkipSpace()
	// Token 用于从扫描器中读取符合要求的字符串，
	// Token 从扫描器中读取连续的符合 f(c) 的字符 c，准备解析。
	// 如果 f 为 nil，则使用 !unicode.IsSpace(c) 代替 f(c)。
	// skipSpace：是否跳过开头的连续空白。返回读取到的数据。
	// 注意：token 指向共享的数据，下次的 Token 操作可能会覆盖本次的结果。
	Token(skipSpace bool, f func(rune) bool) (token []byte, err error)
	// Width 返回占位符中的宽度值以及宽度值是否被设置
	Width() (wid int, ok bool)
	// 因为上面实现了 ReadRune 方法，所以 Read 方法永远不应该被调用。
	// 一个好的 ScanState 应该让 Read 直接返回相应的错误信息。
	Read(buf []byte) (n int, err error)
}
```
**代码示例：[github](https://github.com/mjyi/go-package-fmt/blob/master/scanner.go)**

Done.

> [http://www.cnblogs.com/golove/p/3286303.html](http://www.cnblogs.com/golove/p/3286303.html)
