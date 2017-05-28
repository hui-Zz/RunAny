/*
╔═════════════════════════════════
║【RunAny】一劳永逸的快速启动工具 v3.0 批量搜索
║ by Zz 建议：hui0.0713@gmail.com
║ @2017.5.20 github.com/hui-Zz/RunAny
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
global fast:=true
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
OneKey:=Var_Read("OneKey")
OneWinKey:=Var_Read("OneWinKey",0)
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
	if(OneKey){
		try{
			OneHotKey:=OneWinKey ? "#" . OneKey : OneKey
			Hotkey,%OneHotKey%,One_Show,On
		}catch{
			gosub,Menu_Set
			MsgBox,16,请设置正确热键,%OneHotKey%`n一键搜索热键设置不正确
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
			MsgBox,17,,RunAny需要Everything快速识别程序的路径`n请设置正确安装路径或下载Everything：http://www.voidtools.com/
			IfMsgBox Ok
				Run,http://www.voidtools.com/
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
Menu_Init:
;#应用菜单数组#
global menuRoot:=Object()
menuRoot.Insert(RunAnyZz)
global menuLevel:=1
;#网址菜单名数组及地址队列#
global menuWebRoot:=Object()
global menuWebList:=Object()
menuWebRoot.Insert(RunAnyZz)
global webRootShow:=false
Loop, read, %iniFile%
{
	Z_ReadLine=%A_LoopReadLine%
	if(InStr(Z_ReadLine,"-")=1){
		;~;[生成节点树层级结构]
		menuItem:=RegExReplace(Z_ReadLine,"S)^-+")
		menuLevel:=StrLen(RegExReplace(Z_ReadLine,"S)(^-+).*","$1"))
		if(menuItem){
			Menu,%menuItem%,add
			Menu,% menuRoot[menuLevel],add,%menuItem%,:%menuItem%
			Menu,% menuRoot[menuLevel],Icon,%menuItem%,% TreeIconS[1],% TreeIconS[2]
			menuLevel+=1
			menuRoot[menuLevel]:=menuItem
		}else if(fast && menuRoot[menuLevel]){
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
		if(fast){
			Menu_Add_Fast(menuRoot[menuLevel],menuDiy[1])
		}else{
			Menu_Add(menuRoot[menuLevel],menuDiy[1])
		}
	}else if(RegExMatch(Z_ReadLine,"iS)^(\\\\|.:\\).*?\.exe$")){
		;~;[生成完全路径的应用]
		SplitPath,Z_ReadLine,fileName,,,nameNotExt
		MenuObj[nameNotExt]:=Z_ReadLine
		if(fast){
			Menu_Add_Fast(menuRoot[menuLevel],nameNotExt)
		}else{
			Menu_Add(menuRoot[menuLevel],nameNotExt)
		}
	}else{
		;~;[生成已取到的应用]
		appName:=RegExReplace(Z_ReadLine,"iS)\.(exe|lnk)$")
		if(!MenuObj[appName])
			MenuObj[appName]:=Z_ReadLine
		if(fast){
			Menu_Add_Fast(menuRoot[menuLevel],appName)
		}else{
			Menu_Add(menuRoot[menuLevel],appName)
		}
	}
}
Menu,% menuRoot[1],Add
if(ini){
	ini:=false
	TrayTip,,RunAny菜单初始化完成`n右击任务栏图标设置,3,1
	gosub,Menu_About
	gosub,Menu_Show
}
;~ TrayTip,,% A_TickCount-StartTick "毫秒",3,17
;#如果当前是无图标极速菜单,则开始加载图标的正常菜单#
if(fast){
	fast:=false
	gosub,Menu_Init
}
;#添加网址菜单的批量打开功能
Loop,% menuWebRoot.MaxIndex()
{
	webRoot:=menuWebRoot[A_Index]
	if(webRoot = menuRoot[1]){
		if(webRootShow){
			Menu,MENUWEB,add
			Menu,MENUWEB,add,&1批量打开,Web_Run
			Menu,MENUWEB,Icon,&1批量打开,% UrlIconS[1],% UrlIconS[2]
		}
	}else{
		Menu,%webRoot%,add,&1批量打开%webRoot%,Web_Run
		Menu,%webRoot%,Icon,&1批量打开%webRoot%,% UrlIconS[1],% UrlIconS[2]
	}
}
try Menu,Tray,Icon,% AnyIconS[1],% AnyIconS[2]
return
;══════════════════════════════════════════════════════════════════
;~;[生成菜单(判断后缀创建图标)]
Menu_Add(menuName,menuItem){
	try {
		item:=MenuObj[(menuItem)]
		itemLen:=StrLen(item)
		if(!fast)
			Menu,%menuName%,add,%menuItem%,Menu_Run
		if(Ext_Check(item,itemLen,".lnk")){
			try{
				FileGetShortcut, %item%, OutItem, , , , OutIcon, OutIconNum
				if(OutIcon){
					Menu,%menuName%,Icon,%menuItem%,%OutIcon%,%OutIconNum%
					IL_Add(ImageListID, OutIcon, OutIconNum)
				}else{
					Menu,%menuName%,Icon,%menuItem%,%OutItem%
					IL_Add(ImageListID, OutItem, 0)
				}
			} catch e {
				Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,264
				IL_Add(ImageListID, "shell32.dll", 264)
			}
		}else if(Ext_Check(item,itemLen,".ahk")){
			Menu,%menuName%,Icon,%menuItem%,% AHKIconS[1],% AHKIconS[2]
		}else if(Ext_Check(item,itemLen,".bat") || Ext_Check(item,itemLen,".cmd")){
			Menu,%menuName%,Icon,%menuItem%,% BATIconS[1],% BATIconS[2]
		}else if(RegExMatch(item,"iS)([\w-]+://?|www[.]).*")){
			website:=RegExReplace(item,"iS)[\w-]+://?((\w+\.)+\w+).*","$1")
			webIcon:=A_ScriptDir "\RunIcon\" website ".ico"
			if(FileExist(webIcon)){
				Menu,%menuName%,Icon,%menuItem%,%webIcon%,0
				IL_Add(ImageListID, webIcon, 0)
			}else{
				Menu,%menuName%,Icon,%menuItem%,% UrlIconS[1],% UrlIconS[2]
				IL_Add(ImageListID, UrlIconS[1], UrlIconS[2])
			}
			;~ [添加到网址菜单]
			if(menuName = menuRoot[1]){
				Menu,MENUWEB,Add,%menuItem%,Menu_Run
				Menu,MENUWEB,Icon,%menuItem%,%webIcon%,0
				webRootShow:=true
			}else{
				Menu,MENUWEB,Add,%menuName%, :%menuName%
			}
			menuWebList[(menuName)].=menuItem "`n"
			menuWebSame:=false
			Loop,% menuWebRoot.MaxIndex()
			{
				if(menuWebRoot[A_Index]=menuName){
					menuWebSame:=true
					break
				}
			}
			if(!menuWebSame){
				menuWebRoot.Insert(menuName)
			}
		}else if(InStr(item,"\",,0,1)=itemLen){
			Menu,%menuName%,Icon,%menuItem%,% FolderIconS[1],% FolderIconS[2]
		}else if(InStr(item,";",,0,1)=itemLen){
			Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,2
		}else{
			Menu,%menuName%,Icon,%menuItem%,%item%
			IL_Add(ImageListID, item, 0)
		}
	} catch e {
		IL_Add(ImageListID, EXEIconS[1], EXEIconS[2])
		if(HideFail){
			Menu,%menuName%,Delete,%menuItem%
		}else{
			Menu,%menuName%,Icon,%menuItem%,% EXEIconS[1],% EXEIconS[2]
		}
	}
}
;~;[生成菜单_极速]
Menu_Add_Fast(menuName,menuItem){
	try {
		Menu,%menuName%,add,%menuItem%,Menu_Run
	} catch e {
		if(HideFail){
			Menu,%menuName%,Delete,%menuItem%
		}else{
			Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,124
		}
	}
}
;~;[显示菜单]
Menu_Show:
	global selectZz:=Get_Zz()
	;#选中文本弹出网址菜单，其他弹出应用菜单#
	if(selectZz && !HideUnSelect && Candy_isFile!=1){
		Menu,MENUWEB,Show
	}else{
		Menu,% menuRoot[1],Show
	}
return
;~;[菜单运行]
Menu_Run:
	any:=MenuObj[(A_ThisMenuItem)]
	anyLen:=StrLen(any)
	if(!RegExMatch(A_ThisMenuItem,"S)^&1|2"))
		gosub,Menu_Common
	try {
		If(InStr(any,";",,0,1)=anyLen){
			StringLeft, any, any, anyLen-1
			Send_Zz(any)	;[输出短语]
			return
		}
		If GetKeyState("Ctrl"){	;[按住Ctrl是打开应用目录]
			If(TcPath && InStr(any,"\",,0,1)=anyLen){
				Run,%TcPath%%A_Space%"%any%"
			}else{
				Run,% "explorer.exe /select," any
			}
			return
		}
		try {
			if(selectZz){
				if(Candy_isFile=1){
					if(GetKeyState("Shift")){
						Run,*RunAs %any%%A_Space%"%selectZz%"
					}else{
						Run,%any%%A_Space%"%selectZz%"
					}
				}else if(RegExMatch(any,"iS)([\w-]+://?|www[.]).*")){
					Run,%any%%selectZz%
				}else{
					Run,%any%
				}
				return
			}
		} catch e {
		}
		If GetKeyState("Shift"){	;[按住Shift则是管理员身份运行]
			Run,*RunAs %any%
		}else{
			Run,%any%
		}
	} catch e {
		MsgBox,16,%A_ThisMenuItem%运行出错,% "运行路径：" any "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
	}
return
;~;[菜单最近运行]
Menu_Common:
	if(!MenuCommonList[1]){
		MenuCommonList[1]:="&1 " A_ThisMenuItem
		MenuObj[MenuCommonList[1]]:=any
		Menu,% menuRoot[1],Add,% MenuCommonList[1],Menu_Run
	}else if(MenuCommonList[1]!="&1" A_Space A_ThisMenuItem){
		if(!MenuCommonList[2]){
			MenuCommonList[2]:="&2" A_Space A_ThisMenuItem
			MenuObj[MenuCommonList[2]]:=any
			Menu,% menuRoot[1],Add,% MenuCommonList[2],Menu_Run
		}else if(MenuCommonList[1] && MenuCommonList[2]){
			MenuCommon1:=MenuCommonList[1]
			MenuCommon2:=MenuCommonList[2]
			MenuCommonList[1]:="&1" A_Space A_ThisMenuItem
			MenuCommonList[2]:=RegExReplace(MenuCommon1,"&1","&2")
			MenuObj[MenuCommonList[1]]:=any
			MenuObj[MenuCommonList[2]]:=MenuObj[(MenuCommon1)]
			Menu,% menuRoot[1],Rename,% MenuCommon1,% MenuCommonList[1]
			Menu,% menuRoot[1],Rename,% MenuCommon2,% MenuCommonList[2]
		}
	}
return
Web_Run:
	webName:=RegExReplace(A_ThisMenuItem,"iS)^&1批量打开")
	if(webName){
		webList:=menuWebList[(webName)]
	}else{
		webList:=menuWebList[(menuRoot[1])]
	}
	MsgBox,33,开始批量打开,确定用【%selectZz%】批量搜索以下网站：`n%webList%
	IfMsgBox Ok
	{
		Loop,parse,webList,`n
		{
			if(A_LoopField){
				any:=MenuObj[(A_LoopField)]
				if(InStr(any,"%s")){
					Run,% RegExReplace(any,"S)%s",selectZz)
				}else{
					Run,%any%%selectZz%
				}
			}
		}
	}
return
;══════════════════════════════════════════════════════════════════
;~;[一键Everything][搜索选中文字][激活][隐藏]
Ev_Show:
	selectZz:=Get_Zz()
	if(RegExMatch(selectZz,"S)^(\\\\|.:\\).*?$")){
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
One_Show:
	selectZz:=Get_Zz()
	if(InStr(OnePath,"%s")){
		Run,% RegExReplace(OnePath,"%s",selectZz)
	}else{
		Run,% OnePath selectZz
	}
return
;══════════════════════════════════════════════════════════════════
;~;[初始化]
Var_Set:
	RegRead, AutoRun, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, RunAny
	AutoRun:=AutoRun ? 1 : 0
	global HideFail:=Var_Read("HideFail",0)
	global HideUnSelect:=Var_Read("HideUnSelect",0)
	TcPath:=Var_Read("TcPath")
	OnePath:=Var_Read("OnePath","https://www.baidu.com/s?wd=%s")
	DisableApp:=Var_Read("DisableApp","vmware-vmx.exe,TeamViewer.exe")
	Loop,parse,DisableApp,`,
	{
		GroupAdd,DisableGUI,ahk_exe %A_LoopField%
	}
	if(Ext_Check(A_ScriptName,StrLen(A_ScriptName),".exe")){
		iconAny:=A_ScriptName ",1"
		iconMenu:=A_ScriptName ",2"
	}else if(FileExist(A_ScriptDir "\ZzIcon.dll")){
		iconAny:="ZzIcon.dll,1"
		iconMenu:="ZzIcon.dll,2"
		TreeIcon:="ZzIcon.dll,3"
		MoveIcon:="ZzIcon.dll,4"
		UpIcon:="ZzIcon.dll,5"
		DownIcon:="ZzIcon.dll,6"
	}else{
		iconAny:="shell32.dll,190"
		iconMenu:="shell32.dll,195"
		MoveIcon:="SHELL32.dll,246"
		UpIcon:="SHELL32.dll,247"
		DownIcon:="SHELL32.dll,248"
	}
	global AnyIcon:=Var_Read("AnyIcon",iconAny)
	global AnyIconS:=StrSplit(AnyIcon,",")
	global MenuIcon:=Var_Read("MenuIcon",iconMenu)
	global MenuIconS:=StrSplit(MenuIcon,",")
	global MoveIconS:=StrSplit(MoveIcon,",")
	global UpIconS:=StrSplit(UpIcon,",")
	global DownIconS:=StrSplit(DownIcon,",")
	global MenuCommonList:={}
return
;~;[后缀图标初始化]
Icon_Set:
	TreeIcon:=Var_Read("TreeIcon",TreeIcon)
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
	;~;[树型菜单图标集]
	global ImageListID := IL_Create(6)
	IL_Add(ImageListID, "shell32.dll", 1)
	IL_Add(ImageListID, "shell32.dll", 2)
	IL_Add(ImageListID, EXEIconS[1], EXEIconS[2])
	IL_Add(ImageListID, FolderIconS[1], FolderIconS[2])
	IL_Add(ImageListID, "shell32.dll", 264)
	IL_Add(ImageListID, TreeIconS[1], TreeIconS[2])
	Menu,Tray,Icon,启动菜单(&Z),% TreeIconS[1],% TreeIconS[2]
	Menu,Tray,Icon,菜单配置(&E),% EXEIconS[1],% EXEIconS[2]
	Menu,Tray,Icon,配置文件(&F),SHELL32.dll,134
	Menu,Tray,Icon,设置RunAny(&D),% AnyIconS[1],% AnyIconS[2]
	Menu,Tray,Icon,关于RunAny(&A)...,% MenuIconS[1],% MenuIconS[2]
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
	global Candy_isFile
	Candy_Saved:=ClipboardAll
	Clipboard=
	SendInput,^c
	if WinActive("ahk_class TTOTAL_CMD")
		ClipWait,0.5
	else
		ClipWait,0.2
	If(ErrorLevel){
		Clipboard:=Candy_Saved
		return
	}
	Candy_isFile:=DllCall("IsClipboardFormatAvailable","UInt",15)
	CandySel=%Clipboard%
	Clipboard:=Candy_Saved
	return CandySel
}
;══════════════════════════════════════════════════════════════════

;~;[菜单配置]
Menu_Edit:
	global TVFlag:=false
	;~;[功能菜单初始化]
	treeRoot:=Object()
	global moveRoot:=Object()
	moveRoot[1]:="moveMenu"
	global moveLevel:=0
	global exeIconNum:=6
	;~;[树型菜单初始化]
	Gui, Destroy
	Gui, +Resize
	Gui, Font,, Microsoft YaHei
	Gui, Add, TreeView,vRunAnyTV w450 r30 -Readonly AltSubmit Checked hwndHTV gTVClick ImageList%ImageListID%
	Gui, Add, Progress,vMyProgress w450 cBlue
	GuiControl, Hide, MyProgress
	GuiControl, -Redraw, RunAnyTV
	;~;[读取菜单配置内容写入树形菜单]
	Loop, read, %iniFile%
	{
		Z_ReadLine=%A_LoopReadLine%
		if(InStr(Z_ReadLine,"-")=1){
			;~;[生成节点树层级结构]
			treeLevel:=StrLen(RegExReplace(Z_ReadLine,"S)(^-+).+","$1"))
			if(RegExMatch(Z_ReadLine,"S)^-+[^-]+.*")){
				if(treeLevel=1){
					treeRoot.Insert(treeLevel,TV_Add(Z_ReadLine,,"Bold Icon6"))
				}else{
					treeRoot.Insert(treeLevel,TV_Add(Z_ReadLine,treeRoot[treeLevel-1],"Bold Icon6"))
				}
				TV_MoveMenu(Z_ReadLine)
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
	TVMenu("TVMenu")
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
		MsgBox,51,菜单树退出,已修改过菜单信息，是否保存修改再退出？
		IfMsgBox Yes
		{
			gosub,Menu_Save
			Gui, Destroy
		}
		IfMsgBox No
			Gui, Destroy
	}else{
		Gui, Destroy
	}
return
;~;[创建头部及右键功能菜单]
TVMenu(addMenu){
	flag:=addMenu="GuiMenu" ? true : false
	Menu, %addMenu%, Add,% flag ? "保存" : "保存`tCtrl+S", TVSave
	Menu, %addMenu%, Icon,% flag ? "保存" : "保存`tCtrl+S", SHELL32.dll,194
	Menu, %addMenu%, Add,% flag ? "添加" : "添加`tF3", TVAdd
	Menu, %addMenu%, Icon,% flag ? "添加" : "添加`tF3", SHELL32.dll,1
	Menu, %addMenu%, Add,% flag ? "编辑" : "编辑`tF2", TVEdit
	Menu, %addMenu%, Icon,% flag ? "编辑" : "编辑`tF2", SHELL32.dll,134
	Menu, %addMenu%, Add,% flag ? "删除" : "删除`tDel", TVDel
	Menu, %addMenu%, Icon,% flag ? "删除" : "删除`tDel", SHELL32.dll,132
	Menu, %addMenu%, Add
	Menu, %addMenu%, Add,移动到..., :moveMenu
	Menu, %addMenu%, Icon,移动到...,% MoveIconS[1],% MoveIconS[2]
	Menu, %addMenu%, Add,% flag ? "向下" : "向下`t(F5/PgDn)", TVDown
	Menu, %addMenu%, Icon,% flag ? "向下" : "向下`t(F5/PgDn)",% DownIconS[1],% DownIconS[2]
	Menu, %addMenu%, Add,% flag ? "向上" : "向上`t(F6/PgUp)", TVUp
	Menu, %addMenu%, Icon,% flag ? "向上" : "向上`t(F6/PgUp)",% UpIconS[1],% UpIconS[2]
	Menu, %addMenu%, Add
	Menu, %addMenu%, Add,% flag ? "多选导入" : "多选导入`tF8", TVImportFile
	Menu, %addMenu%, Icon,% flag ? "多选导入" : "多选导入`tF8", SHELL32.dll,55
	Menu, %addMenu%, Add,% flag ? "批量导入" : "批量导入`tF9", TVImportFolder
	Menu, %addMenu%, Icon,% flag ? "批量导入" : "批量导入`tF9", SHELL32.dll,46
	Menu, %addMenu%, Add,桌面导入, Desktop_Import
	Menu, %addMenu%, Icon,桌面导入, SHELL32.dll,35
	Menu, %addMenu%, Add,网站图标, Website_Icon
	Menu, %addMenu%, Icon,网站图标, SHELL32.dll,14
}
;~;[后缀判断图标]
Set_Icon(itemVar){
	itemLen:=StrLen(itemVar)
	if(RegExMatch(itemVar,"S)^-+[^-]+.*"))
		return "Icon6"
	if(RegExMatch(itemVar,"iS)\.(exe|lnk)$") || RegExMatch(itemVar,"iS)([\w-]+://?|www[.]).*")){
		exeIconNum++
		return "Icon" . exeIconNum
	}
	if(InStr(itemVar,";")=1 || itemVar="")
		return "Icon2"
	if(InStr(itemVar,"\",,0,1)=itemLen)
		return "Icon4"
	return "Icon1"
}
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
		TV_MoveMenuClean()
		TVFlag:=true
	}else if (A_GuiEvent == "K"){
		if (A_EventInfo = 46)
			gosub,TVDel
	}else if (A_GuiControl = "RunAnyTV") {
		TV_Modify(A_EventInfo, "Select Vis")
		TV_CheckUncheckWalk(A_GuiEvent,A_EventInfo,A_GuiControl)
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
TVUp:
	TV_Move(false)
return
TVDel:
	selText:=""
	DelListID:=Object()
	CheckID = 0
	Loop
	{
		CheckID := TV_GetNext(CheckID, "Checked")
		if not CheckID
			break
		TV_GetText(ItemText, CheckID)
		selText.=ItemText "`n"
		DelListID.Insert(CheckID)
	}
	if(!selText){
		MsgBox,请最少勾选一项
		return
	}
	if(RegExMatch(selText,"S)^-+[^-]+.*"))
		MsgBox,51,请确认(Esc取消),确定删除勾中的【以及它下面的所有子项目】？(注意)`n%selText%
	else
		MsgBox,51,请确认(Esc取消),确定删除勾中的？`n%selText%
	IfMsgBox Yes
	{
		Loop,% DelListID.MaxIndex()
		{
			TV_Delete(DelListID[A_Index])
		}
		TV_MoveMenuClean()
		TVFlag:=true
	}
return
TVSave:
	if(TVFlag){
		MsgBox,33,菜单树保存,需要保存修改吗？
		IfMsgBox Ok
		{
			gosub,Menu_Save
		}
	}else{
		Gui,Destroy
	}
return
Menu_Save:
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
return
;~;[制表符设置]
Set_Tab(tabNum){
	tabText:=""
	Loop,%tabNum%
	{
		tabText.=A_Tab
	}
	return tabText
}
TVImportFile:
	selID:=TV_GetSelection()
	parentID:=TV_GetParent(selID)
	FileSelectFile, exeName, M35, , 选择多项要导入的EXE(快捷方式), (*.exe;*.lnk)
	Menu,import%selID%,add,TVImportFolder	;只用于测试应用图标
	Loop,parse,exeName,`n
	{
		if(A_Index=1){
			lnkPath:=A_LoopField
		}else{
			I_LoopField:=A_LoopField
			exePath:=lnkPath "\" I_LoopField
			if Ext_Check(I_LoopField,StrLen(I_LoopField),".lnk"){
				FileGetShortcut,%lnkPath%\%I_LoopField%,exePath
				if Ext_Check(exePath,StrLen(exePath),".exe")
					SplitPath,exePath,I_LoopField
			}
			try{
				Menu,import%selID%,Icon,TVImportFolder,%exePath%,0
				IL_Add(ImageListID, exePath, 0)
				exeIconNum++
				fileID:=TV_Add(I_LoopField,parentID,"Icon" . exeIconNum)
			} catch e {
				fileID:=TV_Add(I_LoopField,parentID,"Icon3")
			} finally {
				TVFlag:=true
			}
		}
	}
return
TVImportFolder:
	selID:=TV_GetSelection()
	parentID:=TV_GetParent(selID)
	FileSelectFolder, folderName, , 0
	Menu,import%selID%,add,TVImportFolder	;只用于测试应用图标
	if(folderName){
		MsgBox,33,导入文件夹所有exe和lnk,确定导入%folderName%及子文件夹下所有程序和快捷方式吗？
		IfMsgBox Ok
		{
			Loop,%folderName%\*.lnk,0,1
			{
				lnkID:=TV_Add(A_LoopFileName,parentID,"Icon5")
			}
			Loop,%folderName%\*.exe,0,1
			{
				try{
					Menu,import%selID%,Icon,TVImportFolder,%A_LoopFileFullPath%,0
					IL_Add(ImageListID, A_LoopFileFullPath, 0)
					exeIconNum++
					folderID:=TV_Add(A_LoopFileName,parentID,"Icon" . exeIconNum)
				} catch e {
					folderID:=TV_Add(A_LoopFileName,parentID,"Icon3")
				}
			}
			TVFlag:=true
		}
	}
return
Website_Icon:
	IconPath:=A_ScriptDir "\RunIcon\"
	IfNotExist %IconPath%
		FileCreateDir,%IconPath%
	selText:=""
	selTextList:=Object()
	CheckID = 0
	Loop
	{
		CheckID := TV_GetNext(CheckID, "Checked")
		if not CheckID
			break
		TV_GetText(ItemText, CheckID)
		selText.=ItemText "`n"
		selTextList.Insert(ItemText)
	}
	if(selTextList.MaxIndex()=1){
		try {
			diyText:=StrSplit(ItemText,"|")
			webText:=(diyText[2]) ? diyText[2] : diyText[1]
			if(RegExMatch(webText,"iS)([\w-]+://?|www[.]).*")){
				website:=RegExReplace(webText,"iS)[\w-]+://?((\w+\.)+\w+).*","$1")
				webIcon:=IconPath website ".ico"
				InputBox, webSiteInput, 重新下载网站图标,可以重新下载图标并匹配网址`n请修改以下网址再点击下载,,,,,,,,http://%website%/favicon.ico
				if !ErrorLevel
				{
					URLDownloadToFile,%webSiteInput%,%webIcon%
					MsgBox,65,,图标下载成功，是否要重启生效？
					IfMsgBox Ok
						Reload
				}
			}
		} catch e {
			MsgBox,以下网站图标无法下载，可以手动添加对应网址图标到%A_ScriptDir%\RunIcon`n%webSiteInput%
		}
		return
	}
	if(selText){
		MsgBox,33,下载网站图标,确定下载以下选中的网站图标：`n(下载的图标在%A_ScriptDir%\RunIcon)`n%selText%
		IfMsgBox Ok
		{
			Loop,% selTextList.MaxIndex()
			{
				GuiControl, Show, MyProgress
				ItemText:=selTextList[A_Index]
				Gosub,Website_Icon_Down
			}
			if(errDown!="")
				MsgBox,以下网站图标无法下载，请单选后点[网站图标]按钮重新指定网址下载，或手动添加对应网址图标到%A_ScriptDir%\RunIcon`n%errDown%
			GuiControl, Hide, MyProgress
			MsgBox,65,,图标下载完成，是否要重启生效？
			IfMsgBox Ok
				Reload
		}
		return
	}
	MsgBox,33,下载网站图标,确定下载RunAny内所有网站图标吗？`n(下载的图标在%A_ScriptDir%\RunIcon)
	IfMsgBox Ok
	{
		errDown:=""
		ItemID = 0
		Loop
		{
			ItemID := TV_GetNext(ItemID, "Full")
			if not ItemID
				break
			TV_GetText(ItemText, ItemID)
			GuiControl, Show, MyProgress
			Gosub,Website_Icon_Down
		}
		if(errDown!="")
			MsgBox,以下网站图标无法下载，请单选后点[网站图标]按钮重新指定网址下载，或手动添加对应网址图标到%A_ScriptDir%\RunIcon`n%errDown%
		GuiControl, Hide, MyProgress
		MsgBox,65,,图标下载完成，是否要重启生效？
		IfMsgBox Ok
			Reload
	}
return
Website_Icon_Down:
	try {
		diyText:=StrSplit(ItemText,"|")
		webText:=(diyText[2]) ? diyText[2] : diyText[1]
		if(RegExMatch(webText,"iS)([\w-]+://?|www[.]).*")){
			website:=RegExReplace(webText,"iS)[\w-]+://?((\w+\.)+\w+).*","$1")
			webIcon:=IconPath website ".ico"
			URLDownloadToFile,http://%website%/favicon.ico,%webIcon%
			GuiControl,, MyProgress, +10
		}
	} catch e {
		errDown.="http://" website "/favicon.ico`n"
	}
return
;~;[上下移动项目]
TV_Move(moveMode = true){
	selID:=TV_GetSelection()
	moveID:=moveMode ? TV_GetNext(selID) : TV_GetPrev(selID)
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
;~;[批量移动项目到指定树节点]
TV_MoveMenu(moveMenuName){
	moveItem:=RegExReplace(moveMenuName,"S)^-+")
	moveLevel:=StrLen(RegExReplace(moveMenuName,"S)(^-+).*","$1"))
	Menu,%moveMenuName%,add,%moveMenuName%,Move_Menu
	Menu,% moveRoot[moveLevel],add,%moveItem%, :%moveMenuName%
	Menu,% moveRoot[moveLevel],Icon,%moveItem%,% TreeIconS[1],% TreeIconS[2]
	moveLevel+=1
	moveRoot[moveLevel]:=moveMenuName
}
TV_MoveMenuClean(){
	;[清空功能菜单]
	Menu,TVMenu,Delete
	Menu,GuiMenu,Delete
	Menu,moveMenu,DeleteAll
	;[重建]
	ItemID = 0
	Loop
	{
		ItemID := TV_GetNext(ItemID, "Full")
		if not ItemID
			break
		TV_GetText(ItemText, ItemID)
		if(RegExMatch(ItemText,"S)^-+[^-]+.*")){
			TV_MoveMenu(ItemText)
		}
	}
	TVMenu("TVMenu")
	TVMenu("GuiMenu")
	Gui, Menu, GuiMenu
}
;~;[移动节点后保存原来级别和自动变更名称(死了好多脑细胞)]
Move_Menu:
	ItemID = 0
	MoveID = 0
	CheckID = 0
	DelListID:=Object()
	;[获取目标节点]
	Loop
	{
		ItemID := TV_GetNext(ItemID, "Full")
		if not ItemID
			break
		TV_GetText(ItemText, ItemID)
		if(ItemText=A_ThisMenuItem){
			MoveID:=ItemID
		}
	}
	;[获取选中节点并移动到目标节点下]
	if(MoveID){
		parentL:=StrLen(RegExReplace(A_ThisMenuItem,"S)(^-+).*","$1"))
		moveLevelID:=
		moveLevelList:=Object()
		moveLevelList[parentL]:=MoveID
		cpLevel:=0
		Loop
		{
			CheckID := TV_GetNext(CheckID, "Checked")
			if not CheckID
				break
			TV_GetText(ItemText, CheckID)
			;[对比选中节点到目标节点的级别，进行加减"-"级别匹配]
			if(InStr(ItemText,"-")=1){
				cItem:=RegExReplace(ItemText,"S)^-+")
				cLevel:=StrLen(RegExReplace(ItemText,"S)(^-+).*","$1"))
				;[如已有比选中节点高一级则它为父级,否则为目标节点级别]
				pLevel:=(moveLevelList[cLevel+Abs(cpLevel)]) ? cLevel+Abs(cpLevel) : parentL
				cpLevel:=cLevel-pLevel	;选中节点与目标的级别差
				if(cpLevel>1){	;选中节点比目标大于1级
					Loop,% cpLevel - 1
					{
						ItemText:=RegExReplace(ItemText,"S)^-")
					}
				}else if(cpLevel<1){	;选中节点比目标小于1级
					Loop,% Abs(1 - cpLevel)
					{
						ItemText:="-" . ItemText
					}
				}
				cLevel:=StrLen(RegExReplace(ItemText,"S)(^-+).*","$1"))
				if(Abs(cLevel-pLevel)=1){	;选中节点与目标差1级
					if(cItem){
						;[是节点不是分隔符]
						moveLevelID:=TV_Add(ItemText,moveLevelList[cLevel-1],Set_Icon(ItemText))
						moveLevelList[cLevel]:=moveLevelID
						MoveID:=moveLevelID
					}else{
						;[遇到分隔符则改变树型]
						TV_Add(ItemText,moveLevelList[cLevel-1],Set_Icon(ItemText))
						MoveID:=moveLevelList[cLevel-1]
					}
				}
			}else{
				moveLevelID:=TV_Add(ItemText,MoveID,Set_Icon(ItemText))
			}
			DelListID.Insert(CheckID)
			TVFlag:=true
		}
		;[删除原先节点]
		Loop,% DelListID.MaxIndex()
		{
			TV_Delete(DelListID[A_Index])
		}
		;[焦点到移动后新节点]
		TV_Modify(moveLevelID, "VisFirst")
		TV_Modify(moveLevelID, "Select")
		TV_MoveMenuClean()
	}
return
;修改于ahk论坛全选全不选
TV_CheckUncheckWalk(_GuiEvent, _EventInfo, _GuiControl)
{	
	static 	TV_SuspendEvents := False											;最初接受事件并保持跟踪
	If ( TV_SuspendEvents || !_GuiEvent || !_EventInfo || !_GuiControl )		;无所事事：出去！
		Return
	If _GuiEvent = Normal														;这是一个左键：继续
	{
		Critical											                    ;不能被中断。
		TV_SuspendEvents := True												;在工作时停止对功能的进一步调用
		Gui, TreeView, %_GuiControl% 											;激活正确的TV
		TV_Modify(_EventInfo, "Select")										;选择项目反正...这一行可能在这里取消和分散进一步
		If TV_Get( _EventInfo, "Checked" )										;项目的复选标记
		{
			If TV_GetChild( _EventInfo )										;项目的节点
				ToggleAllTheWay( _EventInfo, False )							;复选标记所有的孩子一路下来
		}
		Else																	;它未被选中
		{
			If TV_GetChild( _EventInfo )										;它是一个节点
				ToggleAllTheWay( _EventInfo, True )								;取消选中所有的孩子一直向下
			If TV_Get( TV_GetParent( _EventInfo ), "Checked") 				;父节点选中怎么样？
			{
				locItemId := TV_GetParent( _EventInfo )						;父节点检查标记：获取父ID
				While locItemId													;循环一路向上
				{
					TV_Modify( locItemId , "-Check" )							;它的未选中：检查！
					locItemId := TV_GetParent( locItemId )						;获取下一个父ID
				}
			}
		}
	}
	TV_SuspendEvents := False													;激活事件
	Return
}
; ToggleAllTheWay：内部使用
ToggleAllTheWay(_ItemID=0, _ChkUchk=True ) {
	If !_ItemID		;停止递归
		Return			
	_ItemID := TV_GetChild( _ItemID ) 	;得到下一个孩子
	Loop
	{
		If  !_ItemID 					;工作结束：出去
			Break
		If _ChkUchk        ;区分条件检索
		{
			If TV_Get( _ItemID , "Checked" )
				TV_Modify( _ItemID , "-Check" )
		}
		Else
		{
			If !TV_Get( _ItemID , "Checked" )
				TV_Modify( _ItemID , "Check" )
		}
		ToggleAllTheWay( _ItemID, _ChkUchk )			;使用递归
		_ItemID := TV_GetNext( _ItemID )
	}
	Return
}
;══════════════════════════════════════════════════════════════════
;~;[设置选项]
Menu_Set:
	Gui,66:Destroy
	Gui,66:Font,,Microsoft YaHei
	Gui,66:Margin,30,20
	Gui,66:Add,Tab,x10 y10 w360 h350,RunAny设置|Everything设置|一键搜索|图标设置
	Gui,66:Tab,RunAny设置,,Exact
	Gui,66:Add,GroupBox,xm-10 y+5 w330 h70,RunAny
	Gui,66:Add,Checkbox,Checked%AutoRun% xm yp+25 vvAutoRun,开机自动启动
	Gui,66:Add,Checkbox,Checked%HideFail% xm yp+20 vvHideFail,隐藏失效项
	Gui,66:Add,Checkbox,Checked%HideUnSelect% x+30 vvHideUnSelect,选中文字也显示应用菜单
	Gui,66:Add,GroupBox,xm-10 y+10 w215 h55,自定义显示热键
	Gui,66:Add,Hotkey,xm+10 yp+20 w140 vvMenuKey,%MenuKey%
	Gui,66:Add,Checkbox,Checked%MenuWinKey% xm+155 yp+3 vvMenuWinKey,Win
	Gui,66:Add,GroupBox,xm-10 y+15 w330 h85,屏蔽RunAny程序列表（逗号分隔）
	Gui,66:Add,Edit,xm+10 yp+20 w300 r3 vvDisableApp,%DisableApp%
	Gui,66:Add,GroupBox,xm-10 y+15 w340 h65,TotalCommander安装路径（TC打开文件夹）
	Gui,66:Add,Button,xm yp+20 w50 GSetTcPath,选择
	Gui,66:Add,Edit,xm+60 yp w260 r2 vvTcPath,%TcPath%
	
	Gui,66:Tab,Everything设置,,Exact
	Gui,66:Add,GroupBox,xm-10 y+20 w215 h55,一键Everything[搜索选中文字][激活][隐藏]
	Gui,66:Add,Hotkey,xm+10 yp+20 w140 vvEvKey,%EvKey%
	Gui,66:Add,Checkbox,Checked%EvWinKey% xm+155 yp+3 vvEvWinKey,Win
	Gui,66:Add,GroupBox,xm-10 y+20 w340 h150,Everything安装路径
	Gui,66:Add,Button,xm yp+30 w50 GSetEvPath,选择
	Gui,66:Add,Edit,xm+60 yp w260 r5 vvEvPath,%EvPath%
	
	Gui,66:Tab,一键搜索,,Exact
	Gui,66:Add,GroupBox,xm-10 y+20 w340 h230,一键搜索选中文字
	Gui,66:Add,Hotkey,xm yp+30 w140 vvOneKey,%OneKey%
	Gui,66:Add,Checkbox,Checked%OneWinKey% xm+155 yp+3 vvOneWinKey,Win
	Gui,66:Add,Text,xm yp+40 w250,一键搜索网址(`%s为选中文字的替代参数)
	Gui,66:Add,Edit,xm yp+20 w325 r5 vvOnePath,%OnePath%
	
	Gui,66:Tab,图标设置,,Exact
	Gui,66:Add,GroupBox,xm-10 y+10 w340 h280,图标自定义设置（文件路径,序号）
	Gui,66:Add,Text,xm yp+30 w80,树节点图标
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
	Gui,66:Add,Button,Default xm y+25 w75 GSetOK,确定(&Y)
	Gui,66:Add,Button,x+5 w75 GSetCancel,取消(&C)
	Gui,66:Add,Button,x+5 w75 GSetReSet,重置
	Gui,66:Show,,%RunAnyZz%设置
	return
;~;[关于]
Menu_About:
	Gui,99:Destroy
	Gui,99:Margin,20,20
	Gui,99:Font,Bold,Microsoft YaHei
	Gui,99:Add,Text,y+10, 【%RunAnyZz%】一劳永逸的快速启动工具 v3.0 批量搜索
	Gui,99:Font
	Gui,99:Add,Text,y+10, 默认启动菜单热键为``(Esc键下方的重音符键)
	Gui,99:Add,Text,y+10, 右键任务栏RunAny图标自定义菜单、热键、图标等配置
	Gui,99:Add,Text,y+10
	Gui,99:Font,,Consolas
	Gui,99:Add,Text,y+10, by Zz @2017.5.20 建议：hui0.0713@gmail.com
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
	Reg_Set(vHideUnSelect,HideUnSelect,"HideUnSelect")
	Reg_Set(vMenuKey,MenuKey,"MenuKey")
	Reg_Set(vMenuWinKey,MenuWinKey,"MenuWinKey")
	Reg_Set(vEvKey,EvKey,"EvKey")
	Reg_Set(vEvWinKey,EvWinKey,"EvWinKey")
	Reg_Set(vEvPath,EvPath,"EvPath")
	Reg_Set(vOneKey,OneKey,"OneKey")
	Reg_Set(vOneWinKey,OneWinKey,"OneWinKey")
	Reg_Set(vOnePath,OnePath,"OnePath")
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
	RegDelete, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, RunAny
	Reload
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
	Menu,Tray,add
	Menu,Tray,add,设置RunAny(&D),Menu_Set
	Menu,Tray,Add,关于RunAny(&A)...,Menu_About
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
	;执行搜索动作
	Query(aValue=1)
	{
		dllcall(everyDLL "\Everything_Query",int,aValue)
		return
	}
	;返回匹配总数
	GetTotResults()
	{
		return dllcall(everyDLL "\Everything_GetTotResults")
	}
	;返回文件名
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
;~;[导入桌面程序菜单]
Desktop_Import:
	MsgBox,33,导入桌面程序,确定导入桌面程序到菜单当中吗？
	IfMsgBox Ok
	{
		Gosub,Desktop_Append
		Reload
	}
return
Desktop_Append:
	desktopItem:="`n-桌面(&D)`n"
	desktopDir:=""
	Loop,%A_Desktop%\*.lnk,0,1
	{
		if(A_LoopFileDir!=A_Desktop && A_LoopFileDir!=desktopDir){
			desktopDir:=A_LoopFileDir
			StringReplace,dirItem,desktopDir,%A_Desktop%\
			desktopItem.="`t--" dirItem "`n"
		}
		desktopItem.="`t" A_LoopFileName "`n"
	}
	desktopItem.="`n"
	desktopDir:=""
	Loop,%A_Desktop%\*.exe,0,1
	{
		if(A_LoopFileDir!=A_Desktop && A_LoopFileDir!=desktopDir){
			desktopDir:=A_LoopFileDir
			StringReplace,dirItem,desktopDir,%A_Desktop%\
			desktopItem.="`t--" dirItem "`n"
		}
		desktopItem.="`t" A_LoopFileName "`n"
	}
	FileAppend,%desktopItem%,%iniFile%
return
;~;[初次运行]
First_Run:
FileAppend,
(
;以【;】开头代表注释
;以【-】开头+名称表示1级节点
-App常用
	;以【--】开头+名称表示2级节点树
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
	百度(&B)|https://www.baidu.com/s?wd=
	翻译(&F)|http://translate.google.cn/#auto/zh-CN/
	淘宝(&T)|https://s.taobao.com/search?q=
	--
	RunAny地址|https://github.com/hui-Zz/RunAny
-File文件
	WinRAR.exe
-Sys系统
	cmd.exe
	控制面板(&S)|Control.exe
),%iniFile%
Gosub,Desktop_Append
FileAppend,
(
-
;1级分隔符【-】并且使下面项目都回归1级节点
QQ.exe
;使用【&】指定快捷键为C,忽略下面C盘的快捷键C
计算器(&C)|calc.exe
我的电脑(&Z)|explorer.exe
;以【\】结尾代表是文件夹路径
C盘|C:\
-
),%iniFile%
ini:=true
fast:=false
return
