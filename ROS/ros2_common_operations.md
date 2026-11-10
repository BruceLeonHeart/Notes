# ROS2 常用操作笔记

## 基础概念

### ROS2核心概念
- **节点（Node）**: 执行具体功能的进程
- **话题（Topic）**: 节点间通信的通道
- **消息（Message）**: 话题传输的数据结构
- **服务（Service）**: 节点间的请求-响应通信
- **动作（Action）**: 长时间运行的服务
- **参数（Parameter）**: 节点的配置值
- **包（Package）**: ROS2软件的基本组织单元
- **工作空间（Workspace）**: 存放ROS2包的目录结构
- **组件（Component）**: ROS2中的可重用模块
- **生命周期（Lifecycle）**: 节点的状态管理

### ROS2版本
- **Foxy Fitzroy**: Ubuntu 20.04（LTS，已停止支持）
- **Galactic Geochelone**: Ubuntu 20.04（已停止支持）
- **Humble Hawksbill**: Ubuntu 22.04（LTS）
- **Iron Irwini**: Ubuntu 22.04（非 LTS，已停止支持）
- **Jazzy Jalisco**: Ubuntu 24.04（LTS，当前最新）

---

## 工作空间操作

### 创建工作空间
```bash
# 创建工作空间目录
mkdir -p ~/colcon_ws/src

# 初始化工作空间
cd ~/colcon_ws
colcon build

# 激活工作空间
source install/setup.bash

# 验证工作空间
echo $AMENT_PREFIX_PATH
```

### 管理工作空间
```bash
# 编译工作空间
cd ~/colcon_ws
colcon build

# 清理工作空间
cd ~/colcon_ws
colcon build --cmake-clean-first

# 编译特定包
cd ~/colcon_ws
colcon build --packages-select package_name

# 编译多个包
cd ~/colcon_ws
colcon build --packages-select package1 package2

# 编译时跳过测试
cd ~/colcon_ws
colcon build --cmake-args -DBUILD_TESTING=0
```

### 工作空间环境变量
```bash
# 添加工作空间到bashrc
echo "source ~/colcon_ws/install/setup.bash" >> ~/.bashrc
source ~/.bashrc

# 查看ROS2环境变量
printenv | grep ROS
printenv | grep AMENT

# 临时设置ROS2环境变量
export ROS_DOMAIN_ID=0
export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
```

---

## 包操作

### 创建包
```bash
# 在工作空间中创建包
cd ~/colcon_ws/src
ros2 pkg create package_name --build-type ament_cmake --dependencies rclcpp std_msgs

# 创建Python包
cd ~/colcon_ws/src
ros2 pkg create package_name --build-type ament_python --dependencies rclpy std_msgs

# 创建带多个依赖的包
cd ~/colcon_ws/src
ros2 pkg create package_name --build-type ament_cmake --dependencies rclcpp rclpy std_msgs sensor_msgs geometry_msgs
```

### 查看包
```bash
# 查找包
ros2 pkg prefix package_name

# 列出所有包
ros2 pkg list

# 查看包的依赖
ros2 pkg dependencies package_name

# 查看包的清单
ros2 pkg xml package_name
```

### 包的结构

#### C++包结构
```text
package_name/
├── CMakeLists.txt      # CMake构建配置文件
├── package.xml         # 包的元数据和依赖
├── src/                # C++源代码
├── include/            # C++头文件
├── launch/             # 启动文件
├── config/             # 配置文件
├── msg/                # 自定义消息
└── srv/                # 自定义服务
```

#### Python包结构
```text
package_name/
├── setup.py            # Python包配置
├── setup.cfg           # 额外配置
├── package.xml         # 包的元数据和依赖
├── package_name/       # Python模块
│   ├── __init__.py
│   └── nodes/          # Python节点
├── launch/             # 启动文件
├── config/             # 配置文件
└── msg/                # 自定义消息
```

---

## 节点操作

### 运行节点
```bash
# 运行单个节点
ros2 run package_name node_name

# 运行节点并设置参数
ros2 run package_name node_name --ros-args -p param_name:=value

# 在特定命名空间运行节点
ros2 run package_name node_name --ros-args --namespace /namespace

# 重映射节点名称
ros2 run package_name node_name --ros-args --remap __node:=new_node_name

# 重映射话题
ros2 run package_name node_name --ros-args --remap chatter:=my_chatter
```

