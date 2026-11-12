# C++ 文件输入/输出 (I/O) 流笔记

> 类型：concept
> 一句话：C++ fstream 文件 IO


C++ 通过 `<fstream>` 头文件提供了一套强大的文件 I/O 功能。它主要基于三个类：

-   `ofstream`: output file stream，用于向文件写入数据。
-   `ifstream`: input file stream，用于从文件读取数据。
-   `fstream`: file stream，可以同时进行读写操作。

这些类都继承自 `iostream`，因此你可以像使用 `cout` 和 `cin` 一样使用 `<<` 和 `>>` 操作符。

---

## 1. 写入文件 (`ofstream`)

`ofstream` 用于创建文件并向其中写入信息。

### 关键步骤

1.  包含头文件 `<fstream>`。
2.  创建一个 `ofstream` 对象。
3.  使用 `open()` 方法或在构造函数中关联一个文件。
4.  检查文件是否成功打开（非常重要！）。
5.  使用流插入运算符 `<<` 写入数据。
6.  使用 `close()` 方法关闭文件。如果对象在栈上创建，当其离开作用域时，析构函数会自动关闭文件（RAII 原则）。

### 文件打开模式

-   `ios::out`: (默认) 写入模式，如果文件存在则清空内容。
-   `ios::app`: 追加模式，在文件末尾写入数据，不清空原有内容。
-   `ios::trunc`: (默认) 如果文件存在，先删除文件内容再写入。

### 示例代码

```cpp
#include <iostream>
#include <fstream>
#include <string>

void write_to_file_example() {
    // 1. 创建 ofstream 对象并打开文件 (默认覆盖)
    std::ofstream outFile("data.txt");

    // 2. 检查文件是否成功打开
    if (!outFile.is_open()) {
        std::cerr << "错误: 无法打开文件 data.txt 进行写入。" << std::endl;
        return;
    }

    // 3. 写入数据
    outFile << "你好, C++ 文件流!" << std::endl;
    outFile << 42 << std::endl;
    outFile << 3.14159 << std::endl;

    // 4. 关闭文件 (RAII 会自动处理，但也可以显式关闭)
    outFile.close();
    std::cout << "成功写入到 data.txt。" << std::endl;

    // 5. 以追加模式打开文件
    std::ofstream appendFile("data.txt", std::ios::app);
    if (!appendFile.is_open()) {
        std::cerr << "错误: 无法打开文件 data.txt 进行追加。" << std::endl;
        return;
    }
    appendFile << "这是追加的内容。" << std::endl;
    appendFile.close();
    std::cout << "成功追加内容到 data.txt。" << std::endl;
}
```

---

## 2. 读取文件 (`ifstream`)

`ifstream` 用于从文件中读取数据。

### 关键步骤

1.  创建一个 `ifstream` 对象并关联文件。
2.  检查文件是否成功打开。
3.  使用流提取运算符 `>>` 或 `getline()` 函数读取数据。
4.  关闭文件。

### 读取方式

-   **`>>` 操作符**: 逐字读取。按空白字符（包括空格、制表符或换行符）分隔来读取数据。
-   **`getline()` 函数**: 读取一整行，直到遇到换行符。
-   **逐字符读取**: `get()` 和 `get(char& c)`。



### 正确的文件读取循环

一个常见的误区是使用 `while (!inFile.eof())`。这是不正确的，因为 `eof` 标志在读取操作失败 *之后* 才会被设置。正确的做法是直接在循环条件中进行读取操作。

```cpp
// 正确的方式
while (inFile >> variable) {
    // 处理 variable
}

// 或者
while (std::getline(inFile, line)) {
    // 处理 line
}

//或者
char c;
while (inFile.get(c)) {
    // 处理 c
}

int i;
while(i = inFile.get())
{
    // 处理 i
}
```

### 示例代码

```cpp
#include <iostream>
#include <fstream>
#include <string>

void read_from_file_example() {
    std::ifstream inFile("data.txt");
    // 也可以延迟打开
    // std::ifstream inFile;
    // inFile.open("data.txt");

    // 读取之前检查是否成功打开
    if (!inFile.is_open()) {
        std::cerr << "错误: 无法打开文件 data.txt 进行读取。" << std::endl;
        return;
    }

    std::cout << "\n--- 使用 >> 读取 data.txt ---" << std::endl;
    std::string word;
    // 循环会因读取失败（如到达文件末尾）而终止
    while (inFile >> word) {
        std::cout << "读取到: " << word << std::endl;
    }

    // 清除流的状态标志 (如 eof) 并将读取位置重置到文件开头
    inFile.clear();
    inFile.seekg(0, std::ios::beg);

    std::cout << "\n--- 使用 getline 读取 data.txt ---" << std::endl;
    std::string line;
    while (std::getline(inFile, line)) {
        std::cout << "读取到行: " << line << std::endl;
    }

    inFile.close();
}
```

