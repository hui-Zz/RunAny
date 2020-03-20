# 【RunAny】一劳永逸的快速启动工具 ![GitHub release](https://img.shields.io/github/release/hui-Zz/RunAny.svg?style=flat-square&logo=github)  [![HitCount](http://hits.dwyl.io/hui-Zz/RunAny.svg)](http://hits.dwyl.io/hui-Zz/RunAny)


**RunAny区别一般的启动工具，适合家里、公司多台电脑的用户，不管软件装在C盘还是D盘Anywhere，根据名字直接找到并运行**

__多台电脑你只需配置一套软件列表(RunAny.ini)，就能到处运行，配合 坚果云 \ OneDrive \ Dropbox 等网盘同步更是如虎添翼，达到一劳永逸！😎__

- ☑ 一键菜单分类界面，找应用零记忆负担
- ☑ 分类定位，三键启动，简单迅速
- ☑ 一次配置，到处运行，永久使用
- ☑ [一键直达](/README?id=一键直达)，[一键公式计算](/README?id=一键公式计算)，[一键批量搜索](/README?id=批量搜索)
- ☑ [全局热键](/README?id=全局热键)，[热键映射](/README?id=热键映射)，[热字符串](/README?id=热字符串)，多样快捷
- ☑ [短语输出](/README?id=短语输出)，[透明化启动](/quick-config?id=半透明启动程序)，[快捷打开文件方式](/README?id=快捷打开文件方式)
- ☑ [外接脚本，个性函数](/plugins-list)，[自由定制](/plugins-help?id=新建自定义objreg插件)


> RunAny使用Everything神器来知道所有软件的位置，Everything可以秒搜Windows下任何文件 <br>
> RunAny可以左键右鼠操作，也可以全键盘、全鼠标操作（配合鼠标手势软件更佳）

---
## 演示效果

RunAny启动软件就跟五笔打字一样高效方便，3键直达（如<kbd>Esc</kbd>键下方的重音符键<kbd>\`</kbd>为热键）：

- <kbd>\`</kbd><kbd>a</kbd><kbd>w</kbd>就是启动『app常用』分类下的微信
- <kbd>\`</kbd><kbd>w</kbd><kbd>w</kbd>就是启动『work工作』分类下的Word
- <kbd>\`</kbd><kbd>f</kbd><kbd>w</kbd>就是启动『file文件』分类下的WinRAR

![RunAny演示](/assets/images/RunAny演示.webp)

---

![RunAny菜单多种使用方式](/assets/images/RunAny菜单多种使用方式.gif)

## 下载地址

- Github下载地址：https://github.com/hui-Zz/RunAny/archive/v5.7.0.zip
- 蓝奏云下载：https://www.lanzous.com/b902490/
- 百度云下载：https://pan.baidu.com/s/1qxbYAx0UA-u1dkoY-RXZJg

---

## 一键直达

**没有比按一个键更快的操作！**

- 按<kbd>\`</kbd>一键用默认浏览器打开选中网址
- 按<kbd>\`</kbd>一键打开选中路径的文件或程序
- 按<kbd>\`</kbd>一键打开选中路径的文件夹
- 按<kbd>\`</kbd>一键用默认BT下载工具下载选中磁力链接

![RunAny一键直达功能](/assets/images/RunAny一键直达功能.gif)

### 一键公式计算

![RunAny公式计算](/assets/images/RunAny公式计算.gif)

---

## 快捷打开文件方式

**RunAny让你告别繁琐的右键打开文件方式！**

只要先选中文件，然后再按<kbd>\`</kbd>启动RunAny中的软件，即可用该软件打开选中文件

![RunAny演示打开文件](/assets/images/RunAny演示打开文件.gif)

---

## 批量搜索

**RunAny除了运行还能搜索，还能批量搜索！**

在菜单中添加搜索网址，先选中任意文字，按<kbd>\`</kbd>后就可以选择想用的搜索，更有一次批量搜索功能。

?> 内置购物、视频、图片、软件、音乐、网盘类等搜索网站，复制需要的到`RunAny.ini`内使用

![RunAny演示批量搜索](/assets/images/RunAny演示批量搜索.gif)

### 搜索网址

**复制以下需要的功能写入`RunAny.ini`文件保存、重启RunAny，然后选中任意文字后打开菜单即可搜索**

<details>
<summary>日常搜索</summary>

```ini
聊天|tencent://message/?uin=QQ号&Site=&menu=yes
百度(&B)|https://www.baidu.com/s?wd=%s
百度指数|http://index.baidu.com/v2/main/index.html#/trend/springboot?words=
谷歌(&G)|https://www.google.com/search?q=%s&gws_rd=ssl
谷歌商店|https://chrome.google.com/webstore/search/%s?hl=zh-CN
谷歌Play|https://play.google.com/store/search?q=%s
翻译(&F)|https://translate.google.cn/#auto/zh-CN/
知乎(&Z)|https://www.zhihu.com/search?type=content&q=%s
github|https://github.com/search?utf8=%E2%9C%93&q=%s&type=
```

</details>
<br>
<details>
<summary>视频搜索</summary>

```ini
-视频(&V)
	A站|http://www.acfun.cn/search/#query=%s
	B站|http://search.bilibili.com/all?keyword=%s
	优酷|http://www.soku.com/search_video/q_%s
	腾讯|http://v.qq.com/x/search/?q=%s
	爱奇艺|http://so.iqiyi.com/so/q_%s
	乐视|http://so.le.com/s?wd=%s
	搜狐|http://so.tv.sohu.com/mts?wd=%s
	360|http://so.360kan.com/index.php?kw=%s
  --
	vimeo|https://vimeo.com/search?q=%s
	youtube|https://www.youtube.com/results?search_query=%s
	nico|http://www.nicovideo.jp/search/%s
