# ROS 常用操作笔记

> 类型：command
> 一句话：ROS 常用命令手册


## 基础概念

### ROS核心概念
- **节点（Node）**: 执行具体功能的进程
- **话题（Topic）**: 节点间通信的通道
- **消息（Message）**: 话题传输的数据结构
- **服务（Service）**: 节点间的请求-响应通信
- **动作（Action）**: 长时间运行的服务
- **参数（Parameter）**: 节点的配置值
- **包（Package）**: ROS软件的基本组织单元
- **工作空间（Workspace）**: 存放ROS包的目录结构

### ROS版本
- **Noetic Ninjemys**: Ubuntu 20.04（ROS1 最后一个 LTS 版本，维护至 2025 年）
- **Melodic Morenia**: Ubuntu 18.04（已停止维护）
- **Kinetic Kame**: Ubuntu 16.04（已停止维护）

---

## 工作空间操作

### 创建工作空间
```bash
# 创建工作空间目录
mkdir -p ~/catkin_ws/src

# 初始化工作空间
cd ~/catkin_ws
catkin_make

# 激活工作空间
source devel/setup.bash

# 验证工作空间
echo $ROS_PACKAGE_PATH
```

### 管理工作空间
```bash
# 编译工作空间
cd ~/catkin_ws
catkin_make

# 清理工作空间
cd ~/catkin_ws
catkin_make clean

# 编译特定包
cd ~/catkin_ws
catkin_make -DCATKIN_WHITELIST_PACKAGES="package_name"

# 编译多个包
cd ~/catkin_ws
catkin_make -DCATKIN_WHITELIST_PACKAGES="package1;package2"
```

### 工作空间环境变量
```bash
# 添加工作空间到bashrc
echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc
source ~/.bashrc

# 查看ROS环境变量
printenv | grep ROS

# 临时设置ROS环境变量
export ROS_MASTER_URI=http://localhost:11311
export ROS_HOSTNAME=localhost
```

---

## 包操作

### 创建包
```bash
# 在工作空间中创建包
cd ~/catkin_ws/src
catkin_create_pkg package_name roscpp rospy std_msgs

# 创建带多个依赖的包
cd ~/catkin_ws/src
catkin_create_pkg package_name roscpp rospy std_msgs sensor_msgs geometry_msgs
```

### 查看包
```bash
# 查找包
rospack find package_name

# 列出所有包
rospack list

# 查看包的依赖
rospack depends package_name
rospack depends1 package_name

# 查看包的清单
rospack profile
```

### 包的结构
```text
package_name/
├── CMakeLists.txt      # CMake构建配置文件
├── package.xml         # 包的元数据和依赖
├── src/                # 源代码
├── include/            # 头文件
├── scripts/            # Python脚本
├── launch/             # 启动文件
├── config/             # 配置文件
└── msg/                # 自定义消息
```

---

## 节点操作

### 运行节点
```bash
# 运行单个节点
rosrun package_name node_name

# 运行节点并设置参数
rosrun package_name node_name _param_name:=value

# 在特定命名空间运行节点
rosrun package_name node_name __ns:=/namespace

# 重映射节点名称
rosrun package_name node_name __name:=new_node_name
```

### 查看节点
```bash
# 列出所有运行的节点
rosnode list

# 查看节点信息
rosnode info /node_name

# 检查节点是否存在
rosnode ping /node_name

# 杀死节点
rosnode kill /node_name

# 清理僵尸节点
rosnode cleanup
```

---

## 话题操作

### 查看话题
```bash
# 列出所有话题
rostopic list

# 列出话题及发布者/订阅者
rostopic list -v

# 查看话题类型
rostopic type /topic_name

# 查看话题信息
rostopic info /topic_name

# 查看话题数据
rostopic echo /topic_name

# 查看话题数据的前N条
rostopic echo /topic_name -n 10

# 实时查看话题带宽
rostopic bw /topic_name

# 查看话题频率
rostopic hz /topic_name
```

### 发布话题
```bash
# 发布字符串消息
rostopic pub /topic_name std_msgs/String "data: 'hello'"

# 发布一次消息
rostopic pub -1 /topic_name std_msgs/String "data: 'hello'"

# 持续发布消息（10Hz）
rostopic pub -r 10 /topic_name std_msgs/String "data: 'hello'"

# 发布复杂消息
rostopic pub /cmd_vel geometry_msgs/Twist "linear: {x: 0.1, y: 0.0, z: 0.0}" "angular: {x: 0.0, y: 0.0, z: 0.1}"
```

