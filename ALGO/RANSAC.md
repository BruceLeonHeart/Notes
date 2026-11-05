# RANSAC 算法详解与 C++ 实现

RANSAC (Random Sample Consensus, 随机采样一致性) 是一种强大的迭代算法，用于从包含大量“局外点 (outliers)”的观测数据中，估计出数学模型的参数。它是一种非确定性算法，但能在有限的迭代次数内，以很高的概率找到一个合理的结果。

## 1. 什么是 RANSAC？

想象一下，你有一堆数据点，其中大部分点（“局内点, inliers”）都遵循某个模型（比如一条直线），但还有一部分点（“局外点, outliers”）是由于噪声、错误测量等原因产生的，完全偏离了这个模型。

如果你使用传统的最小二乘法等方法来拟合一条直线，那么那些离群的局外点会对结果产生巨大的影响，导致拟合出的直线偏离真实模型。

**RANSAC 的核心思想是**：假设数据中存在一个“正确”的模型，该模型由大多数局内点所决定。算法通过反复随机抽取数据中的一小部分子集（最小样本集），基于这个子集来估计模型，然后用所有数据来检验这个模型的好坏（即有多少点符合这个模型），并最终选择那个被最多数据点所支持的模型。

![RANSAC Illustration](https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/RANSAC_LINIE_Animiert.gif/300px-RANSAC_LINIE_Animiert.gif)

## 2. RANSAC 算法步骤

RANSAC 的流程可以概括为以下几个步骤：

1.  **随机采样 (Sample)**：从输入数据集中随机选择 `s` 个数据点，`s` 是计算模型参数所需的最少数据点数量。例如，拟合一条直线需要2个点，计算单应性矩阵需要4对点，计算本质矩阵需要8对点（使用8点法时）。

2.  **计算模型 (Compute)**：使用这 `s` 个点来计算出一个模型 `M` 的参数。

3.  **检验与计数 (Score)**：遍历数据集中的所有数据点，计算每个点与模型 `M` 之间的误差。如果误差小于一个预设的阈值 `t`，则该点被认为是“局内点 (inlier)”。统计所有局内点的数量。

4.  **评估与保存 (Evaluate)**：如果当前模型 `M` 的局内点数量超过了历史最佳模型的局内点数量，则将 `M` 保存为新的最佳模型，并更新最佳局内点数量。

5.  **迭代 (Iterate)**：重复以上步骤 1-4，直到达到预设的迭代次数 `k`。**或者**，如果当前找到的最佳模型的内点数量已经达到了一个预设的阈值 `d`（见下文），也可以提前终止迭代。

6.  **（可选）模型优化**：在迭代结束后，可以使用最佳模型对应的所有局内点，重新计算一次模型参数，以得到一个更精确、更鲁棒的模型。

## 3. RANSAC 关键参数

-   **最小样本数 `s`**：由所选模型决定，是固定的。
-   **距离阈值 `t`**：用于区分局内点和局外点，这个值的选择非常关键。太小会导致很多本应是局内点的点被误判，太大会导致模型对局外点过于宽松。图像匹配场景中通常取 1-3 像素的重投影误差，本质矩阵估计在归一化坐标下则取 1e-3 量级。
-   **迭代次数 `k`**：理论上，迭代次数越多，找到最优解的概率越高。`k` 的值可以根据一个概率公式来确定：
-   **最小内点数 `d` (可选)**：一个预设的阈值，代表一个“可接受”或“足够好”的模型所应拥有的最少内点数量。当 RANSAC 找到一个拥有超过 `d` 个内点的模型时，可以提前终止迭代，这是一种常见的性能优化策略。

    $$ k = \frac{\log(1 - p)}{\log(1 - w^s)} $$

    其中：
    -   `p`：希望算法成功的概率（例如 0.99）。
    -   `w`：数据集中局内点的比例（这是一个估计值，例如 0.5）。
    -   `s`：计算模型所需的最少点数。

### 关于提前终止的说明