```

</details>
<br>
<details>
<summary>购物搜索</summary>

```ini
-购物(&S)
	淘宝(&T)|https://s.taobao.com/search?q=%s
	天猫|http://list.tmall.com/search_product.htm?q=%s
	京东(&D)|http://search.jd.com/Search?keyword=%s&enc=utf-8
	--
	1688|https://s.1688.com/selloffer/offer_search.htm?keywords=%s
	亚马逊|https://www.amazon.cn/s/field-keywords=%s
	当当|http://search.dangdang.com/?key=%s
	苏宁|http://search.suning.com/%s/cityId=110
```

</details>
<br>
<details>
<summary>图片搜索</summary>

```ini
-图片(&P)
	谷歌图片|https://www.google.com/search?tbm=isch&q=%s&safe=off
	yandex|https://yandex.com/images/search?text=%s
	百度图片|http://image.baidu.com/search/index?tn=baiduimage&ie=utf-8&word=%s
	搜狗|http://pic.sogou.com/pics?query=%s
	必应|https://www.bing.com/images/search?q=%s
	好搜|http://image.so.com/i?q=%s
  --
	flickr|https://www.flickr.com/search/?w=all&q=%s
	tumblr|http://www.tumblr.com/search/%s
```

</details>
<br>
<details>
<summary>音乐搜索</summary>

```ini
-音乐(&M)
	网易|http://music.163.com/#/search/m/?s=%s&type=1
	百度音乐|http://music.baidu.com/search?key=%s&ie=utf-8&oe=utf-8
	虾米|http://www.xiami.com/search?key=%s
	QQ音乐|https://y.qq.com/portal/search.html#page=1&w=%s
```

</details>
<br>
<details>
<summary>绿软搜索</summary>

```ini
-绿软(&R)
	小众软件|https://www.appinn.com/?s=%s
	绿盟|http://www.xdowns.com/index.php?ac=search&keyword=%s
	异次元软件|http://www.iplaysoft.com/search/?s=548512288484505211&q=%s
	zd423|http://www.zdfans.com/search.asp?keyword=%s
	软件缘|http://www.appcgn.com/?s=%s
	精品绿色便携|http://so.portablesoft.org/cse/search?q=%s&s=521260595841649407
	;	Portable便携软件|http://forum.portableappc.com/search.php?keywords=%s
```

</details>
<br>
<details>
<summary>网盘搜索</summary>

```ini
-网盘(&W)
	爱挖盘|http://www.iwapan.com/so.aspx?wd=%s
	去转盘网|http://www.quzhuanpan.com/source/search.action?q=%s&currentPage=1
	西林街|http://www.xilinjie.com/s?q=%s
	搜白度盘|http://www.sobaidupan.com/search.asp?wd=%s&so_md5key=06625be22887c8bd0ea3ff47265611b3
	百度云so|http://www.bdyunso.com/search-all-%s-1
	印象|https://impress.pw/search?site=pan.baidu.com&tab=disk&q=%s
	盘搜|http://sou.pansou.com/?q=%s
	;	呆木瓜|http://md5.daimugua.com/search.aspx?q=%s