### 查看节点
```bash
# 列出所有运行的节点
ros2 node list

# 查看节点信息
ros2 node info /node_name

# 查看节点服务
ros2 node info /node_name | grep Services

# 查看节点话题
ros2 node info /node_name | grep Topics
```

---

## 话题操作

### 查看话题
```bash
# 列出所有话题
ros2 topic list

# 列出话题及类型
ros2 topic list -t

# 查看话题类型
ros2 topic type /topic_name

# 查看话题信息
ros2 topic info /topic_name

# 查看话题数据
ros2 topic echo /topic_name

# 查看话题数据的前N条
ros2 topic echo /topic_name --once

# 实时查看话题带宽
ros2 topic bw /topic_name

# 查看话题频率
ros2 topic hz /topic_name

# 查看话题延迟
ros2 topic delay /topic_name
```

### 发布话题
```bash
# 发布字符串消息
ros2 topic pub /topic_name std_msgs/msg/String '{data: "hello"}'

# 发布一次消息
ros2 topic pub --once /topic_name std_msgs/msg/String '{data: "hello"}'

# 持续发布消息（10Hz）
ros2 topic pub --rate 10 /topic_name std_msgs/msg/String '{data: "hello"}'

# 发布复杂消息
ros2 topic pub /cmd_vel geometry_msgs/msg/Twist '{linear: {x: 0.1, y: 0.0, z: 0.0}, angular: {x: 0.0, y: 0.0, z: 0.1}}'
```

---

## 服务操作

### 查看服务
```bash
# 列出所有服务
ros2 service list

# 查看服务类型
ros2 service type /service_name

# 查看服务信息
ros2 service info /service_name

# 调用服务
ros2 service call /service_name

# 调用带参数的服务
ros2 service call /add_two_ints example_interfaces/srv/AddTwoInts '{a: 1, b: 2}'

# 列出所有服务及其类型
ros2 service list -t
```

### 创建服务
```bash
# 定义服务文件 (srv/AddTwoInts.srv)
int64 a
int64 b
---
int64 sum

# 编译服务
cd ~/colcon_ws
colcon build
```

---

## 消息操作

### 查看消息
```bash
# 列出所有消息类型
ros2 msg list

# 查看消息定义
ros2 msg show std_msgs/msg/String

# 在接口列表中查找某消息类型
ros2 interface list | grep geometry_msgs/msg/Twist

# 列出所有提供接口的包
ros2 interface packages
```

### 创建消息
```bash
# 定义消息文件 (msg/Person.msg)
string name
int32 age
float32 height

# 编译消息
cd ~/colcon_ws
colcon build
```

---

## 动作操作

### 查看动作
```bash
# 列出所有动作
ros2 action list

# 查看动作类型
ros2 action type /action_name

# 查看动作信息
ros2 action info /action_name

# 查看动作定义
ros2 action show action_tutorials/action/Fibonacci
```

### 发送动作目标
```bash
# 发送动作目标
ros2 action send_goal /fibonacci action_tutorials/action/Fibonacci '{order: 10}'

# 发送动作目标并等待结果
ros2 action send_goal --feedback /fibonacci action_tutorials/action/Fibonacci '{order: 10}'
```

---

## 参数操作

### 查看参数
```bash
# 列出所有参数
ros2 param list

# 查看参数值
ros2 param get /node_name param_name

# 查看参数类型
ros2 param describe /node_name param_name
```

### 设置参数
```bash
# 设置参数
ros2 param set /node_name param_name value

# 从文件加载参数
ros2 param load /node_name params.yaml

# 保存参数到文件
ros2 param dump /node_name > params.yaml

# 删除参数
ros2 param delete /node_name param_name
```

---

## 启动文件操作

### 运行启动文件
```bash
# 运行启动文件
ros2 launch package_name launch_file.launch.py

# 带参数运行启动文件
ros2 launch package_name launch_file.launch.py param_name:=value

# 查看启动文件参数
ros2 launch package_name launch_file.launch.py --show-args
```

### 启动文件示例