在 RANSAC 算法中，除了达到最大迭代次数 `k`，我们通常还会设置一个“最小内点数量 `d`”作为提前终止的条件。这种做法的合理性在于：

1.  **效率与性能**：RANSAC 的理论迭代次数 `k` 在局外点比例较高时可能非常大。在实时应用中，我们无法承受如此大的计算开销。如果算法已经找到了一个被足够多的数据点（超过 `d` 个内点）支持的模型，我们就可以有信心地认为这个模型已经足够好，从而提前终止迭代，用一个可接受的结果换取巨大的性能提升。

2.  **置信度**：当一个模型能够拟合超过 `d` 个内点时，这个事件本身就是一个极低概率的事件（如果模型是错误的）。因此，我们可以认为这个模型已经很好地描述了数据的内在结构，继续迭代去寻找可能只多出几个内点的“绝对最佳”模型，其带来的精度提升往往微乎其微。

总而言之，**设置最小内点数 `d` 是一种在“最优解”和“计算效率”之间进行权衡的实用策略**。

### 优缺点

- **优点**：
  - 对离群点鲁棒性极强，可处理高达 50% 甚至更多的离群点；
  - 概念简单、通用性强，适用于各种模型拟合问题（直线/平面、单应矩阵、本质/基础矩阵等）。
- **缺点**：
  - 非确定性：随机采样导致每次运行结果略有差异；
  - 计算成本高：当最小样本数 `s` 较大或内点率 `w` 较低时，迭代次数 `k` 会非常大；
  - 参数敏感：阈值 `t` 和内点率 `w` 的估计对结果影响很大，通常需要经验或试错；
  - 不保证最优解，只保证以概率 `p` 找到可接受的解。

## 4. 应用：使用 RANSAC 求解本质矩阵 (Essential Matrix)

在计算机视觉中，一个经典的应用是利用匹配好的特征点对来估计两幅图像之间的相机运动，其中关键一步就是求解本质矩阵 `E`。

### 什么是本质矩阵？

本质矩阵 `E` 是一个 3x3 的矩阵，它描述了在**归一化图像坐标**下，左右两幅图像上对应点之间的几何关系。其数学表达式为：

$$ p_2^T E p_1 = 0 $$

其中，$p_1$ 和 $p_2$ 是左右两图上一对匹配好的特征点在各自相机坐标系下的归一化坐标（即 `p = K_inv * [u, v, 1]^T`，`K`是相机内参矩阵）。

### 8点算法简介

求解本质矩阵 `E` 最经典的方法是 **8点算法**。由于 `E` 是一个 3x3 矩阵，有9个未知数，但它具有尺度等价性，所以实际上有8个自由度。因此，理论上只需要8对匹配点就可以建立一个线性方程组 `Ah = 0` 来求解 `E` 的元素。

### 坐标归一化（Hartley 归一化）

直接在原始像素坐标上跑 8 点算法数值稳定性差（像素坐标量级大、质心远离原点）。**Hartley 归一化** 的做法是：先把点集平移到质心（原点），再缩放使各点到原点的平均距离为 `sqrt(2)`，跑完 8 点算法后用归一化矩阵的逆把结果变换回去。

```cpp
/**
 * @brief Hartley 归一化：平移到质心 + 缩放使平均距离为 sqrt(2)
 * @param points          输入图像点
 * @param normalized_points 输出归一化后的点
 * @param T               输出 3x3 归一化变换矩阵 p_norm = T * p_h
 */
void normalizePoints(const std::vector<cv::Point2f>& points,
                     std::vector<cv::Point2f>& normalized_points,
                     cv::Mat& T) {
    if (points.empty()) {
        T = cv::Mat::eye(3, 3, CV_64F);
        return;
    }

    // 1. 质心
    double centroid_x = 0, centroid_y = 0;
    for (const auto& p : points) { centroid_x += p.x; centroid_y += p.y; }
    centroid_x /= points.size();
    centroid_y /= points.size();

    // 2. 到质心的平均距离
    double avg_dist = 0.0;
    for (const auto& p : points) {
        avg_dist += std::sqrt((p.x - centroid_x) * (p.x - centroid_x) +
                              (p.y - centroid_y) * (p.y - centroid_y));
    }
    avg_dist /= points.size();

    // 3. 缩放因子：使平均距离等于 sqrt(2)
    double scale = std::sqrt(2.0) / avg_dist;

    // 4. 归一化矩阵：先平移(质心→原点)，再缩放
    T = (cv::Mat_<double>(3, 3) <<
         scale, 0, -scale * centroid_x,
         0, scale, -scale * centroid_y,
         0,     0,  1);

    // 5. 应用归一化
    normalized_points.clear();
    for (const auto& p : points) {
        normalized_points.push_back(cv::Point2f(scale * (p.x - centroid_x),
                                                scale * (p.y - centroid_y)));
    }
}
```

