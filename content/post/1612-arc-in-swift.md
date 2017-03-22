---
title: Swift:Automatic Reference Counting in Swift
date: 2016-12-30 10:40:56
categories:
- iOS
tags:
- Swift
- iOS
---


> 原文地址：[Automatic Reference Counting](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/AutomaticReferenceCounting.html#//apple_ref/doc/uid/TP40014097-CH20-ID48)
> 翻译： [https://www.cnswift.org/](https://www.cnswift.org/)

`Swift` 使用自动引用计数*(ARC)*机制来追踪和管理你的APP的内存使用。在大多数情况下，这意味着内存管理在Swift中“正常工作”，不需要自己考虑内存管理。ARC会自动释放类实例所占用的内存。

但是，少数情况下，`ARC `需要更多关于你和你代码之间的关系信息，以方便帮助你管理内存。


> **NOTE**
> 引用计数仅适用于类的实例。结构和枚举是值类型，而不是引用类型，不会通过引用存储和传递。


## ARC工作机制

当我们创建一个类的实例时，`ARC` 会分类一块内存来存储这个实例的信息。包括实例的内存信息，以及实例所有存储属性值的信息。

另外，当实例不再需要时，`ARC` 会释放实例所占用的内存。这样确保类实例当它不需要时，不会一直占着内存。


但是，如果`ARC`释放了一个正在使用的实例的内存，将无法再访问该实例的属性，或者调用该实例的方法。事实上，如果你试图访问实例，你的应用程序很可能会崩溃。

为了确保实例在仍然需要时不消失，ARC跟踪有多少属性，常量和变量当前指向每个类实例。只要至少有一个对该实例的活动引用仍然存在，ARC就不会释放实例。

为了实现这些，无论你将实例分配给属性，常量或变量，它们都会创建该实例的`强引用`(strong)。之所以称之为“强”引用，是因为它会将实例保持住，只要强引用还在，实例是不允许被销毁的。


## ARC

下面的例子展示了自动引用计数的工作机制、

```
class Person {
    let name: String
    init(name: String) {
        self.name = name
        print("\(name) is being initialized")
    }
    deinit {
        print("\(name) is being deinitialized")
    }
}
```

`Person` 类有一个初始化器， 它设定了实例的`name` 属性。一个反初始化器，会在类的实例被销毁的时候打印一条信息。

现在定义三个`Person?` 类型的变量，用来按照代码的顺序，为新的`Person` 实例设置引用。由于可选类型的变量会被自动初始化为一个`nil`值，目前还不会引用到`Person` 类的实例。
```
var reference1: Person?   // nil
var reference2: Person?	  // nil
var reference3: Person?   // nil
```

创建一个新的 Person 实例并且将它赋值`reference1`
```
reference1 = Person(name: "John Appleseed")		// Person
// print "John Appleseed is being initialized"
```

## 类实例之间的循环强引用

如果两个类实例彼此持有对方的强引用，因而每个实例都让对方一直存在，就会发生这种情况。这就是所谓的`循环强引用`。(Strong reference Cycles Between Class Instances)

解决循环强引用问题，可以通过定义类之间的关系为弱引用(`weak`)或无主引用(`unowned`)来代替强引用。

```
class Person {
    let name: String
    init(name: String) { self.name = name }
    var apartment: Apartment?
    deinit { print("\(name) is being deinitialized") }
}
 
class Apartment {
    let unit: String
    init(unit: String) { self.unit = unit }
    var tenant: Person?
    deinit { print("Apartment \(unit) is being deinitialized") }
}

```
这两个类都定义了反初始化器，用以在类实例被反初始化时输出信息.

```
var john: Person?			// nil
var unit4A: Apartment?		// nil

john = Person(name: "John Appleseed")	// Person
unit4A = Apartment(unit: "4A")			// Apartment

john!.apartment = unit4A
unit4A!.tenant = john

```
感叹号( ! )是用来展开和访问可选变量 john 和 unit4A 里的实例的，所以这些实例的属性可以设置。

这两个实例关联后会产生一个循环强引用。 `Person` 实例现在有了一个指向 `Apartment` 实例的强引用，而 `Apartment` 实例也有了一个指向 `Person` 实例的强引用。因此，当你断开 `john` 和 `unit4A `变量所持有的强引用时，引用计数并不会降零，实例也不会被 ARC 释放：
```
john = nil
unit4A = nil
```

注意，当你把这两个变量设为 `nil` 时，没有任何一个反初始化器被调用。循环强引用会一直阻止 `Person` 和 `Apartment` 类实例的释放，这就在你的应用程序中造成了内存泄漏。

## 解决实例之间的循环强引用

`Swift` 提供了两种办法用来解决你在使用类的属性时所遇到的循环强引用问题：弱引用（ `weak reference` ）和无主引用（ `unowned reference` )。

#### 弱引用 weak

弱引用不会对其引用的实例保持强引用，因而不会阻止`ARC` 释放被引用的实例。这个特性阻止了引用变为循环强引用。声明属性或者变量时，在前面加上`weak`关键字表明这是一个弱引用。

由于弱引用不会强保持对实例的引用，所以说实例被释放了弱引用仍旧引用着这个实例也是有可能的。因此，`ARC` 会在被引用的实例被释放是自动地设置弱引用为 `nil` 。由于弱引用需要允许它们的值为 `nil` ，它们一定得是可选类型。

> **NOTE**
> 在`ARC`给弱引用设置`nil`时不会调用属性观察者。

下面的例子跟上面 `Person` 和 `Apartment` 的例子一致，但是有一个重要的区别。这次，` Apartment` 的 `tenant` 属性被声明为弱引用：

```
class Person {
    let name: String
    init(name: String) {
        self.name = name
        print("\(name) is being initialized")
    }
    var apartment: Apartment?
    deinit {
        print("\(name) is being deinitialized")
    }
}

class Apartment {
    let unit: String
    init(unit: String) {
        self.unit = unit
    }
    weak var tenant: Person?
    deinit {
        print("Apartment \(unit) is being deinitialized")
    }
}
```

将两个变量关联起来

```
var john: Person?
var unit4A: Apartment?
 
john = Person(name: "John Appleseed")
unit4A = Apartment(unit: "4A")
 
john!.apartment = unit4A
unit4A!.tenant = john
```
`Person`实例保持对`Apartment`实例的强引用，但是`Apartment`实例现在对`Person`实例是弱引用。
```
unit4A = nil
// 
```
此时，`Person`实例保持对`Apartment`实例的强引用，所以 `Apartment`实例 并没有被释放掉。

```
john = nil

//	John Appleseed is being deinitialized
//	Apartment 4A is being deinitialized
```
`john`设置nil 后，没有对`Apartment`实例的引用，所以 `Apartment` 实例也被释放掉了。

>**NOTE**
> 在使用垃圾回收机制的系统中，由于没有强引用的对象会在内存有压力时触发垃圾回收而被释放，弱指针有时用来实现简单的缓存机制。总之，对于 ARC 来说，一旦最后的强引用被移除，值就会被释放，这样的话弱引用就不再适合这类用法了。

#### 无主引用

和`弱引用`类似，`无主引用`不会牢牢保持住引用的实例。但是不像`弱引用`，总之，`无主引用`假定是永远有值的。因此，`无主引用`总是被定义为*非可选类型*。你可以在声明属性或者变量时，在前面加上关键字 `unowned` 表示这是一个`无主引用`。

由于无主引用是`非可选类型`，你不需要在使用它的时候将它展开。无主引用总是可以直接访问。不过 `ARC` 无法在实例被释放后将无主引用设为 `nil` ，因为非可选类型的变量不允许被赋值为 `nil` 。

> **NOTE**
> 如果你试图在实例的被释放后访问无主引用，那么你将触发运行时错误。只有在你确保引用会一直引用实例的时候才使用无主引用。
> 还要注意的是，如果你试图访问引用的实例已经被释放了的无主引用，Swift 会确保程序直接崩溃。你不会因此而遭遇无法预期的行为。所以你应当避免这样的事情发生。

下面看一个例子

```
class Customer {
    let name: String
    var card: CreditCard?
    init(name: String) {
        self.name = name
    }
    deinit {
        print("\(name) is being deinitialized")
    }
}

class CreditCard {
    let number: UInt64
    unowned let customer: Customer
    init(number: UInt64, customer: Customer) {
        self.number = number
        self.customer = customer
    }
    deinit {
        print("Card # \(number) is being deinitialized")
    }
}

```
`Customer`和`CreditCard` 类，模拟了银行客户和客户的信用卡。这两个类中，每一个都将另外一个类的实例作为自身的属性。这种关系可能会造成循环强引用。

`Customer` 和 `CreditCard` 之间的关系与前面弱引用例子中 `Apartment` 和 `Person` 的关系略微不同。在这个数据模型中，一个客户可能有或者没有信用卡，但是一张信用卡总是关联着一个客户。为了表示这种关系， `Customer` 类有一个可选类型的 `card` 属性，但是 `CreditCard` 类有一个非可选类型的 customer 属性。

```
var john: Customer?    //nil

john = Customer(name: "John Appleseed")
john!.card = CreditCard(number: 1234_5678_9012_3456， customer: john!)
```
创建一个 `Customer` 实例，用它初始化和分配一个新的 `CreditCard `实例作为 `customer` 的 `card` 属性.

现在 `Customer` 实例对 `CreditCard` 实例有一个强引用，并且 `CreditCard` 实例对 `Customer` 实例有一个无主引用。

由于 `Customer` 的无主引用，当你断开 `john` 变量持有的强引用时，那么就再也没有指向 `Customer` 实例的强引用了。
```
john = nil
// prints "John Appleseed is being deinitialized"
// prints "Card #1234567890123456 is being deinitialized"
```
> **NOTE**
> 上边的例子展示了如何使用安全无主引用。Swift 还为你需要关闭运行时安全检查的情况提供了不安全无主引用——举例来说，性能优化的时候。对于所有的不安全操作，你要自己负责检查代码安全性。
> 使用 `unowned(unsafe)` 来明确使用了一个不安全无主引用。如果你在实例的引用被释放后访问这个不安全无主引用，你的程序就会尝试访问这个实例曾今存在过的内存地址，这就是不安全操作。

## 无主引用和隐式展开的可选属性

`Person `和 `Apartment` 的例子展示了两个属性值都允许为`nil`，并会潜在产生循环强引用。这种场景最适合用弱引用来解决。

`Customer`和 `CreditCard`的例子战士胃一个属性值允许为`nil`，另一个不允许为`nil`，这也有可能导致循环强引用。这种场景最好使用`无主引用`来解决。

还有第三中场景，两个属性都必须有值，并且初始化完成后永远不会为`nil`。在这种场景中，需要一个类使用`无主属性`，而另一个类使用隐式展开的`可选属性`。

下面的例子定义了两个类，`Country`和`City`，每个类将另外一个类的实例保存为属性。在这个数据模型中，每个国家必须有首都，每个城市必须属于一个国家。为了实现这种关系， `Country` 类拥有一个 `capitalCity` 属性，而 `City` 类有一个 `country` 属性：

```
class Country {
    let name: String
    var capitalCity: City!
    init(name: String, capitalName: String) {
        self.name = name
        self.capitalCity = City(name: capitalName, country: self)
    }
}


class City {
    let name: String
    unowned let country: Country
    init(name: String, country: Country) {
        self.name = name
        self.country = country
    }
}
```
为了建立两个类的依赖关系，`City`的初始化器 接收一个`Country`实例，并且将实例保存 到 `country`属性。

`Country`的初始化器调用了`City `的初始化器。总之，如同在两段式初始化中描述的那样，只有`Country`的实例完全初始化完成后，`Country`的初始化器才能把`self`传给`City`的初始化器。

为了满足这种需求，通过在类型结尾处加上感叹号（` City!` ）的方式，以声明 `Country` 的 `capitalCity` 属性为一个隐式展开的可选属性。如同在隐式展开可选项中描述的那样，这意味着像其他可选项一样， `capitalCity` 属性有一个默认值 `nil` ，但是不需要展开它的值就能访问它。

由于 `capitalCity` 默认值为 `nil` ，一旦 `Country` 的实例在初始化器中给 `name` 属性赋值后，整个初始化过程就完成了。这意味着一旦 `name` 属性被赋值后， `Country` 的初始化器就能引用并传递隐式的 `self` 。 `Country` 的初始化器在赋值 `capitalCity` 时，就能将 `self` 作为参数传递给 `City` 的初始化器。

以上的意义在于你可以通过一条语句同时创建`Country`和`City`的实例，而不产生循环引用。并且 `capitalCity` 的属性能被直接访问，而不需要通过感叹号来展开它的可选值：
```
var country = Country(name: "Canada", capitalName: "Ottawa")
print("\(country.name)'s capital city is called \(country.capitalCity.name)")
// prints "Canada's capital city is called Ottawa"

```

## 闭包的循环强引用

循环强引用还会出现在你把一个闭包分配给类实例属性的时候，并且这个闭包中又捕获了这个实例。
捕获可能发生于这个闭包函数体中访问了实例的某个属性，比如`self.someProperty`，或者这个闭包调用了一个实例的方法，例如`self.someMethod()`. 这两种情况都导致了闭包“捕获”了`self`，从而产生了循环强引用。

`循环强引用`的产生，是因为闭包和类相似，都是`引用类型`。当你把闭包赋值给了一个属性，你实际上是把一个引用赋值给了这个闭包。实质上，这跟之前上面的问题是一样的——两个强引用让彼此一直有效。总之，和两个类实例不同，这次一个是类实例和一个闭包互相引用。

`Swift` 提供了一种优雅的方法来解决这个问题，称之为闭包捕获列表（ `closuer capture list`）。不过，在学习如何用闭包捕获列表打破循环强引用之前，我们还是先来了解一下这个循环强引用是如何产生的，这对我们很有帮助。

下面的例子为你展示了当一个闭包引用了`self`后是如何产生一个循环强引用的。例子中定义了一个叫 `HTMLElement` 的类，用一种简单的模型表示 `HTML` 中的一个单独的元素：
```swift
class HTMLElement {
    let name: String
    let text: String?
    lazy var asHTML: (Void) -> String = {
        if let text = self.text {
            return "<\(self.name)>\(text)</\(self.name)>"
        } else {
            return "<\(self.name) />"
        }
    }
    init(name: String, text: String? = nil) {
        self.name = name
        self.text = text
    }
    
    deinit {
        print("\(name) is being deinitialized")
    }
}
```

默认情况下，闭包赋值给了 `asHTML` 属性，这个闭包返回一个代表` HTML `标签的字符串。如果 `text` 值存在，该标签就包含可选值 `text` ；如果 `text` 不存在，该标签就不包含文本。对于段落元素，根据 `text` 是 "some text" 还是 `nil` ，闭包会返回 `<p>some text</p>` 或者 `<p />` 。

可以像实例方法那样去命名、使用 `asHTML` 属性。总之，由于 `asHTML` 是闭包而不是实例方法，如果你想改变特定元素的 `HTML `处理的话，可以用自定义的闭包来取代默认值。

```
let heading = HTMLElement(name: "h1")
let defaultText = "some default text"
heading.asHTML = {
    return "<\(heading.name)>\(heading.text ?? defaultText)</\(heading.name)>"
}

print(heading.asHTML())
```

> **NOTE**
>`asHTML` 声明为`lazy`属性，因为只有当元素确实需要处理为`HTML`输出的字符串时，才需要使用 `asHTML `。
> 实际上 asHTML 是延迟加载属性意味着你在默认的闭包中可以使用 `self` ，因为只有当初始化完成以及 self 确实存在后，才能访问延迟加载属性。

`HTMLElement` 类只提供一个初始化器，通过 name 和 text （如果有的话）参数来初始化一个元素。该类也定义了一个初始化器，当 `HTMLElement` 实例被释放时打印一条消息。

实例的 `asHTML` 属性持有闭包的强引用。但是，闭包在其闭包体内使用了 `self `（引用了 `self.name` 和 `self.text` ），因此闭包捕获了 `self` ，这意味着闭包又反过来持有了 `HTMLElement` 实例的强引用。这样两个对象就产生了循环强引用。（更多关于闭包捕获值的信息，请参考值捕获）。

> **NOTE**
> 尽管闭包多次引用`HTMLElement`,它只捕获`HTMLElement`实例的一个强引用。

如果设置 paragraph 变量为 nil ，打破它持有的 HTMLElement 实例的强引用， HTMLElement 实例和它的闭包都不会被释放，也是因为循环强引用。

```
paragraph = nil
```

## 解决闭包的循环强引用

你可以通过定义捕获列表作为闭包的定义来解决在闭包和类实例之间的循环强引用。捕获列表定义了当在闭包体里捕获一个或多个引用类型的规则。正如在两个类实例之间的循环强引用，声明每个捕获的引用为引用或无主引用而不是强引用。应当根据代码关系来决定使用弱引用还是无主引用。

> **NOTE**
> `Swift` 要求你在闭包中引用`self`成员时使用 `self.someProperty` 或者` self.someMethod` （而不只是 `someProperty` 或 `someMethod` ）。这有助于提醒你可能会一不小心就捕获了 `self` 。

```
lazy var someClosure: (Int, String) -> String = {
    [unowned self, weak delegate = self.delegate!] (index: Int, stringToProcess: String) -> String in
    // closure body goes here
}
```

如果闭包没有指明形式参数列表或者返回类型，是因为它们会通过上下文推断，那么就把捕获列表放在关键字 in 前边，闭包最开始的地方：

```
lazy var someClosure: Void -> String = {
    [unowned self, weak delegate = self.delegate!] in
    // closure body goes here
}
```

## 弱引用和无主引用

在闭包和捕获的实例总是互相引用并且总是同时释放时，将闭包内的捕获定义为无主引用。

相反，在被捕获的引用可能会变为 nil 时，定义一个弱引用的捕获。弱引用总是可选项，当实例的引用释放时会自动变为 nil 。这使我们可以在闭包体内检查它们是否存在。

> **NOTE**
> 如果被捕获的引用永远不会变为`nil` ，应该用无主引用而不是弱引用。

前面的 `HTMLElement `例子中，无主引用是正确的解决循环强引用的方法。这样编写 `HTMLElement` 类来避免循环强引用：
```swift
class HTMLElement {
    
    let name: String
    let text: String?
    
    lazy var asHTML: Void -> String = {
        [unowned self] in
        if let text = self.text {
            return "<\(self.name)>\(text)</\(self.name)>"
        } else {
            return "<\(self.name) />"
        }
    }
    
    init(name: String, text: String? = nil) {
        self.name = name
        self.text = text
    }
    
    deinit {
        print("\(name) is being deinitialized")
    }
}
```
上面的 `HTMLElement` 实现和之前的实现一致，除了在` asHTML` 闭包中多了一个捕获列表。这里，捕获列表是 `[unowned self]` ，表示“用无主引用而不是强引用来捕获 `self` 。

```swift
var paragraph: HTMLElement? = HTMLElement(name: "p", text: "hello, world")
print(paragraph!.asHTML())
// prints "<p>hello, world</p>"

paragraph = nil
// prints "p is being deinitialized"
```

end!!!
