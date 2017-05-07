---
date: 2017-03-23T13:09:52+08:00
description: ""
tags:
- Objective-C
title: "Block和self的循环引用"
topics:
- development
- iOS
draft: true
---

Block
========

什么是`block`, `Block`由以下形式的结构组成：[在线查看][block online]
```
struct Block_literal_1 {
    void *isa;
    int flags;
    int reserved; 
    void (*invoke)(void *, ...);
    struct Block_descriptor_1 {
	unsigned long int reserved;	// NULL
    	unsigned long int size;  // sizeof(struct Block_literal_1)
    	void (*copy_helper)(void *dst, void *src);
    	void (*dispose_helper)(void *src); 
    } *descriptor;
    // 捕获的变量
};
```

block是带有自动变量(局部变量)的匿名函数,Block是Objective-C版本的lambda或者closure(闭包)。
block对象就是一个结构体，里面有isa指针指向自己的类（global malloc stack），有desc结构体描述block的信息，__forwarding指向自己或堆上自己的地址，如果block对象截获变量，这些变量也会出现在block结构体中。最重要的block结构体有一个函数指针，指向block代码块。</br>
block结构体的构造函数的参数，包括函数指针，描述block的结构体，自动截获的变量（全局变量不用截获），引用到的__block变量。(__block对象也会转变成结构体)block代码块在编译的时候会生成一个函数，函数第一个参数是前面说到的block对象结构体指针。
执行block，相当于执行block里面__forwarding里面的函数指针。
多用于参数传递, 代替代理方法, (有多个参数需要传递或者多个代理方法需要实现还是推荐使用代理方法), 少用于当做返回值传递.
<!--more-->
block是一个OC对象, 它的功能是保存代码片段, 预先准备好代码, 并在需要的时候执行.
关键点：
- `block`是在栈上创建的
- `block`可以复制到堆上
- `block` 会捕获栈上的变量(或指针)，将其复制为私有的`const`变量。
- 如果在`block`中修改`block`块外的变量和指针，必须用`__block`关键字申明。

如果`block`没有在其他地方被持有，那么它会随着栈生存，并且随着栈帧(stack frame)的返回而消失。仅存在于栈上时，`block`对于对象的内存管理和生命周期没有任何影响。

如果`block`需要在栈帧返回时存在，那么`block`需要明确地被复制到堆上。这样，`block`会像其他`Cocoa`对象一样增加引用计数。当它们被复制的时候，它会带着它们的捕获作用域一起，`retain`他们所引用的对象。

最重要的事情是 `__block` 声明的变量和指针在 `block` 里面是作为显示操作真实值/对象的结构来对待的。

关于`Block`的概念概述以及用法，在[Blocks Programming Topics][Blocks Programming Topics]中，有很详细的说明。

[block online]:[http://opensource.apple.com/source/libclosure/libclosure-63/]
[Blocks Programming Topics]:[https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/Blocks/Articles/00_Introduction.html#//apple_ref/doc/uid/TP40007502-CH1-SW1]

