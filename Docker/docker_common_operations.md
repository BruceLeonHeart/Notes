# Docker 常见操作笔记

> 类型：command
> 一句话：Docker 常用命令手册


## 基础概念

### Docker核心组件
- **镜像**: 只读的模板，用于创建容器
- **容器**: 镜像的运行实例
- **仓库**: 存储和分发镜像的地方
- **Dockerfile**: 用于构建镜像的脚本文件

### Docker架构
- **Docker客户端**: 用户与Docker交互的界面
- **Docker守护进程**: 管理Docker对象的后台服务
- **Docker注册表**: 存储Docker镜像的服务

---

## 镜像操作

### 拉取镜像
```bash
# 拉取最新版本
docker pull ubuntu

# 拉取指定版本
docker pull ubuntu:20.04

# 拉取多个镜像
docker pull nginx redis mysql
```

### 查看镜像
```bash
# 列出所有镜像
docker images

# 列出所有镜像（包括中间层）
docker images -a

# 只显示镜像ID
docker images -q

# 格式化输出
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

### 构建镜像
```bash
# 基本构建
docker build -t myapp:1.0 .

# 指定Dockerfile路径
docker build -f /path/to/Dockerfile -t myapp:1.0 .

# 构建时不使用缓存
docker build --no-cache -t myapp:1.0 .

# 构建时传递构建参数
docker build --build-arg VERSION=1.0 -t myapp:1.0 .
```

### 删除镜像
```bash
# 删除指定镜像
docker rmi myapp:1.0

# 删除多个镜像
docker rmi myapp:1.0 myapp:2.0

# 强制删除镜像
docker rmi -f myapp:1.0

# 删除所有未使用的镜像
docker image prune

# 删除所有悬空镜像
docker image prune -a

# 删除所有镜像（慎用）
docker rmi $(docker images -q)
```

### 导出和导入镜像
```bash
# 导出镜像到文件
docker save -o myapp.tar myapp:1.0

# 从文件导入镜像
docker load -i myapp.tar

# 导入镜像并重命名
docker load < myapp.tar | grep "Loaded image"
```

### 标记镜像
```bash
# 为镜像添加标签
docker tag myapp:1.0 myapp:latest

# 为镜像添加多个标签
docker tag myapp:1.0 registry.example.com/myapp:1.0
```

### 搜索镜像
```bash
# 搜索镜像
docker search nginx

# 搜索官方镜像
docker search --filter is-official=true nginx

# 搜索自动化构建的镜像
docker search --filter is-automated=true nginx

# 限制搜索结果数量
docker search --limit 5 nginx
```

---

## 容器操作

### 运行容器
```bash
# 基本运行
docker run ubuntu

# 交互式运行
docker run -it ubuntu bash

# 后台运行
docker run -d nginx

# 指定容器名称
docker run --name mynginx nginx

# 端口映射
docker run -p 8080:80 nginx

# 挂载卷
docker run -v /host/path:/container/path nginx

# 设置环境变量
docker run -e APP_ENV=production nginx

# 删除容器（退出后自动删除）
docker run --rm nginx

# 重启策略
docker run --restart=always nginx
docker run --restart=on-failure:5 nginx
docker run --restart=unless-stopped nginx
```

### 查看容器
```bash
# 列出运行中的容器
docker ps

# 列出所有容器（包括停止的）
docker ps -a

# 只显示容器ID
docker ps -q

# 显示容器大小
docker ps -s

# 显示最新创建的容器
docker ps -l

# 格式化输出
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### 启动和停止容器
```bash
# 启动容器
docker start mycontainer

# 停止容器
docker stop mycontainer

# 强制停止容器
docker kill mycontainer

# 重启容器
docker restart mycontainer

# 暂停容器
docker pause mycontainer

# 恢复容器
docker unpause mycontainer
```

### 进入容器
```bash
# 使用exec进入运行中的容器
docker exec -it mycontainer bash

# 使用attach连接到容器
docker attach mycontainer

# 在容器中执行命令
docker exec mycontainer ls -la

# 以特定用户执行命令
docker exec -u root mycontainer whoami
```

