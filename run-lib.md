# 【功能库v1.1】

**复制以下需要的功能写入`RunAny.ini`文件保存，然后重启RunAny打开菜单即可使用**

<details>
<summary>【常用工具】App</summary>

```autohotkey
-常用(&App)	
	;聊天工具
	QQ.exe
	微信|WeChat.exe
	TIM.exe
	--
	;浏览器
	IE|%ProgramFiles%\Internet Explorer\iexplore.exe
	IE(32位)|C:\Program Files (x86)\Internet Explorer\iexplore.exe
	msedge.exe
	Firefox.exe
	chrome.exe
	360极速器X|360ChromeX.exe
	chrome新窗口|chrome.exe --profile-directory="Default" --new-window
	chrome跨域|chrome.exe -disable-web-security --user-data-dir
	chrome本地文件读取|chrome.exe --allow-file-access-from-files
	chrome隐身模式|chrome.exe --incognito
	--
	新窗口打开多网址|chrome.exe --new-window http://www.baidu.com" "https://hui-zz.gitee.io/runany
	新窗口多网站搜索|chrome.exe --new-window https://www.baidu.com/s?wd=%getZz%" "https://www.zhihu.com/search?q=%getZz%
	打开多个网址|%ComSpec% /c "start www.baidu.com & start https://hui-zz.gitee.io/runany"
	--
	计算器|calc.exe
	RunAny快速启动|RunAny.exe
	BCompare文件比较工具|BCompare.exe
	StrokesPlus鼠标手势|StrokesPlus.exe
	Ditto剪贴板|Ditto.exe
	天若OCR文字识别.exe
	flux护眼|flux.exe
	二维码识别生成|PsQREdit.exe
	KeePass密码管理|KeePass.exe
	--
```

</details>

<br>
<details>
<summary>【图片处理】Img</summary>

```autohotkey
-图片(im&G)|bmp gif jpeg jpg png webp	
	;图片查看
	ACDSee.exe
	XnView.exe
	IrfanView|i_view64.exe
	ComicsViewer.exe
	MangaMeeya.exe
	Honeyview.exe
	照片查看器|rundll32.exe C:\Windows\System32\shimgvw.dll,ImageView_Fullscreen %getZz%
	调用DO的看图|d8viewer.exe
	--
	;屏幕截图
	Snipaste.exe
	FSCapture.exe
	HprSnap8.exe
	截图工具|SnippingTool.exe
	搜狗输入法截图|screencapture.exe
	--
	;图片比较
	DiffImg|DiffImgPortable.exe
	VSDImageFinder|VSDuplicateImageFinder.exe
	--
	;动画录制
	GifCam.exe
	ga_main.exe
	gif123.exe
	--
	;图片编辑
	画图(&T)|mspaint.exe
	图标编辑|IconWorkshop.exe
	PhotoZoom|PhotoZoomPortable.exe
	PhotoScape|PhotoScapePortable.exe
	Photoshop.exe
	PS在线Photopea|chrome.exe  --profile-directory=Default --app-id=jdklklfpinionkgpmghaghehojplfjio
	--
	自动抠图(&R)|removebg.exe --api-key XXXXXXXXX "%getZz%"
	倍数_2 降噪_2(&S)|waifu2x-ncnn-vulkan.exe -i "%getZz%" -o "%getZz%_n2_s2.png" -n 2 -s 2
	;搜图
	谷歌搜图免图床|GoogleImageShell.exe search %getZz%
	--
	;壁纸
	每日桌面Bing壁纸|BingBgZz.ahk
	win10锁屏图片获取.ahk
	wallpaper|wallpaper64.exe
	;保存当前桌面壁纸到"我的图片"目录
	保存壁纸Win10|%ComSpec% /c "copy /y %A_AppData%\Microsoft\Windows\Themes\TranscodedWallpaper %A_MyDocuments%\..\Pictures\Wallpaper_%A_YYYY%%A_MM%%A_DD%%A_Hour%%A_Min%%A_Sec%.jpg"
	保存壁纸Win7|%ComSpec% /c "copy /y %A_AppData%\Microsoft\Windows\Themes\TranscodedWallpaper.jpg %A_MyDocuments%\..\Pictures\Wallpaper_%A_YYYY%%A_MM%%A_DD%%A_Hour%%A_Min%%A_Sec%.jpg"
	--
	
```

