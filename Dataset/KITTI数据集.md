# KITTI数据集


## 1.相机标定

KITTI 数据集中的 calib.txt 文件包含了传感器（主要是相机和 LiDAR/Velodyne）之间的校准参数。这些参数对于将不同传感器的数据投影到同一坐标系下，或者将 3D 点投影到 2D 图像平面至关重要。

calib.txt 文件通常包含以下几行，每一行都代表一个校准矩阵或参数：

 文件结构示例


P0: 7.215377000000e+02 0.000000000000e+00 6.095593000000e+02 0.000000000000e+00 0.000000000000e+00 7.215377000000e+02 1.728540000000e+02 0.000000000000e+00 0.000000000000e+00 0.000000000000e+00 1.000000000000e+00 0.000000000000e+00
P1: ... (类似 P0)
P2: ... (类似 P0)
P3: ... (类似 P0)
R0_rect: 9.999239000000e-01 9.837760000000e-03 -7.445048000000e-03 -1.196266000000e-02 9.999008000000e-01 -1.442187000000e-03 7.252797000000e-03 1.736691000000e-02 9.998467000000e-01
Tr_velo_to_cam: 7.533745000000e-03 -9.999714000000e-01 -6.166020000000e-04 -4.069766000000e-03 1.480249000000e-02 7.280733000000e-04 -9.998902000000e-01 -7.631618000000e-02 9.998621000000e-01 7.523790000000e-03 1.480755000000e-02 -2.717806000000e-01
Tr_imu_to_velo: ... (如果存在)


 详细解读

 1. P0, P1, P2, P3: 投影矩阵 (Projection Matrices)

   含义： 这些是 3x4 的投影矩阵，用于将 3D 点从 相机坐标系 投影到 2D 图像平面。KITTI 数据集通常有四台相机：
       P0: 灰度相机 0 (左)
       P1: 灰度相机 1 (右)
       P2: 彩色相机 0 (左) - 通常这是 KITTI 视觉任务中使用的主要彩色相机
       P3: 彩色相机 1 (右)
   格式： 每个 P 矩阵是 3x4 的，但文件中以一维数组的形式给出 12 个浮点数。你可以将其重构为：
    
    P = | f_x  0   c_x  t_x |
        | 0    f_y c_y  t_y |
        | 0    0   1    t_z |
    
    其中：
       (f_x, f_y) 是焦距（以像素为单位）。
       (c_x, c_y) 是主点坐标（图像中心的偏移）。
       (t_x, t_y, t_z) 是一个平移向量，表示 基线 (baseline) 效应。在 KITTI 中，P 矩阵已经包含了相机的内参和经过 R0_rect 矫正后的外参（即相机相对于参考相机 P0 的位移）。
   使用方法： 如果有一个 3D 点 X_cam = (x, y, z) 在相机坐标系下（齐次坐标 [x, y, z, 1]^T），则其在图像上的 2D 像素坐标 (u, v) 可以通过以下方式计算：
    [us, vs, s]^T = P  [x, y, z, 1]^T
    然后 u = (us) / s，v = (vs) / s。

 2. R0_rect: 矫正旋转矩阵 (Rectification Rotation Matrix)

   含义： 这是一个 3x3 的旋转矩阵，用于将原始相机坐标系下的 3D 点旋转到 矫正后的相机坐标系。在 KITTI 数据集中，所有相机图像都经过了矫正，使得左右相机图像的行对齐，方便进行立体匹配。R0_rect 是将原始相机坐标系（通常是 P0 对应的坐标系）旋转到矫正后的坐标系。
   格式： 9 个浮点数，重构为 3x3 矩阵。
    
    R0_rect = | r11 r12 r13 |
              | r21 r22 r23 |
              | r31 r32 r33 |
    
   使用方法： 如果你有一个 3D 点 X_cam_orig 在原始相机坐标系下，你可以通过 X_cam_rect = R0_rect  X_cam_orig 得到它在矫正后的相机坐标系下的位置。P 矩阵已经包含了这个矫正，所以通常你不需要单独使用 R0_rect 来处理 P 矩阵。它主要用于将 Velodyne 点转换到矫正后的相机坐标系。

 3. Tr_velo_to_cam: Velodyne 到相机坐标系的变换矩阵 (Transformation Matrix)

   含义： 这是一个 3x4 的刚体变换矩阵（旋转 R 和平移 t），用于将 3D 点从 Velodyne 激光雷达坐标系 转换到 矫正后的相机坐标系。
   格式： 12 个浮点数，重构为 3x4 矩阵。为了方便计算，通常将其扩展为 4x4 的齐次变换矩阵：
    
    T_velo_to_cam = | r11 r12 r13 t_x |
                    | r21 r22 r23 t_y |
                    | r31 r32 r33 t_z |
                    | 0   0   0   1   |
    
   使用方法： 如果有一个 3D 点 X_velo = (x, y, z) 在 Velodyne 坐标系下（齐次坐标 [x, y, z, 1]^T），则其在矫正后的相机坐标系下的 3D 坐标 X_cam_rect 为：
    X_cam_rect = T_velo_to_cam  X_velo

 4. Tr_imu_to_velo: IMU 到 Velodyne 坐标系的变换矩阵 (Transformation Matrix)

   含义： 这是一个 3x4 的刚体变换矩阵，用于将 3D 点从 IMU 坐标系 转换到 Velodyne 激光雷达坐标系。这个通常在 calib.txt 文件中不总是出现，但如果你的任务需要处理 IMU 数据，它会非常有用。
   格式： 12 个浮点数，重构为 3x4 矩阵，同样可以扩展为 4x4 齐次变换矩阵。
   使用方法： 类似于 Tr_velo_to_cam，用于将 IMU 坐标系下的点转换到 Velodyne 坐标系。

 坐标系约定

   相机坐标系：
       X 轴指向右侧。
       Y 轴指向下方。
       Z 轴指向前方。
   Velodyne 坐标系：
       X 轴指向前方。
       Y 轴指向左侧。
       Z 轴指向上方。
       这是一个右手坐标系。

 如何使用这些矩阵进行点云到图像的投影

