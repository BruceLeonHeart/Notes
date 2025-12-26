RANSAC (RANdom SAmple Consensus) 是一种迭代算法，用于从包含大量离群点（outliers）的数据集中估计数学模型的参数。它通过随机抽样和验证来找到一个能够最好地拟合大多数数据点的模型。

 RANSAC 算法的详细解读

 1. 为什么需要 RANSAC？

在计算机视觉、图像处理等领域，我们经常需要从观测数据中估计几何模型（如直线、平面、单应矩阵、基础矩阵、本质矩阵等）。这些观测数据通常来自特征点匹配，而特征匹配的结果往往包含大量的错误匹配（离群点）。传统的最小二乘法等方法对离群点非常敏感，一个或几个离群点就可能导致模型估计结果严重偏离真实值。RANSAC 算法的出现就是为了解决这个问题，它能够鲁棒地从包含离群点的数据中估计模型。

 2. 核心思想

RANSAC 的核心思想是：
   假设： 数据集中存在一定比例的“内点”（inliers），它们能够通过某个数学模型很好地描述，并且这些内点受到高斯噪声的影响。
   离群点： 数据集中还存在“离群点”，它们不符合这个模型，可能是由于严重的测量误差或错误匹配。
   迭代： 算法通过不断随机选择数据子集来估计模型，并评估该模型对所有数据的拟合程度。

 3. 算法步骤

RANSAC 算法通常包含以下步骤：

1.  参数设定：
       s：拟合模型所需的最小数据点数量。例如，拟合一条直线需要 2 个点，拟合本质矩阵需要 8 个点。
       k：最大迭代次数。算法将重复 k 次随机采样和模型评估。
       t：内点阈值。一个数据点到估计模型的距离小于 t，则被认为是内点。
       d：最小内点数量。如果一个模型拥有至少 d 个内点，则认为这个模型是“好的”。

2.  迭代过程 (重复 k 次)：
    a.  随机采样： 从原始数据集中随机选择 s 个数据点。这些点被认为是潜在的内点。
    b.  模型拟合： 使用这 s 个点来拟合一个模型。
    c.  内点计数 (共识集)： 对于数据集中的所有数据点，计算它们到当前拟合模型的距离。如果距离小于阈值 t，则将该点归类为内点。统计内点的总数量，形成一个“共识集”。
    d.  最佳模型更新： 如果当前模型的内点数量超过了迄今为止发现的最佳模型的内点数量，则更新最佳模型。同时，如果当前内点数量达到或超过 d，也可以认为这是一个可接受的模型。

3.  模型优化 (可选但推荐)：
    在 k 次迭代结束后，选择拥有最多内点的那个模型作为“最佳模型”。然后，使用这个最佳模型所对应的所有内点（即最终的共识集）来重新拟合模型。这一步通常会使用更精确的优化方法（如最小二乘法），因为此时数据集中已经排除了大部分离群点，可以获得更准确的模型参数。

 4. 参数选择

   s (最小点数)： 由模型类型决定。
   t (内点阈值)：
       取决于数据的噪声水平。
       通常通过经验值设定，例如在图像匹配中，可以设置为 1-3 像素的误差。
       过小可能导致没有足够的内点，过大可能将离群点误判为内点。
   k (迭代次数)：
       可以通过以下公式计算：k = log(1 - p) / log(1 - w^s)
           p：期望算法成功的概率（例如 0.99，表示 99% 的置信度能找到正确模型）。
           w：数据集中内点的比例（内点率）。这是最难估计的参数，通常需要预估或通过多次运行来调整。
           s：拟合模型所需的最小点数。
       如果 w 很小（离群点很多），k 需要非常大。
   d (最小内点数量)： 通常设置为 w  N，其中 N 是总数据点数。

 5. 优缺点

   优点：
       对离群点具有极强的鲁棒性，可以处理高达 50% 甚至更多的离群点。
       概念简单，易于实现。
       通用性强，适用于各种模型拟合问题。
   缺点：
       非确定性：由于随机采样，每次运行结果可能略有不同。
       计算成本高：当 s 较大或内点率 w 较低时，迭代次数 k 会非常大。
       参数调优：t 和 w 的选择对算法性能影响很大，通常需要经验或试错。
       无法保证找到最优解，只保证以 p 的概率找到一个可接受的解。

 基于特征点对的 RANSAC 求解本质矩阵的 C++ 实现