### 删除容器
```bash
# 删除指定容器
docker rm mycontainer

# 强制删除运行中的容器
docker rm -f mycontainer

# 删除多个容器
docker rm container1 container2 container3

# 删除所有停止的容器
docker container prune

# 删除所有容器（包括运行中的）
docker rm -f $(docker ps -aq)
```

### 容器日志
```bash
# 查看容器日志
docker logs mycontainer

# 实时查看日志
docker logs -f mycontainer

# 显示最后100行
docker logs --tail 100 mycontainer

# 显示最近10分钟的日志
docker logs --since 10m mycontainer

# 显示特定时间段的日志
docker logs --since "2024-01-01T00:00:00" --until "2024-01-01T23:59:59" mycontainer

# 显示时间戳
docker logs -t mycontainer
```

### 容器信息
```bash
# 查看容器详细信息
docker inspect mycontainer

# 查看容器IP地址
docker inspect --format='{{.NetworkSettings.IPAddress}}' mycontainer

# 查看容器端口映射
docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}}{{$p}} -> {{(index $conf 0).HostPort}}{{"\n"}}{{end}}' mycontainer

# 查看容器资源使用情况
docker stats mycontainer

# 查看所有容器的资源使用情况
docker stats
```

### 容器文件操作
```bash
# 从容器复制文件到主机
docker cp mycontainer:/path/to/file /host/path

# 从主机复制文件到容器
docker cp /host/path mycontainer:/path/to/file

# 在容器中创建目录
docker exec mycontainer mkdir -p /path/to/dir

# 查看容器文件系统变化
docker diff mycontainer
```

### 容器导出和导入
```bash
# 导出容器为镜像
docker commit mycontainer mynewimage:1.0

# 导出容器为文件
docker export mycontainer > mycontainer.tar

# 从文件导入为镜像
docker import mycontainer.tar mynewimage:1.0
```

---

## 网络操作

### 查看网络
```bash
# 列出所有网络
docker network ls

# 查看网络详细信息
docker network inspect mynetwork

# 查看容器连接的网络
docker inspect --format='{{range $net, $v := .NetworkSettings.Networks}}{{$net}}{{end}}' mycontainer
```

### 创建网络
```bash
# 创建bridge网络
docker network create mynetwork

# 创建自定义bridge网络
docker network create --driver bridge mynetwork

# 创建网络并指定子网
docker network create --subnet=192.168.0.0/16 mynetwork

# 创建网络并指定网关
docker network create --gateway=192.168.0.1 mynetwork
```

### 连接容器到网络
```bash
# 运行容器时连接到网络
docker run --network mynetwork nginx

# 将运行中的容器连接到网络
docker network connect mynetwork mycontainer

# 指定容器在网络中的别名
docker network connect --alias web mynetwork mycontainer

# 断开容器与网络的连接
docker network disconnect mynetwork mycontainer
```

### 删除网络
```bash
# 删除指定网络
docker network rm mynetwork

# 删除所有未使用的网络
docker network prune

# 删除所有网络（慎用）
docker network rm $(docker network ls -q)
```

### 网络类型
- **bridge**: 默认网络模式，容器间通过bridge通信
- **host**: 容器使用主机的网络栈
- **none**: 容器没有网络连接
- **overlay**: 跨主机通信的网络模式
- **macvlan**: 为容器分配MAC地址

---

## 存储操作

### 数据卷
```bash
# 创建数据卷
docker volume create myvolume

# 列出所有数据卷
docker volume ls

# 查看数据卷详细信息
docker volume inspect myvolume

# 删除数据卷
docker volume rm myvolume

# 删除所有未使用的数据卷
docker volume prune

# 使用数据卷运行容器
docker run -v myvolume:/data nginx

# 查看数据卷使用情况
docker system df -v
```

### 绑定挂载
```bash
# 挂载主机目录到容器
docker run -v /host/path:/container/path nginx

# 只读挂载
docker run -v /host/path:/container/path:ro nginx

# 挂载单个文件
docker run -v /host/file:/container/file nginx

# 指定挂载选项
docker run -v /host/path:/container/path:rw,z nginx
```

