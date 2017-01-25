# 【RunAny】一劳永逸的快速启动工具 v2.2

只需配置一个自定义程序菜单，就可以快速启动任何电脑任何路径的程序😎

家里和公司电脑还是笔记本都使用同一套配置，云端同步就更是如虎添翼！

RunAny追求就是：<u>**一劳永逸**</u>
---

RunAny启动软件就跟打字一样高效方便（如<kbd>\`</kbd>为热键）：

- \`ew就是work工作分类下的Word
- \`aw就是app常用分类下的Wiz
- \`fw就是file文件分类下的WinRAR

(PS:输入\`可以<kbd>Win</kbd>+<kbd>\`</kbd>输入)

---

RunAny演示：<img src="https://raw.githubusercontent.com/hui-Zz/RunAny/master/RunAny%E6%BC%94%E7%A4%BA.gif" alt="RunAny演示" style="max-width:60%;">
---

[【RunAny版本更新历史】](#ver)


[【自定义树形菜单配置方法：】](#tree)

---

建议：hui0.0713@gmail.com

讨论QQ群：[246308937【RunAny快速启动一劳永逸】](https://jq.qq.com/?_wv=1027&k=445Ug7u)、[3222783【AutoHotkey高级群】](https://jq.qq.com/?_wv=1027&k=43uBHer)、[493194474【软客】](https://jq.qq.com/?_wv=1027&k=43trxF5)

支持RunAny：![支付宝](https://raw.githubusercontent.com/hui-Zz/RunAny/master/支持RunAny.jpg)

---

## <a name="tree">【自定义树形菜单配置方法：】</a>

* 以-开头+名称为1级目录名,--名称为2级以此类推，如：`-app`、`--img`
* 单独一个-是1级分隔符，--2级亦是如此，如：`-`、`--`
* 每个菜单名首字母(或用&指定任意)便是启动快捷键，如：`IE(&E)`快捷键是e
* 可用竖|添加别名前缀,菜单便会显示别名，如：`TC|Totalcmd.exe`会显示TC
* 前加;可以注释暂时不需要用的，如：`;cmd.exe`
* 末尾;识别为短语可以直接输出，如：`hui0.0713@gmail.com;`
* 如果电脑上有多个同名程序，加上全路径指定运行其中一个
* 运行除exe、lnk后缀之外的，也可用全路径或者创建快捷方式来放入RunAny菜单

---

## <a name="ver">【RunAny版本更新历史】</a>

### v2.2 快捷🎈
+ **增加lnk全盘路径和图标识别**
+ **增加开机自动选项**
+ **增加一键Everything[搜索选中文字][激活][隐藏]**
+ *增加输出简单短语的功能*
+ *新增屏蔽RunAny热键的程序列表*
+ *支持TotalCommander打开文件夹*
+ ~~现在可以隐藏失效的项目~~
+ 菜单编辑添加树时自动为其增加子项目
+ 初次运行的菜单配置增加了通用分类和流行软件
+ 初次运行自动添加桌面快捷方式
* 修复菜单删除项目时Del与删文字冲突
* 修复了批量导入问题且现在可以导入快捷方式
* 修正了网址的正则

### v2.1 酷炫😉
+ 批量导入程序名称
+ 图标自定义化(包括托盘图标)
+ 优化搜索条件，排除C:\Windows及其他升级文件夹
* 现在会自动检查Everything.dll的可用性，需要用Everything64.dll时提示

### v2.0 正式更名为RunAny，易用性大幅提升，兼容菜单文件编辑和GUI界面编辑

### v1.9 自定义配置优化

+ 添加Everything路径配置选项
+ 添加显示热键自定义配置选项
+ 菜单配置现在单独保存在RunMenuZz.ini
+ 只有在用户设置与默认不同才将配置保存在注册表HKEY_CURRENT_USER\Software\RunAny
+ 添加重置按钮，清除注册表配置，不留痕迹

### v1.8 集成Everything自动检索程序，从此程序随便放目录都能用RunMenu运行了😀
