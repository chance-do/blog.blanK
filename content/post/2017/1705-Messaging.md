---
comments: true
date: 2017-05-25
categories:
- 技术文章
tags:
- iOS
- runtime
title: Objective-C Messaging
toc: true
---


## 消息传递（Messaging）

在C语言中，调用一个方法其实就是跳转到内存中的某一点，并开始执行一段代码。没有动态特性特性，因为这个是在编译时就决定的。
但是在`Objective-C`，在运行时之前，消息不会绑定到方法实现。例如代码`[receiver message]`,实际上是编译器会在运行时给`receiver` 发送一条`message`,`message`可以由`receiver`处理，也可以被转发给另一个对象。等同于：


```objc
objc_msgSend(receiver, selector)
```

>`objc_msgSend`方法定义为`id objc_msgSend(id self, SEL op, ...);`,向实例对象发送一个简单返回值的消息。

其中参数

- **self** : 指向要接受消息的实例对象的指针
- **op** :   处理消息的方法的选择器
- **...** :  包含方法参数的变量参数列表。

要想进一步了解其中的关键，需要先了解一些结构。*objc_class*,*objc_object*,*objc_method*

而消息传递的关键在于 `objc_object` 中的 isa 指针和 `objc_class` 中的 class dispatch table。

```objc

// ******************* objc.h ************************
#if !OBJC_TYPES_DEFINED
/// An opaque type that represents an Objective-C class.
typedef struct objc_class *Class;

/// Represents an instance of a class.
struct objc_object {
    Class isa  OBJC_ISA_AVAILABILITY;
};

/// A pointer to an instance of a class.
typedef struct objc_object *id;
#endif

// ********************** runtime.h **********************
struct objc_method {
    SEL method_name     OBJC2_UNAVAILABLE; // 函数名
    char *method_types  OBJC2_UNAVAILABLE; // 函数类型的字符串 
    IMP method_imp      OBJC2_UNAVAILABLE; // 实现IMP
} OBJC2_UNAVAILABLE;


struct objc_class {
    Class isa  OBJC_ISA_AVAILABILITY; // isa指针指向MetaClass,因为Objc的类的本身也是一个Objective，为了处理这种关系，runtime创造了MetaClass,当给类发送[NSObject alloc]这样消息时，实际上是把消息发送给了Class Object。

#if !__OBJC2__
    Class super_class  OBJC2_UNAVAILABLE; // 父类
    const char *name   OBJC2_UNAVAILABLE; // 类名
    long version       OBJC2_UNAVAILABLE; // 类的版本号，默认为0
    long info          OBJC2_UNAVAILABLE; // 类信息，供运行期间使用的一些标识
    long instance_size              OBJC2_UNAVAILABLE; //类的实例变量大小
    struct objc_ivar_list *ivars    OBJC2_UNAVAILABLE; //类的成员变量链表
    struct objc_method_list **methodLists   OBJC2_UNAVAILABLE; // 方法定义的链表
    struct objc_cache *cache                OBJC2_UNAVAILABLE; // 方法缓存，对象接收一个消息会根据isa指针查找消息对象，这时会在methodLists中遍历，如果cache了，可以大大提高函数查询的效率。
    struct objc_protocol_list *protocols    OBJC2_UNAVAILABLE; // 协议链表
#endif

} OBJC2_UNAVAILABLE;
/* Use `Class` instead of `struct objc_class *` */

```
> objc 关于runtime的代码可以在[https://opensource.apple.com/tarballs/objc4/][runtime-open]下载查看

>  char *method_types 参考：[Type Encodings][type-encodings]

`objc_method_list` 可以看作一个有 `objc_method` 元素的可变长度的数组。

从上面的定义可以很好理解`objc_msgSend`做了什么。拿 `objc_msgSend(receiver, selector)` 为例：

1. 通过 receiver 的isa指针找到它的 class
2. 在 cache 和 methodLists 中找到方法 selector 
3. 如果在 class 中没有找到，继续往它的 superclass 中找
4. 一旦找到 selector 这个函数，就去执行它的实现IMP

## 动态方法解析和转发

### 动态解析流程图

![动态解析流程图](/media/runtime-messaging.png)

- 第一步：通过`resolveInstanceMethod：`方法决定是否动态添加方法。如果返回Yes则通过`class_addMethod`动态添加方法，消息得到处理，结束；如果返回No，则进入下一步；
- 第二步：这步会进入`forwardingTargetForSelector:`方法，用于指定备选对象响应这个selector，不能指定为self。如果返回某个对象则会调用对象的方法，结束。如果返回nil，则进入第三步；
- 第三步：这步我们要通过`methodSignatureForSelector:`方法签名，如果返回nil，则消息无法处理。如果返回methodSignature，则进入下一步；
- 第四步：这步调用`forwardInvocation：`方法，我们可以通过anInvocation对象做很多处理，比如修改实现方法，修改响应对象等，如果方法调用成功，则结束。如果失败，则进入`doesNotRecognizeSelector`方法，若我们没有实现这个方法，那么就会crash。

### 代码
> Talk is Cheep, show me the code.

 举例：创建一个`Cat`类，通过向`Cat`的实例对象调用不实现的方法,验证消息传递和消息转发。

#### One

向`Cat`调用`run`方法,在找不到方法时动态添加方法。

创建`Cat`类

```objc
// .h 
@interface Cat : NSObject

@end

// .m
@implementation Cat

// 没有声名实现run方法，在这里动态添加。
+ (BOOL)resolveInstanceMethod:(SEL)aSEL
{
    if([NSStringFromSelector(aSEL) isEqualToString:@"run"]){
        class_addMethod([self class], aSEL, (IMP)runMethod, "v@:");
        return YES;
    }
    return [super resolveInstanceMethod:aSEL];
}

void runMethod(id self, SEL _cmd)
{
    NSLog(@"Cat run！");
}
@end

```
在main.m 中运行代码；
```objc
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Cat *cat = [[Cat alloc] init];
        // 强制转换objc_msgSend函数类型为带两个参数且返回值为void函数
        ((void (*)(id, SEL))objc_msgSend)(cat, NSSelectorFromString(@"run"));
    }
    return 0;
}
```
结果输出为：

    Cat run！


#### Two

向`Cat`调用`sing`方法,动态更换调用对象。新增`Dog`类，实现`sing`方法。

`Dog`类
```objc
// .h
@interface Dog : NSObject

- (void)sing;

@end

// .m
@implementation Dog

- (void)sing {
    NSLog(@"汪 汪!");
}

@end

```

`Cat`类
```objc

// 1.不动态添加方法，返回NO
+ (BOOL)resolveInstanceMethod:(SEL)aSEL
{
    return NO;
}

// 2. 指定 Dog 为转发对象
- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([NSStringFromSelector(aSelector) isEqualToString:@"sing"]) {
        return [[Dog alloc] init];
    }
    return nil;
}

```
结果输出：

    汪 汪!


 Cat 类 实现了`-forwardingTargetForSelector:` 方法，那么Runtime 就会调用这个方法，消息转发给其他对象，整个消息发送的过程就会被重启，发送的对象会变成你返回的那个对象。

#### Three

如果在上一步，返回nil，那么这里是处理消息的最后机会了。
首先 Runtime 会发送 `-methodSignatureForSelector:` 消息获得函数的参数和返回值类型。如果 `-methodSignatureForSelector: `返回 nil ，Runtime 则会发出 `-doesNotRecognizeSelector: `消息，程序这时也就挂掉了。如果返回了一个函数签名，Runtime 就会创建一个 `NSInvocation` 对象并发送 `-forwardInvocation: `消息给目标对象。

向`Cat`调用`sleep`方法,用eat方法处理。


`Cat`类
```objc
// .m
- (void) eat {
    NSLog(@"Cat eat！");
}

// 不动态添加方法，返回NO
+ (BOOL)resolveInstanceMethod:(SEL)aSEL {
    return NO;
}

// 不指定备选对象
- (id)forwardingTargetForSelector:(SEL)aSelector {
    return nil;
}

// 返回方法选择器
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if ([NSStringFromSelector(aSelector) isEqualToString:@"sleep"]) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return [super methodSignatureForSelector:aSelector];
}

// 修改调用对象
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    [anInvocation setSelector:@selector(eat)];
    [anInvocation invokeWithTarget:self];
}

- (void)doesNotRecognizeSelector:(SEL)aSelector {
    NSLog(@"Dog消息无法处理： %@",NSStringFromSelector(aSelector));
}


@end
```

输出结果：
    
    Cat eat

## 总结

`Runtime`是Objective-C 面向对象和动态特性的基础。了解消息传递机制。有助于更好的解决开发中的项目技术和设计问题。
[代码传送门](https://github.com/mjyi/objc-Message-Forwarding.git)

## Reference

[Objective-C Runtime Programming Guide][guide]

[Objective-C Runtime][objc-runtime]


[guide]: https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008048
[objc-runtime]: http://tech.glowing.com/cn/objective-c-runtime/

[runtime-open]: https://opensource.apple.com/tarballs/objc4/

[type-encodings]:https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html