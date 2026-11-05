这是一个更新后的 **Makefile 模板**，增加了对 **静态库（.a）和共享库（.so）** 的支持，并附带详细注释说明。适用于需要同时编译可执行文件、静态库和动态库的 C/C++ 项目。


### **关键更新说明**
#### **1. 新增库支持**
- **静态库（.a）**  
  - 使用 `ar` 工具打包目标文件（`.o`）生成静态库。  
  - 命令：`ar rcs $(STATIC_LIB) $(OBJS)`  
    - `r`：替换已存在的文件  
    - `c`：创建库文件  
    - `s`：添加索引  

- **共享库（.so）**  
  - 使用 `g++ -shared` 生成位置无关的动态库。  
  - 编译时需加 `-fPIC` 选项（位置无关代码）。  

#### **2. 新增目录和变量**
- `LIB_DIR`：存放生成的库文件（`.a` 和 `.so`）。  
- `INCLUDE_DIR`：头文件目录，通过 `-I$(INCLUDE_DIR)` 传递给编译器。  
- `LIB_NAME`：库的名称（如 `mylib` 会生成 `libmylib.a` 和 `libmylib.so`）。  

#### **3. 编译选项更新**
- **`-fPIC`**：  
   - 必须用于共享库编译，确保代码可被加载到任意内存地址。  
   - 对静态库非必需，但建议统一添加以兼容性。  

#### **4. 多目标生成**
- `all` 目标现在同时依赖 `$(TARGET)`、`$(STATIC_LIB)` 和 `$(SHARED_LIB)`。  

---

### **使用示例**
#### **项目结构**
```
project/
├── Makefile
├── include/           # 头文件
│   └── utils.h
├── src/               # 源代码
│   ├── main.c
│   └── utils.cpp
├── obj/              # 自动生成
├── bin/              # 可执行文件
└── lib/              # 库文件（自动生成）
```

#### **编译和运行**
```bash
make              # 编译可执行文件、静态库和共享库
./bin/app         # 运行程序
make clean        # 清理所有生成文件
```

#### **使用生成的库**
- **静态库链接**：  
  ```bash
  gcc -o myapp myapp.c -L./lib -lmylib
  ```
- **共享库链接**（需设置库路径）：  
  ```bash
  export LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH
  gcc -o myapp myapp.c -L./lib -lmylib
  ```

---

### **扩展场景**
#### **1. 仅编译静态库或共享库**
```makefile
# 只编译静态库
static: $(STATIC_LIB)

# 只编译共享库
shared: $(SHARED_LIB)
```
运行：  
```bash
make static   # 仅生成 libmylib.a
make shared  # 仅生成 libmylib.so
```

#### **2. 添加外部依赖库**
在 `LDFLAGS` 中指定库路径和库名：  
```makefile
LDFLAGS := -L/path/to/external/lib -lmylib -lpthread
```

#### **3. 安装库到系统路径**
添加 `install` 目标：  
```makefile
install:
	cp $(STATIC_LIB) /usr/local/lib/
	cp $(SHARED_LIB) /usr/local/lib/
	cp $(INCLUDE_DIR)/*.h /usr/local/include/
	ldconfig  # 更新共享库缓存
```

---

### **总结**
- **静态库**：适合代码直接嵌入可执行文件，避免运行时依赖。  
- **共享库**：适合动态加载，减少内存占用，需管理运行时路径（`LD_LIBRARY_PATH`）。  
- **通用性**：通过 `-fPIC` 和灵活的目录结构支持多种构建需求。  

按需调整 `LIB_NAME` 和 `INCLUDE_DIR` 即可快速适配你的项目！