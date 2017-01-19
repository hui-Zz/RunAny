/*
╔═════════════════════════════════
║【RunAny】一劳永逸的快速启动工具 v2.0
║ by Zz 建议：hui0.0713@gmail.com
║ @2017.1.19 github.com/hui-Zz/RunAny
║ 讨论QQ群：3222783、271105729、493194474
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
;~ StartTick:=A_TickCount	;若要评估出menu时间
RunAny:="RunAny"
Gosub,Run_Exist
MenuTray()
global mTime:=0
global MenuObj:=Object()
SetTimer,Count_Time,300
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
menuRoot:=Object()
menuRoot.Insert(RunAny)
menuLevel:=1
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
gosub,TVMenu
gosub,Run_Done
if(ini){
	TrayTip,,RunAny菜单初始化完成,3,1
	gosub,Menu_About
	gosub,Menu_Show
}
ini=true
;~ TrayTip,,% A_TickCount-StartTick "毫秒",3,17
return
;══════════════════════════════════════════════════════════════════
;~;[生成菜单]
Menu_Add(menuName,menuItem){
	try {
		item:=MenuObj[(menuItem)]
		itemLen:=StrLen(item)
		Menu,%menuName%,add,%menuItem%,Menu_Run
		if(Ext_Check(item,itemLen,".ahk")){
			Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,74
		}else if(Ext_Check(item,itemLen,".bat") || Ext_Check(item,itemLen,".cmd")){
			Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,72
		}else if(InStr(item,"/")){
			Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,44
		}else if(InStr(item,"\")=itemLen){
			Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,4
		}else{
			Menu,%menuName%,Icon,%menuItem%,%item%
		}
	} catch e {
		Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,124
	}
}
Ext_Check(name,len,ext){
	len_ext:=StrLen(ext)
	site:=InStr(name,ext,,0,1)
	return site!=0 && site=len-len_ext+1
}
Run_Exist:
	iniFile:=A_ScriptDir "\" fileNotExt ".ini"
	IfNotExist,%iniFile%
		gosub,First_Run
	global everyDLL:=A_Is64bitOS ? "Everything64.dll" : "Everything32.dll"
	IfNotExist,%A_ScriptDir%\%everyDLL%
		MsgBox,16,,没有找到%A_ScriptDir%\%everyDLL%，将不能识别菜单中程序的路径`n请复制%everyDLL%到目录下`n或在github.com/hui-Zz/RunAny/RunMenu下载不使用Everything的版本
	global iconDll:="SHELL32.dll"
	global iconAny:=190
	global iconMenu:=195
	IfExist,%A_ScriptDir%\ZzIcon.dll
	{
		iconDll:="ZzIcon.dll"
		iconAny:=1
		iconMenu:=2
	}
	return
Count_Time:
	mTime:=mTime=0 ? 1 : 0
	Menu,Tray,Icon,%iconDll%,% mTime=0 ? iconAny : iconMenu
	return
Run_Done:
	SetTimer,Count_Time,Off
	Menu,Tray,Icon,%iconDll%,%iconAny%
	return
;~;[显示菜单]
Menu_Show:
	try{
		Menu,% menuRoot[1],Show
	}catch{
		gosub,Menu_Edit
		MsgBox,16,,菜单显示错误，请检查菜单配置
	}
	return
;~;[菜单运行]
Menu_Run:
	any:=MenuObj[(A_ThisMenuItem)]
	try {
		If GetKeyState("Ctrl"){			;[按住Ctrl是打开应用目录]
			Run,% "explorer.exe /select," any
		}else If GetKeyState("Shift"){	;[按住Shift则是管理员身份运行]
			Run,*RunAs %any%
		}else{
			Run,%any%
		}
	} catch e {
		MsgBox,16,,运行路径不正确：%any%
	}
	return
;══════════════════════════════════════════════════════════════════
;~;[菜单配置]
Menu_Edit:
	global TVFlag:=false
	Gui, Destroy
	Gui, +Resize
	Gui, Font,, Microsoft YaHei
	ImageListID := IL_Create(5)
	Loop 5
		IL_Add(ImageListID, "shell32.dll", A_Index)
	IL_Add(ImageListID, "shell32.dll", 42)
	IL_Add(ImageListID, "shell32.dll", 44)
	Gui, Add, TreeView,vRunAnyTV w400 r30 -Readonly hwndHTV gTVClick ImageList%ImageListID%
	GuiControl, -Redraw, RunAnyTV
	treeRoot:=Object()
	Loop, read, %iniFile%
	{
		Z_ReadLine=%A_LoopReadLine%
		if(InStr(Z_ReadLine,"-")=1){
			;~;[生成目录树层级结构]
			treeLevel:=StrLen(RegExReplace(Z_ReadLine,"S)(^-+).+","$1"))
			if(RegExMatch(Z_ReadLine,"S)^-+[^-]+.*")){
				if(treeLevel=1){
					treeRoot.Insert(treeLevel,TV_Add(Z_ReadLine,,"Icon6"))
				}else{
					treeRoot.Insert(treeLevel,TV_Add(Z_ReadLine,treeRoot[treeLevel-1],"Icon6"))
				}
			}else if(Z_ReadLine="-"){
				treeLevel:=0
				TV_Add(Z_ReadLine,,"Icon1")
			}else{
				TV_Add(Z_ReadLine,treeRoot[treeLevel])
			}
		}else{
			TV_Add(Z_ReadLine,treeRoot[treeLevel],Set_Icon(Z_ReadLine))
		}
	}
	GuiControl, +Redraw, RunAnyTV
	Gui, Show, , %RunAny%菜单树管理(右键操作)
return

#If WinActive(RunAny "菜单树管理(右键操作)")
	F5::
	PGDN::
		gosub,TVDown
		return
	F6::
	PGUP::
		gosub,TVUp
		return
	F3::gosub,TVAdd
	F7::gosub,TVDownNext
	Del::gosub,TVDel
	^s::gosub,TVSave
	Esc::gosub,GuiClose
#If
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
	if(TVFlag){
		MsgBox,49,菜单树退出,确定退出而不保存修改吗？
		IfMsgBox Ok
			Gui, Destroy
	}else{
		Gui, Destroy
	}
return
TVMenu:
	Menu, TVMenu, Add, 编辑`tF2, TVEdit
	Menu, TVMenu, Add, 添加`tF3, TVAdd
	Menu, TVMenu, Add, 删除`tDel, TVDel
	Menu, TVMenu, Add
	Menu, TVMenu, Add, 向下`tF5/PgDn, TVDown
	Menu, TVMenu, Add, 向上`tF6/PgUp, TVUp
	Menu, TVMenu, Add, 同级向下`tF7, TVDownNext
	Menu, TVMenu, Add
	Menu, TVMenu, Add, 保存`tCtrl+S, TVSave
return
TVClick:
	if (A_GuiEvent == "e"){
		TV_GetText(selVar, A_EventInfo)
		TV_Modify(A_EventInfo, Set_Icon(selVar))
		TVFlag:=true
	}
return

TVAdd:
	selID:=TV_GetSelection()
	addID:=TV_Add("",TV_GetParent(selID),selID)
	SendMessage, 0x110E, 0, addID, , ahk_id %HTV%
return
TVEdit:
	If (A_ThisMenuItemPos = 1)
		SendMessage, 0x110E, 0, ClickedID, , ahk_id %HTV%
return
TVDown:
	TV_Move(true)
return
TVDownNext:
	TV_Move(true,false)
return
TVUp:
	TV_Move(false)
return
TVDel:
	TV_GetText(selVar, TV_GetSelection())
	if(RegExMatch(selVar,"S)^-+[^-]+.*"))
		MsgBox,52,请确认,确定删除选中的【%selVar%】以及它下面的所有子项目？(注意)
	else
		MsgBox,52,请确认,确定删除选中的【%selVar%】？
	IfMsgBox Yes
	{
		TV_Delete(TV_GetSelection())
		TVFlag:=true
	}
return
TVSave:
	if(TVFlag){
		MsgBox,33,菜单树保存,需要保存修改吗？
		IfMsgBox Ok
		{
			ItemID = 0
			tabText:=""
			saveText:=""
			Loop
			{
				ItemID := TV_GetNext(ItemID, "Full")
				if not ItemID
					break
				TV_GetText(ItemText, ItemID)
				;~;根据保存菜单树生成菜单ini文件
				treeLevel:=StrLen(RegExReplace(ItemText,"S)(^-+).+","$1"))
				if(RegExMatch(ItemText,"S)^-+[^-]+.*")){
					saveText.=Set_Tab(treeLevel-1) . ItemText . "`n"
					tabText:=Set_Tab(treeLevel)
				}else if(ItemText="-"){
					tabText:=""
					saveText.=tabText . ItemText . "`n"
				}else if(RegExMatch(ItemText,"S)^-+")){
					tabText:=Set_Tab(treeLevel)
					saveText.=tabText . ItemText . "`n"
				}else{
					saveText.=tabText . ItemText . "`n"
				}
			}
			FileDelete,%iniFile%
			FileAppend,%saveText%,%iniFile%
			Reload
		}
	}else{
		Gui,Destroy
	}
return
;~;[上下移动项目]
TV_Move(moveMode = true,moveFull = true){
	selID:=TV_GetSelection()
	if moveMode
		moveID:=moveFull ? TV_GetNext(selID, "Full") : TV_GetNext(selID)
	else
		moveID:=TV_GetPrev(selID)
	moveID:=moveID=0 ? TV_GetParent(selID) : moveID
	if(moveID!=0){
		TV_GetText(moveVar, moveID)
		TV_GetText(selVar, selID)
		TV_Modify(selID, , moveVar)
		TV_Modify(moveID, , selVar)
		TV_Modify(selID, "-select -focus")
		TV_Modify(moveID, "select vis")
		TV_Modify(selID, Set_Icon(moveVar))
		TV_Modify(moveID, Set_Icon(selVar))
		TVFlag:=true
	}
	return
}
;~;[后缀判断图标]
Set_Icon(itemVar){
	itemLen:=StrLen(itemVar)
	if(RegExMatch(itemVar,"S)^-+[^-]+.*"))
		return "Icon6"
	else if(Ext_Check(itemVar,itemLen,".exe"))
		return "Icon3"
	else if(InStr(itemVar,";")=1 || itemVar="")
		return "Icon2"
	else if(InStr(itemVar,"\")=itemLen)
		return "Icon4"
	else if(InStr(itemVar,"/"))
		return "Icon7"
	else
		return "Icon1"
}
;~;[制表符设置]
Set_Tab(tabNum){
	tabText:=""
	Loop,%tabNum%
	{
		tabText.=A_Tab
	}
	return tabText
}
;══════════════════════════════════════════════════════════════════
;~;[设置选项]
Menu_Set:
	Gui,66:Destroy
	Gui,66:Font,,Microsoft YaHei
	Gui,66:Margin,30,40
	Gui,66:Add,GroupBox,xm-10 y+20 w350 h55,自定义显示热键
	Gui,66:Add,Hotkey,xm yp+20 w100 vvZzkey,%menuKey%
	Gui,66:Add,GroupBox,xm-10 y+20 w350 h80,Everything安装路径
	Gui,66:Add,Button,xm yp+20 w50 GSetPath,选择
	Gui,66:Add,Edit,xm+60 yp w250 vvZzpath,%evPath%
	Gui,66:Add,Button,Default xm y+30 w75 GSetOK,确定(&Y)
	Gui,66:Add,Button,x+5 w75 GSetCancel,取消(&C)
	Gui,66:Add,Button,x+5 w75 GSetReSet,重置
	Gui,66:Show,,%RunAny%设置
	return
Menu_About:
	Gui,99:Destroy
	Gui,99:Margin,20,20
	Gui,99:Font,Bold,Microsoft YaHei
	Gui,99:Add,Text,y+10, 【%RunAny%】一劳永逸的快速启动工具 v2.0
	Gui,99:Font
	Gui,99:Add,Text,y+10, 默认启动菜单热键为``(Esc键下方的重音符键)
	Gui,99:Add,Text,y+10
	Gui,99:Font,,Consolas
	Gui,99:Add,Text,y+10, by Zz @2017.1.19 建议：hui0.0713@gmail.com
	Gui,99:Font,CBlue Underline
	Gui,99:Add,Text,y+10 Ggithub, GitHub：https://github.com/hui-Zz/RunAny
	Gui,99:Font
	Gui,99:Add,Text,y+10, 讨论QQ群：3222783、271105729、493194474
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
	Gui,Destroy
return
github:
	Run,https://github.com/hui-Zz/RunAny
return
;══════════════════════════════════════════════════════════════════
;~;[托盘菜单]
MenuTray(){
	Menu,Tray,NoStandard
	Menu,Tray,Icon,%iconDll%,%iconAny%
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
FileAppend,
(
;以【;】开头代表注释
cmd.exe
;根目录分隔符【-】
-
;在【|】前加上TC的简称显示
TC|Totalcmd64.exe
StrokesPlus.exe
Everything.exe
;以【-】开头+名称代表是目录
-app
	计算器|calc.exe
	;2级分隔符【--】
	--
	--img
		画图|mspaint.exe
		;3级分隔符【---】
		---
		截图|SnippingTool.exe
		---media
			wmplayer.exe
	--edit
		notepad.exe
		写字板|wordpad.exe
-
;此时【-】使下面项目都回归根目录
C:\
;以【\】结尾代表是文件夹路径
D:\
-
;带【/】代表是网址路径
更新地址GitHub|https://github.com/hui-Zz/RunAny
-
;使用【&】指定IE的快捷键为E,忽略上面Everything的快捷键E
IE(&E)|C:\Program Files\Internet Explorer\iexplore.exe
控制面板|Control.exe
),%iniFile%
return