</details>
<br>
<details>
<summary>【影像音乐】Video</summary>

```autohotkey
-影音(&Video)|avi mkv mp4 rm rmvb flv wmv swf mp3	
	;音乐
	云音乐(&C)|cloudmusic.exe
	云音乐托盘启动(&C)|cloudmusic.exe --orpheus-startup=autorun
	QQ音乐|QQMusic.exe
	foobar2000|foobar2000.exe
	mcool[本地音乐播放器]|mcool.exe
	MusicPlayer2|MusicPlayer2.exe
	洛雪音乐助手桌面版|lx-music-desktop.exe
	--
	;视频
	哔哩哔哩.exe
	弹弹play|dandanplay.exe
	QQPlayer.exe
	XMP.exe
	PotPlayer|PotPlayerMini64.exe
	pot打开选中|PotPlayerMini64.exe /urldlg %getZz%
	Windows Media Player|wmplayer.exe
	--
	;剪辑
	剪映专业版|JianyingPro.exe
	必剪|BCUT.exe
	无损剪辑|BoilsoftVideoSplitterPortable.exe
	LosslessCut|LosslessCut.exe
	--
	格式工厂|FormatFactory.exe
	小丸工具箱|xiaowan.exe
	MediaMux|MediaMux.exe
	--
	;字幕
	aegisub32|aegisub32.exe
	SubtitleEdit|SubtitleEdit.exe
	MKVExtract|gMKVExtractGUI.exe
	SrtEdit|SrtEditPortable.exe
	--
```

</details>
<br>
<details>
<summary>【网络下载】Down</summary>

```autohotkey
-下载(&Down)
	;下载工具
	迅雷|Thunder.exe
	IDM(&D)|IDMan.exe
	IDM下载选中|IDMan.exe /d %getZz%
	qbittorrent.exe
	uTorrent.exe
	B站下载|JiJiDownForWPF.exe
	文件Hash校验|MyHash.exe
	--
	;网盘
	百度网盘|BaiduNetdisk.exe
	百度网盘补全打开|https://pan.baidu.com/s/%getZz%
	坚果云|Nutstore.exe
	小米云服务.lnk
	--
	;m3u8下载
	N_m3u8DL-CLI|N_m3u8DL-CLI-SimpleG.exe
	HmDX[很萌下载器]|很萌下载器HmDX.exe
	--
	;软件工具箱
	盘姬工具箱|Sunshine.exe
	在线工具包|Cencrack在线工具包6.46.exe
	黑科技工具箱V1.2.exe
	--
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
	SumatraPDF.exe
	--WPS(&S)
		WPS|wpsoffice.exe
		&WPS文字|WPS文字.lnk
		WP&S表格|WPS表格.lnk
		W&PS演示|WPS演示.lnk
		;WPS(&W)|WPS.exe
		;ET(&E)|et.exe
		;WPP(&P)|wpp.exe
	--
	;远程桌面
	远程桌面连接(&C)|mstsc.exe
	ToDesk.exe
	SunloginClient.exe
	TeamViewer.exe
	AnyDesk.exe
	FeiQ.exe
	Xshell.exe
	X&ftp|Xftp.exe
	--
	;屏幕扩展
	Twomon PC Program.exe
	spacedeskServiceTray.exe
	--
	;RunAny插件函数：huiZz_Work.ahk
	发送邮件|huiZz_Work[mailto](addressee,subject,%getZz%)
	选中地址发送剪贴板内容邮件|huiZz_Work[mailto](%getZz%,邮件主题,%Clipboard%)
	老板键Win|huiZz_Work[boss_win](%"idea64.exe"%)
	--

-学习(s&Tudy)|pdf xmind	
	;笔记记录
	为知|Wiz.exe
	印象笔记|Evernote.exe
	有道云笔记|YoudaoNote.exe
	Obsidian.exe
	OneNote.exe
	;思维导图
	XMind.exe
	XMind ZEN.exe
	--
	;翻译软件
	有道词典|YoudaoDict.exe
	aboboo.exe
	--
```

</details>
<br>
<details>
<summary>【文件管理】File</summary>