本质矩阵 (Essential Matrix) E 描述了两幅图像中对应点之间的几何关系，它与相机的旋转 R 和平移 t 有关。它满足 x_2^T E x_1 = 0，其中 x_1 和 x_2 是归一化图像坐标系下的对应点（齐次坐标）。

实现细节：
   8 点算法： 求解本质矩阵需要至少 8 对对应点。
   归一化： 在 8 点算法之前，对图像坐标进行归一化（将坐标原点移到图像中心，并缩放使平均距离为 sqrt(2)），可以提高数值稳定性。
   本质矩阵约束： 8 点算法得到的矩阵可能不满足本质矩阵的内部约束（两个奇异值相等，一个为零）。需要通过 SVD 对其进行校正。
   距离度量： 通常使用对称对极距离 (Symmetric Epipolar Distance) 来衡量点到对极线的距离。

我们将使用 OpenCV 库来处理矩阵运算、点结构和 SVD，但会手动实现 8 点算法和距离计算，以展示 RANSAC 的核心逻辑。

cpp
include <iostreaminclude <vectorinclude <randominclude <numeric// For iota
include <algorithm// For shuffle, max_element

// 引入 OpenCV 库
include <opencv2/opencv.hppinclude <opencv2/core/eigen.hpp// For converting OpenCV Mat to Eigen (optional, but good for some math)

// 定义一些常量
const int MIN_POINTS_FOR_ESSENTIAL = 8; // 8点算法
const double DEFAULT_RANSAC_THRESHOLD = 1.0; // 默认内点阈值 (像素误差)
const int MAX_RANSAC_ITERATIONS = 1000; // 最大RANSAC迭代次数

/
  @brief 对图像点进行归一化
         将点集平移到中心，并缩放使平均距离为 sqrt(2)
  @param points 输入的图像点
  @param normalized_points 归一化后的点
  @param T 归一化变换矩阵
 /
void normalizePoints(const std::vector<cv::Point2f& points,
                     std::vector<cv::Point2f& normalized_points,
                     cv::Mat& T) {
    if (points.empty()) {
        normalized_points.clear();
        T = cv::Mat::eye(3, 3, CV_64F);
        return;
    }

    // 1. 计算质心
    cv::Scalar sum_x = cv::sum(cv::Mat(points).col(0));
    cv::Scalar sum_y = cv::sum(cv::Mat(points).col(1));
    double centroid_x = sum_x[0] / points.size();
    double centroid_y = sum_y[0] / points.size();

    // 2. 计算平均距离
    double avg_dist = 0.0;
    normalized_points.resize(points.size());
    for (size_t i = 0; i < points.size(); ++i) {
        normalized_points[i].x = points[i].x - centroid_x;
        normalized_points[i].y = points[i].y - centroid_y;
        avg_dist += std::sqrt(normalized_points[i].x  normalized_points[i].x +
                              normalized_points[i].y  normalized_points[i].y);
    }
    avg_dist /= points.size();

    // 3. 计算缩放因子
    double scale = std::sqrt(2.0) / avg_dist;

    // 4. 构建归一化变换矩阵 T
    T = (cv::Mat_<double(3, 3) <<
         scale, 0, -scale  centroid_x,
         0, scale, -scale  centroid_y,
         0, 0, 1);

    // 5. 应用归一化
    for (size_t i = 0; i < points.size(); ++i) {
        normalized_points[i].x = scale;
        normalized_points[i].y = scale;
    }
}

/
  @brief 使用8点算法计算本质矩阵
         pts1_norm 和 pts2_norm 必须是归一化后的点
  @param pts1_norm 归一化后的第一幅图像点 (至少8个)
  @param pts2_norm 归一化后的第二幅图像点 (至少8个)
  @return 计算得到的本质矩阵 E
 /
