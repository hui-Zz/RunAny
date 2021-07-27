/*
╔══════════════════════════════════════════════════
║【RunAny】一劳永逸的快速启动工具 v5.7.6 @2021.07.16
║ 国内Gitee文档：https://hui-zz.gitee.io/RunAny
║ Github文档：https://hui-zz.github.io/RunAny
║ Github地址：https://github.com/hui-Zz/RunAny
║ by hui-Zz 建议：hui0.0713@gmail.com
║ 讨论QQ群：246308937
╚══════════════════════════════════════════════════
*/
#NoEnv                  ;~;不检查空变量为环境变量
#Persistent             ;~;让脚本持久运行
#WinActivateForce       ;~;强制激活窗口
#SingleInstance,Force   ;~;运行替换旧实例
ListLines,Off           ;~;不显示最近执行的脚本行
AutoTrim,On             ;~;自动去除变量中前导和尾随空格制表符
SendMode,Input          ;~;使用更速度和可靠方式发送键鼠点击
CoordMode,Menu          ;~;相对于整个屏幕
SetBatchLines,-1        ;~;脚本全速执行
SetWorkingDir,%A_ScriptDir%               ;~;脚本当前工作目录
global StartTick:=A_TickCount             ;~;评估RunAny初始化时间
global RunAnyZz:="RunAny"                 ;~;名称
global RunAnyConfig:="RunAnyConfig.ini"   ;~;配置文件
global RunAny_ObjReg:="RunAny_ObjReg.ini" ;~;插件注册配置文件
global RunAny_update_version:="5.7.6"     ;~;版本号
global RunAny_update_time:="2021.07.16"   ;~;更新日期
gosub,Var_Set           ;~;01.参数初始化
gosub,Menu_Var_Set      ;~;02.自定义变量
gosub,Icon_Set          ;~;03.图标初始化
gosub,Run_Exist         ;~;04.调用环境判断
gosub,Plugins_Read      ;~;05.插件脚本读取
gosub,RunCtrl_Read      ;~;06.启动规则读取
;══════════════════════════════════════════════════════════════════
;~;[07.初始化菜单显示热键]
HotKeyList:=["MenuHotKey","MenuHotKey2","MenuNoGetHotKey","EvHotKey","OneHotKey"]
RunHotKeyList:=HotKeyList.Clone()
HotKeyList.Push("TreeHotKey1","TreeHotKey2","TreeIniHotKey1","TreeIniHotKey2")
HotKeyList.Push("RunATrayHotKey","RunASetHotKey","RunAReloadHotKey","RunASuspendHotKey","RunAExitHotKey")
HotKeyList.Push("PluginsManageHotKey","RunCtrlManageHotKey","PluginsAlonePauseHotKey","PluginsAloneSuspendHotKey","PluginsAloneCloseHotKey")
HotKeyTextList:=["RunAny菜单显示热键","RunAny菜单2热键","RunAny菜单热键(不获取选中内容)","一键Everything热键","一键搜索热键"]
HotKeyTextList.Push("修改菜单管理(1)","修改菜单管理(2)","修改菜单文件(1)","修改菜单文件(2)")
HotKeyTextList.Push("RunAny托盘菜单","设置RunAny","重启RunAny","停用RunAny","退出RunAny","插件管理","启动管理","独立插件脚本一键暂停","独立插件脚本挂起热键","独立插件脚本一键关闭")
RunList:=["Menu_Show1","Menu_Show2","Menu_NoGet_Show","Ev_Show","One_Show","Menu_Edit1","Menu_Edit2","Menu_Ini","Menu_Ini2"]
RunList.Push("Menu_Tray","Settings_Gui","Menu_Reload","Menu_Suspend","Menu_Exit","Plugins_Gui","RunCtrl_Manage_Gui","Plugins_Alone_Pause","Plugins_Alone_Suspend","Plugins_Alone_Close")
Hotkey, IfWinNotActive, ahk_group DisableGUI
For ki, kv in HotKeyList
{
	StringReplace,keyV,kv,Hot
	%keyV%:=Var_Read(keyV)
	StringReplace,winkeyV,kv,Hot,Win
	%winkeyV%:=Var_Read(winkeyV,0)
	if(ki=1 && !%keyV%){
		%keyV%:="``"
	}
}
errorKeyStr:=""
For ki, kv in HotKeyList
{
	StringReplace,keyV,kv,Hot
	StringReplace,winkeyV,kv,Hot,Win
	if(%keyV%){
		if(!MENU2FLAG){
			if ki in 2,6,8
			{
				continue
			}
		}
		%kv%:=%winkeyV% ? "#" . %keyV% : %keyV%
		try{
			Hotkey,% %kv%,% RunList[ki],On
		}catch{
			errorKeyStr.=kv "`n"
		}
	}
}
;~;[08.托盘菜单]
Gosub,MenuTray
if(errorKeyStr){
	gosub,Settings_Gui
	if(ki!=1 && ki!=2)
		SendInput,^{Tab}
	MsgBox,16,RunAny热键配置不正确,% "热键错误：`n" errorKeyStr "`n请设置正确热键后重启RunAny"
	return
}
if(A_AhkVersion < 1.1.28){
	MsgBox, 16, AutoHotKey版本过低！, 由于你的AHK版本没有高于1.1.28，会影响RunAny功能的使用!`n
	(
1. 不支持StrSplit()函数的MaxParts`n2. 不支持动态Hotstring创建
	)
}
;══════════════════════════════════════════════════════════════════
t1:=A_TickCount-StartTick
Menu_Tray_Tip("初始化时间：" Round(t1/1000,3) "s`n","开始运行插件脚本...")
if(!iniFlag){
	;~;[09.运行插件脚本]
	Gosub,AutoClose_Plugins
	Gosub,AutoRun_Plugins
	;~;[10.插件对象注册]
	Gosub,Plugins_Object_Register
}
;~;[11.后缀图标初始化]
Gosub,Icon_FileExt_Set
;══════════════════════════════════════════════════════════════════
;~;[12.创建初始菜单]
t2:=A_TickCount-StartTick
Menu_Tray_Tip("运行插件脚本：" Round((t2-t1)/1000,3) "s`n","开始创建无图标菜单...")
global MenuObj:=Object()                    ;~程序全路径
global MenuObjKey:=Object()                 ;~程序热键
global MenuObjKeyName:=Object()             ;~程序热键关联菜单项名称
global MenuObjExt:=Object()                 ;~后缀对应的菜单
global MenuObjWindow:=Object()              ;~软件窗口对应的菜单
global MenuHotStrList:=Object()             ;~热字符串对象数组
global MenuTreeKey:=Object()                ;~菜单树分类热键
global MenuItemIconList:=Object()           ;~菜单项对应图标对象
global MenuItemIconNoList:=Object()         ;~菜单项对应图标位置对象
global MenuExeArray:=Object()               ;~EXE程序对象数组
global MenuExeIconArray:=Object()           ;~EXE程序优先加载图标对象数组
global MenuObjTreeLevel:=Object()           ;~菜单对应级别
global MenuObjPublic:=[]                    ;~后缀公共菜单
global MenuShowFlag:=false                  ;~菜单功能是否可以显示
global MenuIconFlag:=false                  ;~菜单图标是否加载完成
global MenuObjName:=Object()                ;~程序菜单项名称
global MenuBar:=""                          ;~菜单分列标记
global MenuCount:=MENU2FLAG ? 2 : 1
MenuObj.SetCapacity(10240)
MenuExeArray.SetCapacity(1024)
MenuExeIconArray.SetCapacity(3072)
Loop,%MenuCount%
{
	M%A_Index%:=RunAnyZz . A_Index
	MenuSendStrList%A_Index%:=Object()      ;菜单中短语项列表
	MenuWebList%A_Index%:=Object()          ;菜单中网址%s搜索项列表
	MenuGetZzList%A_Index%:=Object()        ;菜单中GetZz搜索项列表
	MenuExeList%A_Index%:=Object()          ;菜单中的exe列表
	MenuObjList%A_Index%:=Object()          ;菜单分类运行项列表
	MenuObjText%A_Index%:=[]                ;选中文字菜单
	MenuObjFile%A_Index%:=[]                ;选中文件菜单
	MenuObjTree%A_Index%:=Object()          ;分类目录程序全数据
	MenuObjTree%A_Index%[M%A_Index%]:=Object()
	;菜单级别：初始为根菜单RunAny
	menuRoot%A_Index%:=[M%A_Index%]
}
MenuShowFlag:=true
;══════════════════════════════════════════════════════════════════
;~;[13.判断有无路径应用则需要使用Everything]
EvPath:=Var_Read("EvPath")
if(!EvNo){
	global EvQueryFlag:=false  ;~Everything是否可以搜索到结果
	EvCommandStr:=EvDemandSearch ? everythingCommandStr() : ""
	if(!EvDemandSearch || (EvDemandSearch && EvCommandStr!="")){
		evAdminRun:=A_IsAdmin ? "-admin" : ""
		;获取everything路径
		evExist:=true
		DetectHiddenWindows,On
		if(WinExist("ahk_exe Everything.exe")){
			WinGet, EvPathRun, ProcessPath, ahk_exe Everything.exe
			ev := new everything
			;RunAny管理员权限运行后发现Everything非管理员权限则重新以管理员权限运行
			if(!ev.GetIsAdmin() && A_IsAdmin && EvPathRun){
				Run,%EvPathRun% -exit
				Run,%EvPathRun% -startup %evAdminRun%
				Sleep,500
				gosub,Menu_Reload
			}
		}
		while !WinExist("ahk_exe Everything.exe")
		{
			if(A_Index>10){
				EvPathRun:=Get_Transform_Val(EvPath)
				if(EvPathRun && FileExist(EvPathRun) && !InStr(FileExist(EvPathRun), "D")){
					Run,%EvPathRun% -startup %evAdminRun%
					Sleep,500
					break
				}else if(FileExist(A_ScriptDir "\Everything\Everything.exe")){
					Run,%A_ScriptDir%\Everything\Everything.exe -startup %evAdminRun%
					EvPath=%A_ScriptDir%\Everything\Everything.exe
					Sleep,500
					break
				}else{
					TrayTip,,RunAny需要Everything快速识别无路径程序`n
					(
* 运行Everything后再重启RunAny
* 或在RunAny设置中配置Everything正确安装路径`n* 或www.voidtools.com下载安装
					),5,1
					evExist:=false
					break
				}
			}
			Sleep,100
		}
		if(Trim(EvPath," `t`n`r")=""){
			;>>发现Everything已运行则取到路径
			WinGet, EvPath, ProcessPath, ahk_exe Everything.exe
		}
		;使用everything补全无路径exe的全路径
		global MenuObjEv:=Object()    ;Everything搜索结果程序全径
		global MenuObjSame:=Object()  ;Everything搜索结果重名程序全径
		If(evExist){
			if(EvCheckFlag){
				RegWrite,REG_SZ,HKEY_CURRENT_USER,SOFTWARE\RunAny,EvTotResults,0
				gosub,everythingCheck
			}
			RegRead,EvTotResults,HKEY_CURRENT_USER,SOFTWARE\RunAny,EvTotResults
			if(EvTotResults>0){
				everythingQuery(EvCommandStr)
				EvQueryFlag:=true
			}else{
				SetTimer,everythingCheckResults,100
			}
			for k,v in MenuObjEv
			{
				MenuObj:=MenuObjEv.Clone()
				break
			}
		}
		;如果需要自动关闭everything
		if(EvAutoClose && EvPath && EvQueryFlag){
			EvPathRun:=Get_Transform_Val(EvPath)
			Run,%EvPathRun% -exit
		}
		DetectHiddenWindows,Off
	}
}
;══════════════════════════════════════════════════════════════════
t3:=A_TickCount-StartTick
Menu_Tray_Tip("调用Everything搜索应用全路径：" Round((t3-t2)/1000,3) "s`n","开始加载完整菜单功能...")
Menu_Read(iniVar1,menuRoot1,"",1)

t4:=t5:=A_TickCount-StartTick
Menu_Tray_Tip("创建菜单1：" Round((t4-t3)/1000,3) "s`n")
;~;[14.如果有第2菜单则开始加载]
if(MENU2FLAG){
	Menu_Tray_Tip("","开始创建菜单2内容...")
	Menu_Read(iniVar2,menuRoot2,"",2)
	t5:=A_TickCount-StartTick
	Menu_Tray_Tip("创建菜单2：" Round((t5-t4)/1000,3) "s`n")
}

;~;[15.初始菜单加载后操作]
if(SendStrEcKey!="")
	SendStrDcKey:=SendStrDecrypt(SendStrEcKey,RunAnyZz ConfigDate)

Gosub,Rule_Effect
try Menu,Tray,Icon,% ZzIconS[1],% ZzIconS[2]

;~;[16.对菜单内容项进行过滤调整]
Loop,%MenuCount%
{
	menuDefaultRoot%A_Index%:=[M%A_Index% " "]
	Menu_Read(iniVar%A_Index%,menuDefaultRoot%A_Index%," ",A_Index)

	menuWebRoot%A_Index%:=[M%A_Index% "  "]
	Menu_Read(iniVar%A_Index%,menuWebRoot%A_Index%,"  ",A_Index)

	menuFileRoot%A_Index%:=[M%A_Index% "   "]
	Menu_Read(iniVar%A_Index%,menuFileRoot%A_Index%,"   ",A_Index)

	Menu_Item_List_Filter(A_Index,"MenuSendStrList",HideSend)
	Menu_Item_List_Filter(A_Index,"MenuWebList",HideWeb)
	Menu_Item_List_Filter(A_Index,"MenuGetZzList",HideGetZz)
	
	;带%s的网址菜单分类下增加批量搜索功能项
	For mn,items in MenuWebList%A_Index%
	{
		if(!RegExMatch(mn,"S)[^\s]+\s$")){
			Menu,%mn%,add
			Menu,%mn%,add,%RUNANY_SELF_MENU_ITEM1%%mn%,Web_Run
			Menu,%mn%,Icon,%RUNANY_SELF_MENU_ITEM1%%mn%,% UrlIconS[1],% UrlIconS[2],%MenuIconSize%
		}
	}
	;设置后缀公共菜单
	MenuObjExt["public"]:=MenuObjPublic
	
	;选中文本菜单过滤分类
	if(MenuObjText%A_Index%.MaxIndex()>0){
		Menu_Tree_List_Filter(A_Index,"MenuObjText",2)
		rootName:=menuWebRoot%A_Index%[1]
		;开启选中文字菜单后，主菜单里面不带%getZz%或%s的都不再显示
		for k,v in MenuObjTree%A_Index%[rootName]
		{
			if(v!="" && Get_Menu_Item_Mode(v,true)<10){
				if(!InStr(v,"%getZz%") && !InStr(v,"%s")){
					try Menu,%rootName%,Delete,% Get_Obj_Name(v)
				}else{
					global MenuObjTextRootFlag:=true
				}
			}
		}
	}
	;选中文件菜单过滤分类
	if(MenuObjFile%A_Index%.MaxIndex()>0){
		Menu_Tree_List_Filter(A_Index,"MenuObjFile",3)
		rootName:=menuFileRoot%A_Index%[1]
		;开启选中文件菜单后，主菜单里面不带%getZz%或%s的都不再显示
		for k,v in MenuObjTree%A_Index%[rootName]
		{
			if(v!="" && !InStr(v,"%getZz%") && !InStr(v,"%s") 
				&& Get_Menu_Item_Mode(v,true)!=1 && Get_Menu_Item_Mode(v,true)<10){
				try Menu,%rootName%,Delete,% Get_Obj_Name(v)
			}
		}
	}
	;~;[17.最近运行项]
	if(RecentMax>0){
		M_Index:=A_Index
		Menu,% menuDefaultRoot%M_Index%[1],Add
		Menu,% menuWebRoot%M_Index%[1],Add
		Menu,% menuFileRoot%M_Index%[1],Add
		For mci, mcItem in MenuCommonList
		{
			if(A_Index>RecentMax)
				break
			obj:=RegExReplace(mcItem,"&\d+ ")
			MenuObj[mcItem]:=MenuObj[obj]
			Menu,% menuDefaultRoot%M_Index%[1],Add,%mcItem%,Menu_Run
			Menu,% menuWebRoot%M_Index%[1],Add,%mcItem%,Menu_Run
			Menu,% menuFileRoot%M_Index%[1],Add,%mcItem%,Menu_Run
			fullpath:=Get_Obj_Path(MenuObj[mcItem])
			SplitPath,fullpath, , , ext
			if(ext="exe"){
				Menu_Item_Icon(menuDefaultRoot%M_Index%[1],mcItem,fullpath)
				Menu_Item_Icon(menuWebRoot%M_Index%[1],mcItem,fullpath)
				Menu_Item_Icon(menuFileRoot%M_Index%[1],mcItem,fullpath)
			}else{
				recentItemMode:=Get_Menu_Item_Mode(MenuObj[mcItem])
				Menu_Add(menuDefaultRoot%M_Index%[1],mcItem,MenuObj[mcItem],recentItemMode,"")
				Menu_Add(menuWebRoot%M_Index%[1],mcItem,MenuObj[mcItem],recentItemMode,"")
				Menu_Add(menuFileRoot%M_Index%[1],mcItem,MenuObj[mcItem],recentItemMode,"")
			}
		}
	}
}
;~;[18.内部关联后缀打开方式]
Gosub,Open_Ext_Set

Menu_Tray_Tip("","菜单已经可以正常使用`n开始为菜单中exe程序加载图标...")
;~;[19.菜单中EXE程序加载图标，有ico图标更快]
For k, v in MenuExeIconArray
{
	if(DisableExeIcon){
		Menu_Item_Icon(v["menuName"],v["menuItem"],EXEIconS[1],EXEIconS[2])
	}else{
		Menu_Item_Icon(v["menuName"],v["menuItem"],v["itemFile"])
	}
}
For k, v in MenuExeArray
{
	if(DisableExeIcon){
		Menu_Item_Icon(v["menuName"],v["menuItem"],EXEIconS[1],EXEIconS[2])
	}else{
		Menu_Item_Icon(v["menuName"],v["menuItem"],v["itemFile"])
	}
}
;-------------------------------------------------------------------------------------------
;~;[20.菜单已经加载完毕，托盘图标变化]
if(EvNo || EvQueryFlag || EvCommandStr="")
	try Menu,Tray,Icon,% AnyIconS[1],% AnyIconS[2]
t6:=A_TickCount-StartTick
Menu_Tray_Tip("菜单中exe加载图标：" Round((t6-t5)/1000,3) "s`n","总加载时间：" Round(t6/1000,3) "s")
MenuIconFlag:=true

;#如果是第一次运行#
if(iniFlag){
	iniFlag:=false
	TrayTip,,RunAny菜单初始化完成`n右击任务栏图标设置,3,1
	gosub,Menu_About
	gosub,Menu_Show1
}
;提前加载菜单树图标缓存
Gosub,Plugins_LV_Icon_Set
global TreeImageListID := IL_Create(11)
Icon_Image_Set(TreeImageListID)
Icon_Tree_Image_Set(TreeImageListID)
;如果有需要继续执行的操作
RegRead, ReloadGosub, HKEY_CURRENT_USER, Software\RunAny, ReloadGosub
if(ReloadGosub){
	RegWrite, REG_SZ, HKEY_CURRENT_USER, SOFTWARE\RunAny, ReloadGosub, 0
	gosub,%ReloadGosub%
}
;自动备份配置文件
if(RunABackupRule && RunABackupDirPath!=A_ScriptDir){
	RunABackupFormatStr:=Get_Transform_Val(RunABackupFormat)
	RunABackup(RunABackupDirPath "\", RunAnyZz ".ini*", iniVar1, iniPath, RunAnyZz ".ini" RunABackupFormatStr)
	RunABackup(RunABackupDirPath "\" RunAnyZz "2.ini\", RunAnyZz "2.ini*", iniVar2, iniPath2, RunAnyZz "2.ini" RunABackupFormatStr)
	FileRead, iniVarBak, %RunAnyConfig%
	RunABackup(RunABackupDirPath "\" RunAnyConfig "\", RunAnyConfig "*", iniVarBak, RunAnyConfig, RunAnyConfig RunABackupFormatStr)
}
;~[记录ini文件修改时间]
FileGetTime,MTimeIniPath, %iniPath%, M  ; 获取修改时间.
RegWrite, REG_SZ, HKEY_CURRENT_USER, SOFTWARE\RunAny, %iniPath%, %MTimeIniPath%
if(MENU2FLAG){
	FileGetTime,MTimeIniPath2, %iniPath2%, M  ; 获取修改时间.
	RegWrite, REG_SZ, HKEY_CURRENT_USER, SOFTWARE\RunAny, %iniPath2%, %MTimeIniPath2%
}
if(AutoReloadMTime>0){
	SetTimer,AutoReloadMTime,%AutoReloadMTime%
}
return

;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

;~[菜单项过滤不同内容类型]
Menu_Item_List_Filter(M_Index,MenuTypeList,HideFlag,MenuType:=1){
	if(!HideFlag)
		return
	if(MenuType=1){
		rootName:=menuDefaultRoot%M_Index%[1]
		rootReg:="S)[^\s]+\s$"
	}else if(MenuType=2){
		rootName:=menuWebRoot%M_Index%[1]
		rootReg:="S)[^\s]+\s{2}$"
	}else if(MenuType=3){
		rootName:=menuFileRoot%M_Index%[1]
		rootReg:="S)[^\s]+\s{3}$"
	}
	For mn,items in %MenuTypeList%%M_Index%
	{
		if(mn=rootName || RegExMatch(mn,rootReg)){
			Loop, Parse, items, `n
			{
				if(A_LoopField="")
					continue
				try Menu,%mn%,Delete,%A_LoopField%
			}
			if(InStr(mn,RunAnyZz))
				continue
			if(%MenuTypeList%%M_Index%[mn]=MenuObjList%M_Index%[mn]){
				try Menu,%mn%,Delete
			}
		}
	}
}
;~[菜单节点分类过滤]
Menu_Tree_List_Filter(M_Index,MenuTypeList,MenuType){
	if(MenuType=2){
		TREE_TYPE:="  "
		rootReg:="S)[^\s]+\s{2}$"
	}else if(MenuType=3){
		TREE_TYPE:="   "
		rootReg:="S)[^\s]+\s{3}$"
	}
	For mn,items in MenuObjTree%M_Index%
	{
		if(!RegExMatch(mn,rootReg))
			continue
		delFlag:=true
		For k,v in %MenuTypeList%%M_Index%
		{
			if(mn=v TREE_TYPE || mn=M%M_Index% TREE_TYPE){
				delFlag:=false
				break
			}
		}
		if(delFlag){
			try Menu,%mn%,Delete
		}
	}
}
;~[鼠标悬停在托盘图标上时显示初始化信息]
Menu_Tray_Tip(tText,tmpText:=""){
	MenuTrayTipText.=tText
	Menu,Tray,Tip,% MenuTrayTipText tmpText
	return MenuTrayTipText
}
;~[鼠标悬停在托盘图标上时显示运行路径信息]
Menu_Run_Tray_Tip(tText,tmpText:=""){
	if(Menu_Tray_Tip(tText,tmpText)!=A_IconTip){
		MenuTrayTipText:="运行路径`n" tText tmpText
		Menu,Tray,Tip,%MenuTrayTipText%
	}
}
;~[菜单调试模式下的调试信息]
Menu_Debug_Mode(tText,tmpText:=""){
	if(DebugMode){
		DebugModeShowText.=tText
		if(StrLen(tText)>DebugModeShowTextLen)
			DebugModeShowTextLen:=StrLen(tText)
		CoordMode, ToolTip
		ToolTip,%DebugModeShowText%`n%tmpText%,A_ScreenWidth-DebugModeShowTextLen,0,1
		SetTimer,RemoveDebugModeToolTip,%DebugModeShowTime%
		WinSet, Transparent, % DebugModeShowTrans/100*255, ahk_class tooltips_class32
	}
}
;══════════════════════════════════════════════════════════════════
;~;[多种启动菜单热键]
#If MenuDoubleCtrlKey=1
Ctrl::
	KeyWait,Ctrl
	KeyWait,Ctrl,d,t0.2
	if !Errorlevel
		gosub,Menu_Show1
	return
#If
#If MenuDoubleAltKey=1
Alt::
	KeyWait,Alt
	KeyWait,Alt,d,t0.2
	if !Errorlevel
		gosub,Menu_Show1
	return
#If
#If MenuDoubleLWinKey=1
LWin::
	KeyWait,LWin
	KeyWait,LWin,d,t0.2
	if !Errorlevel
		gosub,Menu_Show1
	else
		SendInput,{LWin}
	return
#If
#If MenuDoubleRWinKey=1
RWin::
	KeyWait,RWin
	KeyWait,RWin,d,t0.2
	if !Errorlevel
		gosub,Menu_Show1
	else
		SendInput,{RWin}
	return
#If
#If MenuCtrlRightKey=1
~Ctrl & RButton::gosub,Menu_Show1
#If
#If MenuShiftRightKey=1
~Shift & RButton::gosub,Menu_Show1
#If
#If MenuXButton1Key=1
XButton1::gosub,Menu_Show1
#If
#If MenuXButton2Key=1
XButton2::gosub,Menu_Show1
#If
#If MenuMButtonKey=1 && !WinActive("ahk_group DisableGUI")
~MButton::gosub,Menu_Show1
#If
AutoReloadMTime:
	RegRead, MTimeIniPathReg, HKEY_CURRENT_USER, Software\RunAny, %iniPath%
	FileGetTime,MTimeIniPath, %iniPath%, M  ; 获取修改时间.
	if(MTimeIniPathReg!=MTimeIniPath){
		gosub,Menu_Reload
	}
	if(MENU2FLAG){
		RegRead, MTimeIniPath2, HKEY_CURRENT_USER, Software\RunAny, %iniPath2%
		FileGetTime,MTimeIniPath2Reg, %iniPath2%, M  ; 获取修改时间.
		if(MTimeIniPath2!=MTimeIniPath2Reg){
			gosub,Menu_Reload
		}
	}
return
;~;[RunAny自动备份配置文件]
RunABackup(RunABackupDir,RunABackupFile,RunABackupFileContent,RunABackupFileCopy,RunABackupFileTarget){
	ConfigBackupNum:=0
	ConfigBackupFlag:=true
	Loop,%RunABackupDir%%RunABackupFile%
	{
		FileRead, iniVarBak, %A_LoopFileFullPath%
		if(RunABackupFileContent=iniVarBak){
			ConfigBackupFlag:=false
		}
		ConfigBackupNum++
	}
	if(ConfigBackupFlag){
		FileCopy, %RunABackupFileCopy%, %RunABackupDir%%RunABackupFileTarget%, 1
	}
	if(ConfigBackupNum>RunABackupMax){
		RunABackupClear(RunABackupDir,RunABackupFile)
	}
}
RunABackupClear(RunABackupDir,RunABackupFile){
	if(RunABackupMax>0){
		oldFile:=A_Now
		Loop,%RunABackupDir%%RunABackupFile%
		{
			if(oldFile>A_LoopFileTimeCreated){
				oldFile:=A_LoopFileTimeCreated
				oldPath:=A_LoopFileLongPath
			}
		}
		if(RegExMatch(oldPath, "iS).*?\.bak$")){
			FileDelete, %oldPath%
		}
	}
}
;══════════════════════════════════════════════════════════════════
;~;【读取配置并开始创建菜单】
;══════════════════════════════════════════════════════════════════
Menu_Read(iniReadVar,menuRootFn,TREE_TYPE,TREE_NO){
	MenuObjName:=Object()	;~程序菜单项名称
	MenuBar:=""				;~菜单分列标记
	MenuObjParam:=Object()         ;~程序参数
	menuLevel:=1
	Loop, parse, iniReadVar, `n, `r
	{
		try{
			Z_LoopField=%A_LoopField%
			if(InStr(Z_LoopField,";")=1 || Z_LoopField=""){
				continue
			}
			TREE_TYPE_FLAG:=(TREE_TYPE="" || TREE_TYPE="    ")
			;~;[生成节点树层级结构]
			if(InStr(Z_LoopField,"-")=1){
				menuItem:=RegExReplace(Z_LoopField,"S)^-+")
				treeLevel:=RegExReplace(Z_LoopField,"S)(^-+).*","$1")
				menuLevel:=StrLen(treeLevel)
				if(InStr(menuItem,"|")){
					menuItems:=StrSplit(menuItem,"|",,2)
					menuItem:=menuItems[1]
					;[读取菜单关联后缀][不重复]
					if(TREE_TYPE=""){
						Loop, parse,% menuItems[2],%A_Space%
						{
							;选中文件后显示的公共后缀菜单
							if(A_LoopField="public"){
								MenuObjPublic.Push(treeLevel . menuItem)
							}else if(A_LoopField="text"){
								MenuObjText%TREE_NO%.Push(menuItem)
							}else if(A_LoopField="file"){
								MenuObjFile%TREE_NO%.Push(menuItem)
							}else if(RegExMatch(A_LoopField,"iS).+\.exe$")){
								global MenuObjWindowFlag:=true
								MenuObjWindow[(A_LoopField)]:=menuItem
							}else{
								MenuObjExt[(A_LoopField)]:=menuItem
							}
						}
					}
				}
				if(menuItem!=""){
					menuItemType:=menuItem . TREE_TYPE
					Menu,%menuItemType%,add
					try Menu,% menuRootFn[menuLevel],add,%menuItemType%,:%menuItemType%,%MenuBar%
					Menu_Item_Icon(menuRootFn[menuLevel],menuItemType,TreeIconS[1],TreeIconS[2],treeLevel . menuItemType)
					Menu,%menuItemType%,Delete, 1&
					menuLevel+=1	;比初始根菜单加一级
					menuRootFn[menuLevel]:=menuItemType		;从这之后内容项都添加到该级别菜单中
					
					;记录全局菜单数据
					if(!IsObject(MenuObjTree%TREE_NO%[menuItemType]))
						MenuObjTree%TREE_NO%[menuItemType]:=Object()
					MenuObjTreeLevel[menuItemType]:=treeLevel
					
					;[分割Tab获取菜单自定义热键][不重复]
					if(TREE_TYPE_FLAG && InStr(menuItem,"`t")){
						menuKeyStr:=RegExReplace(menuItem, "S)\t+", A_Tab)
						menuKeys:=StrSplit(menuKeyStr,"`t")
						if(menuKeys[2]){
							MenuTreeKey[menuKeys[2]]:=menuItemType
							Hotkey,% menuKeys[2],Menu_Key_Show,On
						}
					}
				}else if(menuRootFn[menuLevel]){	;[添加分隔符]
					menuRootFnLevel:=menuRootFn[menuLevel]
					Menu,%menuRootFnLevel%,Add
					MenuObjTree%TREE_NO%[menuRootFnLevel].Push(Z_LoopField)
				}
				MenuBar:=""
				continue
			}
			if(Z_LoopField="|" || Z_LoopField="||"){
				MenuBar:=(Z_LoopField="||") ? "+BarBreak" : "+Break"
				continue
			}
			if(menuRootFn[menuLevel]="")
				continue
			
			itemMode:=Get_Menu_Item_Mode(Z_LoopField,true)
			if(TREE_TYPE="" && itemMode=60 && RegExMatch(Z_LoopField,"iS).*?%s[^%]*$")){
				MsgBox,48,请修改菜单项 `%s不能识别,% "菜单项：" Get_Obj_Transform_Name(Z_LoopField) 
					. "`n里面的`%s 仅支持在纯网址模式，`n在参数中请替换使用%getZz%表示选中文字"
			}
			;短语、网址、脚本插件函数除外的菜单项直接转换%%为系统变量值
			transformValFlag:=false
			if(itemMode!=2 && itemMode!=3 && itemMode!=6 && itemMode!=8){
				Z_LoopField:=StrReplace(Z_LoopField,"%getZz%",Chr(3))
				Z_LoopField:=StrReplace(Z_LoopField,"%Clipboard%",Chr(4))
				Z_LoopField:=StrReplace(Z_LoopField,"%ClipboardAll%",Chr(5))
				Z_LoopField:=Get_Transform_Val(Z_LoopField)
				Z_LoopField:=StrReplace(Z_LoopField,Chr(3),"%getZz%")
				Z_LoopField:=StrReplace(Z_LoopField,Chr(4),"%Clipboard%")
				Z_LoopField:=StrReplace(Z_LoopField,Chr(5),"%ClipboardAll%")
				transformValFlag:=true
			}
			itemMode:=Get_Menu_Item_Mode(Z_LoopField,true)
			;~添加到分类目录程序全数据
			if(!IsObject(MenuObjTree%TREE_NO%[(menuRootFn[menuLevel])]))
				MenuObjTree%TREE_NO%[(menuRootFn[menuLevel])]:=Object()
			MenuObjTree%TREE_NO%[(menuRootFn[menuLevel])].Push(Z_LoopField)
			flagEXE:=false			;~添加exe菜单项目
			flagSys:=false			;~添加系统项目文件
			IconFail:=false		;~是否显示无效项图标
			;~;[生成有前缀备注的应用]
			if(InStr(Z_LoopField,"|")){
				menuDiy:=StrSplit(Z_LoopField,"|",,2)
				menuItemDiy:=menuDiy[1]
				appName:=RegExReplace(menuDiy[2],"iS)(.*?\.[a-zA-Z0-9]+)($| .*)","$1")	;去掉参数，取应用名
				appName:=RegExReplace(appName,"iS)\.exe$")	;去掉exe后缀，取应用名
				;[分割Tab获取应用自定义热键]
				menuKeyStr:=RegExReplace(menuDiy[1], "S)\t+", A_Tab)
				menuKeys:=StrSplit(menuKeyStr,"`t",,2)
				if(MenuObjName.HasKey(menuItemDiy) || MenuObjParam.HasKey(menuItemDiy)){
					if(menuKeys[2]){
						menuItemDiy:=menuKeys[1] "重名" A_Tab menuKeys[2]
					}else{
						menuItemDiy.="重名"
					}
				}
				itemContent:=MenuObjEv[appName]
				if(itemContent){
					SplitPath, itemContent,,, FileExt  ; 获取文件扩展名.
					appParm:=RegExReplace(menuDiy[2],"iS).*?\." FileExt "($| .*)","$1")	;去掉应用名，取参数
					;非exe后缀的菜单项名与无路径exe的名称相同，则自动在菜单项名末尾添加后缀标记
					if(FileExt!="exe" && appName!=menuItemDiy && MenuObjEv[menuItemDiy]){
						menuItemDiy.="." FileExt
					}
					MenuObjParam[menuItemDiy]:=itemContent . appParm
					itemParam:=itemContent . appParm
					flagEXE:=true
				}else{
					itemContent:=menuDiy[2]
					itemParam:=menuDiy[2]
					if(transformValFlag && RegExMatch(itemContent,"iS).*?\.(exe|lnk|bat|cmd|vbs|ps1|ahk) .*"))
						itemContent:=RegExReplace(itemContent,"iS)(.*?\.(exe|lnk|bat|cmd|vbs|ps1|ahk)) .*","$1")	;只去参数
					SplitPath, itemContent,,, FileExt  ; 获取文件扩展名.
					;~;如果是有效全路径或系统程序则保留显示
					if(RegExMatch(itemContent,"iS)^(\\\\|.:\\).*?\.(exe|lnk|bat|cmd|vbs|ps1|ahk)$") && FileExist(itemContent)){
						flagEXE:=true
					}else if(FileExist(A_WinDir "\" itemContent) || FileExist(A_WinDir "\system32\" itemContent)){
						flagEXE:=true
						if(FileExt!="exe"){
							flagSys:=true
							flagSysPath:=FileExist(A_WinDir "\" itemContent) ? A_WinDir "\" itemContent : ""
							if(flagSysPath="" && FileExist(A_WinDir "\system32\" itemContent))
								flagSysPath:=A_WinDir "\system32\" itemContent
						}
					}
					;~;如果是有效程序、不隐藏失效、不是exe程序则添加该菜单项功能
					if(FileExt!="exe"){
						MenuObj[menuItemDiy]:=menuDiy[2]
					}else if(flagEXE || !HideFail){
						MenuObjParam[menuItemDiy]:=menuDiy[2]
					}
				}
				if(FileExt="exe"){
					if(flagEXE){
						MenuExeArrayPush(menuRootFn[menuLevel],menuItemDiy,itemContent,menuDiy[2],TREE_NO)
					}else{
						IconFail:=true
					}
					if(!HideFail)
						flagEXE:=true
					;添加菜单项
					if(flagEXE){
						Menu,% menuRootFn[menuLevel],add,% menuItemDiy,Menu_Run,%MenuBar%
						if(IconFail)
							Menu_Item_Icon(menuRootFn[menuLevel],menuItemDiy,"SHELL32.dll","124")
					}
				}else if FileExt in lnk,bat,cmd,vbs,ps1,ahk
				{
					Menu_Add(menuRootFn[menuLevel],menuItemDiy,itemContent,itemMode,TREE_NO)
				}else if(flagSys){
					Menu_Add(menuRootFn[menuLevel],menuItemDiy,flagSysPath="" ? itemContent : flagSysPath,itemMode,TREE_NO)
				}else{
					Menu_Add(menuRootFn[menuLevel],menuItemDiy,itemParam,itemMode,TREE_NO)
				}
				;[设置热键启动方式][不重复]
				if(TREE_TYPE_FLAG && InStr(menuDiy[1],"`t") && menuKeys[2]){
					MenuObj[menuKeys[1]]:=itemParam
					MenuObjKey[menuKeys[2]]:=itemParam
					MenuObjKeyName[menuKeys[2]]:=menuKeys[1]
					if(!InStr(menuDiy[2],"%getZz%") && RegExMatch(menuDiy[2],"iS).+?\[.+?\]%?\(.*?\)")){
						Hotkey,% menuKeys[2],Menu_Key_NoGet_Run,On
					}else if(itemMode=4 || itemMode=5){ ;热键映射不去获取当前选中内容
						Hotkey,% menuKeys[2],Menu_Key_NoGet_Run,On
					}else{
						Hotkey,% menuKeys[2],Menu_Key_Run,On
					}
				}
				;[设置热字符串启动方式][不重复]
				if(TREE_TYPE="" && RegExMatch(menuKeys[1],"S):[*?a-zA-Z0-9]+?:[^:]*")){
					hotStrName:=menuKeys[1]
					if(RegExMatch(hotStrName,"S).*_:\d{1,2}$"))
						hotStrName:=RegExReplace(hotStrName,"S)(.*)_:\d{1,2}$","$1")
					hotstr:=RegExReplace(hotStrName,"S)^[^:]*?(:[*?a-zA-Z0-9]+?:[^:]*)","$1")
					hotStrName:=RegExReplace(hotStrName,"S)^([^:]*?):[*?a-zA-Z0-9]+?:[^:]*","$1")
					if(hotstr){
						MenuObjKey[hotstr]:=itemParam
						MenuObjKeyName[hotstr]:=menuKeys[1]
						if(RegExMatch(hotstr,"S):[^:]*?X[^:]*?:[^:]*")){
							;热字符串运行不传递选中内容：不带%getZz%的运行项、不带%getZz%或%s的网址
							if(itemMode=6 && !InStr(menuDiy[2],"%getZz%") && !InStr(menuDiy[2],"%s")){
								Hotstring(hotstr,"Menu_Key_NoGet_Run","On")
							}else if(!InStr(menuDiy[2],"%getZz%")){
								Hotstring(hotstr,"Menu_Key_NoGet_Run","On")
							}else{
								Hotstring(hotstr,"Menu_Key_Run","On")
							}
							if(!HideHotStr)
								Menu_HotStr_Hint_Read(hotstr,hotStrName,itemParam)
						}else{
							Hotstring(hotstr,itemParam,"On")
						}
					}
				}
				MenuBar:=""
				continue
			}
			;~;[生成完全路径的应用]
			if(RegExMatch(Z_LoopField,"iS)^(\\\\|.:\\).*?\.exe($| .*)")){
				appParm:=RegExReplace(Z_LoopField,"iS).*?\.exe($| .*)","$1")	;去掉应用名，取参数
				Z_LoopField:=RegExReplace(Z_LoopField,"iS)(.*?\.exe)($| .*)","$1")
				SplitPath,Z_LoopField,fileName,,,nameNotExt
				menuAppName:=appParm!="" ? nameNotExt A_Space : nameNotExt
				MenuObjParam[menuAppName]:=Z_LoopField . appParm
				if(FileExist(Z_LoopField)){
					MenuExeArrayPush(menuRootFn[menuLevel],menuAppName,Z_LoopField,Z_LoopField . appParm,TREE_NO)
					flagEXE:=true
				}else{
					IconFail:=true
				}
				if(!HideFail)
					flagEXE:=true
				;添加菜单项
				if(flagEXE){
					Menu,% menuRootFn[menuLevel],add,% menuAppName,Menu_Run,%MenuBar%
					if(IconFail){
						Menu_Item_Icon(menuRootFn[menuLevel],menuAppName,"SHELL32.dll","124")
					}
				}
				MenuBar:=""
				continue
			}
			;~;[生成通过Everything取到的无路径应用]
			if(RegExMatch(Z_LoopField,"iS)\.exe($| .*)")){
				appParm:=RegExReplace(Z_LoopField,"iS).*?\.exe($| .*)","$1")	;去掉应用名，取参数
				Z_LoopField:=RegExReplace(Z_LoopField,"iS)(.*?\.exe)($| .*)","$1")
				appName:=RegExReplace(Z_LoopField,"iS)\.exe$")
				menuAppName:=appParm!="" ? appName A_Space A_Space : appName
				if(MenuObjEv[appName]){
					flagEXE:=true
					MenuObj[menuAppName]:=MenuObjEv[appName]
					MenuObjParam[menuAppName]:=MenuObjEv[appName] . appParm
				}else if(FileExist(A_WinDir "\" Z_LoopField) || FileExist(A_WinDir "\system32\" Z_LoopField)){
					flagEXE:=true
					MenuObj[menuAppName]:=Z_LoopField
					MenuObjParam[menuAppName]:=Z_LoopField . appParm
				}else if(!HideFail){
					MenuObj[menuAppName]:=Z_LoopField
					MenuObjParam[menuAppName]:=Z_LoopField . appParm
				}
				if(flagEXE){
					MenuExeArrayPush(menuRootFn[menuLevel],menuAppName,MenuObj[menuAppName],MenuObj[menuAppName] . appParm,TREE_NO)
				}else{
					IconFail:=true
				}
				if(!HideFail)
					flagEXE:=true
				;添加菜单项
				if(flagEXE){
					Menu,% menuRootFn[menuLevel],add,% menuAppName,Menu_Run,%MenuBar%
					if(IconFail)
						Menu_Item_Icon(menuRootFn[menuLevel],menuAppName,"SHELL32.dll","124")
				}
			}else{
				if(!MenuObjEv[Z_LoopField])
					MenuObj[Z_LoopField]:=Z_LoopField
				else
					MenuObj[Z_LoopField]:=MenuObjEv[Z_LoopField]
				Menu_Add(menuRootFn[menuLevel],Z_LoopField,MenuObj[Z_LoopField],itemMode,TREE_NO)
			}
			MenuBar:=""
		} catch e {
			MsgBox,16,构建菜单出错,% "菜单名：" menuRootFn[menuLevel] "`n菜单项：" A_LoopField 
				. "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
		}
	}
	For key, value in MenuObjParam
	{
		MenuObj[key]:=value
	}
	if(!HideMenuTray){
		Menu,% menuRootFn[1],add,%RUNANY_SELF_MENU_ITEM2%,:Tray,%MenuBar%
		Menu,% menuRootFn[1],Icon,%RUNANY_SELF_MENU_ITEM2%,% AnyIconS[1],% AnyIconS[2],%MenuIconSize%
	}
}
;~;[统一集合菜单中软件运行项]
MenuExeArrayPush(menuName,menuItem,itemFile,itemAny,TREE_NO){
	MenuObjEXE:=Object()	;~软件对象
	MenuObjEXE["menuName"]:=menuName
	MenuObjEXE["menuItem"]:=menuItem
	MenuObjEXE["itemFile"]:=itemFile
	;~ MenuObjEXE["itemAny"]:=itemAny
	if(RegExMatch(menuName,"S)[^\s]+$")){
		MenuExeArray.Push(MenuObjEXE)
	}else{
		MenuExeIconArray.Push(MenuObjEXE)
		if(!InStr(itemAny,"%getZz%"))
			MenuExeList%TREE_NO%[menuName].=menuItem "`n"
	}
}
;~;[读取热字串用作提示文字]
Menu_HotStr_Hint_Read(hotstr,hotStrName,itemParam){
	menuHotStrShow:=RegExReplace(hotstr,"^:[^:]*?X[^:]*?:")
	menuHotStrLen:=StrLen(menuHotStrShow)
	HotStrHintLenVal:=HotStrHintLen>1 ? HotStrHintLen : 1
	if(menuHotStrLen=0)
		return
	if(menuHotStrLen=1){
		menuHotStrHint:=menuHotStrShow
	}else if(menuHotStrLen<=HotStrHintLenVal){ ;总长度小于4在减1长度时提示
		menuHotStrHint:=SubStr(menuHotStrShow, 1, menuHotStrLen-1)
	}else{
		loop, % menuHotStrLen - HotStrHintLenVal
		{
			MenuObjHotStr:=Object()	;热字符对象
			menuHotStrHint:=SubStr(menuHotStrShow, 1, A_Index + HotStrHintLenVal-1)
			MenuObjHotStr["hotStrAny"]:=itemParam
			MenuObjHotStr["hotStrHint"]:=menuHotStrHint
			MenuObjHotStr["hotStrShow"]:=menuHotStrShow
			MenuObjHotStr["hotStrName"]:=hotStrName
			MenuHotStrList.Push(MenuObjHotStr)
			Hotstring(":*Xb0:" . menuHotStrHint,"Menu_HotStr_Hint_Run","On")
		}
		return
	}
	MenuObjHotStr:=Object()	;热字符对象
	MenuObjHotStr["hotStrAny"]:=itemParam
	MenuObjHotStr["hotStrHint"]:=menuHotStrHint
	MenuObjHotStr["hotStrShow"]:=menuHotStrShow
	MenuObjHotStr["hotStrName"]:=hotStrName
	MenuHotStrList.Push(MenuObjHotStr)
	Hotstring(":*Xb0:" . menuHotStrHint,"Menu_HotStr_Hint_Run","On")
}
Menu_HotStr_Hint_Run:
	runHotStrHint:=RegExReplace(A_ThisHotkey,"^:[^:]*?Xb0:")
	HintTip:=""
	for k , v in MenuHotStrList
	{
		if(v["hotStrHint"]=runHotStrHint){
			hotStrName:=v["hotStrName"]!=""?"`t" v["hotStrName"]:""
			if(HotStrShowLen<=0){
				hotStrAny:=""
			}else if(StrLen(v["hotStrAny"])>HotStrShowLen){
				hotStrAny:="`t" SubStr(v["hotStrAny"], 1, HotStrShowLen) . "..."
			}else{
				hotStrAny:="`t" v["hotStrAny"]
			}
			HintTip.=v["hotStrShow"] hotStrName hotStrAny "`n"
		}
	}
	HintTip:=RTrim(HintTip,"`n")
	MouseGetPos, MouseX, MouseY
	if(HotStrShowX=0 && HotStrShowY=0)
		ToolTip,%HintTip%
	else
		ToolTip,%HintTip%,% MouseX+HotStrShowX,% MouseY+HotStrShowY
	Sleep,100
	WinSet, Transparent, % HotStrShowTransparent/100*255, ahk_class tooltips_class32
	SetTimer,RemoveToolTip,%HotStrShowTime%
return
;══════════════════════════════════════════════════════════════════
;~;【生成菜单(判断后缀创建图标)】
;══════════════════════════════════════════════════════════════════
Menu_Add(menuName,menuItem,itemContent,itemMode,TREE_NO){
	if(!menuName || !itemContent)
		return
	try {
		SplitPath, itemContent,,, FileExt  ; 获取文件扩展名.
		Menu,%menuName%,add,%menuItem%,Menu_Run,%MenuBar%
		MenuBar:=""
		MenuObjList%TREE_NO%[menuName].=menuItem "`n"
		if(itemMode=2 || itemMode=3){  ; {短语}
			Menu_Item_Icon(menuName,menuItem,"SHELL32.dll",itemMode=3 ? "2" : "71")
			MenuSendStrList%TREE_NO%[menuName].=menuItem "`n"
			return
		}
		if(itemMode=4 || itemMode=5){	; {发送热键}
			Menu_Item_Icon(menuName,menuItem,"SHELL32.dll",itemMode=5 ? "101" : "100")
			return
		}
		if(itemMode=6){  ; {网址}
			website:=RegExReplace(itemContent,"iS)[\w-]+://?((\w+\.)+\w+).*","$1")
			webIcon:=RunIconDir "\" website ".ico"
			webIconNum:=0
			if(!FileExist(webIcon)){
				webIcon:=UrlIconS[1]
				webIconNum:=UrlIconS[2]
			}
			Menu_Item_Icon(menuName,menuItem,webIcon,webIconNum)
			if(InStr(itemContent,"%s") || InStr(itemContent,"%getZz%"))
				MenuWebList%TREE_NO%[menuName].=menuItem "`n"
			return
		}
		if(itemMode=8){  ; {脚本插件函数}
			Menu_Item_Icon(menuName,menuItem,FuncIconS[1],FuncIconS[2])
			if(InStr(itemContent,"%getZz%")){
				MenuGetZzList%TREE_NO%[menuName].=menuItem "`n"	; 添加到GetZz搜索
			}
			return
		}
		if(itemMode=7){  ; {目录}
			Menu,%menuName%,Icon,%menuItem%,% FolderIconS[1],% FolderIconS[2],%MenuIconSize%
		}else if(FileExt="lnk"){  ; {快捷方式}
			try{
				FileGetShortcut, %itemContent%, OutItem, , , , OutIcon, OutIconNum
				if(!OutIcon){
					OutIcon:=OutItem
					OutIconNum:=0
				}
				Menu_Item_Icon(menuName,menuItem,OutIcon,OutIconNum)
			} catch e {
				if(!HideFail){
					Menu_Item_Icon(menuName,menuItem,LNKIconS[1],LNKIconS[2])
				}else{
					Menu,%menuName%,Delete,%menuItem%
				}
			}
		}else{  ; {处理未知的项目图标}
			If(FileExt && FileExist(itemContent)){
				try{
					RegRead, regFileExt, HKEY_CLASSES_ROOT, .%FileExt%
					RegRead, regFileIcon, HKEY_CLASSES_ROOT, %regFileExt%\DefaultIcon
					regFileIconS:=StrSplit(regFileIcon,",")
					Menu_Item_Icon(menuName,menuItem,regFileIconS[1],regFileIconS[2])
				}catch{}
			}else if(!HideFail){
				Menu_Item_Icon(menuName,menuItem,"SHELL32.dll","124")
			}else{
				Menu,%menuName%,Delete,%menuItem%
			}
		}
	} catch e {
		MsgBox,16,判断后缀创建菜单项出错,% "菜单名：" menuName "`n菜单项：" menuItem 
			. "`n路径：" itemContent "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
	}
}
;~;[统一设置菜单项图标]
Menu_Item_Icon(menuName,menuItem,iconPath,iconNo=0,treeLevel=""){
	try{
		menuItemSet:=treeLevel ? treeLevel : menuItem
		menuItemSet:=RTrim(menuItemSet)
		menuItemSet:=menuItemIconFileName(menuItemSet)
		if(IconFolderList[menuItemSet]){
			Menu,%menuName%,Icon,%menuItem%,% IconFolderList[menuItemSet],0,%MenuIconSize%
			MenuItemIconList[menuItem]:=IconFolderList[menuItemSet]
			MenuItemIconNoList[menuItem]:=0
		}else{
			Menu,%menuName%,Icon,%menuItem%,%iconPath%,%iconNo%,%MenuIconSize%
			MenuItemIconList[menuItem]:=iconPath
			MenuItemIconNoList[menuItem]:=iconNo
		}
		MenuObjName[menuItemSet]:=1
	}catch{}
}
Menu_Show1:
	MENU_NO:=1
	iniFileShow:=iniPath
	gosub,Menu_Show
return
Menu_Show2:
	MENU_NO:=2
	iniFileShow:=iniPath2
	gosub,Menu_Show
return
Menu_NoGet_Show:
	MENU_NO:=1
	iniFileShow:=iniPath
	noGetZz:=true
	getZz:=""
	gosub,Menu_Show
	noGetZz:=false
return
MenuShowTime:
	MenuShowTimeFlag:=true
	if(MenuShowFlag){
		SetTimer,MenuShowTime,Off
		gosub,Menu_Show
	}
return
;══════════════════════════════════════════════════════════════════
;~;【——显示菜单——】
;══════════════════════════════════════════════════════════════════
Menu_Show:
	try{
		if(!MenuShowFlag && !MenuShowTimeFlag){
			SetTimer,MenuShowTime,20
			return
		}
		if(!extMenuHideFlag && !noGetZz)
			getZz:=Get_Zz()
		selectCheck:=Trim(getZz," `t`n`r")
		if(selectCheck=""){
			;#无选中内容
			;加载顺序：无Everything菜单 -> 无图标菜单 -> 有图标无路径识别菜单
			if(MenuIconFlag && MenuShowFlag){
				WinGet,name,ProcessName,A
				if(MenuObjWindowFlag && MenuObjWindow[name]){
					Menu_Show_Show(MenuObjWindow[name],"")
				}else{
					Menu,% menuDefaultRoot%MENU_NO%[1],Show
				}
			}else{
				Menu,% menuRoot%MENU_NO%[1],Show
			}
			return
		}
		getZz:=Get_Transform_Val(getZz)
		if(Candy_isFile){
			SplitPath, getZz,FileName,, FileExt  ; 获取文件扩展名.
			if(InStr(FileExist(getZz), "D")){  ; {目录}
				FileExt:="folder"
			}
			try{
				extMenuName:=MenuObjExt[FileExt]
				if(MENU_NO=1 && extMenuName && !extMenuHideFlag){
					if(MenuObjTree%MENU_NO%[extMenuName].MaxIndex()=1){
						itemContent:=MenuObjTree%MENU_NO%[extMenuName][1]
						MenuShowMenuRun:=Get_Obj_Transform_Name(itemContent)
						gosub,Menu_Run
					}else{
						if(!HideAddItem){
							Menu,%extMenuName%,Insert, ,%RUNANY_SELF_MENU_ITEM3%,Menu_Add_File_Item
							Menu,%extMenuName%,Default,%RUNANY_SELF_MENU_ITEM3%
							Menu,%extMenuName%,Icon,%RUNANY_SELF_MENU_ITEM3%,SHELL32.dll,166,%MenuIconSize%
						}
						;添加后缀公共菜单
						publicMenuMaxNum:=MenuObjExt["public"].MaxIndex()
						if(publicMenuMaxNum>0){
							Loop {
								v:=MenuObjExt["public"][publicMenuMaxNum]
								vn:=RegExReplace(v,"S)^-+")
								Menu,%extMenuName%,Insert, 1&, %vn%, :%vn%
								Menu_Item_Icon(extMenuName,vn,TreeIconS[1],TreeIconS[2],v)
								publicMenuMaxNum--
							} Until % publicMenuMaxNum<1
							publicMaxNum:=MenuObjExt["public"].MaxIndex() + 1
							Menu,%extMenuName%,Insert, %publicMaxNum%&
						}
						;[显示自定义后缀菜单]
						Menu_Show_Show(extMenuName,FileName)
						;删除临时添加的菜单
						if(MenuObjExt["public"].MaxIndex()>0){
							Menu,%extMenuName%,Delete, %publicMaxNum%&
							for k,v in MenuObjExt["public"]
							{
								vn:=RegExReplace(v,"S)^-+")
								Menu,%extMenuName%,Delete,%vn%
							}
						}
						if(!HideAddItem)
							Menu,%extMenuName%,Delete,%RUNANY_SELF_MENU_ITEM3%
					}
				}else{
					if(!HideAddItem){
						Menu_Add_Del_Temp(1,MENU_NO,RUNANY_SELF_MENU_ITEM3,"Menu_Add_File_Item","SHELL32.dll","166")
						if(!MenuObjTree%MENU_NO%[M%MENU_NO% "   "]){
							;如果根目录下没有程序时
							Menu,% M%MENU_NO% "   ",Insert, ,%RUNANY_SELF_MENU_ITEM3%,Menu_Add_File_Item
							Menu,% M%MENU_NO% "   ",Icon,%RUNANY_SELF_MENU_ITEM3%,SHELL32.dll,166,%MenuIconSize%
						}
						try Menu,% menuFileRoot%MENU_NO%[1],Default,%RUNANY_SELF_MENU_ITEM3%
					}
					Menu_Show_Show(menuFileRoot%MENU_NO%[1],FileName)
					if(!HideAddItem){
						try Menu,% menuFileRoot%MENU_NO%[1],Delete,%RUNANY_SELF_MENU_ITEM3%
						Menu_Add_Del_Temp(0,MENU_NO,RUNANY_SELF_MENU_ITEM3)
					}
				}
			}catch e{
				TrayTip,,% "[显示菜单]：" any "`n出错命令：" e.What 
			. "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message,5,1
				Menu_Show_Show(menuFileRoot%MENU_NO%[1],FileName)
			}
			return
		}
		if(MENU_NO=1){
			openFlag:=false
			calcFlag:=false
			notCalcFlag:=false
			calcResult:=""
			selectResult:=""
			Loop, parse, getZz, `n, `r
			{
				S_LoopField=%A_LoopField%
				if(S_LoopField=""){
					if(calcResult)
						calcResult.=A_LoopField "`n"
					if(selectResult)
						selectResult.=A_LoopField "`n"
					continue
				}
				;一键计算公式数字加减乘除
				if(RegExMatch(S_LoopField,"S)^[\(\)\.\s\d]*\d+\s*[+*/-]+[\(\)\.+*/-\d\s]+($|=$)")){
					formula:=S_LoopField
					if(RegExMatch(S_LoopField,"S)^[\(\)\.\s\d]*\d+\s*[+*/-]+[\(\)\.+*/-\d\s]+=$")){
						StringTrimRight, formula, formula, 1
					}
					calc:=js_eval(formula)
					selectResult.=A_LoopField
					if(RegExMatch(S_LoopField,"S)^[\(\)\.\s\d]*\d+\s*[+*/-]+[\(\)\.+*/-\d\s]+=$")){
						calcFlag:=true
						selectResult.=calc
					}else{
						calcResult.=calc "`n"
					}
					selectResult.="`n"
					if(!notCalcFlag)
						openFlag:=true
					continue
				}else{
					notCalcFlag:=true
				}
				;一键打开网址
				if(OneKeyWeb && RegExMatch(S_LoopField,"iS)^([\w-]+://?|www[.]).*")){
					Run_Search(S_LoopField,"",BrowserPathRun)
					openFlag:=true
					continue
				}
				;一键磁力下载
				if(OneKeyMagnet && InStr(S_LoopField,"magnet:?xt=urn:btih:")=1){
					Run,%S_LoopField%
					openFlag:=true
					continue
				}
				if(RegExMatch(S_LoopField,"S)^(\\\\|.:\\)")){
					;一键打开目录
					if(OneKeyFolder && InStr(FileExist(S_LoopField), "D")){
						If(OpenFolderPathRun){
							Run,%OpenFolderPathRun%%A_Space%"%S_LoopField%"
						}else{
							Run,%S_LoopField%
						}
						openFlag:=true
						continue
					}
					;一键打开文件
					if(OneKeyFile && FileExist(S_LoopField)){
						Run,%S_LoopField%
						openFlag:=true
						continue
					}
				}
				;一键注册表路径
				regKeyName:="HKEY_CLASSES_ROOT|HKEY_CURRENT_USER|HKEY_LOCAL_MACHINE|HKEY_USERS|HKEY_CURRENT_CONFIG|"
				regKeyName.="HKCR\\|HKCU\\|HKLM\\|HKU\\|HKCC\\"
				if(OneKeyRegedit && RegExMatch(S_LoopField,"i)^(" regKeyName ").*")){
					if(WinExist("ahk_exe regedit.exe")){
						Process,Close,regedit.exe
					}
					shell:=ComObjCreate("WScript.Shell")
					shell.RegWrite("HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit\LastKey","计算机\" RTrim(S_LoopField,"\"))
					shell.Run("RegEdit.exe")
					openFlag:=true
					continue
				}
			}
			if(calcResult){
				StringTrimRight, calcResult, calcResult, 1
				MouseGetPos, MouseX, MouseY
				ToolTip,%calcResult%,% MouseX-25,% MouseY+5
				Clipboard:=calcResult
				SetTimer,RemoveToolTip,% (calcResult="?") ? 1000 : 3000
			}
			if(calcFlag && !notCalcFlag && selectResult){  ;选中内容多种类型时不输出公式结果
				StringTrimRight, selectResult, selectResult, 1
				Send_Str_Zz(selectResult)
			}
			if(openFlag)
				return
			;#绑定菜单1为一键搜索
			if(OneKeyMenu){
				gosub,One_Search
				return
			}
		}
		;#选中文本弹出网址菜单#
		if(!MenuObjTextRootFlag && MenuObjText%MENU_NO%.MaxIndex()=1){
			;如果根目录没有%getZz%或%s且text菜单只有1个，直接显示这个text菜单
			Menu_Show_Show(MenuObjText%MENU_NO%[1],getZz)
		}else{
			Menu_Show_Show(menuWebRoot%MENU_NO%[1],getZz)
		}
	}catch{}
return
;~;【显示菜单-热键】
Menu_Key_Show:
	getZz:=Get_Zz()
	try {
		Menu_Show_Show(menuTreekey[(A_ThisHotkey)],getZz)
	}catch{}
return
Menu_All_Show:
	Menu_Show_Show(menuDefaultRoot%MENU_NO%[1],getZz)
return
Menu_Show_Show(menuName,itemName){
	selectCheck:=Trim(itemName," `t`n`r")
	if(!HideSelectZz && selectCheck!=""){
		;[选中内容翻译]
		translate:=Menu_Show_Translate(selectCheck)
		if(StrLen(itemName)>ShowGetZzLen)
			itemName:=SubStr(itemName, 1, ShowGetZzLen) . "..."
		Menu,%menuName%,Insert, 1&,%itemName%,Menu_Show_Select_Clipboard
		Menu,%menuName%,ToggleCheck, 1&
		Menu,%menuName%,Insert, 2&
		if(translate!=""){
			Menu,%menuName%,Insert, 3&,%translate%,Menu_Show_Select_Translate,+Radio
			Menu,%menuName%,ToggleCheck, 3&
			Menu,%menuName%,Insert, 4&
		}
	}
	if(menuName!=menuDefaultRoot%MENU_NO%[1]){
		Menu,%menuName%,Insert, ,%RUNANY_SELF_MENU_ITEM4%,Menu_All_Show
		Menu,%menuName%,Icon,%RUNANY_SELF_MENU_ITEM4%,SHELL32.dll,40,%MenuIconSize%
	}
	;[显示菜单]
	Menu,%menuName%,Show
	if(!HideSelectZz && selectCheck!=""){
		if(translate!=""){
			Menu,%menuName%,Delete, 4&
			Menu,%menuName%,Delete, 3&
		}
		Menu,%menuName%,Delete, 2&
		Menu,%menuName%,Delete,%itemName%
	}
	if(menuName!=menuDefaultRoot%MENU_NO%[1]){
		Menu,%menuName%,Delete,%RUNANY_SELF_MENU_ITEM4%
	}
}
Menu_Show_Translate(selectCheck){
	translate:=""
	if(translateFlag && GetZzTranslate && (!GetZzTranslateMenu || GetZzTranslateMenu=MENU_NO)
			&& !RegExMatch(selectCheck,"iS)^([\w-]+://?|www[.]).*")){
		if(GetZzTranslateAuto){
			if(!RegExMatch(selectCheck,"S)[\p{Han}]+")){
				GetZzTranslateTarget:="zh-CN"
			}else if(!RegExMatch(selectCheck,"S)[a-zA-Z]+")){
				GetZzTranslateTarget:="en"
			}else{
				return ""
			}
		}else{
			if(GetZzTranslateSource="en" && !RegExMatch(selectCheck,"S)[a-zA-Z]+"))
				return ""
			if(GetZzTranslateSource="zh-CN" && !RegExMatch(selectCheck,"S)[\p{Han}]+"))
				return ""
		}
		PluginsObjRegActive["huiZz_Text"]:=ComObjActive(PluginsObjRegGUID["huiZz_Text"])
		translate:=PluginsObjRegActive["huiZz_Text"]["runany_google_translate"](selectCheck,GetZzTranslateSource,GetZzTranslateTarget)
		translate:=RegExReplace(translate,"[+].*")
		if(StrLen(translate)>ShowGetZzLen)
			translate:=SubStr(translate, 1, ShowGetZzLen) . "..."
	}
	return translate
}
Menu_Show_Select_Clipboard:
	Clipboard:=Candy_Select
return
Menu_Show_Select_Translate:
	Run,https://translate.google.cn/#%GetZzTranslateSource%/%GetZzTranslateTarget%/%getZz%
return
;~;[所有菜单(添加/删除)临时项]
Menu_Add_Del_Temp(addDel=1,TREE_NO=1,mName="",LabelName="",mIcon="",mIconNum=""){
	if(!mName)
		return
	For mn, vv in MenuObjTree%TREE_NO%
	{
		if(RegExMatch(mn,"S)[^\s]+\s{3}$")){
			if(addDel){
				Menu,%mn%,Insert, ,%mName%,%LabelName%
				Menu,%mn%,Icon,%mName%,%mIcon%,%mIconNum%,%MenuIconSize%
			}else{
				try Menu,%mn%,Delete,%mName%
			}
		}
	}
}
;══════════════════════════════════════════════════════════════════
;~;【——菜单运行——】
;══════════════════════════════════════════════════════════════════
Menu_Run:
	Z_ThisMenuItem:=A_ThisMenuItem
	any:=MenuObj[(Z_ThisMenuItem)]
	if(MenuShowMenuRun){
		any:=MenuObj[(MenuShowMenuRun)]
		if(any="")
			TrayTip,,%MenuShowMenuRun% 没有找到`n请检查是否存在(在Everything能搜索到)，并重启RunAny重试,3,1
		MenuShowMenuRun:=""
	}
	MenuRunDebugModeShow()
	if(any="")
		return
	fullPath:=Get_Obj_Path(any)
	SplitPath, fullPath, name, dir, ext, name_no_ext
	if(dir && FileExist(dir))
		SetWorkingDir,%dir%
	try {
		global TVEditItem
		;[判断运行软件时按住的键]
		menuholdkey:=MenuRunHoldKey()
		;[获取菜单项启动模式]
		itemMode:=Get_Menu_Item_Mode(any)
		;[从最近运行项中记录的右键多功能项]
		M_ThisMenuItem:=""
		R_ThisMenuItem:=RegExReplace(Z_ThisMenuItem,"&\d+ ","")
		menuRunNameStr:="运行(&R) " Z_ThisMenuItem "," MENU_RUN_NAME_STR
		menuRunNameNoFileStr:="运行(&R) " Z_ThisMenuItem "," MENU_RUN_NAME_NOFILE_STR
		if R_ThisMenuItem in %menuRunNameStr%
		{
			M_ThisMenuItem:=R_ThisMenuItem
		}
		;[显示功能菜单]
		if(menuholdkey=HoldKeyRun5){
			gosub,MenuRunMultifunctionMenu
			if(M_ThisMenuItem="")
				return
		}
		;[编辑菜单项]
		if(menuholdkey=HoldKeyRun3 || M_ThisMenuItem="编辑(&E)"){
			TVEditItem:=Z_ThisMenuItem
			TVEditItem:=RegExReplace(TVEditItem,"重名$")
			gosub,Menu_Edit%MENU_NO%
			TVEditItem:=""
			return
		}
		;[复制或输出菜单项内容]
		if(menuholdkey=HoldKeyRun31 || M_ThisMenuItem="复制运行路径(&C)"){
			Send_Or_Show(fullPath,false,HoldKeyShowTime,3000)
			return
		}else if(menuholdkey=HoldKeyRun32 || M_ThisMenuItem="输出运行路径(&V)"){
			Send_Or_Show(fullPath,true,HoldKeyShowTime,3000)
			return
		}else if(menuholdkey=HoldKeyRun33 || M_ThisMenuItem="复制软件名(&N)"){
			Send_Or_Show(name_no_ext,false,HoldKeyShowTime,3000)
			return
		}else if(menuholdkey=HoldKeyRun34 || M_ThisMenuItem="输出软件名(&M)"){
			Send_Or_Show(name_no_ext,true,HoldKeyShowTime,3000)
			return
		}else if(menuholdkey=HoldKeyRun35 || M_ThisMenuItem="复制软件名+后缀(&F)"){
			Send_Or_Show(name,false,HoldKeyShowTime,3000)
			return
		}else if(menuholdkey=HoldKeyRun36 || M_ThisMenuItem="输出软件名+后缀(&G)"){
			Send_Or_Show(name,true,HoldKeyShowTime,3000)
			return
		}
		;[结束软件进程]
		if((menuholdkey=HoldKeyRun4 || M_ThisMenuItem="结束软件进程(&X)") && (itemMode=1 || itemMode=60)){
			Process,Close,%name%
			return
		}
		if(RecentMax>0 && !RegExMatch(Z_ThisMenuItem,"S)^&\d+"))
			gosub,Menu_Recent
		;[根据菜单项模式运行]
		returnFlag:=false
		gosub,Menu_Run_Mode_Label
		if(returnFlag)
			return
		;[解析选中变量%getZz%]
		getZzFlag:=InStr(any,"%getZz%") ? true : false
		any:=Get_Transform_Val(any)
		any:=RTrim(any," `t`n`r")
		anyRun:=""
		if(getZz="" && !Candy_isFile){
			;[打开应用所在目录，只有目录则直接打开]
			if(menuholdkey=HoldKeyRun2 || M_ThisMenuItem="软件目录(&D)" || InStr(FileExist(any), "D")){
				if(OpenFolderPathRun){
					anyRun=%anyRun%%OpenFolderPathRun%%A_Space%"%any%"
				}else if(InStr(FileExist(any), "D")){
					anyRun=%anyRun%%any%
				}else{
					anyRun.="explorer.exe /select," any
				}
				Run_Any(anyRun)
				return
			}
		}
		menuKeys:=StrSplit(Z_ThisMenuItem,"`t")
		thisMenuName:=menuKeys[1]
		;[管理员身份运行]
		if(menuholdkey=HoldKeyRun11 || M_ThisMenuItem="管理员权限运行(&A)"){
			anyRun.="*RunAs "
		}
		;[最小化、最大化、隐藏运行模式]
		if(menuholdkey=HoldKeyRun12 || M_ThisMenuItem="最小化运行(&I)"){
			mode:="Min"
		}else if(menuholdkey=HoldKeyRun13 || M_ThisMenuItem="最大化运行(&P)"){
			mode:="Max"
		}else if(menuholdkey=HoldKeyRun14 || M_ThisMenuItem="隐藏运行(&H)"){
			mode:="Hide"
		}else{
			mode:=""
		}
		;[透明运行模式]
		menuTransNum:=100
		if(thisMenuName && RegExMatch(thisMenuName,"S).*?_:(\d{1,2})$")){
			menuTransNum:=RegExReplace(thisMenuName,"S).*?_:(\d{1,2})$","$1")
		}else if(RegExMatch(M_ThisMenuItem,"S)^透明运行:&\d{1,2}%")){
			menuTransNum:=RegExReplace(M_ThisMenuItem,"S)^透明运行:&(\d{1,2})%$","$1")
		}
		;[置顶运行模式]
		topFlag:=false
		if(M_ThisMenuItem="置顶运行(&T)"){
			topFlag:=true
		}
		;[带选中内容运行]
		if(getZz!="" && (getZzFlag || AutoGetZz)){
			firstFile:=RegExReplace(getZz,"(.*)(\n|\r).*","$1")  ;取第一行
			if(Candy_isFile=1 || FileExist(getZz) || FileExist(firstFile)){
				getZzStr:=""
				Loop, parse, getZz, `n, `r, %A_Space%%A_Tab%
				{
					if(!A_LoopField)
						continue
					getZzStr.="""" . A_LoopField . """" . A_Space
				}
				StringTrimRight, getZzStr, getZzStr, 1
				if(GetKeyState("Ctrl")){
					gosub,Menu_Add_File_Item
					return
				}
				if(getZzFlag || InStr(FileExist(any), "D")){
					Run_Any(any,mode)
				}else{
					Run_Any(any . A_Space . getZzStr,mode)
				}
				if(topFlag || menuTransNum<100){
					Run_Wait(any,false,menuTransNum)
				}
				return
			}
			if(getZzFlag){
				anyRun=%anyRun%%any%
			}else{
				anyRun=%anyRun%%any%%A_Space%%getZz%
			}
			Run_Any(anyRun,mode)
			if(topFlag || menuTransNum<100){
				Run_Wait(any,false,menuTransNum)
			}
			return
		}
		
		if(ext && openExtRunList[ext]){
			Run_Any(openExtRunList[ext] . A_Space . """" any """",mode)
		}else{
			Run_Any(anyRun . any,mode)
		}
		if(topFlag || menuTransNum<100){
			Run_Wait(any,false,menuTransNum)
		}
	} catch e {
		MsgBox,16,%Z_ThisMenuItem%运行出错,% "运行路径：" any "`n出错命令：" e.What 
			. "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
	}finally{
		SetWorkingDir,%A_ScriptDir%
	}
return
;判断运行软件时按住的键
MenuRunHoldKey(){
	holdKey:=0
	if(GetKeyState("Ctrl"))
		holdKey:=2
	if(GetKeyState("Shift")){
		holdKey:=holdKey=2 ? 3 : 5
	}
	if(GetKeyState("LWin") || GetKeyState("RWin")){
		if(holdKey=2){
			holdKey:=4
		}else if(holdKey=5){
			holdKey:=6
		}else if(holdKey=3){
			holdKey:=7
		}
	}
	return holdKey
}
;右键菜单项显示多功能菜单
MenuRunMultifunctionMenu:
	menuRunSameSubFlag:=false
	Menu,menuRun,Add,运行(&R) %Z_ThisMenuItem%,MultifunctionMenu
	Menu,menuRun,Add,编辑(&E),MultifunctionMenu
	if itemMode not in 2,3,4,5,6,7,8
	{
		menuRunMultifunctionMenuStr:=menuRunNameStr
		for k, v in MenuObjSame
		{
			SplitPath, v, v_name
			vName:=RegExReplace(v_name,"iS)\.exe$")
			if(vName=Z_ThisMenuItem && v!=fullPath){
				MenuObj[v]:=v
				Menu,menuRunSameSub,Add, %k%, Menu_Run
				Menu_Item_Icon("menuRunSameSub",k,v)
				menuRunSameSubFlag:=true
			}
		}
		if(menuRunSameSubFlag)
			Menu,menuRun,Add,同名软件(&S), :menuRunSameSub
		Menu,menuRun,Add,软件目录(&D),MultifunctionMenu
		Menu,menuRun,Add
		Loop, 9
		{
			menuRunTransSubItem:="透明运行:&" A_Index*10 "%"
			Menu,menuRunTransSub,Add,%menuRunTransSubItem%, MultifunctionMenu
			Menu_Item_Icon("menuRunTransSub",menuRunTransSubItem,MenuItemIconList[Z_ThisMenuItem],MenuItemIconNoList[Z_ThisMenuItem])
		}
		Menu,menuRun,Add,透明运行(&Q), :menuRunTransSub
		Menu,menuRun,Add,置顶运行(&T),MultifunctionMenu
		;~ Menu,menuRun,Add,改变大小运行(&W), :menuRunWinSizeSub
		Menu,menuRun,Add,管理员权限运行(&A),MultifunctionMenu
		Menu,menuRun,Add,最小化运行(&I),MultifunctionMenu
		Menu,menuRun,Add,最大化运行(&P),MultifunctionMenu
		Menu,menuRun,Add,隐藏运行(&H),MultifunctionMenu
		Menu,menuRun,Add,结束软件进程(&X),MultifunctionMenu
	}else{
		menuRunMultifunctionMenuStr:=menuRunNameNoFileStr
	}
	Menu,menuRun,Add
	Menu,menuRun,Add,复制运行路径(&C),MultifunctionMenu
	Menu,menuRun,Add,输出运行路径(&V),MultifunctionMenu
	Menu,menuRun,Add,复制软件名(&N),MultifunctionMenu
	Menu,menuRun,Add,输出软件名(&M),MultifunctionMenu
	Menu,menuRun,Add,复制软件名+后缀(&F),MultifunctionMenu
	Menu,menuRun,Add,输出软件名+后缀(&G),MultifunctionMenu
	Loop, Parse, menuRunMultifunctionMenuStr, `,
	{
		if(A_LoopField="同名软件(&S)" && !menuRunSameSubFlag)
			continue
		Menu_Item_Icon("menuRun",A_LoopField,MenuItemIconList[Z_ThisMenuItem],MenuItemIconNoList[Z_ThisMenuItem])
	}
	Menu,menuRun,Show
	Menu,menuRun,DeleteAll
return
MultifunctionMenu:
	M_ThisMenuItem:=A_ThisMenuItem
return
;══════════════════════════════════════════════════════════════════
;~;【菜单运行-热键】
;══════════════════════════════════════════════════════════════════
Menu_Key_Run:
	getZz:=Get_Zz()
	gosub,Menu_Key_Run_Run
return
Menu_Key_NoGet_Run:
	getZz:=""
	gosub,Menu_Key_Run_Run
return
Menu_Key_Run_Run:
	any:=menuObjkey[(A_ThisHotkey)]
	thisMenuName:=MenuObjKeyName[(A_ThisHotkey)]
	SplitPath, any, , dir, ext
	if(dir && FileExist(dir))
		SetWorkingDir,%dir%
	try {
		itemMode:=Get_Menu_Item_Mode(any)
		
		MenuRunDebugModeShow(1)
		;[根据菜单项模式运行]
		returnFlag:=false
		gosub,Menu_Run_Mode_Label
		if(returnFlag)
			return
		
		;[解析选中变量%getZz%]
		getZzFlag:=InStr(any,"%getZz%") ? true : false
		any:=Get_Transform_Val(any)
		any:=RTrim(any," `t`n`r")
		if(itemMode=7 && InStr(FileExist(any), "D")){
			;[打开文件夹]
			if(OpenFolderPathRun){
				Run_Any(OpenFolderPathRun A_Space """" any """")
			}else{
				Run_Any(any)
			}
			return
		}
		;[透明运行模式]
		menuTransNum:=100
		if(thisMenuName && RegExMatch(thisMenuName,"S).*?_:(\d{1,2})$")){
			menuTransNum:=RegExReplace(thisMenuName,"S).*?_:(\d{1,2})$","$1")
		}
		if(getZz!="" && (getZzFlag || AutoGetZz)){
			firstFile:=RegExReplace(getZz,"(.*)(\n|\r).*","$1")  ;取第一行
			if(getZzFlag){
				Run_Any(any)
			}else if(Candy_isFile=1 || FileExist(getZz) || FileExist(firstFile)){
				getZzStr:=""
				Loop, parse, getZz, `n, `r, %A_Space%%A_Tab%
				{
					if(!A_LoopField)
						continue
					getZzStr.="""" . A_LoopField . """" . A_Space
				}
				StringTrimRight, getZzStr, getZzStr, 1
				Run_Any(any . A_Space . getZzStr)
			}else{
				Run_Zz(any)
			}
		}else{
			if(ext && openExtRunList[ext]){
				Run_Any(openExtRunList[ext] . A_Space . """" any """")
			}else if(RegExMatch(any,"iS).*?\.[a-zA-Z0-9]+$")){
				Run_Zz(any)
			}else{
				Run_Any(any)
			}
		}
		if(menuTransNum<100){
			Run_Wait(any,false,menuTransNum)
		}
	} catch e {
		MsgBox,16,%thisMenuName%热键运行出错,% "运行路径：" any "`n出错命令：" e.What 
			. "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
	}finally{
		SetWorkingDir,%A_ScriptDir%
	}
return
Menu_Run_Mode_Label:
	anyLen:=StrLen(any)
	if(itemMode=2){
		StringLeft, any, any, anyLen-1
		if(RegExMatch(any,"S).*\$$"))
			any:=SendStrDecrypt(any)
		Send_Str_Zz(any,true)  ;[粘贴输出短语]
		returnFlag:=true
	}else if(itemMode=3){
		StringLeft, any, any, anyLen-2
		if(RegExMatch(any,"S).*\$$"))
			any:=SendStrDecrypt(any)
		Send_Str_Input_Zz(any,true)  ;[键盘输出短语]
		returnFlag:=true
	}else if(itemMode=4){
		gosub,Menu_Run_Send_Zz  ;[输出热键]
		returnFlag:=true
	}else if(itemMode=5){
		gosub,Menu_Run_Send_Ahk_Zz  ;[输出AHK热键]
		returnFlag:=true
	}else if(itemMode=8){
		gosub,Menu_Run_Plugins_ObjReg  ;{脚本插件函数}
		returnFlag:=true
	}else if(itemMode=60){
		gosub,Menu_Run_Exe_Url  ;指定浏览器打开网页
		returnFlag:=true
	}else if(itemMode=6){
		Run_Search(any,getZz)  ;网页
		returnFlag:=true
	}
return
Menu_Run_Send_Zz:
	StringLeft, any, any, anyLen-2
	Send_Key_Zz(any)
return
Menu_Run_Send_Ahk_Zz:
	StringLeft, any, any, anyLen-3
	Send_Key_Zz(any,1)
return
Menu_Run_Exe_Url:
	BrowserPath:=RegExReplace(any,"iS)(.*?\.exe) .*","$1")	;只去参数
	anyUrl:=RegExReplace(any,"iS).*?\.exe (.*)","$1")	;去掉应用名，取参数
	Run_Search(anyUrl,getZz,BrowserPath)
return
;菜单运行时显示的调试信息
MenuRunDebugModeShow(key:=0){
	if(DebugMode){
		if(getZz!=""){
			Menu_Debug_Mode("===选中内容===`n")
			Menu_Debug_Mode(getZz "`n")
		}
		if(Candy_isFile)
			Menu_Debug_Mode("选中内容类型：文件" "`n")
		if(key){
			Menu_Debug_Mode("全局热键：" A_ThisHotkey "`n")
		}else if(GetKeyState("Ctrl") || GetKeyState("Shift") || GetKeyState("Alt") 
				|| GetKeyState("LWin") || GetKeyState("RWin")){
			Menu_Debug_Mode("按下按键：")
			if(GetKeyState("Ctrl"))
				Menu_Debug_Mode(" Ctrl键")
			if(GetKeyState("Shift"))
				Menu_Debug_Mode(" Shift键")
			if(GetKeyState("Alt"))
				Menu_Debug_Mode(" Alt键")
			if(GetKeyState("LWin"))
				Menu_Debug_Mode(" 左Win键")
			if(GetKeyState("RWin"))
				Menu_Debug_Mode(" 右Win键")
			Menu_Debug_Mode("`n")
		}
	}
}
Run_Any(any,mode:=""){
	Menu_Debug_Mode("[运行路径]`n" any "`n")
	if(MenuIconFlag){
		Menu_Run_Tray_Tip(any "`n")
	}
	if(mode!=""){
		Run,%any%,,%mode%
	}else{
		Run,%any%
	}
}
Run_Zz(program){
	fullPath:=Get_Obj_Path(program)
	exePath:=fullPath ? fullPath : program
	DetectHiddenWindows, Off
	If(!WinExist("ahk_exe" . exePath)){
		Run_Any(program)
		return true
	}else{
		WinGet,l,List,ahk_exe %exePath%
		if l=1
			If WinActive("ahk_exe" . exePath)
				WinMinimize
			else
				WinActivate
		else
			WinActivateBottom,ahk_exe %exePath%
		return false
	}
}
Run_Wait(program,topFlag:=false,transRatio=100,winSizeRatio=100,winSize=0){
	fullPath:=Get_Obj_Path(program)
	exePath:=fullPath ? fullPath : program
	transRatio:=transRatio<0 ? 0 : transRatio
	SplitPath, exePath, fName,, fExt  ; 获取扩展名
	DetectHiddenWindows, Off
	if(fExt="lnk"){
		FileGetShortcut,%exePath%,lnkexePath
		SplitPath, lnkexePath, fName,, fExt  ; 获取扩展名
		if(fExt="exe")
			exePath:=lnkexePath
	}
	WinWait,ahk_exe %exePath%,,10
	if ErrorLevel
		return
	if(topFlag){
		if(WinActive("ahk_class CabinetWClass")){
			WinSet,AlwaysOnTop,On,ahk_class CabinetWClass
		}else{
			WinSet,AlwaysOnTop,On,ahk_exe %exePath%
		}
	}
	if(transRatio<100){
		try WinSet,Transparent,% transRatio/100*255,ahk_exe %exePath%
	}
}
Run_Search(any,getZz="",browser=""){
	if(browser){
		browserRun:=browser A_Space
	}else if(RegExMatch(any,"iS)(www[.]).*") && openExtRunList["www"]){
		browserRun:=openExtRunList["www"] A_Space
	}else{
		HyperList:=["http","https","ftp"]
		For i, v in HyperList
		{
			if(RegExMatch(any,"iS)(" v "://?).*") && openExtRunList[v]){
				browserRun:=openExtRunList[v] A_Space
				break
			}
		}
	}
	if(InStr(any,"%getZz%")){
		Run,% browserRun """" StrReplace(any,"%getZz%",getZz) """"
	}else if(InStr(any,"%Clipboard%")){
		Run,% browserRun """" StrReplace(any,"%Clipboard%",Clipboard) """"
	}else if(InStr(any,"%s",true)){
		Run,% browserRun """" StrReplace(any,"%s",getZz) """"
	}else if(InStr(any,"%S",true)){
		Run,% browserRun """" StrReplace(any,"%S",SkSub_UrlEncode(getZz)) """"
	}else if(AutoGetZz){
		Run,%browserRun%"%any%%getZz%"
	}else{
		Run,%browserRun%"%any%"
	}
}
;~;[执行批量搜索]
Web_Run:
	webName:=RegExReplace(A_ThisMenuItem,"iS)^" RUNANY_SELF_MENU_ITEM1)
	if(webName){
		webList:=(A_ThisHotkey=MenuHotKey2) ? menuWebList2[(webName)] : menuWebList1[(webName)]
	}else{
		webList:=(A_ThisHotkey=MenuHotKey2) ? menuWebList2[(menuRoot2[1])] : menuWebList1[(menuRoot1[1])]
	}
	if(JumpSearch){
		gosub,Web_Search
	}else{
		MsgBox,33,开始批量搜索%webName%,确定用【%getZz%】批量搜索以下网站：`n%webList%
		IfMsgBox Ok
		{
			gosub,Web_Search
		}
	}
return
Web_Search:
	Loop,parse,webList,`n
	{
		if(A_LoopField){
			any:=MenuObj[(A_LoopField)]
			Run_Search(any,getZz,BrowserPathRun)
		}
	}
return
;调用huiZz_Text插件函数
SendStrDecrypt(any,key:=""){
	try{
		if(encryptFlag){
			key:=(key="") ? SendStrDcKey : key
			PluginsObjRegActive["huiZz_Text"]:=ComObjActive(PluginsObjRegGUID["huiZz_Text"])
			anyval:=PluginsObjRegActive["huiZz_Text"]["runany_decrypt"](any,key)
			return anyval
		}
	} catch {}
	return any
}
SendStrEncrypt(any,key:=""){
	try{
		if(encryptFlag){
			key:=(key="") ? SendStrDcKey : key
			PluginsObjRegActive["huiZz_Text"]:=ComObjActive(PluginsObjRegGUID["huiZz_Text"])
			anyval:=PluginsObjRegActive["huiZz_Text"]["runany_encrypt"](any,key)
			return anyval
		}
	} catch {}
	return any
}
;~;[脚本插件函数运行]
Menu_Run_Plugins_ObjReg:
	appPlugins:=RegExReplace(any,"iS)(.+?)\[.+?\]%?\(.*?\)$","$1")	;取插件名
	appFunc:=RegExReplace(any,"iS).+?\[(.+?)\]%?\(.*?\)$","$1")	;取函数名
	appParmStr:=RegExReplace(any,"iS).+?\[.+?\]%?\((.*?)\)$","$1")	;取函数参数
	appParmErrorStr:=(appParmStr="") ? "空" : appParmStr
	if(!PluginsObjRegGUID[appPlugins]){
		ToolTip,脚本插件：%appPlugins%`n脚本函数：%appFunc%`n函数参数：%appParmErrorStr%`n插件%appPlugins%没有找到！`n【请检查修改后重启RunAny重试】
		SetTimer,RemoveToolTip,8000
		return
	}
	if(RegExMatch(any,"iS).+?\[.+?\]%\(.*?\)")){  ;动态函数执行
		DynaExpr_ObjRegisterActive(PluginsObjRegGUID[appPlugins],appFunc,appParmStr,getZz)
	}else{
		try {
			PluginsObjRegActive[appPlugins]:=ComObjActive(PluginsObjRegGUID[appPlugins])
		} catch {
			TrayTip,,%appPlugins% 外接脚本失败`n请检查是否已经启动(在插件管理中设为自动启动)，并重启RunAny重试,3,1
		}
		appParmStr:=StrReplace(appParmStr,"``,",Chr(3))
		appParms:=StrSplit(appParmStr,",")
		Loop,% appParms.MaxIndex()
		{
			appParms[A_Index]:=StrReplace(appParms[A_Index],Chr(3),",")
			if(RegExMatch(appParms[A_Index],"iS)%""(.+?)""%")){	;无路径应用变量
				appNoPath:=RegExReplace(appParms[A_Index],"iS)%""(.+?)""%","$1")
				appNoPathName:=RegExReplace(appNoPath,"iS)\.exe($| .*)")	;去掉后缀或参数，取应用名
				appNoPathGetTfVal:=Get_Transform_Val("%" appNoPath "%")
				if(appNoPathGetTfVal="%" appNoPath "%"){	;识别为系统自带软件
					appParms[A_Index]:=RegExReplace(appParms[A_Index],"iS)%"".+?""%",appNoPath)
				}else{
					appParms[A_Index]:=appNoPathGetTfVal	;识别为自定义变量软件路径
				}
				if(MenuObj[appNoPathName]){
					SplitPath,% MenuObj[appNoPathName],,, FileExt  ; 获取文件扩展名.
					appNoPathParm:=RegExReplace(appNoPath,"iS).*?\." FileExt "($| .*)","$1")	;去掉应用名，取参数
					appParms[A_Index]:=MenuObj[appNoPathName] . appNoPathParm
				}
			}
			appParms[A_Index]:=Get_Transform_Val(appParms[A_Index])
		}
		if(appParmStr=""){	;没有传参，直接执行函数
			PluginsObjRegActive[appPlugins][appFunc]()
		}else if(appParms.MaxIndex()=1){
			PluginsObjRegActive[appPlugins][appFunc](appParms[1])
		}else if(appParms.MaxIndex()=2){
			PluginsObjRegActive[appPlugins][appFunc](appParms[1],appParms[2])
		}else if(appParms.MaxIndex()=3){
			PluginsObjRegActive[appPlugins][appFunc](appParms[1],appParms[2],appParms[3])
		}else if(appParms.MaxIndex()=4){
			PluginsObjRegActive[appPlugins][appFunc](appParms[1],appParms[2],appParms[3],appParms[4])
		}else if(appParms.MaxIndex()=5){
			PluginsObjRegActive[appPlugins][appFunc](appParms[1],appParms[2],appParms[3],appParms[4],appParms[5])
		}else if(appParms.MaxIndex()=6){
			PluginsObjRegActive[appPlugins][appFunc](appParms[1],appParms[2],appParms[3],appParms[4],appParms[5],appParms[6])
		}else if(appParms.MaxIndex()=7){
			PluginsObjRegActive[appPlugins][appFunc](appParms[1],appParms[2],appParms[3],appParms[4],appParms[5],appParms[6],appParms[7])
		}else if(appParms.MaxIndex()=8){
			PluginsObjRegActive[appPlugins][appFunc](appParms[1],appParms[2],appParms[3],appParms[4],appParms[5],appParms[6],appParms[7],appParms[8])
		}else if(appParms.MaxIndex()=9){
			PluginsObjRegActive[appPlugins][appFunc](appParms[1],appParms[2],appParms[3],appParms[4],appParms[5],appParms[6],appParms[7],appParms[8],appParms[9])
		}else if(appParms.MaxIndex()=10){
			PluginsObjRegActive[appPlugins][appFunc](appParms[1],appParms[2],appParms[3],appParms[4],appParms[5],appParms[6],appParms[7],appParms[8],appParms[9],appParms[10])
		}else if(appParms.MaxIndex()>10){
			ToolTip,脚本插件：%appPlugins%`n脚本函数：%appFunc%`n函数参数：%appParmErrorStr% 参数数量最多为10个，请修改后重试！
			SetTimer,RemoveToolTip,8000
		}
	}
	if(!InStr(PluginsContentList[(appPlugins ".ahk")],appFunc "(")){
		ToolTip,脚本插件：%appPlugins%`n脚本函数：%appFunc%`n函数参数：%appParmErrorStr%`n
		(
函数%appFunc%没有找到！`n【请检查插件脚本是否已更新版本，或修改错误后重启RunAny重试】
		)
		SetTimer,RemoveToolTip,8000
	}
return
;~;[菜单最近运行]
Menu_Recent:
	recentAny:=any
	escapeList:=StrSplit("\.*?+[{|()^$")
	regMenuItem:=A_ThisMenuItem
	For k, v in escapeList
	{
		regMenuItem:=StrReplace(regMenuItem,v,"\" v)
	}
	Loop,% MenuCommonList.MaxIndex()
	{
		if(RegExMatch(MenuCommonList[A_Index],"S)&\d+\s" regMenuItem)){
			return
		}
	}
	Loop,% MenuCommonList.MaxIndex()
	{
		C_Index:=A_Index
		try{
			Loop,%MenuCount%
			{
				Menu,% menuDefaultRoot%A_Index%[1],Delete,% MenuCommonList[C_Index]
				Menu,% menuWebRoot%A_Index%[1],Delete,% MenuCommonList[C_Index]
				Menu,% menuFileRoot%A_Index%[1],Delete,% MenuCommonList[C_Index]
			}
		}catch{}
	}
	regMenuItem:=RegExReplace(A_ThisMenuItem,"iS)^运行\(&R\) ")
	;插入到最近运行第一条
	MenuCommonList.InsertAt(1,"&1" A_Space regMenuItem)
	MenuCommonNewList:=[]
	MenuCommonNewList.InsertAt(1,"&1" A_Space regMenuItem)
	
	Loop,% MenuCommonList.MaxIndex()
	{
		try{
			if(A_Index<=RecentMax){
				if(A_Index>1){
					recentAny:=MenuObj[MenuCommonList[A_Index]]  ;获取原顺序下运行路径
					MenuCommonNewList[A_Index]:=RegExReplace(MenuCommonList[A_Index],"&\d+","&" A_Index)  ;修改序号
				}
				menuItem:=MenuCommonNewList[A_Index]
				MenuObj[menuItem]:=recentAny
				fullPath:=Get_Obj_Path(recentAny)
				SplitPath,fullpath, , , recentExt
				Loop,%MenuCount%
				{
					Menu,% menuDefaultRoot%A_Index%[1],Add,%menuItem%,Menu_Run
					Menu,% menuWebRoot%A_Index%[1],Add,%menuItem%,Menu_Run
					Menu,% menuFileRoot%A_Index%[1],Add,%menuItem%,Menu_Run
					;更改图标
					if(recentExt="exe"){
						Menu_Item_Icon(menuDefaultRoot%A_Index%[1],menuItem,fullpath)
						Menu_Item_Icon(menuWebRoot%A_Index%[1],menuItem,fullpath)
						Menu_Item_Icon(menuFileRoot%A_Index%[1],menuItem,fullpath)
					}else{
						recentItemMode:=Get_Menu_Item_Mode(recentAny)
						Menu_Add(menuDefaultRoot%A_Index%[1],menuItem,recentAny,recentItemMode,"")
						Menu_Add(menuWebRoot%A_Index%[1],menuItem,recentAny,recentItemMode,"")
						Menu_Add(menuFileRoot%A_Index%[1],menuItem,recentAny,recentItemMode,"")
					}
				}
			}
		}catch{}
	}
	;保存菜单最近运行项至注册表，重启后加载
	commonStr:=""
	MenuCommonList:=MenuCommonNewList.Clone()
	For k, v in MenuCommonList
	{
		commonStr:=commonStr ? commonStr "|" v : v
	}
	RegWrite, REG_SZ, HKEY_CURRENT_USER, SOFTWARE\RunAny, MenuCommonList, %commonStr%
return
;══════════════════════════════════════════════════════════════════
;~;[一键Everything][搜索选中文字][激活][隐藏]
Ev_Show:
	getZz:=Get_Zz()
	evSearch:=""
	if(Trim(getZz," `t`n`r")!=""){
		getZzLength:=StrSplit(getZz,"`n").Length()
		Loop, parse, getZz, `n, `r
		{
			S_LoopField=%A_LoopField%
			if(EvShowFolder && (InStr(FileExist(S_LoopField), "D") || RegExMatch(S_LoopField,"S).*\\$"))){
			}else if(RegExMatch(S_LoopField,"S)^(\\\\|.:\\).*?$")){
				SplitPath,S_LoopField,fileName,,,name_no_ext
				S_LoopField:=EvShowExt ? fileName : name_no_ext
			}
			if(InStr(S_LoopField,A_Space) && getZzLength>1){
				S_LoopField="""%S_LoopField%"""
			}
			evSearch.=S_LoopField "|"
		}
		evSearch:=RegExReplace(evSearch,"\|$")
	}
	EvPathRun:=Get_Transform_Val(EvPath)
	DetectHiddenWindows,On
	IfWinExist ahk_class EVERYTHING
		if evSearch
			Run % EvPathRun " -search """ evSearch """"
		else
			IfWinNotActive
				WinActivate
			else
				WinMinimize
	else
		Run % EvPathRun (evSearch ? " -search """ evSearch """" : "")
	DetectHiddenWindows,Off
return
;~;[一键搜索]
One_Show:
	getZz:=Get_Zz()
	gosub,One_Search
return
One_Search:
	Loop,parse,OneKeyUrl,`n
	{
		if(A_LoopField){
			if(Candy_isFile){
				SplitPath, getZz,FileName
				Run_Search(A_LoopField,FileName,BrowserPathRun)
			}else{
				Run_Search(A_LoopField,getZz,BrowserPathRun)
			}
		}
	}
return
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
;~;【——函数方法——】
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
;[检查后缀名]
Ext_Check(name,len,ext){
	len_ext:=StrLen(ext)
	site:=InStr(name,ext,,0,1)
	return site!=0 && site=len-len_ext+1
}
;~;[输出结果还是仅显示保存到剪贴板]
Send_Or_Show(textResult,isSend:=false,sTime:=1000,wTime:=0){
	textResult:=RegExReplace(textResult,"`r`n$")
	if(isSend){
		Send_Str_Zz(textResult)
		return
	}
	Clipboard:=textResult
	ToolTip,%textResult%
	Sleep,%sTime%
	if(A_TimeIdle>500){
		Sleep,% wTime ? wTime : sTime
	}
	ToolTip
}
;~;[粘贴输出短语]
Send_Str_Zz(strZz,tf=false){
	Candy_Saved:=ClipboardAll
	;切换Win10输入法为英文
	try DllCall("SendMessage",UInt,DllCall("imm32\ImmGetDefaultIMEWnd",Uint,WinExist("A")),UInt,0x0283,Int,0x002,Int,0x00)
	if(tf){
		strZz:=Get_Transform_Val(strZz)
	}
	Clipboard:=strZz
	SendInput,^v
	Sleep,80
	Clipboard:=Candy_Saved
}
;~;[键盘输出短语]
Send_Str_Input_Zz(strZz,tf=false){
	if(tf){
		strZz:=Get_Transform_Val(strZz)
	}
	SendInput,{Text}%strZz%
}
;~;[输出热键]
Send_Key_Zz(keyZz,keyLevel=0){
	if(keyLevel=1)
		SendLevel,1
	SendInput,%keyZz%
	if(keyLevel=1)
		SendLevel,0
}
;~;[获取选中]
Get_Zz(){
	global Candy_isFile
	global Candy_Select
	Candy_isFile:=0
	try Candy_Saved:=ClipboardAll
	Clipboard=
	SendInput,^c
	if (ClipWaitTime != 0.1) && WinActive("ahk_group ClipWaitGUI"){
		ClipWait,%ClipWaitTime%
	}else{
		ClipWait,0.1
	}
	If(ErrorLevel){
		Clipboard:=Candy_Saved
		return ""
	}
	Candy_isFile:=DllCall("IsClipboardFormatAvailable","UInt",15)
	CandySel=%Clipboard%
	Candy_Select=%ClipboardAll%
	Clipboard:=Candy_Saved
	return CandySel
}
;[文本转换为URL编码]
SkSub_UrlEncode(str, enc="UTF-8")
{
    enc:=trim(enc)
    If enc=
        Return str
   hex := "00", func := "msvcrt\" . (A_IsUnicode ? "swprintf" : "sprintf")
   VarSetCapacity(buff, size:=StrPut(str, enc)), StrPut(str, &buff, enc)
   While (code := NumGet(buff, A_Index - 1, "UChar")) && DllCall(func, "Str", hex, "Str", "%%%02X", "UChar", code, "Cdecl")
   encoded .= hex
   Return encoded
}
;[数组拼接字符]
StrJoin(sep, params*) {
	str:=""
    for index,param in params
        str .= param . sep
    return SubStr(str, 1, -StrLen(sep))
}
;~;[获取变量展开转换后的值]
Get_Transform_Val(var){
	try{
		Transform,varTemp,Deref,%var%
		return varTemp
	}catch{
		return var
	}
}
;变量布尔值反转
Variable_Boolean_Reverse(vars*){
	global
	for i,v in vars
	{
		%v%:=!%v%
	}
}
/*
【获取当前电脑机型-规则】
返回值参考：https://docs.microsoft.com/zh-cn/windows/win32/cimwin32prov/win32-systemenclosure
*/
rule_chassis_types(){
	chassisTypes:=cmdClipReturn("wmic PATH Win32_SystemEnclosure get ChassisTypes /value | findstr ""ChassisTypes=""")
	chassisTypes:=RegExReplace(chassisTypes,"i)ChassisTypes=\{(\d+)\}.*","$1")
	return Format("{:d}",chassisTypes)
}
;~;[检查网络状态-规则]
rule_check_network(lpszUrl=""){
	if(lpszUrl="")
		lpszUrl:="http://www.baidu.com"
	return DllCall("Wininet.dll\InternetCheckConnection", "Ptr", &lpszUrl, "UInt", 0x1, "UInt", 0x0, "Int")
}
/*
【判断启动项当前是否已经运行】
runNamePath 进程名或者启动项路径
*/
rule_check_is_run(runNamePath){
	runValue:=RegExReplace(runNamePath,"iS)(.*?\.exe)($| .*)","$1")	;去掉参数
	SplitPath, runValue, name,, ext  ; 获取扩展名
	if(ext="ahk"){
		if(InStr(runNamePath,"..\")=1){
			runNamePath:=IsFunc("funcPath2AbsoluteZz") ? Func("funcPath2AbsoluteZz").Call(runNamePath,A_ScriptFullPath) : runNamePath
		}
		IfWinExist, %runNamePath% ahk_class AutoHotkey
		{
			return true
		}
	}else if(name){
		Process,Exist,%name%
		if ErrorLevel
			return true
	}
	return false
}
/*
【相对路径转换为绝对路径 by hui-Zz】
aPath 被转换的相对路径，可带文件名
ahkPath 相对参照的执行脚本完整全路径，带文件名
return -1 路径参数有误
*/
funcPath2AbsoluteZz(aPath,ahkPath){
	SplitPath, aPath, fname, fdir, fext, , fdrive
	SplitPath, ahkPath, name, dir, ext, , drive
	if(!aPath || !ahkPath)
		return -1
	;下级目录直接加上参照目录路径
	if(!fdrive && !InStr(aPath,"..")){
		return dir . "\" . aPath
	}
	pathList:=StrSplit(dir,"\")
	;上级目录根据层级递进添加多级路径
	if(InStr(aPath,"..\")=1){
		aPathStr:=RegExReplace(aPath, "\.\.\\", , PointCount)
		pathStr:=""
		;每次向上递进，找到添加与启动项相匹配路径段
		Loop,% pathList.MaxIndex()-PointCount
		{
			pathStr.=pathList[A_Index] . "\"
		}
		filePath:=pathStr . aPathStr
		return filePath
	}
	return false
}
/*
【绝对路径转换为相对路径 by hui-Zz】
fPath 被转换的全路径，可带文件名
ahkPath 相对参照的执行脚本完整全路径，带文件名
return -1 路径参数有误
return -2 被转换路径和参照路径不在同一磁盘，不能转换
*/
funcPath2RelativeZz(fPath,ahkPath){
	SplitPath, fPath, fname, fdir, fext, , fdrive
	SplitPath, ahkPath, name, dir, ext, , drive
	if(!fPath || !ahkPath || !dir || !fdir || !fdrive)
		return -1
	if(fdrive!=drive){
		return -2
	}
	;下级目录直接去掉参照目录路径
	if(InStr(fPath,dir)){
		filePath:=StrReplace(fPath,dir)
		StringTrimLeft, filePath, filePath, 1
		return filePath
	}
	;上级目录根据层级递进添加多级前缀..\
	pathList:=StrSplit(dir,"\")
	Loop,% pathList.MaxIndex()
	{
		pathStr:=""
		upperStr:=""
		;每次向上递进，找到与启动项相匹配路径段替换成..\
		Loop,% pathList.MaxIndex()-A_Index
		{
			pathStr.=pathList[A_Index] . "\"
		}
		StringTrimRight, pathStr, pathStr, 1
		if(InStr(fdir,pathStr)){
			Loop,% A_Index
			{
				upperStr.="..\"
			}
			StringTrimRight, upperStr, upperStr, 1
			filePath:=StrReplace(fPath,pathStr,upperStr)
			return filePath
		}
	}
	return false
}
;[利用HTML中JS的eval函数来计算]
js_eval(exp)
{
	HtmlObj:=ComObjCreate("HTMLfile")
	exp:=escapeString(exp)
	if(InStr(exp,"-") && InStr(exp,".")){
		;解决eval减法精度失真问题，根据最长的小数位数四舍五入
		subMaxNum:=0
		expResult:=exp
		while RegExMatch(expResult,"S)(\.\d+)")
		{
			sub:=RegExReplace(expResult,".*(\.\d+).*","$1")
			if(StrLen(sub)>subMaxNum)
				subMaxNum:=StrLen(sub)
			expResult:=RegExReplace(expResult,sub)
		}
		expNum:="1"
		Loop,%subMaxNum%
		{
			expNum.="0"
		}
	}else{
		expNum:="100000000000000"
	}
	HtmlObj.write("<body><script>var t=document.body;t.innerText='';t.innerText=Math.round(eval('" . exp . "')*" expNum ")/" expNum ";</script></body>")
	return InStr(cabbage:=HtmlObj.body.innerText, "body") ? "?" : cabbage
}
escapeString(string){
	string:=RegExReplace(string, "('|""|&|\\|\\n|\\r|\\t|\\b|\\f)", "\$1")
	string:=RegExReplace(string, "\R", "\n")
	return string
}
/*
【隐藏运行cmd命令并将结果存入剪贴板后取回 @hui-Zz】
*/
cmdClipReturn(command){
	cmdInfo:=""
	try{
		Clip_Saved:=ClipboardAll
		Clipboard=
		Run,% ComSpec " /C " command " | CLIP", , Hide
		ClipWait,2
		cmdInfo:=Clipboard
		Clipboard:=Clip_Saved
	}catch{}
	return cmdInfo
}
;[动态执行脚本注册对象]
DynaExpr_ObjRegisterActive(GUID,appFunc,appParms:="",getZz:="")
{
	sScript:="
	(
		#NoTrayIcon
		get_zz = " getZz "
		try appPlugins := ComObjActive(""" GUID """)
		appPlugins[""" appFunc """](" appParms ")
	)"
	PID:=DynaRun(sScript)
}
;[动态获得AHK代码结果值]
DynaExpr_EvalToVar(sExpr,getZz:="")
{
	sTmpFile := A_Temp "\temp.ahk"
	sScript:="
	(
		#NoTrayIcon
		FileDelete " sTmpFile "
		get_zz = " getZz "
		val := " sExpr "
		FileAppend %val%, " sTmpFile "
	)"

	PID:=DynaRun(sScript)

	Process,WaitClose,%PID%
	FileRead sResult, %sTmpFile%
	return sResult
}
;[动态执行AHK代码]
DynaRun(TempScript, pipename="", params="")
{
   static _:="uint",@:="Ptr"
   If pipename =
      name := "AHK" A_TickCount
   Else
      name := pipename
   __PIPE_GA_ := DllCall("CreateNamedPipe","str","\\.\pipe\" name,_,2,_,0,_,255,_,0,_,0,@,0,@,0)
   __PIPE_    := DllCall("CreateNamedPipe","str","\\.\pipe\" name,_,2,_,0,_,255,_,0,_,0,@,0,@,0)
   if (__PIPE_=-1 or __PIPE_GA_=-1)
      Return 0
	 If A_IsCompiled || (A_IsDll && DllCall(A_AhkPath "\ahkgetvar","Str","A_IsCompiled")) ; allow compiled executable to execute dynamic scripts. Requires AHK_H
		Run, % """" A_AhkPath """" (params?" ":"") params " /E ""\\.\pipe\" name """",,UseErrorLevel HIDE, PID
	 else
		Run, % """" A_AhkPath """" (params?" ":"") params " ""\\.\pipe\" name """",,UseErrorLevel HIDE, PID
   If ErrorLevel
      MsgBox, 262144, ERROR,% "Could not open file:`n" __AHK_EXE_ """\\.\pipe\" name """"
   DllCall("ConnectNamedPipe",@,__PIPE_GA_,@,0)
   DllCall("CloseHandle",@,__PIPE_GA_)
   DllCall("ConnectNamedPipe",@,__PIPE_,@,0)
   script := (A_IsUnicode ? chr(0xfeff) : (chr(239) . chr(187) . chr(191))) TempScript
   if !DllCall("WriteFile",@,__PIPE_,"str",script,_,(StrLen(script)+1)*(A_IsUnicode ? 2 : 1),_ "*",0,@,0)
      Return A_LastError,DllCall("CloseHandle",@,__PIPE_)
   DllCall("CloseHandle",@,__PIPE_)
   Return PID
}
;[改进版URLDownloadToFile，来源于：http://ahkcn.net/thread-5658.html]
URLDownloadToFile(URL, FilePath, Options:="", RequestHeaders:="")
{
	Options:=this.解析信息到对象(Options)
	RequestHeaders:=this.解析信息到对象(RequestHeaders)

	ComObjError(0)	;禁用 COM 错误通告。禁用后，检查 A_LastError 的值，脚本可以实现自己的错误处理
	WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")

	if (Options["EnableRedirects"]<>"")	;设置是否获取跳转后的页面信息
		WebRequest.Option(6):=Options["EnableRedirects"]
	;proxy_setting没值时，根据Proxy值的情况智能设定是否要进行代理访问。
	;这样的好处是多数情况下需要代理时依然只用给出代理服务器地址即可。而在已经给出代理服务器地址后，又可以很方便的对是否启用代理进行开关。
	if (Options["proxy_setting"]="" and Options["Proxy"]<>"")
		Options["proxy_setting"]:=2	;0表示 Proxycfg.exe 运行了且遵循 Proxycfg.exe 的设置（没运行则效果同设置为1）。1表示忽略代理直连。2表示使用代理
	if (Options["proxy_setting"]="" and Options["Proxy"]="")
		Options["proxy_setting"]:=1
	;设置代理服务器。微软的代码 SetProxy() 是放在 Open() 之前的，所以我也放前面设置，以免无效
	WebRequest.SetProxy(Options["proxy_setting"],Options["Proxy"],Options["ProxyBypassList"])
	if (Options["Timeout"]="")		;Options["Timeout"]如果被设置为-1，并不代表无限超时，而是依然遵循SetTimeouts第4个参数设置的最大超时时间
		WebRequest.SetTimeouts(0,60000,30000,0)		;0或-1都表示超时无限等待，正整数则表示最大超时（单位毫秒）
	else if (Options["Timeout"]>30)				;如果超时设置大于30秒，则需要将默认的最大超时时间修改为大于30秒
		WebRequest.SetTimeouts(0,60000,30000,Options["Timeout"]*1000)
	else
		WebRequest.SetTimeouts(0,60000,30000,30000)	;此为SetTimeouts的默认设置。这句可以不加，因为默认就是这样，加在这里是为了表述清晰。

	WebRequest.Open("GET", URL, true)   			;true为异步获取。默认是false，龟速的根源！！！卡顿的根源！！！

	;SetRequestHeader() 必须 Open() 之后才有效
	for k, v in RequestHeaders
	{
		if (k="Cookie")
		{
			WebRequest.SetRequestHeader("Cookie","tuzi")    ;先设置一个cookie，防止出错，msdn推荐这么做
			WebRequest.SetRequestHeader("Cookie",v)
		}
		WebRequest.SetRequestHeader(k,v)
	}

	Loop
	{
		WebRequest.Send()
		WebRequest.WaitForResponse(-1)		;WaitForResponse方法确保获取的是完整的响应。-1表示总是使用SetTimeouts设置的超时

		;获取状态码，一般status为200说明请求成功
		this.Status:=WebRequest.Status()
		this.StatusText:=WebRequest.StatusText()

		if (Options["expected_status"]="" or Options["expected_status"]=this.Status)
			break
		;尝试指定次数后页面返回的状态码依旧与预期状态码不一致，则抛出错误及详细错误信息（可使用我另一个错误处理函数专门记录处理它们）
		;即使number_of_retries为空，表达式依然成立，所以不用为number_of_retries设置初始值。
		else if (A_Index>=Options["number_of_retries"])
		{
			this.extra.URL:=URL
			this.extra.Expected_Status:=Options["expected_status"]
			this.extra.Status:=this.Status
			this.extra.StatusText:=this.StatusText
			throw, Exception("经过" Options.number_of_retries "次尝试后，服务器返回状态码依旧与期望值不一致", -1, Object(this.extra))
		}
	}

	ADO:=ComObjCreate("adodb.stream")   		;使用 adodb.stream 编码返回值。参考 http://bbs.howtoadmin.com/ThRead-814-1-1.html
	ADO.Type:=1									;以二进制方式操作
	ADO.Mode:=3 								;可同时进行读写
	ADO.Open()  								;开启物件
	ADO.Write(WebRequest.ResponseBody())    	;写入物件。注意没法将 WebRequest.ResponseBody() 存入一个变量，所以必须用这种方式写文件
	ADO.SaveToFile(FilePath,2)   				;文件存在则覆盖
	ADO.Close()
	this.ResponseHeaders:=this.解析信息到对象(WebRequest.GetAllResponseHeaders())
	return, 1
}
;══════════════════════════════════════════════════════════════════
;~;【函数方法-内部】
;══════════════════════════════════════════════════════════════════
;~;[写入注册表]
Reg_Set(vGui, var, sz){
	StringCaseSense, On
	if(vGui!=var){
		RegWrite, REG_SZ, HKEY_CURRENT_USER, SOFTWARE\RunAny, %sz%, %vGui%
		IniWrite,%vGui%,%RunAnyConfig%,Config,%sz%
	}
	StringCaseSense, Off
}
;~;[读取注册表]
Var_Read(rValue,defVar=""){
	if(IniConfig){
		IniRead, regVar,%RunAnyConfig%, Config, %rValue%,% defVar ? defVar : A_Space
	}else{
		RegRead, regVar, HKEY_CURRENT_USER, SOFTWARE\RunAny, %rValue%
	}
	if(regVar!=""){
		if(InStr(regVar,"ZzIcon.dll") && !FileExist(A_ScriptDir "\ZzIcon.dll"))
			return defVar
		else
			return regVar
	}else{
		return defVar
	}
}
;~;{获取菜单项启动模式}
;~;1-启动路径|2-短语模式|3-模拟打字短语|4-热键映射|5-AHK热键映射|6-网址|60-程序参数中带网址
;~;7-文件夹|8-插件脚本函数
;~;10-菜单分类|11-分割符|12-注释说明
Get_Menu_Item_Mode(item,fullItemFlag:=false){
	if(fullItemFlag){
		if(InStr(item,";")=1)
			return 12
		if(RegExMatch(item,"S)^-+[^-]+.*"))
			return 10
		if(RegExMatch(item,"S)^-+"))
			return 11
		menuItems:=StrSplit(item,"|",,2)
		item:=(menuItems[2]) ? menuItems[2] : menuItems[1]
	}
	len:=StrLen(item)
	if(len=0)
		return 1
	if(InStr(item,";",,0,1)=len)
		return InStr(item,";;",,0,1)=len-1 ? 3 : 2
	if(InStr(item,"::",,0,1)=len-1)
		return InStr(item,":::",,0,1)=len-2 ? 5 : 4
	if(RegExMatch(item,"iS)^.*?\.(exe|lnk|bat|cmd|vbs|ps1|ahk) .*?([\w-]+://?|www[.]).*"))
		return 60
	if(RegExMatch(item,"iS)^([\w-]+://?|www[.]).*"))
		return 6
	if(RegExMatch(item,"S).+?\[.+?\]%?\(.*?\)"))
		return 8
	if(InStr(FileExist(item), "D"))
		return 7
	return 1
}
;~;[获取分类名称]
Get_Tree_Name(z_item,show_key=true){
	if(InStr(z_item,"|")){
		menuDiy:=StrSplit(z_item,"|",,2)
		z_item:=menuDiy[1]
		if(show_key && InStr(menuDiy[1],"`t")){
			menuKeyStr:=RegExReplace(menuDiy[1], "S)\t+", A_Tab)
			menuKeys:=StrSplit(menuKeyStr,"`t")
			z_item:=menuKeys[1]
		}
	}
	return RegExReplace(z_item,"S)^-+")
}
;~;[获取应用名称]
Get_Obj_Transform_Name(z_item){
	return Get_Obj_Name(Get_Transform_Val(z_item))
}
Get_Obj_Name(z_item){
	if(InStr(z_item,"|")){
		menuDiy:=StrSplit(z_item,"|",,2)
		return menuDiy[1]
	}else if(RegExMatch(z_item,"iS)^(\\\\|.:\\).*?\.exe$")){
		SplitPath,z_item,fileName,,,menuItem
		return menuItem
	}else{
		return RegExReplace(z_item,"iS)\.exe$")
	}
}
;~;[获取应用路径]
Get_Obj_Path(z_item){
	obj_path:=""
	if(InStr(z_item,"|")){
		menuDiy:=StrSplit(z_item,"|",,2)
		obj_path:=MenuObj[menuDiy[1]]
	}else{
		z_item:=RegExReplace(z_item,"iS)(.*?\.[a-zA-Z0-9]+)($| .*)","$1")	;去掉参数，取路径
		if(RegExMatch(z_item,"iS)^(\\\\|.:\\).*?\.exe$")){
			obj_path:=z_item
		}else{
			appName:=RegExReplace(z_item,"iS)\.exe$")
			obj_path:=MenuObj[appName]="" ? z_item : MenuObj[appName]
		}
	}
	if(RegExMatch(obj_path,"iS).*?\.[a-zA-Z0-9]+($| .*)")){
		obj_path:=RegExReplace(obj_path,"iS)(\.[a-zA-Z0-9]+)($| .*)","$1")
	}
	if(obj_path!="" && !InStr(obj_path,"\")){
		if(FileExist(A_WinDir "\" obj_path))
			obj_path=%A_WinDir%\%obj_path%
		if(FileExist(A_WinDir "\system32\" obj_path))
			obj_path=%A_WinDir%\system32\%obj_path%
		return obj_path
	}else if(!InStr(obj_path,"..\")){
		return obj_path
	}else{
		val:=RegExReplace(obj_path,"\.\.\\.*?$")
		aPath:=StrReplace(obj_path,val)
		absolute:=funcPath2AbsoluteZz(aPath,val)
		return absolute ? absolute : obj_path
	}
}
;~;[获取变量转换后的应用路径]
Get_Obj_Path_Transform(z_item){
	if(z_item="")
		return z_item
	itemPath:=Get_Transform_Val(z_item) ; 变量转换
	objPathItem:=Get_Obj_Path(itemPath) ; 自动添加完整路径
	if(objPathItem){
		itemPath:=objPathItem . RegExReplace(itemPath,"iS).*?\.exe($| .*)","$1")
	}
	return itemPath
}
;~;[判断后返回该菜单项最佳的启动路径]
Get_Item_Run_Path(z_item_path){
	SplitPath,z_item_path,fileName,,,itemName
	if(InStr(FileExist(z_item_path), "D"))
		return z_item_path
	if(!Check_Obj_Ext(z_item_path))
		return z_item_path
	any:=MenuObj[fileName] ? MenuObj[fileName] : MenuObj[itemName]
	if(any && any!=z_item_path){
		return z_item_path
	}
	return fileName
}
;~;[检查文件后缀是否支持无路径查找]
Check_Obj_Ext(filePath){
	EvExtFlag:=false
	fileValue:=RegExReplace(filePath,"iS)(.*?\..*?)($| .*)","$1")	;去掉参数
	SplitPath, fileValue, fName,, fExt  ; 获取扩展名
	Loop,% EvCommandExtList.MaxIndex()
	{
		EvCommandExtStr:=StrReplace(EvCommandExtList[A_Index],"*.")
		if(fExt=EvCommandExtStr){
			EvExtFlag:=true
			break
		}
	}
	if(!EvExtFlag && fExt)
		return false
	else
		return true
}
;[自动调整列表宽度]
LVModifyCol(width, colList*){
	LV_ModifyCol()  ; 根据内容自动调整每列的大小.
	for index,col in colList
	{
		LV_ModifyCol(col, width)
		LV_ModifyCol(col, "center")
	}
}

;══════════════════════════════════════════════════════════════════
;~;[添加编辑新添加的菜单项]
Menu_Add_File_Item:
	if(iniFileShow=iniPath){
		iniFileVar:=iniVar1
		TREE_NO:=1
	}else{
		iniFileVar:=iniVar2
		TREE_NO:=2
	}
	;初始化要添加的内容
	itemGlobalWinKey:=0
	hotStrOption:=hotStrShow:=itemGlobalHotKey:=itemGlobalKey:=X_ThisMenuItem:=ItemText:=""
	itemPath:=Get_Item_Run_Path(getZz)
	SplitPath, itemPath, fName,, fExt, itemName
	Z_ThisMenu:=RTrim(A_ThisMenu)
	Z_ThisMenuItem:=A_ThisMenuItem
	if(Z_ThisMenuItem=RUNANY_SELF_MENU_ITEM3){
		X_ThisMenuItem:=Z_ThisMenuItem
		itemContent:=MenuObjTree%TREE_NO%[Z_ThisMenu][(MenuObjTree%TREE_NO%[Z_ThisMenu].MaxIndex())]
		Z_ThisMenuItem:=Get_Obj_Transform_Name(itemContent)
	}
	if(!Z_ThisMenu)
		return
	menuGuiFlag:=false
	menuGuiEditFlag:=false
	thisMenuItemStr:=X_ThisMenuItem=RUNANY_SELF_MENU_ITEM3 ? "" : "菜单项（" Z_ThisMenuItem "）的上面"
	thisMenuStr:=Z_ThisMenu=RunAnyZz . "File" . TREE_NO 
		? "新增项会在『根目录』分类下（如果没有用“-”回归1级会添加在最末的菜单内）" 
		: "新增项会在『" Z_ThisMenu "』分类下"
	gosub,Menu_Item_Edit
return
;~;[保存新添加的菜单项]
SetSaveItem:
	Gui,SaveItem:Submit,NoHide
	saveText:=tabText:=itemGlobalKeyStr:=""
	menuFlag:=false		;判断是否定位到要插入的菜单位置
	endFlag:=false		;判断是否插入到末尾
	rootFlag:=true		;判断是否为根目录
	inputFlag:=false	;判断是否插入
	itemIndex:=0
	splitStr:=vitemName && vitemPath ? "|" : ""
	if(vitemGlobalKey){
		if(!vitemName){
			MsgBox, 48, ,设置热键后必须填写菜单项名
			return
		}
		if(!vitemPath && InStr(vitemName,"-")!=1){
			MsgBox, 48, ,应用设置热键后必须填写启动路径
			return
		}
		itemGlobalKeySave:=vitemGlobalWinKey ? "#" . vitemGlobalKey : vitemGlobalKey
		itemGlobalKeyStr:=A_Tab . itemGlobalKeySave
		if(vitemGlobalKey!=itemGlobalKey || vitemGlobalWinKey!=itemGlobalWinKey){
			if(InStr(iniVar1,itemGlobalKeyStr "|") || InStr(iniVar2,itemGlobalKeyStr "|")){
				MsgBox, 48, ,该全局热键已经被其他菜单应用使用
				return
			}
		}
	}
	;保存热字符串
	if(vhotStrShow){
		if(vhotStrShow!=hotStrShow || vhotStrOption!=hotStrOption){
			vhotStrSave:=vhotStrOption ? vhotStrOption . vhotStrShow : ":*X:" vhotStrShow
			if(InStr(iniVar1,vhotStrSave "|") || InStr(iniVar2,vhotStrSave "|")){
				MsgBox, 48, ,该热字符串已经被其他菜单应用使用
				return
			}
		}
		vitemName.=vhotStrSave
	}
	Gui,SaveItem:Destroy
	;[读取菜单内容插入新菜单项到RunAny.ini]
	Loop, parse, iniFileVar, `n, `r
	{
		itemContent=%A_LoopField%
		if(InStr(itemContent,"-")=1){
			rootFlag:=false
			treeContent:=Get_Tree_Name(itemContent,false)
			if(itemContent="-")
				rootFlag:=true
			if(treeContent=Z_ThisMenu){	;定位到要插入的菜单位置
				menuFlag:=true
				;计算出前面添加的制表符数量
				treeLevel:=StrLen(RegExReplace(itemContent,"S)(^-+).+","$1"))
				tabText:=Set_Tab(treeLevel)
			}
		}else if(rootFlag && (Z_ThisMenu=RunAnyZz . TREE_NO)){	;如果要添加到根目录
			menuFlag:=true
		}
		if(menuFlag){
			menuItem:=Get_Obj_Transform_Name(itemContent)
			if(menuItem=Z_ThisMenuItem){
				if(X_ThisMenuItem!=RUNANY_SELF_MENU_ITEM3){
					saveText.=tabText . vitemName . itemGlobalKeyStr . splitStr . vitemPath . "`n"
					inputFlag:=true
				}else{
					endFind:=true
				}
				menuFlag:=false
			}else if (Z_ThisMenuItem="" && (X_ThisMenuItem="" || X_ThisMenuItem=RUNANY_SELF_MENU_ITEM3)){
				endFind:=true
				menuFlag:=false
			}
		}
		saveText.=A_LoopField . "`n"
		if(endFind && !inputFlag){
			saveText.=tabText . vitemName . itemGlobalKeyStr . splitStr . vitemPath . "`n"
			endFind:=false
			inputFlag:=true
		}
	}
	if(saveText){
		if(!inputFlag){
			saveText.=tabText . vitemName . itemGlobalKeyStr . splitStr . vitemPath . "`n"
		}
		stringtrimright, saveText, saveText, 1
		FileDelete,%iniFileShow%
		FileAppend,%saveText%,%iniFileShow%
		gosub,Menu_Reload
	}
return
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
;~;【——菜单配置Gui——】
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
Menu_Edit_Gui:
	global TVFlag:=false
	global FailFlag:=false
	;[功能菜单初始化]
	treeRoot:=Object()
	global moveRoot:=Object()
	moveRoot[1]:="moveMenu" . both
	Menu,% moveRoot[1],add
	global moveLevel:=0
	;[树型菜单初始化]
	Gui, MenuEdit:Destroy
	Gui, MenuEdit:Default
	Gui, MenuEdit:+Resize
	Gui, MenuEdit:Font,s10, Microsoft YaHei
	Gui, MenuEdit:Add, TreeView,vRunAnyTV w600 r30 -Readonly AltSubmit Checked hwndHTV gTVClick ImageList%TreeImageListID%
	Gui, MenuEdit:Add, Progress,vMyProgress w450 cBlue
	GuiControl, MenuEdit:Hide, MyProgress
	GuiControl, MenuEdit:-Redraw, RunAnyTV
	Tv:=new treeview(HTV)
	;[读取菜单配置内容写入树形菜单]
	Loop, parse, iniFileVar, `n, `r, %A_Space%%A_Tab%
	{
		if(A_LoopField=""){
			continue
		}
		if(InStr(A_LoopField,"-")=1){
			;[生成节点树层级结构]
			treeLevel:=StrLen(RegExReplace(A_LoopField,"S)(^-+).+","$1"))
			if(RegExMatch(A_LoopField,"S)^-+[^-]+.*")){
				if(treeLevel=1){
					treeRoot.InsertAt(treeLevel,TV_Add(A_LoopField,,Set_Icon(TreeImageListID,A_LoopField,false)))
				}else{
					treeRoot.InsertAt(treeLevel,TV_Add(A_LoopField,treeRoot[treeLevel-1],Set_Icon(TreeImageListID,A_LoopField,false)))
				}
				TV_MoveMenu(A_LoopField)
			}else if(A_LoopField="-"){
				treeLevel:=0
				TV_Add(A_LoopField,,"Bold Icon8")
			}else{
				TV_Add(A_LoopField,treeRoot[treeLevel],"Bold Icon8")
			}
		}else if(A_LoopField="|" || A_LoopField="||"){
			TV_Add(A_LoopField,treeRoot[treeLevel],"Bold Icon8")
		}else if(InStr(A_LoopField,";")=1){
			hwnd:=TV_Add(A_LoopField,treeRoot[treeLevel],"Icon8")
			Tv.modify({hwnd:hwnd,fore:0x00A000})
		}else{
			FailFlag:=false
			itemIcon:=Set_Icon(TreeImageListID,A_LoopField,false)
			hwnd:=TV_Add(A_LoopField,treeRoot[treeLevel],itemIcon)
			if(itemIcon="Icon3" || FailFlag){
				Tv.modify({hwnd:hwnd,fore:0x999999})
			}
		}
	}
	GuiControl, MenuEdit:+Redraw, RunAnyTV
	try Menu,TVMenu,Delete
	TVMenu("TVMenu")
	TVMenu("GuiMenu")
	Gui, MenuEdit:Menu, GuiMenu
	Gui, MenuEdit:Show, , %RunAnyZz%菜单树管理【%both%】%RunAny_update_version% %RunAny_update_time%%AdminMode%(双击修改，右键操作)
	if(TVEditItem!=""){
		ItemEdit:=Get_Obj_Name(TVEditItem)
		ItemID = 0
		Loop
		{
			ItemID := TV_GetNext(ItemID, "Full")
			if not ItemID
				break
			TV_GetText(ItemText, ItemID)
			ItemName:=Get_Obj_Transform_Name(ItemText)
			if(ItemName=ItemEdit){
				TV_Modify(ItemID, "Expand Select")
				selIDTVEdit:=ItemID
				gosub,TVEdit
			}
		}
	}
return
Menu_Edit1:
	both:=1
	iniFileWrite:=iniPath
	iniFileVar:=iniVar1
	gosub,Menu_Edit_Gui
return
Menu_Edit2:
	both:=2
	iniFileWrite:=iniPath2
	iniFileVar:=iniVar2
	gosub,Menu_Edit_Gui
return
#If WinActive(RunAnyZz "菜单树管理【" both "】")
	F5::
	PGDN::
		gosub,TVDown
		return
	F6::
	PGUP::
		gosub,TVUp
		return
	F3::gosub,TVAdd
	F4::gosub,TVAddTree
	F8::gosub,TVImportFile
	F9::gosub,TVImportFolder
	^s::gosub,TVSave
	Esc::gosub,MenuEditGuiClose
	F2::gosub,TVEdit
	Tab::Send_Str_Zz(A_Tab)
#If
;~;[创建头部及右键功能菜单]
TVMenu(addMenu){
	flag:=addMenu="GuiMenu" ? true : false
	Menu, %addMenu%, Add,% flag ? "保存" : "保存`tCtrl+S", TVSave
	Menu, %addMenu%, Icon,% flag ? "保存" : "保存`tCtrl+S", SHELL32.dll,194
	Menu, %addMenu%, Add,% flag ? "添加应用" : "添加应用`tF3", TVAdd
	Menu, %addMenu%, Icon,% flag ? "添加应用" : "添加应用`tF3", SHELL32.dll,3
	Menu, %addMenu%, Add,% flag ? "添加分类" : "添加分类`tF4", TVAddTree
	Menu, %addMenu%, Icon,% flag ? "添加分类" : "添加分类`tF4", SHELL32.dll,4
	Menu, %addMenu%, Add,% flag ? "编辑" : "编辑`tF2", TVEdit
	Menu, %addMenu%, Icon,% flag ? "编辑" : "编辑`tF2", SHELL32.dll,134
	Menu, %addMenu%, Add,% flag ? "删除" : "删除`tDel", TVDel
	Menu, %addMenu%, Icon,% flag ? "删除" : "删除`tDel", SHELL32.dll,132
	if(!flag)
		Menu, %addMenu%, Add,注释, TVComments
	;~ Menu, %addMenu%, Add
	Menu, %addMenu%, Add,移动到..., :moveMenu%both%
	try Menu, %addMenu%, Icon,移动到...,% MoveIconS[1],% MoveIconS[2]
	Menu, %addMenu%, Add,% flag ? "向下" : "向下`t(F5/PgDn)", TVDown
	try Menu, %addMenu%, Icon,% flag ? "向下" : "向下`t(F5/PgDn)",% DownIconS[1],% DownIconS[2]
	Menu, %addMenu%, Add,% flag ? "向上" : "向上`t(F6/PgUp)", TVUp
	try Menu, %addMenu%, Icon,% flag ? "向上" : "向上`t(F6/PgUp)",% UpIconS[1],% UpIconS[2]
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
TVClick:
	if (A_GuiEvent == "e"){
		;~;完成编辑时
		TV_GetText(selVar, A_EventInfo)
		TV_Modify(A_EventInfo, Set_Icon(TreeImageListID,selVar))
		if(addID && RegExMatch(selVar,"S)^-+[^-]+.*")){
			insertID:=TV_Add("",A_EventInfo)
			TV_Modify(A_EventInfo, "Bold Expand")
			TV_Modify(insertID, "Select Vis")
			SendMessage, 0x110E, 0, TV_GetSelection(), , ahk_id %HTV%
			addID:=
			TV_MoveMenuClean()
		}
		TVFlag:=true
	}else if (A_GuiEvent == "K"){
		if (A_EventInfo = 46)
			gosub,TVDel
	}else if (A_GuiEvent == "DoubleClick"){
		TV_GetText(selVar, A_EventInfo)
		if(!RegExMatch(selVar,"S)^-+[^-]+.*"))
			gosub,TVEdit
	}else if (A_GuiControl = "RunAnyTV") {
		TV_Modify(A_EventInfo, "Select Vis")
		TV_CheckUncheckWalk(A_GuiEvent,A_EventInfo,A_GuiControl)
	}
return
TVAdd:
	selID:=TV_Add("",TV_GetParent(TV_GetSelection()),TV_GetSelection())
	itemGlobalWinKey:=0
	itemName:=itemPath:=hotStrOption:=hotStrShow:=itemGlobalHotKey:=itemGlobalKey:=getZz:=""
	menuGuiFlag:=true
	menuGuiEditFlag:=false
	gosub,Menu_Item_Edit
return
TVAddTree:
	selID:=TV_Add("",TV_GetParent(TV_GetSelection()),TV_GetSelection())
	TV_GetText(parentTreeName, TV_GetParent(TV_GetSelection()))
	itemName:=RegExReplace(parentTreeName,"S)(^-+).*","$1") "-"
	itemGlobalWinKey:=0
	itemPath:=hotStrOption:=hotStrShow:=itemGlobalHotKey:=itemGlobalKey:=getZz:=""
	menuGuiFlag:=true
	menuGuiEditFlag:=false
	ToolTip,% "菜单分类开头是" itemName "表示新建 " StrLen(itemName) "级目录",195,270
	SetTimer,RemoveToolTip,5000
	gosub,Menu_Item_Edit
return
TVEdit:
	selID:=TV_GetSelection()
	if(selIDTVEdit!="")
		selID:=selIDTVEdit
	TV_GetText(ItemText, selID)
	;分解已有菜单项到编辑框中
	gosub,TVEdit_GuiVal
	menuGuiFlag:=true
	menuGuiEditFlag:=true
	selIDTVEdit:=""
	if(RunCtrlMenuItemFlag){
		Gui, MenuEdit:Destroy
		GuiControlSet("CtrlRun","vRunCtrlRunValue",itemName!="" ? itemName : itemPath)
		RunCtrlMenuItemFlag:=false
	}else{
		gosub,Menu_Item_Edit
	}
return
TVEdit_GuiVal:
	itemGlobalWinKey:=itemTrNum:=setItemMode:=0
	itemName:=itemPath:=hotStrOption:=hotStrShow:=itemGlobalHotKey:=itemGlobalKey:=getZz:=""
	if(ItemText="|" || ItemText=";|" || ItemText="||" || ItemText=";||"){
		itemPath:=ItemText
	}else if(InStr(ItemText,"|") || InStr(ItemText,"-")=1){
		menuDiy:=StrSplit(ItemText,"|",,2)
		itemName:=menuDiy[1]
		itemPath:=menuDiy[2]
		;[分割Tab获取应用自定义热键]
		menuKeyStr:=RegExReplace(menuDiy[1], "S)\t+", A_Tab)
		menuKeys:=StrSplit(menuKeyStr,"`t")
		itemName:=menuKeys[1]
		if(InStr(menuKeyStr,"`t") && menuKeys[2]){
			itemGlobalHotKey:=menuKeys[2]
			itemGlobalKey:=menuKeys[2]
			if(InStr(menuKeys[2],"#")){
				itemGlobalWinKey:=1
				itemGlobalKey:=StrReplace(menuKeys[2], "#")
			}
		}
		;[设置透明度]
		if(RegExMatch(itemName,"S).*?_:(\d{1,2})$")){
			itemTrNum:=RegExReplace(itemName,"S).*?_:(\d{1,2})$","$1")
			itemName:=RegExReplace(itemName,"S)(.*)_:\d{1,2}$","$1")
		}
		;[设置热字符串启动方式]
		if(RegExMatch(itemName,"S):[*?a-zA-Z0-9]+?:[^:]*")){
			hotStr:=RegExReplace(itemName,"S)^[^:]*?(:[*?a-zA-Z0-9]+?:[^:]*)","$1")
			hotStrOption:=RegExReplace(hotstr,"S)^(:[*?a-zA-Z0-9]+?:)[^:]*","$1")
			hotStrShow:=RegExReplace(hotstr,"S)^:[^:]*?X[^:]*?:")
			itemName:=RegExReplace(itemName,"S)^([^:]*?):[*?a-zA-Z0-9]+?:[^:]*","$1")
		}
	}else{
		itemPath:=ItemText
	}
return
;~;【新增修改菜单项Gui】
Menu_Item_Edit:
	SaveLabel:=menuGuiFlag ? "SetSaveItemGui" : "SetSaveItem"
	PromptStr:=menuGuiFlag ? "需要" : "点击此处"
	setItemMode:=Get_Menu_Item_Mode(ItemText,true)
	If(setItemMode=2 || setItemMode=3){
		itemPath:=StrReplace(itemPath,"``t","`t")
		itemPath:=StrReplace(itemPath,"``n","`n")
	}
	if(InStr(itemName,"-")){
		treeYNum:=20
		itemNameText:="菜单分类"
	}else{
		treeYNum:=10
		itemNameText:="菜单项名"
	}
	SplitPath, itemPath, fName,, fExt, name_no_ext
	itemIconName:=itemName ? itemName : name_no_ext
	itemIconFile:=IconFolderList[menuItemIconFileName(itemIconName)]
	Gui,SaveItem:Destroy
	if(menuGuiFlag)
		Gui,SaveItem:+ownerMenuEdit
	Gui,SaveItem:Margin,20,20
	Gui,SaveItem:+Resize
	Gui,SaveItem:Font,,Microsoft YaHei
	Gui,SaveItem:Add, Text, xm+10 y+20 y20 w60, %itemNameText%：
	Gui,SaveItem:Add, Edit, x+5 yp-3 w350 vvitemName GEditItemPathChange, %itemName%
	Gui,SaveItem:Add, Picture, x+50 yp+3 w64 h-1 vvPictureIconAdd gSetItemIconPath, %itemIconFile%
	Gui,SaveItem:Add, Text,yp+8 w72 cGreen vvTextIconAdd gSetItemIconPath BackgroundTrans, 点击添加图标
	Gui,SaveItem:Add, Text,yp w72 cGreen vvTextIconDown gSetItemIconDown BackgroundTrans, 下载网站图标
	if(!InStr(itemName,"-")){
		Gui,SaveItem:Add, Text, xm+10 y+4 w60 vvTextHotStr, 热字符串：
		Gui,SaveItem:Font,,Consolas
		Gui,SaveItem:Add, Edit, x+5 yp-1 w60 vvhotStrOption, % hotStrShow="" ? ":*X:" : hotStrOption
		Gui,SaveItem:Add, Edit, x+5 yp w90 vvhotStrShow GHotStrShowChange, %hotStrShow%
		Gui,SaveItem:Font,,Microsoft YaHei
		Gui,SaveItem:Add, Text, x+5 yp+3 w55 vvTextTransparent,透明度(`%)
		Gui,SaveItem:Add, Slider, x+5 yp ToolTip w135 r1 vvitemTrNum,%itemTrNum%
	}
	Gui,SaveItem:Add,Text, xm+10 y+%treeYNum%+10 w100, 制 表 符 ：  Tab
	Gui,SaveItem:Add,Text, xm+10 y+%treeYNum% w60, 全局热键：
	Gui,SaveItem:Add,Hotkey,x+5 yp-3 w150 vvitemGlobalKey,%itemGlobalKey%
	Gui,SaveItem:Add,Checkbox,Checked%itemGlobalWinKey% x+5 yp+3 vvitemGlobalWinKey,Win
	Gui,SaveItem:Add,Text, x+5 yp cBlue w200 BackgroundTrans, %itemGlobalHotKey%
	Gui,SaveItem:Add,Text, xm+10 y+15 w100, 分 隔 符 ：  |
	Gui,SaveItem:Add,Text, xm+90 yp w355 cRed vvExtPrompt GSetSaveItemFullPath, 注意：RunAny不支持当前后缀无路径运行，%PromptStr%使用全路径
	Gui,SaveItem:Add, DropDownList,x+30 yp-5 w120 AltSubmit vvItemMode GChooseItemMode Choose%setItemMode%,启动路径|短语模式|模拟打字短语|热键映射|AHK热键映射|网址|文件夹|插件脚本函数
	
	Gui,SaveItem:Add,Text, xm+10 yp w60 vvSetFileSuffix,文件后缀：
	Gui,SaveItem:Add,Button, xm+6 y+%treeYNum% w60 vvSetItemPath GSetItemPath,启动路径
	Gui,SaveItem:Font,,Consolas
	Gui,SaveItem:Add,Edit, x+10 yp WantTab w510 r5 vvitemPath GEditItemPathChange, %itemPath%
	Gui,SaveItem:Font,,Microsoft YaHei
	Gui,SaveItem:Add,Button, xm+6 yp w60 vvSetMenuPublic GSetMenuPublic,公共菜单
	Gui,SaveItem:Add,Button, xm+6 yp w60 vvSetMenuText GSetMenuText,文本菜单
	Gui,SaveItem:Add,Button, xm+6 yp w60 vvSetMenuFile GSetMenuFile,文件菜单
	Gui,SaveItem:Add,Button, xm+6 yp+27 w60 vvSetFileRelativePath GSetFileRelativePath,相对路径
	Gui,SaveItem:Add,Button, xm+6 yp+27 w60 vvSetItemPathGetZz GSetItemPathGetZz,选中变量
	Gui,SaveItem:Add,Button, xm+6 yp+27 w60 vvSetItemPathClipboard GSetItemPathClipboard, 剪贴板 
	Gui,SaveItem:Add,Button, xm+6 yp+27 w60 vvSetShortcut GSetShortcut,快捷目标
	Gui,SaveItem:Add,Button, xm+6 yp+27 w60 vvSetSendStrEncrypt GSetSendStrEncrypt,加密短语

	Gui,SaveItem:Add,Button,Default xm+220 y+15 w75 vvSaveItemSaveBtn G%SaveLabel%,保存
	Gui,SaveItem:Add,Button,x+20 w75 vvSaveItemCancelBtn GSetCancel,取消
	Gui,SaveItem:Add,Text, xm+10 w590 cBlue vvStatusBar, %thisMenuStr% %thisMenuItemStr%
	Gui,SaveItem:Show,H365,新增修改菜单项 - %RunAnyZz% - 支持拖放应用
	GuiControl,SaveItem:Hide, vExtPrompt
	if(fExt!="lnk")
		GuiControl,SaveItem:Hide, vSetShortcut
	if(itemIconFile || setItemMode!=6){
		GuiControl,SaveItem:Hide, vTextIconDown
		if(itemIconFile){
			GuiControl,SaveItem:Hide, vTextIconAdd
		}
	}
	if(hotStrShow=""){
		GuiControl,SaveItem:Hide, vhotStrOption
		GuiControl,SaveItem:Move, vhotStrShow, x95 y47
	}
	itemNameText:=thisMenuStr:=thisMenuItemStr:=""
	gosub,EditItemPathChange
return
;[保存新增修改菜单项内容]
SetSaveItemGui:
	Gui,SaveItem:Submit,NoHide
	itemGlobalKeyStr:=""
	if(vitemGlobalKey){
		if(!vitemName){
			MsgBox, 48, ,设置热键后必须填写菜单项名
			return
		}
		if(!vitemPath && InStr(vitemName,"-")!=1){
			MsgBox, 48, ,应用设置热键后必须填写启动路径
			return
		}
		itemGlobalKeySave:=vitemGlobalWinKey ? "#" . vitemGlobalKey : vitemGlobalKey
		itemGlobalKeyStr:=A_Tab . itemGlobalKeySave
		if(vitemGlobalKey!=itemGlobalKey || vitemGlobalWinKey!=itemGlobalWinKey){
			if(InStr(iniVar1,itemGlobalKeyStr "|") || InStr(iniVar2,itemGlobalKeyStr "|")){
				MsgBox, 48, ,该全局热键已经被其他菜单应用使用
				return
			}
		}
	}
	;保存热字符串
	if(vhotStrShow){
		if(vhotStrShow!=hotStrShow || vhotStrOption!=hotStrOption){
			vhotStrSave:=vhotStrOption ? vhotStrOption . vhotStrShow : ":*X:" vhotStrShow
			if(InStr(iniVar1,vhotStrSave "|") || InStr(iniVar2,vhotStrSave "|")){
				MsgBox, 48, ,该热字符串已经被其他菜单应用使用
				return
			}
		}
		vitemName.=vhotStrSave
	}
	if(vitemTrNum && vitemTrNum<100){
		vitemName.="_:" vitemTrNum
	}
	splitStr:=vitemName && vitemPath ? "|" : ""
	vitemPath:=StrReplace(vitemPath,"`t","``t")
	vitemPath:=StrReplace(vitemPath,"`n","``n")
	saveText:=vitemName . itemGlobalKeyStr . splitStr . vitemPath
	Gui,SaveItem:Destroy
	Gui,MenuEdit:Default
	TV_Modify(selID, , saveText)
	TV_Modify(selID, "Select Vis")
	TV_Modify(selID, Set_Icon(TreeImageListID,saveText))
	if(ItemText!=saveText)
		TVFlag:=true
	if(!menuGuiEditFlag && selID && RegExMatch(saveText,"S)^-+[^-]+.*")){
		insertID:=TV_Add("",selID)
		TV_Modify(selID, "Bold Expand")
		TV_Modify(insertID, "Select Vis")
		SendMessage, 0x110E, 0, TV_GetSelection(), , ahk_id %HTV%
		addID:=
		TV_MoveMenuClean()
	}
return
#If WinActive("新增修改菜单项 - " RunAnyZz " - 支持拖放应用")
	~^v::
		if(InStr(Clipboard,"|")){
			Sleep,200
			ItemText:=Trim(Clipboard)
			MsgBox,36,,是否需要把RunAny菜单项值，自动添加到各个编辑框中？
			IfMsgBox Yes
			{
				gosub,TVEdit_GuiVal
				GuiControlSet("SaveItem","vitemGlobalKey",itemGlobalKey)
				GuiControlSet("SaveItem","vitemPath",itemPath)
				Gui,SaveItem:Submit, NoHide
				if(itemGlobalKey!="" && vitemGlobalKey=""){
					MsgBox, 48,,% itemGlobalHotKey "`n无法设置到全局热键的编辑框里，变为保存在菜单项名中`n"
					. "建议有特殊热键的菜单项，后续修改直接打开RunAny.ini来编辑生效"
					GuiControlSet("SaveItem","vitemName",menuDiy[1])
					GuiControlSet("SaveItem","vhotStrOption")
					GuiControlSet("SaveItem","vhotStrShow")
					GuiControlSet("SaveItem","vitemTrNum")
					GuiControlSet("SaveItem","vitemGlobalWinKey")
					Sleep,200
					GuiControlHide("SaveItem","vhotStrOption","vhotStrShow","vitemTrNum","vitemGlobalKey","vitemGlobalWinKey")
				}else{
					GuiControlSet("SaveItem","vitemName",itemName)
					GuiControlSet("SaveItem","vhotStrOption",hotStrOption)
					GuiControlSet("SaveItem","vhotStrShow",hotStrShow)
					GuiControlSet("SaveItem","vitemTrNum",itemTrNum)
					GuiControlSet("SaveItem","vitemGlobalWinKey",itemGlobalWinKey)
				}
			}
		}
	return
#If
EditItemPathChange:
	Gui,SaveItem:Submit, NoHide
	if(InStr(vitemName,"-")=1){
		GuiControlHide("SaveItem","vItemMode","vSetItemPath","vSetFileRelativePath","vSetItemPathGetZz","vSetItemPathClipboard","vSetShortcut")
		GuiControlShow("SaveItem","vSetFileSuffix","vSetMenuPublic","vSetMenuText","vSetMenuFile")
		GuiControl,SaveItem:Move, vSetFileSuffix, y+160
		GuiControl,SaveItem:Move, vSetMenuPublic, y+190
		GuiControl,SaveItem:Move, vSetMenuText, y+220
		GuiControl,SaveItem:Move, vSetMenuFile, y+250
	}else{
		GuiControlHide("SaveItem","vSetFileSuffix","vSetMenuPublic","vSetMenuText","vSetMenuFile")
		GuiControlShow("SaveItem","vItemMode","vSetItemPath","vSetFileRelativePath","vSetItemPathGetZz","vSetItemPathClipboard")
		filePath:=!vitemPath && vitemName ? vitemName : vitemPath
		itemPathMode:=StrReplace(filePath,"%getZz%",Chr(3))
		itemPathMode:=Get_Transform_Val(itemPathMode)
		getItemMode:=Get_Menu_Item_Mode(itemPathMode)
		if(filePath){
			if(getItemMode!=1 || EvDemandSearch || Check_Obj_Ext(filePath)){
				GuiControl, SaveItem:Hide, vExtPrompt
			}else{
				GuiControl, SaveItem:Show, vExtPrompt
			}
			fileValue:=RegExReplace(filePath,"iS)(.*?\..*?)($| .*)","$1")	;去掉参数
			SplitPath, fileValue, fName,, fExt  ; 获取扩展名
			if(fExt="exe" || fExt="lnk"){
				GuiControlShow("SaveItem","vTextTransparent","vitemTrNum")
				if(fExt="lnk")
					GuiControlShow("SaveItem","vSetShortcut")
			}else{
				GuiControlHide("SaveItem","vTextTransparent","vitemTrNum")
			}
		}
		GuiControl, SaveItem:Choose, vItemMode,% getItemMode=60 ? 1 : getItemMode
	}
	if(SendStrDcKey!="" && encryptFlag && (getItemMode=2 || getItemMode=3)){
		GuiControlShow("SaveItem","vSetSendStrEncrypt")
	}else{
		GuiControlHide("SaveItem","vSetSendStrEncrypt")
	}
return
HotStrShowChange:
	Gui,SaveItem:Submit, NoHide
	if(vhotStrShow){
		GuiControl,SaveItem:Show, vhotStrOption
		GuiControl,SaveItem:Move, vhotStrShow, x160 y47
	}
return
;[启动模式变换]
ChooseItemMode:
	Gui,SaveItem:Submit, NoHide
	itemPathMode:=StrReplace(vitemPath,"%getZz%",Chr(3))
	itemPathMode:=Get_Transform_Val(itemPathMode)
	getItemMode:=Get_Menu_Item_Mode(itemPathMode)
	if((vItemMode=1 || vItemMode!=2) && getItemMode=2){	;清除短语
		StringTrimRight, vitemPath, vitemPath, 1
	}else if((vItemMode=1 || vItemMode!=3) && getItemMode=3){		;清除打字短语
		StringTrimRight, vitemPath, vitemPath, 2
	}else if((vItemMode=1 || vItemMode!=4) && getItemMode=4){		;清除热键映射
		StringTrimRight, vitemPath, vitemPath, 2
	}else if((vItemMode=1 || vItemMode!=5) && getItemMode=5){		;清除AHK热键映射
		StringTrimRight, vitemPath, vitemPath, 3
	}
	if(InStr(vitemName,"-"))
		return
	if(vItemMode=2 && getItemMode!=2){
		vitemPath.=";"
		GuiControl, SaveItem:,vStatusBar,此模式可把保存的短语 输出到任意位置
	}else if(vItemMode=3 && getItemMode!=3){
		vitemPath.=";;"
		GuiControl, SaveItem:,vStatusBar,此模式除输出短语外 ``n和``r转换为Enter键击  ``t转换为Tab键击  ``b转换为Backspace键击
	}else if(vItemMode=4 && getItemMode!=4){
		vitemPath.="::"
		GuiControl, SaveItem:,vStatusBar,此模式可以模拟人手发送键击 把全局热键映射成其他热键 ^代表Ctrl键 !代表Alt键 #代表Win键 +代表Shift键
	}else if(vItemMode=5 && getItemMode!=5){
		vitemPath.=":::"
		GuiControl, SaveItem:,vStatusBar,此模式可以映射发送任意已运行AHK脚本中的热键键击
	}
	GuiControl, SaveItem:, vitemPath, %vitemPath%
	gosub,EditItemPathChange
return
SetMenuPublic:
	Gui,SaveItem:Submit, NoHide
	GuiControl, SaveItem:, vStatusBar,有public的菜单分类在任意不同情况菜单中都会显示
	GuiControl, SaveItem:, vitemPath, %vitemPath% public
return
SetMenuFile:
	Gui,SaveItem:Submit, NoHide
	GuiControl, SaveItem:, vStatusBar,有file的菜单分类会在选中文件内容的时候显示
	GuiControl, SaveItem:, vitemPath, %vitemPath% file
return
SetMenuText:
	Gui,SaveItem:Submit, NoHide
	GuiControl, SaveItem:, vStatusBar,有text的菜单分类会在选中文本内容的时候显示
	GuiControl, SaveItem:, vitemPath, %vitemPath% text
return
SetItemPath:
	FileSelectFile, fileSelPath, , , 启动文件路径
	if(fileSelPath){
		GuiControl, SaveItem:, vitemPath, % Get_Item_Run_Path(fileSelPath)
		gosub,EditItemPathChange
	}
return
SetItemPathGetZz:
	GuiControl, SaveItem:, vStatusBar,`%getZz`%在运行时会转换为你鼠标选中的文本内容
	GuiControl, SaveItem:Focus, vitemPath
	Send_Str_Zz("%getZz%")
return
SetItemPathClipboard:
	GuiControl, SaveItem:, vStatusBar,`%Clipboard`%在运行时会转换为剪贴板里的文本内容
	GuiControl, SaveItem:Focus, vitemPath
	Send_Str_Zz("%Clipboard%")
return
SetSendStrEncrypt:
	Gui,SaveItem:Submit, NoHide
	if(vItemMode=2){
		if(RegExMatch(vitemPath,"S).+\$;$")){
			vitemPath:=RegExReplace(vitemPath,"\$;$")
			GuiControl, SaveItem:, vitemPath, % SendStrDecrypt(vitemPath) ";"
			return
		}
		vitemPath:=RegExReplace(vitemPath,";$")
		GuiControl, SaveItem:, vitemPath, % SendStrEncrypt(vitemPath) "$;"
	}else if(vItemMode=3){
		if(RegExMatch(vitemPath,"S).+\$;;$")){
			vitemPath:=RegExReplace(vitemPath,"\$;;$")
			GuiControl, SaveItem:, vitemPath, % SendStrDecrypt(vitemPath) ";;"
			return
		}
		vitemPath:=RegExReplace(vitemPath,";;$")
		GuiControl, SaveItem:, vitemPath, % SendStrEncrypt(vitemPath) "$;;"
	}
return
;[全路径转换为RunAnyCtrl的相对路径]
SetFileRelativePath:
	Gui,SaveItem:Submit, NoHide
	if(InStr(vitemPath,"`%A_ScriptDir`%\")=1){
		funcResult:=RegExReplace(vitemPath,"S)^`%A_ScriptDir`%\\")
		funcResult:=funcPath2AbsoluteZz(funcResult,A_ScriptFullPath)
		headPath=
	}else{
		headPath=`%A_ScriptDir`%\
		funcResult:=funcPath2RelativeZz(vitemPath,A_ScriptFullPath)
	}
	if(funcResult=-1){
		GuiControl, SaveItem:,vStatusBar,路径有误
		return
	}
	if(funcResult=-2){
		GuiControl, SaveItem:,vStatusBar,与RunAny不在同一磁盘，不能转换为相对路径
		return
	}
	if(funcResult){
		GuiControl, SaveItem:, vitemPath, %headPath%%funcResult%
		gosub,EditItemPathChange
	}
return
SetItemIconPath:
	Gui,SaveItem:Submit, NoHide
	if(!vitemName && !vitemPath){
		MsgBox, 48, ,菜单项名和启动路径不能同时为空时设置图标
		return
	}
	FileSelectFile, iconSelPath, , , 图标文件路径, (%IconFileSuffix%)
	if(iconSelPath){
		SplitPath, vitemPath, fName,, fExt, name_no_ext
		itemIconName:=vitemName ? vitemName : name_no_ext
		itemIconName:=menuItemIconFileName(itemIconName)
		if(FileExist(itemIconFile) && iconSelPath!=itemIconFile){
			IfNotExist %A_Temp%\%RunAnyZz%\RunIcon
				FileCreateDir,%A_Temp%\%RunAnyZz%\RunIcon
			SplitPath, itemIconFile, iName
			FileMove,%itemIconFile%,%A_Temp%\%RunAnyZz%\RunIcon\%iName%,1
		}
		if(RegExMatch(vitemPath,"iS)([\w-]+://?|www[.]).*")){
			iconCopyDir:=WebIconDir
		}else{
			iconCopyDir:=ExeIconDir
		}
		SplitPath, iconSelPath,,, iExt
		FileCopy, %iconSelPath%, %iconCopyDir%\%itemIconName%.%iExt%, 1
		gosub,SetSaveItemGui
	}
return
SetItemIconDown:
	try {
		Gui,SaveItem:Submit, NoHide
		if(!vitemName && !vitemPath){
			MsgBox, 48, ,菜单项名和启动路径不能同时为空时设置图标
			return
		}
		if(RegExMatch(vitemPath,"iS)^([\w-]+://?|www[.]).*")){
			website:=RegExReplace(vitemPath,"iS)[\w-]+://?((\w+\.)+\w+).*","$1")
			webIcon:=WebIconDir "\" menuItemIconFileName(vitemName) ".ico"
			InputBox, webSiteInput, 下载网站图标,确认或修改下面的默认地址并下载图标ico文件`n`n如果下载错误或界面变空要重新下载图标`n`n请打开【修改菜单】界面选中后点“网站图标”按钮,,,,,,,,http://%website%/favicon.ico
			if !ErrorLevel
			{
				URLDownloadToFile(webSiteInput,webIcon)
				MsgBox,65,,图标下载成功，是否要重新打开RunAny生效？
				IfMsgBox Ok
					gosub,Menu_Reload
			}
		}
	} catch e {
		WebsiteIconError(webSiteInput)
	}
return
SetSaveItemFullPath:
	if(getZz && !menuGuiFlag){
		GuiControl, SaveItem:, vitemPath, %getZz%
		GuiControl, SaveItem:Hide, vPrompt
	}
return
SetShortcut:
	Gui,SaveItem:Submit, NoHide
	filePath:=!vitemPath && vitemName ? vitemName : vitemPath
	filePath:=Get_Obj_Path(filePath)	;补全路径
	if(!filePath)	;如果没补全，还原原选中文件地址
		filePath:=getZz
	SplitPath, filePath, ,, fExt  ; 获取扩展名
	if(filePath && fExt="lnk"){
		FileGetShortcut, %filePath%, exePath, OutDir, exeArgs
		exeArgs:=exeArgs ? A_Space exeArgs : ""
		if(exePath){
			GuiControl, SaveItem:, vitemPath, %exePath%%exeArgs%
		}
	}else{
		gosub,SetSaveItemFullPath
	}
	gosub,EditItemPathChange
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
		DelListID.Push(CheckID)
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
TVComments:
	CheckID = 0
	Loop
	{
		CheckID := TV_GetNext(CheckID, "Checked")
		if not CheckID
			break
		TV_GetText(ItemText, CheckID)
		if(InStr(ItemText,";")=1){
			StringTrimLeft, ItemText, ItemText, 1
			Tv.modify({hwnd:CheckID,fore:0x000000})
		}else{
			ItemText:=";" ItemText
			Tv.modify({hwnd:CheckID,fore:0x00A000})
		}
		TV_Modify(CheckID, ,ItemText)
	}
return
TVSave:
	MsgBox, 4131, 菜单树保存, 是：保存后重启生效`n否：保存重启后继续修改`n取消：取消保存
	IfMsgBox Yes
	{
		gosub,Menu_Save
		gosub,Menu_Reload
	}
	IfMsgBox No
	{
		gosub,Menu_Save
		RegWrite, REG_SZ, HKEY_CURRENT_USER, SOFTWARE\RunAny, ReloadGosub, Menu_Edit%both%
		gosub,Menu_Reload
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
	if(saveText){
		FileDelete,%iniFileWrite%
		FileAppend,%saveText%,%iniFileWrite%
	}
return
;[制表符设置]
Set_Tab(tabNum){
	tabText:=""
	Loop,%tabNum%
	{
		tabText.=A_Tab
	}
	return tabText
}
;~;[多选导入]
TVImportFile:
	selID:=TV_GetSelection()
	TV_GetText(ItemText, selID)
	if(InStr(ItemText,"-")=1){
		parentID:=selID
		TV_Modify(selID, "Bold Expand")
	}else{
		parentID:=TV_GetParent(selID)
	}
	FileSelectFile, exeName, M35, , 选择多项要导入的EXE(快捷方式), (*.exe;*.lnk)
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
			fileID:=TV_Add(I_LoopField,parentID,Set_Icon(TreeImageListID,exePath))
			TVFlag:=true
		}
	}
return
;~;[批量导入]
TVImportFolder:
	selID:=TV_GetSelection()
	TV_GetText(ItemText, selID)
	if(InStr(ItemText,"-")=1){
		parentID:=selID
		TV_Modify(selID, "Bold Expand")
	}else{
		parentID:=TV_GetParent(selID)
	}
	FileSelectFolder, folderName, , 0
	if(folderName){
		MsgBox,33,导入文件夹所有exe和lnk,确定导入  %folderName%  及子文件夹下所有程序和快捷方式吗？
		IfMsgBox Ok
		{
			Loop,%folderName%\*.lnk,0,1
			{
				lnkID:=TV_Add(A_LoopFileName,parentID,Set_Icon(TreeImageListID,A_LoopFileFullPath))
			}
			Loop,%folderName%\*.exe,0,1
			{
				folderID:=TV_Add(A_LoopFileName,parentID,Set_Icon(TreeImageListID,A_LoopFileFullPath))
			}
			TVFlag:=true
		}
	}
return
Website_Icon:
	IfNotExist %WebIconDir%
		FileCreateDir,%WebIconDir%
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
		selTextList.Push(ItemText)
	}
	if(selTextList.MaxIndex()=1){
		try {
			diyText:=StrSplit(ItemText,"|",,2)
			webText:=(diyText[2]) ? diyText[2] : diyText[1]
			if(RegExMatch(webText,"iS)^([\w-]+://?|www[.]).*")){
				website:=RegExReplace(webText,"iS)[\w-]+://?((\w+\.)+\w+).*","$1")
				webIcon:=WebIconDir "\" menuItemIconFileName(diyText[1]) ".ico"
				InputBox, webSiteInput, 重新下载网站图标,可以重新下载图标并匹配网址`n`n请修改以下网址再点击下载,,,,,,,,http://%website%/favicon.ico
				if !ErrorLevel
				{
					URLDownloadToFile(webSiteInput,webIcon)
					MsgBox,65,,图标下载成功，是否要重新打开RunAny生效？
					IfMsgBox Ok
						gosub,Menu_Reload
				}
			}
		} catch e {
			WebsiteIconError(webSiteInput)
		}
		return
	}
	if(selText){
		MsgBox,33,下载网站图标,确定下载以下选中的网站图标：`n(下载的图标在%WebIconDir%)`n%selText%
		IfMsgBox Ok
		{
			Loop,% selTextList.MaxIndex()
			{
				GuiControl, Show, MyProgress
				ItemText:=selTextList[A_Index]
				Gosub,Website_Icon_Down
			}
			if(errDown!="")
				WebsiteIconError(errDown)
			GuiControl, Hide, MyProgress
			MsgBox,65,,图标下载完成，是否要重新打开RunAny生效？
			IfMsgBox Ok
				gosub,Menu_Reload
		}
		return
	}
	MsgBox,33,下载网站图标,确定下载RunAny内所有网站图标吗？`n(下载的图标在%WebIconDir%)
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
			if(InStr(ItemText,";")=1 || ItemText="")
				continue
			GuiControl, Show, MyProgress
			Gosub,Website_Icon_Down
		}
		if(errDown!="")
			WebsiteIconError(errDown)
		GuiControl, Hide, MyProgress
		MsgBox,65,,图标下载完成，是否要重新打开RunAny生效？
		IfMsgBox Ok
			gosub,Menu_Reload
	}
return
Website_Icon_Down:
	try {
		diyText:=StrSplit(ItemText,"|",,2)
		webText:=(diyText[2]) ? diyText[2] : diyText[1]
		if(RegExMatch(webText,"iS)^([\w-]+://?|www[.]).*")){
			website:=RegExReplace(webText,"iS)[\w-]+://?((\w+\.)+\w+).*","$1")
			webIcon:=WebIconDir "\" menuItemIconFileName(diyText[1]) ".ico"
			URLDownloadToFile("http://" website "/favicon.ico",webIcon)
			GuiControl,, MyProgress, +10
		}
	} catch e {
		errDown.="http://" website "/favicon.ico`n"
	}
return
WebsiteIconError(errDown){
	MsgBox,以下网站图标无法下载，请单选后点[网站图标]按钮重新指定网址下载，`n或手动添加对应图标到[%WebIconDir%]`n`n%errDown%
}
;~;[上下移动项目]
TV_Move(moveMode = true){
	selID:=TV_GetSelection()
	moveID:=moveMode ? TV_GetNext(selID) : TV_GetPrev(selID)	; 向下：moveID为下个节点ID，向上：上个节点ID
	if(moveID!=0){
		TV_GetText(selVar, selID)
		TV_GetText(moveVar, moveID)
		selTreeFlag:=RegExMatch(selVar,"S)^-+[^-]+.*")
		moveTreeFlag:=RegExMatch(moveVar,"S)^-+[^-]+.*")
		selNextID:=moveMode ? moveID : TV_GetNext(selID)	; 向下：moveID即为树末节点，向上：选中树的下个同级节点为树末节点
		moveNextID:=!moveMode ? selID : TV_GetNext(moveID)	; 向上：selID即为树末节点，向下：目标树的下个同级节点为树末节点
		if((selTreeFlag || moveTreeFlag) && selNextID && moveNextID){
			DelListID:=Object()		; 需要删除的旧节点
			selTextList:=Object()	; 选中树的所有节点名列表
			moveTextList:=Object()	; 目标树的所有节点名列表
			ItemID:=selID
			Loop
			{
				ItemID := TV_GetNext(ItemID, "Full")
				if(ItemID=selNextID)	; 如果遍历到树末节点则跳出
					break
				TV_GetText(ItemText, ItemID)
				selTextList.Push(ItemText)
				DelListID.Push(ItemID)
			}
			ItemID:=moveID
			Loop
			{
				ItemID := TV_GetNext(ItemID, "Full")
				if(ItemID=moveNextID)	; 如果遍历到树末节点则跳出
					break
				TV_GetText(ItemText, ItemID)
				moveTextList.Push(ItemText)
				DelListID.Push(ItemID)
			}
			; 遍历旧节点数组删除
			Loop,% DelListID.MaxIndex()
			{
				TV_Delete(DelListID[A_Index])
			}
			; 遍历添加选中树内容到目标树
			Loop,% selTextList.MaxIndex()
			{
				TV_Add(selTextList[A_Index],moveID,Set_Icon(TreeImageListID,selTextList[A_Index]))
			}
			; 遍历添加目标树内容到选中树
			Loop,% moveTextList.MaxIndex()
			{
				TV_Add(moveTextList[A_Index],selID,Set_Icon(TreeImageListID,moveTextList[A_Index]))
			}
		}
		;~ [互换选中目标节点的名称]
		TV_Modify(selID, , moveVar)
		TV_Modify(moveID, , selVar)
		TV_Modify(selID, "-Select -focus")
		TV_Modify(moveID, "Select Vis")
		TV_Modify(selID, Set_Icon(TreeImageListID,moveVar))
		TV_Modify(moveID, Set_Icon(TreeImageListID,selVar))
		TVFlag:=true
	}

}
;~;[批量移动项目到指定树节点]
TV_MoveMenu(moveMenuName){
	moveItem:=RegExReplace(moveMenuName,"S)^-+")
	moveLevel:=StrLen(RegExReplace(moveMenuName,"S)(^-+).*","$1"))
	Menu,%moveMenuName%,add,%moveMenuName%,Move_Menu
	try Menu,% moveRoot[moveLevel],add,%moveItem%, :%moveMenuName%
	try Menu,% moveRoot[moveLevel],Icon,%moveItem%,% TreeIconS[1],% TreeIconS[2]
	moveLevel+=1
	moveRoot[moveLevel]:=moveMenuName
}
TV_MoveMenuClean(){
	try{
		;[清空功能菜单]
		Menu,TVMenu,Delete
		Menu,GuiMenu,Delete
		Menu,moveMenu%both%,DeleteAll
	}catch{}
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
	Gui, MenuEdit:Menu, GuiMenu
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
						moveLevelID:=TV_Add(ItemText,moveLevelList[cLevel-1],Set_Icon(TreeImageListID,ItemText))
						moveLevelList[cLevel]:=moveLevelID
						MoveID:=moveLevelID
					}else{
						;[遇到分隔符则改变树型]
						TV_Add(ItemText,moveLevelList[cLevel-1],Set_Icon(TreeImageListID,ItemText))
						MoveID:=moveLevelList[cLevel-1]
					}
				}
			}else{
				moveLevelID:=TV_Add(ItemText,MoveID,Set_Icon(TreeImageListID,ItemText))
			}
			DelListID.Push(CheckID)
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
;~;[菜单树项目根据后缀或模式设置图标和样式]
Set_Icon(ImageListID,itemVar,editVar=true,fullItemFlag=true,itemName=""){
	;变量转换实际值
	itemVar:=Get_Transform_Val(itemVar)
	;菜单项启动模式
	setItemMode:=Get_Menu_Item_Mode(itemVar,fullItemFlag)
	itemStyle:=setItemMode=10 ? "Bold " : ""
	SplitPath,itemVar,,,FileExt,name_no_ext  ; 获取文件扩展名.
	;[获取全路径]
	if(setItemMode=1 || setItemMode=60){
		FileName:=Get_Obj_Path(itemVar)
		if(!FileExist(FileName))
			FailFlag:=true
	}
	;[优先加载自定义图标]
	if(itemName!=""){
		itemIcon:=itemName
	}else if(InStr(itemVar,"|")){
		diyText:=StrSplit(itemVar,"|",,2)
		itemIcon:=diyText[1]
		objText:=(diyText[2]) ? diyText[2] : diyText[1]
	}else{
		itemIcon:=name_no_ext
	}
	itemIconFile:=IconFolderList[menuItemIconFileName(itemIcon)]
	if(itemIconFile && FileExist(itemIconFile)){
		try{
			Menu,exeTestMenu,Icon,SetCancel,%itemIconFile%,0
			addNum:=IL_Add(ImageListID, itemIconFile, 0)
			return itemStyle . "Icon" . addNum
		}catch{}
	}
	if(setItemMode=2 || setItemMode=3)
		return "Icon2"
	if(setItemMode=10)
		return itemStyle . "Icon6"
	if(setItemMode=11)
		return "Icon8"
	if(setItemMode=7)
		return "Icon4"
	if(setItemMode=4)	; {发送热键}
		return "Icon9"
	if(setItemMode=5)
		return "Icon10"
	if(setItemMode=8)  ; {脚本插件函数}
		return "Icon11"
	if(!editVar && FileName="" && FileExt="exe")
		return "Icon3"
	;[获取网址图标]
	if(setItemMode=6){
		try{
			website:=RegExReplace(objText,"iS)[\w-]+://?((\w+\.)+\w+).*","$1")
			webIcon:=A_ScriptDir "\RunIcon\" website ".ico"
			if(FileExist(webIcon)){
				Menu,exeTestMenu,Icon,SetCancel,%webIcon%,0
				addNum:=IL_Add(ImageListID, webIcon, 0)
				return "Icon" . addNum
			}else{
				return "Icon7"
			}
		} catch e {
			return "Icon7"
		}
	}
	;[编辑后图标重新加载]
	if(editVar && FailFlag){
		;~;[编辑后通过everything重新添加应用图标]
		if(FileExt="exe"){
			if(!EvNo)
				exeQueryPath:=exeQuery(FileName="" ? objText : FileName)
			if(exeQueryPath){
				FileName:=exeQueryPath
			}else{
				return "Icon3"
			}
		}else{
			FileName:=objText!="" ? objText : FileName
		}
	}
	; 计算 SHFILEINFO 结构需要的缓存大小.
	sfi_size := A_PtrSize + 8 + (A_IsUnicode ? 680 : 340)
	VarSetCapacity(sfi, sfi_size)
	;【下面开始处理未知的项目图标】
    if FileExt in EXE,ICO,ANI,CUR
    {
        ExtID := FileExt  ; 特殊 ID 作为占位符.
        IconNumber := 0  ; 进行标记这样每种类型就含有唯一的图标.
    }
    else  ; 其他的扩展名/文件类型, 计算它们的唯一 ID.
    {
        ExtID := 0  ; 进行初始化来处理比其他更短的扩展名.
        Loop 7     ; 限制扩展名为 7 个字符, 这样之后计算的结果才能存放到 64 位值.
        {
            ExtChar := SubStr(FileExt, A_Index, 1)
            if not ExtChar  ; 没有更多字符了.
                break
            ; 把每个字符与不同的位置进行运算来得到唯一 ID:
            ExtID := ExtID | (Asc(ExtChar) << (8 * (A_Index - 1)))
        }
        ; 检查此文件扩展名的图标是否已经在图像列表中. 如果是,
        ; 可以避免多次调用并极大提高性能,
        ; 尤其对于包含数以百计文件的文件夹而言:
		if(ExtID>0)
			IconNumber := IconArray%ExtID%
        noEXE:=true
    }
    if not IconNumber  ; 此扩展名还没有相应的图标, 所以进行加载.
    {
		; 获取与此文件扩展名关联的高质量小图标:
		if not DllCall("Shell32\SHGetFileInfo" . (A_IsUnicode ? "W":"A"), "str", FileName
            , "uint", 0, "ptr", &sfi, "uint", sfi_size, "uint", 0x101)  ; 0x101 为 SHGFI_ICON+SHGFI_SMALLICON
		{
			IconNumber = 3  ; 显示默认应用图标.
			if(noEXE)
				IconNumber = 1
		}
		else ; 成功加载图标.
		{
			; 从结构中提取 hIcon 成员:
			hIcon := NumGet(sfi, 0)
			; 直接添加 HICON 到小图标和大图标列表.
			; 下面加上 1 来把返回的索引从基于零转换到基于一:
			IconNumber := DllCall("ImageList_ReplaceIcon", "ptr", ImageListID, "int", -1, "ptr", hIcon) + 1
			; 现在已经把它复制到图像列表, 所以应销毁原来的:
			DllCall("DestroyIcon", "ptr", hIcon)
			; 缓存图标来节省内存并提升加载性能:
			if(ExtID>0)
				IconArray%ExtID% := IconNumber
		}
	}
	return "Icon" . IconNumber
}
;修改于ahk论坛全选全不选
TV_CheckUncheckWalk(_GuiEvent, _EventInfo, _GuiControl)
{
    static  TV_SuspendEvents := False                                           ;最初接受事件并保持跟踪
    If ( TV_SuspendEvents || !_GuiEvent || !_EventInfo || !_GuiControl )        ;无所事事：跳出
        Return
    If _GuiEvent = Normal                                                       ;这是一个左键：继续
    {
        Critical                                                                ;不能被中断。
        TV_SuspendEvents := True                                                ;在工作时停止对功能的进一步调用
        Gui, TreeView, %_GuiControl%                                            ;激活正确的TV
        TV_Modify(_EventInfo, "Select")                                         ;选择项目反正...这一行可能在这里取消和分散进一步
        If TV_Get( _EventInfo, "Checked" )                                      ;项目的复选标记
        {
            If TV_GetChild( _EventInfo )                                        ;项目的节点
                ToggleAllTheWay( _EventInfo, False )                            ;复选标记所有的子节点一路下来
        }
        Else                                                                    ;它未被选中
        {
            If TV_GetChild( _EventInfo )                                        ;它是一个节点
                ToggleAllTheWay( _EventInfo, True )                             ;取消选中所有的子节点一直向下
            If TV_Get( TV_GetParent( _EventInfo ), "Checked")                   ;父节点选中怎么样？
            {
                locItemId := TV_GetParent( _EventInfo )                         ;父节点检查标记：获取父ID
                While locItemId                                                 ;循环一路向上
                {
                    TV_Modify( locItemId , "-Check" )                           ;取消选中
                    locItemId := TV_GetParent( locItemId )                      ;获取下一个父ID
                }
            }
        }
    }
    TV_SuspendEvents := False                                                   ;激活事件
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
;Treeview自定义项目颜色
;https://www.autohotkey.com/boards/viewtopic.php?f=6&t=2632&hilit=TreeView+colour
class treeview{
	static list:=[]
	__New(hwnd){
		this.list[hwnd]:=this
		OnMessage(0x4e,"WM_NOTIFY")
		this.hwnd:=hwnd,this.selectcolor:=""
	}
	add(info){
		Gui,TreeView,% this.hwnd
		hwnd:=TV_Add(info.Label,info.parent,info.option)
		if info.fore!=""
			this.control["|" hwnd,"fore"]:=info.fore
		if info.back!=""
			this.control["|" hwnd,"back"]:=info.back
		return hwnd
	}
	modify(info){
		this.control["|" info.hwnd,"fore"]:=info.fore
		this.control["|" info.hwnd,"back"]:=info.back
		WinSet,Redraw,,A
	}
	Remove(hwnd){
		this.control.Remove("|" hwnd)
	}
}
WM_NOTIFY(Param*){
	static list:=[],ll:=""
	control:=""
	if (this:=treeview.list[NumGet(Param.2)])&&(NumGet(Param.2,2*A_PtrSize,"int")=-12){
		stage:=NumGet(Param.2,3*A_PtrSize,"uint")
		if (stage=1)
			return 0x20 ;sets CDRF_NOTIFYITEMDRAW
		if (stage=0x10001&&info:=this.control["|" numget(Param.2,A_PtrSize=4?9*A_PtrSize:7*A_PtrSize,"uint")]){ ;NM_CUSTOMDRAW && Control is in the list
			if info.fore!=""
				NumPut(info.fore,Param.2,A_PtrSize=4?12*A_PtrSize:10*A_PtrSize,"int") ;sets the foreground
			if info.back!=""
				NumPut(info.back,Param.2,A_PtrSize=4?13*A_PtrSize:10.5*A_PtrSize,"int") ;sets the background
		}
		if (this.selectcolor){
			Gui,TreeView,% NumGet(param.2)
			if (NumGet(param.2,9*A_PtrSize)=TV_GetSelection())
				NumPut(this.selectcolor,Param.2,A_PtrSize=4?13*A_PtrSize:10.5*A_PtrSize,"int") ;sets the background
		}
	}
}
;══════════════════════════════════════════════════════════════════
;~;【——插件Gui——】
;══════════════════════════════════════════════════════════════════
Plugins_Gui:
	gosub,Plugins_Read
	gosub,Plugins_LV_Icon_Set
	;根据网络自动选择对应插件说明网页地址
	pagesPluginsUrl:=RunAnyGiteePages . "/runany/#/plugins-help"
	if(!rule_check_network(RunAnyGiteePages)){
		pagesPluginsUrl:=RunAnyGiteePages . "/RunAny/#/plugins-help"
	}
	pagesHash:=pagesPluginsUrl . "?id="
	global PluginsHelpList:={"huiZz_QRCode.ahk":pagesHash "huizz_qrcode二维码脚本使用方法"}
	PluginsHelpList["huiZz_Window.ahk"]:=pagesHash "huizz_window窗口操作插件使用方法"
	PluginsHelpList["huiZz_System.ahk"]:=pagesHash "huizz_system系统操作插件使用方法"
	PluginsHelpList["huiZz_Text.ahk"]:=pagesHash "huizz_text文本操作插件使用方法"
	global ColumnName:=1
	global ColumnStatus:=2
	global ColumnAutoRun:=3
	global ColumnContent:=5
	DetectHiddenWindows,On
	Gui,PluginsManage:Destroy
	Gui,PluginsManage:Default
	Gui,PluginsManage:+Resize
	Gui,PluginsManage:Font, s10, Microsoft YaHei
	Gui,PluginsManage:Add, Listview, xm w710 r22 grid AltSubmit vRunAnyLV glistview, 插件文件|运行状态|自动启动|插件描述|插件说明地址
	GuiControl,PluginsManage: -Redraw, RunAnyLV
	LV_SetImageList(PluginsImageListID)
	For runn, runv in PluginsObjList
	{
		runStatus:=rule_check_is_run(PluginsPathList[runn]) ? "启动" : ""
		pluginsConfig:=runv ? "自启" : ""
		if(!PluginsPathList[runn])
			pluginsConfig:="未找到"
		LV_Add(LVPluginsIcon(runn), runn, runStatus, pluginsConfig, PluginsTitleList[runn], PluginsHelpList[runn])
	}
	GuiControl,PluginsManage: +Redraw, RunAnyLV
	LVMenu("LVMenu")
	LVMenu("ahkGuiMenu")
	Gui,PluginsManage: Menu, ahkGuiMenu
	LVModifyCol(65,ColumnStatus,ColumnAutoRun)
	Gui,PluginsManage:Show, , %RunAnyZz% 插件管理 - 支持拖放 %RunAny_update_version% %RunAny_update_time%%AdminMode%
	DetectHiddenWindows,Off
return

LVMenu(addMenu){
	flag:=addMenu="ahkGuiMenu" ? true : false
	Menu, %addMenu%, Add,% flag ? "启动" : "启动`tF1", LVRun
	try Menu, %addMenu%, Icon,% flag ? "启动" : "启动`tF1", %A_AhkPath%,2
	Menu, %addMenu%, Add,% flag ? "编辑" : "编辑`tF2", LVEdit
	Menu, %addMenu%, Icon,% flag ? "编辑" : "编辑`tF2", SHELL32.dll,134
	Menu, %addMenu%, Add,% flag ? "自启" : "自启`tF3", LVEnable
	Menu, %addMenu%, Icon,% flag ? "自启" : "自启`tF3", SHELL32.dll,166
	Menu, %addMenu%, Add,% flag ? "关闭" : "关闭`tF4", LVClose
	Menu, %addMenu%, Icon,% flag ? "关闭" : "关闭`tF4", SHELL32.dll,28
	Menu, %addMenu%, Add,% flag ? "挂起" : "挂起`tF5", LVSuspend
	try Menu, %addMenu%, Icon,% flag ? "挂起" : "挂起`tF5", %A_AhkPath%,3
	Menu, %addMenu%, Add,% flag ? "暂停" : "暂停`tF6", LVPause
	try Menu, %addMenu%, Icon,% flag ? "暂停" : "暂停`tF6", %A_AhkPath%,4
	Menu, %addMenu%, Add,% flag ? "移除" : "移除`tF7", LVDel
	Menu, %addMenu%, Icon,% flag ? "移除" : "移除`tF7", SHELL32.dll,132
	Menu, %addMenu%, Add,% flag ? "下载插件" : "下载插件`tF8", LVAdd
	Menu, %addMenu%, Icon,% flag ? "下载插件" : "下载插件`tF8", SHELL32.dll,194
	Menu, %addMenu%, Add,% flag ? "插件说明" : "插件说明`tF9", LVHelp
	Menu, %addMenu%, Icon,% flag ? "插件说明" : "插件说明`tF9", SHELL32.dll,92
	Menu, %addMenu%, Add,% flag ? "插件库" : "插件库`tF10", LVPluginsLib
	Menu, %addMenu%, Icon,% flag ? "插件库" : "插件库`tF10", SHELL32.dll,42
	Menu, %addMenu%, Add,% flag ? "新建插件" : "新建插件`tF11", LVCreate
	Menu, %addMenu%, Icon,% flag ? "新建插件" : "新建插件`tF11", SHELL32.dll,1
}
LVRun:
	menuItem:="启动"
	gosub,LVApply
	return
LVEdit:
	menuItem:="编辑"
	gosub,LVApply
	return
LVEnable:
	menuItem:="自启"
	gosub,LVApply
	return
LVClose:
	menuItem:="关闭"
	gosub,LVApply
	return
LVSuspend:
	menuItem:="挂起"
	gosub,LVApply
	return
LVPause:
	menuItem:="暂停"
	gosub,LVApply
	return
LVDel:
	menuItem:="移除"
	gosub,LVApply
	return
LVHelp:
	menuItem:="帮助"
	gosub,LVApply
	return
return
LVApply:
	Gui,PluginsManage:Default
	DetectHiddenWindows,On      ;~显示隐藏窗口
	Row:=LV_GetNext(0, "F")
	RowNumber:=0
	if(Row && menuItem="移除"){
		MsgBox,35,确认移除？(Esc取消),确定移除选中的插件配置？(不会删除文件)
		DelRowList:=""
	}
	Loop
	{
		RowNumber := LV_GetNext(RowNumber)  ; 在前一次找到的位置后继续搜索.
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		LV_GetText(FileName, RowNumber, ColumnName)
		LV_GetText(FileStatus, RowNumber, ColumnStatus)
		LV_GetText(FileAutoRun, RowNumber, ColumnAutoRun)
		FilePath:=PluginsPathList[FileName]
		if(menuItem="启动"){
			runValue:=RegExReplace(FilePath,"iS)(.*?\.exe)($| .*)","$1")	;去掉参数
			try {
				SplitPath, runValue, name, dir, ext  ; 获取扩展名
				if(dir && FileExist(dir)){
					SetWorkingDir,%dir%
				}
				if(A_AhkPath && ext="ahk"){
					Run,%A_AhkPath%%A_Space%"%FilePath%"
				}else{
					Run,%FilePath%
				}
				LV_Modify(RowNumber, "", , "启动")
			} finally {
				SetWorkingDir,%A_ScriptDir%
			}
		}else if(menuItem="编辑"){
			Plugins_Edit(FilePath)
		}else if(menuItem="挂起"){
			PostMessage, 0x111, 65404,,, %FilePath% ahk_class AutoHotkey
			LVStatusChange(RowNumber,FileStatus,"挂起",FileName)
		}else if(menuItem="暂停"){
			PostMessage, 0x111, 65403,,, %FilePath% ahk_class AutoHotkey
			LVStatusChange(RowNumber,FileStatus,"暂停",FileName)
		}else if(menuItem="关闭"){
			runValue:=RegExReplace(FilePath,"iS)(.*?\.exe)($| .*)","$1")	;去掉参数
			SplitPath, runValue, name,, ext  ; 获取扩展名
			if(ext="ahk"){
				PostMessage, 0x111, 65405,,, %FilePath% ahk_class AutoHotkey
				runStatus:=""
			}else if(name){
				Process,Close,%name%
				if ErrorLevel
					runStatus:=""
			}
			LV_Modify(RowNumber, "", , runStatus)
		}else if(menuItem="自启"){
			if(FileAutoRun!="未找到" && FileAutoRun!="自启"){
				IniWrite,1,%RunAnyConfig%,Plugins,%FileName%
				LV_Modify(RowNumber, "", , ,"自启")
			}else if(FileAutoRun="自启"){
				IniWrite,0,%RunAnyConfig%,Plugins,%FileName%
				LV_Modify(RowNumber, "", , ,"禁用")
			}
		}else if(menuItem="移除"){
			IfMsgBox Yes
			{
				DelRowList := RowNumber . ":" . DelRowList
				IniDelete,%RunAnyConfig%,Plugins,%FileName% ;删除插件管理数据
				SplitPath,FileName,,,,o_name_no_ext
				IniDelete,%RunAny_ObjReg_Path%,objreg,%o_name_no_ext% ;删除插件注册数据
			}
		}else if(menuItem="帮助"){
			if(PluginsHelpList[FileName]){
				Run,% PluginsHelpList[FileName]
			}else{
				Plugins_Edit(FilePath)
			}
		}
	}
	if(menuItem="移除"){
		IfMsgBox Yes
		{
			stringtrimright, DelRowList, DelRowList, 1
			loop, parse, DelRowList, :
				LV_Delete(A_loopfield)
		}
	}
	DetectHiddenWindows,Off
return
;[插件脚本编辑操作]
Plugins_Edit(FilePath){
	try{
		if(Trim(PluginsEditor," `t`n`r")!=""){
			Run,% Get_Obj_Path_Transform(PluginsEditor) A_Space """" FilePath """"
		}else{
			PostMessage, 0x111, 65401,,, %FilePath% ahk_class AutoHotkey
		}
	}catch{
		try{
			RegRead, AhkSetup, HKEY_LOCAL_MACHINE\SOFTWARE\Classes\AutoHotkeyScript
			if(AhkSetup){
				Run,edit "%FilePath%"
			}else{
				Run,notepad.exe "%FilePath%"
			}
		}catch{
			Run,notepad.exe "%FilePath%"
		}
	}
}
#If WinActive(RunAnyZz " 插件管理 - 支持拖放 " RunAny_update_version A_Space RunAny_update_time)
	F1::gosub,LVRun
	F2::gosub,LVEdit
	F3::gosub,LVEnable
	F4::gosub,LVClose
	F5::gosub,LVSuspend
	F6::gosub,LVPause
	F7::gosub,LVDel
	F8::gosub,LVAdd
	F9::gosub,LVHelp
	F10::gosub,LVPluginsLib
	F11::gosub,LVCreate
#If
listview:
    if A_GuiEvent = DoubleClick
    {
		menuItem:="启动"
		gosub,LVApply
    }
return
LVAdd:
	global pluginsDownList:=Object()
	global pluginsNameList:=Object()
	gosub,PluginsDownVersion
	Gui,PluginsDownload:Destroy
	Gui,PluginsDownload:Default
	Gui,PluginsDownload:+Resize
	Gui,PluginsDownload:Font, s10, Microsoft YaHei
	Gui,PluginsDownload:Add, Listview, xm w620 r15 grid AltSubmit Checked vRunAnyDownLV, 插件文件|状态|版本号|最新版本|插件描述
	GuiControl,PluginsDownload: -Redraw, RunAnyDownLV
	For pk, pv in pluginsDownList
	{
		runStatus:=PluginsPathList[pk] ? "已下载" : "未下载"
		pluginsLocalVersion:=Plugins_Read_Version(PluginsPathList[pk])
		if(runStatus="已下载" && checkGithub)
			runStatus:=pluginsLocalVersion < pv ? "可更新" : "已最新"
		LV_Add("", pk, runStatus, pluginsLocalVersion, checkGithub ? pv : "网络异常",checkGithub ? pluginsNameList[pk] : PluginsTitleList[pk])
	}
	GuiControl,PluginsDownload: +Redraw, RunAnyDownLV
	Menu, ahkDownMenu, Add,下载, LVDown
	Menu, ahkDownMenu, Icon,下载, SHELL32.dll,194
	Gui,PluginsDownload: Menu, ahkDownMenu
	LVModifyCol(65,ColumnStatus,ColumnAutoRun)
	Gui,PluginsDownload:Show, , %RunAnyZz% 插件下载 %RunAny_update_version% %RunAny_update_time%
return
LVCreate:
newObjRegCount:=1
Loop,%A_ScriptDir%\%PluginsDir%\RunAny_NewObjReg_*.ahk
{
	newObjRegCount++
}
loop
{
	InputBox, newObjRegInput, ObjReg新建插件脚本名称,`n  新建插件脚本（默认自动启动），名称建议为`n`n  作者名_功能.ahk,,,,,,,,RunAny_NewObjReg_%newObjRegCount%.ahk
	if !ErrorLevel
	{
		IfNotExist,%A_ScriptDir%\%PluginsDir%\%newObjRegInput%
			break
		else
			MsgBox, 48, 文件重名, 已有同名的脚本存在，请重新输入
	}else{
		return
	}
}
SplitPath, newObjRegInput,,,,inputNameNotExt
;[新建ObjReg插件脚本模板]
FileAppend,
(
;************************
;* 【ObjReg插件脚本 %newObjRegCount%】 *
;************************
global RunAny_Plugins_Version:="1.0.0"
#NoTrayIcon             ;~不显示托盘图标
#Persistent             ;~让脚本持久运行
#SingleInstance,Force   ;~运行替换旧实例
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
#Include `%A_ScriptDir`%\RunAny_ObjReg.ahk

class RunAnyObj {
	;[新建：你自己的函数]
	;保存到RunAny.ini为：菜单项名|你的脚本文件名%inputNameNotExt%[你的函数名](参数1,参数2)
	;你的函数名(参数1,参数2){
		;函数内容写在这里
`t`t
	;}
`t
}

;独立使用方式
;F1::
	;RunAnyObj.你的函数名(参数1,参数2)
;return
),%A_ScriptDir%\%PluginsDir%\%newObjRegInput%,UTF-8
IniWrite,1,%RunAnyConfig%,Plugins,%newObjRegInput%
gosub,Plugins_Gui
Run,notepad.exe %A_ScriptDir%\%PluginsDir%\%newObjRegInput%
return
;~;【插件-脚本库Gui】
LVPluginsLib:
	PluginsDirPath:=StrReplace(PluginsDirPath, "|", "`n")
	Gui,PluginsLib:Destroy
	Gui,PluginsLib:Default
	Gui,PluginsLib:+OwnerPluginsManage
	Gui,PluginsLib:Margin,20,20
	Gui,PluginsLib:Font,,Microsoft YaHei
	Gui,PluginsLib:Add, GroupBox,xm y+10 w460 h220
	Gui,PluginsLib:Add, Text, xm+5 y+35 y35 w80,%A_Space%默认插件库：
	Gui,PluginsLib:Add, Text, x+5 yp,%A_ScriptDir%\RunPlugins
	Gui,PluginsLib:Add, Button, xm+10 y+15 w80 gSetPluginsDirPath,其他插件库：`n支持多行`n支持变量
	Gui,PluginsLib:Add, Edit, x+5 yp w350 r5 vvPluginsDirPath, %PluginsDirPath%
	Gui,PluginsLib:Add, Button, xm+10 y+10 w80 gSetPluginsEditor,插件编辑器：`n支持无路径%A_Tab%
	Gui,PluginsLib:Add, Edit, x+5 yp w350 r2 vvPluginsEditor, %PluginsEditor%
	Gui,PluginsLib:Font
	Gui,PluginsLib:Add,Button,Default xm+130 y+35 w75 GSavePluginsLib,保存(&S)
	Gui,PluginsLib:Add,Button,x+20 w75 GSetCancel,取消(&C)
	Gui,PluginsLib:Show,,%RunAnyZz% - 插件脚本库 %RunAny_update_version% %RunAny_update_time%
return
SetPluginsDirPath:
	Gui,PluginsLib:Submit, NoHide
	FileSelectFolder, pluginsLibFolder, , 0
	if(pluginsLibFolder){
		if(vPluginsDirPath){
			GuiControl,, vPluginsDirPath, %vPluginsDirPath%`n%pluginsLibFolder%
		}else{
			GuiControl,, vPluginsDirPath, %pluginsLibFolder%
		}
	}
return
SetPluginsEditor:
	FileSelectFile, pluginsLibFile, , , 插件编辑器路径
	if(pluginsLibFile){
		GuiControl,, vPluginsEditor, %pluginsLibFile%
	}
return
SavePluginsLib:
	Gui,PluginsLib:Submit, NoHide
	vPluginsDirPath:=RegExReplace(vPluginsDirPath,"S)[\n]+","|")
	IniWrite,%vPluginsDirPath%,%RunAnyConfig%,Config,PluginsDirPath
	IniWrite,%vPluginsEditor%,%RunAnyConfig%,Config,PluginsEditor
	Gui,PluginsLib:Destroy
	Gui,PluginsManage:Destroy
	gosub,Plugins_Gui
return
PluginsDownVersion:
	if(!rule_check_network(giteeUrl)){
		RunAnyDownDir:=githubUrl . RunAnyGithubDir
		if(!rule_check_network(githubUrl)){
			TrayTip,,网络异常，无法连接网络读取最新版本文件，请手动下载,5,1
			pluginsDownList:=PluginsObjList
			checkGithub:=false
			return
		}
	}
	IfNotExist %A_Temp%\%RunAnyZz%\%PluginsDir%
		FileCreateDir,%A_Temp%\%RunAnyZz%\%PluginsDir%
	ObjRegIniPath=%A_Temp%\%RunAnyZz%\%PluginsDir%\RunAny_ObjReg.ini
	URLDownloadToFile(RunAnyDownDir "/" PluginsDir "/RunAny_ObjReg.ini",ObjRegIniPath)
	IfExist,%ObjRegIniPath%
	{
		FileGetSize, ObjRegIniSize, %ObjRegIniPath%
		if(ObjRegIniSize>100){
			IniRead,objRegIniVar,%ObjRegIniPath%,version
			Loop, parse, objRegIniVar, `n, `r
			{
				varList:=StrSplit(A_LoopField,"=",,2)
				pluginsDownList[(varList[1])]:=varList[2]
			}
			IniRead,objRegIniVar,%ObjRegIniPath%,name
			Loop, parse, objRegIniVar, `n, `r
			{
				varList:=StrSplit(A_LoopField,"=",,2)
				pluginsNameList[(varList[1])]:=varList[2]
			}
			checkGithub:=true
			return
		}
	}
	pluginsDownList:=PluginsObjList
	checkGithub:=false
return
LVDown:
	MsgBox,33,RunAny下载插件,是否下载插件？如有修改过插件代码请注意备份！`n
	(
仅仅更新下载 %A_ScriptDir%\%PluginsDir% 目录下的插件
(旧版文件会转移到%A_Temp%\%RunAnyZz%\%PluginsDir%)
	)
	IfMsgBox Ok
	{
		if(!rule_check_network(giteeUrl)){
			RunAnyDownDir:=githubUrl . RunAnyGithubDir
			if(!rule_check_network(githubUrl)){
				MsgBox,网络异常，无法连接网络读取最新版本文件，请手动下载
				return
			}
		}
		downFlag:=false
		firstUpdateFlag:=false
		Loop
		{
			RowNumber := LV_GetNext(RowNumber, "Checked")  ; 再找勾选的行
			if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
				break
			LV_GetText(FileName, RowNumber, ColumnName)
			LV_GetText(FileStatus, RowNumber, ColumnStatus)
			LV_GetText(FileContent, RowNumber, ColumnContent)
			TrayTip,,RunAny开始下载%FileName%，请稍等……,3,1
			pluginsDownPath=%PluginsDir%
			;如果插件需要创建目录
			if(RegExMatch(FileContent,"iS)\{\}$")){
				SplitPath, FileName, fName,, fExt, name_no_ext
				pluginsDownPath.="\" name_no_ext
				IfNotExist %A_ScriptDir%\%pluginsDownPath%
					FileCreateDir,%A_ScriptDir%\%pluginsDownPath%
			}
			;特殊插件下载依赖
			if(FileName="huiZz_QRCode.ahk"){
				TrayTip,,huiZz_QRCode需要下载quricol32.dll，请稍等……,3,1
				URLDownloadToFile(RunAnyDownDir "/" PluginsDir "/" name_no_ext "/quricol32.dll",A_ScriptDir "\" pluginsDownPath "\quricol32.dll")
				if(A_Is64bitOS){
					URLDownloadToFile(RunAnyDownDir "/" PluginsDir "/" name_no_ext "/quricol64.dll",A_ScriptDir "\" pluginsDownPath "\quricol64.dll")
					FileRead, quricol64, %A_ScriptDir%\%pluginsDownPath%\quricol64.dll
					if(quricol64="404: Not Found`n"){
						MsgBox,二维码插件quricol64.dll下载异常，请重新更新或到官网下载！
						return
					}
				}
				FileRead, quricol32, %A_ScriptDir%\%pluginsDownPath%\quricol32.dll
				if(quricol32="404: Not Found`n"){
					MsgBox,二维码插件quricol32.dll下载异常，请重新更新或到官网下载！
					return
				}
			}
			;[下载插件脚本]
			IfExist,%A_ScriptDir%\%pluginsDownPath%\%FileName%
				FileMove,%A_ScriptDir%\%pluginsDownPath%\%FileName%,%A_Temp%\%RunAnyZz%\%pluginsDownPath%\%FileName%,1
			URLDownloadToFile(RunAnyDownDir "/" StrReplace(pluginsDownPath,"\","/") "/" FileName,A_ScriptDir "\" pluginsDownPath "\" FileName)
			downFlag:=true
			if(FileStatus="未下载"){
				firstUpdateFlag:=true
			}
		}
		if(downFlag){
			if(firstUpdateFlag){
				if(PluginsHelpList[FileName]){
					Run,%pagesPluginsUrl%
					Sleep,1000
					MsgBox, 64, ,RunAny插件下载成功，请在网页上阅读对应插件使用说明后使用
				}else{
					MsgBox, 64, ,RunAny插件下载成功，在插件管理界面点击“编辑”按钮可以阅读说明和进行配置
				}
			}
			RegWrite, REG_SZ, HKEY_CURRENT_USER, SOFTWARE\RunAny, ReloadGosub, Plugins_Gui
			gosub,Menu_Reload
		}else{
			ToolTip,请至少选中一项
			SetTimer,RemoveToolTip,2000
		}
	}
return
;[加载插件脚本图标]
Plugins_LV_Icon_Set:
	global PluginsImageListID:=IL_Create(6)
	IL_Add(PluginsImageListID, A_AhkPath, 1)
	IL_Add(PluginsImageListID, A_AhkPath, 2)
	IL_Add(PluginsImageListID, A_AhkPath, 3)
	IL_Add(PluginsImageListID, A_AhkPath, 4)
	IL_Add(PluginsImageListID, A_AhkPath, 5)
	IL_Add(PluginsImageListID, FuncIconS[1], FuncIconS[2])
return
;[插件管理独立脚本一键关闭]
Plugins_Alone_Pause:
	Plugins_Alone("暂停")
return
Plugins_Alone_Suspend:
	Plugins_Alone("挂起")
return
Plugins_Alone_Close:
	Plugins_Alone("关闭")
return
Plugins_Alone(r){
	DetectHiddenWindows,On      ;~显示隐藏窗口
	For runn, runv in PluginsPathList
	{
		SplitPath,runv,,,,pname_no_ext
		if(PluginsObjRegGUID[pname_no_ext]){
			continue
		}
		if(r="暂停"){
			PostMessage, 0x111, 65403,,, %runv% ahk_class AutoHotkey
		}else if(r="挂起"){
			PostMessage, 0x111, 65404,,, %runv% ahk_class AutoHotkey
		}else if(r="关闭"){
			PostMessage, 0x111, 65405,,, %runv% ahk_class AutoHotkey
		}
	}
	DetectHiddenWindows,Off
}

LVPluginsIcon(pname){
	pname_no_ext:=RegExReplace(pname,"iS)\.ahk$")
	PluginsFile:=RegExReplace(PluginsPathList[pname],"iS)\.ahk$")
	Loop, Parse,% IconFileSuffix "*.exe;", `;
	{
		suffix:=StrReplace(A_LoopField, "*")
		if(FileExist(PluginsFile suffix)){
			addNum:=IL_Add(PluginsImageListID, PluginsFile suffix, 0)
			return "Icon" addNum
		}
	}
	if(PluginsObjRegGUID[pname_no_ext]){
		return "Icon6"
	}
	return "Icon2"
}
;[判断脚本当前状态]
LVStatusChange(RowNumber,FileStatus,lvItem,FileName){
	item:=lvItem
	if(FileStatus="挂起" && lvItem="暂停"){
		LV_Modify(RowNumber, "Icon5", ,"挂起暂停")
		LV_ModifyCol()
		return
	}else if(FileStatus="暂停" && lvItem="挂起"){
		LV_Modify(RowNumber, "Icon5", ,"暂停挂起")
		LV_ModifyCol()
		return
	}else if(FileStatus!="启动"){
		StringReplace, lvItem, FileStatus, %item%
	}
	if(lvItem="")
		lvItem:="启动"
	if(lvItem="启动"){
		LV_Modify(RowNumber, LVPluginsIcon(FileName), ,lvItem)
	}else if(lvItem="挂起"){
		LV_Modify(RowNumber, "Icon3", ,lvItem)
	}else if(lvItem="暂停"){
		LV_Modify(RowNumber, "Icon4", ,lvItem)
	}
	LV_ModifyCol()
}
;══════════════════════════════════════════════════════════════════
;~;【——启动控制Gui——】
;══════════════════════════════════════════════════════════════════
RunCtrl_Manage_Gui:
	gosub,RunCtrl_Read
	RunCtrlListBoxChoose:=1
	if(RunCtrlListBox!=""){
		for i,v in RunCtrlListBoxList
		{
			if(RunCtrlListBox=v){
				RunCtrlListBoxChoose:=i
				break
			}
		}
	}
	Gui,RunCtrlManage:Destroy
	Gui,RunCtrlManage:Default
	Gui,RunCtrlManage:+Resize
	Gui,RunCtrlManage:Font, s10, Microsoft YaHei
	Gui,RunCtrlManage:Add, ListBox, x16 w130 vRunCtrlListBox gRunCtrlListClick Choose%RunCtrlListBoxChoose%, %RunCtrlListBoxVar%
	Gui,RunCtrlManage:Add, Listview,x+15 w530 r15 grid AltSubmit vRunCtrlLV gRunCtrlListView, 启动项|类型|重复运行
	GuiControl,RunCtrlManage:-Redraw, RunCtrlLV
	LVImageListID := IL_Create(11)
	Icon_Image_Set(LVImageListID)
	LV_SetImageList(LVImageListID)
	Gui,RunCtrlManage:Submit, NoHide
	For runn, runv in RunCtrlList[RunCtrlListBox].runList
	{
		LV_Add(Set_Icon(LVImageListID,runv.noPath ? Get_Obj_Path(runv.path) : runv.path,false,false,runv.path)
			,runv.path,runv.noPath ? "菜单项" : "全路径",runv.repeatRun ? "重复" : "")
	}
	GuiControl,RunCtrlManage:+Redraw, RunCtrlLV
	LV_ModifyCol()
	LV_ModifyCol(1,450)
	RunCtrlLVMenu("RunCtrlLVMenu")
	RunCtrlLVMenu("RunCtrlManageMenu")
	Gui,RunCtrlManage: Menu, RunCtrlManageMenu
	Gui,RunCtrlManage:Show, w720 , %RunAnyZz% 启动管理 %RunAny_update_version% %RunAny_update_time%%AdminMode%(双击修改，右键操作)
return

RunCtrlListClick:
	if A_GuiEvent = Normal
	{
		Gui,RunCtrlManage:Default
		Gui,RunCtrlManage:Submit, NoHide
		LV_delete()
		GuiControl,RunCtrlManage:-Redraw, RunCtrlLV
		For runn, runv in RunCtrlList[RunCtrlListBox].runList
		{
			LV_Add(Set_Icon(LVImageListID,runv.noPath ? Get_Obj_Path(runv.path) : runv.path,false,false,runv.path)
				,runv.path,runv.noPath ? "菜单项" : "全路径",runv.repeatRun ? "重复" : "")
		}
		GuiControl,RunCtrlManage:+Redraw, RunCtrlLV
	}else if A_GuiEvent = DoubleClick
	{
		gosub,RunCtrlLVEdit
	}
return
RunCtrlListView:
    if A_GuiEvent = DoubleClick
    {
		gosub,LVCtrlRunEdit
    }
return
;创建头部及右键功能菜单
RunCtrlLVMenu(addMenu){
	flag:=addMenu="RunCtrlManageMenu" ? true : false
	Menu, %addMenu%, Add,% flag ? "启动" : "启动`tF1", RunCtrlLVRun
	Menu, %addMenu%, Icon,% flag ? "启动" : "启动`tF1",% EXEIconS[1],% EXEIconS[2]
	Menu, %addMenu%, Add,% flag ? "添加组" : "添加组`tF3", RunCtrlLVAdd
	Menu, %addMenu%, Icon,% flag ? "添加组" : "添加组`tF3",% RunCtrlManageIconS[1],% RunCtrlManageIconS[2]
	Menu, %addMenu%, Add,% flag ? "添加应用" : "添加应用`tF4", LVCtrlRunAdd
	Menu, %addMenu%, Icon,% flag ? "添加应用" : "添加应用`tF4", SHELL32.dll,3
	Menu, %addMenu%, Add,% flag ? "编辑" : "编辑`tF2", RunCtrlLVEdit
	Menu, %addMenu%, Icon,% flag ? "编辑" : "编辑`tF2", SHELL32.dll,134
	Menu, %addMenu%, Add,% flag ? "移除" : "移除`tDel", RunCtrlLVDel
	Menu, %addMenu%, Icon,% flag ? "移除" : "移除`tDel", SHELL32.dll,132
	Menu, %addMenu%, Add,% flag ? "规则" : "规则`tF7", Rule_Manage_Gui
	Menu, %addMenu%, Icon,% flag ? "规则" : "规则`tF7", SHELL32.dll,166
	Menu, %addMenu%, Add,% flag ? "下移" : "下移`t(F5/PgDn)", RunCtrlLVDown
	try Menu, %addMenu%, Icon,% flag ? "下移" : "下移`t(F5/PgDn)",% DownIconS[1],% DownIconS[2]
	Menu, %addMenu%, Add,% flag ? "上移" : "上移`t(F6/PgUp)", RunCtrlLVUp
	try Menu, %addMenu%, Icon,% flag ? "上移" : "上移`t(F6/PgUp)",% UpIconS[1],% UpIconS[2]
	Menu, %addMenu%, Add,% flag ? "全选" : "全选`tCtrl+A", RunCtrlLVSelect
}
RunCtrlLVDel:
	Gui,RunCtrlManage:Default
	if(RunCtrlListBox="")
		return
	GuiControlGet, focusGuiName, Focus
	if(focusGuiName="ListBox1"){
		MsgBox,35,确认移除规则组 %RunCtrlListBox%？(Esc取消),确定移除规则组：%RunCtrlListBox% ？`n【注意!】：同时会移除 %RunCtrlListBox% 下的所有运行项和规则条件！
		IfMsgBox Yes
		{
			IniDelete,%RunAnyConfig%,RunCtrlList,%RunCtrlListBox%
			IniDelete,%RunAnyConfig%,%RunCtrlListBox%_Run
			IniDelete,%RunAnyConfig%,%RunCtrlListBox%_Rule
			gosub,RunCtrl_Manage_Gui
		}
	}
	if(focusGuiName!="SysListView321"){
		return
	}
	Row:=LV_GetNext(0, "F")
	RowNumber:=0
	if(Row){
		MsgBox,35,确认移除？(Esc取消),确定移除当前选中的启动项？
		DelRowList:=""
	}
	DelRunValList:=Object()
	Loop
	{
		RowNumber := LV_GetNext(RowNumber)  ; 在前一次找到的位置后继续搜索.
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		LV_GetText(RunCtrlRunValue, RowNumber, 1)
		LV_GetText(RunCtrlNoPath, RowNumber, 2)
		LV_GetText(RunCtrlRepeatRun, RowNumber, 3)
		IfMsgBox Yes
		{
			DelRowList := RowNumber . ":" . DelRowList
			oldRunMenu:=RunCtrlNoPath="菜单项" ? "menu" : "path"
			oldRunRepeat:=RunCtrlRepeatRun="重复" ? "|1" : ""
			oldStr:=oldRunMenu oldRunRepeat "=" RunCtrlRunValue
			DelRunValList[oldStr]:=true
		}
	}
	IfMsgBox Yes
	{
		DelRowList:=SubStr(DelRowList, 1, -StrLen(":"))
		loop, parse, DelRowList, :
			LV_Delete(A_loopfield)

		IniRead,ctrlAppsVar,%RunAnyConfig%,%RunCtrlListBox%_Run
		runContent:=""
		Loop, parse, ctrlAppsVar, `n, `r
		{
			runContent.=DelRunValList[A_LoopField] ? "" : A_LoopField "`n"
		}
		IniWrite,%runContent%,%RunAnyConfig%,%RunCtrlListBox%_Run
		gosub,RunCtrl_Read
	}
return
#If WinActive(RunAnyZz " 启动管理 " RunAny_update_version A_Space RunAny_update_time)
	F1::gosub,RunCtrlLVRun
	F2::gosub,RunCtrlLVEdit
	F3::gosub,RunCtrlLVAdd
	F4::gosub,LVCtrlRunAdd
	Del::gosub,RunCtrlLVDel
	F7::gosub,Rule_Manage_Gui
	^a::gosub,RunCtrlLVSelect
#If
RunCtrlLVUp:
RunCtrlLVDown:
	Gui,RunCtrlManage:Default
	Gui,RunCtrlManage:Submit, NoHide
	if(RunCtrlListBox=""){
		return
	}
	GuiControlGet, focusGuiName, Focus
	if(focusGuiName="ListBox1"){
		;上下移动规则组
		RunCtrlListContent:=""
		for i,v in RunCtrlListBoxList
		{
			if(A_ThisLabel="RunCtrlLVDown"){
				if(RunCtrlListBox=v){
					if((i + 1) > RunCtrlListBoxList.MaxIndex()){
						return
					}
					RunCtrlListContent.=RunCtrlListBoxList[i + 1] "=" RunCtrlListContentList[RunCtrlListBoxList[i + 1]] "`n"
					RunCtrlListContent.=v "=" RunCtrlListContentList[v] "`n"
				}else if(RunCtrlListBox!=RunCtrlListBoxList[i - 1]){
					RunCtrlListContent.=v "=" RunCtrlListContentList[v] "`n"
				}
			}else if(A_ThisLabel="RunCtrlLVUp"){
				if(RunCtrlListBox=v){
					if((i - 1) <= 0){
						return
					}
					RunCtrlListContent.=v "=" RunCtrlListContentList[v] "`n"
					RunCtrlListContent.=RunCtrlListBoxList[i - 1] "=" RunCtrlListContentList[RunCtrlListBoxList[i - 1]] "`n"
				}else if(RunCtrlListBox!=RunCtrlListBoxList[i + 1]){
					RunCtrlListContent.=v "=" RunCtrlListContentList[v] "`n"
				}
			}
		}
		RunCtrlListContent:=SubStr(RunCtrlListContent, 1, -StrLen("`n"))
		IniWrite,%RunCtrlListContent%,%RunAnyConfig%,RunCtrlList
		gosub,RunCtrl_Manage_Gui
		return
	}
	RunRowNumber1 := LV_GetNext(0, "F")
	if not RunRowNumber1
		return
	if(A_ThisLabel="RunCtrlLVDown"){
		RunRowNumber2 := RunRowNumber1 + 1 
		RunRowCount := LV_GetCount()
		if(RunRowNumber2 > RunRowCount)
			return
	}else if(A_ThisLabel="RunCtrlLVUp"){
		RunRowNumber2 := RunRowNumber1 - 1 
		if(RunRowNumber2 <= 0)
			return
	}
	LV_GetText(RunCtrlRunValue1, RunRowNumber1, 1)
	LV_GetText(RunCtrlNoPath1, RunRowNumber1, 2)
	LV_GetText(RunCtrlRepeatRun1, RunRowNumber1, 3)
	LV_GetText(RunCtrlRunValue2, RunRowNumber2, 1)
	LV_GetText(RunCtrlNoPath2, RunRowNumber2, 2)
	LV_GetText(RunCtrlRepeatRun2, RunRowNumber2, 3)
	LV_Modify(RunRowNumber1,Set_Icon(LVImageListID,RunCtrlNoPath2 ? Get_Obj_Path(RunCtrlRunValue2) : RunCtrlRunValue2,false,false,RunCtrlRunValue2)
		,RunCtrlRunValue2,RunCtrlNoPath2,RunCtrlRepeatRun2)
	LV_Modify(RunRowNumber2,Set_Icon(LVImageListID,RunCtrlNoPath1 ? Get_Obj_Path(RunCtrlRunValue1) : RunCtrlRunValue1,false,false,RunCtrlRunValue1)
		,RunCtrlRunValue1,RunCtrlNoPath1,RunCtrlRepeatRun1)
	;顺序改变后写入配置文件
	runContent=
	Gui, ListView, RunCtrlLV
	Loop % LV_GetCount()
	{
		LV_GetText(RunCtrlRunValue, A_Index, 1)
		LV_GetText(RunCtrlNoPath, A_Index, 2)
		LV_GetText(RunCtrlRepeatRun, A_Index, 3)
		runMenu:=RunCtrlNoPath="菜单项" ? "menu" : "path"
		runRepeat:=RunCtrlRepeatRun="重复" ? "|1" : ""
		runContent.=runMenu runRepeat "=" RunCtrlRunValue "`n"
	}
	runContent:=SubStr(runContent, 1, -StrLen("`n"))
	IniWrite, %runContent%, %RunAnyConfig%, %RunCtrlListBox%_Run
	LV_Modify(0, "-Select")
	LV_Modify(RunRowNumber2, "Select Focus")
return
RunCtrlLVSelect:
	Gui,RunCtrlManage:Default
	LV_Modify(0, "Select Focus")   ; 选择所有.
return
RunCtrlLVRun:
	Gui,RunCtrlManage:Default
	Gui,RunCtrlManage:Submit, NoHide
	GuiControlGet, focusGuiName, Focus
	if(focusGuiName="ListBox1"){
		effectResult:=RunCtrl_RunRules(RunCtrlList[RunCtrlListBox],true)
	}else if(focusGuiName="SysListView321"){
		gosub,LVCtrlRunRun
	}
return
RunCtrlLVAdd:
	RuleGroupName:=RuleGroupLogic2:=RuleMostRun:=RuleIntervalTime:=RuleGroupKey:=RunCtrlListBox:=""
	RuleEnable:=RuleGroupLogic1:=true
	RuleGroupWinKey:=false
	menuItem:="新建"
	gosub,RunCtrlConfig
return
RunCtrlLVEdit:
	RuleGroupName:=RunCtrlListBox
	menuItem:="编辑"
	Gui,RunCtrlManage:Default
	GuiControlGet, focusGuiName, Focus
	if(focusGuiName="ListBox1"){
		RuleEnable:=RunCtrlList[RunCtrlListBox].enable
		RuleEnableText:=RuleEnable ? "Green" : ""
		RuleGroupLogic1:=RunCtrlList[RunCtrlListBox].ruleLogic
		RuleGroupLogic2:=RuleGroupLogic1 ? 0 : 1
		RuleMostRun:=RunCtrlList[RunCtrlListBox].ruleMostRun
		RuleMostRun:=RuleMostRun=0 ? "" : RuleMostRun
		RuleIntervalTime:=RunCtrlList[RunCtrlListBox].ruleIntervalTime
		RuleIntervalTime:=RuleIntervalTime=0 ? "" : RuleIntervalTime
		RuleGroupKey:=RunCtrlList[RunCtrlListBox].key
		RuleGroupWinKey:=0
		if(InStr(RuleGroupKey,"#")){
			RuleGroupWinKey:=1
			RuleGroupKey:=StrReplace(RuleGroupKey, "#")
		}
		gosub,RunCtrlConfig
	}else if(focusGuiName="SysListView321"){
		gosub,LVCtrlRunEdit
	}
return
;~;【启动控制-规则组配置Gui】
RunCtrlConfig:
	Gui,RunCtrlConfig:Destroy
	Gui,RunCtrlConfig:Default
	Gui,RunCtrlConfig:+OwnerRunCtrlManage
	Gui,RunCtrlConfig:Font,,Microsoft YaHei
	Gui,RunCtrlConfig:Margin,20,20
	Gui,RunCtrlConfig:Add, CheckBox, xm+5 y+15 Checked%RuleEnable% vvRuleEnable c%RuleEnableText%, 启用规则组
	Gui,RunCtrlConfig:Add, Text, x+30 yp w60, 全局热键：
	Gui,RunCtrlConfig:Add, Hotkey,x+5 yp-2 w130 h22 vvRuleGroupKey,%RuleGroupKey%
	Gui,RunCtrlConfig:Add, Checkbox, x+10 yp+3 w55 Checked%RuleGroupWinKey% vvRuleGroupWinKey,Win
	Gui,RunCtrlConfig:Add, Text, xm+5 yp+30 w60, 规则组名：
	Gui,RunCtrlConfig:Add, Edit, x+5 yp-3 w300 vvRuleGroupName, %RuleGroupName%
	Gui,RunCtrlConfig:Add, GroupBox,xm y+10 w500 h385,规则组设置
	Gui,RunCtrlConfig:Add, Radio, xm+10 yp+25 Checked%RuleGroupLogic1% vvRuleGroupLogic1, 与（全部规则都验证成立）(&A)
	Gui,RunCtrlConfig:Add, Radio, x+10 yp Checked%RuleGroupLogic2% vvRuleGroupLogic2, 或（一个规则即验证成立）(&O)
	Gui,RunCtrlConfig:Add, Text, xm+10 y+15 w100, 规则循环最大次数:
	Gui,RunCtrlConfig:Add, Edit, x+2 yp-3 Number w50 h20 vvRuleMostRun, %RuleMostRun%
	Gui,RunCtrlConfig:Add, Text, x+20 yp+3 w110, 循环间隔时间(秒):
	Gui,RunCtrlConfig:Add, Edit, x+2 yp-3 w100 h20 vvRuleIntervalTime, %RuleIntervalTime%
	Gui,RunCtrlConfig:Add, Button, xm+10 y+15 w85 GLVFuncAdd, + 增加规则(&A)
	Gui,RunCtrlConfig:Add, Button, x+10 yp w85 GLVFuncEdit, · 修改规则(&E)
	Gui,RunCtrlConfig:Add, Button, x+10 yp w85 GLVFuncRemove, - 减少规则(&D)
	Gui,RunCtrlConfig:Font, s10, Microsoft YaHei
	Gui,RunCtrlConfig:Add, Listview, xm+10 y+10 w480 r10 grid AltSubmit C808000 vFuncLV glistfunc, 规则名|中断|条件|条件值
	;[读取启动项设置的规则内容写入列表]
	GuiControl, RunCtrlConfig:-Redraw, FuncLV
	For k, v in RunCtrlList[RunCtrlListBox].ruleList
	{
		funcBoolean:=v.logic="1" ? "相等" : v.logic="0" ? "不相等" : RunCtrlLogicEnum[v.logic]
		funcBoolean:=rulestatusList[v.name] ? funcBoolean : "规则失效"
		LV_Add("", v.name, v.ruleBreak, funcBoolean, v.value)
	}
	LV_ModifyCol(1)
	LV_ModifyCol(2)
	LV_ModifyCol(3)
	GuiControl, RunCtrlConfig:+Redraw, FuncLV
	Gui,RunCtrlConfig:Add,Button,Default xm+150 y+15 w75 GRunCtrlLVSave,保存(&Y)
	Gui,RunCtrlConfig:Add,Button,x+20 w75 GSetCancel,取消(&C)
	Gui,RunCtrlConfig:Show, , %RunAnyZz% 规则组 - %menuItem% %RunAny_update_version% %RunAny_update_time%%AdminMode%
return

RunCtrlLVSave:
	Gui,RunCtrlConfig:Submit, NoHide
	fnx:=250
	fny:=40
	if(!vRuleGroupName){
		ToolTip, 请填入规则组名,%fnx%,%fny%
		SetTimer,RemoveToolTip,3000
		return
	}
	if(RuleGroupName!=vRuleGroupName && RunCtrlList[vRuleGroupName]){
		ToolTip, 已存在相同的规则组名，请修改,%fnx%,%fny%
		SetTimer,RemoveToolTip,3000
		return
	}
	if(Instr(vRuleGroupName, A_SPACE)){
		StringReplace, vRuleGroupName, vRuleGroupName, %A_SPACE%, _, All
		GuiControl, RunCtrlConfig:, vRuleGroupName, %vRuleGroupName%
		ToolTip, 规则组名不能带有空格，请用_代替,%fnx%,%fny%
		SetTimer,RemoveToolTip,3000
		return
	}
	if(Instr(vRuleGroupName, A_Tab)){
		StringReplace, vRuleGroupName, vRuleGroupName, %A_Tab%, _, All
		GuiControl, RunCtrlConfig:, vRuleGroupName, %vRuleGroupName%
		ToolTip, 规则组名不能带有制表符，请用_代替,%fnx%,%fny%
		SetTimer,RemoveToolTip,3000
		return
	}
	;中文、数字、字母、下划线正则校验，根据Unicode字符属性Han来判断中文，RunAnyCtrl.ahk编码不能为ANSI
	if(!RegExMatch(vRuleGroupName,"^[\p{Han}A-Za-z0-9_]+$")){
		ToolTip, 规则组名只能为中文、数字、字母、下划线,%fnx%,%fny%
		SetTimer,RemoveToolTip,5000
		return
	}
	runContent:=ruleContent:=""
	Loop % LV_GetCount()
	{
		LV_GetText(RuleName, A_Index, 1)
		LV_GetText(FuncBreak, A_Index, 2)
		LV_GetText(FuncBoolean, A_Index, 3)
		LV_GetText(FuncValue, A_Index, 4)
		FuncBoolean:=RunCtrlLogicEnumGetKey(FuncBoolean)
		FuncBoolean:=FuncBoolean="eq" ? 1 : FuncBoolean="ne" ? 0 : FuncBoolean
		FuncBreak:=FuncBreak ? "|" FuncBreak : ""
		ruleContent.=RuleName . "|" . FuncBoolean . FuncBreak . "=" . FuncValue . "`n"
	}
	;~ ;[写入配置文件]
	Gui,RunCtrlManage:Default
	ruleLogicVal:=vRuleGroupLogic1=1 ? 1 : 0
	if(RuleGroupName!=vRuleGroupName){
		IniDelete, %RunAnyConfig%, RunCtrlList, %RuleGroupName%
		IniDelete, %RunAnyConfig%, %RuleGroupName%_Rule
		IniDelete, %RunAnyConfig%, %RuleGroupName%_Run
	}
	ruleRunListVal=%vRuleEnable%|%ruleLogicVal%
	if(vRuleMostRun!=""){
		ruleRunListVal.="|" vRuleMostRun "|" vRuleIntervalTime
	}
	if(vRuleGroupKey!=""){
		if(vRuleMostRun=""){
			ruleRunListVal.="||"
		}
		vRuleGroupKey:=vRuleGroupWinKey ? "#" . vRuleGroupKey : vRuleGroupKey
		ruleRunListVal.="|" vRuleGroupKey
	}
	IniWrite, %ruleRunListVal%, %RunAnyConfig%, RunCtrlList, %vRuleGroupName%

	if(RunCtrlList[RuleGroupName]){
		For runn, runv in RunCtrlList[RuleGroupName].runList
		{
			runMenu:=runv.noPath ? "menu" : "path"
			runRepeat:=runv.repeatRun ? "|1" : ""
			runContent.=runMenu runRepeat "=" runv.path "`n"
		}
		runContent:=SubStr(runContent, 1, -StrLen("`n"))
	}
	IniWrite, %runContent%, %RunAnyConfig%, %vRuleGroupName%_Run
	ruleContent:=SubStr(ruleContent, 1, -StrLen("`n"))
	IniWrite, %ruleContent%, %RunAnyConfig%, %vRuleGroupName%_Rule
	Gui,RunCtrlConfig:Destroy
	gosub,RunCtrl_Manage_Gui
return
; LVImport:
; 	FileSelectFile, selectName, M35, , 选择多项要导入的AHK(EXE), (*.ahk;*.exe)
; 	Loop,parse,selectName,`n
; 	{
; 		if(A_Index=1){
; 			dir:=A_LoopField
; 		}else{
; 			fullPath:=dir "\" A_LoopField
; 			SplitPath, fullPath, , , ext, name_no_ext
; 			if(run_item_List[name_no_ext]){
; 				TrayTip,,导入项中有已存在的相同文件名启动项，不会导入,3,1
; 				continue
; 			}
; 			LV_Add("", name_no_ext, ext, "", "", "", "", , "", "", , ,"", , fullPath)
; 			IniWrite, %fullPath%, %iniFile%, run_item, %name_no_ext%
; 		}
; 	}
; 	LVModifyCol(38,ColumnAutoRun,ColumnHideRun,ColumnCloseRun,ColumnRepeatRun,ColumnRuleRun,ColumnRuleLogic)  ; 根据内容自动调整每列的大小.
; return
;══════════════════════════════════════════════════════════════════════════════════════════════════════
;[规则函数配置]
LVFuncAdd:
	menuFuncItem:="新建规则函数"
	RuleName:=FuncBoolean:=FuncValue:=""
	FuncBooleanNE:=FuncBooleanGE:=FuncBooleanLE:=FuncBooleanGT:=FuncBooleanLT:=FuncBreak:=false
	FuncBooleanEQ:=true
	RuleNameChoose:=1
	gosub,LVFuncConfig
return
LVFuncEdit:
	menuFuncItem:="修改规则函数"
	RowNumber:=LV_GetNext(0, "F")
	if not RowNumber
		return
	LV_GetText(RuleName, RowNumber, 1)
	LV_GetText(FuncBreak, RowNumber, 2)
	LV_GetText(FuncBoolean, RowNumber, 3)
	LV_GetText(FuncValue, RowNumber, 4)
	FuncBreak:=FuncBreak ? 1 : 0
	for k,v in RunCtrlLogicEnum
	{
		FuncBoolean%k%:=false
		if(v=FuncBoolean){
			FuncBoolean%k%:=true
		}
	}
	RuleNameChoose:=1
	loop, parse, rulenameStr, |
	{
		if(RuleName=A_LoopField){
			RuleNameChoose:=A_Index
			break
		}
	}
	FuncValue:=StrReplace(FuncValue,"``t","`t")
	FuncValue:=StrReplace(FuncValue,"``n","`n")
	gosub,LVFuncConfig
return
;~;【启动控制-运行规则Gui】
LVFuncConfig:
	Gui,RunCtrlFunc:Destroy
	Gui,RunCtrlFunc:+OwnerRunCtrlConfig
	Gui,RunCtrlFunc:Font,,Microsoft YaHei
	Gui,RunCtrlFunc:Margin,20,10
	Gui,RunCtrlFunc:Add, Text, xm y+10 w60, 规则名：
	Gui,RunCtrlFunc:Add, DropDownList, xm+60 yp-3 Choose%RuleNameChoose% GDropDownRuleChoose vvRuleName, %RuleNameStr%
	Gui,RunCtrlFunc:Add, Text, x+10 yp+3 cblue w150 vvRuleResultText, 
	Gui,RunCtrlFunc:Add, Radio, xm y+10 Checked%FuncBooleanEQ% vvFuncBooleanEQ, 相等 ( 真 &True 1)
	Gui,RunCtrlFunc:Add, Radio, x+4 yp Checked%FuncBooleanNE% vvFuncBooleanNE, 不相等 ( 假 &False 0)
	Gui,RunCtrlFunc:Add, Radio, xm y+10 Checked%FuncBooleanGE% vvFuncBooleanGE, 大于等于　　　
	Gui,RunCtrlFunc:Add, Radio, x+10 yp Checked%FuncBooleanLE% vvFuncBooleanLE, 小于等于　　　
	Gui,RunCtrlFunc:Add, Radio, xm y+10 Checked%FuncBooleanGT% vvFuncBooleanGT, 大于　　　　　
	Gui,RunCtrlFunc:Add, Radio, x+10 yp Checked%FuncBooleanLT% vvFuncBooleanLT, 小于　　　　　
	Gui,RunCtrlFunc:Add, CheckBox, xm y+10 Checked%FuncBreak% vvFuncBreak, 不满足此条件就中断整个规则循环（排在其他规则前面）
	Gui,RunCtrlFunc:Add, Text, xm y+10 w350 vvRuleText, 条件值：（只判断规则真假，可不填写）
	Gui,RunCtrlFunc:Add, Text, xm yp w350 cblue vvRuleParamText, 条件值：（条件值变为参数传递到规则函数，只判断结果真假）
	; `n多个参数每行为一个参数，最多支持10个，保存会用|分隔
	Gui,RunCtrlFunc:Add, Edit, xm y+10 w350 r6 vvFuncValue GFuncValueChange, %FuncValue%
	Gui,RunCtrlFunc:Add, Button,Default xm+80 y+15 w75 GLVFuncSave,保存(&Y)
	Gui,RunCtrlFunc:Add, Button,x+10 w75 GSetCancel,取消(&C)
	Gui,RunCtrlFunc:Show, , %RunAnyZz% 修改规则函数 %RunAny_update_version% %RunAny_update_time%%AdminMode%
	gosub,DropDownRuleChoose
return
LVFuncRemove:
	DelRowList:=""
	RowNumber:=0
	Loop
	{
		RowNumber := LV_GetNext(RowNumber)  ; 在前一次找到的位置后继续搜索.
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		DelRowList:=RowNumber . ":" . DelRowList
	}
	stringtrimright, DelRowList, DelRowList, 1
	loop, parse, DelRowList, :
		LV_Delete(A_loopfield)
return
LVFuncSave:
	Gui,RunCtrlFunc:Submit, NoHide
	fnx:=40
	fny:=230
	if(!vRuleName){
		ToolTip, 请选择使用的规则,%fnx%,%fny%
		SetTimer,RemoveToolTip,3000
		return
	}
	if(vFuncValue="" && !(vFuncBooleanEQ || vFuncBooleanNE)){
		ToolTip, 如果是大于或小于请填写条件值,%fnx%,%fny%
		SetTimer,RemoveToolTip,3000
		return
	}
	vFuncValue:=StrReplace(vFuncValue,"`t","``t")
	vFuncValue:=StrReplace(vFuncValue,"`n","``n")
	;[写入配置文件]
	Gui,RunCtrlFunc:Destroy
	Gui,RunCtrlConfig:Default
	for k,v in RunCtrlLogicEnum
	{
		if(vFuncBoolean%k%){
			funcBoolean:=k
		}
	}
	ruleLogic:=RunCtrlLogicEnum[funcBoolean]
	if(menuFuncItem="修改规则函数"){
		LV_Modify(RowNumber,"",vRuleName,vFuncBreak ? "*" : "",ruleLogic,vFuncValue)
	}else{
		LV_Add("",vRuleName,vFuncBreak ? "*" : "",ruleLogic,vFuncValue)
	}
	LV_ModifyCol(1)
	LV_ModifyCol(2)
	LV_ModifyCol(3)
	GuiControl, RunCtrlConfig:+Redraw, FuncLV
return
listfunc:
    if A_GuiEvent = DoubleClick
    {
		gosub,LVFuncEdit
    }
return
DropDownRuleChoose:
	Gui,RunCtrlFunc:Submit, NoHide
	if(ruleparamList[vRuleName]){
		GuiControl, RunCtrlFunc:show, vRuleParamText
		GuiControl, RunCtrlFunc:hide, vRuleText
		if(FuncBooleanEQ){
			GuiControl, RunCtrlFunc:,vFuncBooleanEQ,1
		}else{
			GuiControl, RunCtrlFunc:,vFuncBooleanNE,1
		}
		GuiControl, RunCtrlFunc:Disable, vFuncBooleanGE
		GuiControl, RunCtrlFunc:Disable, vFuncBooleanLE
		GuiControl, RunCtrlFunc:Disable, vFuncBooleanGT
		GuiControl, RunCtrlFunc:Disable, vFuncBooleanLT
	}else{
		GuiControl, RunCtrlFunc:show, vRuleText
		GuiControl, RunCtrlFunc:hide, vRuleParamText
		GuiControl, RunCtrlFunc:enable, vFuncBooleanGE
		GuiControl, RunCtrlFunc:enable, vFuncBooleanLE
		GuiControl, RunCtrlFunc:enable, vFuncBooleanGT
		GuiControl, RunCtrlFunc:enable, vFuncBooleanLT
	}
	GuiControl, RunCtrlFunc:,vRuleResultText,% RunCtrl_RuleResult(vRuleName, ruleitemList[vRuleName], vFuncValue)
return
FuncValueChange:
	Gui,RunCtrlFunc:Submit, NoHide
	if(!InStr(rulefileList[vRuleName],"RunCtrl_Network.ahk")){
		gosub,DropDownRuleChoose
	}
return
SetFilePath:
	FileSelectFile, filePath, 3, , 请选择导入的启动项, (*.ahk;*.exe)
	GuiControl, RunCtrlConfig:, vFilePath, %filePath%
return
;~;【启动控制-启动项Gui】
LVCtrlRunAdd:
	menuItem:="新建"
	RunCtrlRepeatRun:=RunCtrlRunValue:=""
	RunCtrlNoPath:="菜单项"
	gosub,LVCtrlRunConfig
return
LVCtrlRunEdit:
	menuItem:="编辑"
	gosub,LVCtrlRunConfig
return
LVCtrlRunRun:
	Loop
	{
		RowNumber := LV_GetNext(RowNumber)  ; 在前一次找到的位置后继续搜索.
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		LV_GetText(RunCtrlRunValue, RowNumber, 1)
		LV_GetText(RunCtrlNoPath, RowNumber, 2)
		LV_GetText(RunCtrlRepeatRun, RowNumber, 3)
		RunCtrl_RunApps(RunCtrlRunValue, RunCtrlNoPath="菜单项" ? 1 : 0, 1)
	}
return
LVCtrlRunConfig:
	Gui, ListView, RunCtrlLV
	if(menuItem="编辑"){
		RunRowNumber := LV_GetNext(0, "F")
		if not RunRowNumber
			return
		LV_GetText(RunCtrlRunValue, RunRowNumber, 1)
		LV_GetText(RunCtrlNoPath, RunRowNumber, 2)
		LV_GetText(RunCtrlRepeatRun, RunRowNumber, 3)
	}
	RunCtrlNoPath1:=RunCtrlNoPath="菜单项" ? 1 : 0
	RunCtrlNoPath2:=RunCtrlNoPath1 ? 0 : 1
	RunCtrlRepeatRun:=RunCtrlRepeatRun="重复" ? 1 : 0
	Gui,CtrlRun:Destroy
	Gui,CtrlRun:Default
	Gui,CtrlRun:+OwnerRunCtrlManage
	Gui,CtrlRun:Margin,20,20
	Gui,CtrlRun:Font,,Microsoft YaHei
	Gui,CtrlRun:Add, Radio, xm+10 yp+25 Checked%RunCtrlNoPath1% vvRunCtrlNoPath1, 菜单项(&Z)
	Gui,CtrlRun:Add, Radio, x+10 yp Checked%RunCtrlNoPath2% vvRunCtrlNoPath2, 全路径(&A)
	Gui,CtrlRun:Add, CheckBox, x+30 yp Checked%RunCtrlRepeatRun% vvRunCtrlRepeatRun, 重复启动(&R)
	Gui,CtrlRun:Add, Button, xm+5 y+15 w60 GSetRunCtrlRunValue,运行软件路径`n或菜单项
	Gui,CtrlRun:Add, Edit, x+12 yp w300 r3 -WantReturn vvRunCtrlRunValue, %RunCtrlRunValue%
	Gui,CtrlRun:Font
	Gui,CtrlRun:Add,Button,Default xm+100 y+25 w75 GSaveRunCtrlRunValue,保存(&Y)
	Gui,CtrlRun:Add,Button,x+20 w75 GSetCancel,取消(&C)
	Gui,CtrlRun:Show,,%RunAnyZz% - %openExtItem%启动项 %RunAny_update_version% %RunAny_update_time%
return
SetRunCtrlRunValue:
	Gui,CtrlRun:Submit, NoHide
	if(vRunCtrlNoPath1){
		global RunCtrlMenuItemFlag:=true
		gosub,Menu_Edit1
	}else if(vRunCtrlNoPath2){
		FileSelectFile, runPath, , , 启动程序路径
		if(runPath){
			GuiControlSet("CtrlRun","vRunCtrlRunValue",runPath)
		}
	}
return
SaveRunCtrlRunValue:
	Gui,CtrlRun:Submit, NoHide
	if(RunCtrlListBox=""){
		Gui,CtrlRun:Destroy
		return
	}
	oldRunMenu:=RunCtrlNoPath1 ? "menu" : "path"
	oldRunRepeat:=RunCtrlRepeatRun ? "|1" : ""
	oldStr:=oldRunMenu oldRunRepeat "=" RunCtrlRunValue
	newRunMenu:=vRunCtrlNoPath1 ? "menu" : "path"
	newRunRepeat:=vRunCtrlRepeatRun ? "|1" : ""
	newStr:=newRunMenu newRunRepeat "=" vRunCtrlRunValue
	if(oldStr=newStr){
		Gui,CtrlRun:Destroy
		return
	}
	if(vRunCtrlNoPath2 && !InStr(vRunCtrlRunValue,".")){
		ToolTip, 全路径是直接运行，不是运行RunAny菜单项，请填写正确的启动项,30,25
		SetTimer,RemoveToolTip,5000
		return
	}
	IniRead,ctrlAppsVar,%RunAnyConfig%,%RunCtrlListBox%_Run
	runContent:=""
	if(menuItem="编辑"){
		Loop, parse, ctrlAppsVar, `n, `r
		{
			runContent.=A_LoopField=oldStr ? newStr "`n" : A_LoopField "`n"
		}
		runContent:=SubStr(runContent, 1, -StrLen("`n"))
	}else if(menuItem="新建"){
		runContent:=ctrlAppsVar!="" ? ctrlAppsVar "`n" newStr : newStr
	}
	IniWrite,%runContent%,%RunAnyConfig%,%RunCtrlListBox%_Run
	gosub,RunCtrl_Manage_Gui
return
;══════════════════════════════════════════════════════════════════════════════════════════════════════
;~;【——规则Gui——】
;══════════════════════════════════════════════════════════════════════════════════════════════════════
Rule_Manage_Gui:
	gosub,RunCtrl_Read
	Gui,RuleManage:Destroy
	Gui,RuleManage:Default
	Gui,RuleManage:+Resize
	Gui,RuleManage:Font, s10, Microsoft YaHei
	Gui,RuleManage:Add, Listview, xm w660 r18 grid AltSubmit BackgroundF6F6E8 vRuleLV glistrule, 规则名|规则函数|状态|类型|参数|示例|规则插件名
	;[读取规则内容写入列表]
	GuiControl, -Redraw, RuleLV
	For kName, kVal in rulefileList
	{
		LV_Add("", kName, rulefuncList[kName], rulestatusList[kName] ? "正常" : "不可用"
			,ruletypelist[kName] ? "变量" : "插件",ruleparamList[kName] ? "传参" : ""
			,!InStr(kVal,"RunCtrl_Network.ahk") ? RunCtrl_RuleResult(kName, ruleitemList[kName], "") : "http://ip-api.com/json" , kVal)
	}
	GuiControl, +Redraw, RuleLV
	Menu, ruleGuiMenu, Add, 新增, LVRulePlus
	Menu, ruleGuiMenu, Icon, 新增, SHELL32.dll,1
	Menu, ruleGuiMenu, Add, 修改, LVRuleEdit
	Menu, ruleGuiMenu, Icon, 修改, SHELL32.dll,134
	Menu, ruleGuiMenu, Add, 减少, LVRuleMinus
	Menu, ruleGuiMenu, Icon, 减少, SHELL32.dll,132
	Gui,RuleManage:Menu, ruleGuiMenu
	LV_ModifyCol()  ; 根据内容自动调整每列的大小.
	LV_ModifyCol(2,"Sort")
	Gui,RuleManage:Show, , %RunAnyZz% 规则管理 %RunAny_update_version% %RunAny_update_time%%AdminMode%
return
LVRulePlus:
	menuRuleItem:="规则新建"
	RuleName:=RuleFunction:=RulePath:=""
	gosub,RuleConfig_Gui
return
LVRuleEdit:
	RowNumber:=LV_GetNext(0, "F")
	if not RowNumber
		return
	LV_GetText(RuleName, RowNumber, 1)
	LV_GetText(RuleFunction, RowNumber, 2)
	LV_GetText(RuleType, RowNumber, 4)
	LV_GetText(RulePath, RowNumber, 7)
	menuRuleItem:="规则编辑"
	RuleTypeVar:=RuleType="变量" ? 1 : 0
	RuleTypeFunc:=RuleTypeVar=1 ? 0 : 1
	gosub,RuleConfig_Gui
return
;~;【规则-编辑Gui】
RuleConfig_Gui:
	Gui,RuleConfig:Destroy
	Gui,RuleConfig:+OwnerRuleManage
	Gui,RuleConfig:Font,,Microsoft YaHei
	Gui,RuleConfig:Margin,20,10
	Gui,RuleConfig:Add, Text, xm y+10 w60, 规则名：
	Gui,RuleConfig:Add, Edit, xm+60 yp-3 w450 vvRuleName, %RuleName%
	Gui,RuleConfig:Add, Text, xm y+10 w60, 规则类型：
	Gui,RuleConfig:Add, Radio, x+4 yp Checked%RuleTypeVar% GRuleTypeChange vvRuleTypeVar, 菜单变量
	Gui,RuleConfig:Add, Radio, x+4 yp Checked%RuleTypeFunc% GRuleTypeChange vvRuleTypeFunc, 插件函数
	Gui,RuleConfig:Add, Link, x+15 yp vvVarDocs,<a href="https://hui-zz.gitee.io/runany/#/article/built-in-variables">变量参考</a>
	Gui,RuleConfig:Add, Text, xm y+10 w60, 规则函数：
	Gui,RuleConfig:Add, Edit, xm+60 yp-3 w225 vvRuleFunction, %RuleFunction%
	Gui,RuleConfig:Add, DropDownList, x+5 yp+2 w220 vvRuleDLL GDropDownRuleList
	Gui,RuleConfig:Add, Button, xm-5 yp+30 w60 h60 vvSetRulePath GSetRulePath,规则路径 可自动识别函数名
	Gui,RuleConfig:Add, Edit, xm+60 yp w450 r3 vvRulePath GRulePathChange, %RulePath%
	Gui,RuleConfig:Add, Button,Default xm+180 y+10 w75 GLVRuleSave,保存(&Y)
	Gui,RuleConfig:Add, Button,x+10 w75 GSetCancel,取消(&C)
	Gui,RuleConfig:Show, , %RunAnyZz% 规则编辑 %RunAny_update_version% %RunAny_update_time%%AdminMode%
	funcnameStr:=KnowAhkFuncZz(RulePath)
	GuiControl, RuleConfig:, vRuleDLL, |
	GuiControl, RuleConfig:, vRuleDLL, %funcnameStr%
	funcNameChoose:=1
	loop, parse, funcnameStr, |
	{
		if(RuleFunction=A_LoopField){
			funcNameChoose:=A_Index
			break
		}
	}
	GuiControl, RuleConfig:Choose, vRuleDLL, %funcNameChoose%
	gosub,RuleTypeChange
return
LVRuleMinus:
	DelRowList:=""
	Row:=LV_GetNext(0, "F")
	RowNumber:=0
	if(Row)
		MsgBox,35,确认删除？(Esc取消),确定删除选中的规则项？`n【注意！】此操作会连带删除所有规则组中用到的这个规则
	Loop
	{
		RowNumber := LV_GetNext(RowNumber)  ; 在前一次找到的位置后继续搜索.
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		IfMsgBox Yes
		{
			LV_GetText(RuleName, RowNumber, 1)
			LV_GetText(RuleFunction, RowNumber, 2)
			LV_GetText(RulePath, RowNumber, 7)
			DelRowList:=RowNumber . ":" . DelRowList
			IniDelete, %RunAnyConfig%, RunCtrlRule, %RuleName%|%RuleFunction%
			;删除所有正在使用此规则的关联配置
			Change_Rule_Name(RuleName,"")
			gosub,RunCtrl_Read
		}
	}
	IfMsgBox Yes
	{
		stringtrimright, DelRowList, DelRowList, 1
		loop, parse, DelRowList, :
			LV_Delete(A_loopfield)
	}
return
LVRuleSave:
	Gui,RuleConfig:Submit, NoHide
	if(vRuleTypeVar){
		vRulePath:=0
	}
	if(!vRuleName || !vRuleFunction || vRulePath=""){
		MsgBox, 48, ,请填入规则名、规则函数和规则路径
		return
	}
	if(InStr(vRuleName,"|")){
		MsgBox, 48, ,规则名不能包含有“|”分割符
		return
	}
	if(RuleName!=vRuleName && rulefileList[vRuleName]){
		MsgBox, 48, ,已存在相同的规则名，请修改
		return
	}
	if(vRuleTypeFunc){
		checkRulePath:=Get_Transform_Val(vRulePath)
		if(!FileExist(checkRulePath) && !FileExist(A_ScriptDir "\" PluginsDir "\" checkRulePath)){
			MsgBox, 48, ,规则路径AHK脚本不存在，请重新添加
			return
		}
	}
	;[写入配置文件]
	Gui,RuleManage:Default
	if(menuRuleItem="规则编辑"){
		if(RuleName!=vRuleName || RuleFunction!=vRuleFunction){
			IniDelete, %RunAnyConfig%, RunCtrlRule, %RuleName%|%RuleFunction%
			;~ 变更所有正在使用此规则的启动项中关联规则名称
			if(RuleName!=vRuleName)
				Change_Rule_Name(RuleName,vRuleName)
		}
		LV_Modify(RowNumber,"",vRuleName,vRuleFunction,"重启生效",vRuleTypeVar ? "变量" : "插件",ruleparamList[vRuleName] ? "传参" : "",,vRulePath)
	}else{
		LV_Add("",vRuleName,vRuleFunction,"重启生效",vRuleTypeVar ? "变量" : "插件",ruleparamList[vRuleName] ? "传参" : "",,vRulePath)
	}
	IniWrite, %vRulePath%, %RunAnyConfig%, RunCtrlRule, %vRuleName%|%vRuleFunction%
	LV_ModifyCol()  ; 根据内容自动调整每列的大小.
	GuiControl, RuleManage:+Redraw, RuleLV
	gosub,RunCtrl_Read
	Gui,RuleConfig:Destroy
return
listrule:
    if A_GuiEvent = DoubleClick
    {
		gosub,LVRuleEdit
    }
return
SetRulePath:
	FileSelectFile, rulePath, 3, , 请选择要使用的的AutoHotkey规则脚本, (*.ahk)
	if(rulePath){
		Gui,RuleConfig:Submit, NoHide
		Get_Rule_Func_Name(rulePath,vRuleFunction)
		rulePath:=StrReplace(rulePath,A_ScriptDir "\" PluginsDir "\")
		rulePath:=StrReplace(rulePath,A_ScriptDir "\")
		GuiControl, RuleConfig:, vRulePath, %rulePath%
	}
return
RuleTypeChange:
	Gui,RuleConfig:Submit, NoHide
	if(vRuleTypeVar){
		GuiControlShow("RuleConfig","vVarDocs")
		GuiControlHide("RuleConfig","vRuleDLL","vSetRulePath","vRulePath")
	}else{
		GuiControlShow("RuleConfig","vRuleDLL","vSetRulePath","vRulePath")
		GuiControlHide("RuleConfig","vVarDocs")
		if(vRulePath="0"){
			GuiControl, RuleConfig:, vRulePath, RunCtrl_Common.ahk
			gosub,RulePathChange
		}
	}
return
RulePathChange:
	Gui,RuleConfig:Submit, NoHide
	Get_Rule_Func_Name(vRulePath,vRuleFunction)
return
DropDownRuleList:
	Gui,RuleConfig:Submit, NoHide
	GuiControl, RuleConfig:, vRuleFunction, %vRuleDLL%
return
;[自动根据规则脚本的路径来变更函数下拉选择框和空规则函数]
Get_Rule_Func_Name(rulePath,vRuleFunction){
	if(rulePath){
		funcnameStr:=KnowAhkFuncZz(rulePath)
		GuiControl, RuleConfig:, vRuleDLL, |
		GuiControl, RuleConfig:, vRuleDLL, %funcnameStr%
		GuiControl, RuleConfig:Choose, vRuleDLL, 1
		if(!vRuleFunction && funcnameStr){
			gosub,DropDownRuleList
		}
	}
}
;[变更所有正在使用此规则的启动项中关联规则名称]
Change_Rule_Name(rname,rnew){
	if(rname=rnew)
		Return
	for n,obj in RunCtrlList
	{
		runCtrlName:=obj.name
		for i,r in obj.ruleList
		{
			if(r.name=rname && runCtrlName!=""){
				IniDelete,%RunAnyConfig%,%runCtrlName%_Rule,% r.name "|" r.logic
				IniWrite,% r.value, %RunAnyConfig%, %runCtrlName%_Rule,% rnew "|" r.logic
			}
		}
	}
}
/*
【自动识别AHK脚本中的函数 by hui-Zz】
ahkPath AHK脚本路径
return AHK脚本所有函数用|分隔的字符串,没有返回""
*/
KnowAhkFuncZz(ahkPath){
	ahkPath:=Get_Transform_Val(ahkPath)
	if(FileExist(A_ScriptDir "\" PluginsDir "\" ahkPath)){
		ahkPath:=A_ScriptDir "\" PluginsDir "\" ahkPath
	}
	funcName:=funcnameStr:=""
	StringReplace, checkPath, ahkPath,`%A_ScriptDir`%, %A_ScriptDir%
	if(FileExist(checkPath)){
		funcIndex:=0
		getFuncNameReg:="iS)^\t*\s*(?!if)([^\s\.,:=\(]*)\(.*?\)\t*\s*"
		getFuncNameReg1:=getFuncNameReg . "\{"
		getFuncNameReg2:=getFuncNameReg . "$"
		Loop, read, %checkPath%
		{
			if(RegExMatch(A_LoopReadLine,getFuncNameReg1)){
				funcnameStr.=RegExReplace(A_LoopReadLine,getFuncNameReg1,"$1") . "|"
			}
			if(funcName && A_Index=funcIndex && RegExMatch(A_LoopReadLine,"^\t*\s*\{\t*\s*$")){
				funcnameStr.=funcName . "|"
			}
			if(RegExMatch(A_LoopReadLine,getFuncNameReg2)){
				funcName:=RegExReplace(A_LoopReadLine,getFuncNameReg2,"$1")
				funcIndex:=A_Index+1
			}
		}
		stringtrimright, funcnameStr, funcnameStr, 1
	}
	return funcnameStr
}
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
;~;【——设置选项Gui——】
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
Settings_Gui:
	if(GetKeyState("Shift")){
		gosub,Menu_Config
		return
	}
	HotKeyFlag:=MenuVarFlag:=OpenExtFlag:=AdvancedConfigFlag:=false
	GUI_WIDTH_66=640
	TAB_WIDTH_66=620
	GROUP_WIDTH_66=590
	GROUP_LISTVIEW_WIDTH_66=580
	GROUP_CHOOSE_EDIT_WIDTH_66=510
	GROUP_ICON_EDIT_WIDTH_66=480
	MARGIN_TOP_66=15
	ev := new everything
	Gui,66:Destroy
	Gui,66:Default
	Gui,66:+Resize
	Gui,66:Margin,30,20
	Gui,66:Font,,Microsoft YaHei
	Gui,66:Add,Tab3,x10 y10 w%TAB_WIDTH_66% h475 vConfigTab +Theme -Background,RunAny设置|热键配置|菜单变量|搜索Everything|一键直达|内部关联|热字符串|图标设置|高级配置
	Gui,66:Tab,RunAny设置,,Exact
	Gui,66:Add,Checkbox,Checked%AutoRun% xm y+%MARGIN_TOP_66% vvAutoRun,开机自动启动
	Gui,66:Add,Checkbox,Checked%AdminRun% x+25 vvAdminRun,管理员权限运行所有软件和插件
	Gui,66:Add,Button,x+20 w245 h20 gSetScheduledTasks,系统任务计划方式：开机管理员启动%RunAnyZz%
	Gui,66:Add,GroupBox,xm-10 y+10 w%GROUP_WIDTH_66% h105,RunAny应用菜单
	Gui,66:Add,Checkbox,Checked%HideFail% xm yp+20 vvHideFail,隐藏失效项
	Gui,66:Add,Checkbox,Checked%HideSend% x+180 vvHideSend,隐藏短语
	Gui,66:Add,Checkbox,Checked%HideWeb% xm yp+20 vvHideWeb,隐藏带`%s网址
	Gui,66:Add,Checkbox,Checked%HideGetZz% x+163 vvHideGetZz,隐藏带`%getZz`%插件脚本
	Gui,66:Add,Checkbox,Checked%HideSelectZz% xm yp+20 vvHideSelectZz gSetHideSelectZz,隐藏选中目标提示
	Gui,66:Add,Checkbox,Checked%HideAddItem% x+144 vvHideAddItem,隐藏【添加到此菜单】
	Gui,66:Add,Checkbox,Checked%HideMenuTray% xm yp+20 vvHideMenuTray,隐藏底部“RunAny设置”
	Gui,66:Add,Edit,x+101 w30 h20 vvRecentMax,%RecentMax%
	Gui,66:Add,Text,x+5 yp+2,最近运行项数量 (0为隐藏)
	Gui,66:Add,Button,x+5 w50 h20 gSetClearRecentMax,清理

	Gui,66:Add,GroupBox,xm-10 y+10 w225 h55,RunAny菜单热键 %MenuHotKey%
	Gui,66:Add,Hotkey,xm yp+20 w150 vvMenuKey,%MenuKey%
	Gui,66:Add,Checkbox,Checked%MenuWinKey% xm+155 yp+3 w55 vvMenuWinKey gSetMenuWinKey,Win

	If(MENU2FLAG){
		Gui,66:Add,GroupBox,x+60 yp-23 w225 h55,菜单2热键 %MenuHotKey2%
		Gui,66:Add,Hotkey,xp+10 yp+20 w150 vvMenuKey2,%MenuKey2%
		Gui,66:Add,Checkbox,Checked%MenuWinKey2% xp+155 yp+3 w55 vvMenuWinKey2 gSetMenuWinKey2,Win
	}else{
		Gui,66:Add,Button,x+60 yp-5 w150 GSetMenu2,开启第2个菜单
	}

	Gui,66:Add,GroupBox,xm-10 y+20 w%GROUP_WIDTH_66% h110,RunAny.ini文件设置
	Gui,66:Add,Edit,xm yp+20 w50 h20 vvAutoReloadMTime,%AutoReloadMTime%
	Gui,66:Add,Text,x+5 yp+2,(毫秒)  RunAny.ini修改后自动重启，0为不自动重启
	Gui,66:Add,Checkbox,xm yp+25 Checked%RunABackupRule% vvRunABackupRule,自动备份
	Gui,66:Add,Text,x+5 yp,最多备份数量
	Gui,66:Add,Edit,x+5 yp-2 w70 h20 vvRunABackupMax,%RunABackupMax%
	Gui,66:Add,Text,x+5 yp+2,备份文件名格式
	Gui,66:Add,Edit,x+5 yp-2 w236 h20 vvRunABackupFormat,%RunABackupFormat%
	Gui,66:Add,Button,xm yp+25 GSetRunABackupDir,RunAny.ini自动备份目录
	Gui,66:Add,Edit,x+11 yp+2 w400 r1 vvRunABackupDir,%RunABackupDir%
	
	Gui,66:Add,GroupBox,xm-10 y+15 vvDisableAppGroup,屏蔽RunAny程序列表（逗号分隔）
	Gui,66:Font,,Consolas
	Gui,66:Add,Edit,xm yp+25 r4 -WantReturn vvDisableApp,%DisableApp%
	Gui,66:Font,,Microsoft YaHei
	
	Gui,66:Tab,热键配置,,Exact
	Gui,66:Add,Link,xm y+%MARGIN_TOP_66% w%GROUP_WIDTH_66%
		,%RunAnyZz%热键配置列表（双击修改，按F2可手写AHK使用特殊热键，<a href="https://wyagd001.github.io/zh-cn/docs/KeyList.htm">如Space、CapsLock、Tab等</a>）
	Gui,66:Add,Listview,xm yp+20 w%GROUP_LISTVIEW_WIDTH_66% r16 AltSubmit -ReadOnly -Multi vRunAnyHotkeyLV glistviewHotkey, 热键AHK写法|热键说明|热键变量名
	kvLenMax:=0
	GuiControl, 66:-Redraw, RunAnyHotkeyLV
	For ki, kv in HotKeyList
	{
		StringReplace,keyV,kv,Hot
		StringReplace,winkeyV,kv,Hot,Win
		if(!MENU2FLAG){
			if ki in 2,6,8
			{
				continue
			}
		}
		%kv%:=%winkeyV% ? "#" . %keyV% : %keyV%
		LV_Add("", %kv%, HotKeyTextList[ki], kv)
		if(StrLen(%kv%)>kvLenMax)
			kvLenMax:=StrLen(%kv%)
	}
	LV_ModifyCol()
	if(kvLenMax<13)
		LV_ModifyCol(1,"AutoHdr")  ;列宽调整为标题对齐
	GuiControl, 66:+Redraw, RunAnyHotkeyLV
	
	Gui,66:Add,GroupBox,xm-10 y+%MARGIN_TOP_66% w%GROUP_WIDTH_66% h125,RunAny多种方式启动菜单（与第三方软件热键冲突则取消勾选）
	Gui,66:Add,Checkbox,Checked%MenuDoubleCtrlKey% xm yp+20 vvMenuDoubleCtrlKey,双击Ctrl键
	Gui,66:Add,Checkbox,Checked%MenuDoubleAltKey% x+166 vvMenuDoubleAltKey,双击Alt键
	Gui,66:Add,Checkbox,Checked%MenuDoubleLWinKey% xm yp+20 vvMenuDoubleLWinKey,双击左Win键
	Gui,66:Add,Checkbox,Checked%MenuDoubleRWinKey% x+152 vvMenuDoubleRWinKey,双击右Win键
	Gui,66:Add,Checkbox,Checked%MenuCtrlRightKey% xm yp+20 w160 vvMenuCtrlRightKey,按住Ctrl再按鼠标右键
	Gui,66:Add,Checkbox,Checked%MenuShiftRightKey% x+86 vvMenuShiftRightKey,按住Shift再按鼠标右键
	Gui,66:Add,Checkbox,Checked%MenuXButton1Key% xm yp+20 vvMenuXButton1Key,鼠标X1键
	Gui,66:Add,Checkbox,Checked%MenuXButton2Key% x+171 vvMenuXButton2Key,鼠标X2键
	Gui,66:Add,Checkbox,Checked%MenuMButtonKey% xm yp+20 vvMenuMButtonKey,鼠标中键（需要关闭插件huiZz_MButton.ahk）

	Gui,66:Tab,菜单变量,,Exact
	Gui,66:Add,Text,xm y+%MARGIN_TOP_66% w%GROUP_WIDTH_66%,自定义配置RunAny菜单中可以使用的变量
	Gui,66:Add,Button, xm yp+30 w50 GLVMenuVarAdd, + 增加
	Gui,66:Add,Button, x+10 yp w50 GLVMenuVarEdit, · 修改
	Gui,66:Add,Button, x+10 yp w50 GLVMenuVarRemove, - 减少
	Gui,66:Add,Link, x+15 yp-5,使用方法：变量两边加百分号如：<a href="https://hui-zz.gitee.io/runany/#/article/built-in-variables">`%变量名`%`n</a>编辑菜单项的启动路径中 或 RunAny.ini文件中使用
	Gui,66:Add,Listview,xm yp+40 r16 grid AltSubmit vRunAnyMenuVarLV glistviewMenuVar, 菜单变量名|类型|菜单变量值（动态变量不同电脑会自动变化）
	RunAnyMenuVarImageListID:=IL_Create(2)
	IL_Add(RunAnyMenuVarImageListID,AnyIconS[1],AnyIconS[2])
	IL_Add(RunAnyMenuVarImageListID,"shell32.dll",71)
	IL_Add(RunAnyMenuVarImageListID,"shell32.dll",25)
	GuiControl, 66:-Redraw, RunAnyMenuVarLV
	LV_SetImageList(RunAnyMenuVarImageListID)
	For mVarName, mVarVal in MenuVarIniList
	{
		mtypeIcon:=(MenuVarTypeList[mVarName]=1) ? "Icon1" : (MenuVarTypeList[mVarName]=2) ? "Icon3" : "Icon2"
		mtypeStr:=(MenuVarTypeList[mVarName]=1) ? "RunAny变量(动态)" : (MenuVarTypeList[mVarName]=2) ? "系统环境变量(动态)" : "用户变量(固定值)"
		LV_Add(mtypeIcon, mVarName, mtypeStr, mVarVal)
	}
	LV_ModifyCol()
	GuiControl, 66:+Redraw, RunAnyMenuVarLV
	
	Gui,66:Tab,搜索Everything,,Exact
	EvIsAdmin:=ev.GetIsAdmin()
	EvIsAdminStatus:=EvIsAdmin ? "管理员权限" : "非管理员"
	Gui,66:Add,Text,xm y+%MARGIN_TOP_66%,Everything当前权限：【%EvIsAdminStatus%】
	Gui,66:Add,Checkbox,Checked%EvAutoClose% x+20 yp vvEvAutoClose,Everything自动关闭(不常驻后台)
	Gui,66:Add,Button,x+10 w80 h20 gSetEvReindex,重建索引
	Gui,66:Add,GroupBox,xm-10 y+10 w%GROUP_WIDTH_66% h55,一键Everything [搜索选中文字，支持多选文件、再按为隐藏/激活] %EvHotKey%
	Gui,66:Add,Hotkey,xm+10 yp+20 w130 vvEvKey,%EvKey%
	Gui,66:Add,Checkbox,Checked%EvWinKey% xm+150 yp+3 vvEvWinKey,Win
	Gui,66:Add,Checkbox,Checked%EvShowExt% x+23 vvEvShowExt,搜索带文件后缀
	Gui,66:Add,Checkbox,Checked%EvShowFolder% x+5 vvEvShowFolder,搜索选中文件夹内部
	Gui,66:Add,GroupBox,xm-10 y+20 w%GROUP_WIDTH_66% h80,Everything安装路径（支持菜单变量和相对路径 \..\代表上一级目录）
	Gui,66:Add,Button,xm yp+30 w50 GSetEvPath,选择
	Gui,66:Add,Edit,xm+60 yp w%GROUP_CHOOSE_EDIT_WIDTH_66% r2 -WantReturn vvEvPath,%EvPath%
	Gui,66:Add,GroupBox,xm-10 y+20 vvEvCommandGroup,RunAny调用Everything搜索参数（搜索结果可在RunAny无路径运行，Everything异常请尝试重建索引）
	Gui,66:Add,Checkbox,Checked%EvDemandSearch% xm yp+25 vvEvDemandSearch gSetEvDemandSearch,按需搜索模式（只搜索RunAny菜单的无路径文件，非全磁盘搜索后再匹配）
	Gui,66:Add,Checkbox,Checked%EvExeVerNew% xm yp+20 vvEvExeVerNew gSetEvExeVerNew,搜索结果优先最新版本的同名exe
	Gui,66:Add,Checkbox,Checked%EvExeMTimeNew% x+10 vvEvExeMTimeNew gSetEvExeVerNew,搜索结果优先最新修改时间的同名文件
	Gui,66:Add,Button,xm yp+30 w50 GSetEvCommand,修改
	Gui,66:Add,Text,xm+60 yp,!C:\*Windows*为排除系统缓存和系统程序，注意空格间隔
	Gui,66:Add,Text,xm+60 yp+15,file:*.exe|*.lnk|后面类推增加想要的后缀
	Gui,66:Font,,Consolas
	Gui,66:Add,Edit,ReadOnly xm yp+25 r7 -WantReturn vvEvCommand,%EvCommand%
	Gui,66:Font,,Microsoft YaHei
	
	Gui,66:Tab,一键直达,,Exact
	Gui,66:Add,GroupBox,xm-10 y+%MARGIN_TOP_66% w%GROUP_WIDTH_66% h50,一键直达（仅菜单1热键触发，不想触发的菜单项放入菜单2中）
	Gui,66:Add,Text,xm yp+25 w120,选中后直接一键打开：
	Gui,66:Add,Checkbox,Checked%OneKeyWeb% x+20 yp vvOneKeyWeb,网址
	Gui,66:Add,Checkbox,Checked%OneKeyFile% x+10 yp vvOneKeyFile,文件路径
	Gui,66:Add,Checkbox,Checked%OneKeyFolder% x+10 yp vvOneKeyFolder,文件夹路径
	Gui,66:Add,Checkbox,Checked%OneKeyMagnet% x+10 yp vvOneKeyMagnet,磁力链接
	Gui,66:Add,Checkbox,Checked%OneKeyRegedit% x+10 yp vvOneKeyRegedit,注册表路径
	Gui,66:Add,GroupBox,xm-10 y+20 h310 vvOneKeyUrlGroup,一键搜索选中文字 %OneHotKey%
	Gui,66:Add,Hotkey,xm yp+30 w150 vvOneKey,%OneKey%
	Gui,66:Add,Checkbox,Checked%OneWinKey% xm+155 yp+3 vvOneWinKey,Win
	Gui,66:Add,Checkbox,Checked%OneKeyMenu% x+38 vvOneKeyMenu,绑定菜单1热键为一键搜索
	Gui,66:Add,Text,xm yp+40 w325,一键搜索网址(`%s为选中文字的替代参数，多行搜索多个网址)
	Gui,66:Add,Edit,xm yp+20 r12 vvOneKeyUrl,%OneKeyUrl%
	Gui,66:Add,Text,xm y+20 w325,非默认浏览器打开网址(适用一键搜索和一键网址直达)
	Gui,66:Add,Button,xm yp+20 w50 GSetBrowserPath,选择
	Gui,66:Add,Edit,xm+60 yp r3 -WantReturn vvBrowserPath,%BrowserPath%
	
	Gui,66:Tab,内部关联,,Exact
	Gui,66:Add,Text,xm y+%MARGIN_TOP_66% w%GROUP_WIDTH_66%,内部关联软件打开%RunAnyZz%菜单内不同后缀的文件（仅菜单内部不作用资源管理器）
	Gui,66:Add,Button, xm yp+30 w50 GLVOpenExtAdd, + 增加
	Gui,66:Add,Button, x+10 yp w50 GLVOpenExtEdit, · 修改
	Gui,66:Add,Button, x+10 yp w50 GLVOpenExtRemove, - 减少
	Gui,66:Add,Text, x+10 yp-5 w360,特殊类型：网址http https www ftp等`n文件夹folder（原来使用TC、DO第三方软件打开文件夹的功能）
	Gui,66:Add,Listview,xm yp+40 r16 grid AltSubmit -Multi vRunAnyOpenExtLV glistviewOpenExt, RunAny菜单内文件后缀(用空格分隔)|打开方式(支持无路径)
	kvLenMax:=0
	GuiControl, 66:-Redraw, RunAnyOpenExtLV
	For mOpenExtName, mOpenExtRun in openExtIniList
	{
		LV_Add("", mOpenExtRun, mOpenExtName)
		if(StrLen(mOpenExtRun)>kvLenMax)
			kvLenMax:=StrLen(mOpenExtRun)
	}
	LV_ModifyCol()
	if(kvLenMax<22)
		LV_ModifyCol(1,"AutoHdr")  ;列宽调整为标题对齐
	GuiControl, 66:+Redraw, RunAnyOpenExtLV
	
	Gui,66:Tab,热字符串,,Exact
	Gui,66:Add,GroupBox,xm-10 y+%MARGIN_TOP_66% w%GROUP_WIDTH_66% h460,热字符串设置
	Gui,66:Add,Checkbox,Checked%HideHotStr% xm yp+40 vvHideHotStr,隐藏热字符串提示
	Gui,66:Add,Text,xm yp+40 w250,按几个字符出现提示 (默认3个字符)
	Gui,66:Add,Edit,xm+200 yp-3 w200 r1 vvHotStrHintLen,%HotStrHintLen%
	Gui,66:Add,Text,xm yp+50 w250,提示启动路径最长字数 (0为隐藏)
	Gui,66:Add,Edit,xm+200 yp-3 w200 r1 vvHotStrShowLen,%HotStrShowLen%
	Gui,66:Add,Text,xm yp+50 w250,提示显示时长 (毫秒)
	Gui,66:Add,Edit,xm+200 yp-3 w200 r1 vvHotStrShowTime,%HotStrShowTime%
	Gui,66:Add,Text,xm yp+50 w250,提示显示透明度百分比 (`%)
	Gui,66:Add,Slider,xm+200 yp ToolTip w200 r1 vvHotStrShowTransparent,%HotStrShowTransparent%
	Gui,66:Add,Text,xm yp+50 w250,提示相对于鼠标坐标 X (可为负数)：
	Gui,66:Add,Edit,xm+200 yp-3 w200 r1 vvHotStrShowX,%HotStrShowX%
	Gui,66:Add,Text,xm yp+50 w250,提示相对于鼠标坐标 Y (可为负数)：
	Gui,66:Add,Edit,xm+200 yp-3 w200 r1 vvHotStrShowY,%HotStrShowY%
	if(encryptFlag){
		Gui,66:Add,Text,xm yp+50 w250 GMenu_Config,短语key（huiZz_Text）：
		Gui,66:Add,Edit,xm+200 yp-3 Password w200 cWhite r1 vvSendStrEcKey,%SendStrEcKey%
	}
	Gui,66:Add,Text,xm yp+50 cBlue,提示文字自动消失后，而且后续输入字符不触发热字符串功能`n需要按Tab/回车/句点/空格等键之后才会再次进行提示
	
	Gui,66:Tab,图标设置,,Exact
	Gui,66:Add,Checkbox,Checked%HideMenuTrayIcon% xm-5 y+%MARGIN_TOP_66% vvHideMenuTrayIcon gSetHideMenuTrayIcon,隐藏任务栏托盘图标
	Gui,66:Add,Text,x+10 yp,RunAny菜单图标大小(像素)
	Gui,66:Add,Edit,x+3 yp w30 h20 vvMenuIconSize,%MenuIconSize%
	Gui,66:Add,Text,x+15 yp,任务栏托盘右键图标大小(像素)
	Gui,66:Add,Edit,x+3 yp w30 h20 vvMenuTrayIconSize,%MenuTrayIconSize%
	Gui,66:Add,GroupBox,xm-10 yp+30 w%GROUP_WIDTH_66% h275,图标自定义设置（图片或图标文件路径 , 序号不填默认1）
	Gui,66:Add,Button,xm yp+20 w80 GSetAnyIcon,RunAny图标
	Gui,66:Add,Edit,xm+85 yp+1 w%GROUP_ICON_EDIT_WIDTH_66% r1 vvAnyIcon,%AnyIcon%
	Gui,66:Add,Button,xm yp+35 w80 GSetMenuIcon,准备图标
	Gui,66:Add,Edit,xm+85 yp+1 w%GROUP_ICON_EDIT_WIDTH_66% r1 vvMenuIcon,%MenuIcon%
	Gui,66:Add,Button,xm yp+35 w80 GSetTreeIcon,分类图标
	Gui,66:Add,Edit,xm+85 yp+1 w%GROUP_ICON_EDIT_WIDTH_66% r1 vvTreeIcon,%TreeIcon%
	Gui,66:Add,Button,xm yp+35 w80 GSetFolderIcon,文件夹图标
	Gui,66:Add,Edit,xm+85 yp+1 w%GROUP_ICON_EDIT_WIDTH_66% r1 vvFolderIcon,%FolderIcon%
	Gui,66:Add,Button,xm yp+35 w80 GSetUrlIcon,网址图标
	Gui,66:Add,Edit,xm+85 yp+1 w%GROUP_ICON_EDIT_WIDTH_66% r1 vvUrlIcon,%UrlIcon%
	Gui,66:Add,Button,xm yp+35 w80 GSetEXEIcon,EXE图标
	Gui,66:Add,Edit,xm+85 yp+1 w%GROUP_ICON_EDIT_WIDTH_66% r1 vvEXEIcon,%EXEIcon%
	Gui,66:Add,Button,xm yp+35 w80 GSetFuncIcon,脚本插件函数
	Gui,66:Add,Edit,xm+85 yp+1 w%GROUP_ICON_EDIT_WIDTH_66% r1 vvFuncIcon,%FuncIcon%
	Gui,66:Add,GroupBox,xm-10 y+25 w%GROUP_WIDTH_66% h165,%RunAnyZz%图标识别库（支持多行, 要求图标名与菜单项名相同, 不包含热字符串和全局热键）
	Gui,66:Add,Text, xm yp+20 w380,如图标文件名可以为：-常用(&&App).ico、cmd.png、百度(&&B).ico
	if(ResourcesExtractExist)
		Gui,66:Add,Button,x+5 yp w110 GMenu_Exe_Icon_Create,生成所有EXE图标
	Gui,66:Add,Button,xm yp+30 w50 GSetIconFolderPath,选择
	Gui,66:Add,Edit,xm+60 yp w%GROUP_CHOOSE_EDIT_WIDTH_66% r6 vvIconFolderPath,%IconFolderPath%

	Gui,66:Tab,高级配置,,Exact
	Gui,66:Add,Link,xm y+%MARGIN_TOP_66% w%GROUP_WIDTH_66%,%RunAnyZz%高级配置列表，请理解说明后修改（双击或按F2进行修改：1或有值=启用，0或空=停用）
	Gui,66:Add,Listview,xm yp+20 r18 grid AltSubmit -ReadOnly -Multi vAdvancedConfigLV glistviewAdvancedConfig, 配置状态值|单位|配置说明|配置脚本|配置项名
	AdvancedConfigImageListID:=IL_Create(2)
	IL_Add(AdvancedConfigImageListID,"shell32.dll",(A_OSVersion="WIN_XP" || A_OSVersion="WIN_7") ? 145 : 297)
	IL_Add(AdvancedConfigImageListID,"shell32.dll",132)
	GuiControl, 66:-Redraw, AdvancedConfigLV
	LV_SetImageList(AdvancedConfigImageListID)
	LV_Add(JumpSearch ? "Icon1" : "Icon2", JumpSearch,, "跳过点击批量搜索时的确认弹窗","","JumpSearch")
	LV_Add(ShowGetZzLen ? "Icon1" : "Icon2", ShowGetZzLen,"字", "[选中] 菜单第一行显示选中文字最大截取字数","","ShowGetZzLen")
	LV_Add(ClipWaitApp ? "Icon1" : "Icon2", ClipWaitApp,, "[选中] 指定软件解决剪贴板等待时间过短获取不到选中内容（多个用,分隔）","","ClipWaitApp")
	LV_Add(ClipWaitApp ? "Icon1" : "Icon2", ClipWaitTime,"秒", "[选中] 指定软件获取选中目标到剪贴板等待时间，全局其他软件默认0.1秒","","ClipWaitTime")
	if(translateFlag){
		LV_Add(GetZzTranslate ? "Icon1" : "Icon2", GetZzTranslate,"", "[选中翻译] 菜单第二行谷歌翻译选中内容","huiZz_Text.ahk","GetZzTranslate")
		LV_Add(GetZzTranslate ? "Icon1" : "Icon2", GetZzTranslateMenu,"菜单", "[选中翻译] 1：仅菜单1显示翻译；2：仅菜单2显示翻译；0：所有菜单均显示","huiZz_Text.ahk","GetZzTranslateMenu")
		LV_Add(GetZzTranslate ? "Icon1" : "Icon2", GetZzTranslateSource,"", "[选中翻译] 翻译源语言，默认auto","huiZz_Text.ahk","GetZzTranslateSource")
		LV_Add(GetZzTranslate ? "Icon1" : "Icon2", GetZzTranslateTarget,"", "[选中翻译] 翻译目标语言，英文：en，中文：zh-CN，具体语言查看谷歌翻译网址","huiZz_Text.ahk","GetZzTranslateTarget")
		LV_Add(GetZzTranslate ? "Icon1" : "Icon2", GetZzTranslateAuto,"", "[选中翻译] 翻译目标语言自动判断切换中英文","huiZz_Text.ahk","GetZzTranslateAuto")
	}
	LV_Add(HoldCtrlRun ? "Icon1" : "Icon2", HoldCtrlRun,"", "[按住Ctrl键] 回车或点击菜单项（选项数字可互用） 2:打开该软件所在目录","","HoldCtrlRun")
	LV_Add(HoldShiftRun ? "Icon1" : "Icon2", HoldShiftRun,"", "[按住Shift键] 回车或点击菜单项（选项数字可互用） 5:打开多功能菜单运行方式","","HoldShiftRun")
	LV_Add(HoldCtrlShiftRun ? "Icon1" : "Icon2", HoldCtrlShiftRun,"", "[按住Ctrl+Shift键] 回车或点击菜单项（选项数字可互用） 3:编辑该菜单项","","HoldCtrlShiftRun")
	LV_Add(HoldCtrlWinRun ? "Icon1" : "Icon2", HoldCtrlWinRun,"", "[按住Ctrl+Win键] 回车或点击菜单项（选项数字可互用） 11:以管理员权限运行 12:最小化运行 13:最大化运行 14:隐藏运行(部分有效)","","HoldCtrlWinRun")
	LV_Add(HoldShiftWinRun ? "Icon1" : "Icon2", HoldShiftWinRun,"", "[按住Shift+Win键] 回车或点击菜单项（选项数字可互用） 31:复制运行路径 32:输出运行路径 33:复制软件名 34:输出软件名 35:复制软件名+后缀 36:输出软件名+后缀","","HoldShiftWinRun")
	LV_Add(HoldCtrlShiftWinRun ? "Icon1" : "Icon2", HoldCtrlShiftWinRun,"", "[按住Ctrl+Shift+Win键] 回车或点击菜单项（选项数字可互用） 4:强制结束该软件单个进程","","HoldCtrlShiftWinRun")
	if(RunAnyMenuSpaceFlag)
		LV_Add(RunAnyMenuSpaceRun ? "Icon1" : "Icon2", RunAnyMenuSpaceRun,"", "[按空格键] 运行菜单项（只能复制上面已设置的选项数字）","RunAny_Menu.ahk","RunAnyMenuSpaceRun")
	if(RunAnyMenuRButtonFlag)
		LV_Add(RunAnyMenuRButtonRun ? "Icon1" : "Icon2", RunAnyMenuRButtonRun,"", "[按右键] 运行菜单项（只能复制上面已设置的选项数字）","RunAny_Menu.ahk","RunAnyMenuRButtonRun")
	if(RunAnyMenuMButtonFlag)
		LV_Add(RunAnyMenuMButtonRun ? "Icon1" : "Icon2", RunAnyMenuMButtonRun,"", "[按中键] 运行菜单项（只能复制上面已设置的选项数字）","RunAny_Menu.ahk","RunAnyMenuMButtonRun")
	if(RunAnyMenuXButton1Flag)
		LV_Add(RunAnyMenuXButton1Run ? "Icon1" : "Icon2", RunAnyMenuXButton1Run,"", "[按XButton1键] 运行菜单项（只能复制上面已设置的选项数字）","RunAny_Menu.ahk","RunAnyMenuXButton1Run")
	if(RunAnyMenuXButton2Flag)
		LV_Add(RunAnyMenuXButton2Run ? "Icon1" : "Icon2", RunAnyMenuXButton2Run,"", "[按XButton2键] 运行菜单项（只能复制上面已设置的选项数字）","RunAny_Menu.ahk","RunAnyMenuXButton2Run")
	LV_Add(HoldKeyShowTime ? "Icon1" : "Icon2", HoldKeyShowTime,"毫秒", "按键运行菜单项复制运行路径、软件名等提示信息的显示时间","RunAny_Menu.ahk","HoldKeyShowTime")
	if(RunAnyMenuTransparentFlag)
		LV_Add(RunAnyMenuTransparent ? "Icon1" : "Icon2", RunAnyMenuTransparent,"", "RunAny菜单和右键菜单透明度数值（0全透明-255不透明）","RunAny_Menu.ahk","RunAnyMenuTransparent")
	LV_Add(RUNANY_SELF_MENU_ITEM1 ? "Icon1" : "Icon2", RUNANY_SELF_MENU_ITEM1,, "RunAny自身功能的菜单项名称修改1：&1批量搜索","","RUNANY_SELF_MENU_ITEM1")
	LV_Add(RUNANY_SELF_MENU_ITEM2 ? "Icon1" : "Icon2", RUNANY_SELF_MENU_ITEM2,, "RunAny自身功能的菜单项名称修改2：RunAny设置","","RUNANY_SELF_MENU_ITEM2")
	LV_Add(RUNANY_SELF_MENU_ITEM3 ? "Icon1" : "Icon2", RUNANY_SELF_MENU_ITEM3,, "RunAny自身功能的菜单项名称修改3：0【添加到此菜单】","","RUNANY_SELF_MENU_ITEM3")
	LV_Add(RUNANY_SELF_MENU_ITEM4 ? "Icon1" : "Icon2", RUNANY_SELF_MENU_ITEM4,, "RunAny自身功能的菜单项名称修改4：-【显示菜单全部】","","RUNANY_SELF_MENU_ITEM4")
	LV_Add(DebugMode ? "Icon1" : "Icon2", DebugMode,, "[调试模式] 实时显示菜单运行的信息","","DebugMode")
	LV_Add(DebugMode ? "Icon1" : "Icon2", DebugModeShowTime,"毫秒", "[调试模式] 实时显示菜单运行信息的自动隐藏时间","","DebugModeShowTime")
	LV_Add(DebugMode ? "Icon1" : "Icon2", DebugModeShowTrans,"%", "[调试模式] 实时显示菜单运行信息的透明度","","DebugModeShowTrans")
	LV_Add(DisableExeIcon ? "Icon1" : "Icon2", DisableExeIcon,, "菜单中exe程序不加载本身图标","","DisableExeIcon")
	LV_Add(RunAEncoding ? "Icon1" : "Icon2", RunAEncoding,, "使用指定编码读取RunAny.ini（默认ANSI）","","RunAEncoding")
	LV_Add(AutoGetZz ? "Icon1" : "Icon2", AutoGetZz,, "【慎改】菜单程序运行自动带上当前选中文件，关闭后需要手动加%getZz%才可以获取到","","AutoGetZz")
	LV_Add(EvNo ? "Icon1" : "Icon2", EvNo,, "【慎改】不使用Everything模式，所有无路径配置都会失效！","","EvNo")
	LV_ModifyCol(2,"Auto Center")
	LV_ModifyCol(3,"Auto")
	LV_ModifyCol(4,"Auto")
	LV_ModifyCol(5,"Auto")
	GuiControl, 66:+Redraw, AdvancedConfigLV

	Gui,66:Tab
	Gui,66:Add,Button,Default w75 vvSetOK GSetOK,确定
	Gui,66:Add,Button,w75 vvSetCancel GSetCancel,取消
	Gui,66:Add,Button,w75 vvSetReSet GSetReSet,重置
	Gui,66:Add,Text,w75 vvMenu_Config GMenu_Config,RunAnyConfig.ini
	Gui,66:Show,w%GUI_WIDTH_66%,%RunAnyZz%设置 %RunAny_update_version% %RunAny_update_time%%AdminMode%
	k:=v:=mVarName:=mVarVal:=mOpenExtName:=mOpenExtRun:=""
	SetValueList:=["AdminRun"]
	;[手写AHK热键情况下不根据Hotkey热键控件保存，避免清空手写热键值]
	Gui,66:Submit, NoHide
	For ki, kv in RunHotKeyList
	{
		keyV:=StrReplace(kv,"Hot")
		winkeyV:=StrReplace(kv,"Hot","Win")
		if(v%keyV%="" && %kv%!=""){
			GuiControl,Disable,v%keyV%
			GuiControl,Disable,v%winkeyV%
		}else{
			SetValueList.Push(keyV)
			SetValueList.Push(winkeyV)
		}
	}
	return
;~;【关于Gui】
Menu_About:
	Gui,99:Destroy
	Gui,99:Color,FFFFFF
	Gui,99:Add, ActiveX, x0 y0 w570 h470 voWB, shell explorer
	oWB.Navigate("about:blank")
vHtml = 
(
<html>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title>name</title>
<body style="font-family:Microsoft YaHei;margin:30px;background:url(https://hui-zz.gitee.io/runany/assets/images/RunAnyMp_120x120.png) no-repeat center top;">
<br><br><br>
<h2>
【%RunAnyZz%】一劳永逸的快速启动工具 v%RunAny_update_version% @%RunAny_update_time% 
<img alt="GitHub stars" src="https://img.shields.io/github/stars/hui-Zz/RunAny.svg?style=social"/> 
<br>
<font size="2">官网版本：</font>
<img alt="GitHub release" src="https://img.shields.io/github/release/hui-Zz/RunAny.svg?style=flat-square&logo=github"/>
</h2>
默认启动菜单热键为 <b><font color="red"><kbd>``</kbd></font></b>（Esc键下方的重音符键~`` ）
<br>
（注意：想打字打出<kbd>``</kbd>的时候，按<kbd>Win</kbd>+<kbd>``</kbd>）
<br><br>
<li>按住<kbd>Shift</kbd>+回车键 或+鼠标左键打开 <b>多功能菜单运行方式</b></li>
<li>按住<kbd>Ctrl</kbd>+回车键 或+鼠标左键打开 软件所在的目录</li>
<li>按住<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+回车键 或+鼠标左键打开 快速跳转到编辑该菜单项</li>
<li>按住<kbd>Ctrl</kbd>+<kbd>Win</kbd>+鼠标左键打开 以管理员身份来运行</li>
<br>【右键任务栏RunAny图标进行配置】<br><br>
作者：hui-Zz 建议：hui0.0713@gmail.com
</body>
</html>
)
	oWB.document.write(vHtml)
	oWB.Refresh()
	Gui,99:Font,s11 Bold,Microsoft YaHei
	Gui,99:Add,Link,xm+18 y+10,国内Gitee文档：<a href="https://hui-zz.gitee.io/RunAny">https://hui-zz.gitee.io/RunAny</a>
	Gui,99:Add,Link,xm+18 y+10,Github文档：<a href="https://hui-zz.github.io/RunAny">https://hui-zz.github.io/RunAny</a>
	Gui,99:Add,Link,xm+18 y+10,Github地址：<a href="https://github.com/hui-Zz/RunAny">https://github.com/hui-Zz/RunAny</a>
	Gui,99:Add,Text,y+10, 讨论QQ群：
	Gui,99:Add,Link,x+8 yp,<a href="https://jq.qq.com/?_wv=1027&k=445Ug7u">246308937【RunAny快速启动一劳永逸】</a>`n`n
	Gui,99:Font
	Gui,99:Show,AutoSize Center,关于%RunAnyZz%%AdminMode%
	hCurs:=DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt") ;IDC_HAND
	OnMessage(0x200,"WM_MOUSEMOVE")
return
SetEvPath:
	FileSelectFile, evFilePath, 3, Everything.exe, Everything安装路径, (Everything.exe)
	if(evFilePath)
		GuiControl,, vEvPath, %evFilePath%
return
SetIconFolderPath:
	Gui,66:Submit, NoHide
	FileSelectFolder, iconFolderName, , 0
	if(iconFolderName){
		if(vIconFolderPath){
			GuiControl,, vIconFolderPath, %vIconFolderPath%`n%iconFolderName%
		}else{
			GuiControl,, vIconFolderPath, %iconFolderName%
		}
	}
return
SetRunABackupDir:
	Gui,66:Submit, NoHide
	FileSelectFolder, RunABackupDir, , 0
	if(RunABackupDir){
		GuiControl,, vRunABackupDir, %RunABackupDir%
	}
return
SetBrowserPath:
	FileSelectFile, browserFilePath, 3, , 程序路径, (*.exe)
	if(browserFilePath)
		GuiControl,, vBrowserPath, %browserFilePath%
return
SetOpenExtRun:
	FileSelectFile, openExtPath, , , 启动文件路径
	if(openExtPath){
		GuiControl,, vopenExtRun, %openExtPath%
	}
return
SetAnyIcon:
SetMenuIcon:
SetTreeIcon:
SetFolderIcon:
SetUrlIcon:
SetEXEIcon:
SetFuncIcon:
	setEdit:=StrReplace(A_ThisLabel, "Set", "v")
	FileSelectFile, filePath, 3, , 图标图片路径
	if(filePath)
		GuiControl,, %setEdit%, %filePath%
return
SetEvCommand:
	MsgBox,64,Everything搜索参数语法,请打开Everything参照`nEverything-帮助(H)-搜索语法`n`n
		(
修改以下文本框参数后，请务必复制参数到Everthing搜索
检验是否有搜索到RunAny菜单中的程序，避免出现错误
		)
	GuiControl,-ReadOnly,vEvCommand
return
SetOK:
	Gui,Submit
	vConfigDate:=A_MM A_DD
	if(vAutoRun!=AutoRun){
		AutoRun:=vAutoRun
		if(AutoRun){
			RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, RunAny, %A_ScriptDir%\%Z_ScriptName%
		}else{
			RegDelete, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, RunAny
		}
	}
	if(vSendStrEcKey!=SendStrEcKey){
		vSendStrEcKey:=SendStrEncrypt(vSendStrEcKey,RunAnyZz vConfigDate)
	}else{
		vSendStrEcKey:=SendStrEncrypt(SendStrDcKey,RunAnyZz vConfigDate)
	}
	SetValueList.Push("ConfigDate","AutoReloadMTime","RunABackupRule","RunABackupMax","RunABackupFormat","RunABackupDir","DisableApp")
	SetValueList.Push("EvPath","EvCommand","EvAutoClose","EvShowExt","EvShowFolder","EvExeVerNew","EvExeMTimeNew","EvDemandSearch")
	SetValueList.Push("HideFail","HideWeb","HideGetZz","HideSend","HideAddItem","HideMenuTray","HideSelectZz","RecentMax")
	SetValueList.Push("OneKeyUrl","OneKeyWeb","OneKeyFolder","OneKeyMagnet","OneKeyRegedit","OneKeyFile","OneKeyMenu","BrowserPath","IconFolderPath")
	SetValueList.Push("HideMenuTrayIcon","MenuIconSize","MenuTrayIconSize","MenuIcon","AnyIcon","TreeIcon","FolderIcon","UrlIcon","EXEIcon","FuncIcon")
	SetValueList.Push("HideHotStr","HotStrHintLen","HotStrShowLen","HotStrShowTime","HotStrShowTransparent","HotStrShowX","HotStrShowY","SendStrEcKey")
	SetValueList.Push("MenuDoubleCtrlKey", "MenuDoubleAltKey", "MenuDoubleLWinKey", "MenuDoubleRWinKey")
	SetValueList.Push("MenuCtrlRightKey", "MenuShiftRightKey", "MenuXButton1Key", "MenuXButton2Key", "MenuMButtonKey")
	;[回车转换成竖杠保存到ini配置文件]
	OneKeyUrl:=RegExReplace(OneKeyUrl,"S)[\n]+","|")
	vOneKeyUrl:=RegExReplace(vOneKeyUrl,"S)[\n]+","|")
	IconFolderPath:=RegExReplace(IconFolderPath,"S)[\n]+","|")
	vIconFolderPath:=RegExReplace(vIconFolderPath,"S)[\n]+","|")
	For vi, vv in SetValueList
	{
		vValue:="v" . vv
		Reg_Set(%vValue%,%vv%,vv)
	}
	;[保存热键配置列表]
	if(HotKeyFlag){
		Gui, ListView, RunAnyHotkeyLV
		Loop % LV_GetCount()
		{
			LV_GetText(RunAHotKey, A_Index, 1)
			LV_GetText(RunAHotKeyVal, A_Index, 3)
			keyV:=StrReplace(RunAHotKeyVal,"Hot")
			winkeyV:=StrReplace(RunAHotKeyVal,"Hot","Win")
			v_keyV:=StrReplace(RunAHotKey,"#")
			v_winkeyV:=InStr(RunAHotKey,"#")
			IniWrite,%v_keyV%,%RunAnyConfig%,Config,%keyV%
			IniWrite,%v_winkeyV%,%RunAnyConfig%,Config,%winkeyV%
		}
	}
	;[保存内部关联打开后缀列表]
	if(OpenExtFlag){
		Gui, ListView, RunAnyOpenExtLV
		IniWrite, delete=1, %RunAnyConfig%, OpenExt
		IniDelete, %RunAnyConfig%, OpenExt, delete
		Loop % LV_GetCount()
		{
			LV_GetText(openExtName, A_Index, 1)
			LV_GetText(openExtRun, A_Index, 2)
			IniWrite,%openExtName%,%RunAnyConfig%,OpenExt,%openExtRun%
		}
	}
	;[保存自定义菜单变量]
	if(MenuVarFlag){
		Gui, ListView, RunAnyMenuVarLV
		IniWrite, delete=1, %RunAnyConfig%, MenuVar
		IniDelete, %RunAnyConfig%, MenuVar, delete
		Loop % LV_GetCount()
		{
			LV_GetText(menuVarName, A_Index, 1)
			LV_GetText(menuVarVal, A_Index, 3)
			IniWrite,%menuVarVal%,%RunAnyConfig%,MenuVar,%menuVarName%
		}
	}
	;[保存高级配置]
	if(AdvancedConfigFlag){
		Gui, ListView, AdvancedConfigLV
		Loop % LV_GetCount()
		{
			LV_GetText(AdvancedConfigVal, A_Index, 1)
			LV_GetText(AdvancedConfigName, A_Index, 5)
			Reg_Set(AdvancedConfigVal,%AdvancedConfigName%,AdvancedConfigName)
		}
	}
	gosub,Menu_Reload
return
SetHideSelectZz:
	GuiControlGet, outPutVar, , vHideSelectZz
	GuiControl,, vHideSelectZz2, %outPutVar%
return
SetScheduledTasks:
	cmdClipReturn("""schtasks /create /tn """ RunAnyZz "启动"" /tr " A_AhkPath " /sc onlogon /rl HIGHEST""")
	Run,taskschd.msc
	if(rule_chassis_types()>=8){
		Sleep,1000
		MsgBox, 64, 任务计划%RunAnyZz%创建完成, 在每次系统登录时会以管理员权限启动%RunAnyZz%`n`n
		(
【注意】`n当前电脑是笔记本，如果需要笔记本使用电池开机也会自动启动%RunAnyZz%
`n请找到任务计划程序库-%RunAnyZz%启动-右键属性-“条件”里面-
取消勾选“只有在计算机使用交流电源时才启动此任务”
		)
	}
	GuiControl,,vAutoRun,0
return
SetClearRecentMax:
	RegDelete, HKEY_CURRENT_USER, SOFTWARE\RunAny, MenuCommonList
return
SetEvReindex:
	Gui,66:Submit, NoHide
	Run,% Get_Transform_Val(vEvPath) " -reindex"
return
SetReSet:
	MsgBox,49,重置RunAny配置,此操作会删除RunAny所有注册表配置，以及删除本地配置文件%RunAnyConfig%，确认删除重置吗？
	IfMsgBox Ok
	{
		RegDelete, HKEY_CURRENT_USER, SOFTWARE\RunAny
		RegDelete, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, RunAny
		FileDelete, %RunAnyConfig%
		gosub,Menu_Reload
	}
return
SetEvExeVerNew:
	Gui,66:Submit, NoHide
	if(vEvExeVerNew){
		MsgBox,64,Everything搜索结果优先最新版本或修改时间的同名exe全路径, %RunAnyZz%会比较电脑上所有同名exe的版本号、修改时间`n
		(
如果电脑同名程序过多会延长开机后%RunAnyZz%初始化速度`n
建议同时开启上边“按需搜索模式”（只搜索%RunAnyZz%菜单的无路径文件）
只比较%RunAnyZz%菜单中的同名程序版本号、修改时间，大大加快速度
		)
	}
return
SetEvDemandSearch:
	Gui,66:Submit, NoHide
	if(vEvDemandSearch){
		MsgBox,64,Everything按需搜索模式, 不再搜索电脑上所有exe、lnk等后缀文件全路径，`n
		(
（只搜索%RunAnyZz%菜单的无路径文件）加快加载速度`n
如果想在%RunAnyZz%菜单中的任意后缀文件都可以无路径运行
按需模式可以去掉file搜索参数，全量搜索在后面按格式添加其他后缀  file:*.exe|*.lnk|*.ahk|*.bat|*.cmd`n
【注意】开启后会影响RunAny所有设置和插件脚本的无路径识别，
不在RunAny.ini菜单内的程序无法自动识别全路径
		)
	}
return
SetMenu2:
	MsgBox,33,开启第2个菜单,确定开启第2个菜单吗？`n会在目录生成RunAny2.ini`n【注意！】`n还原可以删除或重命名RunAny2.ini
	IfMsgBox Ok
	{
		text2=;这里添加第2菜单内容`n-菜单2分类
		FileAppend,%text2%,%iniPath2%
		gosub,Menu_Edit2
	}
return
SetMenuWinKey:
	GuiControlGet, outPutVar, , vMenuWinKey
	If(outPutVar)
		MsgBox, 48, 提示：, 使用Win+字母热键可能无法取得QQ聊天窗口中文字，`n因为QQ聊天窗口是绘制的特殊窗体
return
SetMenuWinKey2:
	GuiControlGet, outPutVar, , vMenuWinKey2
	If(outPutVar)
		MsgBox, 48, 提示：, 使用Win+字母热键可能无法取得QQ聊天窗口中文字，`n因为QQ聊天窗口是绘制的特殊窗体
return
SetHideMenuTrayIcon:
	Gui,66:Submit, NoHide
	If(vHideMenuTray && vHideMenuTrayIcon){
		MsgBox, 48, 警告！, 已经隐藏菜单中的“RunAny设置”，如果再隐藏任务栏托盘图标后`n
		(
只能通过快捷键来再次打开RunAny设置界面，如果忘记热键的话`n`n需要手动修改 RunAnyConfig.ini 文件取消隐藏图标： HideMenuTrayIcon=0
		)
	}
return
;-------------------------------------RunAny热键配置界面-------------------------------------
RunA_Hotkey_Edit:
	Gui, ListView, RunAnyHotkeyLV
	RunRowNumber := LV_GetNext(0, "F")
	if not RunRowNumber
		return
	LV_GetText(RunAHotKey, RunRowNumber, 1)
	LV_GetText(RunAHotKeyText, RunRowNumber, 2)
	LV_GetText(RunAHotKeyVal, RunRowNumber, 3)
	keyV:=StrReplace(RunAHotKeyVal,"Hot")
	winkeyV:=StrReplace(RunAHotKeyVal,"Hot","Win")
	v_keyV:=StrReplace(RunAHotKey,"#")
	v_winkeyV:=InStr(RunAHotKey,"#")
	Gui,key:Destroy
	Gui,key:Default
	Gui,key:+Owner66
	Gui,key:Margin,20,20
	Gui,key:Font,,Microsoft YaHei
	Gui,key:Add,GroupBox,xm-10 y+20 w225 h55,%RunAHotKeyText%：%RunAHotKey%
	Gui,key:Add,Hotkey,xm yp+20 w150 vvkeyV,%v_keyV%
	Gui,key:Add,Checkbox,Checked%v_winkeyV% xm+155 yp+3 vvwinkeyV,Win
	Gui,key:Font
	Gui,key:Add,Button,Default xm+20 y+25 w75 GSaveRunAHotkey,保存
	Gui,key:Add,Button,x+20 w75 GSetCancel,取消
	Gui,key:Show,,配置热键 %RunAny_update_version% %RunAny_update_time%
return
listviewHotkey:
    if A_GuiEvent = DoubleClick
    {
		gosub,RunA_Hotkey_Edit
    }else if A_GuiEvent = e
	{
		HotKeyFlag:=true
	}else if  A_GuiEvent = R
	{
		Run,https://wyagd001.github.io/zh-cn/docs/KeyList.htm
	}
return
SaveRunAHotkey:
	HotKeyFlag:=true
	Gui,key:Submit, NoHide
	vKeyWinKeyV:=vwinkeyV ? "#" . vkeyV : vkeyV
	Gui,66:Default
	LV_Modify(RunRowNumber,"",vKeyWinKeyV)
	LV_ModifyCol()  ; 根据内容自动调整每列的大小.
	Gui,key:Destroy
return
;-------------------------------------内部关联打开后缀界面-------------------------------------
Open_Ext_Edit:
	Gui, ListView, RunAnyOpenExtLV
	if(openExtItem="编辑"){
		RunRowNumber := LV_GetNext(0, "F")
		if not RunRowNumber
			return
		LV_GetText(openExtName, RunRowNumber, 1)
		LV_GetText(openExtRun, RunRowNumber, 2)
	}
	Gui,SaveExt:Destroy
	Gui,SaveExt:Default
	Gui,SaveExt:+Owner66
	Gui,SaveExt:Margin,20,20
	Gui,SaveExt:Font,,Microsoft YaHei
	Gui,SaveExt:Add, GroupBox,xm y+10 w400 h145,%openExtItem%内部关联后缀打开方式
	Gui,SaveExt:Add, Text, xm+10 y+35 y35 w62, 文件后缀    (空格分隔)
	Gui,SaveExt:Add, Edit, x+5 yp+5 w300 vvopenExtName, %openExtName%
	Gui,SaveExt:Add, Button, xm+5 y+15 w60 GSetOpenExtRun,打开方式软件路径
	Gui,SaveExt:Add, Edit, x+12 yp w300 r3 -WantReturn vvopenExtRun, %openExtRun%
	Gui,SaveExt:Font
	Gui,SaveExt:Add,Button,Default xm+100 y+25 w75 GSaveOpenExt,保存(&Y)
	Gui,SaveExt:Add,Button,x+20 w75 GSetCancel,取消(&C)
	Gui,SaveExt:Show,,%RunAnyZz% - %openExtItem%内部关联后缀打开方式 %RunAny_update_version% %RunAny_update_time%
return
listviewOpenExt:
    if A_GuiEvent = DoubleClick
    {
		openExtItem:="编辑"
		gosub,Open_Ext_Edit
    }
return
LVOpenExtAdd:
	openExtItem:="新建"
	openExtName:=openExtRun:=""
	gosub,Open_Ext_Edit
return
LVOpenExtEdit:
	openExtItem:="编辑"
	gosub,Open_Ext_Edit
return
LVOpenExtRemove:
	Gui, ListView, RunAnyOpenExtLV
	OpenExtFlag:=true
	RunRowNumber := LV_GetNext(0, "F")
	if not RunRowNumber
		return
	LV_Delete(RunRowNumber)
return
SaveOpenExt:
	OpenExtFlag:=true
	Gui,SaveExt:Submit, NoHide
	if(!vopenExtName || !vopenExtRun){
		ToolTip, 请填入文件后缀名和打开方式软件路径,195,35
		SetTimer,RemoveToolTip,3000
		return
	}
	Gui,66:Default
	if(openExtItem="新建"){
		if(openExtIniList[vopenExtRun]){
			Loop % LV_GetCount()
			{
				LV_GetText(openExtNameGet, A_Index, 1)
				LV_GetText(openExtRunGet, A_Index, 2)
				if(vopenExtRun=openExtRunGet){
					LV_Modify(A_Index,"",openExtNameGet . A_Space . vopenExtName,vopenExtRun)
					ToolTip, 已自动合并后缀到相同打开方式中,195,-20
					SetTimer,RemoveToolTip,3000
					break
				}
			}
		}else{
			LV_Add("",vopenExtName,vopenExtRun)
		}
	}else{
		LV_Modify(RunRowNumber,"",vopenExtName,vopenExtRun)
	}
	LV_ModifyCol()  ; 根据内容自动调整每列的大小.
	Gui,SaveExt:Destroy
return
;--------------------------------------菜单变量设置界面--------------------------------------
Menu_Var_Edit:
	Gui, ListView, RunAnyMenuVarLV
	if(menuVarItem="编辑"){
		RunRowNumber := LV_GetNext(0, "F")
		if not RunRowNumber
			return
		LV_GetText(menuVarName, RunRowNumber, 1)
		LV_GetText(menuVarType, RunRowNumber, 2)
		LV_GetText(menuVarVal, RunRowNumber, 3)
	}
	Gui,SaveVar:Destroy
	Gui,SaveVar:Default
	Gui,SaveVar:+Owner66
	Gui,SaveVar:Margin,20,20
	Gui,SaveVar:Font,,Microsoft YaHei
	Gui,SaveVar:Add, GroupBox,xm y+10 w400 h145 vvmenuVarType,%menuVarType%
	Gui,SaveVar:Add, Text, xm+5 y+35 y35 w60,菜单变量名
	Gui,SaveVar:Add, Edit, x+5 yp w300 vvmenuVarName gSetMenuVarVal, %menuVarName%
	Gui,SaveVar:Add, Text, xm+5 y+15 w60,菜单变量值
	Gui,SaveVar:Add, Edit, x+5 yp w300 r3 -WantReturn vvmenuVarVal, %menuVarVal%
	Gui,SaveVar:Font
	Gui,SaveVar:Add,Button,Default xm+100 y+25 w75 GSaveMenuVar,保存(&S)
	Gui,SaveVar:Add,Button,x+20 w75 GSetCancel,取消(&C)
	Gui,SaveVar:Show,,%RunAnyZz% - %menuVarItem%菜单变量和变量值 %RunAny_update_version% %RunAny_update_time%
	if(menuVarType!="用户变量(固定值)")
		gosub,SetMenuVarVal
return
listviewMenuVar:
    if A_GuiEvent = DoubleClick
    {
		menuVarItem:="编辑"
		gosub,Menu_Var_Edit
    }
return
LVMenuVarAdd:
	menuVarItem:="新建"
	menuVarName:=menuVarVal:=""
	gosub,Menu_Var_Edit
return
LVMenuVarEdit:
	menuVarItem:="编辑"
	gosub,Menu_Var_Edit
return
LVMenuVarRemove:
	Gui, ListView, RunAnyMenuVarLV
	MenuVarFlag:=true
	RunRowNumber := LV_GetNext(0, "F")
	if not RunRowNumber
		return
	LV_Delete(RunRowNumber)
return
SetMenuVarVal:
	Gui,SaveVar:Submit, NoHide
	if(vmenuVarName="")
		return
	if(!RegExMatch(vmenuVarName,"S)^[\p{Han}A-Za-z0-9_]+$")){
		ToolTip, 变量名只能为中文、数字、字母、下划线,195,35
		SetTimer,RemoveToolTip,3000
		return
	}
	try EnvGet, sysMenuVarName, %vmenuVarName%
	if(sysMenuVarName){
		menuVarType:="系统环境变量(动态)"
		GuiControl,, vmenuVarVal, %sysMenuVarName%
		GuiControl,, vmenuVarType, %menuVarType%
		GuiControl,Disable, vmenuVarVal
	}else{
		if(%vmenuVarName%){
			menuVarType:="RunAny变量(动态)"
			GuiControl,, vmenuVarVal, % %vmenuVarName%
			GuiControl,, vmenuVarType, %menuVarType%
			GuiControl,Disable, vmenuVarVal
		}else{
			menuVarType:="用户变量(固定值)"
			GuiControl,, vmenuVarType, %menuVarType%
			GuiControl,Enable, vmenuVarVal
		}
	}
return
SaveMenuVar:
	MenuVarFlag:=true
	Gui,SaveVar:Submit, NoHide
	if(vmenuVarName=""){
		ToolTip, 请填入菜单变量名,195,35
		SetTimer,RemoveToolTip,3000
		return
	}
	if(!RegExMatch(vmenuVarName,"S)^[\p{Han}A-Za-z0-9_]+$")){
		ToolTip, 变量名只能为中文、数字、字母、下划线,195,35
		SetTimer,RemoveToolTip,3000
		return
	}
	Gui,66:Default
	if(menuVarItem="新建"){
		if(MenuVarIniList[vmenuVarName]){
			ToolTip, 已有相同菜单变量名！,195,35
			SetTimer,RemoveToolTip,3000
			return
		}
		LV_Add("",vmenuVarName,menuVarType,vmenuVarVal)
	}else{
		LV_Modify(RunRowNumber,"",vmenuVarName,menuVarType,vmenuVarVal)
	}
	LV_ModifyCol()  ; 根据内容自动调整每列的大小.
	Gui,SaveVar:Destroy
return
listviewAdvancedConfig:
	if A_GuiEvent = DoubleClick
	{
		SendInput,{F2}
	}else if A_GuiEvent = e
	{
		AdvancedConfigFlag:=true
	}
return
;[窗口控件控制函数]
GuiControlShow(guiName,controls*){
	For k,v in controls
	{
	GuiControl, %guiName%:Show, %v%
	}
}
GuiControlHide(guiName,controls*){
	For k,v in controls
	{
	GuiControl, %guiName%:Hide, %v%
	}
}
GuiControlSet(guiName,controlName,controlVal:=""){
	GuiControl, %guiName%:, %controlName%, %controlVal%
}
;~;【——窗口事件Gui——】
MenuEditGuiClose:
	if(TVFlag){
		MsgBox,51,菜单树退出,已修改过菜单信息，是否保存修改再退出？
		IfMsgBox Yes
		{
			gosub,Menu_Save
			gosub,Menu_Reload
		}
		IfMsgBox No
			Gui, Destroy
	}else{
		Gui, Destroy
	}
return
;[GuiEscape]
MenuEditGuiEscape:
SaveItemGuiEscape:
PluginsManageGuiEscape:
PluginsDownloadGuiEscape:
PluginsLibGuiEscape:
RunCtrlManageGuiEscape:
RunCtrlConfigGuiEscape:
RunCtrlFuncGuiEscape:
CtrlRunGuiEscape:
RuleManageGuiEscape:
RuleConfigGuiEscape:
99GuiEscape:
keyGuiEscape:
SaveExtGuiEscape:
SaveVarGuiEscape:
SetCancel:
	Gui,Destroy
return
;[GuiSize]
MenuEditGuiSize:
RuleManageGuiSize:
PluginsManageGuiSize:
PluginsDownloadGuiSize:
	if A_EventInfo = 1
		return
	GuiControl, Move, RunAnyTV, % "H" . (A_GuiHeight-10) . " W" . (A_GuiWidth - 20)
	GuiControl, Move, RunAnyLV, % "H" . (A_GuiHeight-10) . " W" . (A_GuiWidth - 20)
	GuiControl, Move, RuleLV, % "H" . (A_GuiHeight-10) . " W" . (A_GuiWidth - 20)
	GuiControl, Move, RunAnyDownLV, % "H" . (A_GuiHeight-10) . " W" . (A_GuiWidth - 20)
return
66GuiSize:
	if A_EventInfo = 1
		return
	GuiControl, Move, ConfigTab, % "H" . (A_GuiHeight * 0.88) . " W" . (A_GuiWidth - 20)
	GuiControl, Move, vDisableAppGroup, % "H" . (A_GuiHeight * 0.30) . " W" . (A_GuiWidth - 40)
	GuiControl, Move, vDisableApp, % "H" . (A_GuiHeight * 0.25) . " W" . (A_GuiWidth - 60)
	GuiControl, Move, RunAnyHotkeyLV, % " W" . (A_GuiWidth - 60)
	GuiControl, Move, RunAnyMenuVarLV, % "H" . (A_GuiHeight * 0.68) . " W" . (A_GuiWidth - 60)
	GuiControl, Move, vEvCommandGroup, % "H" . (A_GuiHeight * 0.52) . " W" . (A_GuiWidth - 40)
	GuiControl, Move, vEvCommand, % "H" . (A_GuiHeight * 0.32) . " W" . (A_GuiWidth - 60)
	GuiControl, Move, vOneKeyUrlGroup, % " W" . (A_GuiWidth - 40)
	GuiControl, Move, vOneKeyUrl, % " W" . (A_GuiWidth - 60)
	GuiControl, Move, vBrowserPath, % " W" . (A_GuiWidth - 120)
	GuiControl, Move, RunAnyOpenExtLV, % "H" . (A_GuiHeight * 0.68) . " W" . (A_GuiWidth - 60)
	GuiControl, Move, AdvancedConfigLV, % "H" . (A_GuiHeight * 0.77) . " W" . (A_GuiWidth - 60)
	GuiControl, MoveDraw, vSetOK, % " X" . (A_GuiWidth * 0.30) . " Y" . (A_GuiHeight * 0.92)
	GuiControl, MoveDraw, vSetCancel, % " X" . (A_GuiWidth * 0.30 + 90) . " Y" . (A_GuiHeight * 0.92)
	GuiControl, MoveDraw, vSetReSet, % " X" . (A_GuiWidth * 0.30 + 180) . " Y" . (A_GuiHeight * 0.92)
	GuiControl, MoveDraw, vMenu_Config, % " X" . (A_GuiWidth * 0.30 + 310) . " Y" . (A_GuiHeight * 0.925)
return
SaveItemGuiSize:
	if A_EventInfo = 1
		return
	GuiControl,SaveItem:MoveDraw, vitemName, % "W" . (A_GuiWidth-360)
	GuiControl,SaveItem:MoveDraw, vitemPath, % "H" . (A_GuiHeight-230) . " W" . (A_GuiWidth - 120)
	GuiControl,SaveItem:MoveDraw, vPictureIconAdd,% "x" . (A_GuiWidth-130)
	GuiControl,SaveItem:MoveDraw, vTextIconAdd,% "x" . (A_GuiWidth-200)
	GuiControl,SaveItem:MoveDraw, vTextIconDown,% "x" . (A_GuiWidth-100)
	GuiControl,SaveItem:MoveDraw, vSaveItemSaveBtn,% "x" . (A_GuiWidth / 2 - 100) . " y" . (A_GuiHeight-60)
	GuiControl,SaveItem:MoveDraw, vSaveItemCancelBtn,% "x" . (A_GuiWidth / 2 + 10) . " y" . (A_GuiHeight-60)
	GuiControl,SaveItem:MoveDraw, vStatusBar,% "x30" . " y" . (A_GuiHeight-30)
return
RunCtrlManageGuiSize:
	if A_EventInfo = 1
		return
	GuiControl, Move, RunCtrlListBox, % "H" . (A_GuiHeight-15)
	GuiControl, Move, RunCtrlLV, % "H" . (A_GuiHeight-20) . " W" . (A_GuiWidth - 175)
return
;[GuiContextMenu]
MenuEditGuiContextMenu:
PluginsManageGuiContextMenu:
	If (A_GuiControl = "RunAnyTV") {
		TV_Modify(A_EventInfo, "Select Vis")
		Menu, TVMenu, Show
	}
	If (A_GuiControl = "RunAnyLV") {
		LV_Modify(A_EventInfo, "Select Vis")
		Menu, LVMenu, Show
	}
return
RunCtrlManageGuiContextMenu:
	If (A_GuiControl = "RunCtrlListBox" || A_GuiControl = "RunCtrlLV") {
		TV_Modify(A_EventInfo, "Select Vis")
		Menu, RunCtrlLVMenu, Show
	}
return
;[GuiDropFiles]  ; 对拖放提供支持.
MenuEditGuiDropFiles:
SaveItemGuiDropFiles:
	Loop, Parse, A_GuiEvent, `n
	{
		SelectedFileName = %A_LoopField%  ; 仅获取首个文件 (如果有多个文件的时候).
		break
	}
	;获取鼠标下面的控件
	MouseGetPos, , , id, control
	WinGetClass, class, ahk_id %id%
	if(control="SysTreeView321"){
		Loop, Parse, A_GuiEvent, `n
		{
			fileID:=TV_Add(Get_Item_Run_Path(A_LoopField),0,Set_Icon(TreeImageListID,A_LoopField))
			TVFlag:=true
		}
	}
	if(control="Edit1"){
		GuiControl,SaveItem:, vitemName, % Get_Item_Run_Path(SelectedFileName)
	}
	if(control="Edit4"){
		GuiControl,SaveItem:, vitemPath, % Get_Item_Run_Path(SelectedFileName)
	}
	gosub,EditItemPathChange
return
PluginsManageGuiDropFiles:
	MsgBox,33,RunAny新增插件,是否复制脚本文件到插件目录？`n%A_ScriptDir%\%PluginsDir%
	IfMsgBox Ok
	{
		Loop, Parse, A_GuiEvent, `n
		{
			FileCopy, %A_LoopField%, %A_ScriptDir%\%PluginsDir%
		}
		gosub,Plugins_Gui
	}
return
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
;~;【——初始化——】
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
Var_Set:
	;[RunAny设置参数]
	global Z_ScriptName:=FileExist(RunAnyZz ".exe") ? RunAnyZz ".exe" : A_ScriptName
	RegRead, AutoRun, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, RunAny
	AutoRun:=AutoRun=A_ScriptDir "\" Z_ScriptName ? 1 : 0
	;优先读取配置文件，后读注册表
	global IniConfig:=1
	if(FileExist(RunAnyConfig)){
		IniRead,IniConfig,%RunAnyConfig%,Config,IniConfig,1
		RegRead, regVar, HKEY_CURRENT_USER, Software\RunAny, IniConfig
		if ErrorLevel
			IniConfig:=1
	}
	global AdminRun:=Var_Read("AdminRun",0)
	;#判断管理员权限#
	if(AdminRun && !A_IsAdmin){
		adminahkpath:=""
		if(!A_IsCompiled)
			adminahkpath:=A_AhkPath A_Space
		Run *RunAs %adminahkpath%"%A_ScriptFullPath%"
		ExitApp
	}
	global getZz:=""
	global MenuShowMenuRun:=""
	global MENU_NO:=1
	global HideMenuTrayIcon:=Var_Read("HideMenuTrayIcon",0)
	if(HideMenuTrayIcon)
		Menu, Tray, NoIcon
	global AdminMode:=A_IsAdmin ? "【管理员】" : ""
	global MenuTrayTipText:=RunAnyZz . AdminMode "`n"
	global AutoReloadMTime:=Var_Read("AutoReloadMTime",2500)
	global ConfigDate:=Var_Read("ConfigDate")
	global RunABackupDir:=Var_Read("RunABackupDir","`%A_ScriptDir`%\RunBackup")
	global RunABackupRule:=Var_Read("RunABackupRule",1)
	global RunABackupMax:=Var_Read("RunABackupMax",15)
	global RunABackupFormat:=Var_Read("RunABackupFormat",".`%A_Now`%.bak")
	global HideFail:=Var_Read("HideFail",1)
	global HideWeb:=Var_Read("HideWeb",0)
	global HideGetZz:=Var_Read("HideGetZz",0)
	global HideSend:=Var_Read("HideSend",0)
	global HideAddItem:=Var_Read("HideAddItem",0)
	global HideMenuTray:=Var_Read("HideMenuTray",0)
	global HideSelectZz:=Var_Read("HideSelectZz",0)
	global RecentMax:=Var_Read("RecentMax",3)
	;[热键配置]
	global MenuDoubleCtrlKey:=Var_Read("MenuDoubleCtrlKey",0)
	global MenuDoubleAltKey:=Var_Read("MenuDoubleAltKey",0)
	global MenuDoubleLWinKey:=Var_Read("MenuDoubleLWinKey",0)
	global MenuDoubleRWinKey:=Var_Read("MenuDoubleRWinKey",0)
	global MenuMButtonKey:=Var_Read("MenuMButtonKey",0)
	global MenuCtrlRightKey:=Var_Read("MenuCtrlRightKey",0)
	global MenuShiftRightKey:=Var_Read("MenuShiftRightKey",0)
	global MenuXButton1Key:=Var_Read("MenuXButton1Key",0)
	global MenuXButton2Key:=Var_Read("MenuXButton2Key",0)
	global MenuMButtonKey:=Var_Read("MenuMButtonKey",0)
	;[一键直达]
	global OneKeyWeb:=Var_Read("OneKeyWeb",1)
	global OneKeyFolder:=Var_Read("OneKeyFolder",1)
	global OneKeyMagnet:=Var_Read("OneKeyMagnet",1)
	global OneKeyRegedit:=Var_Read("OneKeyRegedit",1)
	global OneKeyFile:=Var_Read("OneKeyFile",1)
	global OneKeyMenu:=Var_Read("OneKeyMenu",0)
	global OneKeyUrl:=Var_Read("OneKeyUrl","https://www.baidu.com/s?wd=%s")
	OneKeyUrl:=StrReplace(OneKeyUrl, "|", "`n")
	;[搜索Everything]
	global EvShowExt:=Var_Read("EvShowExt",1)
	global EvShowFolder:=Var_Read("EvShowFolder",1)
	global EvAutoClose:=Var_Read("EvAutoClose",0)
	global EvExeVerNew:=Var_Read("EvExeVerNew",0)
	global EvExeMTimeNew:=Var_Read("EvExeMTimeNew",0)
	global EvDemandSearch:=Var_Read("EvDemandSearch",1)
	EvCommandDefault:="!C:\Windows* !?:\$RECYCLE.BIN* !?:\Users\*\AppData\Local\Temp"
	try EnvGet, scoopPath, scoop
	if(scoopPath)
		EvCommandDefault.=" !?:\Users\*\scoop\shims\*"
	global EvCommand:=Var_Read("EvCommand",EvDemandSearch ? EvCommandDefault : EvCommandDefault " file:*.exe|*.lnk|*.ahk|*.bat|*.cmd")
	;[热字符串]
	global HideHotStr:=Var_Read("HideHotStr",0)
	global HotStrHintLen:=Var_Read("HotStrHintLen",3)
	global HotStrShowLen:=Var_Read("HotStrShowLen",30)
	global HotStrShowTime:=Var_Read("HotStrShowTime",3000)
	global HotStrShowTransparent:=Var_Read("HotStrShowTransparent",80)
	global HotStrShowX:=Var_Read("HotStrShowX",0)
	global HotStrShowY:=Var_Read("HotStrShowY",0)
	global SendStrEcKey:=Var_Read("SendStrEcKey")
	global SendStrDcKey:=Var_Read("SendStrDcKey")
	;[高级配置]开始
	global ShowGetZzLen:=Var_Read("ShowGetZzLen",50)
	global GetZzTranslate:=Var_Read("GetZzTranslate",0)
	global GetZzTranslateMenu:=Var_Read("GetZzTranslateMenu",0)
	global GetZzTranslateSource:=Var_Read("GetZzTranslateSource","auto")
	global GetZzTranslateTarget:=Var_Read("GetZzTranslateSource","zh-CN")
	global GetZzTranslateAuto:=Var_Read("GetZzTranslateAuto",0)
	global DebugMode:=Var_Read("DebugMode",0)
	global DebugModeShowTime:=Var_Read("DebugModeShowTime",8000)
	global DebugModeShowTrans:=Var_Read("DebugModeShowTrans",70)
	global DebugModeShowText:=""
	global DebugModeShowTextLen:=0
	global EvNo:=Var_Read("EvNo",0)
	global JumpSearch:=Var_Read("JumpSearch",0)
	global AutoGetZz:=Var_Read("AutoGetZz",1)
	global DisableExeIcon:=Var_Read("DisableExeIcon",0)
	global RunAEncoding:=Var_Read("RunAEncoding",A_Language!=0804 ? "UTF-8" : "")
	global ClipWaitTime:=Var_Read("ClipWaitTime",0.1)
	global ClipWaitApp:=Var_Read("ClipWaitApp","")
	global HoldKeyShowTime:=Var_Read("HoldKeyShowTime",1000)
	global RUNANY_SELF_MENU_ITEM1:=Var_Read("RUNANY_SELF_MENU_ITEM1","&1批量搜索")
	global RUNANY_SELF_MENU_ITEM2:=Var_Read("RUNANY_SELF_MENU_ITEM2","RunAny设置")
	global RUNANY_SELF_MENU_ITEM3:=Var_Read("RUNANY_SELF_MENU_ITEM3","0【添加到此菜单】")
	global RUNANY_SELF_MENU_ITEM4:=Var_Read("RUNANY_SELF_MENU_ITEM4","-【显示全部菜单】")
	global RunAnyMenuTransparent:=Var_Read("RunAnyMenuTransparent",225)
	global RunAnyMenuSpaceRun:=Var_Read("RunAnyMenuSpaceRun",2)
	global RunAnyMenuRButtonRun:=Var_Read("RunAnyMenuRButtonRun",3)
	global RunAnyMenuMButtonRun:=Var_Read("RunAnyMenuMButtonRun",0)
	global RunAnyMenuXButton1Run:=Var_Read("RunAnyMenuXButton1Run",0)
	global RunAnyMenuXButton2Run:=Var_Read("RunAnyMenuXButton2Run",0)
	global HoldKeyList:={"HoldCtrlRun":2,"HoldCtrlShiftRun":3,"HoldCtrlWinRun":4,"HoldShiftRun":5,"HoldShiftWinRun":6,"HoldCtrlShiftWinRun":7}
	global HoldKeyValList:={"HoldCtrlRun":2,"HoldCtrlShiftRun":3,"HoldCtrlWinRun":11,"HoldShiftRun":5,"HoldShiftWinRun":31,"HoldCtrlShiftWinRun":4}
	for k, v in HoldKeyList
	{
		%k%:=Var_Read(k,HoldKeyValList[k])
		j:=%k%
		if(j){
			HoldKeyRun%j%:=v
		}
	}
	;[高级配置]结束
	DisableApp:=Var_Read("DisableApp","vmware-vmx.exe,TeamViewer.exe,SunloginClient.exe,War3.exe,dota2.exe,League of Legends.exe")
	Loop,parse,DisableApp,`,
	{
		GroupAdd,DisableGUI,ahk_exe %A_LoopField%
	}
	EvCommandVar:=RegExReplace(EvCommand,"i).*file:(\*\.[^\s]*).*","$1")
	global EvCommandExtList:=StrSplit(EvCommandVar,"|")
	global MENU_RUN_NAME_STR:="编辑(&E),同名软件(&S),软件目录(&D),透明运行(&Q),置顶运行(&T),改变大小运行(&W),管理员权限运行(&A),最小化运行(&I),最大化运行(&P),隐藏运行(&H),结束软件进程(&X)"
	global MENU_RUN_NAME_NOFILE_STR:="复制运行路径(&C),输出运行路径(&V),复制软件名(&N),输出软件名(&M),复制软件名+后缀(&F),输出软件名+后缀(&G)"
	MENU_RUN_NAME_STR.="," MENU_RUN_NAME_NOFILE_STR
	MENU_RUN_NAME_NOFILE_STR:="编辑(&E)," MENU_RUN_NAME_NOFILE_STR
	Loop, 9
	{
		MENU_RUN_NAME_STR.=",透明运行:&" A_Index*10 "%"
	}
	;~[最近运行项]
	if(RecentMax>0){
		global MenuCommonList:={}
		RegRead, MenuCommonListReg, HKEY_CURRENT_USER, Software\RunAny, MenuCommonList
		if(MenuCommonListReg){
			Loop, parse, MenuCommonListReg, |
			{
				R_ThisMenuItem:=RegExReplace(A_LoopField,"&\d+ ","")
				if R_ThisMenuItem not in %MENU_RUN_NAME_STR%
				{
					MenuCommonList.Push(A_LoopField)
				}
			}
		}
	}
	;~[定期自动检查更新]
	global githubUrl:="https://raw.githubusercontent.com"
	global giteeUrl:="https://gitee.com"
	global RunAnyGiteePages:="https://hui-zz.gitee.io"
	global RunAnyGithubPages:="https://hui-zz.github.io"
	global RunAnyGiteeDir:="/hui-Zz/RunAny/raw/master"
	global RunAnyGithubDir:="/hui-Zz/RunAny/master"
	global RunAnyDownDir:=giteeUrl . RunAnyGiteeDir ; 初始使用gitee地址
	if(A_DD=01 || A_DD=15){
		;当天已经检查过就不再更新
		if(FileExist(A_Temp "\temp_RunAny.ahk")){
			FileGetTime,tempMTime, %A_Temp%\temp_RunAny.ahk, M  ; 获取修改时间.
			t1 := A_Now
			t1 -= %tempMTime%, Days
			FormatTime,tempTimeDD,%tempMTime%,dd
			if(t1=0 && (tempTimeDD=01 || tempTimeDD=15))
				return
		}
		Gosub,Auto_Update
	}
return
;~;【菜单自定义变量】
Menu_Var_Set:
	global MenuVarIniList:={}
	global MenuVarTypeList:={}
	IniRead,menuVarVar,%RunAnyConfig%,MenuVar
	SplitPath, A_ScriptDir,,,,,A_ScriptDrive
	if(!menuVarVar){
		menuVarVar:="A_Desktop`nA_MyDocuments`nA_ScriptDir`nA_ScriptDrive`n"
		menuVarVar.="AppData`nComputerName`nComSpec`nLocalAppData`nOneDrive`nProgramFiles`n"
		if(A_Is64bitOS)
			menuVarVar.="ProgramW6432`n"
		menuVarVar.="UserName`nUserProfile`nWinDir"
	}
	Loop, parse, menuVarVar, `n, `r
	{
		if(A_LoopField="")
			continue
		itemList:=StrSplit(A_LoopField,"=",,2)
		menuVarName:=itemList[1]
		menuVarVal:=itemList[2]
		if(%menuVarName%){
			MenuVarIniList[itemList[1]]:=%menuVarName%
			MenuVarTypeList[menuVarName]:=1
		}else{
			try EnvGet, %menuVarName%, %menuVarName%
			if(%menuVarName%){
				MenuVarIniList[itemList[1]]:=%menuVarName%
				MenuVarTypeList[menuVarName]:=2
			}else{
				%menuVarName%:=menuVarVal
				MenuVarTypeList[menuVarName]:=3
				MenuVarIniList[itemList[1]]:=itemList[2]
			}
		}
	}
return
;~;【内部关联后缀打开方式】
Open_Ext_Set:
	;支持一键直达浏览器无路径识别
	global BrowserPath:=Var_Read("BrowserPath")
	global BrowserPathRun:=Get_Obj_Path_Transform(BrowserPath)
	global openExtIniList:={}
	global openExtRunList:={}
	IniRead,openExtVar,%RunAnyConfig%,OpenExt
	Loop, parse, openExtVar, `n, `r
	{
		itemList:=StrSplit(A_LoopField,"=",,2)
		openExtIniList[itemList[1]]:=itemList[2]
		Loop, parse,% itemList[2], %A_Space%
		{
			extLoopField:=RegExReplace(A_LoopField,"^\.","")
			openExtRunList[extLoopField]:=Get_Obj_Path_Transform(itemList[1])
		}
		if((itemList[2]="folder" && (InStr(itemList[1],"totalcmd.exe") || InStr(itemList[1],"TotalCMD64.exe")))
			|| MenuObjEv["totalcmd"] || MenuObjEv["TotalCMD64"]){
			ClipWaitTime:=Var_Read("ClipWaitTime",1.5)
			ClipWaitApp:=Var_Read("ClipWaitApp","totalcmd.exe,totalcmd64.exe")
		}
	}
	Loop,parse,ClipWaitApp,`,
	{
		GroupAdd,ClipWaitGUI,ahk_exe %A_LoopField%
	}
	if(!openExtRunList["folder"]){
		TcPath:=Var_Read("TcPath")
		if(TcPath){
			openExtName:="folder"
			if(openExtIniList[TcPath]){ ; 如果已存在旧打开方式，则加在末尾
				openExtName:=openExtIniList[TcPath] A_Space "folder"
			}
			IniWrite,%openExtName%,%RunAnyConfig%,OpenExt,%TcPath%
			openExtRunList["folder"]:=Get_Obj_Path_Transform(TcPath)
			openExtIniList[TcPath]:=openExtName
			IniDelete,%RunAnyConfig%,Config,TcPath
		}
	}
	global OpenFolderPathRun:=openExtRunList["folder"]
return
;~;【调用环境判断】
Run_Exist:
	;#判断菜单配置文件初始化#
	global iniPath:=A_ScriptDir "\" RunAnyZz ".ini"
	global iniPath2:=A_ScriptDir "\" RunAnyZz "2.ini"
	global iniFile:=iniPath
	global iniVar1:=""
	global both:=1
	global RunABackupDirPath:=Get_Transform_Val(RunABackupDir)
	global PluginsDir:="RunPlugins"	;~插件目录
	IfNotExist %RunABackupDirPath%
		FileCreateDir,%RunABackupDirPath%
	IfNotExist %RunABackupDirPath%\%RunAnyConfig%
		FileCreateDir,%RunABackupDirPath%\%RunAnyConfig%
	IfNotExist,%A_ScriptDir%\%PluginsDir%\Lib
		FileCreateDir, %A_ScriptDir%\%PluginsDir%\Lib
	if(RunAEncoding){
		try{
			FileEncoding,%RunAEncoding%
		}catch e{
			MsgBox,16,文件编码出错,% "请设置正确的编码读取RunAny.ini!`n参考：https://wyagd001.github.io/zh-cn/docs/commands/FileEncoding.htm"
			. "`n`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
		}
	}
	FileGetSize,iniFileSize,%iniFile%
	If(!FileExist(iniFile) || iniFileSize=0){
		TrayTip,,RunAny初始化中...,2,1
		gosub,First_Run
	}
	FileRead, iniVar1, %iniPath%
	;#判断第2菜单ini#
	global MENU2FLAG:=false
	IfExist,%iniPath2%
	{
		global iniVar2:=""
		MENU2FLAG:=true
		FileRead, iniVar2, %iniPath2%
		IfNotExist %RunABackupDirPath%\%RunAnyZz%2.ini
			FileCreateDir,%RunABackupDirPath%\%RunAnyZz%2.ini
	}
	;#判断配置文件
	if(!FileExist(RunAnyConfig)){
		IniWrite,%IniConfig%,%RunAnyConfig%,Config,IniConfig
	}
	global iniFileVar:=iniVar1
	;#判断Everything拓展DLL文件#
	if(!EvNo){
		global everyDLL:="Everything.dll"
		if(FileExist(A_ScriptDir "\Everything.dll")){
			everyDLL:=DllCall("LoadLibrary", str, "Everything.dll") ? "Everything.dll" : "Everything64.dll"
		}else if(FileExist(A_ScriptDir "\Everything64.dll")){
			everyDLL:=DllCall("LoadLibrary", str, "Everything64.dll") ? "Everything64.dll" : "Everything.dll"
		}
		IfNotExist,%A_ScriptDir%\%everyDLL%
		{
			MsgBox,17,,没有找到%everyDLL%，将不能识别菜单中程序的路径`n需要将%everyDLL%放到【%A_ScriptDir%】目录下`n是否需要从网上下载%everyDLL%？
			IfMsgBox Ok
			{
				URLDownloadToFile(RunAnyDownDir "/" everyDLL,A_ScriptDir "\" everyDLL)
				gosub,Menu_Reload
			}
		}
		global EvCheckFlag:=false  ;~是否启动Everything搜索检查
		RegRead,EvTotResults,HKEY_CURRENT_USER,SOFTWARE\RunAny,EvTotResults
		RegRead,RunAnyTickCount,HKEY_CURRENT_USER,SOFTWARE\RunAny,RunAnyTickCount
		RegWrite,REG_SZ,HKEY_CURRENT_USER,SOFTWARE\RunAny,RunAnyTickCount,%A_TickCount%
		if(!RunAnyTickCount || A_TickCount<RunAnyTickCount || !EvTotResults){
			EvCheckFlag:=true
		}
	}
return
;~;【图标初始化】
Icon_Set:
	global RunIconDir:=A_ScriptDir "\RunIcon"
	global WebIconDir:=RunIconDir "\WebIcon"
	global ExeIconDir:=RunIconDir "\ExeIcon"
	global MenuIconDir:=RunIconDir "\MenuIcon"
	IconDirs:="ExeIcon,WebIcon,MenuIcon"
	Loop, Parse, IconDirs, `,
	{
		IfNotExist %RunIconDir%\%A_LoopField%
			FileCreateDir,%RunIconDir%\%A_LoopField%
	}
	global IconFileSuffix:="*.ico;*.bmp;*.png;*.gif;*.jpg;*.jpeg;*.jpe;*.jfif;*.dib;*.tif;*.tiff;*.heic"
		. ";*.cur;*.ani,*.cpl,*.scr"
	global ResourcesExtractExist:=false
	global ResourcesExtractDir:=A_ScriptDir "\ResourcesExtract"
	global ResourcesExtractFile:=A_ScriptDir "\ResourcesExtract\ResourcesExtract.exe"
	if(!FileExist(ResourcesExtractFile)){
		ResourcesExtractFile:=RunIconDir "\ResourcesExtract\ResourcesExtract.exe"
		if(FileExist(ResourcesExtractFile)){
			ResourcesExtractExist:=true
			ResourcesExtractDir:=RunIconDir "\ResourcesExtract"
		}
	}else{
		ResourcesExtractExist:=true
	}
	iconAny:="shell32.dll,190"
	iconMenu:="shell32.dll,195"
	iconTree:="shell32.dll,53"
	if(A_OSVersion="WIN_XP"){
		MoveIcon:="shell32.dll,53"
		UpIcon:="shell32.dll,53"
		DownIcon:="shell32.dll,53"
	}else{
		MoveIcon:="shell32.dll,246"
		UpIcon:="shell32.dll,247"
		DownIcon:="shell32.dll,248"
	}
	if(A_IsCompiled=1){
		iconAny:=A_ScriptName ",1"
		iconMenu:=A_ScriptName ",2"
	}
	if(FileExist(A_ScriptDir "\ZzIcon.dll")){
		iconAny:="ZzIcon.dll,1"
		iconMenu:="ZzIcon.dll,2"
		iconTree:="ZzIcon.dll,3"
		MoveIcon:="ZzIcon.dll,4"
		UpIcon:="ZzIcon.dll,5"
		DownIcon:="ZzIcon.dll,6"
	}
	MonitorHeight:=true
	SysGet, MonitorCount, MonitorCount
	Loop, %MonitorCount%
	{
		SysGet, Monitor, Monitor, %A_Index%
		if(MonitorBottom<1080){
			MonitorHeight:=false
		}
	}
	;如果所有显示器分辨率都大于等于1080高度则菜单图标默认24像素大小
	global MenuIconSize:=Var_Read("MenuIconSize",MonitorHeight ? 24 : "")
	global MenuTrayIconSize:=Var_Read("MenuTrayIconSize")
	global AnyIcon:=Var_Read("AnyIcon",iconAny)
	global AnyIconS:=StrSplit(Get_Transform_Val(AnyIcon),",")
	global MenuIcon:=Var_Read("MenuIcon",iconMenu)
	global MenuIconS:=StrSplit(Get_Transform_Val(MenuIcon),",")
	global TreeIcon:=Var_Read("TreeIcon",iconTree)
	global TreeIconS:=StrSplit(Get_Transform_Val(TreeIcon),",")
	global MoveIconS:=StrSplit(MoveIcon,",")
	global UpIconS:=StrSplit(UpIcon,",")
	global DownIconS:=StrSplit(DownIcon,",")
	global EditFileIcon:=Var_Read("EditFileIcon","shell32.dll,134")
	global EditFileIconS:=StrSplit(EditFileIcon,",")
	global PluginsManageIcon:=Var_Read("PluginsManageIcon","shell32.dll,166")
	global PluginsManageIconS:=StrSplit(PluginsManageIcon,",")
	global RunCtrlManageIcon:=Var_Read("RunCtrlManageIcon","shell32.dll,25")
	global RunCtrlManageIconS:=StrSplit(RunCtrlManageIcon,",")
	global CheckUpdateIcon:=Var_Read("CheckUpdateIcon","shell32.dll,14")
	global CheckUpdateIconS:=StrSplit(CheckUpdateIcon,",")
return
;~;[后缀图标初始化]
Icon_FileExt_Set:
	Menu,exeTestMenu,add,SetCancel	;只用于测试应用图标正常添加
	FolderIcon:=Var_Read("FolderIcon","shell32.dll,4")
	global FolderIconS:=StrSplit(Get_Transform_Val(FolderIcon),",")
	UrlIcon:=Var_Read("UrlIcon","shell32.dll,44")
	global UrlIconS:=StrSplit(Get_Transform_Val(UrlIcon),",")
	EXEIcon:=Var_Read("EXEIcon","shell32.dll,3")
	global EXEIconS:=StrSplit(Get_Transform_Val(EXEIcon),",")
	LNKIcon:="shell32.dll,264"
	if(A_OSVersion="WIN_XP"){
		LNKIcon:="shell32.dll,30"
	}
	global LNKIconS:=StrSplit(LNKIcon,",")
	FuncIcon:=Var_Read("FuncIcon","shell32.dll,131")
	global FuncIconS:=StrSplit(Get_Transform_Val(FuncIcon),",")
	try{
		Menu,exeTestMenu,Icon,SetCancel,ZzIcon.dll,7
		ZzIconPath:="ZzIcon.dll,7"
	} catch {
		ZzIconPath:="ZzIcon.dll,1"
	}
	global ZzIconS:=StrSplit(ZzIconPath,",")
	;[RunAny菜单图标初始化]
	try Menu,Tray,Icon,显示菜单(&Z)`t%MenuHotKey%,% ZzIconS[1],% ZzIconS[2],%MenuTrayIconSize%
	try Menu,Tray,Icon,修改菜单(&E)`t%TreeHotKey1%,% TreeIconS[1],% TreeIconS[2],%MenuTrayIconSize%
	Menu,Tray,Icon,修改文件(&F)`t%TreeIniHotKey1%,% EditFileIconS[1],% EditFileIconS[2],%MenuTrayIconSize%
	If(MENU2FLAG){
		try Menu,Tray,Icon,显示菜单2(&2)`t%MenuHotKey2%,% ZzIconS[1],% ZzIconS[2],%MenuTrayIconSize%
		try Menu,Tray,Icon,修改菜单2(&W)`t%TreeHotKey2%,% TreeIconS[1],% TreeIconS[2],%MenuTrayIconSize%
		Menu,Tray,Icon,修改文件2(&G)`t%TreeIniHotKey2%,% EditFileIconS[1],% EditFileIconS[2],%MenuTrayIconSize%
	}
	try Menu,Tray,Icon,插件管理(&C)`t%PluginsManageHotKey%,% PluginsManageIconS[1],% PluginsManageIconS[2],%MenuTrayIconSize%
	try Menu,Tray,Icon,启动管理(&Q)`t%RunCtrlManageHotKey%,% RunCtrlManageIconS[1],% RunCtrlManageIconS[2],%MenuTrayIconSize%
	try Menu,Tray,Icon,设置RunAny(&D)`t%RunASetHotKey%,% MenuIconS[1],% MenuIconS[2],%MenuTrayIconSize%
	try Menu,Tray,Icon,关于RunAny(&A)...,% AnyIconS[1],% AnyIconS[2],%MenuTrayIconSize%
	Menu,Tray,Icon,检查更新(&U),% CheckUpdateIconS[1],% CheckUpdateIconS[2],%MenuTrayIconSize%
	;~;[引入菜单项图标识别库]
	global IconFolderPath:=Var_Read("IconFolderPath","%A_ScriptDir%\RunIcon\ExeIcon|%A_ScriptDir%\RunIcon\WebIcon|%A_ScriptDir%\RunIcon\MenuIcon")
	global IconFolderList:={}
	Loop, parse, IconFolderPath, |
	{
		IconFolder:=Get_Transform_Val(A_LoopField)
		IfExist,%IconFolder%
		{
			Loop,%IconFolder%\*.*,0,1
			{
				SplitPath,% A_LoopFileFullPath, ,, ext, name_no_ext
				IconFolderList[(name_no_ext)]:=A_LoopFileFullPath
			}
		}
	}
	IconFolderPath:=StrReplace(IconFolderPath, "|", "`n")
return
;~;[图标集初始图标]
Icon_Image_Set(ImageListID){
	IL_Add(ImageListID, "shell32.dll", 1)
	IL_Add(ImageListID, "shell32.dll", 2)
	IL_Add(ImageListID, EXEIconS[1], EXEIconS[2])
	IL_Add(ImageListID, FolderIconS[1], FolderIconS[2])
	IL_Add(ImageListID, LNKIconS[1], LNKIconS[2])
	IL_Add(ImageListID, TreeIconS[1], TreeIconS[2])
	IL_Add(ImageListID, UrlIconS[1], UrlIconS[2])
	IL_Add(ImageListID, "shell32.dll", 50)
	IL_Add(ImageListID, "shell32.dll", 100)
	IL_Add(ImageListID, "shell32.dll", 101)
	IL_Add(ImageListID, FuncIconS[1], FuncIconS[2])
}
;#菜单加载完后，预读完成"修改菜单"的GUI图标
Icon_Tree_Image_Set(ImageListID){
	Loop,%MenuCount%
	{
		Loop, parse, iniVar%A_Index%, `n, `r, %A_Space%%A_Tab%
		{
			if(InStr(A_LoopField,";")=1 || A_LoopField="")
				continue
			Set_Icon(ImageListID,A_LoopField,false)
		}
	}
}
;~;[循环提取菜单中所有EXE程序图标，过程较慢]
Menu_Exe_Icon_Create:
	cfgFile=%ResourcesExtractDir%\ResourcesExtract.cfg
	DestFold=%A_Temp%\%RunAnyZz%\RunAnyExeIconTemp
	if(!ResourcesExtractExist){
		MsgBox, 请将ResourcesExtract.exe放入%ResourcesExtractDir%
		return
	}
	MsgBox,35,生成所有EXE图标，请稍等片刻, 
(	
使用生成的EXE图标可以加快开机第一次RunAny的加载速度`n`n是：覆盖老图标重新生成%RunAnyZz%菜单中的所有EXE图标`n否：只生成没有的EXE图标`n取消：取消生成
)
	IfMsgBox Yes
	{
		exeIconCreateFlag:=false
		gosub,Menu_Exe_Icon_Extract
	}
	IfMsgBox No
	{
		exeIconCreateFlag:=true
		gosub,Menu_Exe_Icon_Extract
	}
return
Menu_Exe_Icon_Extract:
	if(!FileExist(cfgFile)){
		MsgBox, 请将ResourcesExtract.cfg放入%ResourcesExtractDir%
		return
	}else{
		IniWrite,%DestFold%,%cfgFile%,General,DestFolder
		IniWrite,1,%cfgFile%,General,ExtractIcons
		IniWrite,0,%cfgFile%,General,ExtractCursors
		IniWrite,0,%cfgFile%,General,ExtractBitmaps
		IniWrite,0,%cfgFile%,General,ExtractHTML
		IniWrite,0,%cfgFile%,General,ExtractAnimatedIcons
		IniWrite,0,%cfgFile%,General,ExtractAnimatedCursors
		IniWrite,0,%cfgFile%,General,ExtractAVI
		IniWrite,0,%cfgFile%,General,OpenDestFolder
		IniWrite,2,%cfgFile%,General,MultiFilesMode
	}
	ToolTip,RunAny开始用ResourcesExtract生成EXE图标，请稍等……
	For k, v in MenuExeArray
	{
		exePath:=v["itemFile"]
		if(FileExist(exePath)){
			menuItem:=menuItemIconFileName(v["menuItem"])
			if(!exeIconCreateFlag || !FileExist(ExeIconDir "\" menuItem ".ico")){
				Run,%ResourcesExtractFile% /LoadConfig "%cfgFile%" /Source "%exePath%" /DestFold "%DestFold%"
			}
		}
	}
	Process,WaitClose,ResourcesExtract.exe,10
	ToolTip
	Menu_Exe_Icon_Set()
	MsgBox, 成功生成%RunAnyZz%内所有EXE图标到 %ExeIconDir%
	Gui,66:Submit, NoHide
	if(vIconFolderPath){
		if(!InStr(vIconFolderPath,"ExeIcon"))
			GuiControl,, vIconFolderPath, %vIconFolderPath%`n`%A_ScriptDir`%\RunIcon\ExeIcon
	}else{
		GuiControl,, vIconFolderPath, `%A_ScriptDir`%\RunIcon\ExeIcon
	}
return
;~;[循环提取菜单中EXE程序的正确图标]
Menu_Exe_Icon_Set(){
	IfNotExist,%ExeIconDir%
		FileCreateDir, %ExeIconDir%
	For k, v in MenuExeArray
	{
		exePath:=v["itemFile"]
		SplitPath, exePath, exeName, exeDir, ext, name_no_ext
		iconNameFlag:=false
		maxFileName=
		maxFileSize=
		maxFilePath=
		IfExist,%A_Temp%\%RunAnyZz%\RunAnyExeIconTemp\%exeName%
		{
			loop,%A_Temp%\%RunAnyZz%\RunAnyExeIconTemp\%exeName%\*.ico
			{
				if(RegExMatch(A_LoopFileName,"iS).*_MAINICON.ico")){
					maxFilePath:=A_LoopFileFullPath
					break
				}
				if(!iconNameFlag && RegExMatch(A_LoopFileName,"iS).*_\d+\.ico")){
					iconNum:=RegExReplace(A_LoopFileName,"iS).*_(\d+)\.ico","$1")
					if(A_Index=1 || maxFileName>iconNum){
						maxFileName:=iconNum
						maxFilePath:=A_LoopFileFullPath
					}
					continue
				}
				if(maxFileSize<A_LoopFileSize){
					iconNameFlag:=true
					maxFileSize:=A_LoopFileSize
					maxFilePath:=A_LoopFileFullPath
				}
			}
			menuItem:=menuItemIconFileName(v["menuItem"])
			FileCopy, %maxFilePath%, %ExeIconDir%\%menuItem%.ico, 1
			maxFilePath=
		}
	}
}
menuItemIconFileName(menuItem){
	if(InStr(menuItem,"`t")){
		menuKeyStr:=RegExReplace(menuItem, "S)\t+", A_Tab)
		menuKeys:=StrSplit(menuKeyStr,"`t")
		menuItem:=menuKeys[1]
	}
	if(RegExMatch(menuItem,"S).*_:\d{1,2}$"))
		menuItem:=RegExReplace(menuItem,"S)(.*)_:\d{1,2}$","$1")
	if(RegExMatch(menuItem,"S):[*?a-zA-Z0-9]+?:[^:]*")){
		menuItemTemp:=RegExReplace(menuItem,"S)^([^:]*?):[*?a-zA-Z0-9]+?:[^:]*","$1")
		if(menuItemTemp)
			menuItem:=menuItemTemp
	}
	return menuItem
}
;══════════════════════════════════════════════════════════════════
;~;【——插件脚本——】
;══════════════════════════════════════════════════════════════════
;~;【AHK插件脚本Read】
Plugins_Read:
	global PluginsObjList:=Object()
	global PluginsPathList:=Object()
	global PluginsTitleList:=Object()
	global PluginsContentList:=Object()
	global PluginsObjNum:=0
	global PluginsDirList:=[]
	global PluginsEditor:=Var_Read("PluginsEditor")
	global PluginsDirPath:=Var_Read("PluginsDirPath")
	global PluginsDirPathList:="%A_ScriptDir%\RunPlugins|" PluginsDirPath
	FileRead,pluginsContent,%A_ScriptFullPath%
	PluginsContentList[RunAnyZz ".ahk"]:=pluginsContent
	Loop, parse, PluginsDirPathList, |
	{
		PluginsFolder:=Get_Transform_Val(A_LoopField)
		PluginsFolder:=RegExReplace(PluginsFolder,"(.*)\\$","$1")
		if(!FileExist(PluginsFolder))
			continue
		PluginsDirList.Push(PluginsFolder)
		Loop,%PluginsFolder%\*.ahk,0	;Plugins目录下AHK脚本
		{
			PluginsObjList[(A_LoopFileName)]:=0
			PluginsPathList[(A_LoopFileName)]:=A_LoopFileFullPath
			PluginsTitleList[(A_LoopFileName)]:=Plugins_Read_Title(A_LoopFileFullPath)
			if(A_LoopField="%A_ScriptDir%\RunPlugins"){
				FileRead,pluginsContent,%A_LoopFileFullPath%
				PluginsContentList[(A_LoopFileName)]:=pluginsContent
			}
		}
		Loop,%PluginsFolder%\*.*,2	;Plugins目录下文件夹内同名AHK脚本
		{
			IfExist,%A_LoopFileFullPath%\%A_LoopFileName%.ahk
			{
				PluginsObjList[(A_LoopFileName . ".ahk")]:=0
				PluginsPathList[(A_LoopFileName . ".ahk")]:=A_LoopFileFullPath "\" A_LoopFileName ".ahk"
				PluginsTitleList[(A_LoopFileName . ".ahk")]:=Plugins_Read_Title(A_LoopFileFullPath "\" A_LoopFileName ".ahk")
				if(A_LoopField="%A_ScriptDir%\RunPlugins"){
					FileRead,pluginsContent,% A_LoopFileFullPath "\" A_LoopFileName ".ahk"
					PluginsContentList[(A_LoopFileName . ".ahk")]:=pluginsContent
				}
			}
		}
	}
	IniRead,pluginsVar,%RunAnyConfig%,Plugins
	Loop, parse, pluginsVar, `n, `r
	{
		varList:=StrSplit(A_LoopField,"=",,2)
		SplitPath,% varList[1], name,, ext, name_no_ext
		PluginsObjList[(varList[1])]:=varList[2]
		if(varList[2])
			PluginsObjNum++
		Loop,% PluginsDirList.MaxIndex()
		{
			if(FileExist(PluginsDirList[A_Index] "\" varList[1]))
				PluginsPathList[(varList[1])]:=PluginsDirList[A_Index] "\" varList[1]
			if(FileExist(PluginsDirList[A_Index] "\" name_no_ext "\" varList[1]))
				PluginsPathList[(varList[1])]:=PluginsDirList[A_Index] "\" name_no_ext "\" varList[1]
		}
	}
return
;~;【AHK脚本对象注册】
Plugins_Object_Register:
	global PluginsObjRegGUID:=Object()	;~插件对象注册GUID列表
	global PluginsObjRegActive:=Object()	;~插件对象注册Active列表
	global RunAny_ObjReg_Path
	RunAny_ObjReg_Path=%A_ScriptDir%\%PluginsDir%\%RunAny_ObjReg%
	IfExist,%RunAny_ObjReg_Path%
	{
		IniRead,objRegVar,%RunAny_ObjReg_Path%,objreg
		Loop, parse, objRegVar, `n, `r
		{
			varList:=StrSplit(A_LoopField,"=",,2)
			PluginsObjRegGUID[(varList[1])]:=varList[2]
		}
	}
	if(PluginsObjRegGUID["huiZz_Text"] && PluginsObjList["huiZz_Text.ahk"]){
		;#判断huiZz_Text插件是否可以文字翻译
		if(InStr(PluginsContentList["huiZz_Text.ahk"],"runany_google_translate(getZz,from,to){")){
			global translateFlag:=true
		}
		;#判断huiZz_Text插件是否可以文字加解密
		if(InStr(PluginsContentList["huiZz_Text.ahk"],"runany_encrypt(text,key){")
				&& InStr(PluginsContentList["huiZz_Text.ahk"],"runany_decrypt(text,key){")){
			global encryptFlag:=true
		}
	}
	;#判断RunAny_Menu插件是否启用
	if(PluginsObjList["RunAny_Menu.ahk"]){
		if(InStr(PluginsContentList["RunAny_Menu.ahk"],"SetTimer,Transparent_Show"))
			global RunAnyMenuTransparentFlag:=true
		if(InStr(PluginsContentList["RunAny_Menu.ahk"],"~Space Up::"))
			global RunAnyMenuSpaceFlag:=true
		if(InStr(PluginsContentList["RunAny_Menu.ahk"],"~RButton Up::"))
			global RunAnyMenuRButtonFlag:=true
		if(InStr(PluginsContentList["RunAny_Menu.ahk"],"~MButton Up::"))
			global RunAnyMenuMButtonFlag:=true
		if(InStr(PluginsContentList["RunAny_Menu.ahk"],"~XButton1 Up::"))
			global RunAnyMenuXButton1Flag:=true
		if(InStr(PluginsContentList["RunAny_Menu.ahk"],"~XButton2 Up::"))
			global RunAnyMenuXButton2Flag:=true
	}
return
Plugins_Read_Title(filePath){
	returnStr:=""
	strReg:="iS).*?【(.*?)】.*"
	Loop, read, %filePath%
	{
		if(RegExMatch(A_LoopReadLine,strReg)){
			returnStr:=RegExReplace(A_LoopReadLine,strReg,"$1")
			break
		}
	}
	return returnStr
}
Plugins_Read_Version(filePath){
	returnStr:=""
	strReg=iS)^\t*\s*global RunAny_Plugins_Version:="([\d\.]*)"
	Loop, read, %filePath%
	{
		if(RegExMatch(A_LoopReadLine,strReg)){
			returnStr:=RegExReplace(A_LoopReadLine,strReg,"$1")
			break
		}
	}
	return returnStr
}
;~;【自动启动插件】
AutoRun_Plugins:
	try {
		if(A_AhkPath){
			For runn, runv in PluginsPathList	;循环启动项
			{
				;需要自动启动的项
				if(PluginsObjList[runn]){
					runValue:=RegExReplace(runv,"iS)(.*?\.exe)($| .*)","$1")	;去掉参数
					SplitPath, runValue, name, dir, ext  ; 获取扩展名
					if(dir && FileExist(dir)){
						SetWorkingDir,%dir%
					}
					if(ext="ahk"){
						Run,%A_AhkPath%%A_Space%"%runv%"
					}else{
						Run,%runv%
					}
				}
			}
		}
	} catch e {
		MsgBox,16,自动启动插件出错,% "启动插件名：" runn "`n启动插件路径：" runv 
			. "`n出错脚本：" e.File "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
	} finally {
		SetWorkingDir,%A_ScriptDir%
	}
return
;[随RunAny自动关闭插件]
AutoClose_Plugins:
	DetectHiddenWindows,On
	For runn, runv in PluginsPathList
	{
		if(PluginsObjList[runn]){
			runValue:=RegExReplace(runv,"iS)(.*?\.exe)($| .*)","$1")	;去掉参数
			SplitPath, runValue, name,, ext  ; 获取扩展名
			if(ext="ahk"){
				PostMessage, 0x111, 65405,,, %runv% ahk_class AutoHotkey
			}else if(name){
				Process,Close,%name%
			}
		}
	}
	DetectHiddenWindows,Off
return
;══════════════════════════════════════════════════════════════════
;~;【——规则启动——】
;══════════════════════════════════════════════════════════════════
;~;【规则启动项Read】
RunCtrl_Read:
	;规则名-脚本路径；规则名-脚本插件名；规则名-函数名；规则名-状态；规则名-类型；规则名-是否传参
	global rulefileList:=Object(),ruleitemList:=Object(),rulefuncList:=Object(),rulestatusList:=Object(),ruletypelist:=Object(),ruleparamList:=Object()
	global RuleNameStr:=""
	ruleitemVar:=rulefuncVar:=""
	IniRead,ruleitemVar,%RunAnyConfig%,RunCtrlRule
	Loop, parse, ruleitemVar, `n, `r
	{
		varList:=StrSplit(A_LoopField,"=",,2)
		itemList:=StrSplit(varList[1],"|",,2)
		if(varList[1]="" || varList[2]="" || itemList[1]="" || itemList[2]="")
			continue
		RuleNameStr.=itemList[1] "|"
		rulefuncList[(rulefuncList[itemList[1]]!="" ? itemList[1] "(重名)" : itemList[1])]:=itemList[2]
		rulefileList[(rulefileList[itemList[1]]!="" ? itemList[1] "(重名)" : itemList[1])]:=varList[2]
		SplitPath,% varList[2],fileName,,,nameNotExt
		ruleitemList[itemList[1]]:=nameNotExt
		if(varList[2]=RunAnyZz ".ahk"){
			rulestatusList[(rulestatusList[itemList[1]]!="" ? itemList[1] "(重名)" : itemList[1])]:=IsFunc(itemList[2])
		}else if(varList[2]="0"){
			ruletypelist[(ruletypelist[itemList[1]]!="" ? itemList[1] "(重名)" : itemList[1])]:=true
			if(Get_Transform_Val("%" itemList[2] "%")!=itemList[2]){
				rulestatusList[(rulestatusList[itemList[1]]!="" ? itemList[1] "(重名)" : itemList[1])]:=true
			}
		}else{
			rulestatusList[(rulestatusList[itemList[1]]!="" ? itemList[1] "(重名)" : itemList[1])]:=InStr(PluginsContentList[(varList[2])],itemList[2] "(") ? 1 : 0
		}
		if(varList[2]!="0" && !InStr(PluginsContentList[(varList[2])],itemList[2] "()")){
			ruleparamList[(ruleparamList[itemList[1]]!="" ? itemList[1] "(重名)" : itemList[1])]:=true
		}
	}
	RuleNameStr:=SubStr(RuleNameStr, 1, -StrLen("|"))
	;---规则启动项---
	global RunCtrlList:=Object(),RunCtrlListBoxList:=Object(),RunCtrlListContentList:=Object()
	global RunCtrlLogicEnum:={"eq":"相等","ne":"不相等","ge":"大于等于","le":"小于等于","gt":"大于","lt":"小于"}
	global RunCtrlListBoxVar:=""
	IniRead,runCtrlListVar,%RunAnyConfig%,RunCtrlList
	Loop, parse, runCtrlListVar, `n, `r
	{
		R_LoopField=%A_LoopField%
		if(R_LoopField="")
			continue
		varList:=StrSplit(R_LoopField,"=",,2)
		if(varList[1]="")
			continue
		runCtrlName:=varList[1]
		RunCtrlListBoxVar.=runCtrlName "|"
		RunCtrlListBoxList.Push(runCtrlName)
		RunCtrlListContentList[runCtrlName]:=varList[2]
		itemList:=StrSplit(varList[2],"|",,5)
		RunCtrlObj:=new RunCtrl(runCtrlName,itemList[1],itemList[2],itemList[3],itemList[4],itemList[5])
		RunCtrlList[runCtrlName]:=RunCtrlObj
		try{
			if(itemList[5]!=""){
				funcEffect:=Func("RunCtrl_RunRules").Bind(RunCtrlObj,true)
				Hotkey,% itemList[5],% funcEffect,On
			}
		} catch{
			MsgBox,16,规则组%runCtrlName%：热键配置不正确,% "热键错误：`n" itemList[5] "`n请设置正确热键后重启RunAny"
		}
	}
	RunCtrlListBoxVar:=SubStr(RunCtrlListBoxVar, 1, -StrLen("|"))
return

RunCtrlLogicEnumGetKey(val){
	for k,v in RunCtrlLogicEnum
	{
		if(val=v)
			return k
	}
}

class RunCtrl
{
	name:=""                ;运行组名
	enable:=false           ;运行组启用状态
	noPath:=true            ;无全路径应用
	noMenu:=true            ;无菜单项应用
	key:=""                 ;规则组全局热键
	ruleLogic:=true         ;规则组逻辑：与、或
	ruleMostRun:=0          ;规则循环最大次数
	ruleIntervalTime:=0     ;循环间隔时间(秒)
	runNums:=""             ;运行次数
	runList:=Object()       ;应用运行队列
	ruleFile:=Object()      ;规则文件
	ruleList:=Object()      ;规则队列
	__New(name,enable,ruleLogic,ruleMostRun,ruleIntervalTime,key){
		this.name:=name
		this.enable:=enable
		this.ruleLogic:=ruleLogic
		this.ruleMostRun:=ruleMostRun
		this.ruleIntervalTime:=ruleIntervalTime
		this.key:=key
		IniRead,ctrlAppsVar,%RunAnyConfig%,%name%_Run
		Loop, parse, ctrlAppsVar, `n, `r
		{
			varList:=StrSplit(A_LoopField,"=",,2)
			if(varList[1]="")
				continue
			runObj:=new RunCtrlRun
			runObj.path:=varList[2]

			itemList:=StrSplit(varList[1],"|",,2)
			noPathStr:=itemList[1]
			runObj.repeatRun:=itemList[2]!="" ? itemList[2] : 0
			if(noPathStr="path"){
				this.noPath:=false
				runObj.noPath:=false
			}else if(noPathStr="menu"){
				this.noMenu:=false
			}
			this.runList.push(runObj)
		}
		IniRead,ruleAppsVar,%RunAnyConfig%,%name%_Rule
		Loop, parse, ruleAppsVar, `n, `r
		{
			varList:=StrSplit(A_LoopField,"=",,2)
			itemList:=StrSplit(varList[1],"|",,3)
			if(varList[1]="" || itemList[1]="")
				continue
			runRuleObj:=new RunCtrlRunRule
			runRuleObj.value:=varList[2]
			runRuleObj.name:=itemList[1]
			runRuleObj.logic:=itemList[2]
			runRuleObj.ruleBreak:=itemList[3]
			runRuleObj.file:=ruleitemList[itemList[1]]
			this.ruleList.push(runRuleObj)
			if(rulestatusList[runRuleObj.name]){
				this.ruleFile[ruleitemList[runRuleObj.name]]:=true
			}
		}
	}
}
class RunCtrlRun
{
	num:=0
	path:=""
	noPath:=true		;无路径标记
	repeatRun:=false	;重复运行
}
class RunCtrlRunRule
{
	file:="",name:="",value:="",ruleBreak:=""
	logic:=1
}

;~;【规则生效】
Rule_Effect:
	global runIndex:=Object()
	try{
		for n,obj in RunCtrlList
		{
			runCtrlObj:=RunCtrlList[n]
			if(!runCtrlObj.enable){
				continue
			}
			rcName:=runCtrlObj.name
			;规则循环
			if(runCtrlObj.ruleMostRun!="" && runCtrlObj.ruleMostRun>0){
				runIndex[rcName]:=0	;规则定时器初始计数为0
				funcEffect%rcName%:=Func("RunCtrl_RunRules").Bind(runCtrlObj)	;规则定时器
				ruleTime:=runCtrlObj.ruleIntervalTime>0 ? runCtrlObj.ruleIntervalTime * 1000 : 1000		;规则定时器间隔时间(秒)
				SetTimer,% funcEffect%rcName%, %ruleTime%
			}else{
				RunCtrl_RunRules(runCtrlObj)
			}
		}
	} catch e { 
		MsgBox,16,规则判断出错,% "规则名：" rcName 
			. "`n出错脚本：" e.File "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
	}
return
;~;【规则启动-应用】
RunCtrl_RunRules(runCtrlObj,show:=0){
	try {
		rcName:=runCtrlObj.name
		effectResult:=RunCtrl_RuleEffect(runCtrlObj)
		if(effectResult){
			for i,runv in runCtrlObj.runList
			{
				if(!runCtrlObj.noPath || !runCtrlObj.noMenu){
					RunCtrl_RunApps(runv.path, runv.noPath, runv.repeatRun)
				}
			}
		}else if(show){
			ToolTip, 规则验证失败
			SetTimer,RemoveToolTip,3000
		}
		return effectResult
	} catch e {
		MsgBox,16,启动规则出错,% "启动规则名：" rcName 
			. "`n出错脚本：" e.File "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
	} finally {
		runIndex[rcName]++	;规则定时器运行计数+1
		;规则运行计数达到最大循环次数 || 启动项已达到最多运行次数 => 结束定时器
		if((runIndex[rcName] && runIndex[rcName] >= runCtrlObj.ruleMostRun)){
			try SetTimer,% funcEffect%rcName%, Off
		}
	}
}
;~;[规则启动应用]
RunCtrl_RunApps(path,noPath,repeatRun:=0){
	try {
		DetectHiddenWindows,On
		if(noPath){
			path:=Get_Obj_Transform_Name(Trim(path," `t`n`r"))
			if(!repeatRun && rule_check_is_run(MenuObj[path])){
				return
			}
			MenuShowMenuRun:=path
			gosub,Menu_Run
		}else{
			path:=Get_Transform_Val(path)
			SplitPath,% path, name, dir
			if(!repeatRun && rule_check_is_run(path)){
				return
			}
			if(dir && FileExist(dir))
				SetWorkingDir,%dir%
			Run_Any(path)
		}
	} catch e {
		MsgBox,16,规则启动应用出错,% "启动应用：" path
			. "`n出错脚本：" e.File "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
	} finally {
		SetWorkingDir,%A_ScriptDir%
		DetectHiddenWindows,Off
	}
}
;~;[规则判断是否成立]
RunCtrl_RuleEffect(runCtrlObj){
	effectFlag:=false
	ruleRunCount:=0
	rcName:=runCtrlObj.name
	for ruleFile,ruleStatus in runCtrlObj.ruleFile
	{
		if(ruleStatus && ruleFile!="0" && ruleFile!="RunAny"){
			PluginsObjRegActive[ruleFile]:=ComObjActive(PluginsObjRegGUID[ruleFile])
		}
	}
	for i,rulev in runCtrlObj.ruleList
	{
		ruleRunCount++
		if(!rulefuncList[rulev.name])
			continue
		;获取变量规则、插件规则函数的执行结果
		effectResult:=RunCtrl_RuleResult(rulev.name, rulev.file, rulev.value)
		;根据运算符计算规则最终是否成立
		if(ruleparamList[rulev.name]){
			;如果规则设定条件为（假、不相等），而脚本执行结果是真，则判定为假；执行结果是假，则判定为真
			if(rulev.logic=0 || rulev.logic="ne"){
				effectFlag:=!effectResult
			}else{
				effectFlag:=effectResult
			}
		}else{
			;根据不同的运算符判断结果为真或假
			if(rulev.value=""){
				if(rulev.logic=0 || rulev.logic="ne"){
					effectFlag:=!effectResult
				}else{
					effectFlag:=effectResult
				}
			}else if(rulev.logic=1 || rulev.logic="eq"){
				effectFlag:=effectResult = rulev.value
			}else if(rulev.logic=0 || rulev.logic="ne"){
				effectFlag:=effectResult != rulev.value
			}else if(rulev.logic="gt"){
				effectFlag:=effectResult > rulev.value
			}else if(rulev.logic="ge"){
				effectFlag:=effectResult >= rulev.value
			}else if(rulev.logic="lt"){
				effectFlag:=effectResult < rulev.value
			}else if(rulev.logic="le"){
				effectFlag:=effectResult <= rulev.value
			}else{
				effectFlag:=effectResult
			}
		}
		;有中断标记的规则不满足时，则直接中断后续判断并停止规则循环
		if(rulev.ruleBreak){
			if(!effectFlag){
				try SetTimer,% funcEffect%rcName%, Off
				break
			}else{
				continue
			}
		}
		;该启动项所有规则必须全部为真时，如有一假就退出循环
		;该启动项只需要有一项规则为真时，如有一真就退出循环
		if(runCtrlObj.ruleLogic){
			if(!effectFlag)
				break
		}else if(effectFlag){
			break
		}
	}
	return ruleRunCount>0 ? effectFlag : true
}
;~;[规则结果返回]
RunCtrl_RuleResult(ruleName,ruleFile,ruleValue:=""){
	effectResult=
	if(ruleparamList[ruleName]){
		;传参模式仅判断真假，不做运算符计算
		if(ruleFile=RunAnyZz && IsFunc(rulefuncList[ruleName])){
			effectResult:=Func(rulefuncList[ruleName]).Call(ruleValue)
		}else{
			effectResult:=PluginsObjRegActive[ruleFile][(rulefuncList[ruleName])](ruleValue)
		}
	}else{
		if(ruletypelist[ruleName]){
			effectResult:=Get_Transform_Val("%" rulefuncList[ruleName] "%")
		}else if(ruleFile=RunAnyZz && IsFunc(rulefuncList[ruleName])){
			effectResult:=Func(rulefuncList[ruleName]).Call()
		}else{
			effectResult:=PluginsObjRegActive[(ruleitemList[ruleName])][(rulefuncList[ruleName])]()
		}
	}
	return effectResult
}
;══════════════════════════════════════════════════════════════════
;~;【——检查更新——】
;══════════════════════════════════════════════════════════════════
Check_Update:
	checkUpdateFlag:=true
	TrayTip,,RunAny检查更新中……,2,1
	gosub,Auto_Update
return
Auto_Update:
	if(FileExist(A_Temp "\RunAny_Update.bat"))
		FileDelete, %A_Temp%\RunAny_Update.bat
	;[下载最新的更新脚本]
	if(!rule_check_network(giteeUrl)){
		RunAnyDownDir:=githubUrl . RunAnyGithubDir
		if(!rule_check_network(githubUrl)){
			TrayTip,,网络异常，无法连接网络读取最新版本文件,3,1
			return
		}
	}
	URLDownloadToFile(RunAnyDownDir "/RunAny.ahk",A_Temp "\temp_RunAny.ahk")
	versionReg=iS)^\t*\s*global RunAny_update_version:="([\d\.]*)"
	Loop, read, %A_Temp%\temp_RunAny.ahk
	{
		if(RegExMatch(A_LoopReadLine,versionReg)){
			versionStr:=RegExReplace(A_LoopReadLine,versionReg,"$1")
			break
		}
		if(A_LoopReadLine="404: Not Found"){
			TrayTip,,文件下载异常，更新失败！,3,1
			return
		}
	}
	if(versionStr){
		if(RunAny_update_version<versionStr){
			MsgBox,33,RunAny检查更新,检测到RunAny有新版本`n`n%RunAny_update_version%`t版本更新后=>`t%versionStr%`n`n
(
是否更新到最新版本？
覆盖老版本文件，如有修改过RunAny.ahk请注意备份！
)
			IfMsgBox Ok
			{
				TrayTip,,RunAny下载最新版本并替换老版本...,5,1
				gosub,Config_Update
				URLDownloadToFile(RunAnyDownDir "/RunAny.exe",A_Temp "\temp_RunAny.exe")
				gosub,RunAny_Update
				shell := ComObjCreate("WScript.Shell")
				shell.run(A_Temp "\RunAny_Update.bat",0)
				ExitApp
			}
		}else if(checkUpdateFlag){
			FileDelete, %A_Temp%\temp_RunAny.ahk
			TrayTip,,RunAny已经是最新版本。,5,1
			checkUpdateFlag:=false
		}else if(A_DD!=01 && A_DD!=15){
			FileDelete, %A_Temp%\temp_RunAny.ahk
		}
	}
return
Config_Update:
	if(FileExist(A_ScriptDir "\ZzIcon.dll")){
		FileGetSize, ZzIconSize, %A_ScriptDir%\ZzIcon.dll
		if(ZzIconSize=610304){
			URLDownloadToFile(RunAnyDownDir "/ZzIcon.dll",A_ScriptDir "\ZzIcon.dll")
		}
	}
return
RunAny_Update:
if(rule_check_network(RunAnyGiteePages)){
	Run,%RunAnyGiteePages%/runany/#/change-log
}else{
	Run,%RunAnyGithubPages%/RunAny/#/change-log
}
TrayTip,,RunAny已经更新到最新版本。,5,1
FileAppend,
(
@ECHO OFF & setlocal enabledelayedexpansion & TITLE RunAny更新版本
set /a x=1
:BEGIN
set /a x+=1
ping -n 2 127.1>nul
if exist "%A_Temp%\temp_RunAny.ahk" `(
  MOVE /y "%A_Temp%\temp_RunAny.ahk" "%A_ScriptDir%\RunAny.ahk"
`)
if exist "%A_Temp%\temp_RunAny.exe" `(
  MOVE /y "%A_Temp%\temp_RunAny.exe" "%A_ScriptDir%\RunAny.exe"
`)
goto INDEX
:INDEX
if !x! GTR 10 `(
  exit
`)
if exist "%A_Temp%\temp_RunAny.ahk" `(
  goto BEGIN
`)
if exist "%A_Temp%\temp_RunAny.exe" `(
  if !x! EQU 5 `(
    taskkill /f /im %A_ScriptName%
  `)
  goto BEGIN
`)
start "" "%A_ScriptDir%\%A_ScriptName%"
exit
),%A_Temp%\RunAny_Update.bat
return
;══════════════════════════════════════════════════════════════════
;~;【托盘菜单】
MenuTray:
	Menu,Tray,NoStandard
	try Menu,Tray,Icon,% MenuIconS[1],% MenuIconS[2]
	Menu,Tray,add,显示菜单(&Z)`t%MenuHotKey%,Menu_Show1
	Menu,Tray,add,修改菜单(&E)`t%TreeHotKey1%,Menu_Edit1
	Menu,Tray,add,修改文件(&F)`t%TreeIniHotKey1%,Menu_Ini
	Menu,Tray,add
	If(MENU2FLAG){
		Menu,Tray,add,显示菜单2(&2)`t%MenuHotKey2%,Menu_Show2
		Menu,Tray,add,修改菜单2(&W)`t%TreeHotKey2%,Menu_Edit2
		Menu,Tray,add,修改文件2(&G)`t%TreeIniHotKey2%,Menu_Ini2
		Menu,Tray,add
	}
	Menu,Tray,add,插件管理(&C)`t%PluginsManageHotKey%,Plugins_Gui
	Menu,Tray,add,启动管理(&Q)`t%RunCtrlManageHotKey%,RunCtrl_Manage_Gui
	Menu,Tray,add
	Menu,Tray,add,设置RunAny(&D)`t%RunASetHotKey%,Settings_Gui
	Menu,Tray,add,关于RunAny(&A)...,Menu_About
	Menu,Tray,add,检查更新(&U),Check_Update
	Menu,Tray,add
	Menu,Tray,add,重启(&R)`t%RunAReloadHotKey%,Menu_Reload
	Menu,Tray,add,停用(&S)`t%RunASuspendHotKey%,Menu_Suspend
	Menu,Tray,add,退出(&X)`t%RunAExitHotKey%,Menu_Exit
	Menu,Tray,Default,显示菜单(&Z)`t%MenuHotKey%
	Menu,Tray,Click,1
return
Menu_Tray:
	Menu,Tray,Show
return
Menu_Ini:
	Ini_Run(iniPath)
return
Menu_Ini2:
	Ini_Run(iniPath2)
return
Menu_Config:
	Ini_Run(RunAnyConfig)
return
Menu_Reload:
	try Reload
	Sleep,1000
	Run,%A_AhkPath%%A_Space%"%A_ScriptFullPath%"
	ExitApp
return
Menu_Suspend:
	Menu,tray,ToggleCheck,停用(&S)`t%RunASuspendHotKey%
	Suspend
return
Menu_Exit:
	gosub,AutoClose_Plugins
	ExitApp
return
RemoveToolTip:
	SetTimer,RemoveToolTip,Off
	ToolTip
return
RemoveDebugModeToolTip:
	SetTimer,RemoveDebugModeToolTip,Off
	DebugModeShowText:=""
	DebugModeShowTextLen:=0
	ToolTip
return
ExitSub:
	gosub,AutoClose_Plugins
	ExitApp
return
Ini_Run(ini){
	try{
		if(!FileExist(ini)){
			MsgBox,16,%ini%,没有找到配置文件：%ini%
		}
		Run,"%ini%"
	}catch{
		Run,notepad.exe "%ini%"
	}
}
;══════════════════════════════════════════════════════════════════
;~;【使用everything搜索所有exe程序】
;══════════════════════════════════════════════════════════════════
;[校验everything是否可正常返回搜索结果]
everythingCheck:
FileDelete,%A_Temp%\RunAnyEv.ahk
FileAppend,
(
#NoTrayIcon
global everyDLL:="%A_ScriptDir%\%everyDLL%"
ev:=new everything
ev.SetMatchWholeWord(true)
ev.SetSearch("explorer.exe")
ev.Query()
while,`% !ev.GetTotResults()
{
	if(A_Index>1000){
		MsgBox,16,RunAny无法与Everything通信,Everything启动缓慢或异常导致无法搜索到磁盘文件``n``n
		`(
【原因1：Everything正在创建索引】
请手动打开Everything等待可以搜索到文件了请再重启RunAny``n
【原因2：Everything数据库在不同磁盘导致读写缓慢】
查看Everything.exe和文件Everything.db是否不在同一硬盘``n
在Everything窗口最上面菜单的“工具”——“选项”——找到选中左边的“索引”——
修改右边的数据库路径到Everything.exe同一硬盘，加快读写速度``n
【原因3：Everything搜索异常】
请打开Everything菜单-工具-选项设置 安装Everything服务(S)，再重启Everything待可以搜索文件再重启RunAny
		`)
		break
	}
	Sleep, 100
	ev.Query()
}
val:=ev.GetTotResults(0)
RegWrite,REG_SZ,HKEY_CURRENT_USER,SOFTWARE\RunAny,EvTotResults,`%val`%
return
class everything
{
	__New(){
		this.hModule := DllCall("LoadLibrary",str,everyDLL)
	}
	SetSearch(aValue)
	{
		this.eSearch := aValue
		dllcall(everyDLL "\Everything_SetSearch",str,aValue)
		return
	}
	SetMatchWholeWord(aValue)
	{
		this.eMatchWholeWord := aValue
		dllcall(everyDLL "\Everything_SetMatchWholeWord",int,aValue)
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
}
),%A_Temp%\RunAnyEv.ahk
Run,%A_AhkPath%%A_Space%"%A_Temp%\RunAnyEv.ahk"
return
everythingCheckResults:
	RegRead,EvTotResults,HKEY_CURRENT_USER,SOFTWARE\RunAny,EvTotResults
	if(EvTotResults>0){
		SetTimer,everythingCheckResults,Off
		gosub,Menu_Reload
	}
return
everythingQuery(EvCommandStr){
	ev := new everything
	if(EvCommandStr!=""){
		ev.SetMatchWholeWord(true)
	}
	Menu_Tray_Tip("","开始调用Everything搜索菜单内应用全路径...")
	evSearchStr:=EvCommandStr ? EvCommand " " EvCommandStr : EvCommand
	;查询字串设为everything
	ev.SetSearch("file: " evSearchStr)
	;执行搜索
	ev.Query()
	Loop,% ev.GetNumFileResults()
	{
		chooseNewFlag:=false
		Z_Index:=A_Index-1
		objFullPathName:=ev.GetResultFullPathName(Z_Index)
		objFileName:=ev.GetResultFileName(Z_Index)
		objFileNameNoExeExt:=RegExReplace(objFileName,"iS)\.exe$","")
		if(MenuObjEv[objFileNameNoExeExt]){
			MenuObjSame[(MenuObjEv[objFileNameNoExeExt])]:=MenuObjEv[objFileNameNoExeExt]
			MenuObjSame[objFullPathName]:=objFullPathName
			if(EvExeMTimeNew){
				;优先选择最新修改时间的同名文件全路径
				FileGetTime,objFullPathNameUpdateTimeOld,% MenuObjEv[objFileNameNoExeExt], M
				FileGetTime,objFullPathNameUpdateTimeNew,% objFullPathName, M
				if(objFullPathNameUpdateTimeOld<objFullPathNameUpdateTimeNew){
					chooseNewFlag:=true
				}
			}
			if(EvExeVerNew && RegExMatch(objFileName,"iS).*?\.exe$")){
				;优先选择最新版本的同名exe全路径
				FileGetVersion,objFullPathNameVersionOld,% MenuObjEv[objFileNameNoExeExt]
				FileGetVersion,objFullPathNameVersionNew,% objFullPathName
				if(objFullPathNameVersionOld<objFullPathNameVersionNew){
					MenuObjEv[objFileNameNoExeExt]:=objFullPathName
				}else if(chooseNewFlag && objFullPathNameVersionOld=objFullPathNameVersionNew){
					MenuObjEv[objFileNameNoExeExt]:=objFullPathName
				}
				continue
			}
			;版本相同则取最新修改时间，时间相同或小于则不改变
			if(EvExeMTimeNew && !chooseNewFlag){
				continue
			}
		}
		MenuObjEv[objFileNameNoExeExt]:=objFullPathName
	}
}
everythingCommandStr(){
	Loop,%MenuCount%
	{
		Loop, parse, iniVar%A_Index%, `n, `r, %A_Space%%A_Tab%
		{
			if(A_LoopField="" || InStr(A_LoopField,";")=1 || InStr(A_LoopField,"-")=1){
				continue
			}
			itemVars:=StrSplit(A_LoopField,"|",,2)
			itemVar:=itemVars[2] ? itemVars[2] : itemVars[1]
			itemMode:=Get_Menu_Item_Mode(itemVar)
			outVar:=RegExReplace(itemVar,"iS)^([^|]+?\.[^ ]+)($| .*)","$1")	;去掉参数
			if(InStr(EvCommandStr,"|" outVar "|") || (itemMode!=1 && itemMode!=8)){
				continue
			}else if(itemMode=1 && (RegExMatch(outVar,"S)\\|\/|\:|\*|\?|\""|\<|\>|\|")
					|| FileExist(A_WinDir "\" outVar) || FileExist(A_WinDir "\system32\" outVar))){
				continue
			}else if(itemMode=8){
				if(RegExMatch(itemVar,"iS).+?\[.+?\]%?\(.*?%"".+?""%.*?\)")){
					outVar:=RegExReplace(itemVar,"iS).+?\[.+?\]%?\(.*?%""(.+?)""%.*?\)","$1")
				}else{
					continue
				}
			}
			if(InStr(outVar,A_Space) || InStr(outVar,"!")){
				EvCommandStr.="""" outVar . """|"
			}else{
				EvCommandStr.=outVar . "|"
			}
		}
	}
	EvCommandStr:=RegExReplace(EvCommandStr,"\|$")
	return EvCommandStr
}
;~;[使用everything搜索单个exe程序]
exeQuery(exeName,noSystemExe:=" !C:\Windows*"){
	ev := new everything
	str := exeName . noSystemExe
	;查询字串设为全字匹配
	ev.SetMatchWholeWord(true)
	ev.SetSearch(str)
	;执行搜索
	ev.Query()
	return ev.GetResultFullPathName(0)
}
;~;[IPC方式和everything进行通讯，修改于AHK论坛]
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
	;设置全字匹配
	SetMatchWholeWord(aValue)
	{
		this.eMatchWholeWord := aValue
		dllcall(everyDLL "\Everything_SetMatchWholeWord",int,aValue)
		return
	}
	;执行搜索动作
	Query(aValue=1)
	{
		dllcall(everyDLL "\Everything_Query",int,aValue)
		return
	}
	;返回管理员权限状态
	GetIsAdmin()
	{
		return dllcall(everyDLL "\Everything_IsAdmin")
	}
	;返回匹配总数
	GetTotResults()
	{
		return dllcall(everyDLL "\Everything_GetTotResults")
	}
	;返回可见文件结果的数量
	GetNumFileResults()
	{
		return dllcall(everyDLL "\Everything_GetNumFileResults")
	}
	;返回文件名
	GetResultFileName(aValue)
	{
		return strget(dllcall(everyDLL "\Everything_GetResultFileName",int,aValue))
	}
	;返回文件全路径
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
		gosub,Desktop_Append
		gosub,Menu_Reload
	}
return
Desktop_Append:
	desktopItem:="`n-桌面(&Desktop)`n"
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
	Loop,%A_Desktop%\*.exe,0
	{
		desktopItem.="`t" A_LoopFileName "`n"
	}
	FileAppend,%desktopItem%,%iniFile%
return
;~;[初次运行]
First_Run:
FileAppend,
(
;以【;】开头代表注释
;以【-】开头+名称表示1级分类
-常用(&App)
	Chrome浏览器|chrome.exe
	;多个同名iexplore.exe用全路径指定运行32位IE
	;在【|】前加上IE(&E)的简称显示
	IE(&E)|`%ProgramFiles`%\Internet Explorer\iexplore.exe
	;2级分隔符【--】
	--
	StrokesPlus鼠标手势|StrokesPlus.exe
	Ditto剪贴板|Ditto.exe
-办公(wo&Rk)|doc docx xls xlsx ppt pptx wps et dps
	word(&W)|winword.exe
	Excel(&E)|excel.exe
	PPT(&T)|powerpnt.exe
	;以【--】开头名称表示2级分类
	--WPS(&S)
		WPS(&W)|WPS.exe
		ET(&E)|et.exe
		WPP(&P)|wpp.exe
	--
-网址(&Web)
	;在别名最末尾添加Tab制表符+热键(参考AHK写法:^代表Ctrl !代表Alt #代表Win +代表Shift)，如选中文字按Alt+z百度
	百度(&B)	!z|https://www.baidu.com/s?wd=
	谷歌(&G)	!g|https://www.google.com/search?q=`%s&gws_rd=ssl
	翻译(&F)	#z|https://translate.google.cn/#auto/zh-CN/
	异次元软件|http://www.iplaysoft.com/search/?s=548512288484505211&q=`%s
	淘宝(&T)|https://s.taobao.com/search?q=`%s
	京东(&D)|https://search.jd.com/Search?keyword=`%s&enc=utf-8
	知乎(&Z)|https://www.zhihu.com/search?type=content&q=
	B站|http://search.bilibili.com/all?keyword=`%s
	--
	RunAny地址|https://github.com/hui-Zz/RunAny
-图片(im&G)|bmp gif jpeg jpg png
	画图(&T)|mspaint.exe
	ACDSee.exe
	XnView.exe
	IrfanView.exe
-影音(&Video)|avi mkv mp4 rm rmvb flv wmv swf mp3
	QQPlayer.exe
	PotPlayer.exe
	XMP.exe
	--
	云音乐(&C)|cloudmusic.exe
	QQ音乐|QQMusic.exe
-编辑(&Edit)|txt ini cmd bat md ahk html
	;在别名后面添加_:数字形式来透明启动应用(默认不透明,1-100是全透明到不透明)
	记事本(&N)_:88|notepad.exe
-文件(&File)
	WinRAR.exe
	TC文件管理|Totalcmd.exe
	Everything文件秒搜|Everything.exe
-系统(&Sys)
	cmd.exe
	控制面板(&S)|Control.exe
	;在程序名后空格+带参数启动
	hosts文件|notepad.exe `%A_WinDir`%\System32\drivers\etc\hosts
-输入(inpu&T)
	;当前时间（变量语法参考AHK文档https://wyagd001.github.io/zh-cn/docs/Variables.htm）
	当前时间|`%A_YYYY`%-`%A_MM`%-`%A_DD`% `%A_Hour`%:`%A_Min`%:`%A_Sec`%;
	;热键映射,快捷方便,左边Shift+空格=回车键;左手Shift+大小写键=删除键
	左手回车	<+Space|{Enter}::
	左手删除	LShift & CapsLock|{Delete}::
),%iniFile%
Gosub,Desktop_Append
FileAppend,
(
-
;1级分隔符【-】并且使下面项目都回归1级分类
QQ.exe
;使用【&】指定快捷键为C,忽略下面C盘的快捷键C
计算器(&C)|calc.exe
我的电脑(&Z)|explorer.exe
;以【\】结尾代表是文件夹路径
C盘|C:\
-
),%iniFile%
global iniFlag:=true
return
