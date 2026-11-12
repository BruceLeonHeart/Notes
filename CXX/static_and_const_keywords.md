# C++ `static` 与 `const` 关键字详解

> 类型：concept
> 一句话：static / const / constexpr 用法


在 C++ 中，`static` 和 `const` 是两个非常重要的关键字，它们在不同的上下文中有不同的含义和用途。理解它们的用法对于编写高效、安全且易于维护的 C++ 代码至关重要。

---

## 1. `static` 关键字

`static` 关键字主要用于控制变量的**存储周期 (storage duration)** 和**链接性 (linkage)**，在类中还用于表示类级别的成员。

### 1.1 静态局部变量 (函数内)

-   **作用**：改变局部变量的存储周期，使其在函数调用结束后仍然存在，但作用域仍限制在函数内部。
-   **存储周期**：静态存储周期。在程序启动时初始化一次，在程序结束时销毁。
-   **初始化**：只在第一次执行到其声明时初始化。如果不显式初始化，会被自动初始化为零。
-   **特点**：在多次函数调用之间，其值会保持不变。

**示例：**
```cpp
#include <iostream>

void counter() {
    static int count = 0; // 静态局部变量，只在首次调用时初始化
    count++;
    std::cout << "Count: " << count << std::endl;
}

int main() {
    counter(); // 输出: Count: 1
    counter(); // 输出: Count: 2
    counter(); // 输出: Count: 3
    return 0;
}
```

### 1.2 静态全局变量与函数 (文件作用域)

-   **作用**：改变全局变量和函数的链接性，使其只在当前编译单元（`.cpp` 文件）内可见。
-   **链接性**：内部链接 (internal linkage)。这意味着其他文件无法通过 `extern` 访问或链接到这个 `static` 全局变量或函数。
-   **优点**：避免在多个文件中因同名全局变量或函数而导致的命名冲突。

**示例 (file1.cpp):**
```cpp
// file1.cpp
#include <iostream>

static int file_scoped_var = 10; // 内部链接，只在 file1.cpp 可见

static void file_scoped_func() { // 内部链接，只在 file1.cpp 可见
    std::cout << "Called file_scoped_func() from file1.cpp. Var is " << file_scoped_var << std::endl;
}

// 这个函数是外部链接，可以被其他文件访问
void global_func_from_file1() {
    file_scoped_func(); // 可以调用本文件内的 static 函数
}
```

**示例 (file2.cpp):**
```cpp
// file2.cpp
#include <iostream>

// 声明 file1.cpp 中的全局函数
extern void global_func_from_file1();

int main() {
    // extern int file_scoped_var; // 链接错误：无法访问 file1.cpp 中的 static 变量
    // file_scoped_func();         // 链接错误：无法访问 file1.cpp 中的 static 函数
    
    global_func_from_file1(); // 正确：可以调用 file1.cpp 中非 static 的全局函数
    return 0;
}
```

### 1.3 静态成员变量 (类数据成员)

-   **作用**：使成员变量属于类本身，而不是类的某个对象。所有该类的对象共享同一个 `static` 成员变量的副本。
-   **存储周期**：静态存储周期。
-   **初始化**：必须在类外部进行定义和初始化（通常在 `.cpp` 文件中）。唯一的例外是 `const static` 的整型（或枚举）成员，可以在类内部初始化。
-   **访问**：可以通过类名 `ClassName::static_member` 直接访问，也可以通过对象访问。

**示例：**
```cpp
#include <iostream>

class MyClass {
public:
    static int object_count; // 声明静态成员变量

    MyClass() {
        object_count++;
    }
    ~MyClass() {
        object_count--;
    }
};

// 在类外部定义和初始化静态成员变量
int MyClass::object_count = 0;

int main() {
    std::cout << "Initial count: " << MyClass::object_count << std::endl; // 输出: 0

    MyClass obj1;
    MyClass obj2;
    std::cout << "Count after creating 2 objects: " << obj1.object_count << std::endl; // 输出: 2

    return 0;
}
```

