# C++ 列表初始化

> 类型：concept
> 一句话：C++ 列表初始化语法


在 C++ 中，std::thread t(hello); 和 std::thread t{hello}; 都可以成功构建 std::thread 对象，这涉及 C++ 的两种不同的初始化语法：直接初始化（Direct Initialization）和列表初始化（List Initialization，也常被称为统一初始化 Uniform Initialization）。

 1. std::thread t(hello); - 直接初始化 (Direct Initialization)

这是 C++ 中传统的构造函数调用方式。当你写 std::thread t(hello); 时：

   编译器会寻找 std::thread 类中与 hello 函数签名（或者可以转换为 std::thread 构造函数参数类型）匹配的构造函数。
   std::thread 有一个构造函数接受一个可调用对象（如函数指针、lambda 表达式、函数对象等）作为其第一个参数，以及可选的后续参数作为可调用对象的参数。
   在这里，hello 是一个函数，它的地址可以隐式转换为函数指针，因此它匹配了 std::thread 的构造函数 template< class Function, class... Args > explicit thread( Function&& f, Args&&... args );。

这种方式直接调用了 std::thread 的构造函数。

 2. std::thread t{hello}; - 列表初始化 (List Initialization / Uniform Initialization)

这是 C++11 引入的一种新的初始化语法，旨在提供一种统一的方式来初始化所有类型的对象，并解决一些旧有语法的问题。当你写 std::thread t{hello}; 时：

   编译器首先会尝试寻找 std::thread 类中接受 std::initializer_list 类型参数的构造函数。
   std::thread 没有一个接受 std::initializer_list<void ()()（即函数指针的初始化列表）的构造函数。
   当没有找到匹配的 std::initializer_list 构造函数时，列表初始化会回退（fall back）到执行直接初始化。

因此，std::thread t{hello}; 最终也会调用与 std::thread t(hello); 相同的构造函数。

 为什么引入列表初始化？

列表初始化主要有以下几个优点：

1.  统一性： 它可以用于初始化任何类型，无论是内置类型、数组、结构体还是类。

```cpp
int x = 5;       // 传统
int x{5};        // 列表初始化

int arr[] = {1, 2, 3}; // 传统
int arr[]{1, 2, 3};    // 列表初始化

MyClass obj(arg1, arg2); // 传统
MyClass obj{arg1, arg2}; // 列表初始化
```

2.  防止窄化转换 (Narrowing Conversions)： 列表初始化在默认情况下会禁止窄化转换（例如将 double 隐式转换为 int，这可能导致数据丢失），从而提高代码安全性。

```cpp
int x = 3.14; // 编译通过，x 变为 3 (窄化转换)
// int x{3.14};  // 编译错误，禁止窄化转换
```

3.  解决“最令人头疼的解析”（Most Vexing Parse）： 这是列表初始化最重要的动机之一。在 C++ 中，如果一个声明可以被解析为函数声明，那么它就会被解析为函数声明，而不是对象定义。

例如：

```cpp
MyClass obj(); // 这不是定义一个 MyClass 类型的对象 obj，而是声明一个返回 MyClass 且不接受参数的函数 obj。
```

使用列表初始化可以避免这个问题：

```cpp
MyClass obj{}; // 这明确地定义了一个 MyClass 类型的对象 obj，并使用默认构造函数初始化。
```
    对于 std::thread t(hello); 来说，hello 是一个函数名而不是类型名，所以这里没有“最令人头疼的解析”的问题。但对于 std::thread t(); 这样的写法，它会被解析为函数声明，而不是创建一个 std::thread 对象。

 总结

对于 std::thread t(hello); 和 std::thread t{hello}; 两种写法，它们都能成功构建 std::thread 对象，因为：

   std::thread t(hello); 是直接调用构造函数。
   std::thread t{hello}; 是列表初始化，但由于 std::thread 没有匹配的 std::initializer_list 构造函数，它会回退到执行直接初始化，最终效果与第一种写法相同。

在现代 C++ 编程中，推荐使用列表初始化 {}，因为它更统一、更安全（防止窄化转换），并能避免“最令人头疼的解析”问题。
