/*
╔═════════════════════════════════
║【RunMenuZz】超轻便自由的快速启动应用工具 v1.8
║ 联系：hui0.0713@gmail.com
║ 讨论QQ群：3222783、271105729、493194474
║ by Zz @2017.1.8 集成Everything版本
╚═════════════════════════════════
*/
#Persistent			;~让脚本持久运行
#NoEnv					;~不检查空变量为环境变量
#SingleInstance,Force	;~运行替换旧实例
DetectHiddenWindows,on	;~显示隐藏窗口
ListLines,Off			;~不显示最近执行的脚本行
CoordMode,Menu			;~相对于整个屏幕
SetBatchLines,-1		;~脚本全速执行
SetWorkingDir,%A_ScriptDir%	;~脚本当前工作目录
SplitPath,A_ScriptFullPath,,,,fileNotExt
MenuTray()
iniFile:=fileNotExt ".ini"
IfNotExist,%iniFile%
	gosub,iniFileWrite
SetTimer,CountTime,300
global everyDLL:=A_Is64bitOS ? "Everything64.dll" : "Everything32.dll"
global mTime:=0
global MenuObj:=Object()
menuRoot:=Object()
menuRoot.Insert("RunMenu")
menuLevel:=1
evExist:=true
while !WinExist("ahk_exe Everything.exe")
{
	Sleep,100
	if(A_Index=30){
		TrayTip,,先运行Everything才能读取程序路径,3,1
		evExist:=false
		break
	}
}
;~;[使用everything读取整个系统所有exe]
If evExist
	everythingQuery()

StartTick:=A_TickCount  ;若要评估出menu时间

;~;[读取自定义树形菜单设置]
Loop, read, %iniFile%
{
	Z_ReadLine=%A_LoopReadLine%
	if(InStr(Z_ReadLine,"-")=1){
		;~;[生成目录树层级结构]
		menuItem:=RegExReplace(Z_ReadLine,"S)^-+")
		menuLevel:=StrLen(RegExReplace(Z_ReadLine,"S)(^-+).*","$1"))
		if(menuItem){
			Menu,%menuItem%,add
			Menu,% menuRoot[menuLevel],add,%menuItem%,:%menuItem%
			menuLevel+=1
			menuRoot[menuLevel]:=menuItem
		}else if(menuRoot[menuLevel]){
			Menu,% menuRoot[menuLevel],Add
		}
	}else if(InStr(Z_ReadLine,";")=1){
		continue
	}else if(InStr(Z_ReadLine,"|")){
		;~;[生成有前缀备注的应用]
		menuDiy:=StrSplit(Z_ReadLine,"|")
		appName:=RegExReplace(menuDiy[2],"iS)\.exe$")
		if(MenuObj[appName]){
			MenuObj[menuDiy[1]]:=MenuObj[appName]
		}else{
			MenuObj[menuDiy[1]]:=menuDiy[2]
		}
		Menu_Add(menuRoot[menuLevel],menuDiy[1])
	}else if(RegExMatch(Z_ReadLine,"iS)^(\\\\|.:\\).*?\.exe$")){
		;~ ;[生成完全路径的应用]
		SplitPath,Z_ReadLine,fileName,,,nameNotExt
		MenuObj[nameNotExt]:=Z_ReadLine
		Menu_Add(menuRoot[menuLevel],nameNotExt)
	}else{
		;[生成已取到的应用]
		appName:=RegExReplace(Z_ReadLine,"iS)\.exe$")
		if(!MenuObj[appName])
			MenuObj[appName]:=Z_ReadLine
		Menu_Add(menuRoot[menuLevel],appName)
	}
}

if(ini){
	TrayTip,,RunMenuZz菜单初始化完成,3,1
	Run,%iniFile%
	gosub,``
}

SetTimer,CountTime,Off
Menu,Tray,Icon,RunMenuZz.ico
ini=true
TrayTip,,% A_TickCount-StartTick "毫秒",3,1

return

