# 定义编译器
CC := gcc
CXX := g++

# 编译选项
CFLAGS := -Wall -Wextra -g          # C 编译器选项: 启用所有警告和调试信息
CXXFLAGS := -Wall -Wextra -g -std=c++11  # C++ 编译器选项: 启用 C++11 标准
LDFLAGS := -lm                      # 链接器选项: 例如链接数学库

# 目录定义
#    - `SRC_DIR`：源代码目录（`.c`/`.cpp` 文件）。  
#    - `OBJ_DIR`：存放编译生成的 `.o` 文件。  
#    - `BIN_DIR`：存放最终可执行文件。  
SRC_DIR := src
OBJ_DIR := obj
BIN_DIR := bin

# 源文件和目标文件
#    - `wildcard`：匹配目录下所有 `.c`/`.cpp` 文件。  
#    - `patsubst`：将源文件名替换为目标文件名（`.c` → `.o`）。  
SRCS := $(wildcard $(SRC_DIR)/*.c)          # 获取所有 .c 文件
CXX_SRCS := $(wildcard $(SRC_DIR)/*.cpp)    # 获取所有 .cpp 文件
OBJS := $(patsubst $(SRC_DIR)/%.c, $(OBJ_DIR)/%.o, $(SRCS))  # .c -> .o
OBJS += $(patsubst $(SRC_DIR)/%.cpp, $(OBJ_DIR)/%.o, $(CXX_SRCS))  # .cpp -> .o

# 最终可执行文件名
TARGET := $(BIN_DIR)/app

# 默认目标: 编译所有
#    - `all`：默认目标，依赖 `$(TARGET)`。  
#    - `$(TARGET)`：链接所有 `.o` 文件生成可执行文件。  
#    - `%.o`：编译单个源文件到目标文件，自动区分 C 和 C++。  
#    - `clean`：删除所有生成的文件和目录。  

all: $(TARGET)

# 链接目标文件生成可执行文件
$(TARGET): $(OBJS)
	@mkdir -p $(@D)  # 确保 bin 目录存在
	$(CXX) $(OBJS) -o $@ $(LDFLAGS)  # 使用 C++ 链接器（兼容 C 和 C++ 目标文件）

# 编译 C 源文件
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(@D)  # 确保 obj 目录存在
	$(CC) $(CFLAGS) -c $< -o $@

# 编译 C++ 源文件
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -c $< -o $@

# 清理生成的文件
clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR)

# 伪目标声明（避免和同名文件冲突）
#    - `.PHONY`：声明 `all` 和 `clean` 为伪目标，即使存在同名文件也会执行。
.PHONY: all clean