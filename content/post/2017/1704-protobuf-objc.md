---
date: 2017-04-08
description: ""
tags: 
- iOS
- Protobuf
categories:
- 技术文章
title: "Protocol Buffer Objerctive-C Compiler(protoc)"
comments: true
toc: true
---

## 什么是Protocol buffers?
> Protocol buffers are a language-neutral, platform-neutral extensible mechanism for serializing structured data.

Protocol buffers 是一种以有效且可扩展的格式对结构化数据进行编码的方式。它和xml类似，但是比xml更轻量，更快速，更简单。<br>
你可以定义自己想要的结构化数据，然后可以使用特殊的生成源代码轻松地将结构化数据写入和读取各种数据流并使用各种语言。

**Protocol buffers项目的主页在[这里][protobuf]。**

**开发指南在[这里][guide]。**

Objective-C Protocol Buffers 实现需要以下环境:

- Objective C 2.0 Runtime (32bit & 64bit iOS, 64bit OS X).
- Xcode 7.0 (or later).
- 出于性能考虑，代码没有使用ARC。

## 安装

Protobuf 可以通过brew和source code 两种方式安装。<br>
在这里，我推荐使用源代码安装。到[这里][release]选择发行的版本。
我选择安装的是3.2版本，与公司项目中使用的2.0+版本有很大的区别。

protobuf的安装依赖`automake`,`libtool`。确保它们在系统中存在。
```
brew install automake
brew install libtool
```
homebrew可以到[这里][homebrew]找到如何安装。

将压缩包解压到指定的安装目录，开始编译`protoc`：
```
cd <install_directory>
./autogen.sh
./configure
make
```
如果运行没有错误的话，`protoc`将会出现在 \<install_directory>/src 中。

我们可以对`protoc`在`usr/local/bin`下建立一个链接方便使用。
```
 ln -s ~/<install_directory>/src/protoc /usr/local/bin/   #注意绝对路径。
```

## 编译调用
Objective-C的编译器已经安装好了，下面让我们在项目中测试一下使用。

自定义结构化数据 `.protoc` 并编译。
新建文件foo.proto, 并写入：
```
syntax = "proto3";

message User {
  string name = 1;
  int32 age = 2;
  int32 userId = 3;
}
```
在当前目录执行：`protoc foo.proto --objc_out=./`
当然，你也可以自定义文件输出目录，但是不能忘记参数`-objc_out`。<br>
此时会在当前目录生成`Foo.pbobjc.h`	和`Foo.pbobjc.m`两个文件。将这两个文件添加到项目中去。

## 项目整合

首先要将Objective C Protocol Buffers runtime library 集成到项目中去。

方法一：
在\<install_directory>/objectivec 下将 .h 和 .m 文件作为直接依赖添加到项目中去。

方法二：
使用`cocoapods`来管理
```
pod 'Protobuf', '~> 3.2.0'
```

之前说过，protocbuf生成的代码是不支持`ARC`的,所以如果项目是使用ARC的。还要为 .m 文件添加Compiler Flags:`-fno-objc-arc`。

 Target -> Build Phases -> Compile Sources -> Compiler Flags

正常情况下,项目中错误提示已经处理完了。

简单的看一下Protobuf在OC中的使用：pb > data, data > pb。
```
  User *user = [[User alloc] init];
  user.name = @"blank";
  user.age = 24;
  user.userId = 2333;

  NSData *pbData = [user data];
  NSLog(@"\n%@",user);
  NSLog(@"data.length = %ld",[pbData length]);
  
  NSError *error;
  User *decodeUser = [[User alloc] initWithData:pbData error:&error];
  NSLog(@"\n%@",decodeUser);
```
最后我们对比由Protobuf 序列化data，与Json 序列化data的大小：
```
    NSDictionary *jsonDic = @{@"name": @"blank",
                              @"age": @24,
                              @"userId":@2333
                              };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:0 error:NULL];
    NSLog(@"jsonData.length = %ld",jsonData.length);
```
全部输出：
```
<User 0x6000000d5a10>: {
    name: "blank"
    age: 24
    userId: 2333
}
data.length = 12
<User 0x6180000d6500>: {
    name: "blank"
    age: 24
    userId: 2333
}
 jsonData.length = 39
```
可以看到，Protobuf编码后的data大约只有json 的1/3。优点还是很明显的。
本文的Demo可在[这里](https://github.com/mjyi/Protobuf_Dome.git)找到。

**END**

[protobuf]:https://github.com/google/protobuf
[guide]:https://developers.google.com/protocol-buffers/
[release]:https://github.com/google/protobuf/releases
[homebrew]:https://brew.sh/