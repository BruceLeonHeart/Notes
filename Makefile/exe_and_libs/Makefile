# 定义编译器
CC := gcc
CXX := g++

# 编译选项
CFLAGS := -Wall -Wextra -g -fPIC          # C 编译选项: 启用所有警告、调试信息和位置无关代码（PIC）
CXXFLAGS := -Wall -Wextra -g -fPIC -std=c++11  # C++ 编译选项: 启用 C++11 标准
LDFLAGS := -lm                            # 链接器选项: 例如链接数学库

# 目录定义
SRC_DIR := src
OBJ_DIR := obj
BIN_DIR := bin
LIB_DIR := lib
INCLUDE_DIR := include

# 源文件和目标文件
SRCS := $(wildcard $(SRC_DIR)/*.c)          # 获取所有 .c 文件
CXX_SRCS := $(wildcard $(SRC_DIR)/*.cpp)    # 获取所有 .cpp 文件
OBJS := $(patsubst $(SRC_DIR)/%.c, $(OBJ_DIR)/%.o, $(SRCS))  # .c -> .o
OBJS += $(patsubst $(SRC_DIR)/%.cpp, $(OBJ_DIR)/%.o, $(CXX_SRCS))  # .cpp -> .o

# 库文件名（静态库和共享库）
LIB_NAME := mylib
STATIC_LIB := $(LIB_DIR)/lib$(LIB_NAME).a    # 静态库
SHARED_LIB := $(LIB_DIR)/lib$(LIB_NAME).so   # 共享库

# 最终可执行文件名
TARGET := $(BIN_DIR)/app

# 默认目标: 编译可执行文件、静态库和共享库
all: $(TARGET) $(STATIC_LIB) $(SHARED_LIB)

# 链接目标文件生成可执行文件
$(TARGET): $(OBJS)
	@mkdir -p $(@D)  # 确保 bin 目录存在
	$(CXX) $(OBJS) -o $@ $(LDFLAGS)

# 生成静态库（.a）
$(STATIC_LIB): $(OBJS)
	@mkdir -p $(LIB_DIR)
	ar rcs $@ $^  # ar: 静态库打包工具

# 生成共享库（.so）
$(SHARED_LIB): $(OBJS)
	@mkdir -p $(LIB_DIR)
	$(CXX) -shared $^ -o $@ $(LDFLAGS)  # -shared: 生成共享库

# 编译 C 源文件
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -I$(INCLUDE_DIR) -c $< -o $@  # -I: 添加头文件路径

# 编译 C++ 源文件
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -I$(INCLUDE_DIR) -c $< -o $@

# 清理生成的文件
clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR) $(LIB_DIR)

# 伪目标声明
.PHONY: all clean