```batch
-文件管理(&File)|folder		
	FastCopy最快拷贝工具|FastCopy.exe	
	Unlocker解除进程锁定|Unlocker.exe	
	chfs局域网文件共享|chfsgui.exe	
	SpaceSniffer磁盘占用分析|SpaceSniffer.exe	
	DiskGenius硬盘分区|DiskGenius64.exe	
	UniversalViewer万能文件预览|Viewer.exe	
	Restorator应用程序编辑器|Restorator.exe	
	--	
	;第三方资源管理器	
	;Directory Opus	
	新标签打开|dopusrt.exe /open	
	右侧标签打开|dopusrt.exe /acmd Go "%getZz%" OPENINRIGHT NEWTAB	
	当前标签打开|dopusrt.exe /acmd	
	--	
	;TC	
	TC文件管理_:88|Totalcmd.exe
	用tc打开|TOTALCMD64.EXE /S /O	
	TC插件管理|Plugman.exe	
	vim快捷映射TC|vimd.exe	
	--	
	;文件压缩	
	7-Zip|7zFM.exe	
	WinRAR.exe	
	UltraISO.exe	
	isocmdGUI.exe	
	MiniWinMount.exe	
	bandizip(安装)|Bandizip.exe	
	bandizip(便携)|Bandizip.x64.exe	
	压缩Java项目|WinRar.exe u -agYYYYMMdd -m5 -s -r -o+ -ep1 -x*\.svn -x*\.git -x*\.run -x*\.settings -x*\target -x*\.classpath -x*\.project -x*\.idea -x*.iml -x\desktop.ini -x\.metadata -x\.recommenders -x\logs -x\RemoteSystemsTempFiles "D:\project_.rar" "%getZz%\*"	
	--	
	;文件夹图标修改	
	文件夹改图标|DrFolder.exe -folder	
	--	
	;转区	
	直接转区|LEProc.exe	
	用此程序配置运行|LEProc.exe -run	
	--	
	;文件删除恢复	
	--文件恢复	
		EasyRecovery.exe
		Piriform Recuva.exe
		Recuva|RecuvaPortable.exe
		FinalData3.0.exe
		SuperRecovery2.7.exe
	--

-文件操作|public text file	
	移动文件到软件|%ComSpec% /c "move /y "%getZz%" "D:\Software\"
	复制选中文件到D盘|%ComSpec% /c "xcopy /h /y "%getZz%" "D:\""
	文件系统关联编辑|edit
	文件属性|properties
	--
	多软件打开|huiZz_BatchRun[multi_open](%getZz%,"notepad.exe","wordpad.exe")
	多软件多次无路径打开|huiZz_BatchRun[multi_open](%getZz%,%"notepad2.exe"%,%"sublime_text.exe"%)
	多软件一次打开选中多文件|huiZz_BatchRun[multi_open_once](%getZz%,%"chrome.exe"%,%"sublime_text.exe"%)
	--
	显示隐藏文件|huiZz_System[system_hidefile_zz](1,0,0)
	显示所有文件|huiZz_System[system_hidefile_zz](1,1,0)
	隐藏所有文件|huiZz_System[system_hidefile_zz](0,0,0)
	隐藏文件后缀|huiZz_System[system_hidefile_zz](0,0,1)
	||
	复制名称|huiZz_System[system_file_path_zz](%getZz%,name)
	复制路径|huiZz_System[system_file_path_zz](%getZz%,path)
	复制所在目录|huiZz_System[system_file_path_zz](%getZz%,dir)
	复制无后缀名称|huiZz_System[system_file_path_zz](%getZz%,nameNoExt)
	复制lnk指向路径|huiZz_System[system_file_path_zz](%getZz%,lnkTarget)
	复制lnk指向目录|huiZz_System[system_file_path_zz](%getZz%,lnkDir)
	创建快捷方式到桌面|huiZz_System[system_create_shortcut](%getZz%,%A_Desktop%)
	--

-文件搜索|text	
	Ev文件秒搜|Everything.exe
	Ev索引强制重建|Everything.exe -reindex
	Ev安装服务|Everything.exe -install-service
	Ev搜索选中内容|Everything.exe -search "%getZz%"
	Ev搜索JSON|Everything.exe -search "*.json %getZz%"
	Ev搜索OneDrive冲突|Everything.exe -search "!C:\ case:-DESKTOP-"
	Ev搜索当天文件|Everything.exe -search "dm:today"
	Ev搜索昨天文件|Everything.exe -search "dm:yesterday"
	Ev搜索压缩包|Everything.exe -search "ext:7z;ace;arj;bz2;cab;gz;gzip;r00;r01;r02;r03;rar;tar;tgz;z;zip %getZz%"
	--
	;全文搜索
	AnyTXT|ATGUI.exe
	AnyTXT直接搜|ATGUI.exe /s %getZz%
	FileLocator[免索引]|FileLocatorPro.exe
	FLP搜选中文件夹|FileLocatorPro.exe -c %Clipboard% -d %getZz%
	FLP选中文字全盘搜|FileLocatorPro.exe -r -d "C:;D:;E:;F:;G:" -c %getZz%
	--

```