#### Python启动文件
```python
from launch import LaunchDescription
from launch_ros.actions import Node


def generate_launch_description():
    return LaunchDescription([
        Node(
            package='rospy_tutorials',
            executable='talker.py',
            name='talker',
            output='screen'
        ),
        Node(
            package='rospy_tutorials',
            executable='listener.py',
            name='listener',
            output='screen',
            parameters=[{'queue_size': 10}]
        ),
        Node(
            package='rospy_tutorials',
            executable='talker.py',
            name='remapped_talker',
            output='screen',
            remappings=[
                ('chatter', 'my_chatter')
            ]
        )
    ])
```

#### XML启动文件
```xml
<launch>
  <!-- 启动节点 -->
  <node name="talker" pkg="rospy_tutorials" exec="talker.py" output="screen"/>
  
  <!-- 带参数的节点 -->
  <node name="listener" pkg="rospy_tutorials" exec="listener.py" output="screen">
    <param name="queue_size" value="10"/>
  </node>
  
  <!-- 重映射话题 -->
  <node name="remapped_talker" pkg="rospy_tutorials" exec="talker.py" output="screen">
    <remap from="chatter" to="my_chatter"/>
  </node>
  
  <!-- 包含其他启动文件 -->
  <include file="$(find-pkg-share package_name)/launch/other_launch.launch.py"/>
  
  <!-- 设置全局参数 -->
  <param name="robot_name" value="turtlebot"/>
</launch>
```

---

## 工具操作

### 常用工具
```bash
# 查看ROS2计算图
ros2 run rqt_graph rqt_graph

# 查看话题数据可视化
ros2 run rqt_plot rqt_plot

# 查看服务和参数
ros2 run rqt_reconfigure rqt_reconfigure

# 查看节点信息
ros2 run rqt_console rqt_console

# 查看TF树
ros2 run rqt_tf_tree rqt_tf_tree

# 查看消息内容
ros2 run rqt_msg rqt_msg

# 查看ROS2组件
ros2 component list
```

### 日志工具
```bash
# 查看ROS2日志
ros2 topic echo /rosout

# 查看日志文件
cd ~/.ros/log
ls -la

# 设置日志级别
ros2 run rqt_logger_level rqt_logger_level
```

### 诊断工具
```bash
# 运行诊断聚合器
ros2 launch diagnostic_aggregator diagnostic_aggregator.launch.py

# 查看诊断信息
ros2 topic echo /diagnostics

# 查看硬件状态
ros2 run diagnostic_updater test_diagnostic_updater
```

---

## 导航和机器人操作

### 导航工具
```bash
# 启动导航堆栈
ros2 launch nav2_bringup navigation_launch.py

# 发布目标位置
ros2 run nav2_util send_goal.py

# 查看地图
ros2 run nav2_map_server map_saver_cli -f ~/map

# 查看机器人位置
ros2 run tf2_ros tf2_echo map base_link
```

### 机器人状态
```bash
# 查看机器人关节状态
ros2 topic echo /joint_states

# 查看机器人TF变换
ros2 run tf2_ros tf2_monitor

# 查看机器人里程计
ros2 topic echo /odom

# 查看激光数据
ros2 topic echo /scan
```

---

## 通信和网络

### 多机通信
```bash
# 在所有机器上设置相同的域名ID
export ROS_DOMAIN_ID=0

# 确保机器在同一网络
ping other_machine_ip

# 测试连接
ros2 node list
```

### 网络配置
```bash
# 查看ROS2环境变量
printenv | grep ROS

# 设置RMW实现
export RMW_IMPLEMENTATION=rmw_fastrtps_cpp

# 设置ROS_DOMAIN_ID
export ROS_DOMAIN_ID=0
```

---

## 调试和开发

### 调试工具
```bash
# 使用gdb调试C++节点
ros2 run --prefix "gdb -ex run --args" package_name node_name

# 使用valgrind检查内存
ros2 run --prefix "valgrind" package_name node_name

# 查看节点的CPU和内存使用
ros2 topic echo /diagnostics | grep -A 10 node_name

# 查看ROS2节点的启动时间
ros2 node info /node_name | grep -i time
```