---

## 3. 读写文件 (`fstream`)

`fstream` 结合了 `ifstream` 和 `ofstream` 的功能，可以对同一个文件进行读写。你需要通过文件模式来指定意图。

### 文件打开模式

-   `ios::in`: (默认 `ifstream`) 读取模式。
-   `ios::out`: (默认 `ofstream`) 写入模式。
-   `ios::binary`: 二进制模式。

你可以使用 `|` (位或) 操作符来组合多个模式，例如 `std::ios::in | std::ios::out`。

### 文件指针

`fstream` 维护了两个文件指针：一个用于读 (`get` 指针)，一个用于写 (`put` 指针)。

-   `seekg()`: `seek get`，移动读指针。
-   `seekp()`: `seek put`，移动写指针。
-   `tellg()`: `tell get`，返回当前读指针的位置。
-   `tellp()`: `tell put`，返回当前写指针的位置。

### 示例代码

```cpp
#include <iostream>
#include <fstream>
#include <string>

void read_write_example() {
    // 以读写模式打开文件，如果文件不存在则创建
    std::fstream ioFile("user.txt", std::ios::in | std::ios::out | std::ios::trunc);

    if (!ioFile.is_open()) {
        std::cerr << "无法打开或创建 user.txt" << std::endl;
        return;
    }

    // 写入初始数据
    ioFile << "Username: guest" << std::endl;
    
    // 移动读指针到文件开头
    ioFile.seekg(0, std::ios::beg);

    std::string line;
    std::getline(ioFile, line);
    std::cout << "初始内容: " << line << std::endl;

    // 清除流状态，因为 getline 可能设置了 eof
    ioFile.clear();

    // 移动写指针到 'g' 字符之后的位置 (Username: )
    ioFile.seekp(10, std::ios::beg);
    ioFile << "admin"; // 覆盖 "guest"

    // 再次移动读指针到文件开头以验证
    ioFile.seekg(0, std::ios::beg);
    std::getline(ioFile, line);
    std::cout << "修改后内容: " << line << std::endl;

    ioFile.close();
}
```

---

## 4. 二进制文件

对于非文本数据（如图像、音频、或结构体/类的原始内存表示），应使用二进制模式。

-   **打开模式**: 包含 `ios::binary`。
-   **读写方法**: 使用 `read()` 和 `write()`。

`write()` 和 `read()` 方法操作的是字节块 (`char*`)。你需要进行类型转换。

### 示例代码

```cpp
#include <iostream>
#include <fstream>

struct Player {
    int id;
    char name[50];
    double score;
};

void binary_file_example() {
    Player p1 = {1, "Alice", 95.5};

    // 写入二进制文件
    std::ofstream outFile("player.dat", std::ios::binary);
    outFile.write(reinterpret_cast<const char*>(&p1), sizeof(Player));
    outFile.close();

    // 从二进制文件读取
    Player p2;
    std::ifstream inFile("player.dat", std::ios::binary);
    inFile.read(reinterpret_cast<char*>(&p2), sizeof(Player));
    inFile.close();

    std::cout << "从二进制文件读取的玩家信息:" << std::endl;
    std::cout << "ID: " << p2.id << ", 姓名: " << p2.name << ", 分数: " << p2.score << std::endl;
}
```

---

## 坑

- **二进制/文本模式混淆**：Windows 下文本模式写入的 `\n` 会被自动转成 `\r\n`，读写二进制数据（图像、结构体、自定义格式）时务必显式加 `std::ios::binary`，否则文件体积和字节数都不对。
- **打开失败不检查**：`ofstream f("path"); f << data;` 若路径不存在或权限不足，`f` 是失败状态但不会抛异常，后续写入静默丢失，务必用 `is_open()` 或 `!f` 检查。
- **依赖析构才 flush**：栈上流离开作用域才关闭并 flush，若程序崩溃（`abort`/段错误）缓冲区数据全丢；关键数据落盘用 `flush()` 或显式 `close()`。
- **`seekg` 后读缓存失效**：读写模式下 `seekg`/`seekp` 切换读写方向后必须调用 `clear()` 清除 eof/fail 标志，否则后续读写直接返回失败。
- **文本模式逐行读大文件慢**：对几百 MB 的日志逐字符 `get()` 或频繁 `getline()` 性能极差，应按 `std::ios::binary` 大块 `read` 到缓冲再处理。