> 注意区分两种"归一化"：Hartley 归一化是为了改善 8 点法的数值稳定性；而用相机内参的逆 `K_inv` 把像素坐标变换到归一化相机坐标，是本质矩阵定义本身要求的物理归一化。下面的实现采用后者。

### RANSAC 流程

将 RANSAC 应用于求解本质矩阵的流程如下：

1.  **`s = 8`**：随机选择8对特征点。
2.  **计算模型**：使用这8对点，通过8点算法求解出本质矩阵 `E`。
3.  **检验与计数**：对于所有的特征点对 `(p1, p2)`，计算它们与模型 `E` 的误差。一个常用的误差度量是 **对称极线距离 (Symmetric Epipolar Distance)**。如果误差小于阈值 `t`，则该点对为局内点。
4.  **迭代**：重复以上过程，找到拥有最多局内点的本质矩阵 `E`。

## 5. C++ 实现：基于特征点对的 RANSAC 求解本质矩阵

以下是一个使用 C++ 和 OpenCV 库实现的 RANSAC 求解本质矩阵的示例。代码清晰地展示了 RANSAC 的核心循环，并自己实现了8点算法来求解模型。

**代码说明:**
-   **依赖**: 需要安装 OpenCV 库。
-   **核心函数**: `findEssentialMatRANSAC` 是 RANSAC 的主实现。
-   **模型计算**: 在循环内部，通过构建矩阵 `A` 并使用 SVD 分解来求解本质矩阵 `E`，这正是8点算法的实现。
-   **约束强制**: 求解出的 `E` 不一定满足本质矩阵的内在约束（两个奇异值相等，一个为0）。代码通过 SVD 分解并重构奇异值 `diag(1, 1, 0)` 来强制施加此约束。
-   **误差计算**: 使用对称极线距离作为误差度量。

