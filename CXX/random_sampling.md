# C++ 随机数与随机取样详解

> 类型：concept
> 一句话：C++ <random> 库


在 C++ 中进行随机操作时，强烈推荐使用 C++11 引入的 `<random>` 库，因为它提供了比传统 C 风格的 `rand()` 函数更高质量、更灵活、更安全的随机数生成方案。

## 1. 为什么不推荐使用 `rand()`？

在学习 C++ 早期，我们可能都用过 `srand()` 和 `rand()`。但它们存在一些严重问题：

-   **低质量的随机性**：很多编译器的 `rand()` 实现采用简单的线性同余法，生成的随机数序列在某些情况下可能表现出明显的模式，不适合用于需要高质量随机数的场景（如加密、科学模拟）。
-   **全局状态**：`rand()` 依赖一个全局的种子，这在多线程环境下会导致数据竞争，需要手动加锁保护，非常不便。
-   **范围不便**：`rand()` 生成 `0` 到 `RAND_MAX` 之间的数，要映射到特定范围（如 `[a, b]`）通常使用取模运算 `rand() % N`，但这会导致分布不均（除非 `RAND_MAX + 1` 是 `N` 的整数倍）。

```c
#include <iostream>
#include <cstdlib> // 包含 rand(), srand()
#include <ctime>   // 包含 time()

int main() {
    // 使用当前时间作为种子，只播种一次！
    // 如果在短时间内多次调用 srand()，可能会得到相同的序列。
    srand(static_cast<unsigned int>(time(nullptr)));

    // 生成 [0, RAND_MAX] 范围内的随机数
    int random_num = rand();
    std::cout << "旧方法随机数: " << random_num << std::endl;

    // 转换为 [1, 100] 范围
    int random_1_100 = (rand() % 100) + 1;
    std::cout << "旧方法随机数 (1-100): " << random_1_100 << std::endl;

    return 0;
}
```

## 2. 现代 C++ 的随机数生成：`<random>` 库

`<random>` 库将随机数生成过程解耦为两个核心部分：

1.  **随机数引擎 (Engines)**：一个对象，能够生成均匀分布的伪随机整数序列。它像一个“随机数源”。
    -   **推荐使用**：`std::mt19937` (马特森旋转算法)，它拥有非常长的周期和高质量的随机性，是绝大多数场景下的首选。

2.  **分布 (Distributions)**：一个对象，它接收来自引擎的随机数，并将其映射到特定的统计分布和数值范围内。
    -   `std::uniform_int_distribution<T>(a, b)`：生成 `[a, b]` 范围内的均匀分布整数。
    -   `std::uniform_real_distribution<T>(a, b)`：生成 `[a, b)` 范围内的均匀分布浮点数。
    -   `std::normal_distribution<T>(mean, stddev)`：生成符合正态（高斯）分布的浮点数。

### 如何使用

标准用法分为三步：

1.  **创建并播种引擎**：使用 `std::random_device` 作为高质量的随机数种子来初始化引擎。`std::random_device` 会尝试从硬件获取真正的随机性。
2.  **创建分布对象**：定义你想要的分布类型和范围。
3.  **生成随机数**：将引擎作为参数传递给分布对象。

```cpp
#include <iostream>
#include <random>
#include <vector>

void basic_random_example() {
    // 1. 创建并播种引擎
    std::random_device rd;  // 获取一个随机数种子
    std::mt19937 gen(rd()); // 使用 rd 来初始化马特森旋转算法引擎

    // 2. 创建分布对象
    std::uniform_int_distribution<> distrib(1, 6); // 生成 [1, 6] 范围内的整数

    // 3. 生成随机数
    std::cout << "Rolling a dice 5 times: ";
    for (int i = 0; i < 5; ++i) {
        std::cout << distrib(gen) << " "; // 将引擎传入分布对象
    }
    std::cout << std::endl;
}
```

---

## 3. 核心任务：从集合中进行随机取样

假设我们有一个集合 `std::vector<int> data`，我们想从中无放回地随机抽取 `k` 个元素。

### 方法一：使用 `std::shuffle` (C++11 及以上)

**原理**：
这是最经典的方法之一。创建一个包含原始数据索引的向量，然后使用 `std::shuffle` 彻底打乱这个索引向量，最后取前 `k` 个索引对应的元素即可。

**C++ 代码示例**：
```cpp
#include <iostream>
#include <vector>
#include <random>
#include <numeric>   // for std::iota
#include <algorithm> // for std::shuffle

void sample_with_shuffle(const std::vector<int>& data, int k) {
    if (k > data.size()) return;

    std::vector<int> indices(data.size());
    std::iota(indices.begin(), indices.end(), 0); // 填充索引 0, 1, 2, ...

    std::random_device rd;
    std::mt19937 gen(rd());

    std::shuffle(indices.begin(), indices.end(), gen); // 使用高质量引擎打乱索引

    std::cout << "Sampling " << k << " elements using shuffle: ";
    for (int i = 0; i < k; ++i) {
        std::cout << data[indices[i]] << " ";
    }
    std::cout << std::endl;
}
```

### 方法二：使用 `std::sample` (C++17 及以上) - **推荐**

**原理**：
C++17 标准直接提供了一个名为 `std::sample` 的算法，专门用于随机取样。它高效、简洁，是目前解决该问题的最佳方案。

**C++ 代码示例**：
```cpp
#include <iostream>
#include <vector>
#include <random>
#include <algorithm> // for std::sample
#include <iterator>  // for std::ostream_iterator

void sample_with_std_sample(const std::vector<int>& data, int k) {
    if (k > data.size()) return;

    std::vector<int> result;
    result.reserve(k);

    std::random_device rd;
    std::mt19937 gen(rd());

    std::sample(data.begin(), data.end(), std::back_inserter(result), k, gen);

    std::cout << "Sampling " << k << " elements using std::sample (C++17): ";
    for (const auto& val : result) {
        std::cout << val << " ";
    }
    std::cout << std::endl;
}
```

### 方法三：蓄水池抽样 (Reservoir Sampling) - 适用于大数据流

**原理**：
当数据集非常大，无法一次性加载到内存中，或者数据集是一个持续输入的流（长度未知）时，蓄水池抽样是理想的选择。它只需要对数据进行一次遍历。

1.  将数据流的前 `k` 个元素放入一个“蓄水池”（结果容器）。
2.  对于从第 `k+1` 个元素开始的每一个元素 `i`：
3.  生成一个 `[0, i-1]` 范围内的随机整数 `j`。
4.  如果 `j < k`，则用当前元素 `i` 替换蓄水池中第 `j` 个位置的元素。
5.  继续处理下一个元素，直到数据流结束。

**C++ 代码示例**：
```cpp
#include <iostream>
#include <vector>
#include <random>

void reservoir_sampling(const std::vector<int>& data, int k) {
    if (k <= 0 || data.empty()) return;
    
    std::vector<int> reservoir;
    reservoir.reserve(k);

    std::random_device rd;
    std::mt19937 gen(rd());

    for (int i = 0; i < data.size(); ++i) {
        if (i < k) {
            reservoir.push_back(data[i]);
        } else {
            std::uniform_int_distribution<> distrib(0, i);
            int j = distrib(gen);
            if (j < k) {
                reservoir[j] = data[i];
            }
        }
    }

    std::cout << "Sampling " << k << " elements using Reservoir Sampling: ";
    for (const auto& val : reservoir) {
        std::cout << val << " ";
    }
    std::cout << std::endl;
}
```