```

</details>

---

## 全局热键

在别名最末尾添加<kbd>Tab</kbd>制表符+热键

> 热键格式参考AHK写法:
`^`代表<kbd>Ctrl</kbd> 
`!`代表<kbd>Alt</kbd> 
`#`代表<kbd>Win</kbd>
`+`代表<kbd>Shift</kbd>

1. 按 <kbd>Alt</kbd>+<kbd>b</kbd> 一键百度、谷歌
2. 按 <kbd>Win</kbd>+<kbd>z</kbd>一键翻译选中文字
3. 按 <kbd>Alt</kbd>+<kbd>z</kbd>启动或激活浏览器

<PRE>
百度 (&B)&#9!b|https://www.baidu.com/s?wd=
谷歌 (&G)&#9!g|http://www.google.com/search?q=%s&gws_rd=ssl
翻译 (&F)&#9#z|http://translate.google.cn/#auto/zh-CN/
浏览器(&Z)&#9!z|chrome.exe
</PRE>

> 搜索网址的关键字，如果在中间而不是在末尾，用%s表示，默认不加就是加在末尾来搜索
> - 在选中文字的情况下按全局热键，可以直接用搜索网址搜索选中文字~
> - 在选中文件情况下按全局热键，就可以直接用该热键的应用打开该文件；

**所有exe程序设置独立全局热键后有三种功能：**
1. 启动、最小化时激活
2. 已激活时最小化
3. 同个exe程序多窗口切换功能于一体

![RunAny新增修改菜单项](/assets/images/RunAny新增修改菜单项.jpg)

