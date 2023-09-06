/*
╔═══════════════════════════════════════════════════════════════
║【Scoop使用IDM下载更新】 https://github.com/hui-Zz @2022.12.01
║ by hui-Zz 建议：hui0.0713@gmail.com 讨论QQ群：246308937
╚═══════════════════════════════════════════════════════════════
*/
global RunAny_Plugins_Version:="1.3.3"
#Persistent             ;~让脚本持久运行
#SingleInstance,Force   ;~运行替换旧实例
DetectHiddenWindows,On
Menu,Tray,Icon,SHELL32.dll,123
global scoopUpdateAppList:={}
global scoopAppDownOutList:={}
global scoopAppDownUrlList:=[]
try EnvGet, scoopPath, scoop
global DownDir:="",IDMPath:="",DownUrl:="",DownCmd:="",DownName:="",ProxyUrl:=""
IniRead,DownDir,%A_Temp%\RunAny\ScoopUpdate.ini,config,DownDir,%A_Space%
IniRead,IDMPathIni,%A_Temp%\RunAny\ScoopUpdate.ini,config,IDMPathIni,%A_Space%
IniRead,DownCmd,%A_Temp%\RunAny\ScoopUpdate.ini,config,DownCmd,%A_Space%
IniRead,ProxyUrl,%A_Temp%\RunAny\ScoopUpdate.ini,config,ProxyUrl,%A_Space%
IniRead,AutoRun,%A_Temp%\RunAny\ScoopUpdate.ini,config,AutoRun,%A_Space%
IniRead,AutoMin,%A_Temp%\RunAny\ScoopUpdate.ini,config,AutoMin,%A_Space%