### 临时文件系统
```bash
# 创建临时文件系统
docker run --tmpfs /tmp nginx

# 指定临时文件系统大小
docker run --tmpfs /tmp:rw,size=100m nginx

# 指定临时文件系统权限
docker run --tmpfs /tmp:rw,noexec,nosuid,size=100m nginx
```

---

## Docker Compose

### 基本操作
```bash
# 启动服务
docker-compose up

# 后台启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 停止并删除数据卷
docker-compose down -v

# 重启服务
docker-compose restart

# 查看服务状态
docker-compose ps

# 查看服务日志
docker-compose logs

# 实时查看日志
docker-compose logs -f

# 查看特定服务的日志
docker-compose logs -f web

# 构建服务
docker-compose build

# 构建并启动服务
docker-compose up --build

# 重新构建服务
docker-compose build --no-cache

# 执行服务中的命令
docker-compose exec web bash

# 在服务中运行一次性命令
docker-compose run web python script.py

# 扩展服务
docker-compose up -d --scale web=3

# 查看服务资源使用情况
docker-compose top
```

### Docker Compose配置示例

> 注：Compose v2 已不需要 version 字段，可省略。

```yaml
# 注意：Compose v2 已不需要 version 字段，可省略
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8000:8000"
    volumes:
      - .:/app
    environment:
      - DEBUG=true
    depends_on:
      - db
    networks:
      - frontend
      - backend

  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=mydb
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - dbdata:/var/lib/postgresql/data
    networks:
      - backend

  redis:
    image: redis:alpine
    networks:
      - backend

volumes:
  dbdata:

networks:
  frontend:
  backend:
```

---

## 系统管理

### Docker信息
```bash
# 查看Docker系统信息
docker info

# 查看Docker版本
docker version

# 查看Docker详细信息
docker info --format '{{.ServerVersion}}'

# 查看Docker事件
docker events

# 实时查看Docker事件
docker events -f
```

### 系统清理
```bash
# 清理未使用的镜像、容器、网络、数据卷
docker system prune

# 清理所有未使用的资源
docker system prune -a

# 清理所有未使用的资源（包括构建缓存）
docker system prune -a --volumes

# 查看磁盘使用情况
docker system df

# 查看详细磁盘使用情况
docker system df -v
```

### Docker服务管理
```bash
# 启动Docker服务
sudo systemctl start docker

# 停止Docker服务
sudo systemctl stop docker

# 重启Docker服务
sudo systemctl restart docker

# 查看Docker服务状态
sudo systemctl status docker

# 开机启动Docker
sudo systemctl enable docker

# 禁用开机启动Docker
sudo systemctl disable docker
```

---

## Dockerfile编写

### 基本指令
```dockerfile
# 基础镜像
FROM ubuntu:20.04

# 维护者信息（MAINTAINER 指令已废弃，官方推荐使用 LABEL 替代）
LABEL maintainer="作者 <email>"

# 设置工作目录
WORKDIR /app

# 复制文件
COPY . /app

# 复制文件并解压
ADD archive.tar.gz /app

# 运行命令
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# 设置环境变量
ENV PATH="/app:${PATH}"
ENV APP_ENV="production"

# 暴露端口
EXPOSE 8000

# 添加数据卷
VOLUME /data

# 设置用户
USER appuser

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8000/health || exit 1

# 容器启动时执行的命令
CMD ["python3", "app.py"]

# 容器启动时执行的命令（可被覆盖）
ENTRYPOINT ["python3"]
```

### 多阶段构建
```dockerfile
# 构建阶段
FROM node:16-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# 运行阶段
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### 最佳实践
- 使用官方基础镜像
- 使用特定版本的标签
- 合并RUN指令减少层数
- 利用缓存机制
- 使用.dockerignore文件
- 最小化镜像大小
- 使用多阶段构建
- 设置非root用户
- 使用健康检查

---

## 常见问题解决

### 容器无法启动
```bash
# 查看容器日志
docker logs mycontainer

# 查看容器详细信息
docker inspect mycontainer

# 检查端口是否被占用
netstat -tuln | grep 8000

# 检查防火墙设置
sudo iptables -L
```

### 容器网络问题
```bash
# 检查容器网络连接
docker network inspect mynetwork

# 测试容器间连接
docker exec container1 ping container2

# 检查DNS解析
docker exec mycontainer nslookup google.com

