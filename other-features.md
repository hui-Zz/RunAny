
## RunAny快捷操作菜单项

按<kbd>`</kbd>打开RunAny菜单后：
1. 按住<kbd>Ctrl</kbd>打开软件会打开软件所在的目录
2. 按住<kbd>Shift</kbd>键打开软件快速直接跳转到编辑该菜单项
3. 按住<kbd>Ctrl</kbd>+<kbd>Shift</kbd>键打开软件会以管理员身份来运行
4. **鼠标右键软件菜单项，使用更多新功能** (RunAny5.7.4)

## 注意：打字打出字符 \` 

?> 可以按<kbd>Win</kbd>+<kbd>\`</kbd>输入


## 切换RunAny图标主题

RunAny5.6版本后自带两套图标主题`MenuIcon`和`MenuIcon2`

**打开RunAny设置 —— “图标设置”**

修改“RunAny图标识别库”中内容

`%A_ScriptDir%\RunIcon\MenuIcon` 改为 `%A_ScriptDir%\RunIcon\MenuIcon2`

保存设置即可切换主题

> **自定义修改单独一个菜单分类的图标：** <br>
> 右键RunAny图标 —— “修改菜单” —— 选中菜单分类 —— 右键“编辑”

## 开启菜单2

当菜单1内容过多时，可以在RunAny设置中开启菜单2，RunAny自动创建文件`RunAny2.ini`

**菜单2为辅助菜单，不具备菜单1的“一键直达”功能，可以实现互补功能**

如：

1. 按菜单1热键一键直达网址，按菜单2使用百度搜索该网址

2. 绑定菜单1热键为一键搜索（在RunAny设置的“一键直达”界面）
   - 这样选中任意文字按<kbd>\`</kbd>就一键搜索，想用其他搜索再使用菜单2热键搜索

## 内部关联程序打开RunAny菜单内的文件

**打开RunAny设置 —— “内部关联”**

- 使用Notepad.exe打开RunAny菜单的文件

  - 增加：文件后缀为`txt ahk bat ini`
  - 打开方式软件路径：`Notepad.exe`（支持无路径只写程序名）

- 使用Total Command打开RunAny菜单中的文件夹（包括上面按<kbd>Ctrl</kbd>键打开目录的功能）

  - 增加：文件后缀为特殊类型`folder`

  - 打开方式软件路径：`TotalCMD64.exe /O /S`（支持无路径只写程序名）

  - > 特殊后缀类型：文件夹folder 网址http https www ftp

## 加快RunAny开机运行后图标加载速度

**打开RunAny设置 —— “图标设置”**

如果是完整版RunAny在“RunAny图标识别库”选项右边会有按钮“生成所有EXE图标”

使用的是`RunAny\RunIcon\ResourcesExtract\ResourcesExtract.exe`工具

生成所有RunAny菜单内EXE程序的图标到`RunIcon\ExeIcon`目录

RunAny直接加载ico图标文件 和 动态加载EXE图标速度会有明显提升 ~