?> [手动写RunAny.ini可以了解更多AHK热键写法文档](https://wyagd001.github.io/zh-cn/docs/Hotkeys.htm)

---

## 热字符串

`QQ:*X:#QQ|QQ.exe`
在任何情况下（屏蔽RunAny程序列表除外）先按`#`再按`QQ`，就会直接运行QQ！

`:*X:hg@|hui0.0713@gmail.com;`
在任何地方按`hg@`即可快捷输出短语邮箱地址！

**推荐使用RunAny“新增修改菜单项”界面编辑热字符串**，手动修改`RunAny.ini`请阅读下面[热字符串说明](/README?id=热字符串说明)

![RunAny新增修改菜单项](/assets/images/RunAny新增修改菜单项.jpg)

!> **注意：井号# 或 @可以为任意打字不常用字符，避免聊天时误按了几下QQ就运行QQ了！！**

![RunAny热字符串输出短语](/assets/images/RunAny热字符串输出短语.gif)

### 热字符串说明

> 菜单项名为说明 + `冒号:` + 选项字母 + `冒号:` + 热字符串 + `竖杠|` + 程序、短语、网址等等

- 选项字母：
- `星号*`代表无需按结束按键(回车Tab等)
- `大写X`代表动态执行而不是当作短语输出字符
- > [了解更多选项字母查看文档](https://wyagd001.github.io/zh-cn/docs/Hotstrings.htm)

?> 透明启动情况：`_:数字`依然在别名末尾，热字符在其前面，如：`Sublime:*X:@sub_:88|sublime_text.exe`

### 热字符串提示

右键RunAny图标 - 设置RunAny选项 - “热字符串”设置

可以设置隐藏热字符串全局提示、提示文字的最大长度、提示停留时长、提示透明度

---

## 短语输出

RunAny可以储存邮箱、手机号，想用时就快捷输出，更支持AHK实时变量，输出当前时间。

末尾分号 `;`识别为短语，会用剪贴板粘贴输出，如输出此刻的时分秒：

`hui0.0713@gmail.com;` 输出 `hui0.0713@gmail.com`

`时间-|%A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%;` 输出 `2018-08-08 08:08:08` 

<details>
<summary>【点此展开】写入RunAny.ini文件使用不同格式短语</summary>

```ini
-短语
	日期:*X:date!|%A_YYYY%%A_MM%%A_DD%;
	日期-:*X:date@|%A_YYYY%-%A_MM%-%A_DD%;
	日期中文_:*X:date#|%A_YYYY%年%A_MM%月%A_DD%日;
	时间:*X:time!|%A_YYYY%%A_MM%%A_DD%%A_Hour%%A_Min%%A_Sec%;
	时间-:*X:time@|%A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%;
	时间中文_:*X:time#|%A_YYYY%年%A_MM%月%A_DD%日 %A_Hour%时%A_Min%分%A_Sec%秒;
```

</details>


?> AHK实时变量语法参考[AHK文档](https://wyagd001.github.io/zh-cn/docs/Variables.htm)

### 模拟打字短语【进阶用法】

末尾双分号`;;`识别为模拟打字短语，会模拟键盘按键来输出短语

> \`r 或 \`n 或 \`r\`n 都为回车键<kbd>Enter</kbd>功能 <br>
> \`t 为 制表键<kbd>Capslock</kbd>功能 <br>
> \`b 为退格键<kbd>Backspace</kbd>功能

```ini
粘贴输入:*X:test1|abc`t123`n;
键盘输入:*X:test2|abc`t123`n;;
```

![RunAny键盘输出短语](/assets/images/RunAny键盘输出短语.gif)

---

## 热键映射

**有了RunAny左键右鼠不是梦，左边有大量未使用快捷组合键，利用好这些键，左手再也不用移到键盘的右边😁**

![RunAny短语和热键映射功能](/assets/images/RunAny短语和热键映射功能.gif)

映射空闲的组合键转变为常用键功能，如：

- 映射 左手的<kbd>Shift</kbd>+`空格键`<kbd>Space</kbd>  转变成 => `回车键`<kbd>Enter</kbd> 的功能
- 映射 左手的<kbd>Shift</kbd>+`大小写键`<kbd>CapsLock</kbd>  转变成 => `删除键`<kbd>Delete</kbd> 的功能

> RunAny.ini文件写入
<PRE>
左手回车&#9<+Space|{Enter}::
左手删除&#9LShift & CapsLock|{Delete}::
退格删除&#9CapsLock & Tab|{BackSpace}::
激活上个标签&#9LCtrl & CapsLock|^+{Tab}::
音量增加	LAlt & WheelUp|{Volume_Up 10}::
音量减少	LAlt & WheelDown|{Volume_Down 10}::
静音|{Volume_Mute}::
</PRE>

> `<`代表左边 `>`代表右边
> 
> 前面加`L`也代表左边 前面加`R`也代表右边
> 
> `^`代表Ctrl键 `!`代表Alt键 `#`代表Win键 `+`代表Shift键
> 
> `{Enter}`回车键 `{CapsLock}`是大小写键 `{BackSpace}`是退格键 `{Space}`是空格键 `{Tab}`是制表符键
> 
> `{Down}`方向下键 `{Up}`方向上键 `{Left}`方向左键 `{Right}`方向右键

?> 了解更多AHK热键文档：https://wyagd001.github.io/zh-cn/docs/Hotkeys.htm

### Vim映射模式，左Alt键辅助方案

<PRE>
--vim
&#9方向↓&#9&#60;!j|{Down}::
&#9方向↑&#9&#60;!k|{Up}::
&#9方向←&#9&#60;!h|{Left}::
&#9方向→&#9&#60;!l|{Right}::
&#9跳转左边单词&#9&#60;!n|^{Left}::
&#9跳转右边单词&#9&#60;!m|^{Right}::
&#9跳转行首&#9&#60;!,|{Home}::
&#9跳转行末&#9&#60;!.|{End}::
&#9跳转顶部&#9&#60;!i|^{Home}::
&#9跳转底部&#9&#60;!u|^{End}::
&#9---
&#9向↓选中&#9&#60;!+j|+{Down}::
&#9向↑选中&#9&#60;!+k|+{Up}::
&#9向←选中&#9&#60;!+h|+{Left}::
&#9向→选中&#9&#60;!+l|+{Right}::
&#9跳转选中左边单词&#9&#60;!+n|^+{Left}::
&#9跳转选中右边单词&#9&#60;!+m|^+{Right}::
&#9跳转选中到行首&#9&#60;!+,|+{Home}::
&#9跳转选中到行末&#9&#60;!+.|+{End}::
&#9跳转选中到顶部&#9&#60;!+i|^+{Home}::
&#9跳转选中到底部&#9&#60;!+u|^+{End}::
</PRE>

---