</details>
<br>
<details>
<summary>【编辑编程】Edit Code</summary>

```batch
;编辑器打开透明度88%，在文本文件上RunAny直接显示Edit菜单
-编辑(&Edit)|txt ini cmd bat md ahk html js sql	
	记事本(&N)_:88|notepad.exe
	写字板|write.exe
	Notepad&2_:88|Notepad2.exe
	&Sublime_:88|sublime_text.exe
	gvim.exe
	Typora.exe
	--

;编程
-编程(&Code)|java	
	;开发
	idea_:95|idea64.exe
	eclipse.exe
	vscode|%scoop%\apps\vscode\current\Code.exe
	SciTE_:88|SciTE.exe
	--
	GitHubDesktop.exe
	postman.exe
	jmeter.bat
	jd-gui.exe
	Ahk2Exe|Ahk2Exe.exe /in
	--
	nginx启动|nginx.exe -c conf/nginx.conf
	nginx重启|nginx.exe -s reload
	nginx结束|%ComSpec% /c "taskkill /f /t /im nginx.exe & ping -n 2 127.1>nul"
	RabbitMQ重启|%ComSpec% /c "net stop RabbitMQ && net start RabbitMQ & ping -n 2 127.1>nul"
	KillNode|%ComSpec% /c "taskkill /f /t /im node.exe & ping -n 2 127.1>nul"
	KillJava|%ComSpec% /c "taskkill /f /t /im java.exe & ping -n 2 127.1>nul"
	删除Maven库.lastUpdated|%ComSpec% /c "D: & cd D:\Users\.m2\repository & for /r %i in (*.lastUpdated) do del %i"
	java调试启动Jar|%ComSpec% /c "java -jar -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005 %getZz%"
	--
	;数据库
	Navicat(&C)|navicat.exe
	redis-server.exe
	rdm.exe
	PowerDesigner|PdShell16.exe
	--
```

</details>
<br>
<details>
<summary>【系统工具】Sys</summary>

?> 使用 `%ComSpec%` 代替原来的 `cmd.exe` 可以准确定位 `C:\WINDOWS\system32\cmd.exe`，避免有多个cmd.exe定位错误的情况

