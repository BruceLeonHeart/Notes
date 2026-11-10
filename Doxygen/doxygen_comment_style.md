# VS Code 中 Doxygen 格式代码注释的自动生成

> 类型：command
> 一句话：VSCode Doxygen 注释插件


在 VS Code 中为 C++ 代码自动生成 Doxygen 风格的注释模板，最常用、最强大的方法是使用 Doxygen 文档注释插件。

从代码注释风格（例如 `//! \brief`、`\param[in]`、`\return`）来看，这正是 Doxygen 的标准格式。Doxygen 是一个流行的 C++ 文档生成工具，可以从源代码中的特殊注释提取信息，生成专业的帮助文档。

VS Code 中专门为此设计的插件是 **Doxygen Documentation Generator**（作者 cschlosser）。

## 核心工具：Doxygen Documentation Generator 插件

这款插件可以智能地解析函数（或类、变量等），并自动生成一个包含所有参数、返回值等信息的注释模板。

### 步骤 1：安装插件

1. 打开 VS Code。
2. 点击左侧活动栏的扩展图标（Extensions，快捷键 `Ctrl+Shift+X`）。
3. 在搜索框中输入 `Doxygen Documentation Generator`。
4. 找到由 cschlosser 发布的插件，点击 Install（安装）。

### 步骤 2：配置插件以匹配代码风格

代码使用的是 `//!` 开头的注释风格，而插件默认可能使用 `/**`，需要简单配置来匹配。以下是 VS Code **Doxygen Documentation Generator** 插件的设置项：

1. 打开 VS Code 的设置：
   - 通过菜单：File -> Preferences -> Settings
   - 通过快捷键：`Ctrl+,`
2. 点击右上角的图标，切换到 JSON 视图（Open Settings (JSON)）。
3. 在 `settings.json` 中添加以下配置：

```json
{
    // ... 其他 VSCode 设置 ...

    // Doxygen Documentation Generator 插件：触发序列设为 "//!"
    "doxdocgen.cpp.triggerSequence": [
        "//!"
    ],
    "doxdocgen.c.triggerSequence": [
        "//!"
    ],
    // 可选：自定义模板顺序
    "doxdocgen.generic.order": [
        "brief",
        "param",
        "return"
    ],
    // 可选：自动添加作者信息
    "doxdocgen.generic.authorName": "Your Name",
    "doxdocgen.generic.authorEmail": "your.email@example.com"
}
```

配置说明：

- `"doxdocgen.cpp.triggerSequence": ["//!"]`：关键设置。告诉插件在 C++ 文件中输入 `//!` 并按下 Enter 键时触发自动生成注释。
- `"doxdocgen.generic.order"`：自定义生成注释的标签顺序。
- `"doxdocgen.generic.authorName"`：设置名字，生成的注释会自动包含作者信息。

### 步骤 3：使用方法

配置完成后，使用方法如下：

1. 在 C++ 代码中找到想要添加注释的函数。
2. 将光标移动到函数声明或定义的正上方。
3. 输入配置的触发序列，即 `//!`。
4. 按下 Enter 键。

插件会自动生成一个完整的 Doxygen 注释块，只需在后面填写具体描述即可。

**示例：**

在写下这段代码后，光标停在函数上方，输入 `//!` 然后按回车：

```cpp
void vslamTrainedP4U::reInitCameraParams(camera::Intrinsics camIntrinsics, camera::Extrinsics camExtrinsics, uint8_t camIdx)
{
	// ... 函数实现 ...
}
```

按下 Enter 后，插件会自动生成：

```cpp
//! \brief                      <-- 光标会在这里，填写简述
//!
//! \param camIntrinsics        <-- 自动识别参数
//! \param camExtrinsics        <-- 自动识别参数
//! \param camIdx               <-- 自动识别参数
//! \return                     <-- 自动识别返回值 (void)
//!
void vslamTrainedP4U::reInitCameraParams(camera::Intrinsics camIntrinsics, camera::Extrinsics camExtrinsics, uint8_t camIdx)
{
	// ... 函数实现 ...
}
```

只需在每个标签后面补充相应的说明文字，就能快速生成和现有代码风格一致的专业注释。

## 替代方案：自定义代码片段 (Custom Snippets)

如果需要的模板非常固定，或者想为除函数之外的其他代码（比如类定义、文件头）创建模板，可以使用 VS Code 内置的代码片段（Snippets）功能。

1. 打开命令面板（`Ctrl+Shift+P`）。
2. 输入 `Configure User Snippets` 并选择它。
3. 选择 `cpp.json`（for C++）。
4. 在 `cpp.json` 中定义自己的模板，例如：

```json
{
	"File Header": {
		"prefix": "fileheader",
		"body": [
			"//",
			"//  Project: {${1:VSLAM}}",
			"//",
			"//! \\file    {${TM_FILENAME}}",
			"//! \\author  {${2:Your Name}}",
			"//! \\date    {${CURRENT_MONTH}/${CURRENT_DAY}/${CURRENT_YEAR}}",
			"//!",
			"//! \\brief   {${3:Brief description}}",
			"//!",
			"//! @(#)$$Id: $$",
			"//!",
			"",
			"////////////////////////////////////////////////////////////////////////////",
			"//",
			"// distribution and restricted disclosure only.) All rights reserved.",
			"//",
			"////////////////////////////////////////////////////////////////////////////"
		],
		"description": "Generates a standard file header."
	}
}
```

使用方法：在 C++ 文件中输入 `fileheader`（定义的 prefix），然后按 Tab 或 Enter，即可插入整个模板。

小结：Doxygen Documentation Generator 插件是更直接、更智能的选择；自定义代码片段则提供更高的灵活性。