cv::Mat computeEssentialMatrix8Point(const std::vector<cv::Point2f& pts1_norm,
                                     const std::vector<cv::Point2f& pts2_norm) {
    if (pts1_norm.size() < MIN_POINTS_FOR_ESSENTIAL || pts2_norm.size() < MIN_POINTS_FOR_ESSENTIAL ||
        pts1_norm.size() != pts2_norm.size()) {
        return cv::Mat(); // 返回空矩阵表示失败
    }

    // 构建 A 矩阵 (Nx9)，其中 N 是点对数量
    // 对于每对点 (u1, v1, 1) 和 (u2, v2, 1)，有方程 u2u1e1 + u2v1e2 + u2e3 + v2u1e4 + v2v1e5 + v2e6 + u1e7 + v1e8 + e9 = 0
    cv::Mat A(pts1_norm.size(), 9, CV_64F);
    for (size_t i = 0; i < pts1_norm.size(); ++i) {
        double u1 = pts1_norm[i].x;
        double v1 = pts1_norm[i].y;
        double u2 = pts2_norm[i].x;
        double v2 = pts2_norm[i].y;

        A.at<double(i, 0) = u2  u1;
        A.at<double(i, 1) = u2  v1;
        A.at<double(i, 2) = u2;
        A.at<double(i, 3) = v2  u1;
        A.at<double(i, 4) = v2  v1;
        A.at<double(i, 5) = v2;
        A.at<double(i, 6) = u1;
        A.at<double(i, 7) = v1;
        A.at<double(i, 8) = 1;
    }

    // 对 A 进行 SVD 分解，A = U  S  V^T
    cv::Mat U, S, Vt;
    cv::SVDecomp(A, S, U, Vt, cv::SVD::FULL_UV);

    // E 是 V 的最后一列（对应最小奇异值）
    cv::Mat E_vec = Vt.row(8).t(); // 9x1 向量
    cv::Mat E = E_vec.reshape(1, 3); // 重塑为 3x3 矩阵

    // 强制 E 满足本质矩阵的约束 (两个奇异值相等，一个为零)
    // 对 E 进行 SVD 分解 E = U_E  S_E  V_E^T
    cv::Mat U_E, S_E, Vt_E;
    cv::SVDecomp(E, S_E, U_E, Vt_E, cv::SVD::FULL_UV);

    // 修正奇异值：s1 = s2 = (s1+s2)/2, s3 = 0
    S_E.at<double(0, 0) = (S_E.at<double(0, 0) + S_E.at<double(1, 0)) / 2.0;
    S_E.at<double(1, 0) = S_E.at<double(0, 0);
    S_E.at<double(2, 0) = 0.0;

    // 重构 E = U_E  diag(S_E)  V_E^T
    cv::Mat S_E_diag = cv::Mat::diag(S_E);
    E = U_E  S_E_diag  Vt_E;

    return E;
}

/
  @brief 计算对称对极距离
         距离越小，点对越符合本质矩阵
  @param p1_norm 归一化后的第一幅图像点
  @param p2_norm 归一化后的第二幅图像点
  @param E 本质矩阵
  @return 对称对极距离
 /
double computeSymmetricEpipolarDistance(const cv::Point2f& p1_norm,
                                        const cv::Point2f& p2_norm,
                                        const cv::Mat& E) {
    // 将点转换为齐次坐标
    cv::Mat x1 = (cv::Mat_<double(3, 1) << p1_norm.x, p1_norm.y, 1.0);
    cv::Mat x2 = (cv::Mat_<double(3, 1) << p2_norm.x, p2_norm.y, 1.0);

    // 计算对极线 l2 = E  x1
    cv::Mat l2 = E  x1;
    // 计算对极线 l1 = E^T  x2
    cv::Mat l1 = E.t()  x2;

    // 检查 l1 和 l2 是否有效
    if (l1.at<double(0,0) == 0 && l1.at<double(1,0) == 0 ||
        l2.at<double(0,0) == 0 && l2.at<double(1,0) == 0) {
        return std::numeric_limits<double::max(); // 避免除以零
    }

    // 点到对极线的距离 d = |ax + by + c| / sqrt(a^2 + b^2)
    double num = x2.at<double(0,0)  l2.at<double(0,0) +
                 x2.at<double(1,0)  l2.at<double(1,0) +
                 x2.at<double(2,0)  l2.at<double(2,0); // x2^T  E  x1

    double den1 = l2.at<double(0,0)  l2.at<double(0,0) +
                  l2.at<double(1,0)  l2.at<double(1,0); // a^2 + b^2 for l2

    double den2 = l1.at<double(0,0)  l1.at<double(0,0) +
                  l1.at<double(1,0)  l1.at<double(1,0); // a^2 + b^2 for l1

    if (den1 < 1e-10 || den2 < 1e-10) { // 避免除以接近零的数
        return std::numeric_limits<double::max();
    }

    double dist = (num  num)  (1.0 / den1 + 1.0 / den2); // (d^2 / (a^2+b^2))  (1/den1 + 1/den2)
    return std::sqrt(dist);
}