```autohotkey
-系统(&Sys)	
	;系统工具	
	我的电脑(&Z)|explorer.exe	
	回收站|explorer.exe ::{645FF040-5081-101B-9F08-00AA002F954E}	
	网上邻居|explorer.exe ::{208D2C60-3AEA-1069-A2D7-08002B30309D}	
	Win10UWP应用列表|explorer.exe shell:::{4234d49b-0245-4df3-b780-3893943456e1}	
	--	
	系统进程查看专业软件|ProcessExplorer.exe	
	文件注册表写入监控专业软件|ProcessMonitor.exe	
	一键隐藏窗口(HiddeX)2.5.22汉化版.exe	
	网卡MAC地址修改工具.exe	
	强力卸载工具|geek.exe	
	IObitUninstaler.exe	
	--	
	;虚拟环境	
	Sandboxie沙盘|Sandboxie.exe	
	在沙盘中运行|Start.exe /box:__ask__	
	VMware(&V)|VMware.exe	
	VirtualBox.exe	
	--	
	BlueStacks蓝叠|BluestacksGP.exe	
	雷电模拟器|dnplayer.exe	
	雷电模拟器开机启动APP|dnplayer.exe launch --name 雷电模拟器 --key call.reboot --value com.hui.h	
	--	
	;系统操作	
	;结束桌面后有几率桌面重启失败，可以手动执行上面的 `我的电脑` 或运行 explorer.exe	
	;或使用另一种方式的插件脚本：重启桌面|huiZz_System[system_explorer_zz]()	
	重启资源管理器|%ComSpec% /c "taskkill /f /im explorer.exe & start explorer.exe"	
	重启桌面|huiZz_System[system_explorer_zz]()	
	关闭显示器|%A_WinDir%\system32\scrnsave.scr /s	
	系统锁屏|rundll32.exe user32.dll LockWorkStation	
	系统睡眠|rundll32.exe powrprof.dll,SetSuspendState 0,1,0	
	系统休眠|rundll32.exe powrprof.dll,SetSuspendState	
	系统注销|shutdown.exe -l	
	系统立即关机|shutdown.exe -s -t 0	
	系统立即重启|shutdown.exe -r -t 0	
	--	
	系统音量增加	LAlt & WheelUp|huiZz_System[system_sound_volume](1,10)
	系统音量减少	LAlt & WheelDown|huiZz_System[system_sound_volume](0,10)
	系统静音|huiZz_System[system_sound_volume](2,0)	
	系统音量50|huiZz_System[system_sound_volume](2,50)	
	--	
		
-系统命令(&Q)|text		
	;%ComSpec% = C:\WINDOWS\system32\cmd.exe	
	命令行提示符|%ComSpec%	
	PowerShell(&S)[#]|%A_WinDir%\system32\WindowsPowerShell\v1.0\powershell.exe	
	WindowsTerminal.exe	
	以管理员身份运行|huiZz_System[system_runas_zz](%getZz%)	
	执行选中命令行|%ComSpec% /c "%getZz%"	
	批量cmd命令|huiZz_System[system_batch_cmd](%getZz%,"`n")	
	--	
	hosts文件|notepad.exe %A_WinDir%\System32\drivers\etc\hosts	
	清空回收站|huiZz_System[system_recycle_empty]()	
	注册表自动定位|huiZz_System[system_regedit_zz](%getZz%)	
	打开RunAny注册表位置|huiZz_System[system_regedit_zz](HKEY_CURRENT_USER\Software\RunAny)	
	--	
	;网络命令	
	本机ip地址|huiZz_System[system_ip_zz]()	
	ping百度|%ComSpec% /c "ping baidu.com -t"	
	ping选中地址|%ComSpec% /c "ping %getZz% -t"	
	ping选中地址2|huiZz_System[system_ping_zz](%getZz%)	
	批量ping命令|huiZz_System[system_batch_ping](%getZz%,"`n")	
	系统代理192.168.43.1|huiZz_System[system_proxy_zz](192.168.43.1:8128)	
	系统代理关闭|huiZz_System[system_proxy_zz]()	
	--	

-Windows工具
	注册表|regedit.exe
	磁盘清理|cleanmgr.exe
	屏幕讲述人|narrator.exe
	任务管理器|taskmgr.exe
	步骤记录器|psr.exe
	--
	计算机管理|compmgmt.msc
	设备管理器|devmgmt.msc
	磁盘管理器|diskmgmt.msc
	组策略|gpedit.msc
	共享文件夹|fsmgmt.msc
	服务|services.msc
	本地安全策略|secpol.msc
	本机用户和组|lusrmgr.msc
	任务计划程序|taskschd.msc
	系统认证证书|certmgr.msc
	事件查看器|eventvwr.msc
	性能监视器|perfmon.msc
	策略的结果集|rsop.msc
	组件服务|comexp.msc

-控制面板
	控制面板(&C)|control.exe
	辅助功能选项(&E)|control.exe access.cpl
	添加或删除程序(&A)|control.exe appwiz.cpl
	显示属性(&D)|control.exe desk.cpl
	Windows防火墙(&F)|control.exe firewall.cpl
	添加硬件向导(&H)|control.exe hdwwiz.cpl
	Internet属性(&I)|control.exe inetcpl.cpl
	Internet属性-连接|control.exe inetcpl.cpl,,4
	区域和语言选项(&L)|control.exe intl.cpl
	游戏控制器(&J)|control.exe joy.cpl
	Java控制面板(&Z)|control.exe jpicpl32.cpl
	鼠标属性(&M)|control.exe main.cpl
	声音和音频设备属性(&X)|control.exe mmsys.cpl
	网络连接(&N)|control.exe ncpa.cpl
	网络安装向导(&Q)|control.exe netsetup.cpl
	用户帐户(&U)|control.exe lusrmgr.cpl
	ODBC数据源管理器(&O)|control.exe odbccp32.cpl
	电源选项属性(&P)|control.exe powercfg.cpl
	系统属性(&S)|control.exe sysdm.cpl
	电话和调制解调器选项(&R)|control.exe telephon.cpl
	日期和时间属性(&T)|control.exe timedate.cpl
	Windows安全中心(&W)|control.exe wscui.cpl
	自动更新(&G)|control.exe wuaucpl.cpl