DownDir:=DownDir ? DownDir : scoopPath "\cache"
WinGet, IDMPathRun, ProcessPath, ahk_exe IDMan.exe
IDMPath:=IDMPathRun ? IDMPathRun : Get_Transform_Val(IDMPathIni)
if(!FileExist(IDMPath)){
	IDMPath:="C:\Program Files (x86)\Internet Download Manager\IDMan.exe"
	IDMPath:=FileExist(IDMPath) ? IDMPath : "D:\Program Files (x86)\Internet Download Manager\IDMan.exe"
}
if(!FileExist(IDMPath)){
	IDMPath:=IDMPathIni
}
DownCmd:=DownCmd ? DownCmd : "%IDMPath% /n /d %DownUrl% /f %DownName% /p %DownDir%"
aria2Result:=Trim(cmdClipReturn("scoop config aria2-enabled")," `t`r`n")
proxyResult:=Trim(cmdClipReturn("scoop config proxy")," `t`r`n")
if(ProxyUrl && (!proxyResult || proxyResult="'proxy' is not set")){
	Run, %ComSpec% /c "scoop config proxy %ProxyUrl%", , Min
}else{
	ProxyUrl:=proxyResult
}
checkProxy:=Trim(cmdClipReturn("netstat -ano | findstr " ProxyUrl)," `t`r`n")
global aria2:=aria2Result="False" ? false : true
aria2Enable:=aria2
aria2False:=aria2Enable ? 0 : 1
checkAutoRun:=AutoRun ? 1 : 0
checkAutoMin:=AutoMin ? 1 : 0
optionAutoMin:=AutoMin ? "Minimize" : ""
Gui,Destroy
Gui,+Resize
Gui,Font,,Microsoft YaHei
Gui,Margin,10,10
Gui,Add,Button,xm-5 yp+5 w35 h40 GSetDownDir,下载目录
Gui,Add,Edit,xm+35 yp+10 w650 r1 vDownDir GSetDownDir2,%DownDir%
Gui,Add,Button,xm-5 yp+30 w35 h40 GSetIDMPath,IDM路径
Gui,Add,Edit,xm+35 yp+10 w650 r1 vIDMPath GSetIDMPath2,%IDMPath%
Gui,Add,Button,xm-5 yp+30 w35 h40,下载命令
Gui,Add,Edit,xm+35 yp+10 w650 r1 vDownCmd GSetDownCmd,%DownCmd%
Gui,Add,Button,xm-5 yp+30 w35 h40,代理地址
Gui,Add,Edit,xm+35 yp+10 w650 r1 vProxyUrl GSetProxyUrl,%ProxyUrl%
Gui,Add,Text,x+5 yp+5 vProxyStatus gProxyStatusTips,代理状态：
Gui,Add,Checkbox,Checked%checkAutoRun% xm+35 yp+30 vAutoRun gSetAutoRun,启动后自动开始更新Scoop
Gui,Add,Checkbox,Checked%checkAutoMin% x+10 yp vAutoMin gSetAutoMin,最小化启动
Gui,Add,Radio,x+10 yp Checked%aria2False% varia2False GSetAria2Config, scoop默认下载更新
Gui,Add,Radio,x+10 yp Checked%aria2Enable% varia2Enable GSetAria2Config, aria2下载更新
Gui,Font,Bold
Gui,Add,Button,xm-3 yp+30 w28 h120 GDownStart,开始批量更新
Gui,Add,Button,xm-3 yp+130 w28 h120 GUpdateApp,独立批量更新
Gui,Font,,Consolas
Gui,Add,Edit,xm+35 yp-130 w650 r30 -Wrap HScroll vscoopStatusResult,正在查询scoop更新列表......
Gui,Add,Progress,xm+35 w650 cGreen Hidden vMyProgress
Gui,Add,StatusBar, xm+10 w640 vvStatusBar,
Gui, Show, AutoSize Center %optionAutoMin%, 【Scoop使用IDM下载更新 v%RunAny_Plugins_Version%】https://github.com/hui-Zz
tcping:=Trim(cmdClipReturn("tcping -v | findstr tcping.exe")," `t`r`n")
if(tcping){
	checkProxyTCP:=Trim(cmdSilenceReturn("tcping.exe " StrReplace(ProxyUrl,":"," "))," `t`r`n")
	checkProxy:=InStr(checkProxyTCP,"Port is open") ? true : false
}
checkProxyStr:=checkProxy ? "已连接" : "未连接"
checkProxyColor:=checkProxy ? "green" : "red"
Gui, Font, c%checkProxyColor%, Microsoft YaHei
GuiControl, Font, ProxyStatus
GuiControl, ,ProxyStatus, 代理状态：%checkProxyStr%
;代理可用先更新scoop
if(checkProxy){
	cmdSilenceReturn("scoop update")
}
;获取更新程序列表
scoopStatusResult:=cmdSilenceReturn("scoop status")
scoopStatusResultNew:=""
;[读取scoop更新信息]
if(InStr(scoopStatusResult,"Version")){
	Loop, parse, scoopStatusResult, `n, `r
	{
		Z_LoopField=%A_LoopField%
		if(A_Index<=4)
			scoopStatusResultNew.=A_LoopField . "`n"
 		if(!InStr(Z_LoopField,"Held package") && RegExMatch(Z_LoopField,"^[^\s]+\s+\d+[\w\.-]+\s+\d+[\w\.-]+\s*")){
			appName:=RegExReplace(Z_LoopField,"S)^([^\s]+)\s+\d+[\w\.-]+\s+\d+[\w\.-]+\s*","$1")
			scoopUpdateAppList[appName]:=false
			scoopStatusResultNew.=A_LoopField . "`n"
		}
	}
}
GuiControl,, scoopStatusResult, %scoopStatusResultNew%
if(AutoRun){
	Gosub, DownStart
}
return

;[配置界面]
SetDownDir:
	FileSelectFolder, saveFolder, , 3
	if(saveFolder!=""){
		GuiControl,, DownDir, %saveFolder%
		Gosub, SetDownDir2
	}
return
SetDownDir2:
	Gui,Submit,NoHide
	IniWrite,%DownDir%,%A_Temp%\RunAny\ScoopUpdate.ini,config,DownDir
return
SetIDMPath:
	FileSelectFile, fileSelPath, , , IDMan.exe路径, (*.exe)
	if(fileSelPath!=""){
		GuiControl,, IDMPath, %fileSelPath%
		Gosub, SetIDMPath2
	}