/
  @brief RANSAC 算法求解本质矩阵
  @param pts1 第一幅图像的特征点
  @param pts2 第二幅图像的特征点
  @param K1 第一幅图像的内参矩阵
  @param K2 第二幅图像的内参矩阵
  @param best_E 输出：最佳本质矩阵
  @param inlier_indices 输出：内点索引
  @param threshold 内点阈值 (像素误差)
  @param iterations 最大RANSAC迭代次数
  @return 找到的内点数量
 /
int ransacEssentialMatrix(const std::vector<cv::Point2f& pts1,
                          const std::vector<cv::Point2f& pts2,
                          const cv::Mat& K1,
                          const cv::Mat& K2,
                          cv::Mat& best_E,
                          std::vector<int& inlier_indices,
                          double threshold = DEFAULT_RANSAC_THRESHOLD,
                          int iterations = MAX_RANSAC_ITERATIONS) {
    if (pts1.size() != pts2.size() || pts1.size() < MIN_POINTS_FOR_ESSENTIAL) {
        std::cerr << "Error: Not enough corresponding points for RANSAC." << std::endl;
        return 0;
    }

    int num_points = pts1.size();
    int best_inlier_count = 0;
    best_E = cv::Mat(); // 初始化为空

    std::random_device rd;
    std::mt19937 gen(rd()); // 随机数生成器
    std::vector<intall_indices(num_points);
    std::iota(all_indices.begin(), all_indices.end(), 0); // 填充 0, 1, 2, ..., num_points-1

    // 归一化相机内参矩阵的逆
    cv::Mat K1_inv = K1.inv();
    cv::Mat K2_inv = K2.inv();

    for (int iter = 0; iter < iterations; ++iter) {
        // 1. 随机采样 s 个点
        std::shuffle(all_indices.begin(), all_indices.end(), gen); // 随机打乱索引
        std::vector<cv::Point2fsample_pts1_img, sample_pts2_img;
        std::vector<cv::Point2fsample_pts1_norm, sample_pts2_norm;

        for (int i = 0; i < MIN_POINTS_FOR_ESSENTIAL; ++i) {
            sample_pts1_img.push_back(pts1[all_indices[i]]);
            sample_pts2_img.push_back(pts2[all_indices[i]]);
        }

        // 将图像坐标转换为归一化相机坐标 (x = K_inv  x_img)
        // 注意：这里直接使用 K_inv 转换，而不是 normalizePoints，因为 normalizePoints 是为了 8点算法的数值稳定性
        // 而这里是根据相机内参进行物理意义上的归一化
        cv::Mat sample_pts1_h(3, MIN_POINTS_FOR_ESSENTIAL, CV_64F);
        cv::Mat sample_pts2_h(3, MIN_POINTS_FOR_ESSENTIAL, CV_64F);

        for(int i = 0; i < MIN_POINTS_FOR_ESSENTIAL; ++i) {
            sample_pts1_h.at<double(0,i) = sample_pts1_img[i].x;
            sample_pts1_h.at<double(1,i) = sample_pts1_img[i].y;
            sample_pts1_h.at<double(2,i) = 1.0;

            sample_pts2_h.at<double(0,i) = sample_pts2_img[i].x;
            sample_pts2_h.at<double(1,i) = sample_pts2_img[i].y;
            sample_pts2_h.at<double(2,i) = 1.0;
        }

        cv::Mat normalized_sample_pts1_h = K1_inv  sample_pts1_h;
        cv::Mat normalized_sample_pts2_h = K2_inv  sample_pts2_h;

        for(int i = 0; i < MIN_POINTS_FOR_ESSENTIAL; ++i) {
            sample_pts1_norm.push_back(cv::Point2f(normalized_sample_pts1_h.at<double(0,i), normalized_sample_pts1_h.at<double(1,i)));
            sample_pts2_norm.push_back(cv::Point2f(normalized_sample_pts2_h.at<double(0,i), normalized_sample_pts2_h.at<double(1,i)));
        }

        // 2. 拟合模型 (8点算法)
        cv::Mat E_candidate = computeEssentialMatrix8Point(sample_pts1_norm, sample_pts2_norm);

        if (E_candidate.empty()) {
            continue; // 模型拟合失败，跳过
        }

        // 3. 计算所有点的内点数量
        std::vector<intcurrent_inliers;
        for (int i = 0; i < num_points; ++i) {
            // 将所有点转换为归一化相机坐标
            cv::Point2f p1_norm = cv::Point2f(K1_inv.at<double(0,0)  pts1[i].x + K1_inv.at<double(0,2),
                                              K1_inv.at<double(1,1)  pts1[i].y + K1_inv.at<double(1,2));
            cv::Point2f p2_norm = cv::Point2f(K2_inv.at<double(0,0)  pts2[i].x + K2_inv.at<double(0,2),
                                              K2_inv.at<double(1,1)  pts2[i].y + K2_inv.at<double(1,2));

            double dist = computeSymmetricEpipolarDistance(p1_norm, p2_norm, E_candidate);
            if (dist < threshold) {
                current_inliers.push_back(i);
            }
        }

        // 4. 更新最佳模型
        if (current_inliers.size() best_inlier_count) {
            best_inlier_count = current_inliers.size();
            best_E = E_candidate.clone();
            inlier_indices = current_inliers;
        }
    }

    // 5. (可选) 使用所有内点重新优化模型
    if (best_inlier_count MIN_POINTS_FOR_ESSENTIAL) {
        std::vector<cv::Point2ffinal_pts1_img, final_pts2_img;
        for (int idx : inlier_indices) {
            final_pts1_img.push_back(pts1[idx]);
            final_pts2_img.push_back(pts2[idx]);
        }

        // 再次将图像坐标转换为归一化相机坐标
        cv::Mat final_pts1_h(3, final_pts1_img.size(), CV_64F);
        cv::Mat final_pts2_h(3, final_pts2_img.size(), CV_64F);

        for(size_t i = 0; i < final_pts1_img.size(); ++i) {
            final_pts1_h.at<double(0,i) = final_pts1_img[i].x;
            final_pts1_h.at<double(1,i) = final_pts1_img[i].y;
            final_pts1_h.at<double(2,i) = 1.0;

            final_pts2_h.at<double(0,i) = final_pts2_img[i].x;
            final_pts2_h.at<double(1,i) = final_pts2_img[i].y;
            final_pts2_h.at<double(2,i) = 1.0;
        }

        std::vector<cv::Point2ffinal_pts1_norm_for_opt, final_pts2_norm_for_opt;
        cv::Mat normalized_final_pts1_h = K1_inv  final_pts1_h;
        cv::Mat normalized_final_pts2_h = K2_inv  final_pts2_h;

        for(size_t i = 0; i < final_pts1_img.size(); ++i) {
            final_pts1_norm_for_opt.push_back(cv::Point2f(normalized_final_pts1_h.at<double(0,i), normalized_final_pts1_h.at<double(1,i)));
            final_pts2_norm_for_opt.push_back(cv::Point2f(normalized_final_pts2_h.at<double(0,i), normalized_final_pts2_h.at<double(1,i)));
        }

        // 这里可以调用更精确的优化方法，例如 OpenCV 的 findEssentialMat (如果允许使用)
        // 或者简单地再次使用8点算法，因为它在内点集上会更稳定
        best_E = computeEssentialMatrix8Point(final_pts1_norm_for_opt, final_pts2_norm_for_opt);
    }

    return best_inlier_count;
}


