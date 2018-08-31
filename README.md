# 【RunAny】一劳永逸的快速启动工具 [v5.5.0](#)

**RunAny区别一般的启动工具，适合家里、公司多台电脑的用户，不管软件装在C盘还是D盘，根据名字直接找到并运行**

__【多台电脑你只需配置一套软件列表，就能到处运行，配合坚果云\OneDrive\Dropbox等网盘同步更是如虎添翼，达到一劳永逸！】😎__

另外更有  [一键直达]、[快捷打开文件]、[一键批量搜索]、[短语和热键映射]、[透明化启动]、[全局热键]...等你使用

【RunAny稳定版下载地址：】https://github.com/hui-Zz/RunAny/archive/v5.5.0.zip

【异次元软件RunAny介绍文章：】https://www.iplaysoft.com/runany.html

[【RunAny版本更新历史】](https://github.com/hui-Zz/RunAny/wiki/RunAny版本更新历史)

> RunAny使用Everything神器来知道所有软件的位置，Everything可以秒搜Windows下任何文件

> RunAny可以左键右鼠操作，也可以全键盘、全鼠标操作（配合鼠标手势软件更佳）

---

## RunAny启动软件就跟五笔打字一样高效方便，3键直达（如<kbd>\`</kbd>为热键）：

- <kbd>\`</kbd><kbd>w</kbd><kbd>w</kbd>就是启动『work工作』分类下的Word
- <kbd>\`</kbd><kbd>a</kbd><kbd>w</kbd>就是启动『app常用』分类下的Wiz
- <kbd>\`</kbd><kbd>f</kbd><kbd>w</kbd>就是启动『file文件』分类下的WinRAR

<img src="https://raw.githubusercontent.com/hui-Zz/RunAny/master/help/RunAny%E6%BC%94%E7%A4%BA.gif" alt="RunAny演示" style="max-width:50%;">

---

## RunAny一键直达，没有比按一个键更快的操作！

如果选中的文字就是网址，那按<kbd>\`</kbd>直接会在浏览器打开。

如果是文件夹目录、文件路径、磁力链接，一样一键打开，**就是这么高效！**

<img src="https://raw.githubusercontent.com/hui-Zz/RunAny/master/help/RunAny一键直达功能.gif" alt="RunAny一键直达功能">

---

## RunAny让你告别繁琐的右键打开文件！

只要先选中文件，然后再按<kbd>\`</kbd>启动RunAny中的软件，即可用该软件打开选中文件，**就是这么方便！**

<img src="https://raw.githubusercontent.com/hui-Zz/RunAny/master/help/RunAny%E6%BC%94%E7%A4%BA%E6%89%93%E5%BC%80%E6%96%87%E4%BB%B6.gif" alt="RunAny演示打开文件">

---

## RunAny除了运行还能搜索，还能批量搜索！

在菜单中添加搜索网址，先选中任意文字，按<kbd>\`</kbd>后就可以选择想用的搜索，更有一次批量搜索功能。

详见“实用配置”目录下[搜索网址.ini](https://github.com/hui-Zz/RunAny/blob/master/%E5%AE%9E%E7%94%A8%E9%85%8D%E7%BD%AE/%E6%90%9C%E7%B4%A2%E7%BD%91%E5%9D%80.ini)（内置购物、视频、图片、软件、音乐类等等搜索网站，复制需要的到【RunAny.ini】内使用）

<img src="https://raw.githubusercontent.com/hui-Zz/RunAny/master/help/RunAny%E6%BC%94%E7%A4%BA%E6%89%B9%E9%87%8F%E6%90%9C%E7%B4%A2.gif" alt="RunAny演示批量搜索">

---

## RunAny短语和热键映射功能：

RunAny可以储存邮箱、手机号，想用时就快捷输出，更支持AHK实时变量，输出当前时间。

**有了RunAny左键右鼠不是梦，左边有大量未使用快捷组合键，利用好这些键，左手再也不用移到键盘的右边😁**

<img src="https://raw.githubusercontent.com/hui-Zz/RunAny/master/help/RunAny短语和热键映射功能.gif" alt="RunAny短语和热键映射功能">

---

## RunAny的菜单不止一种用法

<img src="https://raw.githubusercontent.com/hui-Zz/RunAny/master/help/RunAny菜单多种使用方式.gif" alt="RunAny菜单多种使用方式">

---

## <a name="tree">首次使用请阅读：【自定义树形菜单配置方法】</a>

1. **分类/目录：** 以 `-`开头为1级目录名， `--`名称为2级，以此类推，如：`-app应用`、`-work办公`、`--img图像处理`

2. **分隔符：** 单独一个 `-`是1级分隔符， `--`2级分隔符，如：`-`、`--`

3. **菜单别名：** 在竖 `|` 前面添加程序的别名，如：`word|winword.exe`菜单上只会显示word

4. **注释：** 前加 `;`可以注释暂时不用的，如：`;cmd.exe`

5. **快捷短语：** 末尾分号 `;`识别为短语，会直接打字输出，如：`hui0.0713@gmail.com;` 用于注册时输出邮箱，

   `当前时间|%A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%;` 输出 `2018-08-08 08:08:08` （变量语法参考[AHK文档](https://wyagd001.github.io/zh-cn/docs/Variables.htm)）

6. **区分同名程序：** 如果电脑上有多个同名程序，加上全路径指定运行其中一个，如：`IE(32位)|C:\Program Files (x86)\Internet Explorer\iexplore.exe`

> 每个菜单名首字母(或用&指定任意)便是启动快捷键，如：`IE(&E)|iexplore.exe`快捷键是e
>
> 默认支持exe、lnk、ahk、bat、cmd文件的无路径识别，其他后缀可以在RunAny设置中的Everything搜索参数，如支持doc文档免设路径识别

## 【进阶配置】：

7. **不同后缀不同菜单：** 在分类/目录名后加 `|`和后缀，选中不同文件出不同菜单

   如：`-影音(&Video)|avi mkv mp4 rm rmvb flv wmv swf` 
   选中视频文件按<kbd>\`</kbd>只弹出`影音(&Video)`分类内容，多款播放软件选择使用

8. **半透明启动程序：** 在应用别名后面添加 `_:数字`形式来透明启动应用（默认不透明,1-100是全透明到不透明），如88%透明度：

```ini
记事本(&N)_:88|Notepad.exe
```
9. **热键映射：** 映射空闲的组合键转变为常用键功能，如：

   映射 左手的Shift+空格键 转变成 `回车键` 的功能

   映射 左手的Shift+大小写键(CapsLock) 转变成 `删除键` 的功能
```ini
左手回车	<+Space|{Enter}::
左手删除	LShift & CapsLock|{Delete}::
```
   > [了解更多AHK热键写法文档](https://wyagd001.github.io/zh-cn/docs/Hotkeys.htm)
10. **全局热键：** 在别名最末尾添加<kbd>Tab</kbd>制表符+热键（热键格式参考AHK写法:^代表<kbd>Ctrl</kbd> !代表<kbd>Alt</kbd> #代表<kbd>Win</kbd>+代表<kbd>Shift</kbd>），如按 `Alt+b`一键百度、 `Win+z`一键翻译、按 `Alt+z`启动或激活浏览器：
```ini
百度(&B)	!b|https://www.baidu.com/s?wd=
谷歌(&G)	!g|http://www.google.com/search?q=%s&gws_rd=ssl
翻译(&F)	#z|http://translate.google.cn/#auto/zh-CN/
浏览器(&Z)	!z|chrome.exe
```
> 搜索网址的关键字，如果在中间而不是在末尾，用%s表示，默认不加就是加在末尾来搜索

- 在选中文字的情况下按全局热键，可以直接用搜索网址搜索选中文字~
- 在选中文件情况下按全局热键，就可以直接用该热键的应用打开该文件；

---

## 【RunAny其他功能】：

> **所有应用独立全局热键集启动、最小化时激活，已激活时最小化、同应用多窗口切换功能于一体**

> 按住Ctrl打开软件会打开软件所在的目录

> 按住Shift打开软件会以管理员身份来运行

> 开启菜单2功能后，可在设置"绑定菜单1为一键搜索"，这样选中文字按<kbd>\`</kbd>就一键搜索，想用其他搜索再使用菜单2热键搜索

> （PS:输出\`可以<kbd>Win</kbd>+<kbd>\`</kbd>输入）

RunAny追求就是：<u>**一劳永逸**</u>
---

联系作者：hui0.0713@gmail.com

讨论QQ群：[246308937【RunAny快速启动一劳永逸】](https://jq.qq.com/?_wv=1027&k=445Ug7u)、[3222783【AutoHotkey高级群】](https://jq.qq.com/?_wv=1027&k=43uBHer)、[493194474【软客】](https://jq.qq.com/?_wv=1027&k=43trxF5)

**欢迎大家多多提出建议！感谢各位网友和群里的AHK-工兵、Balance、☆☆天甜、°～童年不懂事°等等对RunAny提出好的建议和问题**

**你的支持是我最大的动力！(金额随意)：**
<img src="https://raw.githubusercontent.com/hui-Zz/RunAny/master/支持RunAny.jpg" alt="支持RunAny" width="300" height="300"><img src="https://raw.githubusercontent.com/hui-Zz/RunAny/master/支持RunAny.png" alt="支持RunAny" width="300" height="300">



## 【特别感谢以下朋友对RunAny的赞助！有你们RunAny会越来越好！】

| AHK-工兵 | Balance | °～童年不懂事° | 小雨果 | skystar |
| -------- | ------- | -------------- | ------ | ------- |
| Nicked   | 声仔    | 多多           | 涅槃   |         |
|          |         |                |        |         |
|          |         |                |        |         |

---
