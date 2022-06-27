/*
╔══════════════════════════════════════════════════
║【Scoop使用IDM下载更新】 @2020.09.07 https://github.com/hui-Zz
╚══════════════════════════════════════════════════
*/
#Persistent             ;~让脚本持久运行
#SingleInstance,Force   ;~运行替换旧实例
DetectHiddenWindows,On
#Include *i %A_ScriptDir%\..\..\RunAnyCtrl\Lib\JSON.ahk

global scoopUpdateApp:=[]
scoopStatusResult:=cmdReturn("scoop status")
if(InStr(scoopStatusResult,"Updates are available for")){
	evCommandStr:="!*.lnk D:\* "
	Loop, parse, scoopStatusResult, `n, `r
	{
		Z_LoopField=%A_LoopField%
		if(InStr(Z_LoopField,"->")){
			appName:=RegExReplace(Z_LoopField,"S)(.*): .*","$1")
			scoopUpdateApp.Push(appName)
			evCommandStr.=appName . ".json|"
		}
	}
	StringTrimRight, evCommandStr, evCommandStr, 1
	WinGet, EvPath, ProcessPath, ahk_exe Everything.exe
	Run % EvPath " -search """ evCommandStr """"
}

try EnvGet, scoopPath, scoop
DownPath:=scoopPath "\cache"

WinGet, IDMPath, ProcessPath, ahk_exe IDMan.exe
IDMPath:=IDMPath ? IDMPath : FileExist("C:\Program Files (x86)\Internet Download Manager\IDMan.exe") 
	? "C:\Program Files (x86)\Internet Download Manager\IDMan.exe"
	: "D:\Program Files (x86)\Internet Download Manager\IDMan.exe"

Gui,Destroy
Gui,+Resize
Gui,Font,,Microsoft YaHei
Gui,Margin,10,10
Gui,Add,Button,xm-5 yp+5 w35 h40 GSetDownPath,下载目录
Gui,Add,Edit,xm+35 yp+10 w600 r1 vvDownPath,%DownPath%
Gui,Add,Button,xm-5 yp+30 w35 h40 GSetIDMPath,IDM路径
Gui,Add,Edit,xm+35 yp+10 w600 r1 vvIDMPath,%IDMPath%
Gui,Font,Bold,Microsoft YaHei
Gui,Add,Button,xm-3 yp+35 w28 h120 GDownUrl,开始批量下载！
Gui,Add,Button,xm-3 yp+130 w28 h120 GUpdateApp,分开批量更新
Gui,Add,Edit,xm+35 yp-130 w600 r30 -Wrap HScroll vvUrlPath,%UrlPath%
Gui,Add,Progress,xm+35 w600 cGreen vMyProgress
GuiControl, Hide, MyProgress
Gui, Show, , 【Scoop使用IDM下载更新】https://github.com/hui-Zz
return
GuiSize:
	if A_EventInfo = 1
		return
	GuiControl, Move, vDownPath, % " W" . (A_GuiWidth - 50)
	GuiControl, Move, vMyProgress, % " W" . (A_GuiWidth - 50)
	GuiControl, Move, vUrlPath, % "H" . (A_GuiHeight-70) . " W" . (A_GuiWidth - 50)
return
SetDownPath:
	FileSelectFolder, saveFolder, , 3
	GuiControl,, vDownPath, %saveFolder%
return
SetIDMPath:
	FileSelectFile, fileSelPath, , , IDMan.exe路径, (*.exe)
	GuiControl,, vIDMPath, %fileSelPath%
return
DownUrl:
	Gui,Submit,NoHide
	StringReplace, OutReplace, vUrlPath, `n, `n, UseErrorLevel
	lineNum := ErrorLevel + !(OutReplace = "")
	MsgBox,33,批量下载文件,确定批量下载%lineNum%个文件？
	IfMsgBox Ok
	{
		;~ 每次增加进度 := 向上取整(100%进度条/文件数)
		progressNum := Ceil(100 / lineNum)
		GuiControl, Show, MyProgress
		GuiControl,, MyProgress, 0
		Loop,parse,vUrlPath,`n
		{
			if(A_LoopField){
				SplitPath, A_LoopField, name, dir, ext, name_no_ext, drive
				FileRead, responseStr, %A_LoopField%
				jsonData:=JSON.Load(responseStr)
				version:=jsonData["version"]
				downUrl:=jsonData["url"]
				if(!downUrl){
					downUrl:=jsonData["architecture"]["64bit"]["url"]
				}
				downName:=jsonData["autoupdate"]["url"]
				if(!downName){
					downName:=jsonData["autoupdate"]["architecture"]["64bit"]["url"]
				}
				downName:=StrReplace(downName,"#","")
				downName:=StrReplace(downName,"://","_")
				downName:=StrReplace(downName,"/","_")
				downName:=StrReplace(downName,"$version",version)
				downName:=name_no_ext . "#" . version . "#" . downName
				Run,%vIDMPath% /n /d %downUrl% /f %downName% /p %vDownPath%
				GuiControl,, MyProgress, +%progressNum%
				Sleep,1000
			}
		}
		TrayTip,,url一键批量下载完成,3,17
	}
return
UpdateApp:
for k,v in scoopUpdateApp
{
	Run,%ComSpec% /c "scoop update %v%", , ;Min
}
return
GuiClose:
GuiEscape:
	ExitApp
return
/*
【返回cmd命令的结果值 @hui-Zz】
*/
cmdReturn(command){
    ; WshShell 对象: http://msdn.microsoft.com/en-us/library/aew9yb99
    shell := ComObjCreate("WScript.Shell")
    ; 通过 cmd.exe 执行单条命令
    exec := shell.Exec(ComSpec " /C " command)
    ; 读取并返回命令的输出
    return exec.StdOut.ReadAll()
}