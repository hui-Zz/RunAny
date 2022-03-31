<div align="center">
<a href="https://github.com/hui-Zz/RunAny" target="_blank">
	<img src="https://hui-zz.gitee.io/runany/assets/images/RunAny.svg" alt="RunAny" width="120" height="120">
</a>

# 【RunAny】一劳永逸的快速启动工具

[![GitHub release](https://img.shields.io/github/release/hui-Zz/RunAny.svg?label=最新版本&style=flat-square&logo=github&color=red)![GitHub stars](https://img.shields.io/github/stars/hui-Zz/RunAny.svg?style=flat-square&color=yellow)![GitHub forks](https://img.shields.io/github/forks/hui-Zz/RunAny?style=flat-square)](https://github.com/hui-Zz/RunAny)![history](https://img.shields.io/badge/2017--2022-yellowgreen.svg?style=flat-square)  
[![Autohotkey](https://img.shields.io/badge/autohotkey-1.1.33.10-green.svg?style=flat-square&logo=autohotkey)](http://ahkscript.org)
[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fhui-Zz%2FRunAny&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=%E5%BD%93%E6%97%A5%2F%E6%80%BB%E6%B5%8F%E8%A7%88&edge_flat=true)](https://hits.seeyoufarm.com)
</div>

​    **RunAny区别一般的启动工具，适合家里、公司多台电脑的用户，不管软件装在C盘还是D盘Anywhere，根据名字直接找到并运行**

​    __多台电脑你只需配置一套软件列表(RunAny.ini)，就能到处运行，配合坚果云\OneDrive\Dropbox等网盘同步更是如虎添翼，达到一劳永逸！😎__

- ☑ 一键菜单分类界面，找应用零记忆负担，快搜索启动几倍效率
- ☑ 分类定位，三键启动，极简极速
- ☑ 一次配置，到处运行，永久使用
- ☑ [一键直达](#oneKey)，[一键计算](#oneKeyCalc)，[一键批量搜索](#oneKeySearch)
- ☑ [全局热键，热键映射](#advancedConfig)，[热字符串](https://hui-zz.github.io/RunAny/#/hotstring)，多样快捷
- ☑ [短语输出](#wordOutput)，[透明化启动](#advancedConfig)，[快捷打开文件方式](#quickOpenFile)
- ☑ [外接脚本，个性函数，自由定制](#runPlugins)
- ☑ [规则判断自动启动软件](https://hui-zz.gitee.io/runany/#/run-ctrl) **重磅新功能！**
- ☑ [【打开/保存对话框快速定位目录功能】（类似于Listary的Ctrl+G）](https://hui-zz.gitee.io/runany/#/change-log?id=%e2%9c%85%e6%96%b0%e5%a2%9e%e3%80%90%e6%89%93%e5%bc%80%e4%bf%9d%e5%ad%98%e5%af%b9%e8%af%9d%e6%a1%86%e5%bf%ab%e9%80%9f%e5%ae%9a%e4%bd%8d%e7%9b%ae%e5%bd%95%e5%8a%9f%e8%83%bd%e3%80%91%ef%bc%88%e7%b1%bb%e4%bc%bc%e4%ba%8elistary%e7%9a%84ctrlg%ef%bc%89) **重磅新功能！**

【Github下载地址：】https://github.com/hui-Zz/RunAny/archive/master.zip
- 蓝奏云下载：https://www.lanzoux.com/b902490/
- 百度云下载：https://pan.baidu.com/s/1qxbYAx0UA-u1dkoY-RXZJg

## 【RunAny完整版文档地址：】[https://hui-zz.gitee.io/runany](https://hui-zz.gitee.io/runany) （国内速度快）
## 【RunAny文档Github地址：】[https://hui-zz.github.io/RunAny](https://hui-zz.github.io/RunAny)

【异次元软件RunAny介绍文章：】https://www.iplaysoft.com/runany.html

[【RunAny版本更新历史】](https://hui-zz.github.io/RunAny/#/change-log)

> RunAny使用Everything神器来知道所有软件的位置，Everything可以秒搜Windows下任何文件 <br>
> RunAny可以左键右鼠操作，也可以全键盘、全鼠标操作（配合鼠标手势软件更佳）


## 📢 关注RunAny一劳永逸微信公众号，分享【一劳永逸】的效率软件和解决方案！
<img src="https://hui-zz.gitee.io/runany/assets/images/RunAny%E5%85%AC%E4%BC%97%E5%8F%B7-%E7%99%BD%E8%89%B2%E7%89%88.jpg" alt="RunAny公众号-白色版">

---

## RunAny启动软件就跟五笔打字一样高效方便，3键直达（如<kbd>Esc</kbd>键下方的重音符键<kbd>\`</kbd>为热键）：

- <kbd>\`</kbd><kbd>a</kbd><kbd>w</kbd>就是启动『app常用』分类下的微信
- <kbd>\`</kbd><kbd>w</kbd><kbd>w</kbd>就是启动『work工作』分类下的Word
- <kbd>\`</kbd><kbd>f</kbd><kbd>w</kbd>就是启动『file文件』分类下的WinRAR

<img src="https://hui-zz.github.io/RunAny/assets/images/RunAny%E6%BC%94%E7%A4%BA.webp" alt="RunAny演示" style="max-width:50%;">

---

## <a name="oneKey">RunAny一键直达，没有比按一个键更快的操作！</a>

如果选中的文字就是网址，那按<kbd>\`</kbd>直接会在浏览器打开。

- 按<kbd>\`</kbd>一键打开选中路径的文件或程序
- 按<kbd>\`</kbd>一键打开选中路径的文件夹
- 按<kbd>\`</kbd>一键用默认BT下载工具下载选中磁力链接
- 按<kbd>\`</kbd>一键打开注册表路径并自动定位到键值

**<font color="red">v5.8.1新功能：可用正则实现自定义一键直达！</font>**

如：bilibili的BV号跳转、IP地址选中一键ping、选中23位字母（1qxbYAx0UA-u1dkoY-RXZJg）一键跳转百度云  
**选中的内容中含有7大网盘地址，就可以智能识别出网址和提取码，自动打开（百度网盘、蓝奏云、阿里云盘、微云、天翼云、和彩云、迅雷云盘）**  
![RunAny一键正则直达功能](https://hui-zz.github.io/RunAny/assets/images/RunAny一键正则直达功能.jpg)

<img src="https://hui-zz.github.io/RunAny/assets/images/RunAny一键直达功能.gif" alt="RunAny一键直达功能">

<a name="oneKeyCalc">RunAny一键公式计算</a>

<img src="https://hui-zz.github.io/RunAny/assets/images/RunAny公式计算.gif" alt="RunAny公式计算">

---

## <a name="quickOpenFile">RunAny让你告别繁琐的右键打开文件方式！</a>

只要先选中文件，然后再按<kbd>\`</kbd>启动RunAny中的软件，即可用该软件打开选中文件，**就是这么方便！**

<img src="https://hui-zz.github.io/RunAny/assets/images/RunAny%E6%BC%94%E7%A4%BA%E6%89%93%E5%BC%80%E6%96%87%E4%BB%B6.gif" alt="RunAny演示打开文件">

---

## <a name="oneKeySearch">RunAny除了运行还能搜索，还能批量搜索！</a>

在菜单中添加搜索网址，先选中任意文字，按<kbd>\`</kbd>后就可以选择想用的搜索，更有一次批量搜索功能。

详见文档[批量搜索](https://hui-zz.github.io/RunAny/#/batch-search)（内置购物、视频、图片、软件、音乐类等等搜索网站，复制需要的到【RunAny.ini】内使用）

<img src="https://hui-zz.github.io/RunAny/assets/images/RunAny%E6%BC%94%E7%A4%BA%E6%89%B9%E9%87%8F%E6%90%9C%E7%B4%A2.gif" alt="RunAny演示批量搜索">

---

## <a name="wordOutput">RunAny短语和热键映射功能：</a>

RunAny可以储存邮箱、手机号，想用时就快捷输出，更支持AHK实时变量，输出当前时间。

**有了RunAny左键右鼠不是梦，左边有大量未使用快捷组合键，利用好这些键，左手再也不用移到键盘的右边😁**

<img src="https://hui-zz.github.io/RunAny/assets/images/RunAny短语和热键映射功能.gif" alt="RunAny短语和热键映射功能">

---

## RunAny的菜单不止一种用法

<img src="https://hui-zz.github.io/RunAny/assets/images/RunAny菜单多种使用方式.gif" alt="RunAny菜单多种使用方式">

---

## <a name="runPlugins">RunAny插件脚本</a>

<img src="https://hui-zz.github.io/RunAny/assets/images/RunAny_huiZz_Text变量命名功能.gif" alt="RunAny_huiZz_Text变量命名功能">

| 插件文件      | 插件分类     | 插件功能                                                     |
| ------------- | ------------ | ------------------------------------------------------------ |
| huiZz_MButton | 独立功能插件 | 鼠标中键任意位置拖拽窗口                                     |
| huiZz_QRCode  | 二维码脚本   | 选中文字生成二维码                                           |
| huiZz_System  | 系统操作脚本 | 注册表路径定位、本机IP地址显示并剪贴板、复制选中文件信息、显示隐藏文件等 |
| huiZz_Text    | 文本操作脚本 | 对选中文本：Markdown格式化、加序号转大小写、转驼峰下划线等命名、多行合并字符替换、排序去重、直入编辑器、与剪贴板对比 |
| huiZz_Window  | 窗口操作脚本 | 对当前窗口：居中、置顶、透明、比例或指定像素缩小放大、移动至屏幕边角 |

[点击查看更多RunAny插件功能详细内容](https://hui-zz.github.io/RunAny/#/plugins-list)  
[点击查看RunAny插件使用方法](https://hui-zz.github.io/RunAny/#/plugins-help)

---

## <a name="tree">首次使用请阅读：【自定义树形菜单配置方法】</a>

1. **分类/目录：** 以 `-`开头为1级菜单， `--`+名称为2级菜单，`---`+名称3级菜单……以此类推，如：`-app应用`、`--img图像处理`、……  `------六级菜单`

2. **分隔符：** 单独一个 `-`是1级分隔符， `--`2级分隔符……以此类推，如：`-`、`--`、……  `------`

3. **菜单别名：** 在竖 `|` 前面添加程序的别名，如：`word|winword.exe`菜单上只会显示word

4. **注释：** 前加 `;`可以注释暂时不用的，如：`;cmd.exe`

5. **快捷短语：** 末尾分号 `;`识别为短语，会直接打字输出，如：`hui0.0713@gmail.com;` 用于注册时输出邮箱，

   `当前时间|%A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%;` 输出 `2018-08-08 08:08:08` （变量语法参考[AHK文档](https://wyagd001.github.io/zh-cn/docs/Variables.htm)）

6. **区分重名程序：** 如果电脑上有多个重名程序，加上全路径指定运行其中一个，如：`IE(32位)|C:\Program Files (x86)\Internet Explorer\iexplore.exe`（或创建该程序的快捷方式，在RunAny中添加使用快捷方式解决重名问题）

> 默认支持exe、lnk、ahk、bat、cmd文件的无路径识别，其他后缀可以在RunAny设置中的Everything搜索参数，如支持doc文档免设路径识别
>
> 每个菜单名首字母(或用&指定任意)便是启动快捷键，如：`IE(&E)|iexplore.exe`快捷键是e


## <a name="advancedConfig">【进阶配置】：</a>

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

1. **所有应用独立全局热键集启动、最小化时激活，已激活时最小化、同应用多窗口切换功能于一体**
2. 按住<kbd>Ctrl</kbd>打开软件会打开软件所在的目录
3. 按住<kbd>Shift</kbd>键打开软件快速直接跳转到编辑该菜单项
4. 按住<kbd>Ctrl</kbd>+<kbd>Shift</kbd>键打开软件会以管理员身份来运行

> 开启菜单2功能后，可在设置"绑定菜单1为一键搜索"，这样选中文字按<kbd>\`</kbd>就一键搜索，想用其他搜索再使用菜单2热键搜索

> （PS:输出\`可以<kbd>Win</kbd>+<kbd>\`</kbd>输入）

RunAny追求就是：<u>**一劳永逸**</u>
---

【联系作者】hui0.0713@gmail.com
[【RunAny建议及意见】](https://github.com/hui-Zz/RunAny/issues)

讨论QQ群：[246308937【RunAny快速启动一劳永逸】](https://jq.qq.com/?_wv=1027&k=445Ug7u)

**欢迎大家多多提出建议！感谢各位网友和群里的AHK-工兵、Balance、☆☆天甜、°～童年不懂事°等等对RunAny提出好的建议和问题**

**你的支持是我最大的动力！(金额随意，都是心意)：**

<img src="https://hui-zz.github.io/RunAny/assets/images/支持RunAny.jpg" alt="支持RunAny" width="275" height="275"><img src="https://hui-zz.github.io/RunAny/assets/images/支持RunAny.png" alt="支持RunAny" width="275" height="275">

---

## 【特别感谢以下朋友对RunAny的赞助！有你们RunAny会越来越好！】

| 昵称           | 时间                | 昵称              | 时间                |
| -------------- | ------------------- | ----------------- | ------------------- |
| Balance        | 2017                | 心向              | 2020-03-11 10:11:40 |
| AHK-工兵       | 2018-04-17 17:30:09 | 涅槃 (2)          | 2020-03-23 08:32:57 |
| Nicked         | 2018-05-15 15:25:42 | **E*d (3)**       | 2020-04-01 09:37:45 |
| 声仔           | 2018-05-16 10:29:59 | **成              | 2020-04-22 21:17:34 |
| °～童年不懂事° | 2018-05-16 22:55:26 | S*w（1）          | 2020-06-03 09:53:19 |
| skystar        | 2018-05-27 16:39:36 | contraction       | 2020-07-30 22:33:42 |
| AHK-工兵（2）  | 2018-06-01 11:04:59 | **坤              | 2020-08-06 21:33:45 |
| 小雨果         | 2018-06-03 17:51:58 | *闲               | 2020-08-19 17:24:15 |
| 多多           | 2018-06-07 12:38:42 | K*s               | 2020-08-25 10:21:55 |
| 涅槃           | 2018-06-18 16:54:18 | *丁               | 2020-09-04 18:02:57 |
| skystar（2）   | 2018-06-26 14:24:17 | **国              | 2020-11-18 02:12:44 |
| 小川（Ever）   | 2018-07-18 09:12:00 | *斌               | 2020-11-23 11:35:59 |
| E*d            | 2018-07-23 11:20:18 | **锋              | 2020-12-02 15:26:46 |
| 鼠小天         | 2018-10-20 17:06:00 | **彬              | 2021-01-11 10:19:30 |
| *伟华          | 2018-11-08 16:42:07 | S*w（2）          | 2021-02-01 18:21:40 |
| AHK-工兵（3）  | 2018-11-29 10:01:21 | **涅槃 (3)**      | 2021-07-16 15:23:34 |
| K*a            | 2018-12-04 15:22:41 | **AHK-工兵（6）** | 2021-07-16 16:23:16 |
| *天（过年好）  | 2019-01-30 21:37:40 | ★火★              | 2021-09-14 21:57:24 |
| *杭            | 2019-02-27 18:29:58 | F*o               | 2021-09-15 11:15:26 |
| 禁誋           | 2019-03-27 21:21:08 | R*n               | 2021-09-15 14:29:12 |
| *杭（2）       | 2019-03-29 17:06:15 | *旭               | 2021-09-18 19:00:10 |
| *❎             | 2019-07-10 09:32:15 | 逍遥              | 2021-10-05 11:16:24 |
| E*d（2）       | 2019-07-30 16:51:02 | *毛               | 2021-11-10 19:42:46 |
| ***伟华（2）** | 2019-08-03 23:22:57 | *塔               | 2021-12-01 09:28:11 |
| AHK-工兵（4）  | 2019-08-22 12:13:49 | L*u               | 2021-12-04 09:54:21 |
| AHK-工兵（5）  | 2019-08-23 15:22:22 | **AHK-工兵（7）** | 2021-12-06 19:28:38 |
| Mr.Liu         | 2019-08-23 15:24:37 | *晔               | 2021-12-31 18:21:26 |
| 过客           | 2019-10-01 14:33:37 | **S\*w（3）**      | 2022-01-03 09:09:32 |
|                |                     | Mickey            | 2022-03-15 14:30:54 |

---
![GitHub release](https://img.shields.io/github/release/hui-Zz/RunAny?style=social) ![GitHub stars](https://img.shields.io/github/stars/hui-Zz/RunAny.svg?style=social) ![Lines of code](https://img.shields.io/tokei/lines/github/hui-Zz/RunAny?style=social&logo=github) ![history](https://img.shields.io/badge/2017--2022-yellowgreen.svg?style=social&logo=github) [![Autohotkey](https://img.shields.io/badge/Autohotkey-1.1.33.10-white.svg?style=social&logo=autohotkey)![GitHub top language](https://img.shields.io/github/languages/top/hui-Zz/RunAny?style=social&logo=autohotkey)](http://ahkscript.org) ![windows](https://img.shields.io/badge/Windows-0078D6?style=social&logo=windows) [![码云Gitee](https://img.shields.io/badge/dynamic/json?style=flat-square&label=stars&logo=gitee&logoColor=red&url=https://gitee.com/api/v5/repos/hui-Zz/RunAny&query=$.stargazers_count)](https://gitee.com/hui-Zz/RunAny)

[![Stargazers over time](https://starchart.cc/hui-Zz/RunAny.svg)](https://starchart.cc/hui-Zz/RunAny)

