/*
╔═════════════════════════════════
║【RunAny】一劳永逸的快速启动工具 v2.2
║ by Zz 建议：hui0.0713@gmail.com
║ @2017.1.22 github.com/hui-Zz/RunAny
║ 讨论QQ群：[246308937]、3222783、493194474
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
RunAnyZz:="RunAny"
Gosub,Var_Set
MenuTray()
Gosub,Run_Exist
global MenuObj:=Object()
;══════════════════════════════════════════════════════════════════
;~;[初始化菜单显示热键]
MenuKey:=Var_Read("MenuKey","``")
MenuWinKey:=Var_Read("MenuWinKey",0)
EvKey:=Var_Read("EvKey")
EvWinKey:=Var_Read("EvWinKey",0)
;~;[设定自定义菜单热键]
try{
	MenuHotKey:=MenuWinKey ? "#" . MenuKey : MenuKey
	Hotkey, IfWinNotActive, ahk_group DisableGUI
	Hotkey,%MenuHotKey%,Menu_Show,On
	if(EvKey){
		try{
			EvHotKey:=EvWinKey ? "#" . EvKey : EvKey
			Hotkey,%EvHotKey%,Ev_Show,On
		}catch{
			gosub,Menu_Set
			MsgBox,16,请设置正确热键,%EvHotKey%`n一键Everything热键设置不正确
		}
	}
}catch{
	gosub,Menu_Set
	MsgBox,16,请设置正确热键,%MenuHotKey%`n自定义显示热键设置不正确
}
;══════════════════════════════════════════════════════════════════
;~;[初始化everything安装路径]
evExist:=true
RegRead, EvPath, HKEY_CURRENT_USER, SOFTWARE\RunAny, EvPath
while !WinExist("ahk_exe Everything.exe")
{
	Sleep,100
	if(A_Index>=20){
		if(EvPath && RegExMatch(EvPath,"iS)^(\\\\|.:\\).*?\.exe$")){
			Run,%EvPath% -startup
			Sleep,1000
			break
		}else{
			gosub,Menu_Set
			MsgBox,16,,RunAny需要Everything快速识别程序的路径`n请设置正确安装路径或下载Everything：http://www.voidtools.com/
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
Gosub,Icon_Set
menuRoot:=Object()
menuRoot.Insert(RunAnyZz)
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
		appName:=RegExReplace(menuDiy[2],"iS)\.(exe|lnk)$")
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
		appName:=RegExReplace(Z_ReadLine,"iS)\.(exe|lnk)$")
		if(!MenuObj[appName])
			MenuObj[appName]:=Z_ReadLine
		Menu_Add(menuRoot[menuLevel],appName)
	}
}
Menu,% menuRoot[1],Add
TVMenu("TVMenu")
Menu,Tray,Icon,% AnyIconS[1],% AnyIconS[2]
if(ini){
	TrayTip,,RunAny菜单初始化完成`n右击任务栏图标设置,3,1
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
		if(Ext_Check(item,itemLen,".lnk")){
			try{
				FileGetShortcut, %item%, OutItem, , , , OutIcon, OutIconNum
				if(OutIcon)
					Menu,%menuName%,Icon,%menuItem%,%OutIcon%,%OutIconNum%
				else
					Menu,%menuName%,Icon,%menuItem%,%OutItem%
			} catch e {
				Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,264
			}
		}else if(Ext_Check(item,itemLen,".ahk")){
			Menu,%menuName%,Icon,%menuItem%,% AHKIconS[1],% AHKIconS[2]
		}else if(Ext_Check(item,itemLen,".bat") || Ext_Check(item,itemLen,".cmd")){
			Menu,%menuName%,Icon,%menuItem%,% BATIconS[1],% BATIconS[2]
		}else if(RegExMatch(item,"([\w-]+://?|www[.]).*")){
			Menu,%menuName%,Icon,%menuItem%,% UrlIconS[1],% UrlIconS[2]
		}else if(InStr(item,"\",,0,1)=itemLen){
			Menu,%menuName%,Icon,%menuItem%,% FolderIconS[1],% FolderIconS[2]
		}else if(InStr(item,";",,0,1)=itemLen){
			Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,2
		}else{
			Menu,%menuName%,Icon,%menuItem%,%item%
		}
	} catch e {
		if(HideFail)
			Menu,%menuName%,Delete,%menuItem%
		else
			Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,124
	}
}
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
		If(InStr(any,";",,0,1)=anyLen){
			StringLeft, any, any, anyLen-1
			Send_Zz(any)	;[输出短语]
		}else If(TcPath && (InStr(any,"\",,0,1)=anyLen || GetKeyState("Ctrl"))){
			Run,%TcPath% "%any%"
		}else If GetKeyState("Ctrl"){		;[按住Ctrl是打开应用目录]
			Run,% "explorer.exe /select," any
		}else If GetKeyState("Shift"){	;[按住Shift则是管理员身份运行]
			Run,*RunAs %any%
		}else{
			Run,%any%
		}
		if(!RegExMatch(A_ThisMenuItem,"^&1|2"))
			gosub,Menu_Common
	} catch e {
		MsgBox,16,找不到程序路径,运行路径不正确：%any%
	}
	return
;~;[菜单最近运行]
Menu_Common:
	try {
		if(!MenuCommonList[1]){
			MenuCommon1:=MenuCommonList[1]
			MenuCommonList[1]:="&1 " A_ThisMenuItem
			MenuObj[MenuCommonList[1]]:=any
			Menu,% menuRoot[1],Add,% MenuCommonList[1],Menu_Run
		}else if(!MenuCommonList[2]){
			MenuCommonList[2]:="&2 " A_ThisMenuItem
			MenuObj[MenuCommonList[2]]:=any
			Menu,% menuRoot[1],Add,% MenuCommonList[2],Menu_Run
		}else{
			MenuCommon1:=MenuCommonList[1]
			MenuCommon2:=MenuCommonList[2]
			MenuCommonList[1]:="&1 " A_ThisMenuItem
			MenuCommonList[2]:=RegExReplace(MenuCommon1,"&1","&2")
			MenuObj[MenuCommonList[1]]:=any
			MenuObj[MenuCommonList[2]]:=MenuObj[(MenuCommon1)]
			Menu,% menuRoot[1],Rename,% MenuCommon1,% MenuCommonList[1]
			Menu,% menuRoot[1],Rename,% MenuCommon2,% MenuCommonList[2]
		}
	} catch e {
		MsgBox,16,最近运行,记录最近运行程序错误%A_ThisMenuItem%
	}
return
;~;[一键Everything][搜索选中文字][激活][隐藏]
Ev_Show:
	selectZz:=Get_Zz()
	if(RegExMatch(selectZz,"^(\\\\|.:\\).*?$")){
		SplitPath,selectZz,fileName
		selectZz:=fileName
	}
	IfWinExist ahk_class EVERYTHING
		if selectZz
			Run % evPath " -search """ selectZz """"
		else
			IfWinNotActive
				WinActivate
			else
				WinMinimize
	else
		Run % evPath (selectZz ? " -search """ selectZz """" : "")
	return
;══════════════════════════════════════════════════════════════════
;~;[初始化]
Var_Set:
	RegRead, AutoRun, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, RunAny
	AutoRun:=AutoRun ? 1 : 0
	global HideFail:=Var_Read("HideFail",0)
	TcPath:=Var_Read("TcPath")
	DisableApp:=Var_Read("DisableApp","vmware-vmx.exe,TeamViewer.exe")
	Loop,parse,DisableApp,`,
	{
		GroupAdd,DisableGUI,ahk_exe %A_LoopField%
	}
	iconAny:="shell32.dll,190"
	iconMenu:="shell32.dll,195"
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
	global MenuCommonList:={}
return
;~;[后缀图标初始化]
Icon_Set:
	TreeIcon:=Var_Read("TreeIcon")
	global TreeIconS:=StrSplit(TreeIcon,",")
	FolderIcon:=Var_Read("FolderIcon","shell32.dll,4")
	global FolderIconS:=StrSplit(FolderIcon,",")
	UrlIcon:=Var_Read("UrlIcon","shell32.dll,44")
	global UrlIconS:=StrSplit(UrlIcon,",")
	BATIcon:=Var_Read("BATIcon","shell32.dll,72")
	global BATIconS:=StrSplit(BATIcon,",")
	AHKIcon:=Var_Read("AHKIcon","shell32.dll,74")
	global AHKIconS:=StrSplit(AHKIcon,",")
	EXEIcon:=Var_Read("EXEIcon","shell32.dll,3")
	global EXEIconS:=StrSplit(EXEIcon,",")
return
;~;[调用判断]
Run_Exist:
	iniFile:=A_ScriptDir "\" fileNotExt ".ini"
	IfNotExist,%iniFile%
		gosub,First_Run
	global everyDLL:="Everything.dll"
	if(FileExist(A_ScriptDir "\Everything.dll")){
		everyDLL:=DllCall("LoadLibrary", str, "Everything.dll") ? "Everything.dll" : "Everything64.dll"
	}else if(FileExist(A_ScriptDir "\Everything64.dll")){
		everyDLL:=DllCall("LoadLibrary", str, "Everything64.dll") ? "Everything64.dll" : "Everything.dll"
	}
	IfNotExist,%A_ScriptDir%\%everyDLL%
		MsgBox,16,,没有找到%everyDLL%，将不能识别菜单中程序的路径`n请复制%everyDLL%到%A_ScriptDir%目录下`n`n或在github.com/hui-Zz/RunAny/tree/RunMenu下载不使用Everything的版本
return
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
;~;[输出短语]
Send_Zz(strZz){
	Candy_Saved:=ClipboardAll
	Clipboard:=strZz
	SendInput,^v
	Sleep,200
	Clipboard:=Candy_Saved
}
;~;[获取选中]
Get_Zz(){
	Candy_Saved:=ClipboardAll
	Clipboard=
	SendInput,^c
	ClipWait,0.2
	If(ErrorLevel){
		Clipboard:=Candy_Saved
		return
	}
	CandySel=%Clipboard%
	Clipboard:=Candy_Saved
	return CandySel
}
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
	IL_Add(ImageListID, "shell32.dll", 264)
	IL_Add(ImageListID, UrlIconS[1], UrlIconS[2])
	if(TreeIcon)
		IL_Add(ImageListID, TreeIconS[1], TreeIconS[2])
	else
		IL_Add(ImageListID, "shell32.dll", 42)
	Gui, Add, TreeView,vRunAnyTV w400 r30 -Readonly AltSubmit hwndHTV gTVClick ImageList%ImageListID%
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
					treeRoot.Insert(treeLevel,TV_Add(Z_ReadLine,,"Bold Icon7"))
				}else{
					treeRoot.Insert(treeLevel,TV_Add(Z_ReadLine,treeRoot[treeLevel-1],"Bold Icon7"))
				}
			}else if(Z_ReadLine="-"){
				treeLevel:=0
				TV_Add(Z_ReadLine,,"Bold Icon1")
			}else{
				TV_Add(Z_ReadLine,treeRoot[treeLevel],"Bold")
			}
		}else{
			TV_Add(Z_ReadLine,treeRoot[treeLevel],Set_Icon(Z_ReadLine))
		}
	}
	GuiControl, +Redraw, RunAnyTV
	TVMenu("GuiMenu")
	Gui, Menu, GuiMenu
	Gui, Show, , %RunAnyZz%菜单树管理(右键操作)
return

#If WinActive(RunAnyZz "菜单树管理(右键操作)")
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
	^s::gosub,TVSave
	Esc::gosub,GuiClose
#If
GuiContextMenu:
	If (A_GuiControl = "RunAnyTV") {
		TV_Modify(A_EventInfo, "Select Vis")
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
	Menu, %addMenu%, Add,% flag ? "添加" : "添加`tF3", TVAdd
	Menu, %addMenu%, Icon,% flag ? "添加" : "添加`tF3", SHELL32.dll,1
	Menu, %addMenu%, Add,% flag ? "编辑" : "编辑`tF2", TVEdit
	Menu, %addMenu%, Icon,% flag ? "编辑" : "编辑`tF2", SHELL32.dll,134
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
		;~;完成编辑时
		TV_GetText(selVar, A_EventInfo)
		TV_Modify(A_EventInfo, Set_Icon(selVar))
		if(addID && RegExMatch(selVar,"S)^-+[^-]+.*")){
			insertID:=TV_Add("",A_EventInfo)
			TV_Modify(A_EventInfo, "Bold Expand")
			TV_Modify(insertID, "Select Vis")
			SendMessage, 0x110E, 0, TV_GetSelection(), , ahk_id %HTV%
			addID:=
		}
		TVFlag:=true
	}else if (A_GuiEvent == "K"){
		if (A_EventInfo = 46)
			gosub,TVDel
	}
return
TVAdd:
	selID:=TV_GetSelection()
	addID:=TV_Add("",TV_GetParent(selID),selID)
	TV_Modify(addID, "Select Vis")
	SendMessage, 0x110E, 0, addID, , ahk_id %HTV%
return
TVEdit:
	ClickedID:=TV_GetSelection()
	TV_Modify(ClickedID, "Select Vis")
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
	selID:=TV_GetSelection()
	parentID:=TV_GetParent(selID)
	FileSelectFile, exeName, M35, , 选择多项要导入的EXE(快捷方式), (*.exe;*.lnk)
	Loop,parse,exeName,`n
	{
		if(A_Index=1){
			lnkPath:=A_LoopField
		}else{
			I_LoopField:=A_LoopField
			if Ext_Check(I_LoopField,StrLen(I_LoopField),".lnk"){
				FileGetShortcut,%lnkPath%\%I_LoopField%,exePath
				if Ext_Check(exePath,StrLen(exePath),".exe")
					SplitPath,exePath,I_LoopField
			}
			fileID:=TV_Add(I_LoopField,parentID,selID)
			TVFlag:=true
		}
	}
return
TVImportFolder:
	FileSelectFolder, folderName, , 0
	if(folderName){
		MsgBox,33,导入文件夹所有exe和lnk,确定导入%folderName%及子文件夹下所有程序和快捷方式吗？
		IfMsgBox Ok
		{
			selID:=TV_GetSelection()
			parentID:=TV_GetParent(selID)
			Loop,%folderName%\*.lnk,0,1
			{
				lnkID:=TV_Add(A_LoopFileName,parentID,selID)
			}
			Loop,%folderName%\*.exe,0,1
			{
				folderID:=TV_Add(A_LoopFileName,parentID,selID)
			}
			TVFlag:=true
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
		TV_Modify(selID, "-Select -focus")
		TV_Modify(moveID, "Select Vis")
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
		return "Icon7"
	else if(Ext_Check(itemVar,itemLen,".exe"))
		return "Icon3"
	else if(Ext_Check(itemVar,itemLen,".lnk"))
		return "Icon5"
	else if(InStr(itemVar,";")=1 || itemVar="")
		return "Icon2"
	else if(InStr(itemVar,"\",,0,1)=itemLen)
		return "Icon4"
	else if(RegExMatch(itemVar,"([\w-]+://?|www[.]).*"))
		return "Icon6"
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
	Gui,66:Add,Tab,x10 y10 w360 h335,RunAny设置|Everything设置|图标设置
	Gui,66:Tab,RunAny设置,,Exact
	Gui,66:Add,GroupBox,xm-10 y+10 w200 h70,RunAny
	Gui,66:Add,Checkbox,Checked%AutoRun% xm yp+25 vvAutoRun,开机自动启动
	Gui,66:Add,Checkbox,Checked%HideFail% xm yp+20 vvHideFail,隐藏失效项
	Gui,66:Add,GroupBox,xm-10 y+20 w215 h55,自定义显示热键
	Gui,66:Add,Hotkey,xm+10 yp+20 w140 vvMenuKey,%MenuKey%
	Gui,66:Add,Checkbox,Checked%MenuWinKey% xm+155 yp+3 vvMenuWinKey,Win
	Gui,66:Add,GroupBox,xm-10 y+20 w330 h85,屏蔽RunAny程序列表（逗号分隔）
	Gui,66:Add,Edit,xm+10 yp+20 w300 r3 vvDisableApp,%DisableApp%
	Gui,66:Add,GroupBox,xm-10 y+20 w340 h55,TotalCommander安装路径（TC打开文件夹）
	Gui,66:Add,Button,xm yp+20 w50 GSetTcPath,选择
	Gui,66:Add,Edit,xm+60 yp w260 r1 vvTcPath,%TcPath%
	
	Gui,66:Tab,Everything设置,,Exact
	Gui,66:Add,GroupBox,xm-10 y+20 w215 h55,一键Everything[搜索选中文字][激活][隐藏]
	Gui,66:Add,Hotkey,xm+10 yp+20 w140 vvEvKey,%EvKey%
	Gui,66:Add,Checkbox,Checked%EvWinKey% xm+155 yp+3 vvEvWinKey,Win
	Gui,66:Add,GroupBox,xm-10 y+20 w340 h130,Everything安装路径
	Gui,66:Add,Button,xm yp+30 w50 GSetEvPath,选择
	Gui,66:Add,Edit,xm+60 yp w260 r4 vvEvPath,%EvPath%
	
	Gui,66:Tab,图标设置,,Exact
	Gui,66:Add,GroupBox,xm-10 y+10 w340 h280,图标自定义设置（文件路径,序号）
	Gui,66:Add,Text,xm yp+30 w80,树目录图标
	Gui,66:Add,Edit,xm+70 yp w250 r1 vvTreeIcon,%TreeIcon%
	Gui,66:Add,Text,xm yp+30 w80,文件夹图标
	Gui,66:Add,Edit,xm+70 yp w250 r1 vvFolderIcon,%FolderIcon%
	Gui,66:Add,Text,xm yp+30 w80,网址图标
	Gui,66:Add,Edit,xm+70 yp w250 r1 vvUrlIcon,%UrlIcon%
	Gui,66:Add,Text,xm yp+30 w80,批处理图标
	Gui,66:Add,Edit,xm+70 yp w250 r1 vvBATIcon,%BATIcon%
	Gui,66:Add,Text,xm yp+30 w80,AHK图标
	Gui,66:Add,Edit,xm+70 yp w250 r1 vvAHKIcon,%AHKIcon%
	Gui,66:Add,Text,xm yp+30 w80,EXE图标
	Gui,66:Add,Edit,xm+70 yp w250 r1 vvEXEIcon,%EXEIcon%
	Gui,66:Add,Text,xm yp+30 w80,准备图标
	Gui,66:Add,Edit,xm+70 yp w250 r1 vvMenuIcon,%MenuIcon%
	Gui,66:Add,Text,xm yp+30 w80,托盘图标
	Gui,66:Add,Edit,xm+70 yp w250 r1 vvAnyIcon,%AnyIcon%
	
	Gui,66:Tab
	Gui,66:Add,Button,Default xm y+45 w75 GSetOK,确定(&Y)
	Gui,66:Add,Button,x+5 w75 GSetCancel,取消(&C)
	Gui,66:Add,Button,x+5 w75 GSetReSet,重置
	Gui,66:Show,,%RunAnyZz%设置
	return
;~;[关于]
Menu_About:
	Gui,99:Destroy
	Gui,99:Margin,20,20
	Gui,99:Font,Bold,Microsoft YaHei
	Gui,99:Add,Text,y+10, 【%RunAnyZz%】一劳永逸的快速启动工具 v2.2
	Gui,99:Font
	Gui,99:Add,Text,y+10, 默认启动菜单热键为``(Esc键下方的重音符键)
	Gui,99:Add,Text,y+10, 右键任务栏RunAny图标自定义菜单、热键、图标等配置
	Gui,99:Add,Text,y+10
	Gui,99:Font,,Consolas
	Gui,99:Add,Text,y+10, by Zz @2017.1.22 建议：hui0.0713@gmail.com
	Gui,99:Font,CBlue Underline
	Gui,99:Add,Text,y+10 Ggithub, GitHub：https://github.com/hui-Zz/RunAny
	Gui,99:Add,Text,y+10 GQQRunAny, 讨论QQ群：[246308937]、3222783、493194474
	Gui,99:Font
	Gui,99:Show,,关于%RunAnyZz%
	hCurs:=DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt") ;IDC_HAND
	OnMessage(0x200,"WM_MOUSEMOVE") 
	return
SetEvPath:
	FileSelectFile, evFilePath, 3, Everything.exe, Everything安装路径, (Everything.exe)
	GuiControl,, vEvPath, %evFilePath%
return
SetTcPath:
	FileSelectFile, tcFilePath, 3, , TC安装路径, (Totalcmd.exe;Totalcmd64.exe)
	GuiControl,, vTcPath, %tcFilePath%
return
SetOK:
	Gui,Submit
	if(vAutoRun!=AutoRun){
		AutoRun:=vAutoRun
		if(AutoRun){
			RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, RunAny, %A_ScriptFullPath%
		}else{
			RegDelete, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, RunAny
		}
	}
	Reg_Set(vDisableApp,DisableApp,"DisableApp")
	Reg_Set(vHideFail,HideFail,"HideFail")
	Reg_Set(vMenuKey,MenuKey,"MenuKey")
	Reg_Set(vMenuWinKey,MenuWinKey,"MenuWinKey")
	Reg_Set(vEvKey,EvKey,"EvKey")
	Reg_Set(vEvWinKey,EvWinKey,"EvWinKey")
	Reg_Set(vEvPath,EvPath,"EvPath")
	Reg_Set(vTcPath,TcPath,"TcPath")
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
QQRunAny:
	Run,https://jq.qq.com/?_wv=1027&k=445Ug7u
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
	Menu,Tray,add,启动菜单(&Z),Menu_Show
	Menu,Tray,add,菜单配置(&E),Menu_Edit
	Menu,Tray,add,配置文件(&F),Menu_Ini
	Menu,Tray,add,设置(&D),Menu_Set
	Menu,Tray,Add,关于(&A)...,Menu_About
	Menu,Tray,add
	Menu,Tray,add,重启(&R),Menu_Reload
	Menu,Tray,add,挂起(&S),Menu_Suspend
	Menu,Tray,add,退出(&X),Menu_Exit
	Menu,Tray,Default,启动菜单(&Z)
	Menu,Tray,Click,1
}
Menu_Ini:
	Run,%iniFile%
return
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
	str := "file:*.exe|*.lnk !C:\*Windows*"
	;查询字串设为everything
	ev.SetSearch(str)
	;执行搜索
	ev.Query()
	sleep 100
	Loop,% ev.GetTotResults()
	{
		Z_Index:=A_Index-1
		MenuObj[(RegExReplace(ev.GetResultFileName(Z_Index),"iS)\.(exe|lnk)$",""))]:=ev.GetResultFullPathName(Z_Index)
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
FileAppend,
(
;以【;】开头代表注释
;以【-】开头+名称表示1级目录
-App常用
	;以【--】开头+名称表示2级目录树
	--佳软
		;在【|】前加上TC的简称显示
		TC|Totalcmd.exe
		StrokesPlus.exe
		Everything.exe
		Ditto.exe
	--
	chrome.exe
	;多个同名iexplore.exe用全路径指定运行32位IE
	I&E|C:\Program Files (x86)\Internet Explorer\iexplore.exe
	;2级分隔符【--】
	--
	Wiz.exe
-Edit编辑
	记事本(&N)|notepad.exe
	--
	winword.exe
	excel.exe
	powerpnt.exe
-im&G图片
	画图(&T)|mspaint.exe
	ACDSee.exe
	XnView.exe
	IrfanView.exe
-Video影音
	cloudmusic.exe
	--
	QQPlayer.exe
	PotPlayer.exe
-Web网址
	更新地址&GitHub|https://github.com/hui-Zz/RunAny
-File文件
	WinRAR.exe
-Sys系统
	cmd.exe
	控制面板(&S)|Control.exe
-桌面(&D)`n
),%iniFile%
desktopItem:=""
Loop,%A_Desktop%\*.lnk,0,1
{
	desktopItem.="`t" A_LoopFileName "`n"
}
desktopItem.="`n"
Loop,%A_Desktop%\*.exe,0,1
{
	desktopItem.="`t" A_LoopFileName "`n"
}
FileAppend,%desktopItem%,%iniFile%
FileAppend,
(
-
;1级分隔符【-】并且使下面项目都回归1级目录
QQ.exe
;使用【&】指定快捷键为C,忽略下面C盘的快捷键C
计算器(&C)|calc.exe
我的电脑(&Z)|explorer.exe
;以【\】结尾代表是文件夹路径
C盘|C:\
-
),%iniFile%
ini:=true
return