---

## 服务操作

### 查看服务
```bash
# 列出所有服务
rosservice list

# 查看服务类型
rosservice type /service_name

# 查看服务信息
rosservice info /service_name

# 调用服务
rosservice call /service_name

# 调用带参数的服务
rosservice call /add_two_ints "a: 1, b: 2"

# 查看服务参数
rosservice args /service_name
```

### 创建服务
```bash
# 定义服务文件 (srv/AddTwoInts.srv)
int64 a
int64 b
---
int64 sum

# 编译服务
cd ~/catkin_ws
catkin_make
```

---

## 消息操作

### 查看消息
```bash
# 列出所有消息类型
rosmsg list

# 查看消息定义
rosmsg show std_msgs/String

# 列出某个包中的所有消息
rosmsg package geometry_msgs

# 查看消息的 md5 校验和
rosmsg md5 std_msgs/String
```

### 创建消息
```bash
# 定义消息文件 (msg/Person.msg)
string name
int32 age
float32 height

# 编译消息
cd ~/catkin_ws
catkin_make
```

---

## 动作操作

### 查看动作
```bash
# 列出所有动作
rostopic list | grep action

# 查看动作类型
rosmsg show actionlib_tutorials/FibonacciAction

# 查看动作目标
rosmsg show actionlib_tutorials/FibonacciGoal

# 查看动作结果
rosmsg show actionlib_tutorials/FibonacciResult

# 查看动作反馈
rosmsg show actionlib_tutorials/FibonacciFeedback
```

### 发送动作目标
```bash
# 使用actionlib发送目标
rosrun actionlib_tutorials fibonacci_client
```

---

## 参数操作

### 查看参数
```bash
# 列出所有参数
rosparam list

# 查看参数值（返回 YAML 格式，可据此判断参数类型）
rosparam get /param_name

# 查看某个命名空间下的所有参数
rosparam get /namespace

# 查看参数树
rosparam dump -v
```

### 设置参数
```bash
# 设置参数
rosparam set /param_name value

# 设置嵌套参数
rosparam set /namespace/param_name value

# 从文件加载参数
rosparam load params.yaml

# 保存参数到文件
rosparam dump params.yaml

# 删除参数
rosparam delete /param_name
```

---

## 启动文件操作

### 运行启动文件
```bash
# 运行启动文件
roslaunch package_name launch_file.launch

# 带参数运行启动文件
roslaunch package_name launch_file.launch param_name:=value

# 在特定命名空间运行
roslaunch package_name launch_file.launch __ns:=/namespace

# 查看启动文件内容
roslaunch --args package_name launch_file.launch
```

### 启动文件示例
```xml
<launch>
  <!-- 启动节点 -->
  <node name="talker" pkg="rospy_tutorials" type="talker.py" output="screen"/>
  
  <!-- 带参数的节点 -->
  <node name="listener" pkg="rospy_tutorials" type="listener.py" output="screen">
    <param name="queue_size" value="10"/>
  </node>
  
  <!-- 重映射话题 -->
  <node name="remapped_talker" pkg="rospy_tutorials" type="talker.py" output="screen">
    <remap from="chatter" to="my_chatter"/>
  </node>
  
  <!-- 包含其他启动文件 -->
  <include file="$(find package_name)/launch/other_launch.launch"/>
  
  <!-- 设置全局参数 -->
  <param name="robot_name" value="turtlebot"/>
  
  <!-- 声明参数（须在引用它的 group 之前声明） -->
  <arg name="use_sim_time" default="false"/>

  <!-- 条件执行 -->
  <group if="$(arg use_sim_time)">
    <param name="use_sim_time" value="true"/>
  </group>
</launch>
```

---

## 工具操作

### 常用工具
```bash
# 查看ROS计算图
rosrun rqt_graph rqt_graph

# 查看话题数据可视化
rosrun rqt_plot rqt_plot

# 查看服务和参数
rosrun rqt_reconfigure rqt_reconfigure

# 查看节点信息
rosrun rqt_console rqt_console

# 查看TF树
rosrun rqt_tf_tree rqt_tf_tree

# 查看消息内容
rosrun rqt_msg rqt_msg
```

### 日志工具
```bash
# 查看ROS日志
roscd log
ls -la

# 查看特定节点的日志
rosrun rqt_console rqt_console --clear

# 查看rosout
rostopic echo /rosout
```