# 重启Docker网络
sudo systemctl restart docker
```

### 磁盘空间不足
```bash
# 清理未使用的资源
docker system prune -a --volumes

# 删除悬空镜像
docker image prune -a

# 删除停止的容器
docker container prune

# 删除未使用的数据卷
docker volume prune

# 查看磁盘使用情况
docker system df -v
```

### 权限问题
```bash
# 将用户添加到docker组
sudo usermod -aG docker $USER

# 重新登录使组权限生效
newgrp docker

# 修改文件权限
sudo chown -R $USER:$USER /path/to/volume
```

### 性能优化
```bash
# 限制容器内存使用
docker run -m 512m nginx

# 限制容器CPU使用
docker run --cpus="1.5" nginx

# 设置CPU权重
docker run --cpu-shares=512 nginx

# 限制容器IO
docker run --device-read-bps /dev/sda:1mb nginx
```

---

## 实用技巧

### 批量操作
```bash
# 停止所有容器
docker stop $(docker ps -aq)

# 删除所有容器
docker rm $(docker ps -aq)

# 删除所有镜像
docker rmi $(docker images -q)

# 删除所有悬空镜像
docker rmi $(docker images -f "dangling=true" -q)

# 批量重启容器
docker restart $(docker ps -q)
```

### 监控和调试
```bash
# 实时查看容器资源使用
docker stats

# 查看容器进程
docker top mycontainer

# 查看容器端口映射
docker port mycontainer

# 查看容器文件系统变化
docker diff mycontainer

# 在容器中安装调试工具
docker exec -it mycontainer apt-get update && apt-get install -y vim
```

### 备份和恢复
```bash
# 备份数据卷
docker run --rm -v myvolume:/data -v $(pwd):/backup ubuntu tar czf /backup/myvolume-backup.tar.gz /data

# 恢复数据卷
docker run --rm -v myvolume:/data -v $(pwd):/backup ubuntu tar xzf /backup/myvolume-backup.tar.gz -C /

# 备份容器
docker commit mycontainer mycontainer-backup:$(date +%Y%m%d)

# 导出镜像
docker save -o myapp-backup.tar myapp:1.0
```

### 安全最佳实践
```bash
# 使用非root用户运行容器
docker run -u 1000:1000 nginx

# 只读根文件系统
docker run --read-only nginx

# 限制容器能力
docker run --cap-drop=ALL --cap-add=NET_BIND_SERVICE nginx

# 使用seccomp配置
docker run --security-opt seccomp=default.json nginx

# 禁用特权模式
docker run --privileged=false nginx

# 使用AppArmor配置
docker run --security-opt apparmor=docker-default nginx
```

---

## 常用Docker镜像

### Web服务器
```bash
# Nginx
docker run -d -p 80:80 nginx

# Apache
docker run -d -p 80:80 httpd

# Caddy
docker run -d -p 80:80 caddy
```

### 数据库
```bash
# MySQL
docker run -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password mysql:8.0

# PostgreSQL
docker run -d -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:13

# MongoDB
docker run -d -p 27017:27017 mongo

# Redis
docker run -d -p 6379:6379 redis
```

### 开发环境
```bash
# Python
docker run -it python:3.11 bash

# Node.js
docker run -it node:18 bash

# Go
docker run -it golang:1.21 bash

# Java
docker run -it openjdk:17 bash
```

### 工具镜像
```bash
# Git
docker run -it git bash

# Curl
docker run -it curlimages/curl bash

# Busybox
docker run -it busybox sh

# Alpine
docker run -it alpine sh
```

---

## 学习资源

### 官方文档
- [Docker官方文档](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/)
- [Docker Compose文档](https://docs.docker.com/compose/)

### 最佳实践
- [Dockerfile最佳实践](https://docs.docker.com/develop/dev-best-practices/)
- [Docker安全最佳实践](https://docs.docker.com/engine/security/)
- [Docker性能优化](https://docs.docker.com/develop/dev-best-practices/)

### 社区资源
- [Docker GitHub](https://github.com/docker)
- [Docker论坛](https://forums.docker.com/)
- [Stack Overflow Docker标签](https://stackoverflow.com/questions/tagged/docker)