### 开发工具
```bash
# 代码自动生成
ros2 interface show std_msgs/msg/String

# 消息生成
ros2 msg show package_name/msg/MessageType

# 服务生成
ros2 srv show package_name/srv/ServiceType

# 动作生成
ros2 action show package_name/action/ActionType
```

---

## 常用命令速查

### 核心命令
```bash
# ROS2核心
# ROS2不需要单独启动roscore，由节点自动启动

# 运行节点
ros2 run <pkg> <executable>     # 运行节点
ros2 launch <pkg> <launch>     # 运行启动文件

# 节点管理
ros2 node list               # 列出节点
ros2 node info <node>        # 节点信息

# 话题管理
ros2 topic list              # 列出话题
ros2 topic echo <topic>      # 查看话题数据
ros2 topic pub <topic> <msg> # 发布话题
ros2 topic type <topic>      # 话题类型

# 服务管理
ros2 service list            # 列出服务
ros2 service call <service>  # 调用服务
ros2 service type <service>  # 服务类型

# 参数管理
ros2 param list              # 列出参数
ros2 param get <node> <param> # 获取参数
ros2 param set <node> <param> <val> # 设置参数

# 包管理
ros2 pkg list                # 列出包
ros2 pkg create <pkg>        # 创建包

# 编译
colcon build                 # 编译工作空间
colcon build --packages-select <pkg> # 编译特定包
```

### 实用命令
```bash
# 查看ROS2版本
ros2 --version

# 查看ROS2环境
printenv | grep ROS
printenv | grep AMENT

# 查找可执行文件
ros2 pkg prefix <pkg> && ls -la $(ros2 pkg prefix <pkg>)/lib/<pkg>

# 查看消息定义
ros2 msg show <msg>

# 查看服务定义
ros2 srv show <srv>

# 查看动作定义
ros2 action show <action>

# 查看TF变换
ros2 run tf2_ros tf2_echo <frame1> <frame2>

# 查看地图
ros2 run nav2_map_server map_saver_cli -f <map_name>

# 查看机器人状态
ros2 topic echo /joint_states

# 查看组件
ros2 component list
```

---

## 常见问题解决

### 网络问题
```bash
# 检查ROS2节点是否运行
ros2 node list

# 检查网络连接
ping other_machine_ip

# 确保ROS_DOMAIN_ID相同
echo $ROS_DOMAIN_ID

# 检查RMW实现
echo $RMW_IMPLEMENTATION
```

### 编译问题
```bash
# 清理并重新编译
cd ~/colcon_ws
rm -rf build install log
colcon build

# 检查依赖
rosdep check package_name
rosdep install --from-paths src --ignore-src -r -y

# 检查CMakeLists.txt
colcon build --packages-select package_name --cmake-args -DCMAKE_BUILD_TYPE=Debug
```

### 节点问题
```bash
# 检查节点是否存在
ros2 node list | grep node_name

# 检查节点日志
ros2 topic echo /rosout | grep node_name

# 检查节点启动命令
ros2 run package_name node_name --help
```

### 话题问题
```bash
# 检查话题是否存在
ros2 topic list | grep topic_name

# 检查话题类型
ros2 topic type /topic_name

# 检查发布者和订阅者
ros2 topic info /topic_name

# 检查消息格式
ros2 topic echo /topic_name --once
```

---

## 最佳实践

### 代码组织
- 按照功能模块组织包
- 使用Colcon工作空间管理代码
- 遵循ROS2命名约定（小写+下划线）
- 使用launch文件管理节点启动
- 使用配置文件管理参数

### 命名约定
- **包名**: 小写，使用下划线
- **节点名**: 小写，使用下划线
- **话题名**: 小写，使用斜杠分隔
- **服务名**: 小写，使用下划线
- **参数名**: 小写，使用斜杠分隔
- **消息类型**: 首字母大写，使用驼峰命名

### 性能优化
- 使用适当的消息类型
- 合理设置队列大小
- 使用回调函数处理消息
- 避免在回调中进行耗时操作
- 使用多线程处理复杂任务
- 合理使用ROS2参数

### 调试技巧
- 使用rclcpp/rclpy的日志系统
- 使用rqt工具进行可视化调试
- 使用gdb进行C++代码调试
- 使用ros2 topic echo查看消息内容
- 使用ros2 node info查看节点状态

---

## 学习资源