### 诊断工具
```bash
# 运行诊断聚合器
roslaunch diagnostics diagnostics.launch

# 查看诊断信息
rostopic echo /diagnostics

# 查看硬件状态
rosrun diagnostic_updater test_diagnostic_updater
```

---

## 导航和机器人操作

### 导航工具
```bash
# 启动导航堆栈
roslaunch turtlebot3_navigation turtlebot3_navigation.launch

# 发布目标位置
rosrun move_base send_goal.py

# 查看地图
rosrun map_server map_saver -f ~/map

# 查看机器人位置
rosrun tf tf_echo /map /base_link
```

### 机器人状态
```bash
# 查看机器人关节状态
rostopic echo /joint_states

# 查看机器人TF变换
rosrun tf tf_monitor

# 查看机器人里程计
rostopic echo /odom

# 查看激光数据
rostopic echo /scan
```

---

## 通信和网络

### 多机通信
```bash
# 在主机上设置
# 主机IP: 192.168.1.100
export ROS_MASTER_URI=http://192.168.1.100:11311
export ROS_HOSTNAME=192.168.1.100

# 在从机上设置
export ROS_MASTER_URI=http://192.168.1.100:11311
export ROS_HOSTNAME=192.168.1.101

# 测试连接
rosnode ping /rosout
```

### 网络配置
```bash
# 查看ROS主节点URI
echo $ROS_MASTER_URI

# 查看ROS主机名
echo $ROS_HOSTNAME

# 查看ROS IP
echo $ROS_IP

# 临时设置网络参数
export ROS_MASTER_URI=http://localhost:11311
export ROS_HOSTNAME=localhost
```

---

## 调试和开发

### 调试工具
```bash
# 使用gdb调试C++节点
rosrun --prefix "gdb -ex run --args" package_name node_name

# 使用valgrind检查内存
rosrun --prefix "valgrind" package_name node_name

# 查看节点信息（连接关系、发布/订阅话题、提供的服务等）
rosnode info /node_name

# 查看ROS节点的启动时间
rosnode info /node_name | grep Time
```

### 开发工具
```bash
# 代码自动生成
rosrun gencpp gen_cpp.py msg
rosrun genpy gen_py.py msg

# 消息生成
rosmsg show package_name/MessageType

# 查看服务定义
rossrv show package_name/ServiceType

# 查看动作定义（action 本质是消息类型，用 rosmsg 查看）
rosmsg show package_name/ActionType
```

---

## 常用命令速查

### 核心命令
```bash
# ROS核心
roscore                    # 启动ROS核心
rosrun <pkg> <node>        # 运行节点
roslaunch <pkg> <launch>    # 运行启动文件

# 节点管理
rosnode list               # 列出节点
rosnode info <node>        # 节点信息
rosnode kill <node>        # 杀死节点

# 话题管理
rostopic list              # 列出话题
rostopic echo <topic>      # 查看话题数据
rostopic pub <topic> <msg> # 发布话题
rostopic type <topic>      # 话题类型

# 服务管理
rosservice list            # 列出服务
rosservice call <service>  # 调用服务
rosservice type <service>  # 服务类型

# 参数管理
rosparam list              # 列出参数
rosparam get <param>       # 获取参数
rosparam set <param> <val> # 设置参数

# 包管理
rospack find <pkg>         # 查找包
rospack list               # 列出包
catkin_create_pkg <pkg> <deps> # 创建包

# 编译
catkin_make                # 编译工作空间
catkin_make clean          # 清理工作空间
```

### 实用命令
```bash
# 查看ROS版本
rosversion -d

# 查看ROS环境
printenv | grep ROS

# 查找可执行文件
rospack find <pkg> && ls -la $(rospack find <pkg>)/bin

# 查看消息定义
rosmsg show <msg>

# 查看服务定义
rossrv show <srv>

# 查看动作定义
rosmsg show <action>

# 查看TF变换
rosrun tf tf_echo <frame1> <frame2>

# 查看地图
rosrun map_server map_saver -f <map_name>

# 查看机器人状态
rostopic echo /joint_states
```

---

## 常见问题解决

### 网络问题
```bash
# 检查ROS主节点是否运行
rosnode ping /rosout

# 检查网络连接
ping $(echo $ROS_MASTER_URI | cut -d'/' -f3 | cut -d':' -f1)

# 重启ROS核心
killall -9 rosmaster
roscore
```