int main() {
    // 模拟一些特征点对
    // 假设有100对点，其中80对是内点，20对是离群点
    std::vector<cv::Point2fpts1, pts2;
    int num_total_points = 100;
    int num_inliers = 80;
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<dist_xy(0.0, 640.0); // 图像宽度
    std::uniform_real_distribution<dist_noise(-2.0, 2.0); // 噪声
    std::uniform_real_distribution<dist_outlier(0.0, 1000.0); // 离群点范围

    // 假设一个真实的本质矩阵 (这里简化，实际中需要通过R,t构造)
    // 假设相机1在原点，相机2沿着X轴平移1个单位
    // E = [t]x  R
    // R = I (无旋转)
    // t = (1, 0, 0)^T
    // [t]x = (0, 0, 0; 0, 0, -1; 0, 1, 0)
    // E_true = (0, 0, 0; 0, 0, -1; 0, 1, 0)
    cv::Mat E_true = (cv::Mat_<double(3, 3) <<
        0, 0, 0,
        0, 0, -1,
        0, 1, 0);

    // 模拟内点
    for (int i = 0; i < num_inliers; ++i) {
        double x1 = dist_xy(gen);
        double y1 = dist_xy(gen);

        // 根据本质矩阵生成对应的点 (这里简化，实际中需要更复杂的几何关系)
        // 假设 x2 = x1 + t + noise
        double x2 = x1 + 10.0 + dist_noise(gen); // 模拟平移和噪声
        double y2 = y1 + dist_noise(gen);

        pts1.push_back(cv::Point2f(x1, y1));
        pts2.push_back(cv::Point2f(x2, y2));
    }

    // 模拟离群点
    for (int i = 0; i < num_total_points - num_inliers; ++i) {
        pts1.push_back(cv::Point2f(dist_xy(gen), dist_xy(gen)));
        pts2.push_back(cv::Point2f(dist_outlier(gen), dist_outlier(gen))); // 离群点在很远的地方
    }

    // 模拟相机内参矩阵 (假设图像大小 640x480, 焦距 500)
    cv::Mat K1 = (cv::Mat_<double(3, 3) <<
        500, 0, 320,
        0, 500, 240,
        0, 0, 1);
    cv::Mat K2 = K1.clone(); // 假设两个相机内参相同

    cv::Mat estimated_E;
    std::vector<intfinal_inlier_indices;

    std::cout << "Starting RANSAC for Essential Matrix estimation..." << std::endl;
    int found_inliers = ransacEssentialMatrix(pts1, pts2, K1, K2, estimated_E, final_inlier_indices);

    std::cout << "RANSAC finished." << std::endl;
    std::cout << "Total points: " << num_total_points << std::endl;
    std::cout << "Estimated inliers: " << found_inliers << std::endl;
    std::cout << "Estimated Essential Matrix E:\n" << estimated_E << std::endl;

    // 验证估计的本质矩阵是否满足 x2^T  E  x1 = 0 (对于内点)
    if (!estimated_E.empty()) {
        double max_epipolar_error = 0.0;
        for (int idx : final_inlier_indices) {
            cv::Point2f p1_norm = cv::Point2f(K1.inv().at<double(0,0)  pts1[idx].x + K1.inv().at<double(0,2),
                                              K1.inv().at<double(1,1)  pts1[idx].y + K1.inv().at<double(1,2));
            cv::Point2f p2_norm = cv::Point2f(K2.inv().at<double(0,0)  pts2[idx].x + K2.inv().at<double(0,2),
                                              K2.inv().at<double(1,1)  pts2[idx].y + K2.inv().at<double(1,2));
            double error = computeSymmetricEpipolarDistance(p1_norm, p2_norm, estimated_E);
            if (error max_epipolar_error) {
                max_epipolar_error = error;
            }
        }
        std::cout << "Max epipolar error for inliers: " << max_epipolar_error << std::endl;
    }

    return 0;
}


 编译和运行

