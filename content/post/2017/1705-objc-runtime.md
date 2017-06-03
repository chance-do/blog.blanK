---
comments: true
date: 2017-05-24
description: ""
categories:
- 技术文章
tags:
- runtime
- iOS
title: "Objective-C Runtime"
draft: true
toc: true
---

## Runtime 交互

`Objctive-C`通过有3种不同的层次与运行时系统交互：

1. 通过`Objective-C`代码
- 通过在`Foundation`框架的`NSObject`类中定义的方法
- 通过直接调用运行时功能

### 1.Objective-C Source Code
当编译包含`Objective-C`类和方法，编译器将创建实现语言动态特性的数据结构和函数调用。
数据结构捕获在类中、类别中定义和协议中声明的一些信息;包括类和协议对象、方法、实例变量等
主要的运行时功能是*发送消息*的功能。

### 2.NSObject Methods
`Cocoa`中大多对象都是`NSObject`类的子类。大多数对象继承了它定义的方法（`NSProxy`例外）。
大多数情况下，`NSObject`定义了一些类和实例的固有的行为。
`NSObject`也定义了一些模板方法，如`description`,由子类具体实现。

`NSObject`一些常用于对象检测自身的方法，如：

- `isKindOfClass：`和`isMemberOfClass：`，它测试对象在继承层次结构中的位置;
- `respondToSelector：`指示对象是否可以接受特定消息; 
- `conformsToProtocol：`指示对象是否声称实现特定协议中定义的方法;
- `methodForSelector：`，它提供了方法实现的地址。

### Runtime Functions

运行时系统是一个*动态共享库*，其公共接口由位于目录`/usr/include/objc`中的头文件中的一组函数和数据结构组成。许多这些功能允许您在编写`Objective-C`代码时使用普通C来复制编译器所做的工作。其他组成了通过NSObject类的方法导出的功能的基础。这些功能使得可以开发与运行时系统的其他接口并生成增加开发环境的工具;在Objective-C中编程时不需要它们。但是，在编写Objective-C程序时，有些运行时函数有时可能很有用。