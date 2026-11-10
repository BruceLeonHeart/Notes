# 将 Docker 作为开发环境的工作流程（以 SLAM 十四讲官方镜像为例）

> 类型：howto
> 一句话：Docker 作为 SLAM 开发环境


将 Docker 作为开发环境是一个非常优秀且现代的实践，它能确保开发、测试和部署环境的一致性，避免了“在我电脑上能跑”的经典问题。

对于《SLAM十四讲》这类需要特定库（如 Eigen、Sophus、Pangolin 等）的项目，使用其官方提供的 Docker 镜像（如 gaoxiang12/slambook2）作为开发环境是绝佳的选择。以下是整个工作流程的详细介绍。

核心思想是：代码在主机（Host OS）上，而编译和运行在容器（Container）里。这样即可使用本地编辑器（如 VS Code），同时利用容器里已经配置好的全部依赖。

我们主要有两种主流的工作流程：

1. **传统方式：命令行 + 卷挂载 (Volume Mounting)**
2. **现代方式：VS Code + Remote - Containers 插件（强烈推荐）**

## 工作流程一：命令行 + 卷挂载
这是最基础也是最核心的方式，理解它有助于你理解 Docker 的工作原理。

## 步骤 1: 在主机上准备代码
首先，你需要将《SLAM十四讲》的源代码克隆到你的本地电脑上。

```bash
git clone https://github.com/gaoxiang12/slambook2.git
# 假设你把代码放在了 ~/projects/slambook2 目录下
cd slambook2
```

## 步骤 2: 拉取 Docker 镜像
从 Docker Hub 上拉取高翔《视觉SLAM十四讲》官方提供的环境镜像（gaoxiang12/slambook2 镜像及 bionic tag 均真实存在）。

```bash
docker pull gaoxiang12/slambook2:bionic
(注：bionic 标签对应 Ubuntu 18.04，是比较常用的版本)
```

## 步骤 3: 启动容器并挂载代码目录
这是最关键的一步。我们使用 docker run 命令启动一个容器，并通过 -v 参数将主机上的代码目录“链接”到容器内部的一个目录。

```bash
# 语法: -v /path/on/host:/path/in/container
# 请将下面的 <你本地的代码路径> 替换为真实的绝对路径

docker run -it --rm \
  -v <你本地的代码路径>/slambook2:/root/slambook2 \
  gaoxiang12/slambook2:bionic
```
让我们分解一下这个命令：

* -it: 启动一个交互式的终端 (interactive TTY)，这样你就可以在容器里敲命令了。
* --rm: 当容器退出时，自动删除它。这对于临时的开发会话很方便，可以避免产生很多无用的旧容器。
* -v <你本地的代码路径>/slambook2:/root/slambook2: 卷挂载。
    - 冒号前面是你主机上的绝对路径。
    - 冒号后面是你想映射到容器内部的路径。
    - 执行后，你在主机上对 <你本地的代码路径>/slambook2 目录下的任何文件修改，都会实时同步到容器内的 /root/slambook2 目录，反之亦然。
* gaoxiang12/slambook2:bionic: 指定要使用的镜像。  

执行成功后，你的终端提示符会变成类似 root@xxxxxxxxxxxx:/# 的样子，这表示你已经进入了容器的命令行环境。

## 步骤 4: 在容器内编译和运行
现在，你所有的操作都在容器里进行。

```bash
# 进入我们刚刚挂载的目录
cd /root/slambook2


# 按照书中的指示编译代码
# 例如，编译 ch3 的代码
cd ch3
mkdir build
cd build
cmake ..
make -j4 # -j4 表示使用4个核心并行编译，可以加快速度

# 运行生成的可执行文件
./useEigen
```

**总结这个流程：**
1. 编辑代码：在你的主机上，用你喜欢的任何编辑器（VS Code, Sublime Text, Vim...）打开 <你本地的代码路径>/slambook2 并修改代码。
2. 编译运行：切换到已经打开的容器终端，进入对应目录，执行 make 和 ./executable。

## 工作流程二：VS Code + Remote - Containers 插件（推荐）
这个方法将上述流程无缝集成到了 VS Code 中，体验极佳，是目前的主流选择。

## 步骤 1: 安装必备软件
1. Docker Desktop (Windows/Mac) 或 Docker Engine (Linux)。
2. Visual Studio Code。
3. 在 VS Code 中安装微软官方插件：Remote - Containers。

**VS Code Remote Containers 扩展**

