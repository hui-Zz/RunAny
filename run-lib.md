# 【功能库】

**复制以下需要的功能写入`RunAny.ini`文件保存，然后重启RunAny打开菜单即可使用**

<details>
<summary>【常用工具】App</summary>

```autohotkey
-常用(&App)
	微信|WeChat.exe
	TIM.exe
	--
	chrome跨域|chrome.exe -disable-web-security --user-data-dir
	chrome隐身模式|chrome.exe --incognito
	IE|%ProgramFiles%\Internet Explorer\iexplore.exe
	IE(32位)|C:\Program Files (x86)\Internet Explorer\iexplore.exe
	Firefox.exe
	--
	BCompare文件比较工具|BCompare.exe
	StrokesPlus鼠标手势|StrokesPlus.exe
	Ditto剪贴板|Ditto.exe
	天若OCR文字识别.exe
	flux护眼|flux.exe
```

</details>
<br>
<details>
<summary>【办公学习】Work Study</summary>

```autohotkey
-办公(wo&Rk)|doc docx xls xlsx ppt pptx wps et dps csv
	word(&W)|winword.exe
	Excel(&E)|excel.exe
	PPT(&T)|powerpnt.exe
	--WPS(&S)
		WPS2019|wpsoffice.exe
		&WPS文字|WPS文字.lnk
		WP&S表格|WPS表格.lnk
		W&PS演示|WPS演示.lnk
		;WPS(&W)|WPS.exe
		;ET(&E)|et.exe
		;WPP(&P)|wpp.exe
	--
	;远程桌面
	远程桌面连接|mstsc.exe
	TeamViewer.exe
	SunloginClient.exe
	AnyDesk.exe

-学习(s&Tudy)|pdf
	;笔记记录
	为知(&W)|Wiz.exe
	印象笔记|Evernote.exe
	有道云笔记|YoudaoNote.exe
	OneNote.exe
	--
	;翻译软件
	有道词典|YoudaoDict.exe
	--
	;查看PDF
	SumatraPDF.exe
```



</details>
<br>
<details>
<summary>【图片处理】</summary>

```autohotkey
-图片(im&G)|bmp gif jpeg jpg png
	;图片查看
	ACDSee.exe
	XnView.exe
	IrfanView|IrfanViewPortable.exe
	ComicsViewer.exe
	MangaMeeya.exe
	MassiGraPortable.exe
	--
	;屏幕截图
	Snipaste.exe
	HprSnap8.exe
	FSCapture.exe
	截图工具|SnippingTool.exe
	--
	;图片比较
	DiffImg|DiffImgPortable.exe
	VSDImageFinder|VSDuplicateImageFinder.exe
	--
	;动画录制
	GifCam.exe
	ga_main.exe
	--
	;图片编辑
	画图(&T)|mspaint.exe
	IconWorkshop.exe
	PhotoZoom|PhotoZoomPortable.exe
	PhotoScape|PhotoScapePortable.exe
	Photoshop.exe
	--
	;保存当前桌面壁纸到"我的图片"目录
	保存壁纸Win10|%ComSpec% /c "copy /y %A_AppData%\Microsoft\Windows\Themes\TranscodedWallpaper %A_MyDocuments%\..\Pictures\Wallpaper_%A_YYYY%%A_MM%%A_DD%%A_Hour%%A_Min%%A_Sec%.jpg"
	保存壁纸Win7|%ComSpec% /c "copy /y %A_AppData%\Microsoft\Windows\Themes\TranscodedWallpaper.jpg %A_MyDocuments%\..\Pictures\Wallpaper_%A_YYYY%%A_MM%%A_DD%%A_Hour%%A_Min%%A_Sec%.jpg"
	
```

</details>
<br>
<details>
<summary>【影像音乐】</summary>

```autohotkey
-影音(&Video)|avi mkv mp4 rm rmvb flv wmv swf mp3
	云音乐(&C)|cloudmusic.exe
	QQ音乐|QQMusic.exe
	--
	QQPlayer.exe
	XMP.exe
	PotPlayer|PotPlayerMini64.exe
	Windows Media Player|wmplayer.exe
	--
	FormatFactory.exe
	小丸工具箱|xiaowan.exe
```

