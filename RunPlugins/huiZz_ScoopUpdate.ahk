/*
╔═══════════════════════════════════════════════════════════════
║【Scoop使用IDM下载更新】 https://github.com/hui-Zz @2022.06.27
║ by hui-Zz 建议：hui0.0713@gmail.com 讨论QQ群：246308937
╚═══════════════════════════════════════════════════════════════
*/
global RunAny_Plugins_Version:="1.2.0"
#Persistent             ;~让脚本持久运行
#SingleInstance,Force   ;~运行替换旧实例
DetectHiddenWindows,On
Menu,Tray,Icon,imageres.dll,196
global scoopUpdateAppList:={}
global scoopAppDownOutList:={}
global scoopAppDownUrlList:=[]
try EnvGet, scoopPath, scoop
global DownDir:=scoopPath "\cache"
global IDMPath:="",DownUrl:="",DownName:=""
WinGet, IDMPath, ProcessPath, ahk_exe IDMan.exe
IDMPath:=IDMPath ? IDMPath : FileExist("C:\Program Files (x86)\Internet Download Manager\IDMan.exe") 
	? "C:\Program Files (x86)\Internet Download Manager\IDMan.exe"
	: "D:\Program Files (x86)\Internet Download Manager\IDMan.exe"
DownCmd:="%IDMPath% /n /d %DownUrl% /f %DownName% /p %DownDir%"
proxyResult:=Trim(cmdClipReturn("scoop config proxy")," `t`r`n")
aria2Result:=Trim(cmdClipReturn("scoop config aria2-enabled")," `t`r`n")
global aria2:=aria2Result="False" ? false : true
aria2Enable:=aria2
aria2False:=aria2Enable ? 0 : 1

Gui,Destroy
Gui,+Resize
Gui,Font,,Microsoft YaHei
Gui,Margin,10,10
Gui,Add,Button,xm-5 yp+5 w35 h40 GSetDownDir,下载目录
Gui,Add,Edit,xm+35 yp+10 w400 r1 vDownDir,%DownDir%
Gui,Add,Button,xm-5 yp+30 w35 h40 GSetIDMPath,IDM路径
Gui,Add,Edit,xm+35 yp+10 w400 r1 vIDMPath,%IDMPath%
Gui,Add,Button,xm-5 yp+30 w35 h40,下载命令
Gui,Add,Edit,xm+35 yp+10 w400 r1 vDownCmd,%DownCmd%
Gui,Add,Button,xm-5 yp+30 w35 h40,代理地址
Gui,Add,Edit,xm+35 yp+10 w400 r1 vProxyUrl GSetProxyUrl,%proxyResult%
Gui,Add,Radio,x+10 yp Checked%aria2False% varia2False GSetAria2Config, scoop默认下载更新
Gui,Add,Radio,x+10 yp Checked%aria2Enable% varia2Enable GSetAria2Config, aria2下载更新
Gui,Font,Bold,Microsoft YaHei
Gui,Add,Button,xm-3 yp+35 w28 h120 GDownStart,开始批量下载
Gui,Add,Button,xm-3 yp+130 w28 h120 GUpdateApp,独立批量更新
Gui,Add,Edit,xm+35 yp-130 w400 r30 -Wrap HScroll vscoopStatusResult,正在查询scoop更新列表......
Gui,Add,Progress,xm+35 w400 cGreen vMyProgress
Gui,Add,StatusBar, xm+10 w390 vvStatusBar,
GuiControl, Hide, MyProgress
Gui, Show, , 【Scoop使用IDM下载更新 v%RunAny_Plugins_Version%】https://github.com/hui-Zz

scoopStatusResult:=cmdSilenceReturn("scoop status")
;[读取scoop更新信息]
if(InStr(scoopStatusResult,"Updates are available for")){
	Loop, parse, scoopStatusResult, `n, `r
	{
		Z_LoopField=%A_LoopField%
		if(InStr(Z_LoopField,"->")){
			appName:=RegExReplace(Z_LoopField,"S)(.*): .*","$1")
			scoopUpdateAppList[appName]:=false
		}
	}
	scoopStatusResult:=StrReplace(scoopStatusResult, "Updates are available for", "以下是待更新的应用")
	scoopStatusResult:=StrReplace(scoopStatusResult, "These apps are outdated and on hold", "这些应用已暂停更新")
	scoopStatusResult:=StrReplace(scoopStatusResult, "These app manifests have been removed", "这些应用的buckets地址已失效，无法获取到更新信息")
}
GuiControl,, scoopStatusResult, %scoopStatusResult%

return
GuiSize:
	if A_EventInfo = 1
		return
	GuiControl, Move, DownDir, % " W" . (A_GuiWidth - 50)
	GuiControl, Move, IDMPath, % " W" . (A_GuiWidth - 50)
	GuiControl, Move, DownCmd, % " W" . (A_GuiWidth - 50)
	GuiControl, Move, ProxyUrl, % " W" . (A_GuiWidth * 0.55)
	GuiControl, Move, aria2False, % " X" . (A_GuiWidth * 0.65)
	GuiControl, Move, aria2Enable, % " X" . (A_GuiWidth * 0.85)
	GuiControl, Move, MyProgress, % "H" . (A_GuiHeight-90) . " W" . (A_GuiWidth - 50)
	GuiControl, Move, scoopStatusResult, % "H" . (A_GuiHeight-220) . " W" . (A_GuiWidth - 50)
return
SetDownDir:
	FileSelectFolder, saveFolder, , 3
	if(saveFolder!="")
		GuiControl,, DownDir, %saveFolder%
return
SetIDMPath:
	FileSelectFile, fileSelPath, , , IDMan.exe路径, (*.exe)
	if(fileSelPath!="")
		GuiControl,, IDMPath, %fileSelPath%
return
SetProxyUrl:
	Sleep, 500
	Gui,Submit, NoHide
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
DownStart:
	Gui,Submit,NoHide
	SB_SetText("总更新APP：" scoopUpdateAppList.Count())
	for name,v in scoopUpdateAppList
	{
		Run, %ComSpec% /c "scoop update %name%", , Min
		getScoopAppDownUrl%A_Index%:=Func("getScoopAppDownUrl").Bind(A_Index, name)	;规则定时器
		SetTimer,% getScoopAppDownUrl%A_Index%, 200
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
			if(!scoopUpdateAppList[name] && FileExist(DownDir "\" scoopAppDownOutList[name])){
				Run, %ComSpec% /c "scoop update %name%", , Min
				scoopUpdateAppList[name]:=true
				GuiControl,, MyProgress, +%progressNum%
				WaitAppCount--
				SB_SetText("总下载更新应用数：" scoopUpdateAppList.Count() " | 剩余未下载安装数：" WaitAppCount "  (正在运行的应用和外网应用会下载更新失败)")
			}
			Sleep,200
		}
	} Until % success
	TrayTip,,scoop批量更新完成~,3,17
return
UpdateApp:
for name,v in scoopUpdateAppList
{
	Run,%ComSpec% /c "scoop update %name%", , ;Min
}
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
			Run,% Get_Transform_Val(DownCmd)
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