/*
╔═════════════════════════════════
║【RunAny】一劳永逸的快速启动工具 v2.0
║ 联系：hui0.0713@gmail.com
║ 讨论QQ群：3222783、271105729、493194474
║ by Zz @2017.1.17
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
RunAny:="RunAny"
Gosub,Run_Exist
global mTime:=0
global MenuObj:=Object()
SetTimer,CountTime,300
menuRoot:=Object()
menuRoot.Insert(RunAny)
menuLevel:=1
;══════════════════════════════════════════════════════════════════
;~;[初始化菜单显示热键]
RegRead, menuKey, HKEY_CURRENT_USER, SOFTWARE\RunAny, key
;>>默认为重音符`
if(!menuKey)
	menuKey:="``"
;~;[设定自定义菜单热键]
try{
	Hotkey,%menuKey%,Menu_Show,On
}catch{
	gosub,Menu_Set
	MsgBox,16,,%menuKey%<=热键设置不正确`n请设置正确热键
	gosub,Run_Done
}
;══════════════════════════════════════════════════════════════════
;~;[初始化everything安装路径]
evExist:=true
RegRead, evPath, HKEY_CURRENT_USER, SOFTWARE\RunAny, everythingPath
while !WinExist("ahk_exe Everything.exe")
{
	Sleep,100
	if(A_Index>=30){
		if(evPath && RegExMatch(evPath,"iS)^(\\\\|.:\\).*?\.exe$")){
			Run,%evPath% -startup
			Sleep,1000
			break
		}else{
			gosub,Menu_Set
			MsgBox,16,,请设置正确的Everything安装路径，才能正确读取程序菜单!
			evExist:=false
			break
		}
	}
}
;~;[使用everything读取整个系统所有exe]
If(evExist){
	everythingQuery()
	if(!evPath){
		;>>发现Everything已运行则取到路径
		WinGet, evPath, ProcessPath, ahk_exe Everything.exe
	}
}
;══════════════════════════════════════════════════════════════════
;~;[读取自定义树形菜单设置]
StartTick:=A_TickCount	;若要评估出menu时间
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
	}else if(InStr(Z_ReadLine,";")=1 || Z_ReadLine=""){
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
	TrayTip,,RunAny菜单初始化完成,3,1
	Run,%iniFile%
}
gosub,Run_Done
ini=true
TrayTip,,% A_TickCount-StartTick "毫秒",3,17
return
;══════════════════════════════════════════════════════════════════
;~;[生成菜单]
Menu_Add(menuName,menuItem){
	try {
		item:=MenuObj[(menuItem)]
		Menu,%menuName%,add,%menuItem%,Menu_Run
		if(RegExMatch(item,"iS)\.ahk$")){
			Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,74
		}else if(RegExMatch(item,"iS)\.(bat|cmd)$")){
			Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,72
		}else if(RegExMatch(item,"iS)\b(([\w-]+://?|www[.])[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|/)))")){
			Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,44
		}else if(RegExMatch(item,"iS)^\""?.:\\.*(\\|"")$")){
			Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,42
		}else{
			Menu,%menuName%,Icon,%menuItem%,% item
		}
	} catch e {
		Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,124
	}
}

Run_Exist:
	iniFile:=A_ScriptDir "\" fileNotExt ".ini"
	IfNotExist,%iniFile%
		gosub,First_Run
	global everyDLL:=A_Is64bitOS ? "Everything64.dll" : "Everything32.dll"
	IfNotExist,%A_ScriptDir%\%everyDLL%
		MsgBox,没有找到%A_ScriptDir%\%everyDLL%，将不能识别菜单中程序的路径
	return
CountTime:
	mTime:=mTime=0 ? 1 : 0
	Menu,Tray,Icon,% mTime=0 ? "RunMenuZz.ico" : "RunMenu.ico"
	return
Run_Done:
	SetTimer,CountTime,Off
	Menu,Tray,Icon,RunMenuZz.ico
	return
;~;[显示菜单]
Menu_Show:
	try{
		Menu,% menuRoot[1],Show
	}catch{
		gosub,Menu_Edit
		MsgBox,菜单显示错误，请检查菜单配置
	}
	return
;~;[菜单运行]
Menu_Run:
	If GetKeyState("Ctrl")		;[按住Ctrl则是打开应用目录]
	{
		Run,% "explorer.exe /select," MenuObj[(A_ThisMenuItem)]
		return
	}
	try {
		Run,% MenuObj[(A_ThisMenuItem)]
	} catch e {
		MsgBox,% "运行路径不正确：" MenuObj[(A_ThisMenuItem)]
	}
	return
;══════════════════════════════════════════════════════════════════
;~;[菜单配置]
Menu_Edit:
	Gui, Destroy
	Gui, +Resize
	Gui, Font,, Microsoft YaHei
	ImageListID := IL_Create(5)
	Loop 5
		IL_Add(ImageListID, "shell32.dll", A_Index)
	Gui, Add, TreeView,vRunAnyTV w390 r30 -Readonly hwndHTV gTVClick ImageList%ImageListID%
	GuiControl, -Redraw, RunAnyTV
	treeRoot:=Object()
	Loop, read, %iniFile%
	{
		Z_ReadLine=%A_LoopReadLine%
		if(InStr(Z_ReadLine,"-")=1){
			;~;[生成目录树层级结构]
			treeItem:=RegExReplace(Z_ReadLine,"S)^-+")
			treeLevel:=StrLen(RegExReplace(Z_ReadLine,"S)(^-+).*","$1"))
			if(treeItem){
				if(treeLevel=1){
					treeRoot.Insert(treeLevel,TV_Add(Z_ReadLine,,"Icon4"))
				}else{
					treeRoot.Insert(treeLevel,TV_Add(Z_ReadLine,treeRoot[treeLevel-1],"Icon5"))
				}
			}else{
				treeLevel-=1
				TV_Add(Z_ReadLine,treeRoot[treeLevel])
			}
		}else if(InStr(Z_ReadLine,";")=1 || Z_ReadLine=""){
			continue
		}else{
			TV_Add(Z_ReadLine,treeRoot[treeLevel],"Icon3")
		}
	}
	GuiControl, +Redraw, RunAnyTV
	Menu, TVMenu, Add, 编辑`tF2, TVMenuLabel
	Menu, TVMenu, Add, 删除`tDel, TVMenuLabel
	Menu, TVMenu, Add, 向下`tF5, TVMenuLabel
	Menu, TVMenu, Add, 向上`tF6, TVMenuLabel
	Hotkey,F5,TVDown,On
	Hotkey,PGDN,TVDown,On
	Hotkey,F6,TVUp,On
	Hotkey,PGUP,TVUp,On
	Hotkey,Delete,TVDel,On
	Gui, Show, , 菜单树管理
return

GuiContextMenu:
If (A_GuiControl = "RunAnyTV") {
	ClickedID := A_EventInfo
	TV_Modify(ClickedID, "Select")
	Menu, TVMenu, Show
}
return
GuiSize:
	if A_EventInfo = 1
		return
	GuiControl, Move, RunAnyTV, % "H" . (A_GuiHeight-10) . " W" . (A_GuiWidth - 20)
return
GuiClose:
	Hotkey,F5,TVDown,Off
	Hotkey,PGDN,TVDown,Off
	Hotkey,F6,TVUp,Off
	Hotkey,PGUP,TVUp,Off
	Hotkey,Delete,TVDel,Off
	Gui, Destroy
return
TVClick:
	;~ if (A_GuiEvent == "e")
		;~ ToolTip,编辑完
return
TVMenuLabel:
	if (A_ThisMenuItem = "编辑`tF2")
		gosub,TVEdit
	else if(A_ThisMenuItem = "删除`tDel")
		gosub,TVDel
	else if(A_ThisMenuItem = "向下`tF5")
		TVMove(true)
	else if(A_ThisMenuItem = "向上`tF6")
		TVMove(false)
return
TVEdit:
	If (A_ThisMenuItemPos = 1)
		SendMessage, 0x110E, 0, ClickedID, , ahk_id %HTV%
Return
TVDown:
   TVMove(true)
return
TVUp:
   TVMove(false)
return
TVDel:
	TV_Delete(TV_GetSelection())
return
;[上下移动项目]
TVMove(moveMode = true){
	selID:=TV_GetSelection()
	moveID:=moveMode ? TV_GetNext(selID, "Full") : TV_GetPrev(selID)
	moveID:=moveID=0 ? TV_GetParent(selID) : moveID
	if(moveID!=0){
		TV_GetText(moveVar, moveID)
		TV_GetText(selVar, selID)
		TV_Modify(selID, , moveVar)
		TV_Modify(moveID, , selVar)
		TV_Modify(selID, "-select -focus")
		TV_Modify(moveID, "select vis")
	}
	return
}
;══════════════════════════════════════════════════════════════════
;~;[设置选项]
Menu_Set:
	Gui,Destroy
	Gui,Margin,30,40
	Gui,Add,GroupBox,xm-10 y+20 w350 h55,自定义显示热键
	Gui,Add,Hotkey,xm yp+20 w100 vvZzkey,%menuKey%
	
	Gui,Add,GroupBox,xm-10 y+20 w350 h60,Everything安装路径
	Gui,Add,Button,xm yp+20 w50 GSetPath,选择
	Gui,Add,Edit,xm+60 yp w250 vvZzpath,%evPath%
	
	Gui,Add,Button,xm y+30 w75 GSetOK,确定(&Y)
	Gui,Add,Button,x+5 w75 GSetCancel,取消(&C)
	Gui,Add,Button,x+5 w75 GSetReSet,重置
	GuiControl,+default,确定(&Y)
	Gui,Show,,%RunAny%设置
	return
Menu_About:
	Gui,99:Destroy
	Gui,99:Margin,20,20
	Gui,99:Add,Picture,xm Icon1,%A_ScriptName%
	Gui,99:Font,Bold
	Gui,99:Add,Text,x+10 yp+10,%RunAny% v2 2017
	Gui,99:Font
	Gui,99:Add,Text,y+10, 【RunAny】超轻便自由的快速启动应用工具 v1.9
	Gui,99:Add,Text,y+10, 默认显示菜单热键为``(Esc键下方的重音符键)
	Gui,99:Add,Text,y+10
	Gui,99:Add,Text,y+10, 联系：hui0.0713@gmail.com
	Gui,99:Add,Text,y+10, 讨论QQ群：3222783、271105729、493194474
	Gui,99:Add,Text,y+10, by Zz @2017.1.8 集成Everything版本
	Gui,99:Show,,关于%RunAny%
	hCurs:=DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt") ;IDC_HAND
	OnMessage(0x200,"WM_MOUSEMOVE") 
	return
SetPath:
	FileSelectFile, evFilePath, 3, Everything.exe, Everything安装路径, Everything (*.exe)
	GuiControl,, vZzpath, %evFilePath%
return
SetOK:
	Gui,Submit
	if(vZzkey!=menuKey){
		menuKey:=vZzkey
		RegWrite, REG_SZ, HKEY_CURRENT_USER, SOFTWARE\RunAny, key, %vZzkey%
		Reload
	}
	if(vZzpath!=evPath){
		evPath:=vZzpath
		RegWrite, REG_SZ, HKEY_CURRENT_USER, SOFTWARE\RunAny, everythingPath, %vZzpath%
	}
return
SetCancel:
	Gui,Destroy
return
SetReSet:
	RegDelete, HKEY_CURRENT_USER, SOFTWARE\RunAny
	Gui,Hide
return
;══════════════════════════════════════════════════════════════════
;~;[托盘菜单]
MenuTray(){
	Menu,Tray,NoStandard
	Menu,Tray,Icon,RunMenu.ico
	Menu,Tray,add,启动(&Z),Menu_Show
	Menu,Tray,add,菜单(&E),Menu_Edit
	Menu,Tray,add,设置(&D),Menu_Set
	Menu,Tray,Add,关于(&A)...,Menu_About
	Menu,Tray,add
	Menu,Tray,add,重启(&R),Menu_Reload
	Menu,Tray,add,挂起(&S),Menu_Suspend
	Menu,Tray,add,退出(&X),Menu_Exit
	Menu,Tray,Default,启动(&Z)
	Menu,Tray,Click,1
}
Menu_Reload:
	Reload
return
Menu_Suspend:
	Menu,tray,ToggleCheck,挂起(&S)
	Suspend
return
Menu_Exit:
	ExitApp
return
;══════════════════════════════════════════════════════════════════
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
;══════════════════════════════════════════════════════════════════
;~;[初次运行]
First_Run:
	ini:=true
	FileAppend,% "cmd.exe`n-`n-app`n计算器|calc.exe`n--img`n  画图|mspaint.exe`n  ---`n  截图|SnippingTool.exe`n--sys`n  ---media`n     wmplayer.exe`n--佳软`n  StrokesPlus.exe`n  TC|Totalcmd64.exe`n  Everything.exe`n-edit`n  notepad.exe`n  写字板|wordpad.exe`n-`nIE(&E)|C:\Program Files\Internet Explorer\iexplore.exe`n-`n设置|Control.exe`n",%iniFile%
return