### 1.4 静态成员函数 (类方法)

-   **作用**：使成员函数属于类本身，而不是类的某个对象。
-   **特点**：
    -   没有 `this` 指针，因为它不与任何特定对象关联。
    -   不能直接访问非 `static` 的成员变量或调用非 `static` 的成员函数。
    -   只能访问 `static` 成员变量和调用其他 `static` 成员函数。
-   **访问**：通常通过类名 `ClassName::static_func()` 直接调用。

**示例：**
```cpp
#include <iostream>

class MyClass {
public:
    static int static_var;
    int non_static_var;

    MyClass() : non_static_var(0) {}

    // 静态成员函数
    static void static_func() {
        std::cout << "Inside static_func. Static var: " << static_var << std::endl;
        // std::cout << non_static_var; // 编译错误：不能访问非静态成员
        // non_static_func();           // 编译错误：不能调用非静态方法
    }

    // 非静态成员函数
    void non_static_func() {
        std::cout << "Inside non_static_func. Accessing static var: " << static_var << std::endl;
        static_func(); // OK: 非静态方法可以调用静态方法
    }
};

int MyClass::static_var = 100;

int main() {
    MyClass::static_func(); // 正确且推荐的调用方式

    MyClass obj;
    obj.non_static_func();
    // obj.static_func(); // 语法允许，但不推荐，因为它会误导读者认为该函数与对象状态有关
    return 0;
}
```

---

## 2. `const` 关键字

`const` 关键字用于表示“常量”或“只读”的语义，即一个标识符的值在初始化后不能被修改。它提供了编译时检查，有助于提高代码的健壮性和安全性。

### 2.1 常量

-   **作用**：声明一个变量为常量，其值在初始化后不能被改变。
-   **初始化**：必须在声明时进行初始化。

**示例：**
```cpp
const int MAX_VALUE = 100; // 常量整数
// MAX_VALUE = 200; // 错误：不能修改常量
```

### 2.2 `const` 与指针

`const` 在指针声明中的位置决定了是指针本身是常量，还是指针指向的数据是常量。

**A. 指向常量的指针 (Pointer to `const`)**
-   **含义**：不能通过该指针修改所指向的数据，但指针本身可以指向其他地址。
-   **语法**：`const T* ptr;` 或 `T const* ptr;`
```cpp
int a = 10, b = 20;
const int* p = &a;
// *p = 15; // 错误：不能通过 p 修改 a 的值
p = &b;      // 正确：p 可以指向其他变量
```

**B. 常量指针 (`const` Pointer)**
-   **含义**：指针本身是常量，一旦初始化后不能再指向其他地址，但可以通过该指针修改所指向的数据。
-   **语法**：`T* const ptr;`
```cpp
int a = 10, b = 20;
int* const p = &a;
*p = 15;     // 正确：可以通过 p 修改 a 的值
// p = &b;    // 错误：p 是常量，不能再指向 b
```

**C. 指向常量的常量指针 (`const` Pointer to `const`)**
-   **含义**：指针本身和它指向的数据都是常量，都不能被修改。
-   **语法**：`const T* const ptr;`
```cpp
int a = 10, b = 20;
const int* const p = &a;
// *p = 15; // 错误：不能修改指向的数据
// p = &b;  // 错误：不能指向其他地址
```

### 2.3 `const` 函数参数

-   **作用**：确保函数内部不会修改传入的参数。
-   **传值**：对于传值参数，`const` 修饰没有太大意义，因为函数操作的是副本。
-   **传引用/指针**：对于传引用或传指针的参数，`const` 非常重要。它既能避免大对象的拷贝开销，又能保证原始数据不被函数修改。

```cpp
// 高效且安全：通过 const 引用传递，避免拷贝且保证数据不被修改
void print_item(const std::string& item) {
    // item = "new value"; // 错误：不能修改
    std::cout << item << std::endl;
}
```

### 2.4 `const` 成员函数