## 步骤 2: 准备代码
和方法一一样，先 git clone 代码到本地。

```bash
git clone https://github.com/gaoxiang12/slambook2.git
cd slambook2
```

## 步骤 3: 在容器中打开项目
1. 在 VS Code 中，点击左下角的绿色 >< 图标，或者按 F1 打开命令面板。
2. 选择 "Remote-Containers: Open Folder in Container..."。
3. 在弹出的文件选择框中，选择你刚刚克隆的 slambook2 文件夹。
4. VS Code 会询问你如何配置容器环境。选择 "From a Docker image"。
5. 在输入框中，输入镜像名称 gaoxiang12/slambook2:bionic 并回车。

VS Code 会自动完成以下工作：

- 创建一个 .devcontainer 文件夹和 devcontainer.json 配置文件。
- 在后台启动一个 Docker 容器。
- 将当前项目文件夹挂载到容器中。
- 在容器内安装一个 VS Code Server，使你的本地 VS Code 可以无缝操作容器。

完成后，VS Code 会重新加载窗口。此时，你的 VS Code 界面看起来和本地开发一模一样，但所有操作（包括终端、调试、代码提示）都已经在 Docker 容器内部执行了！

## 步骤 4: 无缝开发
编辑代码：就像在本地一样直接编辑。

编译运行：打开 VS Code 的集成终端（Ctrl+`），这个终端已经是容器的 shell 了。直接执行编译命令：

```bash
# 终端已经是 /root/slambook2 目录了
cd ch3
mkdir build
cd build
cmake ..
make
./useEigen
```
调试：你甚至可以配置 launch.json，直接在 VS Code 中对容器内的程序进行断点调试，和本地开发体验完全一致。

## 常见问题：如何运行带 GUI 的程序？（如 Pangolin）
SLAM 项目经常需要图形化显示，而 Docker 默认没有图形界面。你需要将容器的图形化请求转发到你的主机上，这称为 X11 Forwarding。

## 对于 Linux 主机 (最简单)
在 docker run 命令中加入以下参数：

```bash
docker run -it --rm \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=$DISPLAY \
  -v <你本地的代码路径>/slambook2:/root/slambook2 \
  gaoxiang12/slambook2:bionic
```
* -v /tmp/.X11-unix:/tmp/.X11-unix: 挂载 X11 的 socket 文件。
* -e DISPLAY=$DISPLAY: 将主机的 DISPLAY 环境变量传递给容器。
## 对于 Windows 主机
1. 安装一个 X Server，例如 VcXsrv。

2. 启动 VcXsrv，在 "Extra settings" 步骤中，务必勾选 "Disable access control"。

3. 找到你主机的局域网 IP 地址（例如 192.168.1.100）。

4. 在 docker run 命令中设置 DISPLAY 环境变量：

```bash
docker run -it --rm \
  -e DISPLAY=<你的主机IP>:0.0 \
  -v <你本地的代码路径>/slambook2:/root/slambook2 \
  gaoxiang12/slambook2:bionic
```

## 对于 macOS 主机
1. 安装 XQuartz。
2. 打开 XQuartz 的设置，在 "Security" 标签页中，勾选 "Allow connections from network clients"。
3. 重启 XQuartz。
4. 在终端中运行 xhost +，然后找到你的 IP 地址。
5. 运行 docker run 命令，设置 DISPLAY 环境变量。

使用 VS Code Remote - Containers 时，你可以在 .devcontainer/devcontainer.json 文件中添加这些配置，让它自动生效：

```json
{
	"image": "gaoxiang12/slambook2:bionic",
	"runArgs": [
		"--rm",
		"-v", "/tmp/.X11-unix:/tmp/.X11-unix" // For Linux
	],
	"containerEnv": {
		"DISPLAY": "${localEnv:DISPLAY}" // For Linux
	},
	"extensions": [
		"ms-vscode.cpptools"
	]
}
```
## 总结


|特性	|命令行 + 卷挂载|	VS Code + Remote-Containers|
|---	|-----	    |--------------	|
|优点	|基础，不依赖特定 IDE，自动化脚本友好|	体验极佳，无缝集成，调试方便|
|缺点|	操作繁琐，需要手动管理终端和编辑器|	依赖 VS Code|
|推荐度|	了解原理|	强烈推荐用于日常开发|

## 相关

- 使用 VS Code 访问远程服务器 Docker（见同目录 [使用vscode访问远程服务器Docker.md](./使用vscode访问远程服务器Docker.md)）
