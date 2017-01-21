/*
╔═════════════════════════════════
║【RunAny】一劳永逸的快速启动工具 v2.1短语beta
║ by Zz 建议：hui0.0713@gmail.com
║ @2017.1.21 github.com/hui-Zz/RunAny
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
Gosub,Var_Set
Gosub,Run_Exist
MenuTray()
global MenuObj:=Object()
;══════════════════════════════════════════════════════════════════
;~;[初始化菜单显示热键]
RegRead, MenuKey, HKEY_CURRENT_USER, SOFTWARE\RunAny, MenuKey
;>>默认为重音符`
if(!MenuKey)
	MenuKey:="``"
;~;[设定自定义菜单热键]
try{
	Hotkey,%MenuKey%,Menu_Show,On
}catch{
	gosub,Menu_Set
	MsgBox,16,,%MenuKey%<=热键设置不正确`n请设置正确热键
	gosub,Run_Done
}
;══════════════════════════════════════════════════════════════════
;~;[初始化everything安装路径]
evExist:=true
RegRead, EvPath, HKEY_CURRENT_USER, SOFTWARE\RunAny, EvPath
while !WinExist("ahk_exe Everything.exe")
{
	Sleep,100
	if(A_Index>=30){
		if(EvPath && RegExMatch(EvPath,"iS)^(\\\\|.:\\).*?\.exe$")){
			Run,%EvPath% -startup
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
	if(!EvPath){
		;>>发现Everything已运行则取到路径
		WinGet, EvPath, ProcessPath, ahk_exe Everything.exe
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
			Menu,% menuRoot[menuLevel],Icon,%menuItem%,% TreeIconS[1],% TreeIconS[2]
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
TVMenu("TVMenu")
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
			Menu,%menuName%,Icon,%menuItem%,% AHKIconS[1],% AHKIconS[2]
		}else if(Ext_Check(item,itemLen,".bat") || Ext_Check(item,itemLen,".cmd")){
			Menu,%menuName%,Icon,%menuItem%,% BATIconS[1],% BATIconS[2]
		}else if(InStr(item,"/")){
			Menu,%menuName%,Icon,%menuItem%,% UrlIconS[1],% UrlIconS[2]
		}else if(InStr(item,"\")=itemLen){
			Menu,%menuName%,Icon,%menuItem%,% FolderIconS[1],% FolderIconS[2]
		}else{
			Menu,%menuName%,Icon,%menuItem%,%item%
		}
	} catch e {
		Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,124
	}
}
;~;[输出短语]
Send_Zz(strZz){
	Candy_Saved:=ClipboardAll
	Clipboard:=strZz
	SendInput,^v
	Sleep,200
	Clipboard:=Candy_Saved
}
;~;[检查后缀名]
Ext_Check(name,len,ext){
	len_ext:=StrLen(ext)
	site:=InStr(name,ext,,0,1)
	return site!=0 && site=len-len_ext+1
}
;~;[读取注册表]
Var_Read(rValue,defVar=""){
	RegRead, regVar, HKEY_CURRENT_USER, SOFTWARE\RunAny, %rValue%
	if regVar
		return regVar
	else
		return defVar
}
Var_Set:
	global everyDLL:="Everything.dll"
	global iconAny:="shell32.dll,190"
	global iconMenu:="shell32.dll,195"
	if(Ext_Check(A_ScriptName,StrLen(A_ScriptName),".exe")){
		iconAny:=A_ScriptName ",1"
		iconMenu:=A_ScriptName ",2"
	}else if(FileExist(A_ScriptDir "\ZzIcon.dll")){
		iconAny:="ZzIcon.dll,1"
		iconMenu:="ZzIcon.dll,2"
	}
	global AnyIcon:=Var_Read("AnyIcon",iconAny)
	global AnyIconS:=StrSplit(AnyIcon,",")
	global MenuIcon:=Var_Read("MenuIcon",iconMenu)
	global MenuIconS:=StrSplit(MenuIcon,",")
	global TreeIcon:=Var_Read("TreeIcon")
	global TreeIconS:=StrSplit(TreeIcon,",")
	global FolderIcon:=Var_Read("FolderIcon","shell32.dll,4")
	global FolderIconS:=StrSplit(FolderIcon,",")
	global UrlIcon:=Var_Read("UrlIcon","shell32.dll,44")
	global UrlIconS:=StrSplit(UrlIcon,",")
	global BATIcon:=Var_Read("BATIcon","shell32.dll,72")
	global BATIconS:=StrSplit(BATIcon,",")
	global AHKIcon:=Var_Read("AHKIcon","shell32.dll,74")
	global AHKIconS:=StrSplit(AHKIcon,",")
	global EXEIcon:=Var_Read("EXEIcon","shell32.dll,3")
	global EXEIconS:=StrSplit(EXEIcon,",")
return
Run_Exist:
	iniFile:=A_ScriptDir "\" fileNotExt ".ini"
	IfNotExist,%iniFile%
		gosub,First_Run
	if(FileExist(A_ScriptDir "\Everything.dll")){
		everyDLL:=DllCall("LoadLibrary", str, "Everything.dll") ? "Everything.dll" : "Everything64.dll"
	}else if(FileExist(A_ScriptDir "\Everything64.dll")){
		everyDLL:=DllCall("LoadLibrary", str, "Everything64.dll") ? "Everything64.dll" : "Everything.dll"
	}
	IfNotExist,%A_ScriptDir%\%everyDLL%
		MsgBox,16,,没有找到%everyDLL%，将不能识别菜单中程序的路径`n请复制%everyDLL%到%A_ScriptDir%目录下`n`n或在github.com/hui-Zz/RunAny/tree/RunMenu下载不使用Everything的版本

	return
Run_Done:
	Menu,Tray,Icon,% AnyIconS[1],% AnyIconS[2]
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
	try {
		any:=MenuObj[(A_ThisMenuItem)]
		anyLen:=StrLen(any)
		If(InStr(any,";")=anyLen){
			StringLeft, any, any, anyLen-1
			Send_Zz(any)	;[输出短语]
		}else If GetKeyState("Ctrl"){		;[按住Ctrl是打开应用目录]
			Run,% "explorer.exe /select," any
		}else If GetKeyState("Shift"){	;[按住Shift则是管理员身份运行]
			Run,*RunAs %any%
		}else{
			Run,%any%
		}
	} catch e {
		MsgBox,16,找不到程序路径,运行路径不正确：%any%
	}
	return
;══════════════════════════════════════════════════════════════════
;~;[菜单配置]
Menu_Edit:
	global TVFlag:=false
	Gui, Destroy
	Gui, +Resize
	Gui, Font,, Microsoft YaHei
	ImageListID := IL_Create(6)
	IL_Add(ImageListID, "shell32.dll", 1)
	IL_Add(ImageListID, "shell32.dll", 2)
	IL_Add(ImageListID, EXEIconS[1], EXEIconS[2])
	IL_Add(ImageListID, FolderIconS[1], FolderIconS[2])
	IL_Add(ImageListID, UrlIconS[1], UrlIconS[2])
	if(TreeIcon)
		IL_Add(ImageListID, TreeIconS[1], TreeIconS[2])
	else
		IL_Add(ImageListID, "shell32.dll", 42)
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
	TVMenu("GuiMenu")
	Gui, Menu, GuiMenu
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
	F8::gosub,TVImportFile
	F9::gosub,TVImportFolder
	Del::gosub,TVDel
	^s::gosub,TVSave
	Esc::gosub,GuiClose
#If
GuiContextMenu:
	If (A_GuiControl = "RunAnyTV") {
		TV_Modify(A_EventInfo, "Select")
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
TVMenu(addMenu){
	flag:=addMenu="GuiMenu" ? true : false
	Menu, %addMenu%, Add,% flag ? "保存" : "保存`tCtrl+S", TVSave
	Menu, %addMenu%, Icon,% flag ? "保存" : "保存`tCtrl+S", SHELL32.dll,194
	Menu, %addMenu%, Add
	Menu, %addMenu%, Add,% flag ? "编辑" : "编辑`tF2", TVEdit
	Menu, %addMenu%, Icon,% flag ? "编辑" : "编辑`tF2", SHELL32.dll,134
	Menu, %addMenu%, Add,% flag ? "添加" : "添加`tF3", TVAdd
	Menu, %addMenu%, Icon,% flag ? "添加" : "添加`tF3", SHELL32.dll,1
	Menu, %addMenu%, Add,% flag ? "删除" : "删除`tDel", TVDel
	Menu, %addMenu%, Icon,% flag ? "删除" : "删除`tDel", SHELL32.dll,132
	Menu, %addMenu%, Add
	Menu, %addMenu%, Add,% flag ? "向下↓" : "向下↓`t(F5/PgDn)", TVDown
	Menu, %addMenu%, Add,% flag ? "向上↑" : "向上↑`t(F6/PgUp)", TVUp
	Menu, %addMenu%, Add,% flag ? "同级向下↘" : "同级向下↘`tF7", TVDownNext
	Menu, %addMenu%, Add
	Menu, %addMenu%, Add,% flag ? "多选导入" : "多选导入`tF8", TVImportFile
	Menu, %addMenu%, Icon,% flag ? "多选导入" : "多选导入`tF8", SHELL32.dll,55
	Menu, %addMenu%, Add,% flag ? "批量导入" : "批量导入`tF9", TVImportFolder
	Menu, %addMenu%, Icon,% flag ? "批量导入" : "批量导入`tF9", SHELL32.dll,46
}
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
	ClickedID:=TV_GetSelection()
	TV_Modify(ClickedID, "Select")
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
TVImportFile:
	FileSelectFile, exeName, M35, , 选择多项要导入的EXE(快捷方式), (*.exe;*.lnk)
	Loop,parse,exeName,`n
	{
		if(A_Index=1){
			lnkPath:=A_LoopField
		}else{
			I_LoopField:=A_LoopField
			if Ext_Check(I_LoopField,StrLen(I_LoopField),".lnk"){
				FileGetShortcut,%lnkPath%\%I_LoopField%,exePath
				SplitPath,exePath,I_LoopField
			}
			selID:=TV_GetSelection()
			addID:=TV_Add(I_LoopField,TV_GetParent(selID),selID)
		}
	}
return
TVImportFolder:
	FileSelectFolder, folderName, , 0
	if(folderName){
		MsgBox,33,导入文件夹所有EXE,确定导入%folderName%及子文件夹下所有EXE吗？
		IfMsgBox Ok
		{
			Loop,%folderName%\*.exe,0,1
			{
				selID:=TV_GetSelection()
				addID:=TV_Add(A_LoopFileName,TV_GetParent(selID),selID)
			}
		}
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
	if(Ext_Check(itemVar,itemLen,".exe"))
		return "Icon3"
	else if(InStr(itemVar,";")=1 || itemVar="")
		return "Icon2"
	else if(InStr(itemVar,"\")=itemLen)
		return "Icon4"
	else if(InStr(itemVar,"/"))
		return "Icon5"
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
	Gui,66:Add,Hotkey,xm yp+20 w100 vvMenuKey,%MenuKey%
	Gui,66:Add,GroupBox,xm-10 y+20 w350 h80,Everything安装路径
	Gui,66:Add,Button,xm yp+20 w50 GSetPath,选择
	Gui,66:Add,Edit,xm+60 yp w260 vvEvPath,%EvPath%
	Gui,66:Add,GroupBox,xm-10 y+20 w350 h225,图标自定义设置（文件路径,序号）
	Gui,66:Add,Text,xm yp+23 w80,树目录图标：
	Gui,66:Add,Edit,xm+80 yp w240 vvTreeIcon,%TreeIcon%
	Gui,66:Add,Text,xm yp+23 w80,文件夹图标：
	Gui,66:Add,Edit,xm+80 yp w240 vvFolderIcon,%FolderIcon%
	Gui,66:Add,Text,xm yp+23 w80,网址图标：
	Gui,66:Add,Edit,xm+80 yp w240 vvUrlIcon,%UrlIcon%
	Gui,66:Add,Text,xm yp+23 w80,批处理图标：
	Gui,66:Add,Edit,xm+80 yp w240 vvBATIcon,%BATIcon%
	Gui,66:Add,Text,xm yp+23 w80,AHK图标：
	Gui,66:Add,Edit,xm+80 yp w240 vvAHKIcon,%AHKIcon%
	Gui,66:Add,Text,xm yp+23 w80,EXE图标：
	Gui,66:Add,Edit,xm+80 yp w240 vvEXEIcon,%EXEIcon%
	Gui,66:Add,Text,xm yp+23 w80,准备图标：
	Gui,66:Add,Edit,xm+80 yp w240 vvMenuIcon,%MenuIcon%
	Gui,66:Add,Text,xm yp+23 w80,托盘图标：
	Gui,66:Add,Edit,xm+80 yp w240 vvAnyIcon,%AnyIcon%
	Gui,66:Add,Button,Default xm y+30 w75 GSetOK,确定(&Y)
	Gui,66:Add,Button,x+5 w75 GSetCancel,取消(&C)
	Gui,66:Add,Button,x+5 w75 GSetReSet,重置
	Gui,66:Show,,%RunAny%设置
	return
;~;[关于]
Menu_About:
	Gui,99:Destroy
	Gui,99:Margin,20,20
	Gui,99:Font,Bold,Microsoft YaHei
	Gui,99:Add,Text,y+10, 【%RunAny%】一劳永逸的快速启动工具 v2.1短语beta
	Gui,99:Font
	Gui,99:Add,Text,y+10, 默认启动菜单热键为``(Esc键下方的重音符键)
	Gui,99:Add,Text,y+10
	Gui,99:Font,,Consolas
	Gui,99:Add,Text,y+10, by Zz @2017.1.21 建议：hui0.0713@gmail.com
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
	Reg_Set(vMenuKey,MenuKey,"MenuKey")
	Reg_Set(vEvPath,EvPath,"EvPath")
	Reg_Set(vTreeIcon,TreeIcon,"TreeIcon")
	Reg_Set(vFolderIcon,FolderIcon,"FolderIcon")
	Reg_Set(vUrlIcon,UrlIcon,"UrlIcon")
	Reg_Set(vBATIcon,BATIcon,"BATIcon")
	Reg_Set(vAHKIcon,AHKIcon,"AHKIcon")
	Reg_Set(vEXEIcon,EXEIcon,"EXEIcon")
	Reg_Set(vAnyIcon,AnyIcon,"AnyIcon")
	Reg_Set(vMenuIcon,MenuIcon,"MenuIcon")
	Reload
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
Reg_Set(vGui, var, sz){
	if(vGui!=var){
		%sz%=%vGui%
		RegWrite, REG_SZ, HKEY_CURRENT_USER, SOFTWARE\RunAny, %sz%, %vGui%
	}
}
;══════════════════════════════════════════════════════════════════
;~;[托盘菜单]
MenuTray(){
	Menu,Tray,NoStandard
	Menu,Tray,Icon,% MenuIconS[1],% MenuIconS[2]
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
	str := "file:*.exe !C:\*Windows*"
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
	--edit
		notepad.exe
		;3级分隔符【---】
		---
		写字板|wordpad.exe
	--img
		画图|mspaint.exe
		---media
			wmplayer.exe
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
