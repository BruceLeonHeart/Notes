> 类型：config
> 一句话：终端/编辑器配色偏好

## 配色喜好 

长时间对着电脑，保护眼睛很重要。我的出发点是要求配色具备对比度且护眼。 

- 高对比度可以很好区分不同的界面功能分区，边界清晰。（看个人喜好）。

- 目前使用的Light mode为主，这样字体默认是深色的，配合浅绿背景阅读体验最好。

- 背调为豆沙绿（为啥豆沙绿？绿色真的护眼最佳有待考究）

### 1.vscode设置

这里直接自定义配色方案。

颜色主题使用 默认浅色或者github浅色高对比度方案

这种方法不需要安装额外的插件，且可以精确控制各个区域（如代码区、终端区、侧边栏）的背景颜色。

在 VSCode 中按 Ctrl + Shift + P（Mac 上为 Cmd + Shift + P）打开命令面板。

输入 Open Settings (JSON)，选择首选项: 打开设置(JSON)。

在打开的 settings.json 文件最外层的大括号 {} 内，添加以下代码：

```json
"workbench.colorCustomizations": {
    "editor.background": "#C7EDCC",      // 代码编辑器背景色（经典豆沙绿）
    "terminal.background": "#C7EDCC",    // 底部终端背景色
    "panel.background": "#C7EDCC",       // 底部面板整体背景色
    "sideBar.background": "#DCEFDC",     // 侧边栏背景色（稍微区分一下层级，或者也可以设为 #C7EDCC）
    "activityBar.background": "#C7EDCC", // 最左侧活动栏背景色
    "editor.lineHighlightBackground": "#BEE0C3" // 鼠标所在当前行的反光高亮色
  }

```

这里建议在json中搜索下`workbench`关键字，将属性放在一起，便于维护。

### 2.powershell

windows 上使用CLI辅助日常开发工作，使用windows terminal 添加配色方案。

1. **打开终端配置文件:** 快捷键: Ctrl + Shift + ,.
打开 Windows Terminal，按下快捷键 `Ctrl + Shift + ,`（或者点击标题栏下拉箭头 -> 设置 -> 左下角“打开 JSON 文件”）。系统会使用默认文本编辑器（如记事本或 VSCode）打开 `settings.json`。


2. **粘贴配色方案代码:** 修改 schemes 列表.
在 JSON 文件中找到 `"schemes": [` 这一行。在它的下方，粘贴以下专门优化过对比度的护眼方案代码（注意与原有方案之间用逗号 `,` 隔开）：

```json
{
    "name": "Bean Green",
    "background": "#C7EDCC",
    "foreground": "#000000",
    "cursorColor": "#D93025",
    "selectionBackground": "#9ECCA4",
    "black": "#000000",
    "blue": "#002BB8",
    "cyan": "#005F6B",
    "green": "#006E1C",
    "purple": "#6A1E99",
    "red": "#C50F1F",
    "white": "#404040",
    "yellow": "#996600",
    "brightBlack": "#333333",
    "brightBlue": "#0047AB",
    "brightCyan": "#008596",
    "brightGreen": "#008A22",
    "brightPurple": "#8A2BE2",
    "brightRed": "#E51400",
    "brightWhite": "#FFFFFF",
    "brightYellow": "#B27D00"
}

```

*Verification:* 保存并关闭该文件。代码中加深了黄、蓝、青等颜色，彻底解决了浅色背景下命令输出看不清的问题。


3. **应用该配色方案:** 设置面板.
回到终端，按下 `Ctrl + ,` 打开设置界面。在左侧点击“配置文件”下的 **Windows PowerShell**，然后在右侧找到“外观” -> “配色方案”，在下拉菜单中选择刚添加的 **Bean Green**，点击右下角保存。
*Verification:* 终端界面立刻切换为绿底黑字，且输入命令时，不同颜色的提示符依然清晰锐利。
