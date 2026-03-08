安装 Stable Diffusion WebUI 主要有两种方式：使用 “一键整合包”（适合新手，简单快速）或 “手动源码安装”（适合有基础的用户，方便后续更新插件）。
一、 安装前准备（硬件要求）

* 显卡 (GPU)：首选 NVIDIA (英伟达) 显卡。建议显存 8GB 及以上以获得流畅体验，最低要求 4GB。
* 内存：建议 16GB 或以上。
* 存储：预留至少 20GB 空间（模型文件通常很大）。

------------------------------
二、 安装教程 (Windows 为例)方法 1：一键整合包（推荐新手）
这是由国内社区大佬（如秋叶、星空等）封装好的版本，自带环境，解压即用。

   1. 从 Bilibili 等平台搜索“Stable Diffusion 一键整合包”下载压缩文件。
   2. 将压缩包解压到 非中文路径 的磁盘目录下。
   3. 点击目录下的 A启动器.exe 或类似的启动程序，点击“启动”即可。

方法 2：官方手动安装（源码版）

   1. 安装 Python：从 Python 官网 下载 3.10.6 版本（必须是 3.10 系列），安装时务必勾选 “Add Python to PATH”。
   2. 安装 Git：从 Git 官网 下载并安装。
   3. 安装 CUDA：如果你是 NVIDIA 显卡，建议安装最新的 [CUDA Toolkit](https://developer.nvidia.com/cuda-downloads) 以加速生成速度。
   4. 克隆仓库：打开 CMD 终端，输入以下命令：
```shell
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
```
   5. 运行：进入文件夹，双击 webui-user.bat。首次运行会自动下载约数 GB 的环境和基础模型，请耐心等待。 

------------------------------
三、 基础使用教程

   1. 启动 WebUI：运行完成后，程序会给出一个本地网址（通常是 http://127.0.0.1:7860），将其复制到浏览器打开。
   2. 核心功能区：
   * 文生图 (txt2img)：通过文字描述生成图片。
      * 提示词 (Prompt)：填写你想让 AI 画的内容（目前英语支持最好）。
      * 负面提示词 (Negative Prompt)：填写你不希望出现的内容（如：低画质、多出手指等）。
      * 采样方法 (Sampler)：常用 DPM++ 2M Karras 或 Euler a。
      * 生成 (Generate)：点击右上角橙色按钮开始绘画。
   3. 下载模型：
   * 前往 Civitai (C站) 或 [Hugging Face](https://huggingface.co/) 下载不同风格的模型。
      * 大模型 (.safetensors)：放入 models/Stable-diffusion 文件夹。
      * Lora 模型：放入 models/Lora 文件夹，用于微调特定人物或风格。

------------------------------
四、进阶
    需要了解vae和Lora
    NSFW模型 是 Not Safe For Work 的缩写，直译为“不适合在办公场所查看的内容” 
    https://civitai.com/