假设你想将一个 Velodyne 点 X_velo = (x_v, y_v, z_v) 投影到彩色左相机 P2 的图像上：

1.  将 Velodyne 点转换为齐次坐标：
    X_velo_hom = [x_v, y_v, z_v, 1]^T

2.  将 Velodyne 点从 Velodyne 坐标系转换到矫正后的相机坐标系 (P2)：
    首先，你需要将 Tr_velo_to_cam 扩展为 4x4 齐次变换矩阵 T_velo_to_cam。
    X_cam_rect = T_velo_to_cam  X_velo_hom
    （注意：Tr_velo_to_cam 已经将 Velodyne 点转换到 矫正后的相机坐标系，所以不需要再乘以 R0_rect）

3.  将 3D 相机点投影到 2D 图像平面：
    [us, vs, s]^T = P2  X_cam_rect
    其中 X_cam_rect 是 3D 向量（忽略其齐次坐标的第四个分量），P2 是 3x4 矩阵。
    或者，如果 X_cam_rect 是 4D 齐次向量，则 P2 也可以看作是 [K | t] 形式的 3x4 矩阵。

4.  归一化得到像素坐标：
    u = (us) / s
    v = (vs) / s

 总结

calib.txt 文件是 KITTI 数据集的核心组成部分，它提供了不同传感器之间以及 3D 世界到 2D 图像的几何映射关系。理解这些矩阵的含义和使用方法，是进行点云与图像融合、3D 目标检测、SLAM 等任务的基础。


## 2.Odom 开发包
https://s3.eu-central-1.amazonaws.com/avg-kitti/devkit_odometry.zip

此文件描述了 KITTI 视觉里程计/SLAM 基准套件。
精确的地面实况 (<10cm) 由启用 RTK 浮点/整数校正的 GPS/IMU 系统提供。
为了公平地比较所有方法，
仅公开序列 00-10 的地面实况。
其余序列 (11-21) 作为评估序列。

注意：提交结果时，请使用与地面实况数据相同的数据格式（参见下文“姿势”）进行存储，
文件名为 11.txt 至 21.txt。创建一个 ZIP 压缩包，并将结果存储在其根文件夹中。

文件描述：
### 2.1 “sequences”文件夹：

“sequences”文件夹下的每个文件夹都包含一个序列，其中
左图和右图分别存储在子文件夹 image_0 和 image_1 中。图像以灰度 PNG 格式提供，
可以使用 MATLAB 或 libpng++ 加载。**所有图像均已去畸变和
校正。** 序列 0-10 可用于训练，而测试序列 11-21 必须提供结果。

### 2.2 Velodyne点云数据

为了节省空间，所有扫描数据均以 Nx4 浮点矩阵的形式存储到二进制文件中，代码如下：

```
stream = fopen (dst_file.c_str(),"wb");
fwrite(data,sizeof(float),4*num,stream);
fclose(stream);
```

其中，data 包含 4*num 个值，前 3 个值分别对应 x、y 和 z 轴，最后一个值表示反射率信息。所有扫描数据
均按行对齐存储，这意味着前 4 个值对应于
第一次测量。由于每次扫描的点数可能不同，因此必须在读取文件时根据文件大小确定，其中 1e6 是值数量的上限，足够大：
```
// 分配 4 MB 缓冲区（仅需约 130*4*4 KB）
int32_t num = 1000000;
float *data = (float*)malloc(num*sizeof(float));

// 指针
float *px = data+0;
float *py = data+1;
float *pz = data+2;
float *pr = data+3;

// 加载点云
FILE *stream;
stream = fopen (currFilenameBinary.c_str(),"rb");
num = fread(data,sizeof(float),num,stream)/4;
for (int32_t i=0; i<num; i++) {
point_cloud.points.push_back(tPoint(*px,*py,*pz,*pr));
px+=4; py+=4; pz+=4; pr+=4;
}
fclose(stream);
```

x,y 和 y 以米为单位存储在 Velodyne 坐标系中。