# Day 19：SVD分解——应用场景

> SVD是工程师的瑞士军刀，几乎所有线性代数难题绕不开SVD。

---

## 应用1：图像压缩
把大矩阵（图像）用前k个大的奇异值近似，丢弃后面小的奇异值，就实现了低秩近似。图像保留了大部分能量，但数据量大幅减少。

## 应用2：伪逆
正规方程 AᵀA 不可逆怎么办？用SVD直接求伪逆 A⁺ = V Σ⁺ Uᵀ，σ非零部分取倒数。伪逆是最小二乘问题的通解。

## 应用3：本质矩阵分解
SLAM对极几何求出本质矩阵E之后，用SVD分解，从U和V中提取出旋转R和平移t，恢复相机运动。这是视觉SLAM单目初始化的标准步骤。

```python
import numpy as np
A = np.random.randn(5, 3)
U, s, Vt = np.linalg.svd(A)
print("U形状:", U.shape)
print("奇异值:", s)
print("Vt形状:", Vt.shape)
```