-   **作用**：在成员函数声明的末尾加上 `const`，表示该函数是一个“只读”函数，它承诺不会修改对象的任何非 `static` 成员变量。
-   **特点**：
    -   `const` 对象只能调用 `const` 成员函数。
    -   在 `const` 成员函数内部，`this` 指针的类型是 `const T*`。
    -   不能在 `const` 成员函数内修改非 `mutable` 的成员变量。

**示例：**
```cpp
#include <iostream>

class Point {
private:
    int x_;
    int y_;
    mutable int access_count_ = 0; // mutable 成员可以在 const 函数中被修改

public:
    Point(int x, int y) : x_(x), y_(y) {}

    // 常量成员函数
    void print() const {
        std::cout << "Point(" << x_ << ", " << y_ << ")" << std::endl;
        access_count_++; // OK: mutable 成员可以被修改
        // x_ = 10; // 错误：不能修改非 mutable 成员
    }

    // 非常量成员函数
    void move(int dx, int dy) {
        x_ += dx;
        y_ += dy;
    }
};

int main() {
    const Point p1(1, 2); // 常量对象
    p1.print();           // OK: const 对象可以调用 const 成员函数
    // p1.move(3, 4);     // 错误: const 对象不能调用非 const 成员函数

    Point p2(5, 6);       // 非常量对象
    p2.print();           // OK
    p2.move(7, 8);        // OK
    p2.print();
    return 0;
}
```

---

## 3. `constexpr` (C++11 及以上)

`constexpr` 是一个比 `const` 更强的约束，它表示“常量表达式”。

-   **对于变量**：`constexpr` 变量必须在编译时就能确定其值。
-   **对于函数**：`constexpr` 函数如果传入的参数是编译时常量，那么它就能在编译时产生结果。

这使得 `constexpr` 变量和函数可以用于需要编译时常量的场景，例如数组大小、模板参数等。

```cpp
// constexpr 函数
constexpr int get_square(int n) {
    return n * n;
}

int main() {
    const int runtime_val = 5; // 运行时常量
    constexpr int compile_time_val = get_square(3); // 编译时计算为 9

    int arr[compile_time_val]; // 正确：数组大小必须是编译时常量
    // int arr2[runtime_val]; // 错误 (标准C++)：数组大小不能是运行时变量

    return 0;
}
```

---

## 总结

| 关键字 | 主要作用 | 核心关注点 |
| :--- | :--- | :--- |
| `static` | 控制变量的存储周期和链接性；创建类级别的共享成员。 | **生命周期** 和 **作用域/可见性** |
| `const` | 保证变量或对象在初始化后不可修改；约束函数行为。 | **不变性** 和 **只读** |
| `constexpr` | 声明表达式为编译时常量，用于编译期计算。 | **编译时确定性** |

## 坑

- **类 static 成员必须类外定义**：只在类内声明 `static int count;` 不写 `int MyClass::count;` 会链接报错（undefined reference），只有 `static constexpr` 整型或 C++17 的 `inline static` 才能类内直接初始化。
- **static 局部变量的初始化是线程安全但有锁**：C++11 起 magic static 保证首次初始化线程安全，但首次进入会有一次性开销，且初始化期间其他线程阻塞，热路径里别放大对象构造。
- **`const int*` 和 `int* const` 看 const 在 `*` 哪一侧**：`const int* p` 指向的值不可改、指针可换；`int* const p` 指针不可换、值可改——读声明从右往左读，搞反就会写出编译不过的代码。
- **const 成员函数不是"承诺不修改对象"那么简单**：它内部 `this` 是 `const T*`，不能改普通成员，但可改 `mutable` 成员、可调非 const 的全局对象；把锁/计数器标 `mutable` 是惯例。
- **const 对象调非 const 函数直接编译错**：`const Point p; p.move();` 报错，反过来非常量对象优先调非 const 重载——重载决议时 const 是签名的一部分，写 API 时两个版本都要提供。