</details>
<br>
<details>
<summary>【网络下载】</summary>

```autohotkey
-Down
	文件Hash校验|Hash.exe
	百度网盘|BaiduNetdisk.exe
	百度网盘补全打开|https://pan.baidu.com/s/%getZz%
	--
	IDM(&D)|IDMan.exe
	迅雷|Thunder.exe
	冰点文库下载|iDocDown.exe
	uTorrent.exe
	MiPony.exe
	--
	;软件工具箱
	盘姬工具箱|Sunshine.exe
	在线工具包|Cencrack在线工具包5.25.exe
	黑科技工具箱V1.2.exe
```

</details>
<br>
<details>
<summary>【编辑编程】</summary>

```autohotkey
;编辑器打开透明度88%，在文本文件上RunAny直接显示Edit菜单
-Edit|txt ini cmd bat md ahk html js sql
	记事本(&N)_:88|notepad.exe
	写字板|write.exe
	Notepad&2_:88|Notepad2.exe /C
	&Sublime_:88|sublime_text.exe
	gvim.exe
	EditPlus_:88|EditPlus.exe
	SciTE_:88|SciTE.exe
	--
	Typora.exe
	XMind.exe

;编程
-Code|java
	idea_:95|idea64.exe
	eclipse.exe
	vscode|%scoop%\apps\vscode\current\Code.exe
	GitHubDesktop.exe
	--
	Xshell.exe
	X&ftp|Xftp.exe
	Terminus.exe
	--
	nginx|nginx.exe -c conf/nginx.conf
	nginxReload|nginx.exe -s reload
	KillNginx|%ComSpec% /c "taskkill /f /im nginx.exe"
	KillJava|%ComSpec% /c "taskkill /f /t /im java.exe & ping -n 2 127.1>nul"
	RabbitMQ|%ComSpec% /c "net stop RabbitMQ && net start RabbitMQ & ping -n 2 127.1>nul"
```

</details>
<br>
<details>
<summary>【文件管理】</summary>

```autohotkey
-文件(&File)
    ;文件搜索
	Everything文件秒搜|Everything.exe
	Everything搜索选中内容|Everything.exe -search "%getZz%"
	Listary.exe
	FileLocatorPro.exe
	--
	TC文件管理|Totalcmd.exe
	TC_:88|Totalcmd64.exe
	vimd.exe
	Plugman.exe
	--
	;文件压缩
	WinRAR.exe
	7-&Zip|7zFM.exe
	MiniWinMount.exe
	isocmdGUI.exe
	UltraISO.exe
	--
	FastCopy.exe
	Unlocker.exe
	Viewer.exe
	--文件删除恢复
		EasyRecovery.exe
		Piriform Recuva.exe
		Recuva|RecuvaPortable.exe
		FinalData3.0.exe
		SuperRecovery2.7.exe
```

</details>
<br>
<details>
<summary>【系统工具】</summary>

