# Runtime

An Objective-C simulator written in Swift.

## Goals

With few exceptions, this project aims to simulate, in Swift, how Objective-C works under the hood (i.e. calls to `objc_msgSend`, inserted ARC functions, literal class-refs in class method calls, etc), as opposed to mirroring Objective-C style code and dynamism which Swift can accomplish already via `@objc` classes.

This project could theoretically be used as a dynamic runtime backend for a transpiled progamming language, and as such, this framework and its conventions were crafted with this idea in mind. Many of the constructs used here may seem to lack type-safety, but everything is perfectly safe if the code is generated by some other, more type-safe language. In short, this code is not meant to be written by hand if used for anything serious.

## Features

- Dynamic method dispatch
- Method swizzling / replacing
- Creating entire classes at runtime
- Non-fragile ivars

See `Person.Swift` for an examples of everything mentioned in the readme.

## Overview

Runtime metadata types provided by this framework mirrors that of the public Objective-C runtime interface as closely as possible, declaring types such as `Class`, `Ivar`, `Method`, etc, all of which provide about as much information as their Objective-C counterparts.

### Defining classes

A base class, `RootObject`, is provided for other classes to inherit from if they wish. New classes are defined by declaring a `struct` type to enclose the `Class` object in, with the class object itself being declared as a `static let`, followed by method variables.

```objc
struct Person {
    static let `class` = Class(
        isa: Person_meta.class,
        superclass: RootObject.class,
        name: "Person",
        ivars: [
            (name: "_name", type: .string),
            (name: "_age", type: .integer)
        ],
        methods: [_init, name, setName_, age, setAge_, description],
        properties: [
            Property(name: "name", getter: name, setter: setName_),
            Property(name: "age", getter: age, setter: setAge_),
        ],
        protocols: []
    )
    
    // Methods go here as static vars
    
    static var _init = Method("init", returns: .object("this")) { this, _cmd, args in
        func init$(_ this: id, _ _cmd: SEL) -> id {
            _msgSend(this, "setName_", ("Bob"))
            _msgSend(this, "setAge_", (18))

            return msgSend(super: true, this, _cmd)
        }

        return init$(this, _cmd)
    }
    
    static var name = Method("name", returns: .string) ...
    ...
}

private struct Person_meta {
    static let `class` = Class(
        isa: nil,
        superclass: nil,
        name: "Person.meta",
        ...
    )
}
```

It is good practice to declare a struct for the class itself and another for the metaclass, as above, to reduce ambiguity between class members and instance members (methods, properties, etc). The metaclass stores class members.

`isa:` should be the class's metaclass (or `nil` if the class is a metaclass itself). `superclass:` should be the superclass.

#### The Metaclass

Metaclasses inherit from the super-metaclass, not the superclass. It is convention to declare the compile-time variable like `MyClass_meta` and name it `"MyClass.meta"`. So, `Person` inherits from `Object.class`, and `Person_meta` inherits from `Object_meta.class`.

Each metaclass can be looked up by using `Class.named("Foo").isa` or directly by name with `Class.named("Foo.meta")`.

#### Methods
###### Declaration

`Method`s should be defined as `static var/let` as well (as opposed to right inside the `methods:` argument to the `.class` initializer as I have done with `properties:`), in case you need to reference the method as an argument to a `Property` at compile-time. Declaring them inline also makes the initializer very hard to parse visually since method declarations are typically no less than 7 or 8 lines.

###### Method.init() structure

The `Method` initializer takes the name of the method, the return and argument types (`Type`) an implementation (`IMP`). The return and argument types default to `.void` and `[]`. For initializers, it is convention to return `.object("self")` where you would use `instancetype` in Objective-C. You could use `.object("anything you want")`, but I find that `"self"` makes the most sense here. In cases where you return another object of a fixed type, use `.object("ClassName")`. This runtime aims to provide as much metadata for method type signatures as Objective-C does for property type signatures.

###### IMP arguments

Like Objective-C, all methods take two fixed arguments: `this` in place of `self`, and `_cmd`. However, due to limitations in the Swift type system, all method `IMP`s must return the same thing, `Any`, and without using assembly, they must all take `Any` as the variable arguments, even if a method takes no other arguments. An `IMP` is invoked by passing `this`, `_cmd`, and `args` where `args` is a tuple of the non-fixed arguments to the method.

###### Implementation conventions

To counteract the lack of type safety and enhance readability, I find it helpful to declare a function within the scope of the method `IMP` named with a traling `$` to represent the actual type signature of the method (and to hold the non-trivial implementation), like so:

```swift
static var add__ = Method(…) { this, _cmd, args in
    // Actual implementation and type signature of method
    func add__$(_ this: id, _ _cmd: SEL, a: Int, b: Int) -> Int {
        return a + b
    }
        
    // Cast out arguments and call method
    let args = args as! (Int, Int)
    return add__$(this, _cmd, args.0, args.1)
}
```