```cpp
#include <iostream>
#include <vector>
#include <random>
#include <opencv2/core/core.hpp>
#include <opencv2/features2d/features2d.hpp>
#include <opencv2/calib3d/calib3d.hpp>

/**
 * @brief 使用RANSAC算法从特征点对中找到本质矩阵
 * 
 * @param pts1 图像1的特征点
 * @param pts2 图像2的特征点
 * @param K 相机内参矩阵
 * @param threshold RANSAC阈值，用于判断内外点
 * @param confidence RANSAC的置信度
 * @param max_iterations 最大迭代次数
 * @param inliers_mask 输出参数，标记哪些点是内点
 * @return cv::Mat 计算出的本质矩阵E
 */
cv::Mat findEssentialMatRANSAC(
    const std::vector<cv::Point2f>& pts1,
    const std::vector<cv::Point2f>& pts2,
    const cv::Mat& K,
    double threshold,
    double confidence,
    int max_iterations,
    std::vector<bool>& inliers_mask) {

    if (pts1.size() < 8) {
        return cv::Mat();
    }

    int num_points = pts1.size();
    cv::Mat K_inv = K.inv();

    // 将像素坐标转换为归一化相机坐标
    std::vector<cv::Point2f> norm_pts1, norm_pts2;
    for (int i = 0; i < num_points; ++i) {
        cv::Mat pt1_h = (cv::Mat_<double>(3, 1) << pts1[i].x, pts1[i].y, 1.0);
        cv::Mat norm_pt1_h = K_inv * pt1_h;
        norm_pts1.push_back(cv::Point2f(norm_pt1_h.at<double>(0), norm_pt1_h.at<double>(1)));

        cv::Mat pt2_h = (cv::Mat_<double>(3, 1) << pts2[i].x, pts2[i].y, 1.0);
        cv::Mat norm_pt2_h = K_inv * pt2_h;
        norm_pts2.push_back(cv::Point2f(norm_pt2_h.at<double>(0), norm_pt2_h.at<double>(1)));
    }

    int best_inliers_count = 0;
    cv::Mat best_E;
    inliers_mask.resize(num_points);

    // RANSAC 循环
    for (int iter = 0; iter < max_iterations; ++iter) {
        // 1. 随机采样8个点
        std::vector<int> random_indices(num_points);
        for(int i=0; i<num_points; ++i) random_indices[i] = i;
        std::random_shuffle(random_indices.begin(), random_indices.end());

        std::vector<cv::Point2f> sample_pts1, sample_pts2;
        for (int i = 0; i < 8; ++i) {
            sample_pts1.push_back(norm_pts1[random_indices[i]]);
            sample_pts2.push_back(norm_pts2[random_indices[i]]);
        }

        // 2. 计算模型 (8点算法)
        cv::Mat A(8, 9, CV_64F);
        for (int i = 0; i < 8; ++i) {
            double u1 = sample_pts1[i].x, v1 = sample_pts1[i].y;
            double u2 = sample_pts2[i].x, v2 = sample_pts2[i].y;
            A.at<double>(i, 0) = u2 * u1;
            A.at<double>(i, 1) = u2 * v1;
            A.at<double>(i, 2) = u2;
            A.at<double>(i, 3) = v2 * u1;
            A.at<double>(i, 4) = v2 * v1;
            A.at<double>(i, 5) = v2;
            A.at<double>(i, 6) = u1;
            A.at<double>(i, 7) = v1;
            A.at<double>(i, 8) = 1.0;
        }

        cv::Mat u, w, vt;
        cv::SVD::compute(A, w, u, vt, cv::SVD::FULL_UV);
        cv::Mat E_est = vt.row(8).reshape(1, 3); // E的估计值是V的最后一行

        // 强制E的约束：奇异值为[1, 1, 0]
        cv::SVD::compute(E_est, w, u, vt, cv::SVD::FULL_UV);
        cv::Mat W = (cv::Mat_<double>(3, 3) << 1, 0, 0, 0, 1, 0, 0, 0, 0);
        cv::Mat E = u * W * vt;

        // 3. 检验与计数
        int current_inliers_count = 0;
        std::vector<bool> current_inliers_mask(num_points);
        for (int i = 0; i < num_points; ++i) {
            cv::Mat p1 = (cv::Mat_<double>(3, 1) << norm_pts1[i].x, norm_pts1[i].y, 1.0);
            cv::Mat p2 = (cv::Mat_<double>(3, 1) << norm_pts2[i].x, norm_pts2[i].y, 1.0);

            // 计算对称极线距离
            cv::Mat epipolar_line1 = E * p1;
            cv::Mat epipolar_line2 = E.t() * p2;

            double dist1 = std::abs(p2.dot(epipolar_line1)) / std::sqrt(pow(epipolar_line1.at<double>(0), 2) + pow(epipolar_line1.at<double>(1), 2));
            double dist2 = std::abs(p1.dot(epipolar_line2)) / std::sqrt(pow(epipolar_line2.at<double>(0), 2) + pow(epipolar_line2.at<double>(1), 2));
            
            double error = (dist1 + dist2) / 2.0;

            if (error < threshold) {
                current_inliers_count++;
                current_inliers_mask[i] = true;
            } else {
                current_inliers_mask[i] = false;
            }
        }

        // 4. 评估与保存
        if (current_inliers_count > best_inliers_count) {
            best_inliers_count = current_inliers_count;
            best_E = E.clone();
            inliers_mask = current_inliers_mask;
        }
    }

    std::cout << "RANSAC found " << best_inliers_count << " inliers." << std::endl;

    // (可选) 6. 使用所有内点重新计算模型
    if (best_inliers_count > 8) {
        std::vector<cv::Point2f> inlier_pts1, inlier_pts2;
        for(int i=0; i<num_points; ++i) {
            if(inliers_mask[i]) {
                inlier_pts1.push_back(norm_pts1[i]);
                inlier_pts2.push_back(norm_pts2[i]);
            }
        }
        // OpenCV的findEssentialMat本身就是用RANSAC和8点法，这里为了演示，我们只返回RANSAC循环的结果
        // 在实际项目中，可以用 cv::findEssentialMat(inlier_pts1, inlier_pts2, 1.0, cv::Point2d(0,0), cv::RANSAC, 0.999, 1.0);
        // 来进行最后的优化。
    }

    return best_E;
}

int main() {
    // 示例用法
    // 1. 假设我们有两组匹配好的特征点 pts1 和 pts2
    // 2. 假设我们有相机内参矩阵 K

    // 伪造一些数据用于演示
    cv::Mat K = (cv::Mat_<double>(3, 3) << 520.9, 0, 325.1, 0, 521.0, 249.7, 0, 0, 1);
    std::vector<cv::Point2f> pts1, pts2;
    // ... 在这里填充真实的特征点数据 ...
    // 至少需要8对点，并且包含局外点
    // 这里仅为演示，填充一些随机点
    for(int i=0; i<100; ++i) {
        pts1.push_back(cv::Point2f(rand() % 640, rand() % 480));
        pts2.push_back(cv::Point2f(rand() % 640, rand() % 480));
    }

    if (pts1.size() < 8) {
        std::cerr << "Not enough points to run the algorithm." << std::endl;
        return -1;
    }

    std::vector<bool> inliers_mask;
    double ransac_threshold = 0.001; // 归一化坐标下的阈值，需要仔细调整
    double confidence = 0.99;
    int max_iterations = 500;

    cv::Mat E = findEssentialMatRANSAC(pts1, pts2, K, ransac_threshold, confidence, max_iterations, inliers_mask);

    if (!E.empty()) {
        std::cout << "Essential Matrix found:\n" << E << std::endl;
    } else {
        std::cout << "Could not find Essential Matrix." << std::endl;
    }

    return 0;
}
```

