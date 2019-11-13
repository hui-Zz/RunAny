## 【自定义树形菜单配置方法】

#### **首次使用请阅读：**

### [新建分类/目录]
**以 `-`开头为1级菜单， `--`+名称为2级菜单，`---`+名称3级菜单……以此类推，如：`-app应用`、`--img图像处理`、……  `---三级菜单`**

### [分隔符]
**单独一个 `-`是1级分隔符， `--`2级分隔符……以此类推，如：`-`、`--`、……  `----`**

### [菜单别名]
**在竖 `|` 前面添加程序的别名，如：`word|winword.exe`菜单上只会显示word**

### [注释]
**前加 `;`可以注释暂时不用的，如：`;cmd.exe`**

### [区分重名程序]

**如果电脑上有多个重名程序，加上全路径指定运行其中一个，如：`IE(32位)|C:\Program Files (x86)\Internet Explorer\iexplore.exe`（或创建该程序的快捷方式，在RunAny中添加使用快捷方式解决重名问题）**

> 默认支持exe、lnk、ahk、bat、cmd文件的无路径识别，其他后缀可以在RunAny设置中的Everything搜索参数，如支持doc文档免设路径识别
>
> 每个菜单名首字母(或用&指定任意)便是启动快捷键，如：`IE(&E)|iexplore.exe`快捷键是e


## 【进阶配置】

选中视频文件按<kbd>\`</kbd>只弹出`影音(&Video)`分类内容，多款播放软件选择使用

![RunAny新增修改菜单分类](/assets/images/RunAny新增修改菜单分类.jpg)

### [不同后缀不同菜单]

**在分类/目录名后加 `|`和后缀，选中不同文件出不同菜单**

  - 推荐使用RunAny的“修改菜单”界面，选中分类后右键编辑

  - 如果手动修改RunAny.ini：`-影音(&Video)|avi mkv mp4 rm rmvb flv wmv swf` 

> 如果后缀分类菜单中只有一款软件，那选中对应后缀文件后按<kbd>\`</kbd>将一键用该软件打开文件


### [半透明启动程序]

**推荐使用RunAny“新增修改菜单项”界面修改透明度**

![RunAny新增修改菜单项](/assets/images/RunAny新增修改菜单项.jpg)

**手动修改`RunAny.ini`：**

在应用别名后面添加 `_:数字`形式来透明启动应用（默认不透明,1-100是全透明到不透明），如88%透明度：

```ini
记事本(&N)_:88|Notepad.exe
```

---

## 【实用启动菜单项】

**复制以下需要的功能写入`RunAny.ini`文件保存，然后重启RunAny打开菜单即可使用**

<details>
<summary>【系统工具】</summary>

```autohotkey
;显示Win10中所有UWP应用
;ping百度测试网速
;重启我的电脑，释放内存
;--
;快捷用记事本修改host文件
-Sys
	Win10UWP应用|explorer.exe shell:::{4234d49b-0245-4df3-b780-3893943456e1}
	ping百度|cmd.exe /c "ping baidu.com -t"
	重启资源管理器|cmd.exe /c "taskkill /f /im explorer.exe" && start explorer.exe
	--
	我的电脑(&Z)|explorer.exe
	回收站|explorer.exe ::{645FF040-5081-101B-9F08-00AA002F954E}
	网上邻居|explorer.exe ::{208D2C60-3AEA-1069-A2D7-08002B30309D}
	hosts文件|notepad.exe C:\Windows\System32\drivers\etc\hosts

-系统工具
	注册表|regedit.exe
	磁盘清理|cleanmgr.exe
	写字板|write.exe
	屏幕讲述人|narrator.exe
	任务管理器|taskmgr.exe
	设备管理器|devmgmt.msc
	组策略|gpedit.msc
	本机用户和组|lusrmgr.msc

-控制面板
	控制面板(&C)|control.exe
	辅助功能选项(&E)|control.exe access.cpl
	添加或删除程序(&A)|control.exe appwiz.cpl
	显示 属性(&D)|control.exe desk.cpl
	Windows 防火墙(&F)|control.exe firewall.cpl
	添加硬件向导(&H)|control.exe hdwwiz.cpl
	Internet 属性(&I)|control.exe inetcpl.cpl
	区域和语言选项(&L)|control.exe intl.cpl
	游戏控制器(&J)|control.exe joy.cpl
	Java 控制面板(&Z)|control.exe jpicpl32.cpl
	鼠标属性(&M)|control.exe main.cpl
	声音和音频设备 属性(&X)|control.exe mmsys.cpl
	网络连接(&N)|control.exe ncpa.cpl
	网络安装向导(&Q)|control.exe netsetup.cpl
	用户帐户(&U)|control.exe lusrmgr.cpl
	ODBC 数据源管理器(&O)|control.exe odbccp32.cpl
	电源选项 属性(&P)|control.exe powercfg.cpl
	系统属性(&S)|control.exe sysdm.cpl
	电话和调制解调器选项(&R)|control.exe telephon.cpl
	日期和时间属性(&T)|control.exe timedate.cpl
	Windows 安全中心(&W)|control.exe wscui.cpl
	自动更新(&G)|control.exe wuaucpl.cpl

```

</details>
<br>
<details>
<summary>【快捷工具】</summary>

```autohotkey
;浏览器参数
-App
	chrome跨域|chrome.exe -disable-web-security --user-data-dir
	chrome隐身模式|chrome.exe --incognito

;快捷工具
-Zz
	RunAnyCtrl.ahk
	Ditto.exe
	Everything.exe
	FileLocatorPro.exe
	Listary.exe
	BCompare.exe
	vimd.exe
	StrokesPlus.exe
	TC_:88|Totalcmd64.exe

```

</details>
<br>
<details>
<summary>【编辑编程】</summary>

```autohotkey
;编辑器打开透明度88%，在文本文件上RunAny直接显示Edit菜单
-Edit|txt ini cmd bat md ahk html js sql
	Notepad&2_:88|Notepad2.exe /C
	&Sublime_:88|sublime_text.exe
	Notepad++_:88|Notepad++Portable.exe
	gVim|gVimPortable.exe
	EditPlus_:88|EditPlusPortable.exe
	SciTE_:88|SciTE.exe

;编程
-Code|java
	idea|idea64.exe
	eclipse.exe
	STS.exe
	GitHubDesktop.exe
	--
	nginx|nginx.exe -c conf/nginx.conf
	nginxReload|nginx.exe -s reload
	KillNginx|cmd.exe /c "taskkill /f /im nginx.exe"
	KillJava|cmd.exe /c "taskkill /f /im java.exe"

```

</details>