Arguments must be cast from `Any` to their actual types as a tuple before being used.

###### Overriding methods

To override a method, simply give your subclass another method with the same name as the method you wish to override. If you need to call the `super` implementation, simply pass `super: true` to your call to `msgSend`:

```swift
static var _init = Method("init", ...) { this, _cmd, args in
    func init$(_ this: id, _ _cmd: SEL) -> id {
        return msgSend(super: true, this, _cmd)
        print("init override: \(this)")
    }

    return init$(this, _cmd)
}
```

###### Init

If you're familiar with Swift, you may know that Swift doesn't allow you to use `self` before all ivars have been initialized. With some exceptions, the same is true here. That said, all ivars are initialized to `0` or `nil`, so it is not necessary to initialize primitive integral types to `nil` or `0`.

> Technically, if a class has no stored complex Swift structures in it (such as `String`), it should be safe to use prior to ivar initialization. I plan to make a wrapper for `String` and `Array`, etc, to counteract these edge cases.


#### Instance variables

Ivars are passed to the `Class` initializer as a tuple of their name and type. Their offset is detremined at runtime, and as a result, classes do not have fragile ivars.

> Metaclasses can not have any instance variables; trying to use ivars on a metaclass is undefined behavior.

#### Properties

Properties take a name and one or two implementations. A property's `type` comes from its `getter`.

--

### Creating objects

Instances of objects are allocated by calling `class.createInstance()`, i.e.:

```swift
let instance1 = Person.class.createInstance()
let instance2 = Class.named("Person").createInstance()
```

### Calling methods

Like Objective-C, this runtime uses dynamic dispatch via the `msgSend` and `_msgSend` functions. `_msgSend` only exists as a shortcut for void-returning methods, or cases where you want to discard the return value.

```swift
let bob: id = msgSend(Person.class.createInstance(), "init")
let name: String = msgSend(bob, "name")
let age: Int = msgSend(bob, "age")
let description: String = msgSend(bob, "description")
```

### Accessing ivars

Ivar access works similarly to how it works in Objective-C. You must retrieve the offset from the runtime and add it to `this` to access the ivar. A lot of casting is involved, and I've provided some operators to ease the pain:

```swift
let offset = this|.getClass.getIvarOffset("_someInt")!
let pointer: Pointer<Int> = ~pointer + offset
let ivarValue = pointer.pointee
```

`this|` is shorthand for `this.pointee`. `~pointer` is shorthand for `unsafeBitCast(pointer, to: T.self)`. Note that the runtime uses its own `Pointer` type, which allows `+` to offset it by bytes at at time.

The above is still pretty convoluted and heavily repeated, so I've provided yet another operator which returns `ivarValue` above:

```swift
let ivarValue: Int = this|"_someInt"
```

In general, `|` provides some form of dereferencing an object pointer. Here is another operator which can be used to set an ivar `_foo` to `5`:

```swift
this |= (5, "_foo")
```

--

### Type system "gotchas"

#### You're stuck with `id`
Since new classes are weakly defined as runtime metadata and not as concrete types in Swift code, you cannot declare a `Pointer` to a custom type directly. That is, all object references are typed as `Pointer<Object>` aka `id`, as defined by `Object.swift` (not to be confused with `RootObject`, which is akin to `NSObject`).

If you really want to declare a `Pointer<Vehicle>` for example, you could declare members on your `Vehicle ` struct like so, alongside the `static let class` declaration:

```swift
struct Vehicle {
    let _super: Object
    let _capacity: Int
    ...
    
    static let `class` = Class(isa: ...)
}

/// Vehicle subclass
struct Car {
    let _super: Vehicle
    let make: String
    let model: String
    let year: Int
    ...
    
    static let `class` = Class(isa: ...)
}
```

Now, you could possibly do the following:

```swift
let fiesta: Pointer<Car> = msgSend(
    Car.class.createInstance(),
    "init",
    ("Ford", "Fiesta", 2014, ...)
)
fiesta.year = 2017
```

Be sure to continue to declare all ivars and methods inside the `Class` variable. Statically declaring the layout like this is only useful for extra type-safety and direct ivar access if you wish to bypass non-fragile ivar lookup.

#### Using `Class`es as objects

`Class` instances could only be made possible by making `Class` a Swift `class` and not a `struct`, due to limitations in Swift's type system and several abstractions Swift imposes on the user. Therefore, they do not have the same underlying structure as `Object` does (that is, `Class` does not start with the `isa` defined by the `Object` declaration). To call a class method on a class, pass `.ref` as `this`:

    ```swift
    _msgSend(Person.class.ref, "someClassMethod")
    ```
    In general, use `class.ref` whenever you wish to treat a `Class` as an object.
    
---

## To-do

- More tests
- Zeroing deallocated references
- Suggestions welcome!