## 6. 编译与运行

依赖 OpenCV。编译命令（注意反引号包裹 pkg-config）：

```bash
# OpenCV 4.x
g++ ransac_essential.cpp -o ransac_essential `pkg-config opencv4 --cflags --libs`

# OpenCV 3.x
g++ ransac_essential.cpp -o ransac_essential `pkg-config opencv --cflags --libs`

# 运行
./ransac_essential
```

Windows / MinGW 下需手动指定头文件与库路径：

```bash
g++ ransac_essential.cpp -o ransac_essential.exe \
    -I"C:\path\to\opencv\build\include" \
    -L"C:\path\to\opencv\build\x64\vc15\lib" \
    -lopencv_core455 -lopencv_imgproc455 -lopencv_calib3d455 -lopencv_features2d455
# 库文件名按实际 OpenCV 版本调整，通常只需 core / imgproc / calib3d / features2d
```

实际项目中可直接用 OpenCV 封装好的 `cv::findEssentialMat(..., cv::RANSAC, ...)`，内部已实现 RANSAC；自己实现一版是为了理解其核心循环。

## 7. 总结

RANSAC 是一个非常实用且效果显著的算法，广泛应用于计算机视觉的各种参数估计问题中，如直线/平面拟合、单应性/本质/基础矩阵估计等。它的核心优势在于对大量局外点的鲁棒性。理解其思想并掌握其在具体问题中的应用，是进行相关领域开发的重要技能。
