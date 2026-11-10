在工业界和自动驾驶量产落地中，摄像头硬件（ISP）输出的确实多为 NV12（YUV420SP）格式，以节省数据传输带宽（NV12 每像素占用 1.5 字节，而 RGB 占用 3 字节）。但 `mmdetection` 和 `mmdetection3d` 等开源框架及底层的预训练模型（如 ResNet, Swin）默认都是基于 RGB/BGR 格式构建的。

为了弥合这种差异，工业界通常会在训练端（算法框架）**和**部署端（推理引擎）采取不同的处理策略。

**1. 训练阶段：在 Pipeline 中定制数据加载器 (Custom Data Pipeline)**
在模型训练时，为了复用 ImageNet 的预训练权重并保持与开源生态的兼容，最常见的做法是在数据流中实时将 NV12 转为 BGR/RGB。

* **注册自定义 Loader**：在 `mmdet3d` 的代码中，继承并重写 `LoadImageFromFile` 或 `LoadMultiViewImageFromFiles` 类，注册为一个新的 Pipeline 节点（例如 `LoadNV12ImageFromFile`）。
* **实时转换**：在加载图像的环节，读取 NV12 的二进制数据，利用 OpenCV 转换为标准的三通道数组：`cv2.cvtColor(nv12_data, cv2.COLOR_YUV2BGR_NV12)`。
* **无缝衔接**：转换后返回的依然是 `(H, W, 3)` 的 BGR `ndarray`，后续的 `Normalize`、`Pad`、`DefaultFormatBundle` 等流水线操作完全不需要修改，直接喂给标准 Backbone。

**2. 部署阶段：前处理下沉与硬件加速 (Deployment & Inference)**
到了实车或边缘设备部署时，如果在 CPU 上使用 OpenCV 做 NV12 到 RGB 的转换，会消耗过多的 CPU 资源并引入巨大延迟。工业界的主流解决方案是将这段逻辑“下沉”：

* **方案 A：在模型图（Graph）最前端插入转换节点（最推荐）**
将 NV12 到 RGB 的转换逻辑（本质是矩阵乘法和加法）写成算子，**直接打包进 ONNX 或 TensorRT 模型中**。物理摄像头将体积更小的 NV12 数据直接拷贝到 GPU/NPU 显存，然后在模型的第一个 Node（如 CUDA Kernel）上完成色彩空间转换。这不仅利用了高并发算力，还节省了 PCIe 传输带宽。
* **方案 B：利用底层专用硬件 (VPP/ISP)**
在英伟达（如 Orin）、高通或地平线等车载计算平台上，通常配有专门的图像处理硬件（如 NVIDIA 的 VIC 模块）。在数据进入深度学习引擎之前，调用这些硬件接口，以极低的功耗和几乎零 CPU 占用完成 NV12 转 RGB。
* **方案 C：使用极速汇编库**
如果架构限制必须在 CPU 上做前处理，工业界绝不会使用 OpenCV，而是使用 `libyuv`。它利用 ARM NEON 或 x86 AVX 指令集进行了汇编级的极限优化，转换速度比 OpenCV 快数倍。

**3. 极致性能：原生支持 NV12 输入 (Native NV12 Input)**
对于追求极致端到端延迟且拥有海量数据的自动驾驶团队，会直接改造网络结构，让模型原生接受 NV12 数据，省去色彩空间转换的开销。但这面临一个物理难题：NV12 的 Y 分量分辨率是 $(H, W, 1)$，而交织的 UV 分量分辨率是 $(H/2, W/2, 2)$，两者尺寸不同，无法直接 Concat。

为了解决这个问题，通常需要修改网络的输入层：

* **Space-to-Depth 操作**：将 $(H, W, 1)$ 的 Y 分量在空间维度上做切分（类似于 YOLO 的 Focus 层或 PixelShuffle 的逆操作），重排为 $(H/2, W/2, 4)$。
* **通道拼接**：将重排后的 Y 与原本的 UV $(H/2, W/2, 2)$ 拼接，得到一个 $(H/2, W/2, 6)$ 的特征图。
* **修改 Backbone 卷积**：将网络第一层卷积的 `in_channels` 从 3 改为 6。
* **代价**：这种做法破坏了标准 RGB 的输入结构，导致无法直接加载 ImageNet 预训练权重，必须**从头训练（Train from scratch）**，因此只有在数据集足够庞大、无需依赖开源预训练模型的大厂才会采用。