;~;[设定自定义显示菜单热键]
`::
	gosub,MenuShow
return

;~;[生成菜单]
Menu_Add(menuName,menuItem){
	try {
		item:=MenuObj[(menuItem)]
		Menu,%menuName%,add,%menuItem%,MenuRun
		if(RegExMatch(item,"iS)\.ahk$")){
			Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,74
		}else if(RegExMatch(item,"iS)\.(bat|cmd)$")){
			Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,73
		}else if(RegExMatch(item,"S)\b(([\w-]+://?|www[.])[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|/)))")){
			Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,44
		}else{
			Menu,%menuName%,Icon,%menuItem%,% item,0
		}
	} catch e {
		Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,124
	}
}
CountTime:
	mTime:=mTime=0 ? 1 : 0
	Menu,Tray,Icon,% mTime=0 ? "RunMenuZz.ico" : "RunMenu.ico"
	return
;~;[显示菜单]
MenuShow:
	try{
		Menu,% menuRoot[1],Show
	}catch{
		MsgBox,菜单显示错误，请检查%iniFile%中[menuName]下面的菜单配置
	}
	return
;~;[菜单运行]
MenuRun:
	If GetKeyState("Ctrl")			    ;[按住Ctrl则是进入配置]
	{
		MsgBox,1
	}
	try {
		Run,% MenuObj[(A_ThisMenuItem)]
	} catch e {
		MsgBox,% "运行路径不正确：" MenuObj[(A_ThisMenuItem)]
	}
	return
Menu_Edit:
	Run,%iniFile%
	return
;~;[托盘菜单]
MenuTray(){
	Menu,Tray,NoStandard
	Menu,Tray,Icon,RunMenuZz.ico
	Menu,Tray,add,菜单(&Z),MenuShow
	Menu,Tray,add,重启(&R),Menu_Reload
	Menu,Tray,add,配置(&E),Menu_Edit
	Menu,Tray,add
	Menu,Tray,add,挂起(&S),Menu_Suspend
	Menu,Tray,add,暂停(&A),Menu_Pause
	Menu,Tray,add,退出(&X),Menu_Exit
	Menu,Tray,Default,菜单(&Z)
	Menu,Tray,Click,1
}
Menu_Reload:
	Reload
return
Menu_Suspend:
	Menu,tray,ToggleCheck,挂起(&S)
	Suspend
return
Menu_Pause:
	Menu,tray,ToggleCheck,暂停(&A)
	Pause
return
Menu_Exit:
	ExitApp
return
;~;[使用everything搜索所有exe程序]
everythingQuery(){
	ev := new everything
	str := "*.exe !C:\Windows"
	;查询字串设为everything
	ev.SetSearch(str)
	;执行搜索
	ev.Query()
	sleep 100
	Loop,% ev.GetTotResults()
	{
		Z_Index:=A_Index-1
		MenuObj[(RegExReplace(ev.GetResultFileName(Z_Index),"iS)\.exe$",""))]:=ev.GetResultFullPathName(Z_Index)
	}
}
class everything
{
    __New(){
        this.hModule := DllCall("LoadLibrary", str, everyDLL)
    }
	__Get(aName){
	}
	__Set(aName, aValue){
	}
	__Delete(){
        DllCall("FreeLibrary", "UInt", this.hModule) 
		return
    }
	SetSearch(aValue)
	{
		this.eSearch := aValue
		dllcall(everyDLL "\Everything_SetSearch",str,aValue)
		return
	}
	Query(aValue=1)
	{
		dllcall(everyDLL "\Everything_Query",int,aValue)
		return
	}
	GetTotResults()
	{
		return dllcall(everyDLL "\Everything_GetTotResults")
	}
	GetResultFileName(aValue)
	{
		return strget(dllcall(everyDLL "\Everything_GetResultFileName",int,aValue))
	}
	GetResultFullPathName(aValue,cValue=128)
	{
		VarSetCapacity(bValue,cValue*2)
		dllcall(everyDLL "\Everything_GetResultFullPathName",int,aValue,str,bValue,int,cValue)
		return bValue
	}
}
;~;[配置生成]
iniFileWrite:
	ini:=true
	FileAppend,% "cmd.exe`n-`n-app`n计算器|calc.exe`n--img`n  画图|mspaint.exe`n  ---`n  截图|SnippingTool.exe`n--sys`n  ---media`n     wmplayer.exe`n--佳软`n  StrokesPlus.exe`n  TC|Totalcmd64.exe`n  Everything.exe`n-edit`n  notepad.exe`n  写字板|wordpad.exe`n-`nIE(&E)|C:\Program Files\Internet Explorer\iexplore.exe`n-`n设置|Control.exe`n",%iniFile%
return