return
SetIDMPath2:
	Gui,Submit,NoHide
	IniWrite,%IDMPath%,%A_Temp%\RunAny\ScoopUpdate.ini,config,IDMPath
return
SetDownCmd:
	Gui,Submit,NoHide
	IniWrite,%DownCmd%,%A_Temp%\RunAny\ScoopUpdate.ini,config,DownCmd
return
SetAutoRun:
	Gui,Submit,NoHide
	IniWrite,%AutoRun%,%A_Temp%\RunAny\ScoopUpdate.ini,config,AutoRun
return
SetAutoMin:
	Gui,Submit,NoHide
	IniWrite,%AutoMin%,%A_Temp%\RunAny\ScoopUpdate.ini,config,AutoMin
return
SetProxyUrl:
	Gui,Submit, NoHide
	IniWrite,%ProxyUrl%,%A_Temp%\RunAny\ScoopUpdate.ini,config,ProxyUrl
	if(RegExMatch(ProxyUrl,"^(?:https?:\/\/)?[\w-]+(?:\.[\w-]+)+:\d{1,5}\/?$")){
		Run, %ComSpec% /c "scoop config proxy %ProxyUrl%", , Min
	} else if(ProxyUrl=""){
		Run, %ComSpec% /c "scoop config rm proxy", , Min
	}
return
SetAria2Config:
	Gui,Submit, NoHide
	if(aria2Enable){
		Run, %ComSpec% /c "scoop config rm aria2-enabled", , Min
	}else if(aria2False){
		Run, %ComSpec% /c "scoop config aria2-enabled false", , Min
	}
return
ProxyStatusTips:
	ToolTip,检测远程代理是否通畅需要安装tcping
	SetTimer,RemoveToolTip,8000
return

