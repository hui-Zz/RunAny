# 【RunAny】一劳永逸的快速启动工具 [v5.1 增加更新版本功能](#)

**RunAny区别一般的启动工具，在任意电脑上仅需软件名就能直接找到并运行，特别适合使用家里、公司、学校多台电脑的你**

__【你只需配置一个自定义程序菜单，就能到处运行，网盘同步更是如虎添翼，达到一劳永逸！😎】__

另外更有  [快捷打开文件]、[透明化启动]、[全局热键]、[一键批量搜索]...等你使用

__【RunAny下载地址：】https://github.com/hui-Zz/RunAny/archive/v5.1.zip __

[【RunAny版本更新历史】](https://github.com/hui-Zz/RunAny/wiki/RunAny版本更新历史)


> RunAny使用Everything神器来知道所有软件的位置，Everything可以秒搜Windows下任何文件

---

## RunAny启动软件就跟五笔打字一样高效方便，3键直达（如<kbd>\`</kbd>为热键）：

- <kbd>\`</kbd><kbd>w</kbd><kbd>w</kbd>就是启动work工作分类下的Word
- <kbd>\`</kbd><kbd>a</kbd><kbd>w</kbd>就是启动app常用分类下的Wiz
- <kbd>\`</kbd><kbd>f</kbd><kbd>w</kbd>就是启动file文件分类下的WinRAR

> **4.6版本后支持RunAny内所有应用独立热键启动、激活，已激活时按热键会最小化，见配置方法**

<img src="https://raw.githubusercontent.com/hui-Zz/RunAny/master/help/RunAny%E6%BC%94%E7%A4%BA.gif" alt="RunAny演示" style="max-width:50%;">

---

## RunAny让你告别繁琐的右键打开文件！
只要先选中文件，然后再按<kbd>\`</kbd>启动RunAny中的软件，即可用该软件打开选中文件，**就是这么方便！**

<img src="https://raw.githubusercontent.com/hui-Zz/RunAny/master/help/RunAny%E6%BC%94%E7%A4%BA%E6%89%93%E5%BC%80%E6%96%87%E4%BB%B6.gif" alt="RunAny演示打开文件">

---

## RunAny除了运行还能搜索！
在菜单中添加搜索网址，先选中任意文字，按<kbd>\`</kbd>后就可以选择想用的搜索（任意网站、购物、视频等），更有一次批量搜索功能。

如果选中的文字就是网址，那按<kbd>\`</kbd>直接会在浏览器打开。如果是文件夹目录、文件路径，一样一键打开，**就是这么高效！**

<img src="https://raw.githubusercontent.com/hui-Zz/RunAny/master/help/RunAny%E6%BC%94%E7%A4%BA%E6%89%B9%E9%87%8F%E6%90%9C%E7%B4%A2.gif" alt="RunAny演示批量搜索">

---

## <a name="tree">首次使用请阅读：【自定义树形菜单配置方法】</a>

1. 以-开头+名称为1级目录名,--名称为2级以此类推，如：`-app应用`、`--img图像处理`
2. 单独一个-是1级分隔符，--2级亦是如此，如：`-`、`--`
3. 可用竖|添加别名前缀,菜单便会显示别名，如：`TC|Totalcmd.exe`会显示TC为菜单名
4. 前加;可以注释暂时不需要用的，如：`;cmd.exe`
5. 末尾;识别为短语可以直接输出，如：`hui0.0713@gmail.com;`
6. 如果电脑上有多个同名程序，加上全路径指定运行其中一个，如：`IE(32位)|C:\Program Files (x86)\Internet Explorer\iexplore.exe`
> 每个菜单名首字母(或用&指定任意)便是启动快捷键，如：`IE(&E)|iexplore.exe`快捷键是e
>
> 默认支持exe、lnk、ahk、bat、cmd文件的无路径识别，其他后缀可以在RunAny设置中的Everything搜索参数，如支持doc文档无路径识别

#### 【4.6之后版本新增应用的透明化和全局自定义热键配置】

- 在应用别名后面添加_:数字形式来透明启动应用（默认不透明,1-100是全透明到不透明），如88%透明度：
```ini
记事本(&N)_:88|Notepad.exe
```
- 在别名最末尾添加<kbd>Tab</kbd>制表符+热键（热键格式参考AHK写法:^代表<kbd>Ctrl</kbd> !代表<kbd>Alt</kbd> #代表<kbd>Win</kbd>+代表<kbd>Shift</kbd>），如按Alt+z一键百度、Win+z一键翻译：
```ini
百度(&B)	!z|https://www.baidu.com/s?wd=%s
翻译(&F)	#z|http://translate.google.cn/#auto/zh-CN/
```
> 搜索网址的关键字，如果在中间而不是在末尾，用%s表示，默认不加就是加在末尾来搜索

- 在选中文字的情况下按热键，可以直接用搜索网址搜索选中文字~
- 在选中文件情况下按热键，就可以直接用该热键的应用打开该文件；

> 开启菜单2功能后，可以绑定菜单1为一键搜索，这样选中文字一按<kbd>\`</kbd>就默认搜索，想用其他搜索再使用菜单2热键搜索

---
RunAny追求就是：<u>**一劳永逸**</u>
---

建议：hui0.0713@gmail.com

讨论QQ群：[246308937【RunAny快速启动一劳永逸】](https://jq.qq.com/?_wv=1027&k=445Ug7u)、[3222783【AutoHotkey高级群】](https://jq.qq.com/?_wv=1027&k=43uBHer)、[493194474【软客】](https://jq.qq.com/?_wv=1027&k=43trxF5)

**你的支持是我最大的动力！(金额随意)：**
<img src="https://raw.githubusercontent.com/hui-Zz/RunAny/master/支持RunAny.jpg" alt="支持RunAny" width="300" height="300">

**在此特别感谢 AHK-工兵、Balance、☆☆天甜 等等对RunAny的大力支持，欢迎大家多多提出建议！**

> 这里是隐藏功能：

> 按住Ctrl打开软件会打开软件所在的目录
> 按住Shift打开软件会以管理员身份来运行

> (PS:输入\`可以<kbd>Win</kbd>+<kbd>\`</kbd>输入)

---