### 编译问题
```bash
# 清理并重新编译
cd ~/catkin_ws
catkin_make clean
catkin_make

# 检查依赖
rosdep check package_name
rosdep install --from-paths src --ignore-src -r -y

# 检查CMakeLists.txt
catkin_lint package_name
```

### 节点问题
```bash
# 检查节点是否存在
rosnode list | grep node_name

# 检查节点日志
roscd log
ls -la | grep node_name

# 检查节点启动命令
rosrun package_name node_name --help
```

### 话题问题
```bash
# 检查话题是否存在
rostopic list | grep topic_name

# 检查话题类型
rostopic type /topic_name

# 检查发布者和订阅者
rostopic info /topic_name

# 检查消息格式
rostopic echo /topic_name | head -n 10
```

---

## 最佳实践

### 代码组织
- 按照功能模块组织包
- 使用Catkin工作空间管理代码
- 遵循ROS命名约定（小写+下划线）
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
- 合理使用ROS参数

### 调试技巧
- 使用rosconsole进行日志记录
- 使用rqt工具进行可视化调试
- 使用gdb进行C++代码调试
- 使用rostopic echo查看消息内容
- 使用rosnode info查看节点状态

---

## 学习资源

### 官方资源
- [ROS官方文档](http://wiki.ros.org/)
- [ROS教程](http://wiki.ros.org/ROS/Tutorials)
- [ROS API文档](http://docs.ros.org/)

### 书籍
- 《ROS机器人编程》
- 《Learning ROS for Robotics Programming》
- 《Mastering ROS for Robotics Programming》

### 在线教程
- [ROS Wiki](http://wiki.ros.org/)
- [ROS Answers](https://answers.ros.org/)
- [YouTube ROS教程](https://www.youtube.com/results?search_query=ros+tutorial)

### 社区资源
- [ROS Discourse](https://discourse.ros.org/)
- [ROS GitHub](https://github.com/ros)
- [ROS社区](https://rosindex.github.io/)

---

## 示例代码

### Python节点示例
```python
#!/usr/bin/env python
import rospy
from std_msgs.msg import String

def talker():
    pub = rospy.Publisher('chatter', String, queue_size=10)
    rospy.init_node('talker', anonymous=True)
    rate = rospy.Rate(10)  # 10Hz
    while not rospy.is_shutdown():
        hello_str = "hello world %s" % rospy.get_time()
        rospy.loginfo(hello_str)
        pub.publish(hello_str)
        rate.sleep()

if __name__ == '__main__':
    try:
        talker()
    except rospy.ROSInterruptException:
        pass
```

### C++节点示例
```cpp
#include <ros/ros.h>
#include <std_msgs/String.h>

int main(int argc, char **argv) {
    ros::init(argc, argv, "talker");
    ros::NodeHandle n;
    ros::Publisher chatter_pub = n.advertise<std_msgs::String>("chatter", 1000);
    ros::Rate loop_rate(10);
    int count = 0;
    while (ros::ok()) {
        std_msgs::String msg;
        std::stringstream ss;
        ss << "hello world " << count;
        msg.data = ss.str();
        ROS_INFO("%s", msg.data.c_str());
        chatter_pub.publish(msg);
        ros::spinOnce();
        loop_rate.sleep();
        ++count;
    }
    return 0;
}
```

### 启动文件示例
```xml
<launch>
  <!-- 启动roscore -->
  <master auto="start" />
  
  <!-- 启动talker节点 -->
  <node name="talker" pkg="beginner_tutorials" type="talker" output="screen" />
  
  <!-- 启动listener节点 -->
  <node name="listener" pkg="beginner_tutorials" type="listener" output="screen" />
  
  <!-- 设置参数 -->
  <param name="use_sim_time" value="false" />
  
  <!-- 重映射话题 -->
  <node name="listener_remapped" pkg="beginner_tutorials" type="listener" output="screen">
    <remap from="chatter" to="my_chatter" />
  </node>
</launch>
```

---

## 总结

ROS 是基于节点间通信（话题/服务/动作）的机器人开发框架。常用操作速查：

- 工作空间：catkin_make 编译，source devel/setup.bash 激活
- 通信前提：roscore 启动 ROS Master
- 节点：rosnode list / rosnode info
- 话题：rostopic list / echo / pub / hz / bw
- 服务：rosservice list / call / type
- 参数：rosparam set / get / dump / load
- 多节点编排：roslaunch 统一启动