;[开始批量下载更新]
DownStart:
	Gui,Submit,NoHide
	SB_SetText("总更新应用：" scoopUpdateAppList.Count())
	if(RegExMatch(ProxyUrl,"^(?:https?:\/\/)?[\w-]+(?:\.[\w-]+)+:\d{1,5}\/?$") && !checkProxy){
		Run, %ComSpec% /c "scoop config rm proxy", , Min
	}
	for name,v in scoopUpdateAppList
	{
		Run, %ComSpec% /c "scoop update %name% -s", , Min
		getScoopAppDownUrl%A_Index%:=Func("getScoopAppDownUrl").Bind(A_Index, name)	;规则定时器
		SetTimer,% getScoopAppDownUrl%A_Index%, 500
	}
	WaitAppCount:=scoopUpdateAppList.Count()
	;~ 每次增加进度 := 向上取整(100%进度条/文件数)
	progressNum := Ceil(100 / scoopUpdateAppList.Count())
	GuiControl, Show, MyProgress
	GuiControl,, MyProgress, 
	Loop {
		success:=true
		for name,v in scoopUpdateAppList
		{
			if(!v)
				success:=v
			if(!scoopUpdateAppList[name] && scoopAppDownOutList[name] && FileExist(DownDir "\" scoopAppDownOutList[name])){
				scoopUpdateAppList[name]:=true
				Run, %ComSpec% /c "scoop update %name% -s", , Min
				GuiControl,, MyProgress, +%progressNum%
				WaitAppCount--
				SB_SetText("总下载更新应用数：" scoopUpdateAppList.Count() " | 剩余未下载安装数：" WaitAppCount "  (正在运行的应用和外网应用会下载更新失败)")
				Sleep,2000
			}
			Sleep,2000
		}
	} Until % success || A_Index > 1000
	if(RegExMatch(ProxyUrl,"^(?:https?:\/\/)?[\w-]+(?:\.[\w-]+)+:\d{1,5}\/?$")){
		Run, %ComSpec% /c "scoop config proxy %ProxyUrl%", , Min
	}
	TrayTip,,scoop批量更新完成~,3,17
return
UpdateApp:
	if(RegExMatch(ProxyUrl,"^(?:https?:\/\/)?[\w-]+(?:\.[\w-]+)+:\d{1,5}\/?$") && !checkProxy){
		Run, %ComSpec% /c "scoop config rm proxy", , Min
	}
	for name,v in scoopUpdateAppList
	{
		Run,%ComSpec% /c "scoop update %name% -s", , ;Min
	}
	if(RegExMatch(ProxyUrl,"^(?:https?:\/\/)?[\w-]+(?:\.[\w-]+)+:\d{1,5}\/?$")){
		Run, %ComSpec% /c "scoop config proxy %ProxyUrl%", , Min
	}
return
GuiSize:
	if A_EventInfo = 1
		return
	GuiControl, Move, DownDir, % " W" . (A_GuiWidth - 50)
	GuiControl, Move, IDMPath, % " W" . (A_GuiWidth - 50)
	GuiControl, Move, DownCmd, % " W" . (A_GuiWidth - 50)
	GuiControl, Move, ProxyUrl, % " W" . (A_GuiWidth * 0.58)
	GuiControl, Move, ProxyStatus, % " W" . (A_GuiWidth * 0.40) . " X" . (A_GuiWidth * 0.70)
	GuiControl, Move, MyProgress, % " W" . (A_GuiWidth - 50) . "Y" . (A_GuiHeight-40)
	GuiControl, Move, scoopStatusResult, % "H" . (A_GuiHeight-240) . " W" . (A_GuiWidth - 50)
return
GuiClose:
GuiEscape:
	ExitApp
return

getScoopAppDownUrl(num, appName){
	global
	if(FileExist(DownDir "\" appName ".txt")){
		FileRead, var, %DownDir%\%appName%.txt
		if(var!=""){
			SetTimer,% getScoopAppDownUrl%num%, Off
			Loop, parse, var, `n, `r
			{
				if(A_LoopField="")
					continue
				Z_LoopField=%A_LoopField%
				if(A_Index=1){
					scoopAppDownUrlList.Push(varList[2])
					DownUrl:=Z_LoopField
				}
				varList:=StrSplit(Z_LoopField,"=",,2)
				if(varList[1]="out"){
					scoopAppDownOutList[appName]:=varList[2]
					DownName:=varList[2]
				}
			}
			if(!FileExist(DownDir "\" DownName)){
				Run,% Get_Transform_Val(DownCmd)
			}
		}
	}
}
/*
【隐藏运行cmd命令并将结果存入剪贴板后取回 @hui-Zz】
*/
cmdClipReturn(command,save=0){
	cmdInfo:=""
	try{
		if(save)
			Clip_Saved:=ClipboardAll
		Clipboard=
		Run,% ComSpec " /C " command " | CLIP", , Hide
		ClipWait,2
		cmdInfo:=Clipboard
		if(save)
			Clipboard:=Clip_Saved
	}catch{}
	return cmdInfo
}
cmdSilenceReturn(command){
	CMDReturn:=""
	cmdFN:="ScoopStatusCMD"
	try{
		RunWait,% ComSpec " /C " command " > ""%Temp%\" cmdFN ".log""",, Hide
		FileRead, CMDReturn, %A_Temp%\%cmdFN%.log
		FileDelete,%A_Temp%\%cmdFN%.log
	}catch{}
	return CMDReturn
}
;[获取变量展开转换后的值]
Get_Transform_Val(string){
	try{
		spo := 1
		out := ""
		while (fpo:=RegexMatch(string, "(%(.*?)%)|``(.)", m, spo))
		{
			out .= SubStr(string, spo, fpo-spo)
			spo := fpo + StrLen(m)
			if (m1)
				out .= %m2%
			else switch (m3)
			{
				;此处报错请升级Autohotkey到v1.1.31以上版本
				case "a": out .= "`a"
				case "b": out .= "`b"
				case "f": out .= "`f"
				case "n": out .= "`n"
				case "r": out .= "`r"
				case "t": out .= "`t"
				case "v": out .= "`v"
				default: out .= m3
			}
		}
		return out SubStr(string, spo)
	}catch{
		return string
	}
}
RemoveToolTip:
	if(A_TimeIdle<2500){
		SetTimer,RemoveToolTip,Off
		ToolTip
	}
return