```autohotkey
-Sys
	activehotkeys.exe
	AntiFreeze.exe
	SpaceSniffer.exe
	ProcessExplorer.exe
	ProcessMonitor.exe
	WinspectorU.exe
	--
	Sandboxie.exe
	VMware(&V)|VMware.exe
	VirtualBox.exe

-系统命令
	我的电脑(&Z)|explorer.exe
	回收站|explorer.exe ::{645FF040-5081-101B-9F08-00AA002F954E}
	网上邻居|explorer.exe ::{208D2C60-3AEA-1069-A2D7-08002B30309D}
	--
	;%ComSpec% = C:\WINDOWS\system32\cmd.exe
	命令行提示符|%ComSpec%
	PowerShell|%A_WinDir%\system32\WindowsPowerShell\v1.0\powershell.exe
	计算器|calc.exe
	--
	Win10UWP应用|explorer.exe shell:::{4234d49b-0245-4df3-b780-3893943456e1}
	ping百度|%ComSpec% /c "ping baidu.com -t"
	打开多个网址|%ComSpec% /c "start www.baidu.com & start www.github.com"
	hosts文件|notepad.exe %A_WinDir%\System32\drivers\etc\hosts
	清空回收站(C盘D盘)|%ComSpec% /c "rd /s C:\$Recycle.Bin D:\$Recycle.Bin"
	复制选中文件到D盘|%ComSpec% /c "xcopy /h /y "%getZz%" "D:\""
	执行选中命令行|%ComSpec% /c "%getZz%"
	ping选中地址|%ComSpec% /c "ping %getZz% -t"
	--
	重启资源管理器|taskkill /f /im explorer.exe && start explorer.exe
	关闭显示器|%A_WinDir%\system32\scrnsave.scr /s
	系统锁屏|rundll32.exe user32.dll LockWorkStation
	系统睡眠|rundll32.exe powrprof.dll,SetSuspendState 0,1,0
	系统休眠|rundll32.exe powrprof.dll,SetSuspendState
	系统注销|shutdown.exe -l
	系统立即关机|shutdown.exe -s -t 0
	系统立即重启|shutdown.exe -r -t 0

-系统工具
	注册表|regedit.exe
	服务|services.msc
	磁盘清理|cleanmgr.exe
	屏幕讲述人|narrator.exe
	任务管理器|taskmgr.exe
	设备管理器|devmgmt.msc
	组策略|gpedit.msc
	本机用户和组|lusrmgr.msc
	步骤记录器|psr.exe

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
<summary>【短语输入】</summary>

```autohotkey
-输入(inpu&T)
	;当前时间（变量语法参考AHK文档https://wyagd001.github.io/zh-cn/docs/Variables.htm）
	日期:*X:date;|%A_YYYY%%A_MM%%A_DD%;
	日期-:*X:date-|%A_YYYY%-%A_MM%-%A_DD%;
	日期.:*X:date.|%A_YYYY%.%A_MM%.%A_DD%;
	日期中文':*X:date'|%A_YYYY%年%A_MM%月%A_DD%日;
	时间:*X:time;|%A_YYYY%%A_MM%%A_DD%%A_Hour%%A_Min%%A_Sec%;
	时间_:*X:time-|%A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%;
	时间中文_:*X:time'|%A_YYYY%年%A_MM%月%A_DD%日 %A_Hour%时%A_Min%分%A_Sec%秒;
	--
	:*X:magn|magnet:?xt=urn:btih:;

-命令
	scoop clean|scoop cache rm *`nscoop cleanup *`n;;
	端口:*X:netstat|netstat -ano | findstr ;
	--
	adb连接:*X:adbc|adb connect ;;
	adb设备:*X:adbd|adb devices`n;;
	--
	:*X:scrcpy;|scrcpy -S`n;;
	:*X:aria2;|aria2c --enable-rpc --rpc-allow-origin-all`n;;

-Linux
	创建文件touch|touch;
	端口:*X:netgrep|netstat -apn|grep ;
	java:*X:psjava|ps -ef | grep java`n;;
	nginx:*X:psnginx|ps -ef | grep nginx`n;;
	前20占用进程:*X:ps20|ps aux | head -1;ps aux |grep -v PID |sort -rn -k +4 | head -20`n;;
	:*X:cdtom|cd /usr/local/apache-tomcat-7.0.77/`n;;
	:*X:tomsd|/usr/local/apache-tomcat-7.0.77/bin/shutdown.sh`n;;
	:*X:tomst|/usr/local/apache-tomcat-7.0.77/bin/startup.sh`n;;
	:*X:nginx reload|/usr/local/nginx-1.15.10/sbin/nginx -s reload`n;;
	重启防火墙:*X:iptables|service iptables restart`n;;
	:*X:logstash -f|./logstash -f ../config/first-pipeline.conf --config.reload.automatic`n;;
```

</details>