你需要安装 OpenCV 库。

Linux/macOS (使用 g++)：

bash
g++ RANSAC_Essential.cpp -o RANSAC_Essential pkg-config opencv4 --cflags --libs
 或者如果你的 OpenCV 是 3.x 版本
 g++ RANSAC_Essential.cpp -o RANSAC_Essential pkg-config opencv --cflags --libs


Windows (使用 MinGW g++)：

假设你已经正确安装了 MinGW 和 OpenCV，并且设置了环境变量。
你需要找到 OpenCV 的头文件路径和库文件路径。

bash
g++ RANSAC_Essential.cpp -o RANSAC_Essential.exe \
-I"C:\path\to\opencv\build\include" \
-L"C:\path\to\opencv\build\x64\vc15\lib" \
-lopencv_core455 -lopencv_highgui455 -lopencv_imgproc455 -lopencv_calib3d455 -lopencv_features2d455 -lopencv_videoio455 \
 根据你的OpenCV版本调整库文件名，例如 opencv_core455.lib
 通常只需要 core, highgui, imgproc, calib3d, features2d 

或者，如果你使用 CMake，可以更方便地管理依赖。

运行：
bash
./RANSAC_Essential


 代码解释

1.  normalizePoints (未在 RANSAC 中直接使用，但 8 点算法的理论基础是归一化)
       这个函数实现了图像点的归一化，将点集平移到质心，并缩放使得平均距离原点为 sqrt(2)。这有助于提高 8 点算法的数值稳定性。
       注意： 在 ransacEssentialMatrix 函数中，我们直接使用相机内参 K 的逆来将图像坐标转换为归一化相机坐标，这更符合本质矩阵的定义。normalizePoints 更多是用于纯粹的 8 点算法实现，而 K 逆的转换是物理意义上的归一化。