```

</details>
<br>
<details>
<summary>【短语输入】Input</summary>

```autohotkey
-短语(inpu&T)|text		
	:*X:magn|magnet:?xt=urn:btih:;	
	vim删除重复行|^(.*?)$\s+?^(?=.*^\1$);	
	--时间|text	
		;当前时间（变量语法参考AHK文档https://wyagd001.github.io/zh-cn/docs/Variables.htm）
		日期:*X:date;|%A_YYYY%%A_MM%%A_DD%;
		日期-:*X:date-|%A_YYYY%-%A_MM%-%A_DD%;
		日期.:*X:date.|%A_YYYY%.%A_MM%.%A_DD%;
		日期中文':*X:date'|%A_YYYY%年%A_MM%月%A_DD%日;
		时间:*X:time;|%A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%;
		时间数字:*X:timee|%A_YYYY%%A_MM%%A_DD%%A_Hour%%A_Min%%A_Sec%;
		时间中文:*X:time'|%A_YYYY%年%A_MM%月%A_DD%日 %A_Hour%时%A_Min%分%A_Sec%秒;
		---
	--命令|text cmd.exe powershell.exe WindowsTerminal.exe 	
		端口:*X:netstatf|netstat -ano | findstr ;
		:*X:aria2;|aria2c --enable-rpc --rpc-allow-origin-all`n;;
		:*X:jekyll;|bundle exec jekyll serve`n;;
		:*X:docs;|docsify serve;
		:*X:pipdb;|pip install -r requirements.txt -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com;
		---
		;Scoop
		scoop clean:*X:scoopcl;|scoop cache rm *`nscoop cleanup *`n;;
		scoop proxy:*X:scoop1;|scoop config proxy 127.0.0.1:1080`n;;
		scoop rm proxy:*X:scooprp;|scoop config rm proxy`n;;
		scoop rm aria2-enabled:*X:scoopra;|scoop config rm aria2-enabled`n;;
		scoop aria2 false:*X:scoopcaf;|scoop config aria2-enabled false`n;;
		---
		;安卓
		adb设备列表:*X:adbd|adb devices`n;;
		adb连接手机:*X:adbc|adb connect %phone_ip%:5555`n;;
		:*X:scrcpy;|scrcpy -s %phone_ip%:5555 -S -b 2M --max-fps 60`n;;
		---
	--	
	--Linux|Xshell.exe	
		创建文件touch|touch;
		sh授权|chmod u+x;
		GUID|new-guid;
		Linux版本|cat /etc/issue;
		磁盘容量|df -h;;
		目录大小占用|du -sh *;;
		目录大小排序|du -sm * | sort -n;;
		全局搜索JAR|find / -name '*.jar' -size +5M;
		端口:*X:netgrep|netstat -apn|grep ;
		---
		:*X:psjava|ps -ef | grep java`n;;
		:*X:pstomcat|ps -ef | grep tomcat`n;;
		:*X:psjetty|ps -ef | grep jetty`n;;
		:*X:psnginx|ps -ef | grep nginx`n;;
		前20占用进程:*X:ps20|ps aux | head -1;ps aux |grep -v PID |sort -rn -k +4 | head -20`n;;
		---
		:*X:cdtom|cd /usr/local/apache-tomcat-7.0.77/`n;;
		:*X:tomsd|/usr/local/apache-tomcat-7.0.77/bin/shutdown.sh`n;;
		:*X:tomst|/usr/local/apache-tomcat-7.0.77/bin/startup.sh`n;;
		:*X:nginx reload|/usr/local/nginx-1.15.10/sbin/nginx -s reload`n;;
		重启防火墙:*X:iptables|service iptables restart`n;;
		:*X:logstash -f|./logstash -f ../config/first-pipeline.conf --config.reload.automatic`n;;
		---
	--	
```

</details>