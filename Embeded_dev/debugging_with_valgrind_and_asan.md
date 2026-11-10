> 类型：howto
> 一句话：valgrind / ASan 内存调试

## 如何使用 Valgrind / AddressSanitizer (ASan) 来分析是否存在 内存泄漏、越界访问和野指针

在 C++ 开发中，**AddressSanitizer (ASan)** 和 **Valgrind** 是排查内存问题的两大神器。现代 C++ 开发通常优先使用 ASan（集成在编译器中，速度快），而在无法重新编译代码或需要深度排查未初始化变量时使用 Valgrind。

无论使用哪种工具，**编译时必须加上 `-g` 选项**以保留调试信息，否则报错信息只会显示内存地址，无法定位到具体的代码行数。

### 1. AddressSanitizer (ASan) 现代排查方案

ASan 是由 Google 开发的编译器插件，已被内置于 GCC 和 Clang 中。它的原理是在编译时向内存分配和访问指令周围插入“红区（Redzones）”检测代码。

**如何启用：**
在编译时添加 `-fsanitize=address` 即可启用。

```bash
g++ -O1 -g -fsanitize=address -fno-omit-frame-pointer my_program.cpp -o my_program
./my_program

```

*(注：`-fno-omit-frame-pointer` 用于获取更完美的调用栈。)*

**错误特征与分析：**

* **越界访问 (Out-of-bounds)：**
如果你写了 `int* arr = new int[5]; arr[5] = 10;`，程序会立刻崩溃，终端输出红色的报错提示：
`ERROR: AddressSanitizer: heap-buffer-overflow on address 0x...`
向下看调用栈，ASan 会精准指出：`WRITE of size 4 at 0x... thread T0`，并附带具体的文件名和行号。
* **野指针/悬空指针 (Use-after-free)：**
如果你对已经 `delete` 的指针再次解引用，报错特征为：
`ERROR: AddressSanitizer: heap-use-after-free on address 0x...`
ASan 的强大之处在于，它不仅会告诉你**哪里发生了非法访问**，还会打印出这块内存**最初是在哪里分配的**，以及**是在哪里被释放的**。
* **内存泄漏 (Memory Leak)：**
程序正常运行结束退出时，如果存在未释放的内存，ASan 包含的 LeakSanitizer 会自动输出：
`ERROR: LeakSanitizer: detected memory leaks`
`Direct leak of 40 byte(s) in 1 object(s) allocated from...`

---

### 2. Valgrind (Memcheck) 传统深度排查方案

Valgrind 是一个动态二进制插桩框架。它不需要修改编译选项（除了 `-g`），它会像虚拟机一样接管你的程序并在 CPU 指令级别进行监控。

**如何运行：**
不需要加 `-fsanitize` 编译，直接用普通方式编译后，用 valgrind 启动程序：

```bash
g++ -g my_program.cpp -o my_program
valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes ./my_program

```

**错误特征与分析：**

* **越界访问与野指针：**
Valgrind 统称这类问题为“非法读写”。报错特征为：
`Invalid write of size 4`（越界写或写了已释放的内存）
`Invalid read of size 4`（越界读或读了已释放的内存）
下方会跟随具体的代码行号。如果启用了 `--track-origins=yes`，它还能追溯未初始化变量的来源。
* **内存泄漏：**
Valgrind 会在程序结束时输出一份 `HEAP SUMMARY`，重点关注以下两种泄漏：
* **`definitely lost`（确定泄漏）**：内存没有被释放，且没有任何指针指向这块内存（彻底找不到了）。**必须修复**。
* **`indirectly lost`（间接泄漏）**：通常是因为包含指针的结构体/类本身泄漏了，导致其内部指向的内存也泄漏了。修复外层结构的泄漏，内层通常会随之解决。


* **未初始化内存使用 (Uninitialized values)：**
这是 Valgrind 的强项，报错特征为：
`Conditional jump or move depends on uninitialised value(s)`
通常是因为使用了一个没有赋初值的变量进行了 `if` 判断或数组索引。

---

### 工具对比与选型建议

| 维度 | AddressSanitizer (ASan) | Valgrind (Memcheck) |
| --- | --- | --- |
| **性能影响** | **小**（程序变慢约 2 倍），适合跑大型项目和测试用例 | **极大**（程序变慢 10~50 倍），大型程序可能跑到超时 |
| **内存开销** | 高（需要大量额外内存来维护红区） | 较高，但比 ASan 稍好 |
| **编译要求** | **必须重新编译**代码 | **无需重新编译**，直接运行二进制文件 |
| **检测强项** | 越界访问、Use-after-free、栈内存越界 | 未初始化的内存读取 (`Uninitialized value`) |
| **多线程支持** | 自带 ThreadSanitizer (`-fsanitize=thread`) 排查数据竞争 | 支持较弱，主要是 Helgrind 工具，速度极慢 |

**最佳实践**：
日常开发和持续集成（CI）环境中，默认开启 **ASan**。当遇到某些极其诡异的未初始化值引发的 Bug，或者拿到了一个无法获取源码、无法重新编译的第三方动态库发生崩溃时，再掏出 **Valgrind** 进行深度扫描。**注意：这两种工具原理互斥，绝对不能同时开启使用。**