### 官方资源
- [ROS2官方文档](https://docs.ros.org/en/humble/)
- [ROS2教程](https://docs.ros.org/en/humble/Tutorials.html)
- [ROS2 API文档](https://docs.ros.org/en/humble/API.html)

### 书籍
- 《ROS2机器人编程》
- 《Learning ROS2 for Robotics Programming》
- 《Mastering ROS2 for Robotics Programming》

### 在线教程
- [ROS2 Wiki](https://index.ros.org/doc/ros2/)
- [ROS Answers](https://answers.ros.org/)
- [YouTube ROS2教程](https://www.youtube.com/results?search_query=ros2+tutorial)

### 社区资源
- [ROS2 Discourse](https://discourse.ros.org/)
- [ROS2 GitHub](https://github.com/ros2)
- [ROS2社区](https://index.ros.org/)

---

## 示例代码

### Python节点示例
```python
#!/usr/bin/env python3
import rclpy
from rclpy.node import Node
from std_msgs.msg import String


class TalkerNode(Node):
    def __init__(self):
        super().__init__('talker')
        self.publisher_ = self.create_publisher(String, 'chatter', 10)
        self.timer = self.create_timer(0.1, self.timer_callback)
        self.i = 0

    def timer_callback(self):
        msg = String()
        msg.data = f'hello world {self.i}'
        self.publisher_.publish(msg)
        self.get_logger().info(f'Publishing: {msg.data}')
        self.i += 1


def main(args=None):
    rclpy.init(args=args)
    talker_node = TalkerNode()
    rclpy.spin(talker_node)
    talker_node.destroy_node()
    rclpy.shutdown()


if __name__ == '__main__':
    main()
```

### C++节点示例
```cpp
#include <rclcpp/rclcpp.hpp>
#include <std_msgs/msg/string.hpp>

class TalkerNode : public rclcpp::Node
{
public:
    TalkerNode() : Node("talker"), count_(0)
    {
        publisher_ = this->create_publisher<std_msgs::msg::String>("chatter", 10);
        timer_ = this->create_wall_timer(
            std::chrono::milliseconds(100),
            std::bind(&TalkerNode::timer_callback, this)
        );
    }

private:
    void timer_callback()
    {
        auto msg = std::make_shared<std_msgs::msg::String>();
        msg->data = "hello world " + std::to_string(count_);
        RCLCPP_INFO(this->get_logger(), "Publishing: '%s'", msg->data.c_str());
        publisher_->publish(*msg);
        count_++;
    }

    rclcpp::Publisher<std_msgs::msg::String>::SharedPtr publisher_;
    rclcpp::TimerBase::SharedPtr timer_;
    size_t count_;
};

int main(int argc, char * argv[])
{
    rclcpp::init(argc, argv);
    rclcpp::spin(std::make_shared<TalkerNode>());
    rclcpp::shutdown();
    return 0;
}
```

### 启动文件示例
```python
from launch import LaunchDescription
from launch_ros.actions import Node
from launch.actions import DeclareLaunchArgument
from launch.substitutions import LaunchConfiguration


def generate_launch_description():
    use_sim_time = LaunchConfiguration('use_sim_time', default='false')
    
    return LaunchDescription([
        DeclareLaunchArgument(
            'use_sim_time',
            default_value='false',
            description='Use simulation (Gazebo) clock if true'
        ),
        
        Node(
            package='beginner_tutorials',
            executable='talker',
            name='talker',
            output='screen',
            parameters=[{'use_sim_time': use_sim_time}]
        ),
        
        Node(
            package='beginner_tutorials',
            executable='listener',
            name='listener',
            output='screen',
            parameters=[{'use_sim_time': use_sim_time}]
        )
    ])
```

---

## 总结

ROS2 是基于 DDS 的新一代机器人开发框架，与 ROS1 的主要差异：

- 构建系统：catkin_make → colcon
- 通信中间件：ROS Master → DDS，ros2 daemon 按需启动
- 参数系统：节点级参数，支持类型描述与动态声明（ros2 param describe）
- 多机通信：以 ROS_DOMAIN_ID 隔离，无需配置 ROS_MASTER_URI
- 命令体系：ros1 工具统一替换为 ros2 子命令（rosnode → ros2 node 等）