2.  computeEssentialMatrix8Point
       这是 8 点算法的核心实现。
       它构建一个 A 矩阵，其中每行对应一对归一化后的匹配点。
       对 A 进行 SVD 分解 A = U S V^T。本质矩阵 E 是 V^T 的最后一列（对应最小奇异值）。
       奇异值约束： 8 点算法得到的 E 可能不严格满足本质矩阵的秩 2 约束。因此，需要对 E 再次进行 SVD 分解 E = U_E S_E V_E^T，然后强制 S_E 的奇异值为 (s1+s2)/2, (s1+s2)/2, 0，再重构 E。

3.  computeSymmetricEpipolarDistance
       计算对称对极距离，这是衡量点对与本质矩阵之间一致性的度量。
       对于一对匹配点 x1 和 x2，以及本质矩阵 E，理想情况下 x2^T E x1 = 0。
       对称对极距离考虑了点 x1 到 E^T x2 (对极线) 的距离，以及点 x2 到 E x1 (对极线) 的距离，并取它们的平均。

4.  ransacEssentialMatrix
       输入： 图像特征点对 pts1, pts2，以及相机内参 K1, K2。
       随机采样： 每次迭代随机选择 MIN_POINTS_FOR_ESSENTIAL (8) 对点。
       归一化： 将采样的图像点通过相机内参 K 的逆转换为归一化相机坐标。
       模型拟合： 调用 computeEssentialMatrix8Point 拟合本质矩阵。
       内点计数： 遍历所有点对，将它们也转换为归一化相机坐标，然后计算它们到当前 E 的对称对极距离。如果距离小于 threshold，则认为是内点。
       更新最佳模型： 记录内点数量最多的模型。
       最终优化 (可选)： 在所有迭代结束后，使用所有被识别为内点的点对重新计算一次本质矩阵，以获得更精确的结果。

 总结

RANSAC 是一种非常强大的鲁棒估计方法，在计算机视觉中应用广泛。通过这个 C++ 示例，你可以理解其核心原理和实现细节。在实际应用中，你可能需要根据具体数据和噪声情况调整 RANSAC 的参数（阈值、迭代次数），并考虑使用更高效的实现（例如，OpenCV 提供了 cv::findEssentialMat 函数，内部也使用了 RANSAC）。