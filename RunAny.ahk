/*
╔══════════════════════════════════════════════════
║【RunAny】一劳永逸的快速启动工具 v5.8.1 @2022.05.03
║ 国内Gitee文档：https://hui-zz.gitee.io/RunAny
║ Github文档：https://hui-zz.github.io/RunAny
║ Github地址：https://github.com/hui-Zz/RunAny
║ 直接运行本脚本需要AutoHotKey版本：1.1.31 以上
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
SetWorkingDir,%A_ScriptDir%                  ;~;脚本当前工作目录
global StartTick:=A_TickCount                ;~;评估初始化时间
global RunAnyZz:="RunAny"                    ;~;名称
global PluginsDir:="RunPlugins"              ;~;插件目录
global RunAnyConfig:="RunAnyConfig.ini"      ;~;配置文件
global RunAny_ObjReg:="RunAny_ObjReg.ini"    ;~;插件注册配置文件
global RunAny_update_version:="5.8.1"        ;~;版本号
global RunAny_update_time:="2022.05.03"      ;~;更新日期
global iniPath:=A_ScriptDir "\RunAny.ini"    ;~;菜单1
global iniPath2:=A_ScriptDir "\RunAny2.ini"  ;~;菜单2
Gosub,Config_Set        ;~;01.配置初始化
Gosub,Menu_Var_Set      ;~;02.自定义变量
Gosub,Icon_Set          ;~;03.图标初始化
Gosub,Run_Exist         ;~;04.调用环境判断
;══════════════════════════════════════════════════════════════════
;~;[05.初始化菜单显示热键]
HotKeyList:=["MenuHotKey","MenuHotKey2","MenuNoGetHotKey","EvHotKey","OneHotKey"]
RunHotKeyList:=HotKeyList.Clone()
HotKeyList.Push("TreeHotKey1","TreeHotKey2","TreeIniHotKey1","TreeIniHotKey2"
	,"RunATrayHotKey","RunASetHotKey","RunAReloadHotKey","RunASuspendHotKey","RunAExitHotKey"
	,"PluginsManageHotKey","RunCtrlManageHotKey","PluginsAlonePauseHotKey","PluginsAloneSuspendHotKey","PluginsAloneCloseHotKey")
HotKeyTextList:=["RunAny菜单显示热键","RunAny菜单2热键","RunAny菜单热键(不获取选中内容)","一键Everything热键","一键搜索热键"]
HotKeyTextList.Push("修改菜单管理(1)","修改菜单管理(2)","修改菜单文件(1)","修改菜单文件(2)")
HotKeyTextList.Push("RunAny托盘菜单","设置RunAny","重启RunAny","停用RunAny","退出RunAny"
	,"插件管理","启动管理","独立插件脚本一键暂停","独立插件脚本挂起热键","独立插件脚本一键关闭")
RunList:=["Menu_Show1","Menu_Show2","Menu_NoGet_Show","Ev_Show","One_Show","Menu_Edit1","Menu_Edit2","Menu_Ini","Menu_Ini2"]
RunList.Push("Menu_Tray","Settings_Gui","Menu_Reload","Menu_Suspend","Menu_Exit"
	,"Plugins_Gui","RunCtrl_Manage_Gui","Plugins_Alone_Pause","Plugins_Alone_Suspend","Plugins_Alone_Close")
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
			if ki in 2,7,9
			{
				continue
			}
		}
		%kv%:=%winkeyV% ? "#" . %keyV% : %keyV%
		try{
			if(IsLabel(RunList[ki]))
				Hotkey,% %kv%,% RunList[ki],On
		}catch{
			errorKeyStr.=kv "`n"
		}
	}
}
if(errorKeyStr){
	lb:="Settings_Gui"
	if(IsLabel(lb)){
		Gosub,%lb%
	}
	if(ki!=1 && ki!=2)
		SendInput,^{Tab}
	MsgBox,16,RunAny热键配置不正确,% "热键错误：`n" errorKeyStr "`n请设置正确热键后重启RunAny"
	return
}
if(A_AhkVersion < 1.1.31){
	MsgBox, 16, AutoHotKey版本过低！, 由于你的AHK版本没有高于1.1.31，会影响RunAny功能的使用!`n
	(
1. 不支持StrSplit()函数的MaxParts`n2. 不支持动态Hotstring创建`n3. 不支持Switch Case的语法
	)
}
;══════════════════════════════════════════════════════════════════
Gosub,Menu_Tray_Add                         ;~;06.托盘菜单
Gosub,Icon_FileExt_Set                      ;~;07.后缀图标初始化
t1:=A_TickCount-StartTick
if(!iniFlag){
	Gosub,Plugins_Read                      ;~;08.插件脚本读取
	Gosub,AutoClose_Plugins                 ;~;09.关闭插件脚本
	Gosub,AutoRun_Plugins                   ;~;10.运行插件脚本
	Gosub,Plugins_Object_Register           ;~;11.插件对象注册
	Gosub,RunCtrl_Read                      ;~;12.启动规则读取
}
;══════════════════════════════════════════════════════════════════
;~;[13.创建初始菜单]
t2:=t3:=A_TickCount-StartTick
Menu_Tray_Tip("初始化+运行插件：" Round(t2/1000,3) "s`n","开始创建无图标菜单...")
global MenuObj:=Object()                    ;~程序全路径
global MenuObjKey:=Object()                 ;~程序热键
global MenuObjKeyName:=Object()             ;~程序热键关联菜单项名称
global MenuObjKeyList:=Object()             ;~程序热键关联菜单项列表
global MenuObjExt:=Object()                 ;~后缀对应的菜单
global MenuObjWindow:=Object()              ;~软件窗口对应的菜单
global MenuHotStrList:=Object()             ;~热字符串对象数组
global MenuTreeKey:=Object()                ;~菜单树分类热键
global MenuObjIconList:=Object()            ;~菜单项对应图标对象
global MenuObjIconNoList:=Object()          ;~菜单项对应图标位置对象
global MenuExeArray:=Object()               ;~EXE程序对象数组
global MenuExeIconArray:=Object()           ;~EXE程序优先加载图标对象数组
global MenuObjTreeLevel:=Object()           ;~菜单对应级别
global MenuObjPublic:=[]                    ;~后缀公共菜单
global MenuShowFlag:=false                  ;~菜单功能是否可以显示
global MenuIconFlag:=false                  ;~菜单图标是否加载完成
global MenuObjName:=Object()                ;~程序菜单项名称
global MenuBar:=""                          ;~菜单分列标记
global MenuCount:=MENU2FLAG ? 2 : 1
global fileinfo
global fisize
VarSetCapacity(fileinfo, fisize := A_PtrSize + 688)
global sfi
global sfi_size
; 计算 SHFILEINFO 结构需要的缓存大小.
sfi_size := A_PtrSize + 8 + (A_IsUnicode ? 680 : 340)
VarSetCapacity(sfi, sfi_size)

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
;══════════════════════════════════════════════════════════════════
global NoPathFlag:=false                    ;是否拿到无路径搜索结果
global MenuObjEv:=Object()                  ;Everything搜索结果程序全路径
global MenuObjSame:=Object()                ;Everything搜索结果重名程序全路径
global MenuObjSearch:=Object()              ;Everything搜索无路径菜单项
global MenuObjCache:=Object()               ;Everything搜索无路径应用缓存
global MenuObjNew:=Object()                 ;Everything搜索新增加
global MenuObjEvPathEmptyReason:=Object()   ;Everything无路径应用搜索不到的原因
EvCommandStr:=""                            ;Everything搜索字符
;~;[14.获取无路径应用的运行全路径缓存]
if(EvDemandSearch){
	EvCommandStr:=EverythingNoPathSearchStr()
	Loop, parse, evFullPathIniVar, `n, `r
	{
		varList:=StrSplit(A_LoopField,"=",,2)
		outVarStr:=varList[1]
		objFileNameNoExeExt:=RegExReplace(outVarStr,"iS)\.exe$","")
		MenuObj[objFileNameNoExeExt]:=varList[2]
		MenuObjCache[outVarStr]:=varList[2]
		;检查缓存中的无路径应用被删除或移动
		if(Trim(varList[2]," `t`r`n")!="" && !FileExist(varList[2])){
			MenuObjCache[outVarStr]:=""  ;缓存失效则置空
			if(RegExMatch(outVarStr, RegexEscapeNoPointStr)){
				outVarStr:=StrListEscapeReplace(outVarStr, RegexEscapeNoPointList, "\")
			}
			outVarStr:=StrReplace(outVarStr,".","\.")
			MenuObjNew.push("^" outVarStr "$")
		}
		;无路径应用被删除自动清除对应的缓存
		if(!MenuObjSearch.HasKey(outVarStr)){
			IniDelete, %RunAnyEvFullPathIni%, FullPath, %outVarStr%
		}
	}
	;发现有新增的无路径菜单项
	if(Trim(evFullPathIniVar," `t`r`n")!=""){
		NoPathFlag:=true
		for k,v in MenuObjSearch
		{
			;发现有新的无路径应用
			if(!MenuObjCache.HasKey(k)){
				MenuObjCache[k]:=""
				if(RegExMatch(k, RegexEscapeNoPointStr)){
					k:=StrListEscapeReplace(k, RegexEscapeNoPointList, "\")
				}
				k:=StrReplace(k,".","\.")
				MenuObjNew.push("^" k "$")
			}else{
				MenuObjSearch[k]:=MenuObjCache[k]
			}
		}
		if(MenuObjNew.Length()>0){
			NoPathFlag:=false
			EvCommandStr:=StrListJoin("|",MenuObjNew)
			EvCommandStr:="regex:""" EvCommandStr """"
		}
	}
}
MenuObjEv:=MenuObj.Clone()
;~;[15.判断有无路径应用则需要使用Everything]
if(!NoPathFlag && !EvNo){
	if(!EvDemandSearch || (EvDemandSearch && EvCommandStr!="")){
		t3:=A_TickCount-StartTick
		if(EverythingIsRun()){
			Menu_Tray_Tip("","开始调用Everything搜索菜单内应用全路径...")
			RegRead,EvTotResults,HKEY_CURRENT_USER\SOFTWARE\RunAny,EvTotResults
			if(EvTotResults>0){
				EverythingQuery(EvCommandStr)
				NoPathFlag:=true
				for k,v in MenuObjSearch
				{
					IniWrite, %v%, %RunAnyEvFullPathIni%, FullPath, %k%
				}
			}else{
				Gosub,EverythingCheck
				Loop, 30
				{
					RegRead,EvTotResults,HKEY_CURRENT_USER\SOFTWARE\RunAny,EvTotResults
					if(EvTotResults>0){
						EverythingQuery(EvCommandStr)
						NoPathFlag:=true
						for k,v in MenuObjSearch
						{
							IniWrite, %v%, %RunAnyEvFullPathIni%, FullPath, %k%
						}
						break
					}
					Sleep, 100
				}
				RegRead,EvTotResults,HKEY_CURRENT_USER\SOFTWARE\RunAny,EvTotResults
				if(!EvTotResults){
					SetTimer,EverythingCheckResults,100
				}
			}
		}
	}
}
;══════════════════════════════════════════════════════════════════
t4:=A_TickCount-StartTick
t32:=t3-t2 ? Round((t3-t2)/1000,3) "+" : ""
Menu_Tray_Tip("调用Everything搜索应用全路径：" t32 Round((t4-t3)/1000,3) "s`n","开始加载完整菜单功能...")
Menu_Read(iniVar1,menuRoot1,"",1)
;~;[16.如果有第2菜单则开始加载]
if(MENU2FLAG){
	Menu_Tray_Tip("","开始创建菜单2内容...")
	Menu_Read(iniVar2,menuRoot2,"",2)
}
MenuShowFlag:=true
t5:=A_TickCount-StartTick
Menu_Tray_Tip("菜单创建：" Round((t5-t4)/1000,3) "s`n")
;~;[17.初始菜单加载后操作]
if(SendStrEcKey!="")
	SendStrDcKey:=SendStrDecrypt(SendStrEcKey,RunAnyZz ConfigDate)

t6:=t7:=A_TickCount-StartTick
;~;[18.规则启动程序]
if(RunCtrlListBoxVar!=""){
	Gosub,Rule_Effect
	t7:=A_TickCount-StartTick
	Menu_Tray_Tip("规则启动：" Round((t7-t6)/1000,3) "s`n")
}
;~;[19.对菜单内容项进行过滤调整]
Loop,%MenuCount%
{
	M_Index:=A_Index
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
					MenuObjTextRootFlag%M_Index%:=true
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
	;~;[20.最近运行项]
	if(RecentMax>0){
		For mci, mcItem in MenuCommonList
		{
			if(A_Index>RecentMax)
				break
			obj:=RegExReplace(mcItem,"^&\d+ ")
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
t8:=A_TickCount-StartTick
Menu_Tray_Tip("菜单加载：" Round((t8-t7)/1000,3) "s`n")

;~;[21.内部关联后缀打开方式]
Gosub,Open_Ext_Set
Menu_Tray_Tip("","菜单已经可以正常使用`n开始为菜单中exe程序加载图标...")
;~;[22.菜单中EXE程序加载图标，有ico图标更快]
; For k, v in MenuExeIconArray
; {
; 	if(DisableExeIcon){
; 		Menu_Item_Icon(v["menuName"],v["menuItem"],EXEIconS[1],EXEIconS[2])
; 	}else{
; 		Menu_Item_Icon(v["menuName"],v["menuItem"],v["itemFile"])
; 	}
; }
; For k, v in MenuExeArray
; {
; 	if(DisableExeIcon){
; 		Menu_Item_Icon(v["menuName"],v["menuItem"],EXEIconS[1],EXEIconS[2])
; 	}else{
; 		Menu_Item_Icon(v["menuName"],v["menuItem"],v["itemFile"])
; 	}
; }
;-------------------------------------------------------------------------------------------
;~;[23.菜单已经加载完毕，托盘图标变化]
t9:=A_TickCount-StartTick
Menu_Tray_Tip("菜单加载exe图标：" Round((t9-t8)/1000,3) "s`n","总加载时间：" Round(t9/1000,3) "s")
Menu,Tray,Icon,% AnyIconS[1],% AnyIconS[2]
MenuIconFlag:=true

;#如果是第一次运行#
if(iniFlag){
	iniFlag:=false
	TrayTip,,RunAny菜单初始化完成`n右击任务栏图标设置,5,1
	lb1:="Menu_About",lb2:="Menu_Show1"
	if(IsLabel(lb1) && IsLabel(lb2)){
		Gosub,%lb1%
		Gosub,%lb2%
	}
}
;~;[24.检查无路径应用缓存是否有新的版本]
if(NoPathFlag && !EvNo && Trim(evFullPathIniVar," `t`r`n")!="" && rule_check_is_run("Everything.exe")){
	Gosub,RunAEvFullPathSync
}
;~;[25.记录ini文件修改时间]
FileGetTime,MTimeIniPath, %iniPath%, M  ; 获取修改时间.
RegRead, MTimeIniPathReg, HKEY_CURRENT_USER\Software\RunAny, %iniPath%
RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\RunAny, %iniPath%, %MTimeIniPath%
IniChangeFlag:=MTimeIniPathReg=MTimeIniPath
if(MENU2FLAG){
	FileGetTime,MTimeIniPath2, %iniPath2%, M  ; 获取修改时间.
	RegRead, MTimeIniPath2Reg, HKEY_CURRENT_USER\Software\RunAny, %iniPath2%
	RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\RunAny, %iniPath2%, %MTimeIniPath2%
	IniChangeFlag:=IniChangeFlag && (MTimeIniPath2Reg=MTimeIniPath2)
}
if(rule_check_is_run(PluginsPathList["RunAny_SearchBar.ahk"]) 
		&& (!IniChangeFlag || !FileExist(RunAEvFullPathIniDirPath "\RunAnyMenuObj.ini") 
		|| !FileExist(RunAEvFullPathIniDirPath "\RunAnyMenuObjExt.ini") 
		|| !FileExist(RunAEvFullPathIniDirPath "\RunAnyMenuObjIcon.ini"))){
	Gosub,RunAny_SearchBar
	Run,% A_AhkPath A_Space """" PluginsPathList["RunAny_SearchBar.ahk"] """"
}
;如果有需要继续执行的操作
RegRead, ReloadGosub, HKEY_CURRENT_USER\Software\RunAny, ReloadGosub
if(ReloadGosub){
	RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\RunAny, ReloadGosub, 0
	Gosub,%ReloadGosub%
}
;提前加载菜单树图标缓存
global TreeImageListID := IL_Create(11)
Icon_Image_Set(TreeImageListID)
Icon_Tree_Image_Set(TreeImageListID)
;~;[26.自动备份配置文件]
if(RunABackupRule && RunABackupDirPath!=A_ScriptDir){
	RunABackupFormatStr:=Get_Transform_Val(RunABackupFormat)
	RunABackup(RunABackupDirPath "\", RunAnyZz ".ini*", iniVar1, iniPath, RunAnyZz ".ini" RunABackupFormatStr)
	RunABackup(RunABackupDirPath "\" RunAnyZz "2.ini\", RunAnyZz "2.ini*", iniVar2, iniPath2, RunAnyZz "2.ini" RunABackupFormatStr)
	FileRead, iniVarBak, %RunAnyConfig%
	RunABackup(RunABackupDirPath "\" RunAnyConfig "\", RunAnyConfig "*", iniVarBak, RunAnyConfig, RunAnyConfig RunABackupFormatStr)
}
if(AutoReloadMTime>0){
	SetTimer,AutoReloadMTime,%AutoReloadMTime%
}
;如果需要自动关闭everything
if(EvAutoClose && EvPathRun){
	Run,%EvPathRun% -exit
}
return

;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

;~;[菜单项过滤不同内容类型]
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
;[修改RunAny.ini文件自动重启]
AutoReloadMTime:
	RegRead, MTimeIniPathReg, HKEY_CURRENT_USER\Software\RunAny, %iniPath%
	FileGetTime,MTimeIniPath, %iniPath%, M  ; 获取修改时间.
	if(MTimeIniPathReg!=MTimeIniPath){
		Gosub,Menu_Reload
	}
	if(MENU2FLAG){
		RegRead, MTimeIniPath2Reg, HKEY_CURRENT_USER\Software\RunAny, %iniPath2%
		FileGetTime,MTimeIniPath2, %iniPath2%, M  ; 获取修改时间.
		if(MTimeIniPath2!=MTimeIniPath2Reg){
			Gosub,Menu_Reload
		}
	}
return
;[RunAny自动备份配置文件]
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
;~;[无路径应用缓存同步更新]
RunAEvFullPathSync:
	MenuObjUpdateList:=Object(),MenuObjEv:=Object(),MenuObjSearch:=Object()
	if(EverythingQuery(EvCommandStr)){
		for k,v in MenuObjCache
		{
			if(MenuObjSearch[k] && v!=MenuObjSearch[k]){
				IniWrite, % MenuObjSearch[k], %RunAnyEvFullPathIni%, FullPath, %k%
				MenuObjUpdateList.Push(k)
			}else if(MenuObjCache[k]="" && !MenuObjEvPathEmptyReason[k]){
				MenuObjEvPathEmptyReason[k]:="在EV中没有搜索到"
				RunAEvFullPathSyncFlag:=true
			}
		}
		if(MenuObjUpdateList.Length()>0){
			Gosub,RunAny_SearchBar
			ShowTrayTip("以下无路径应用缓存更新：",StrListJoin("、",MenuObjUpdateList),10,17)
			Gosub,Menu_Reload
		}
	}
return
;══════════════════════════════════════════════════════════════════
;~;【多种启动菜单热键】
#If MenuDoubleCtrlKey=1
Ctrl::Gosub,DoubleClickKey
#If
#If MenuDoubleAltKey=1
Alt::Gosub,DoubleClickKey
#If
#If MenuDoubleLWinKey=1
LWin::Gosub,DoubleClickKey
#If
#If MenuDoubleRWinKey=1
RWin::Gosub,DoubleClickKey
#If
#If MenuCtrlRightKey=1
~Ctrl & RButton::Gosub,Menu_Show1
#If
#If MenuShiftRightKey=1
~Shift & RButton::Gosub,Menu_Show1
#If
#If MenuXButton1Key=1
XButton1::Gosub,Menu_Show1
#If
#If MenuXButton2Key=1
XButton2::Gosub,Menu_Show1
#If
#If MenuMButtonKey=1 && !WinActive("ahk_group DisableGUI")
~MButton::Gosub,Menu_Show1
#If

DoubleClickKey:
	KeyWait,%A_ThisHotkey%
	KeyWait,%A_ThisHotkey%,d,t0.2
	if !Errorlevel
		Gosub,Menu_Show1
	else
		SendInput,{%A_ThisHotkey%}
	return
return
;══════════════════════════════════════════════════════════════════
;~;【——🏗创建菜单——】
;══════════════════════════════════════════════════════════════════
Menu_Read(iniReadVar,menuRootFn,TREE_TYPE,TREE_NO){
	MenuObjName:=Object()    ;~程序菜单项名称
	MenuBar:=""              ;~菜单分列标记
	MenuObjParam:=Object()   ;~程序参数
	menuLevel:=1
	Loop, parse, iniReadVar, `n, `r
	{
		try{
			Z_LoopField=%A_LoopField%
			if(InStr(Z_LoopField,";")=1 || Z_LoopField=""){
				continue
			}
			TREE_TYPE_FLAG:=(TREE_TYPE="" || TREE_TYPE="    ")
			;[生成节点树层级结构]
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
							}else if(RegExMatch(A_LoopField,"iS).+\.(exe|class)$")){
								global MenuObjWindowFlag:=true
								windowItem:=RegExReplace(A_LoopField,"iS)\.class$")
								if(!IsObject(MenuObjWindow[(windowItem)]))
									MenuObjWindow[(windowItem)]:=Object()
								MenuObjWindow[(windowItem)].Push(menuItem)
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
			if(itemMode!=2 && itemMode!=3 && itemMode!=8){
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
			flagEXE:=false      ;~添加exe菜单项目
			flagSys:=false      ;~添加系统项目文件
			IconFail:=false     ;~是否显示无效项图标
			;[生成有前缀备注的应用]
			if(InStr(Z_LoopField,"|")){
				menuDiy:=StrSplit(Z_LoopField,"|",,2)
				menuItemDiy:=menuDiy[1]
				appName:=RegExReplace(menuDiy[2],"iS)(.*?\.[a-zA-Z0-9-_]+)($| .*)","$1")	;去掉参数，取应用名
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
				appParm:=RegExReplace(menuDiy[2],"iS).*?\.[a-zA-Z0-9-_]+($| .*)","$1")	;去掉应用名，取参数
				itemParam:=menuDiy[2]
				itemFullPath:=Get_Obj_Path(menuDiy[2])
				if(appParm!=itemParam && itemParam!=itemFullPath . appParm){
					itemParam:=itemFullPath . appParm
				}
				MenuObj[menuItemDiy]:=itemParam
				Menu_Add(menuRootFn[menuLevel],menuItemDiy,itemFullPath,itemMode,TREE_NO)

				;[设置热键启动方式][不重复]
				if(TREE_TYPE_FLAG && InStr(menuDiy[1],"`t") && menuKeys[2]){
					MenuObj[menuKeys[1]]:=itemParam
					MenuObjKey[menuKeys[2]]:=itemParam
					MenuObjKeyName[menuKeys[2]]:=menuKeys[1]
					MenuObjKeyList[menuKeys[1]]:=menuKeys[2]
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
			;[生成完全路径的应用]
			; if(RegExMatch(Z_LoopField,"iS)^(\\\\|.:\\).*?\.exe($| .*)")){
			; 	appParm:=RegExReplace(Z_LoopField,"iS).*?\.exe($| .*)","$1")	;去掉应用名，取参数
			; 	Z_LoopField:=RegExReplace(Z_LoopField,"iS)(.*?\.exe)($| .*)","$1")
			; 	SplitPath,Z_LoopField,fileName,,,nameNotExt
			; 	menuAppName:=appParm!="" ? nameNotExt A_Space : nameNotExt
			; 	MenuObjParam[menuAppName]:=Z_LoopField . appParm
			; 	if(FileExist(Z_LoopField)){
			; 		MenuExeArrayPush(menuRootFn[menuLevel],menuAppName,Z_LoopField,Z_LoopField . appParm,TREE_NO)
			; 		flagEXE:=true
			; 	}else{
			; 		IconFail:=true
			; 	}
			; 	if(!HideFail)
			; 		flagEXE:=true
			; 	;添加菜单项
			; 	if(flagEXE){
			; 		Menu,% menuRootFn[menuLevel],add,% menuAppName,Menu_Run,%MenuBar%
			; 		if(IconFail){
			; 			Menu_Item_Icon(menuRootFn[menuLevel],menuAppName,"SHELL32.dll","124")
			; 		}
			; 	}else{
			; 		MenuObjTree_Delete_NoFind(MenuObjTree%TREE_NO%,menuRootFn[menuLevel],menuAppName)
			; 	}
			; 	MenuBar:=""
			; 	continue
			; }
			;[生成通过Everything取到的无路径应用]
			if(RegExMatch(Z_LoopField,"iS)\.exe($| .*)")){
				appParm:=RegExReplace(Z_LoopField,"iS).*?\.[a-zA-Z0-9-_]+($| .*)","$1")	;去掉应用名，取参数
				itemParam:=Z_LoopField
				itemFullPath:=Get_Obj_Path(Z_LoopField)
				if(appParm!=itemParam && itemParam!=itemFullPath . appParm){
					itemParam:=itemFullPath . appParm
				}
				Z_LoopField:=RegExReplace(Z_LoopField,"iS)(.*?\.exe)($| .*)","$1")
				appName:=RegExReplace(Z_LoopField,"iS)\.exe$")
				menuAppName:=appParm!="" ? appName A_Space A_Space : appName
				MenuObj[menuAppName]:=itemParam
				Menu_Add(menuRootFn[menuLevel],menuAppName,itemFullPath,itemMode,TREE_NO)

				; if(MenuObjEv[appName]){
				; 	flagEXE:=true
				; 	MenuObj[menuAppName]:=MenuObjEv[appName]
				; 	MenuObjParam[menuAppName]:=MenuObjEv[appName] . appParm
				; }else if(FileExist(A_WinDir "\" Z_LoopField) || FileExist(A_WinDir "\system32\" Z_LoopField)){
				; 	flagEXE:=true
				; 	MenuObj[menuAppName]:=Z_LoopField
				; 	MenuObjParam[menuAppName]:=Z_LoopField . appParm
				; }else if(!HideFail){
				; 	MenuObj[menuAppName]:=Z_LoopField
				; 	MenuObjParam[menuAppName]:=Z_LoopField . appParm
				; }
				; if(flagEXE){
				; 	MenuExeArrayPush(menuRootFn[menuLevel],menuAppName,MenuObj[menuAppName],MenuObj[menuAppName] . appParm,TREE_NO)
				; }else{
				; 	IconFail:=true
				; }
				; if(!HideFail)
				; 	flagEXE:=true
				; ;添加菜单项
				; if(flagEXE){
				; 	Menu,% menuRootFn[menuLevel],add,% menuAppName,Menu_Run,%MenuBar%
				; 	if(IconFail)
				; 		Menu_Item_Icon(menuRootFn[menuLevel],menuAppName,"SHELL32.dll","124")
				; }else{
				; 	MenuObjTree_Delete_NoFind(MenuObjTree%TREE_NO%,menuRootFn[menuLevel],menuAppName)
				; }
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
	Menu,% menuRootFn[1],add,
}
;[统一集合菜单中软件运行项]
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
;[读取热字串用作提示文字]
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
			;将获取到的热字符串中的变量进行转化，比如显示实时时间
			hotStrFixed:=RegExReplace(v["hotStrAny"],"S);+$")
			hotStrFlexible:=Get_Transform_Val(hotStrFixed)
			if(HotStrShowLen<=0){
				hotStrAny:=""
			}else if(StrLen(v["hotStrAny"])>HotStrShowLen){
				hotStrAny:="`t" SubStr(hotStrFlexible, 1, HotStrShowLen) . "..."
			}else{
				hotStrAny:="`t" hotStrFlexible
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
	WinWait,ahk_class tooltips_class32,,0
	WinSet, Transparent, % HotStrShowTransparent/100*255, ahk_class tooltips_class32
	SetTimer,RemoveToolTip,%HotStrShowTime%
return
;══════════════════════════════════════════════════════════════════
;~;【生成菜单项(判断后缀创建图标)】
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
			appPlugins:=RegExReplace(itemContent,"iS)(.+?)\[.+?\]%?\(.*?\)$","$1")	;取插件名
			if(PluginsIconList[appPlugins ".ahk"]){
				PluginsIconS:=StrSplit(Get_Transform_Val(PluginsIconList[appPlugins ".ahk"]),",")
				Menu_Item_Icon(menuName,menuItem,PluginsIconS[1],PluginsIconS[2])
			}else{
				Menu_Item_Icon(menuName,menuItem,FuncIconS[1],FuncIconS[2])
			}
			if(InStr(itemContent,"%getZz%")){
				MenuGetZzList%TREE_NO%[menuName].=menuItem "`n"	; 添加到GetZz搜索
			}
			return
		}
		if(itemMode=7 || itemMode=71){  ; {目录}
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
					MenuObjTree_Delete_NoFind(MenuObjTree%TREE_NO%,menuName,menuItem)
				}
			}
		}else{  ; {处理未知的项目图标}
			If(FileExist(itemContent) || FileExt=""){
				try{
					Menu_Item_Icon(menuName,menuItem,itemContent)
				}catch{}
			}else if(!HideFail){
				Menu_Item_Icon(menuName,menuItem,"SHELL32.dll","124")
			}else{
				Menu,%menuName%,Delete,%menuItem%
				MenuObjTree_Delete_NoFind(MenuObjTree%TREE_NO%,menuName,menuItem)
			}
		}
	} catch e {
		MsgBox,16,判断后缀创建菜单项出错,% "菜单名：" menuName "`n菜单项：" menuItem 
			. "`n路径：" itemContent "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
	}
}
MenuObjTree_Delete_NoFind(MenuObjTreeNum,menuName,menuItem){
	for i,v in MenuObjTreeNum[menuName]
	{
		if(menuItem=Get_Obj_Transform_Name(v)){
			MenuObjTreeNum[menuName].RemoveAt(i)
		}
	}
}
;[统一设置菜单项图标]
Menu_Item_Icon(menuName,menuItem,iconPath,iconNo=0,treeLevel=""){
	try{
		menuItemSet:=treeLevel ? treeLevel : menuItem
		menuItemSet:=RTrim(menuItemSet)
		menuItemSet:=menuItemIconFileName(menuItemSet)
		MenuObjName[menuItemSet]:=1
		if(IconFolderList[menuItemSet]){
			Menu,%menuName%,Icon,%menuItem%,% IconFolderList[menuItemSet],0,%MenuIconSize%
			MenuObjIconList[menuItem]:=IconFolderList[menuItemSet]
			MenuObjIconNoList[menuItem]:=0
			return
		}else if(!RegExMatch(iconPath,"S)^(\\\\|.:\\)") || !FileExist(iconPath)){
			Menu,%menuName%,Icon,%menuItem%,%iconPath%,%iconNo%,%MenuIconSize%
		}else{
			; 获取文件的图标.
			if DllCall("shell32\SHGetFileInfoW", "Wstr", iconPath
				, "UInt", 0, "Ptr", &fileinfo, "UInt", fisize, "UInt", 0x100)
			{
				hicon := NumGet(fileinfo, 0, "Ptr")
				; 设置菜单项的图标.
				Menu, %menuName%, Icon, %menuItem%, HICON:%hicon%, , %MenuIconSize%
				; 因为我们使用了 ":" 而不是 ":*", 在程序退出或菜单被删除时
				; 这些图标也会被自动释放
			}
			; Menu,%menuName%,Icon,%menuItem%,%iconPath%,%iconNo%,%MenuIconSize%
		}
		MenuObjIconList[menuItem]:=iconPath
		MenuObjIconNoList[menuItem]:=iconNo
	}catch{}
}
Menu_Tray_Show:
	if(GetKeyState("Ctrl") && GetKeyState("Shift")){
		Gosub,Menu_Config
		return
	}
	if(GetKeyState("Shift")){
		Gosub,Menu_Ini
		return
	}
	if(GetKeyState("Ctrl")){
		Open_Folder_Path(A_ScriptDir)
		return
	}
	Gosub,Menu_Show1
return
Menu_Show1:
	MENU_NO:=1
	iniFileShow:=iniPath
	Gosub,Menu_Show
return
Menu_Show2:
	MENU_NO:=2
	iniFileShow:=iniPath2
	Gosub,Menu_Show
return
Menu_NoGet_Show:
	MENU_NO:=1
	iniFileShow:=iniPath
	noGetZz:=true
	getZz:=""
	Gosub,Menu_Show
	noGetZz:=false
return
MenuShowTime:
	MenuShowTimeFlag:=true
	if(MenuShowFlag){
		SetTimer,MenuShowTime,Off
		Gosub,Menu_Show
	}
return
;══════════════════════════════════════════════════════════════════
;~;【——📺显示菜单——】
;══════════════════════════════════════════════════════════════════
Menu_Show:
	try{
		if(!MenuShowFlag && !MenuShowTimeFlag){
			SetTimer,MenuShowTime,10
			return
		}
		if(!extMenuHideFlag && !noGetZz)
			getZz:=Get_Zz()
		selectCheck:=Trim(getZz," `t`r`n")
		if(selectCheck=""){
			;#无选中内容
			;加载顺序：无Everything菜单 -> 无图标菜单 -> 有图标无路径识别菜单
			if(MenuIconFlag && MenuShowFlag){
				WinGet,pname,ProcessName,A
				WinGetClass,pclass,A
				ctrlgMenuItem:=Object()
				if(MenuObjWindowFlag && (MenuObjWindow[pclass])){
					ctrlgMenuName:=MenuObjWindow[pclass][1]
					;添加后缀公共菜单
					showPublicMenu:=Var_Read("ShowPublicMenu",1)
					publicMenuMaxNum:=MenuObjExt["public"].MaxIndex()
					if(showPublicMenu && publicMenuMaxNum>0){
						Loop {
							v:=MenuObjExt["public"][publicMenuMaxNum]
							vn:=RegExReplace(v,"S)^-+")
							Menu,%ctrlgMenuName%,Insert, 1&, %vn%, :%vn%
							Menu_Item_Icon(ctrlgMenuName,vn,TreeIconS[1],TreeIconS[2],v)
							publicMenuMaxNum--
						} Until % publicMenuMaxNum<1
						publicMaxNum:=MenuObjExt["public"].MaxIndex() + 1
						Menu,%ctrlgMenuName%,Insert, %publicMaxNum%&
					}
					Gosub,CtrlGQuickSwitch
					Menu_Show_Show(ctrlgMenuName,"")
					Loop,% ctrlgMenuItem.Count()
					{
						Menu,%ctrlgMenuName%,Delete,1&
					}
					;删除临时添加的菜单
					if(showPublicMenu && MenuObjExt["public"].MaxIndex()>0){
						Menu,%ctrlgMenuName%,Delete, %publicMaxNum%&
						for k,v in MenuObjExt["public"]
						{
							vn:=RegExReplace(v,"S)^-+")
							Menu,%ctrlgMenuName%,Delete,%vn%
						}
					}
				}else if(MenuObjWindowFlag && (MenuObjWindow[pname])){
					Menu_Show_Show(MenuObjWindow[pname][1],"")
				}else{
					if(pclass="#32770"){
						ctrlgMenuName:=menuDefaultRoot%MENU_NO%[1]
						Gosub,CtrlGQuickSwitch
					}
					Menu,% menuDefaultRoot%MENU_NO%[1],Show
					if(pclass="#32770"){
						Loop,% ctrlgMenuItem.Count()
						{
							Menu,%ctrlgMenuName%,Delete,1&
						}
					}
				}
			}else{
				try{
					Menu,% menuRoot%MENU_NO%[1],Show
				}catch e{
					TrayTip,RunAny菜单还没准备好，请稍后再试,% "错误信息：" e.extra "`n" e.message,10,3
				}
			}
			return
		}
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
						OutsideMenuItem:=Get_Obj_Transform_Name(itemContent)
						Gosub,Menu_Run
					}else{
						if(!HideAddItem){
							MenuObjTreeMaxSepNum:=MenuObjTree%MENU_NO%[extMenuName].MaxIndex() + 1
							Menu,%extMenuName%,Insert,
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
						Menu_Show_Show(extMenuName, FileName, Candy_isFile)
						;删除临时添加的菜单
						if(MenuObjExt["public"].MaxIndex()>0){
							Menu,%extMenuName%,Delete, %publicMaxNum%&
							for k,v in MenuObjExt["public"]
							{
								vn:=RegExReplace(v,"S)^-+")
								Menu,%extMenuName%,Delete,%vn%
							}
						}
						if(!HideAddItem){
							try Menu,%extMenuName%,Delete,%RUNANY_SELF_MENU_ITEM3%
							try Menu,%extMenuName%,Delete, %MenuObjTreeMaxSepNum%&
						}
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
					Menu_Show_Show(menuFileRoot%MENU_NO%[1], FileName, Candy_isFile)
					if(!HideAddItem){
						try Menu,% menuFileRoot%MENU_NO%[1],Delete, %RUNANY_SELF_MENU_ITEM3%
						Menu_Add_Del_Temp(0,MENU_NO,RUNANY_SELF_MENU_ITEM3)
					}
				}
			}catch e{
				menuName:=extMenuName!="" ? extMenuName : menuFileRoot%MENU_NO%[1]
				TrayTip,,% "[显示菜单]：" menuName "`n出错命令：" e.What 
					. "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message,10,3
				Menu_Show_Show(menuFileRoot%MENU_NO%[1], FileName, Candy_isFile)
			}
			return
		}
		getZz:=Get_Transform_Val(getZz)
		if(MENU_NO=1){
			openFlag:=false
			;~;[多行内容一键直达正则匹配]
			For name, regex in OneKeyRegexMultilineList
			{
				if(name !="一键公式计算" && !OneKeyDisableList[name] && OneKeyRunList[name] && RegExMatch(getZz, regex)){
					Remote_Dyna_Run(OneKeyRunList[name], getZz)
					openFlag:=true
					continue
				}
			}
			if(openFlag)
				return
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
				calcRegex:=OneKeyRegexList["一键公式计算"]
				if(calcRegex!="" && !OneKeyDisableList["一键公式计算"] && RegExMatch(S_LoopField,calcRegex)){
					formula:=S_LoopField
					if(RegExMatch(S_LoopField,"S)=$")){
						StringTrimRight, formula, formula, 1
					}
					calc:=js_eval(formula)
					selectResult.=A_LoopField
					if(RegExMatch(S_LoopField,"S)=$")){
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
				;一键直达动态正则匹配
				For name, regex in OneKeyRegexList
				{
					if(name !="一键公式计算" && !OneKeyDisableList[name] && regex!="" && OneKeyRunList[name] && RegExMatch(S_LoopField, regex)){
						if((name="一键打开目录" && !InStr(FileExist(S_LoopField), "D")) 
								|| (name="一键打开文件" && (!FileExist(S_LoopField) || InStr(FileExist(S_LoopField), "D")))){
							continue
						}
						Remote_Dyna_Run(OneKeyRunList[name], S_LoopField)
						openFlag:=true
						continue
					}
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
				Gosub,One_Search
				return
			}
		}
		showTheMenuName:=menuWebRoot%MENU_NO%[1]
		WinGet,pname,ProcessName,A
		;#选中文本弹出网址菜单#
		if(!MenuObjTextRootFlag%MENU_NO% && MenuObjText%MENU_NO%.MaxIndex()=1
				&& (!MenuObjWindowFlag || !MenuObjWindow[pname]
				|| (MenuObjWindowFlag && MenuObjWindow[pname].Length()=1 && MenuObjWindow[pname][1]=MenuObjText%MENU_NO%[1]))){
			;如果根目录没有%getZz%或%s且text菜单只有1个+没有软件专属菜单或与软件专属菜单相同，直接显示这个text菜单
			Menu_Show_Show(MenuObjText%MENU_NO%[1],getZz)
			return
		}
		if(MenuObjWindowFlag && MenuObjWindow[pname]){
			;添加自定义软件专属菜单
			publicMenuMaxNum:=MenuObjWindow[pname].MaxIndex()
			if(publicMenuMaxNum>0){
				Loop {
					menuObjTextStrs:=StrListJoin(",",MenuObjText%MENU_NO%)
					vn:=MenuObjWindow[pname][publicMenuMaxNum]
					v:=MenuObjTreeLevel[vn] . vn
					if vn in %menuObjTextStrs%
					{
						try Menu,% showTheMenuName,Delete,% vn "  "
					}
					Menu,% showTheMenuName,Insert, 1&, %vn%, :%vn%
					Menu_Item_Icon(showTheMenuName,vn,TreeIconS[1],TreeIconS[2],v)
					publicMenuMaxNum--
				} Until % publicMenuMaxNum<1
				publicMaxNum:=MenuObjWindow[pname].MaxIndex() + 1
				Menu,% showTheMenuName,Insert, %publicMaxNum%&
			}
		}
		Menu_Show_Show(showTheMenuName,getZz)
		;删除临时添加的菜单
		if(MenuObjWindowFlag && MenuObjWindow[pname]){
			Menu,% showTheMenuName,Delete, %publicMaxNum%&
			for k,v in MenuObjWindow[pname]
			{
				Menu,% showTheMenuName,Delete,%v%
			}
		}
	}catch e{
		TrayTip,,% "显示菜单出错：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message,10,3
	}
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
Menu_Show_Show(menuName, itemName, Candy_isFile:=0){
	selectCheck:=Trim(itemName," `t`r`n")
	if(!HideSelectZz && selectCheck!=""){
		if(StrLen(itemName)>ShowGetZzLen)
			itemName:=SubStr(itemName, 1, ShowGetZzLen) . "..."
		Menu,%menuName%,Insert, 1&,%itemName%,Menu_Show_Select_Clipboard
		Menu,%menuName%,ToggleCheck, 1&
		Menu,%menuName%,Insert, 2&
	}
	if(menuName!=menuDefaultRoot%MENU_NO%[1]){
		Menu,%menuName%,Insert, ,%RUNANY_SELF_MENU_ITEM4%,Menu_All_Show
		Menu,%menuName%,Icon,%RUNANY_SELF_MENU_ITEM4%,SHELL32.dll,40,%MenuIconSize%
	}
	;[显示菜单]
	Menu,%menuName%,Show
	if(!HideSelectZz && selectCheck!=""){
		Menu,%menuName%,Delete, 2&
		Menu,%menuName%,Delete,%itemName%
	}
	if(menuName!=menuDefaultRoot%MENU_NO%[1]){
		try Menu,%menuName%,Delete,%RUNANY_SELF_MENU_ITEM4%
	}
}
Menu_Show_Select_Clipboard:
	Clipboard:=Candy_Select
return
;[所有菜单(添加/删除)临时项]
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
CtrlGQuickSwitch:
	ctrlgMenuItemNum:=0
;---------------[ File Explorer ]----------------------------------------
	try{
		For $Exp in ComObjCreate("Shell.Application").Windows {
			try folder := $Exp.Document.Folder.Self.Path
			if(!folder || ctrlgMenuItem[folder]){
				Continue
			}
			ctrlgMenuItemAdd(ctrlgMenuName, ctrlgMenuItem, ctrlgMenuItemNum, folder, "shell32.dll", 5)
		}
		$Exp := ""
		if(ctrlgMenuItem.Count()>0){
			ctrlgMenuItem["-"]:=true
			Menu %ctrlgMenuName%, Insert,% ctrlgMenuItem.Count() "&"
		}
	}catch e{
		TrayTip,无法显示资源管理器当前目录：,% e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message,10,3
	}
;---------------[ Total Commander ]--------------------------------------
	tcIcon:=get_process_path("totalcmd.exe")
	tcIcon:=tcIcon ? tcIcon : get_process_path("TotalCMD64.exe")
	if(tcIcon){
		DetectHiddenWindows,On
		try{
			; Total Commander internal codes
			cm_CopySrcPathToClip  := 2029
			cm_CopyTrgPathToClip  := 2030
			ClipSaved := ClipboardAll
			Clipboard := ""
			SendMessage 1075, %cm_CopySrcPathToClip%, 0, , ahk_class TTOTAL_CMD
			folder:=RegExReplace(clipboard,"S)^\\\\(?!file)")
			If (ErrorLevel = 0 && folder && !ctrlgMenuItem[folder]) {
				ctrlgMenuItemAdd(ctrlgMenuName, ctrlgMenuItem, ctrlgMenuItemNum, folder, tcIcon)
			}
			SendMessage 1075, %cm_CopyTrgPathToClip%, 0, , ahk_class TTOTAL_CMD
			folder:=RegExReplace(clipboard,"S)^\\\\(?!file)")
			If (ErrorLevel = 0 && folder && !ctrlgMenuItem[folder]) {
				ctrlgMenuItemAdd(ctrlgMenuName, ctrlgMenuItem, ctrlgMenuItemNum, folder, tcIcon)
			}
			Clipboard := ClipSaved
			ClipSaved := ""
		}catch e{
			TrayTip,无法显示TC当前目录：,% e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message,10,3
		}
		DetectHiddenWindows,Off
	}
	WinGet, doIcon, ProcessPath,ahk_exe dopus.exe
	if(doIcon){
		try{
			ControlGetText,folder, Edit1,ahk_class dopus.lister
			If (folder && !ctrlgMenuItem[folder]) {
				ctrlgMenuItemAdd(ctrlgMenuName, ctrlgMenuItem, ctrlgMenuItemNum, folder, doIcon)
			}
			try ControlGetText,folder, Edit2,ahk_class dopus.lister
			If (folder && !ctrlgMenuItem[folder]) {
				ctrlgMenuItemAdd(ctrlgMenuName, ctrlgMenuItem, ctrlgMenuItemNum, folder, doIcon)
			}
		}catch e{
			TrayTip,,% "无法获取DO当前目录，不建议最小化到托盘：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message,10,3
		}
	}
	WinGet, xyIcon, ProcessPath,ahk_exe XYplorer.exe
	if(!xyIcon)
		WinGet, xyIcon, ProcessPath,ahk_exe XYplorerFree.exe
	if(xyIcon){
		try{
			SplitPath, xyIcon, xyName
			ControlGetText,folder,Edit18, ahk_exe %xyName%
			If (folder && !ctrlgMenuItem[folder]) {
				ctrlgMenuItemAdd(ctrlgMenuName, ctrlgMenuItem, ctrlgMenuItemNum, folder, xyIcon)
			}
		}catch e{
			TrayTip,,% "无法获取XYplorer当前目录，不建议最小化到托盘：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message,10,3
		}
	}
	if(tcIcon || doIcon || xyIcon){
		ctrlgMenuItem["--"]:=true
		Menu %ctrlgMenuName%, Insert,% ctrlgMenuItem.Count() "&"
	}
return
ctrlgMenuItemAdd(ByRef ctrlgMenuName,ByRef ctrlgMenuItem,ByRef ctrlgMenuItemNum,ByRef folder,menuIcon,menuIconNum:=1){
	Menu %ctrlgMenuName%, Insert,% ctrlgMenuItem.Count() + 1 "&",% "&" ++ctrlgMenuItemNum A_Space folder, Choice
	Menu %ctrlgMenuName%, Icon,% "&" ctrlgMenuItemNum A_Space folder, %menuIcon%, %menuIconNum%, %MenuIconSize%
	ctrlgMenuItem[folder]:=true
}

Choice:
	$FolderPath := RegExReplace(A_ThisMenuItem,"^&\d+ ","")
	Gosub FeedExplorerOpenSave
return
;_____________________________________________________________________________
;
FeedExplorerOpenSave:
;_____________________________________________________________________________
;    
	$WinID := WinExist("A")
	WinActivate, ahk_id %$WinID%
	if(RegExMatch($FolderPath,"S)^.:\\") || RegExMatch($FolderPath,"S)^\\\\file"))
		Gosub,FeedExplorerOpenSaveEdit1
	else
		Gosub,FeedExplorerOpenSaveEdit2
return
FeedExplorerOpenSaveEdit1:
	; Read the current text in the "File Name:" box (= $OldText)
	ControlGetText $OldText, Edit1
	ControlFocus Edit1
	; Go to Folder
	Loop, 5
	{
		ControlSetText, Edit1, %$FolderPath%		; set
		Sleep, 50
		ControlGetText, $CurControlText, Edit1		; check
		if ($CurControlText = $FolderPath)
			break
	}
	Sleep, 50
	ControlSend Edit1, {Enter}
	Sleep, 50
	; Insert original filename
	If !$OldText
		return
	Loop, 5
	{
		ControlSetText, Edit1, %$OldText%		; set
		Sleep, 50
		ControlGetText, $CurControlText, Edit1		; check
		if ($CurControlText = $OldText)
			break
	}
return
FeedExplorerOpenSaveEdit2:
	ControlFocus,Edit2
	ControlSend,Edit2,{f4}
	Sleep, 50
	ControlSetText,Edit2,%$FolderPath%
	Sleep, 50
	ControlSend,Edit2,{Enter}
return
;══════════════════════════════════════════════════════════════════
;~;【——🚀菜单运行——】
;══════════════════════════════════════════════════════════════════
Menu_Run:
	Z_ThisMenuItem:=A_ThisMenuItem
	any:=MenuObj[(Z_ThisMenuItem)]
	if(OutsideMenuItem!=""){
		any:=MenuObj[(OutsideMenuItem)]
		if(any=""){
			TrayTip,%OutsideMenuItem% 没有找到,请检查是否存在(在Everything能搜索到)，并重启RunAny重试,5,2
		}
		if(RunCtrlRunFlag)
			Z_ThisMenuItem:=OutsideMenuItem
		RunCtrlRunFlag:=OutsideMenuItem:=""
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
		R_ThisMenuItem:=RegExReplace(Z_ThisMenuItem,"^&\d+ ","")
		menuRunNameStr:="运行(&R) " Z_ThisMenuItem "," MENU_RUN_NAME_STR
		menuRunNameNoFileStr:="运行(&R) " Z_ThisMenuItem "," MENU_RUN_NAME_NOFILE_STR
		if R_ThisMenuItem in %menuRunNameStr%
		{
			M_ThisMenuItem:=R_ThisMenuItem
		}
		;[显示功能菜单]
		if(menuholdkey=HoldKeyRun5){
			Gosub,MenuRunMultifunctionMenu
			if(M_ThisMenuItem="")
				return
		}
		;[编辑菜单项]
		if(menuholdkey=HoldKeyRun3 || M_ThisMenuItem="编辑(&E)"){
			TVEditItem:=Z_ThisMenuItem
			TVEditItem:=RegExReplace(TVEditItem,"重名$")
			Gosub,Menu_Edit%MENU_NO%
			return
		}
		;[复制或输出菜单项内容]
		if(menuholdkey=HoldKeyRun31 || M_ThisMenuItem="复制运行路径(&C)"){
			Send_Or_Show(fullPath,false,HoldKeyShowTime)
			return
		}else if(menuholdkey=HoldKeyRun32 || M_ThisMenuItem="输出运行路径(&V)"){
			Send_Or_Show(fullPath,true,HoldKeyShowTime)
			return
		}else if(menuholdkey=HoldKeyRun33 || M_ThisMenuItem="复制软件名(&N)"){
			Send_Or_Show(name_no_ext,false,HoldKeyShowTime)
			return
		}else if(menuholdkey=HoldKeyRun34 || M_ThisMenuItem="输出软件名(&M)"){
			Send_Or_Show(name_no_ext,true,HoldKeyShowTime)
			return
		}else if(menuholdkey=HoldKeyRun35 || M_ThisMenuItem="复制软件名+后缀(&F)"){
			Send_Or_Show(name,false,HoldKeyShowTime)
			return
		}else if(menuholdkey=HoldKeyRun36 || M_ThisMenuItem="输出软件名+后缀(&G)"){
			Send_Or_Show(name,true,HoldKeyShowTime)
			return
		}
		;[结束软件进程]
		if((menuholdkey=HoldKeyRun4 || M_ThisMenuItem="结束软件进程(&X)" || RunCtrlRunWayVal=6) && (itemMode=1 || itemMode=60)){
			Run,% ComSpec " /C taskkill /f /im """ name """", , Hide
			RunCtrlRunWayVal=
			return
		}
		if(RecentMax>0 && !NoRecentFlag && !RegExMatch(Z_ThisMenuItem,"S)^&\d+")){
			Gosub,Menu_Recent
		}
		NoRecentFlag:=false
		;[根据菜单项模式运行]
		returnFlag:=false
		Gosub,Menu_Run_Mode_Label
		if(returnFlag)
			return
		;[解析选中变量%getZz%]
		getZzFlag:=InStr(any,"%getZz%") ? true : false
		if(getZzFlag && InStr(getZz,A_Space) && !InStr(any,"""%getZz%""")){
			;如果选中变量中有空格，自动包上双引号
			any:=StrReplace(any,"%getZz%","""%getZz%""")
		}
		any:=Get_Transform_Val(any)
		any:=RTrim(any," `t`r`n")
		anyRun:=""
		if(getZz="" && !Candy_isFile){
			;[打开应用所在目录，只有目录则直接打开]
			if(menuholdkey=HoldKeyRun2 || M_ThisMenuItem="软件目录(&D)" || InStr(FileExist(any), "D")){
				WinGetClass,pclass,A
				if(pclass="#32770"){  ;打开/另存为窗口 变为跳转目录
					$FolderPath:=any
					if(RegExMatch(any,"iS).*?\.exe$")){
						SplitPath, any,, dir
						$FolderPath:=dir
					}
					Gosub,FeedExplorerOpenSave
					return
				}
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
		;判断软件运行方式
		Gosub,MenuRunWay
		;[带选中内容运行]
		if(getZz!="" && (getZzFlag || AutoGetZz)){
			firstFile:=RegExReplace(getZz,"S)(.*)(\n|\r).*","$1")  ;取第一行
			if(Candy_isFile=1 || FileExist(getZz) || FileExist(firstFile)){
				getZzStr:=""
				Loop, parse, getZz, `n, `r, %A_Space%%A_Tab%
				{
					if(!A_LoopField)
						continue
					getZzStr.="""" . A_LoopField . """" . A_Space
				}
				StringTrimRight, getZzStr, getZzStr, 1
				if(getZzFlag || InStr(FileExist(any), "D")){
					Run_Any(any,, way)
				}else{
					Run_Any(any . A_Space . getZzStr,, way)
				}
				if(topFlag || menuTransNum<100){
					Run_Wait(any, topFlag, menuTransNum)
				}
				return
			}
			if(getZzFlag){
				anyRun=%anyRun%%any%
			}else{
				anyRun=%anyRun%%any%%A_Space%%getZz%
			}
			Run_Any(anyRun,, way)
			if(topFlag || menuTransNum<100){
				Run_Wait(any, topFlag, menuTransNum)
			}
			return
		}
		Gosub, MenuRunAny
	} catch e {
		MsgBox,20,%Z_ThisMenuItem%运行出错,% "运行路径：" any "`n出错命令：" e.What 
			. "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message "`n`n是否在命令行中运行测试？"
		IfMsgBox Yes, {
			Run,%ComSpec% /k "echo 【运行命令:】start "" %any% & echo. & start "" %any%"
		}
	}finally{
		SetWorkingDir,%A_ScriptDir%
	}
return
;[软件运行方式]
MenuRunWay:
	menuKeys:=StrSplit(Z_ThisMenuItem,"`t")
	thisMenuName:=menuKeys[1]
	;[管理员身份运行]
	if((!RunCtrlRunFlag && (menuholdkey=HoldKeyRun11 || M_ThisMenuItem="管理员权限运行(&A)")) || RunCtrlAdminRunVal){
		anyRun.="*RunAs "
	}
	;[最小化、最大化、隐藏运行方式]
	if((!RunCtrlRunFlag && (menuholdkey=HoldKeyRun12 || M_ThisMenuItem="最小化运行(&I)")) || RunCtrlRunWayVal=3){
		way:="Min"
	}else if((!RunCtrlRunFlag && (menuholdkey=HoldKeyRun13 || M_ThisMenuItem="最大化运行(&P)")) || RunCtrlRunWayVal=4){
		way:="Max"
	}else if((!RunCtrlRunFlag && (menuholdkey=HoldKeyRun14 || M_ThisMenuItem="隐藏运行(&H)")) || RunCtrlRunWayVal=5){
		way:="Hide"
	}else{
		way:=""
	}
	;[透明运行方式]
	menuTransNum:=100
	if(thisMenuName && RegExMatch(thisMenuName,"S).*?_:(\d{1,2})$")){
		menuTransNum:=RegExReplace(thisMenuName,"S).*?_:(\d{1,2})$","$1")
	}else if(RegExMatch(M_ThisMenuItem,"S)^透明运行:&\d{1,2}%")){
		menuTransNum:=RegExReplace(M_ThisMenuItem,"S)^透明运行:&(\d{1,2})%$","$1")
	}
	;[置顶运行方式]
	topFlag:=false
	if((!RunCtrlRunFlag && M_ThisMenuItem="置顶运行(&T)") || RunCtrlRunWayVal=2){
		topFlag:=true
	}
	RunCtrlAdminRunVal:=false
	RunCtrlRunWayVal:=1
return
MenuRunAny:
	if(ext && openExtRunList[ext]){
		Run_Any(openExtRunList[ext] . A_Space . """" any """",, way)
	}else{
		Run_Any(anyRun . any,, way)
	}
	;运行后进行置顶或透明操作
	if(topFlag || menuTransNum<100){
		Run_Wait(any, topFlag, menuTransNum)
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
			Menu_Item_Icon("menuRunTransSub",menuRunTransSubItem,MenuObjIconList[Z_ThisMenuItem],MenuObjIconNoList[Z_ThisMenuItem])
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
		Menu_Item_Icon("menuRun",A_LoopField,MenuObjIconList[Z_ThisMenuItem],MenuObjIconNoList[Z_ThisMenuItem])
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
	Gosub,Menu_Key_Run_Run
return
Menu_Key_NoGet_Run:
	getZz:=""
	Gosub,Menu_Key_Run_Run
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
		Gosub,Menu_Run_Mode_Label
		if(returnFlag)
			return
		
		;[解析选中变量%getZz%]
		getZzFlag:=InStr(any,"%getZz%") ? true : false
		if(getZzFlag && InStr(getZz,A_Space) && !InStr(any,"""%getZz%""")){
			;如果选中变量中有空格，自动包上双引号
			any:=StrReplace(any,"%getZz%","""%getZz%""")
		}
		any:=Get_Transform_Val(any)
		any:=RTrim(any," `t`r`n")
		;[打开文件夹]
		if(itemMode=7 && InStr(FileExist(any), "D")){
			WinGetClass,pclass,A
			if(pclass="#32770"){  ;打开/另存为窗口 变为跳转目录
				$FolderPath:=any
				Gosub,FeedExplorerOpenSave
			}else{
				Open_Folder_Path(any)
			}
			return
		}
		;[透明运行模式]
		menuTransNum:=100
		if(thisMenuName && RegExMatch(thisMenuName,"S).*?_:(\d{1,2})$")){
			menuTransNum:=RegExReplace(thisMenuName,"S).*?_:(\d{1,2})$","$1")
		}
		if(getZz!="" && (getZzFlag || AutoGetZz)){
			firstFile:=RegExReplace(getZz,"S)(.*)(\n|\r).*","$1")  ;取第一行
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
			Run_Wait(any, false, menuTransNum)
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
		Gosub,Menu_Run_Send_Zz  ;[输出热键]
		returnFlag:=true
	}else if(itemMode=5){
		Gosub,Menu_Run_Send_Ahk_Zz  ;[输出AHK热键]
		returnFlag:=true
	}else if(itemMode=8){
		Gosub,Menu_Run_Plugins_ObjReg  ;{脚本插件函数}
		returnFlag:=true
	}else if(itemMode=60){
		Gosub,Menu_Run_Exe_Url  ;指定浏览器打开网页
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
Run_Any(any,dir:="",way:=""){
	Menu_Debug_Mode("[运行路径]`n" any "`n")
	if(MenuIconFlag){
		Menu_Run_Tray_Tip(any "`n")
	}
	if(dir!="" || way!=""){
		Run,%any%,%dir%,%way%
	}else{
		Run,%any%
	}
}
Run_Zz(program){
	fullPath:=Get_Obj_Path(program)
	exePath:=fullPath ? fullPath : program
	SplitPath, exePath, exeName
	exeName:=exeName ? exeName : exePath
	DetectHiddenWindows, Off
	If(!WinExist("ahk_exe" . exeName)){
		Run_Any(program)
		return true
	}else{
		WinGet,l,List,ahk_exe %exeName%
		if(l=1)
			If WinActive("ahk_exe" . exeName)
				WinMinimize
			else
				WinActivate
		else
			WinActivateBottom,ahk_exe %exeName%
		return false
	}
}
Run_Wait(program,topFlag:=false,transRatio=100,winSizeRatio=100,winSize=0){
	fullPath:=Get_Obj_Path(program)
	exePath:=fullPath ? fullPath : program
	transRatio:=transRatio<0 ? 0 : transRatio
	DetectHiddenWindows, Off
	if(fExt="lnk"){
		FileGetShortcut,%exePath%,lnkexePath
		SplitPath, lnkexePath, fName,, fExt
		if(fExt="exe")
			exePath:=lnkexePath
	}
	SplitPath, exePath, fName,, fExt  ; 获取应用名
	WinWait,ahk_exe %fName%,,3
	if ErrorLevel
		return
	if(topFlag){
		if(WinActive("ahk_class CabinetWClass")){
			WinSet,AlwaysOnTop,On,ahk_class CabinetWClass
		}else{
			WinSet,AlwaysOnTop,On,ahk_exe %fName%
		}
	}
	if(transRatio<100){
		try WinSet,Transparent,% transRatio/100*255,ahk_exe %fName%
	}
}
;~;【🧩脚本插件函数运行】
Menu_Run_Plugins_ObjReg:
	appPlugins:=RegExReplace(any,"iS)(.+?)\[.+?\]%?\(.*?\)$","$1")	;取插件名
	appFunc:=RegExReplace(any,"iS).+?\[(.+?)\]%?\(.*?\)$","$1")	;取函数名
	appParmStr:=RegExReplace(any,"iS).+?\[.+?\]%?\((.*?)\)$","$1")	;取函数参数
	appParmErrorStr:=(appParmStr="") ? "空" : appParmStr
	if(!PluginsObjRegGUID[appPlugins] && appPlugins!="runany"){
		ToolTip,❎`n脚本插件：%appPlugins%`n脚本函数：%appFunc%`n函数参数：%appParmErrorStr%`n插件%appPlugins%没有找到！`n【请检查修改后重启RunAny重试】
		SetTimer,RemoveToolTip,8000
		return
	}
	if(RegExMatch(any,"iS).+?\[.+?\]%\(.*?\)")){  ;动态函数执行
		DynaExpr_ObjRegisterActive(PluginsObjRegGUID[appPlugins],appFunc,appParmStr,getZz)
	}else{
		if(appPlugins!="runany"){
			try {
				PluginsObjRegActive[appPlugins]:=ComObjActive(PluginsObjRegGUID[appPlugins])
			} catch e{
				TrayTip,%appPlugins% 外接脚本失败,请检查是否已经启动(在插件管理中设为自动启动)，并重启RunAny重试,5,2
			}
		}else if(!IsFunc(appFunc)){
			TrayTip,,没有在%appPlugins%.ahk中找到%appFunc%函数,5,2
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
		if(appPlugins="runany"){
			if(appParmStr=""){
				Send_Or_Show(Func(appFunc).Call(),false)
			}else if(appParms.MaxIndex()>=1 && appParms.MaxIndex()<=10){
				Send_Or_Show(Func(appFunc).Call(appParms*),false)
			}else if(appParms.MaxIndex()>10){
				ToolTip,❎`n脚本函数：%appFunc%`n函数参数：%appParmErrorStr% 参数数量最多为10个，请修改后重试！
				SetTimer,RemoveToolTip,8000
			}
			return
		}
		PluginsObjRegRun(appPlugins, appFunc, appParms)
	}
	if(!InStr(PluginsContentList[(appPlugins ".ahk")],appFunc "(")){
		ToolTip,❎`n脚本插件：%appPlugins%`n脚本函数：%appFunc%`n函数参数：%appParmErrorStr%`n
		(
函数%appFunc%没有找到！`n【请检查插件脚本是否已更新版本，或修改错误后重启RunAny重试】
		)
		SetTimer,RemoveToolTip,8000
	}
return
PluginsObjRegRun(appPlugins, appFunc, appParms){
	if(appParms.Length()=0){	;没有传参，直接执行函数
		effectResult:=PluginsObjRegActive[appPlugins][appFunc]()
	}else if(appParms.MaxIndex()>=1 && appParms.MaxIndex()<=10){
		effectResult:=PluginsObjRegActive[appPlugins][appFunc](appParms*)
	}else if(appParms.MaxIndex()>10){
		ToolTip,❎`n脚本插件：%appPlugins%`n脚本函数：%appFunc%`n函数参数：%appParmErrorStr% 参数数量最多为10个，请修改后重试！
		SetTimer,RemoveToolTip,8000
	}
	return effectResult
}
;~;【🕒菜单最近运行】
Menu_Recent:
	recentAny:=any
	regMenuItem:=A_ThisMenuItem
	;正则转义特殊字符
	regMenuItem:=StrListEscapeReplace(regMenuItem, RegexEscapeList, "\")
	Loop,% MenuCommonList.MaxIndex()
	{
		if(RegExMatch(MenuCommonList[A_Index],"S)^&\d+\s" regMenuItem)){
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
	if(regMenuItem="")
		return
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
					MenuCommonNewList[A_Index]:=RegExReplace(MenuCommonList[A_Index],"^&\d+","&" A_Index)  ;修改序号
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
	RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\RunAny, MenuCommonList, %commonStr%
return
;══════════════════════════════════════════════════════════════════
;~;【🔍一键搜索】
One_Show:
	getZz:=Get_Zz()
	Gosub,One_Search
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
Run_Search(anyUrl, getZz="", browser=""){
	any:=Get_Transform_Val(anyUrl)
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
	}else if(AutoGetZz && any=anyUrl){  ;网址中没有变量则在末尾添加选中文字
		Run,%browserRun%"%any%%getZz%"
	}else{
		Run,%browserRun%"%any%"
	}
}
Web_Run:
	webName:=RegExReplace(A_ThisMenuItem,"iS)^" RUNANY_SELF_MENU_ITEM1)
	if(webName){
		webList:=(A_ThisHotkey=MenuHotKey2) ? menuWebList2[(webName)] : menuWebList1[(webName)]
	}else{
		webList:=(A_ThisHotkey=MenuHotKey2) ? menuWebList2[(menuRoot2[1])] : menuWebList1[(menuRoot1[1])]
	}
	if(JumpSearch){
		Gosub,Web_Search
	}else{
		MsgBox,33,开始批量搜索%webName%,确定用【%getZz%】批量搜索以下网站：`n%webList%
		IfMsgBox Ok
		{
			Gosub,Web_Search
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
;~;[🔎一键Everything][搜索选中文字][激活][隐藏]
Ev_Show:
	getZz:=Get_Zz()
	EverythingIsRun()
	evSearch:=EvShowFolderSpace:=""
	if(Trim(getZz," `t`r`n")!=""){
		getZzLength:=StrSplit(getZz,"`n").Length()
		Loop, parse, getZz, `n, `r
		{
			S_LoopField=%A_LoopField%
			if(EvShowFolder && (InStr(FileExist(S_LoopField), "D") || RegExMatch(S_LoopField,"S).*\\$"))){
				EvShowFolderSpace:=A_Space
			}else if(RegExMatch(S_LoopField,"S)^(\\\\|.:\\).*?$")){
				SplitPath,S_LoopField,fileName,,,name_no_ext
				S_LoopField:=EvShowExt ? fileName : name_no_ext
			}
			if(InStr(S_LoopField,A_Space) && getZzLength>1){
				S_LoopField="""%S_LoopField%"""
			}
			evSearch.=S_LoopField "|"
		}
		evSearch:=SubStr(evSearch, 1, -StrLen("|"))
	}
	DetectHiddenWindows,On
	IfWinExist ahk_class EVERYTHING
		if evSearch
			Run % EvPathRun " -search """ evSearch EvShowFolderSpace """"
		else
			IfWinNotActive
				WinActivate
			else
				WinMinimize
	else
		Run % EvPathRun (evSearch ? " -search """ evSearch EvShowFolderSpace """" : "")
	DetectHiddenWindows,Off
return
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
;~;【══🧰通用函数方法══】
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
;[创建文件夹]
CreateDir(dir){
	if(!InStr(FileExist(dir), "D"))
		FileCreateDir, %dir%
}
;[删除已有文件]
DeleteFile(filePath){
	if(FileExist(filePath))
		FileDelete, %filePath%
}
;[检查后缀名]
Ext_Check(name,len,ext){
	len_ext:=StrLen(ext)
	site:=InStr(name,ext,,0,1)
	return site!=0 && site=len-len_ext+1
}
;[输出结果还是仅显示保存到剪贴板]
Send_Or_Show(textResult,isSend:=false,sTime:=1000){
	textResult:=RegExReplace(textResult,"`r`n$")
	if(textResult="")
		return
	if(isSend){
		Send_Str_Zz(textResult)
		return
	}
	Clipboard:=textResult
	ToolTip,%textResult%
	SetTimer,RemoveToolTip,%sTime%
}
;[粘贴输出短语]
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
;[键盘输出短语]
Send_Str_Input_Zz(strZz,tf=false){
	if(tf){
		strZz:=Get_Transform_Val(strZz)
	}
	SendInput,{Text}%strZz%
}
;[输出热键]
Send_Key_Zz(keyZz,keyLevel=0){
	if(keyLevel=1)
		SendLevel,1
	SendInput,%keyZz%
	if(keyLevel=1)
		SendLevel,0
}
;[获取选中]
Get_Zz(copyKey:="^c"){
	global Candy_isFile
	global Candy_Select
	Candy_isFile:=0
	try Candy_Saved:=ClipboardAll
	Clipboard=
	if(GetZzCopyKey!="" && GetZzCopyKeyApp!="" && WinActive("ahk_group GetZzCopyKeyAppGUI"))
		copyKey:=GetZzCopyKey
	SendInput,%copyKey%
	if(ClipWaitTime != 0.1) && WinActive("ahk_group ClipWaitGUI"){
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
;[拼接字符Zz]
StrJoin(sep, params*) {
	str:=""
	for index,param in params
	{
		if(param!="")
			str.= param . sep
	}
	return SubStr(str, 1, -StrLen(sep))
}
;[数组拼接字符Zz]
StrListJoin(sep, paramList, join:=":"){
	str:=""
	for index,param in paramList
	{
		if(paramList.HasKey(1)){
			str.= param . sep
		}else{
			str.= index join param . sep
		}
	}
    return SubStr(str, 1, -StrLen(sep))
}
;[批量替换字符]
StrListBatchReplace(paramList, regExStr, replaceStr:=""){
	strObj:=Object()
	for index,searchStr in paramList
	{
		strObj.Push(RegExReplace(searchStr, regExStr, replaceStr))
	}
	return strObj
}
;[批量替换数组字符]
StrListEscapeReplace(str, paramList, replaceStr:="\"){
	For k, v in paramList
	{
		str:=StrReplace(str, v, replaceStr v)
	}
	return str
}
;[反向获取val对应的key]
GetKeyByVal(obj, val){
	for k,v in obj
	{
		if(val=v)
			return k
	}
}
;[获取变量展开转换后的值]
Get_Transform_Val(string){
	try{
		if(InStr(string,"%getZz%")){
			string:=StrReplace(string, "%getZz%", getZz)
		}
		if(InStr(string,"%Clipboard%") || InStr(string,"%ClipboardAll%")){
			string:=StrReplace(string, "%Clipboard%", Clipboard)
			string:=StrReplace(string, "%ClipboardAll%", ClipboardAll)
		}
		For mVarName, mVarVal in MenuVarIniList
		{
			if(InStr(string,"%" mVarName "%"))
				string:=StrReplace(string, "%" mVarName "%", mVarVal)
		}
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
;变量布尔值反转
Variable_Boolean_Reverse(vars*){
	global
	for i,v in vars
	{
		%v%:=!%v%
	}
}
;时间格式转换
time_format(t, f:="yyyy-MM-dd HH:mm:ss"){
	FormatTime, timeVar, %t%, %f%
	return t!="" ? timeVar : ""
}
;获取运行进程的路径
get_process_path(process){
	DetectHiddenWindows,On
	WinGet, processPath, ProcessPath,ahk_exe %process%
	DetectHiddenWindows,Off
	return processPath
}
;~;[电脑开机后的运行时长(秒)-规则]
rule_boot_time(){
	return A_TickCount/1000
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
	DetectHiddenWindows,On
	result:=false
	runValue:=RegExReplace(runNamePath,"iS)(.*?\.exe)($| .*)","$1")	;去掉参数
	SplitPath, runValue, name,, ext  ; 获取扩展名
	if(ext="ahk"){
		if(InStr(runNamePath,"..\")=1){
			runNamePath:=IsFunc("funcPath2AbsoluteZz") ? Func("funcPath2AbsoluteZz").Call(runNamePath,A_ScriptFullPath) : runNamePath
		}
		if WinExist(runNamePath " ahk_class AutoHotkey")
		{
			result:=true
		}
	}else if(name){
		Process,Exist,%name%
		if ErrorLevel
			result:=true
	}
	DetectHiddenWindows,Off
	return result
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
;~;[接收其他脚本的消息]
Receive_WM_COPYDATA(wParam, lParam)
{
    StringAddress := NumGet(lParam + 2*A_PtrSize)  ; 获取 CopyDataStruct 的 lpData 成员.
    CopyOfData := StrGet(StringAddress)  ; 从结构中复制字符串.
	Remote_Dyna_Run(CopyOfData, "", true)
    return true  ; 返回 1(true) 是回复此消息的传统方式.
}
;[系统关机或重启前操作]
WM_QUERYENDSESSION(wParam, lParam)
{
    ENDSESSION_LOGOFF = 0x80000000
	RegWrite,REG_SZ,HKEY_CURRENT_USER\SOFTWARE\RunAny,RunAnyTickCount,%A_TickCount%
    if (lParam & ENDSESSION_LOGOFF)  ; 用户正在注销.
        EventType = Logoff
    else  ; 系统正在关机或重启.
        EventType = Shutdown
}
;[脚本退出或重启前操作]
ExitFunc(ExitReason, ExitCode)
{
	RegWrite,REG_SZ,HKEY_CURRENT_USER\SOFTWARE\RunAny,RunAnyTickCount,%A_TickCount%
	Gosub,AutoClose_Plugins
    ; 不要调用 ExitApp -- 那会阻止其他 OnExit 函数被调用.
}
;[动态执行脚本注册对象]
DynaExpr_ObjRegisterActive(GUID,appFunc,appParms:="",getZz:="")
{
	sScript:="
	(
		#NoTrayIcon
		getZz = " getZz "
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
		getZz = " getZz "
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
donothing:
return
;══════════════════════════════════════════════════════════════════
;~;【══🔩内部函数方法══】
;══════════════════════════════════════════════════════════════════
;[写入配置]
Var_Set(vGui, var, sz){
	StringCaseSense, On
	if(vGui!=var){
		if(vGui=""){
			IniDelete,%RunAnyConfig%,Config,%sz%
		}else{
			IniWrite,%vGui%,%RunAnyConfig%,Config,%sz%
		}
	}
	StringCaseSense, Off
}
;[读取配置]
Var_Read(rValue,defVar=""){
	IniRead, regVar,%RunAnyConfig%, Config, %rValue%,% defVar ? defVar : A_Space
	if(regVar!=""){
		if(defVar!="" && regVar=defVar){
			IniDelete, %RunAnyConfig%, Config, %rValue%
		}
		if(InStr(regVar,"ZzIcon.dll") && !FileExist(A_ScriptDir "\ZzIcon.dll"))
			return defVar
		else
			return regVar
	}else{
		IniDelete, %RunAnyConfig%, Config, %rValue%
		return defVar
	}
}
;[控制提示信息的显示时长]
RemoveToolTip:
	if(A_TimeIdle<2500){
		SetTimer,RemoveToolTip,Off
		ToolTip
	}
return
RemoveDebugModeToolTip:
	SetTimer,RemoveDebugModeToolTip,Off
	DebugModeShowText:=""
	DebugModeShowTextLen:=0
	ToolTip
return
HideTrayTip(){
    TrayTip
}
;[临时脚本显示提示信息，不受主脚本重启影响]
ShowTrayTip(title,text,seconds,options){
	DeleteFile(A_Temp "\" RunAnyZz "\RunAnyTrayTip.ahk")
	FileAppend,
	(
#NoEnv
Menu,Tray,Icon,SHELL32.dll,50
TrayTip, %title%, %text%, %seconds%, %options%
Sleep,10000
ExitApp
	),%A_Temp%\%RunAnyZz%\RunAnyTrayTip.ahk
	Run,%A_AhkPath%%A_Space%"%A_Temp%\%RunAnyZz%\RunAnyTrayTip.ahk"
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
		if(RegExMatch(item,"S)^-+$") || RegExMatch(item,"S)^\|+$"))
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
	if((RegExMatch(item,"S)^.:\\.*") && InStr(FileExist(item), "D")))
		return 7
	if(RegExMatch(item,"S)^\\.*"))
		return 71
	return 1
}
;[获取分类名称]
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
;[获取应用名称]
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
;[获取应用路径]
Get_Obj_Path(z_item,fullItemFlag:=false){
	obj_path:=""
	if(fullItemFlag && InStr(z_item,"|")){
		menuDiy:=StrSplit(z_item,"|",,2)
		z_item:=MenuObj[menuDiy[1]]
		z_item:=z_item!="" ? z_item : menuDiy[2]
	}
	z_item:=RegExReplace(z_item,"iS)(.*?\.[a-zA-Z0-9-_]+)($| .*)","$1")	;去掉参数，取路径
	if(RegExMatch(z_item,"iS)^(\\\\|.:\\).*?\.exe$")){
		obj_path:=z_item
	}else{
		appName:=RegExReplace(z_item,"iS)\.exe$")
		obj_path:=MenuObj[appName]="" ? z_item : MenuObj[appName]
	}
	if(obj_path=""){
		obj_path:=z_item
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
;[获取变量转换后的应用路径]
Get_Obj_Path_Transform(z_item){
	if(z_item="")
		return z_item
	itemPath:=Get_Transform_Val(z_item) ; 变量转换
	objPathItem:=Get_Obj_Path(itemPath) ; 自动添加完整路径
	if(objPathItem && itemPath!=objPathItem){
		appParm:=RegExReplace(itemPath,"iS).*?\.exe($| .*)","$1")	;去掉应用名，取参数
		itemPath:=objPathItem
		if(appParm!=""){
			itemPath:=objPathItem . appParm
		}
	}
	return itemPath
}
;[判断后返回该菜单项最佳的启动路径]
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
;[打开文件夹(支持使用第三方文件管理器)]
Open_Folder_Path(path){
	If(OpenFolderPathRun){
		Run,%OpenFolderPathRun%%A_Space%"%path%"
	}else{
		Run,%path%
	}
}
;[检查文件后缀是否支持无路径查找]
Check_Obj_Ext(filePath){
	EvExtFlag:=false
	fileValue:=RegExReplace(filePath,"iS)(.*?\.[a-zA-Z0-9-_]+)($| .*)","$1")	;去掉参数
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
;~;[外部动态运行函数和插件]
Remote_Dyna_Run(remoteRun, remoteGetZz, remoteFlag:=false){
	getZz:=remoteGetZz
	if(IsLabel(remoteRun)){
		Gosub,%remoteRun%
		return
	}
	if(remoteFlag){
		if(RegExMatch(remoteRun,"S).+?\[.+?\]%?\(.*?\)")){
			global any:=remoteRun
			SetTimer,Menu_Run_Plugins_ObjReg,-1
		}else{
			Remote_Menu_Run(remoteRun, remoteGetZz)
		}
		return
	}
	global any:=remoteRun
	if(RegExMatch(remoteRun,"S).+?\[.+?\]%?\(.*?\)")){
		Gosub,Menu_Run_Plugins_ObjReg
	}else{
		;[获取菜单项启动模式]
		global itemMode:=Get_Menu_Item_Mode(any)
		;[根据菜单项模式运行]
		global returnFlag:=false
		Gosub,Menu_Run_Mode_Label
		if(returnFlag)
			return
		Run_Any(Get_Obj_Path_Transform(any))
	}
}
;[外部调用运行菜单项]
Remote_Menu_Run(remoteRun, remoteGetZz:=""){
	getZz:=remoteGetZz
	OutsideMenuItem:=remoteRun
	Gosub, Menu_Run
}
;[外部调用显示后缀菜单]
Remote_Menu_Ext_Show(fileExt){
	extMenuName:=MenuObjExt[FileExt]
	If (extMenuName="" || FileExt="public")
		extMenuName := "public"
	Menu_Show_Show(extMenuName, "")
}
;══════════════════════════════════════════════════════════════════
;~;【══🧩插件函数方法══】
;══════════════════════════════════════════════════════════════════
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
;RunAny搜索框插件
RunAny_SearchBar:
	if(rule_check_is_run(PluginsPathList["RunAny_SearchBar.ahk"])){
		DeleteFile(RunAEvFullPathIniDirPath "\RunAnyMenuObj.ini")
		DeleteFile(RunAEvFullPathIniDirPath "\RunAnyMenuObjExt.ini")
		DeleteFile(RunAEvFullPathIniDirPath "\RunAnyMenuObjIcon.ini")
		for k,v in MenuObj
		{
			if(v="")
				continue
			IniWrite, % v, %RunAEvFullPathIniDirPath%\RunAnyMenuObj.ini, MenuObj, %k%
		}
		for k,v in MenuObjExt
		{
			IniWrite, % v, %RunAEvFullPathIniDirPath%\RunAnyMenuObjExt.ini, MenuObjExt, %k%
		}
		for k,v in MenuObjIconList
		{
			if(v="")
				continue
			klist:=StrSplit(k,"`t",,2)
			kname:=klist[1]
			IniWrite, % v "," MenuObjIconNoList[k], %RunAEvFullPathIniDirPath%\RunAnyMenuObjIcon.ini, MenuObjIcon, %kname%
		}
	}
return
Plugins_Down_Check(name, path){
	FileRead, content, %path%
	if(!content || InStr(content,"404: Not Found") || InStr(content,"404 Not Found")){
		MsgBox,48,,%name% 下载失败，请重新勾选下载！
	}
}
;[插件检查版本更新]
PluginsDownVersion:
	if(!rule_check_network(giteeUrl)){
		RunAnyDownDir:=githubUrl . RunAnyGithubDir
		if(!rule_check_network(githubUrl)){
			TrayTip,网络异常,无法连接网络读取最新版本文件，请手动下载,5,2
			pluginsDownList:=PluginsObjList
			checkGithub:=false
			return
		}
	}
	CreateDir(A_Temp "\" RunAnyZz "\" PluginsDir)
	ObjRegIniPath=%A_Temp%\%RunAnyZz%\%PluginsDir%\%RunAny_ObjReg%
	URLDownloadToFile(RunAnyDownDir "/" PluginsDir "/" RunAny_ObjReg, ObjRegIniPath)
	IfExist,%ObjRegIniPath%
	{
		FileGetSize, ObjRegIniSize, %ObjRegIniPath%
		if(ObjRegIniSize>500){
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
;══════════════════════════════════════════════════════════════════
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
		FileName:=Get_Obj_Path(itemVar,fullItemFlag)
		if(!FileExist(FileName))
			FailFlag:=true
	}
	diyText:=StrSplit(itemVar,"|",,2)
	objText:=(diyText[2]) ? diyText[2] : diyText[1]
	;[优先加载自定义图标]
	if(itemName!=""){
		itemIcon:=itemName
	}else if(InStr(itemVar,"|")){
		itemIcon:=diyText[1]
	}else{
		itemIcon:=name_no_ext
	}
	itemIconFile:=IconFolderList[menuItemIconFileName(itemIcon)]
	if(itemIconFile && FileExist(itemIconFile)){
		try{
			Menu,exeTestMenu,Icon,donothing,%itemIconFile%,0
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
	if(setItemMode=7 || setItemMode=71)
		return "Icon4"
	if(setItemMode=4)	; {发送热键}
		return "Icon9"
	if(setItemMode=5)
		return "Icon10"
	if(setItemMode=8){  ; {脚本插件函数}
		appPlugins:=RegExReplace(objText,"iS)(.+?)\[.+?\]%?\(.*?\)$","$1")	;取插件名
		if(PluginsIconList[appPlugins ".ahk"]){
			PluginsIconS:=StrSplit(Get_Transform_Val(PluginsIconList[appPlugins ".ahk"]),",")
			addNum:=IL_Add(ImageListID, PluginsIconS[1], PluginsIconS[2])
			return "Icon" addNum
		}
		return "Icon11"
	}
	if(!editVar && FileName="" && FileExt="exe")
		return "Icon3"
	;[获取网址图标]
	if(setItemMode=6){
		try{
			website:=RegExReplace(objText,"iS)[\w-]+://?((\w+\.)+\w+).*","$1")
			webIcon:=A_ScriptDir "\RunIcon\" website ".ico"
			if(FileExist(webIcon)){
				Menu,exeTestMenu,Icon,donothing,%webIcon%,0
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
		;[编辑后通过everything重新添加应用图标]
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

;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
;~;【——🔛配置初始化——】
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
Config_Set:
	;#判断配置文件
	if(!FileExist(RunAnyConfig)){
		IniWrite,%IniConfig%,%RunAnyConfig%,Config,IniConfig
	}
	;[RunAny设置参数]
	global Z_ScriptName:=FileExist(RunAnyZz ".exe") ? RunAnyZz ".exe" : A_ScriptName
	RegRead, AutoRun, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, RunAny
	AutoRun:=AutoRun=A_ScriptDir "\" Z_ScriptName ? 1 : 0
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
	global OutsideMenuItem:=""
	global MENU_NO:=1
	global RegexEscapeStr:="\\|\.|\*|\?|\+|\[|\{|\||\(|\)|\^|\$"
	global RegexEscapeNoPointStr:="\\|\*|\?|\+|\[|\{|\||\(|\)|\^|\$"
	global RegexEscapeList:=StrSplit("\.*?+[{|()^$")
	global RegexEscapeNoPointList:=StrSplit("\*?+[{|()^$")
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
	DisableApp:=Var_Read("DisableApp","vmware-vmx.exe,TeamViewer.exe,SunloginClient.exe,War3.exe,dota2.exe,League of Legends.exe")
	Loop,parse,DisableApp,`,
	{
		GroupAdd,DisableGUI,ahk_exe %A_LoopField%
	}
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
	global BrowserPath:=Var_Read("BrowserPath")
	global OneKeyRun:={"一键公式计算":""
		,"一键打开文件":"runany[Run_Any](%getZz%)"
		,"一键打开目录":"runany[Open_Folder_Path](%getZz%)"
		,"一键打开网址":"runany[Run_Search](%getZz%)"
		,"一键磁力链接":"runany[Run_Any](%getZz%)"}
	if(BrowserPath!=""){
		OneKeyRun["一键打开网址"]:=BrowserPath " ""%getZz%"""
	}
	global OneKeyRegex:={"一键公式计算":"S)^[\(\)\.\s\d]*\d+\s*[+*/-]+[\(\)\.+*/-\d\s]+($|=$)"
		,"一键打开文件":"S)^(\\\\|.:\\).*?\..+"
		,"一键打开目录":"S)^(\\\\|.:\\)"
		,"一键打开网址":"iS)^([\w-]+:\/\/?|www[.]).*"
		,"一键磁力链接":"iS)^magnet:\?xt=urn:btih:.*"}
	global OneKeyRegexList:={}
	global OneKeyRegexMultilineList:={}
	global OneKeyRunList:={}
	global OneKeyDisableList:={}
	global OneKeyDisableStr:=Var_Read("OneKeyDisableList")
	Loop, parse, OneKeyDisableStr, |
	{
		OneKeyDisableList[A_LoopField]:=true
	}
	IniRead,OneKeyVar,%RunAnyConfig%,OneKey
	if(!OneKeyVar){
		OneKeyRunList:=OneKeyRun
		OneKeyRegexList:=OneKeyRegex
	}
	Loop, parse, OneKeyVar, `n, `r
	{
		R_LoopField=%A_LoopField%
		if(R_LoopField="")
			continue
		varList:=StrSplit(R_LoopField,"=",,2)
		if(varList[1]="")
			continue
		if(RegExMatch(varList[1],".+_Run$")){
			OneKeyRunList[RegExReplace(varList[1],"(.+)_Run$","$1")]:=varList[2]
		}else if(RegExMatch(varList[1],".+_Regex$")){
			name:=RegExReplace(varList[1],"(.+)_Regex$","$1")
			OneKeyRegexList[name]:=varList[2]
			if(RegExMatch(varList[2],"m)^[^(]*?m.*?\).*")){
				OneKeyRegexMultilineList[name]:=varList[2]
			}
		}
	}
	global OneKeyMenu:=Var_Read("OneKeyMenu",0)
	global OneKeyUrl:=Var_Read("OneKeyUrl","https://www.baidu.com/s?wd=%s")
	OneKeyUrl:=StrReplace(OneKeyUrl, "|", "`n")
	;[搜索Everything]
	global EvPath:=Var_Read("EvPath")
	global EvShowExt:=Var_Read("EvShowExt",1)
	global EvShowFolder:=Var_Read("EvShowFolder",1)
	global EvAutoClose:=Var_Read("EvAutoClose",0)
	global EvExeVerNew:=Var_Read("EvExeVerNew",1)
	global EvExeMTimeNew:=Var_Read("EvExeMTimeNew",1)
	global EvDemandSearch:=Var_Read("EvDemandSearch",1)
	EvCommandDefault:="!" A_WinDir "* !?:\$RECYCLE.BIN* !?:\Users\*\AppData\Local\Temp\* !?:\Users\*\AppData\Roaming\*.exe"
	try EnvGet, scoopPath, scoop
	if(scoopPath)
		EvCommandDefault.=" !" RegExReplace(scoopPath,".(:\\.*)","?$1") "\shims\*"
	global EvCommand:=Var_Read("EvCommand",EvDemandSearch ? EvCommandDefault : EvCommandDefault " file:*.exe|*.lnk|*.ahk|*.bat|*.cmd")
	EvCommandVar:=RegExReplace(EvCommand,"i).*file:(\*\.[^\s]*).*","$1")
	global EvCommandExtList:=StrSplit(EvCommandVar,"|")
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
	global ShowGetZzLen:=Var_Read("ShowGetZzLen",30)
	global DebugMode:=Var_Read("DebugMode",0)
	global DebugModeShowTime:=Var_Read("DebugModeShowTime",8000)
	global DebugModeShowTrans:=Var_Read("DebugModeShowTrans",70)
	global DebugModeShowText:=""
	global DebugModeShowTextLen:=0
	global EvNo:=Var_Read("EvNo",0)
	global JumpSearch:=Var_Read("JumpSearch",0)
	global AutoGetZz:=Var_Read("AutoGetZz",1)
	global GetZzCopyKey:=Var_Read("GetZzCopyKey","^{Insert}")
	global GetZzCopyKeyApp:=Var_Read("GetZzCopyKeyApp","cmd.exe,powershell.exe")
	Loop,parse,GetZzCopyKeyApp,`,
	{
		GroupAdd,GetZzCopyKeyAppGUI,ahk_exe %A_LoopField%
	}
	global DisableExeIcon:=Var_Read("DisableExeIcon",0)
	global RunAEncoding:=Var_Read("RunAEncoding",A_Language!=0804 ? "UTF-8" : "")
	global ClipWaitTime:=Var_Read("ClipWaitTime",0.1)
	global ClipWaitApp:=Var_Read("ClipWaitApp")
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
	global MENU_RUN_NAME_STR:="编辑(&E),同名软件(&S),软件目录(&D),透明运行(&Q),置顶运行(&T),改变大小运行(&W),管理员权限运行(&A)" 
		. ",最小化运行(&I),最大化运行(&P),隐藏运行(&H),结束软件进程(&X)"
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
		RegRead, MenuCommonListReg, HKEY_CURRENT_USER\Software\RunAny, MenuCommonList
		if(MenuCommonListReg){
			Loop, parse, MenuCommonListReg, |
			{
				R_ThisMenuItem:=RegExReplace(A_LoopField,"^&\d+ ","")
				if R_ThisMenuItem not in %MENU_RUN_NAME_STR%
				{
					MenuCommonList.Push(A_LoopField)
				}
			}
		}
	}
	OnExit("ExitFunc")
	OnMessage(0x004A, "Receive_WM_COPYDATA")
	OnMessage(0x11, "WM_QUERYENDSESSION")
	;~[定期自动检查更新]
	global giteeUrl:="https://gitee.com"
	global githubUrl:="https://raw.githubusercontent.com"
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
			Gosub,Old_Config_Clear
		}
		Gosub,Auto_Update
	}
return
Old_Config_Clear:
	EvCommandDefaultOld1:="!" A_WinDir "* !?:\$RECYCLE.BIN* !?:\Users\*\AppData\Local\Temp\* !?:\Users\*\AppData\Roaming\*"
	try EnvGet, scoopPath, scoop
	if(scoopPath)
		EvCommandDefaultOld1.=" !" RegExReplace(scoopPath,".(:\\.*)","?$1") "\shims\*"
	EvCommand_Old1:=EvDemandSearch ? EvCommandDefaultOld1 : EvCommandDefaultOld1 " file:*.exe|*.lnk|*.ahk|*.bat|*.cmd"
	IniRead,readVar,%RunAnyConfig%,Config,EvCommand,A_Space
	if(readVar!=""){
		if(readVar=EvCommand_Old1){
			IniDelete,%RunAnyConfig%,Config,EvCommand
		}
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
	global BrowserPathRun:=Get_Obj_Path_Transform(BrowserPath)
	global openExtIniList:={}
	global openExtRunList:={}
	ClipWaitAppStr:=""
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
		if(InStr(itemList[1],"dopus.exe") || MenuObjEv["dopus"])
			ClipWaitAppStr:=StrJoin(",",ClipWaitAppStr,"dopus.exe")
		if(InStr(itemList[1],"xyplorer.exe") || MenuObjEv["xyplorer"])
			ClipWaitAppStr:=StrJoin(",",ClipWaitAppStr,"xyplorer.exe")
		if(InStr(itemList[1],"totalcmd.exe") || MenuObjEv["totalcmd"])
			ClipWaitAppStr:=StrJoin(",",ClipWaitAppStr,"totalcmd.exe")
		if(InStr(itemList[1],"TotalCMD64.exe") || MenuObjEv["TotalCMD64"])
			ClipWaitAppStr:=StrJoin(",",ClipWaitAppStr,"totalcmd64.exe")
	}
	; 解决指定软件界面剪贴板等待时间过短获取不到选中内容
	Sort, ClipWaitAppStr ,U D,
	if(ClipWaitAppStr!=""){
		ClipWaitTime:=Var_Read("ClipWaitTime", 1.2)
		ClipWaitApp:=Var_Read("ClipWaitApp", ClipWaitAppStr)
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
	global iniFile:=iniPath
	global iniVar1:=""
	global both:=1
	global RunABackupDirPath:=Get_Transform_Val(RunABackupDir)
	global RunAEvFullPathIniDir:=Var_Read("RunAEvFullPathIniDir","`%AppData`%\" RunAnyZz)
	global RunAEvFullPathIniDirPath:=Get_Transform_Val(RunAEvFullPathIniDir)
	global RunAnyEvFullPathIni:=RunAEvFullPathIniDirPath "\RunAnyEvFullPath.ini"
	CreateDir(A_ScriptDir "\" PluginsDir "\" Lib)
	CreateDir(A_AppData "\" RunAnyZz)
	CreateDir(RunABackupDirPath "\" RunAnyConfig)
	CreateDir(RunAEvFullPathIniDirPath)
	CreateDir(A_Temp "\" RunAnyZz)
	FileRead, evFullPathIniVar, %RunAnyEvFullPathIni%
	evFullPathIniVar:=StrReplace(evFullPathIniVar, "[FullPath]`r`n", "")
	if(RunAEncoding){
		try{
			FileEncoding,%RunAEncoding%
		}catch e {
			MsgBox,16,文件编码出错,% "请设置正确的编码读取RunAny.ini!`n参考：https://wyagd001.github.io/zh-cn/docs/commands/FileEncoding.htm"
			. "`n`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
		}
	}
	FileGetSize,iniFileSize,%iniFile%
	If(!FileExist(iniFile) || iniFileSize=0){
		TrayTip,,RunAny初始化中...,2,17
		SetTimer, HideTrayTip, -2000
		Gosub,First_Run
	}
	FileRead, iniVar1, %iniPath%
	;#判断第2菜单ini#
	global MENU2FLAG:=false
	IfExist,%iniPath2%
	{
		global iniVar2:=""
		MENU2FLAG:=true
		FileRead, iniVar2, %iniPath2%
		CreateDir(RunABackupDirPath "\" RunAnyZz "2.ini")
	}
	global iniFileVar:=iniVar1
	global EvPathRun:=Get_Transform_Val(EvPath)
	;#判断Everything拓展DLL文件#
	if(!EvNo){
		Gosub,Ev_Exist
		;~Everything搜索检查准备
		global RunAnyTickCount:=0
		RegRead,RunAnyTickCount,HKEY_CURRENT_USER\SOFTWARE\RunAny,RunAnyTickCount
		if(!RunAnyTickCount || A_TickCount<RunAnyTickCount){
			RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\RunAny,EvTotResults,0
		}
	}
return
Ev_Exist:
	global everyDLL:="Everything.dll"
	if(FileExist(A_ScriptDir "\Everything.dll")){
		everyDLL:=DllCall("LoadLibrary", str, "Everything.dll") ? "Everything.dll" : "Everything64.dll"
	}else if(FileExist(A_ScriptDir "\Everything64.dll")){
		everyDLL:=DllCall("LoadLibrary", str, "Everything64.dll") ? "Everything64.dll" : "Everything.dll"
	}
	if(!FileExist(A_ScriptDir "\" everyDLL)){
		MsgBox,17,,没有找到%everyDLL%，将不能识别菜单中程序的路径`n需要将%everyDLL%放到【%A_ScriptDir%】目录下`n是否需要从网上下载%everyDLL%？
		IfMsgBox Ok
		{
			URLDownloadToFile(RunAnyDownDir "/" everyDLL,A_ScriptDir "\" everyDLL)
			Gosub,Menu_Reload
		}else{
			MsgBox,17,【慎改】,是否需要开启不使用Everything模式？所有无路径应用可以通过手动新增修改同步来识别运行路径。`n`n（也可在高级配置中修改）
			IfMsgBox Ok
			{
				Var_Set(1,EvNo,"EvNo")
				EvNo:=1
			}
		}
	}
return
;~;【——⭕️图标初始化——】
Icon_Set:
	Menu,exeTestMenu,add,donothing	;只用于测试应用图标正常添加
	global RunIconDir:=A_ScriptDir "\RunIcon"
	global WebIconDir:=RunIconDir "\WebIcon"
	global ExeIconDir:=RunIconDir "\ExeIcon"
	global MenuIconDir:=RunIconDir "\MenuIcon"
	IconDirs:="ExeIcon,WebIcon,MenuIcon"
	Loop, Parse, IconDirs, `,
	{
		CreateDir(RunIconDir "\" A_LoopField)
	}
	global IconFileSuffix:="*.ico;*.bmp;*.png;*.gif;*.jpg;*.jpeg;*.jpe;*.jfif;*.dib;*.tif;*.tiff;*.heic"
		. ";*.cur;*.ani;*.cpl;*.scr;"
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
		try{
			Menu,exeTestMenu,Icon,donothing,ZzIcon.dll,7
			ZzIconPath:="ZzIcon.dll,7"
		} catch {
			ZzIconPath:="ZzIcon.dll,1"
		}
	}else{
		ZzIconPath:="shell32.dll,194"
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
	global ZzIconS:=StrSplit(ZzIconPath,",")
return
;~;[后缀图标初始化]
Icon_FileExt_Set:
	global FolderIcon:=Var_Read("FolderIcon","shell32.dll,4")
	global FolderIconS:=StrSplit(Get_Transform_Val(FolderIcon),",")
	global UrlIcon:=Var_Read("UrlIcon","shell32.dll,44")
	global UrlIconS:=StrSplit(Get_Transform_Val(UrlIcon),",")
	global EXEIcon:=Var_Read("EXEIcon","shell32.dll,3")
	global EXEIconS:=StrSplit(Get_Transform_Val(EXEIcon),",")
	global LNKIcon:="shell32.dll,264"
	if(A_OSVersion="WIN_XP"){
		LNKIcon:="shell32.dll,30"
	}
	global LNKIconS:=StrSplit(LNKIcon,",")
	FuncIcon:=Var_Read("FuncIcon","shell32.dll,131")
	global FuncIconS:=StrSplit(Get_Transform_Val(FuncIcon),",")
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
;~;[提取菜单中所有EXE程序图标，过程较慢]
Menu_Exe_Icon_Create:
	cfgFile=%ResourcesExtractDir%\ResourcesExtract.cfg
	DestFold=%A_Temp%\%RunAnyZz%\RunAnyExeIconTemp
	if(!ResourcesExtractExist){
		MsgBox,64,,请将ResourcesExtract.exe放入%ResourcesExtractDir%
		return
	}
	MsgBox,35,生成所有EXE图标，请稍等片刻, 
(	
使用生成的EXE图标可以加快开机第一次RunAny的加载速度`n`n是：覆盖老图标重新生成%RunAnyZz%菜单中的所有EXE图标`n否：只生成没有的EXE图标`n取消：取消生成
)
	IfMsgBox Yes
	{
		exeIconCreateFlag:=false
		Gosub,Menu_Exe_Icon_Extract
	}
	IfMsgBox No
	{
		exeIconCreateFlag:=true
		Gosub,Menu_Exe_Icon_Extract
	}
return
Menu_Exe_Icon_Extract:
	if(!FileExist(cfgFile)){
		MsgBox,64,,请将ResourcesExtract.cfg放入%ResourcesExtractDir%
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
	MsgBox,64,,成功生成%RunAnyZz%内所有EXE图标到 %ExeIconDir%
	Gui,66:Submit, NoHide
	if(vIconFolderPath){
		if(!InStr(vIconFolderPath,"ExeIcon"))
			GuiControl,, vIconFolderPath, %vIconFolderPath%`n`%A_ScriptDir`%\RunIcon\ExeIcon
	}else{
		GuiControl,, vIconFolderPath, `%A_ScriptDir`%\RunIcon\ExeIcon
	}
return
;[循环提取菜单中EXE程序的正确图标]
Menu_Exe_Icon_Set(){
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
;~;【——🧩插件脚本——】
;══════════════════════════════════════════════════════════════════
;~;【AHK插件脚本Read】
Plugins_Read:
	global PluginsObjList:=Object(),PluginsPathList:=Object(),PluginsRelativePathList:=Object(),PluginsNameList:=Object(),pluginsDownList:=Object()
	global PluginsVersionList:=Object(),PluginsIconList:=Object(),PluginsContentList:=Object()
	global PluginsObjNum:=0
	global PluginsDirList:=[]
	global PluginsEditor:=Var_Read("PluginsEditor")
	global PluginsDirPath:=Var_Read("PluginsDirPath")
	global PluginsListViewSwap:=Var_Read("PluginsListViewSwap",0)
	global PluginsDirPathList:="%A_ScriptDir%\%PluginsDir%|" PluginsDirPath
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
			PluginsRelativePathList[(A_LoopFileName)]:=StrReplace(A_LoopFileFullPath,A_ScriptDir "\")
			PluginsNameList[(A_LoopFileName)]:=Plugins_Read_Name(A_LoopFileFullPath)
			PluginsVersionList[(A_LoopFileName)]:=Plugins_Read_Version(A_LoopFileFullPath)
			PluginsIconList[(A_LoopFileName)]:=Plugins_Read_Icon(A_LoopFileFullPath)
			if(A_LoopField="%A_ScriptDir%\%PluginsDir%"){
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
				PluginsRelativePathList[(A_LoopFileName . ".ahk")]:=StrReplace(A_LoopFileFullPath "\" A_LoopFileName ".ahk",A_ScriptDir "\")
				PluginsNameList[(A_LoopFileName . ".ahk")]:=Plugins_Read_Name(A_LoopFileFullPath "\" A_LoopFileName ".ahk")
				PluginsVersionList[(A_LoopFileName . ".ahk")]:=Plugins_Read_Version(A_LoopFileFullPath "\" A_LoopFileName ".ahk")
				PluginsIconList[(A_LoopFileName . ".ahk")]:=Plugins_Read_Icon(A_LoopFileFullPath "\" A_LoopFileName ".ahk")
				if(A_LoopField="%A_ScriptDir%\%PluginsDir%"){
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
	global PluginsObjRegGUID:=Object()      ;~插件对象注册GUID列表
	global PluginsObjRegActive:=Object()    ;~插件对象注册Active列表
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
Plugins_Read_Name(filePath){
	returnStr:=""
	strRegOld:="iS).*?【(.*?)】.*"
	strRegNew=iS)^\t*\s*global RunAny_Plugins_Name:="(.+?)"
	Loop, read, %filePath%
	{
		if(RegExMatch(A_LoopReadLine,strRegNew)){
			returnStr:=RegExReplace(A_LoopReadLine,strRegNew,"$1")
			break
		}else if(RegExMatch(A_LoopReadLine,strRegOld)){
			returnStr:=RegExReplace(A_LoopReadLine,strRegOld,"$1")
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
;[获取插件图标的路径]
Plugins_Read_Icon(filePath){
	returnStr:=""
	strReg=iS)^\t*\s*global RunAny_Plugins_Icon:="(.+?)"
	Loop, read, %filePath%
	{
		if(RegExMatch(A_LoopReadLine,strReg)){
			returnStr:=RegExReplace(A_LoopReadLine,strReg,"$1")
			break
		}
	}
	if(returnStr=""){
		PluginsFile:=RegExReplace(filePath,"iS)\.ahk$")
		Loop, Parse,% IconFileSuffix "*.exe;", `;
		{
			suffix:=StrReplace(A_LoopField, "*")
			if(FileExist(PluginsFile suffix)){
				return PluginsFile suffix ",1"
			}
		}
	}
	return returnStr
}
;~;【自动启动插件】
AutoRun_Plugins:
	if(!A_AhkPath)
		return
	try {
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
;~;【——🔗规则启动——】
;══════════════════════════════════════════════════════════════════
;~;[规则启动项Read]
RunCtrl_Read:
	;规则名-脚本路径；规则名-脚本插件名；规则名-函数名；规则名-状态；规则名-类型；规则名-是否传参
	global rulefileList:=Object(),ruleitemList:=Object(),rulefuncList:=Object(),rulestatusList:=Object(),ruletypelist:=Object(),ruleparamList:=Object()
	global RuleNameStr:=""
	global RunCtrlLastTimeIni:=A_AppData "\" RunAnyZz "\RunCtrlLastTime.ini"
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
		;判断规则状态
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
		;判断规则是否需要传参
		if(varList[2]=RunAnyZz ".ahk"){
			ruleparamList[(ruleparamList[itemList[1]]!="" ? itemList[1] "(重名)" : itemList[1])]:=IsFunc(itemList[2]) > 1
		}else if(varList[2]!="0" && !InStr(PluginsContentList[(varList[2])],itemList[2] "()")){
			ruleparamList[(ruleparamList[itemList[1]]!="" ? itemList[1] "(重名)" : itemList[1])]:=true
		}
	}
	RuleNameStr:=SubStr(RuleNameStr, 1, -StrLen("|"))
	if(ruleparamList.HasKey("联网状态")){
		ruleparamList["联网状态"]:=1
	}
	;---规则启动项---
	global RunCtrlList:=Object(),RunCtrlListBoxList:=Object(),RunCtrlListContentList:=Object()
	global RunCtrlLogicEnum:={"eq":"相等","ne":"不相等","ge":"大于等于","le":"小于等于","gt":"大于","lt":"小于","regex":"正则表达式"}
	global RunCtrlRunWayList:=["启动","置顶启动","最小化启动","最大化启动","隐藏启动","结束软件进程_启动"]
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
			if(itemList[1] && itemList[5]!=""){
				funcEffect:=Func("RunCtrl_RunRules").Bind(RunCtrlObj,true)
				Hotkey,% itemList[5],% funcEffect,On
			}
		} catch {
			MsgBox,16,规则组%runCtrlName%：热键配置不正确,% "热键错误：`n" itemList[5] "`n请设置正确热键后重启RunAny"
		}
	}
	RunCtrlListBoxVar:=SubStr(RunCtrlListBoxVar, 1, -StrLen("|"))
return

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

			itemList:=StrSplit(varList[1],"|",,4)
			noPathStr:=itemList[1]
			runObj.repeatRun:=itemList[2]!="" ? itemList[2] : 0
			runObj.adminRun:=itemList[3]!="" ? itemList[3] : 0
			runObj.runWay:=itemList[4]!="" ? itemList[4] : 1
			if(noPathStr="path"){
				this.noPath:=false
				runObj.noPath:=false
			}else if(noPathStr="menu"){
				this.noMenu:=false
			}
			IniRead, lastRunTime, %RunCtrlLastTimeIni%, last_run_time,% runObj.path, %A_Space%
			runObj.lastRunTime:=lastRunTime
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
	noPath:=true        ;无路径标记
	repeatRun:=false    ;重复运行
	adminRun:=false     ;管理员运行
	runWay:=1           ;运行方式
	lastRunTime:=""     ;最后运行时间
}
class RunCtrlRunRule
{
	file:="",name:="",value:="",ruleBreak:=""
	logic:=1
}

;~;[规则生效]
Rule_Effect:
	global runIndex:=Object(), RuleRunFailList:=Object(), RuleRunNoPathList:=Object()
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
		if(RuleRunFailList.Count() > 0){
			RuleRunFailStr:=StrListJoin("`n",RuleRunFailList)
			TrayTip,规则插件脚本没有启动：,%RuleRunFailStr%,5,2
		}
		RunCtrlRunFlag:=false
	} catch e {
		MsgBox,16,规则判断出错,% "规则名：" rcName 
			. "`n出错脚本：" e.File "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
	}
return
;~;[规则启动]
RunCtrl_RunRules(runCtrlObj,show:=0){
	try {
		rcName:=runCtrlObj.name
		effectResult:=RunCtrl_RuleEffect(runCtrlObj)
		if(effectResult){
			for i,runv in runCtrlObj.runList
			{
				if(!runCtrlObj.noPath || !runCtrlObj.noMenu){
					RunCtrl_RunApps(runv.path, runv.noPath, runv.repeatRun, runv.adminRun, runv.runWay)
				}
			}
		}else if(show){
			ToolTip, ❎ 规则验证失败
			SetTimer,RemoveToolTip,3000
			if(RuleRunFailList.Count() > 0){
				RuleRunFailStr:=StrListJoin("`n",RuleRunFailList)
				TrayTip,规则插件脚本没有启动：,%RuleRunFailStr%,5,2
			}
		}
		return effectResult
	} catch e {
		MsgBox,16,启动规则出错,% "启动规则名：" rcName "`n启动规则脚本：" StrListJoin(",",runCtrlObj.ruleFile)
			. "`n出错脚本：" e.File "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
	} finally {
		runIndex[rcName]++	;规则定时器运行计数+1
		;规则运行计数达到最大循环次数 || 启动项已达到最多运行次数 => 结束定时器
		if((runIndex[rcName] && runIndex[rcName] >= runCtrlObj.ruleMostRun)){
			try SetTimer,% funcEffect%rcName%, Off
		}
	}
}
;~;[规则应用启动]
RunCtrl_RunApps(path,noPath,repeatRun:=0,adminRun:=0,runWay:=1){
	try {
		global RunCtrlRunFlag:=true
		global RunCtrlAdminRunVal:=adminRun
		global RunCtrlRunWayVal:=runWay
		if(noPath){
			tfPath:=Get_Obj_Transform_Name(Trim(path," `t`r`n"))
			if(!repeatRun && runWay!=6 && rule_check_is_run(MenuObj[tfPath])){
				return
			}
			if(NoPathFlag || EvNo){
				OutsideMenuItem:=tfPath
				global NoRecentFlag:=true
				Gosub, Menu_Run
				RunCtrl_LastRunTime(path)
			}else{
				RuleRunNoPathList[tfPath]:=true
				RuleRunAdminRunList[tfPath]:=adminRun
				RuleRunRunWayList[tfPath]:=runWay
				;定时等待无路径程序可运行后再运行
				SetTimer,RunCtrl_RunMenu,100
			}
		}else{
			global any:=Get_Transform_Val(path)
			SplitPath,% any, name, dir
			if(!repeatRun && runWay!=6 && rule_check_is_run(any)){
				return
			}else if(runWay=6){
				Run,% ComSpec " /C taskkill /f /im """ name """", , Hide
				return
			}
			if(dir && FileExist(dir))
				SetWorkingDir,%dir%
			global anyRun:=""
			global way:=""
			Gosub, MenuRunWay
			Gosub, MenuRunAny
			RunCtrlRunFlag:=false
			RunCtrl_LastRunTime(path)
		}
	} catch e {
		MsgBox,16,规则启动应用出错,% "启动应用：" path
			. "`n出错脚本：" e.File "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
	} finally {
		SetWorkingDir,%A_ScriptDir%
	}
}
RunCtrl_RunMenu:
	if(NoPathFlag || EvNo){
		SetTimer,RunCtrl_RunMenu,Off
		For path, isRun in RuleRunNoPathList
		{
			if(isRun){
				RuleRunNoPathList[path]:=false
				global RunCtrlRunFlag:=true
				global RunCtrlAdminRunVal:=RuleRunAdminRunList[path]
				global RunCtrlRunWayVal:=RuleRunRunWayList[path]
				global NoRecentFlag:=true
				OutsideMenuItem:=path
				Gosub,Menu_Run
				RunCtrl_LastRunTime(path)
			}
		}
	}
return
RunCtrl_LastRunTime(path){
	IniWrite, %A_Now%, %RunCtrlLastTimeIni%, last_run_time, %path%
}
;~;[规则判断是否成立]
RunCtrl_RuleEffect(runCtrlObj){
	effectFlag:=false
	ruleRunCount:=0
	rcName:=runCtrlObj.name
	for ruleFile,ruleStatus in runCtrlObj.ruleFile
	{
		if(ruleStatus && ruleFile!="0" && ruleFile!="RunAny"){
			if(rule_check_is_run(PluginsPathList[ruleFile ".ahk"])){
				PluginsObjRegActive[ruleFile]:=ComObjActive(PluginsObjRegGUID[ruleFile])
			}else{
				RuleRunFailList[ruleFile]:=""
			}
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
			}else if(rulev.logic="regex"){
				effectFlag:=RegExMatch(effectResult, rulev.value)
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
			appParms:=StrSplit(ruleValue,"``n")
			effectResult:=PluginsObjRegRun(ruleFile, rulefuncList[ruleName], appParms)
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
;~;【——🌏检查更新——】
;══════════════════════════════════════════════════════════════════
Check_Update:
	checkUpdateFlag:=true
	TrayTip,,RunAny检查更新中……,2,17
	SetTimer, HideTrayTip, -2000
	Gosub,Auto_Update
return
Auto_Update:
	DeleteFile(A_Temp "\" RunAnyZz "\RunAny_Update.bat")
	;[下载最新的更新脚本]
	if(!rule_check_network(giteeUrl)){
		RunAnyDownDir:=githubUrl . RunAnyGithubDir
		if(!rule_check_network(githubUrl)){
			TrayTip,网络异常,无法连接网络读取最新版本文件,5,2
			return
		}
	}
	URLDownloadToFile(RunAnyDownDir "/RunAny.ahk",A_Temp "\temp_RunAny.ahk")
	versionReg=iS)^\t*\s*global RunAny_update_version:="([\d\.]*)".*
	Loop, read, %A_Temp%\temp_RunAny.ahk
	{
		if(RegExMatch(A_LoopReadLine,versionReg)){
			versionStr:=RegExReplace(A_LoopReadLine,versionReg,"$1")
			break
		}
		if(A_LoopReadLine="404: Not Found"){
			TrayTip,,文件下载异常，更新失败！,5,2
			return
		}
	}
	if(versionStr){
		Gosub,Plugins_Read
		Gosub,PluginsDownVersion
		runAnyUpdateStr:=pluginUpdateStr:=""
		For pk, pv in pluginsDownList
		{
			if(PluginsVersionList[pk] < pv){
				pluginUpdateStr.=pk A_Tab PluginsVersionList[pk] "`t版本更新后=>`t" pv "`n"
			}
		}
		if(RunAny_update_version<versionStr || pluginUpdateStr!=""){
			runAnyUpdateStr:=RunAny_update_version<versionStr ? "检测到RunAny有新版本`n`n" RunAny_update_version "`t版本更新后=>`t" versionStr "`n" : ""
			pluginUpdateStr:=pluginUpdateStr!="" ? "`n检测到插件有新版本`n" pluginUpdateStr : ""
			MsgBox,33,RunAny检查更新,%runAnyUpdateStr%%pluginUpdateStr%`n
(
是否更新到最新版本？
将移动老版本文件到临时目录，如有修改过请注意备份！`n%A_Temp%\%RunAnyZz%`n
)
			IfMsgBox Ok
			{
				TrayTip,,RunAny开始下载最新版本并替换老版本...,3,17
				SetTimer, HideTrayTip, -3000
				;[下载插件脚本]
				if(pluginUpdateStr!=""){
					For pk, pv in pluginsDownList
					{
						if(PluginsVersionList[pk] < pv && FileExist(PluginsPathList[pk])){
							FileMove,% PluginsPathList[pk],%A_Temp%\%RunAnyZz%\%PluginsDir%\%pk%,1
							URLDownloadToFile(RunAnyDownDir "/" StrReplace(PluginsRelativePathList[pk],"\","/"), A_ScriptDir "\" PluginsRelativePathList[pk])
							Sleep,1000
							Plugins_Down_Check(pk, A_ScriptDir "\" PluginsRelativePathList[pk])
						}
					}
					TrayTip,,插件脚本已经更新到最新版本。,3,1
					SetTimer, HideTrayTip, -3000
				}
				;[下载新版本]
				if(RunAny_update_version<versionStr){
					URLDownloadToFile(RunAnyDownDir "/RunAny.exe",A_Temp "\temp_RunAny.exe")
					Gosub,RunAny_Update
					shell := ComObjCreate("WScript.Shell")
					shell.run(A_Temp "\" RunAnyZz "\RunAny_Update.bat",0)
					ExitApp
				}
			}
		}else if(checkUpdateFlag){
			FileDelete, %A_Temp%\temp_RunAny.ahk
			TrayTip,,RunAny已经是最新版本。,5,1
			checkUpdateFlag:=false
		}
	}
return
RunAny_Update:
if(rule_check_network(RunAnyGiteePages)){
	Run,%RunAnyGiteePages%/runany/#/change-log?id=runany已更新最新版本！感谢一直以来的支持！
}else{
	Run,%RunAnyGithubPages%/RunAny/#/change-log?id=runany已更新最新版本！感谢一直以来的支持！
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
start "" "%A_ScriptDir%\RunAny.exe"
exit
),%A_Temp%\%RunAnyZz%\RunAny_Update.bat
return
;══════════════════════════════════════════════════════════════════
;~;【托盘菜单】
Menu_Tray_Add:
	Menu,Tray,NoStandard
	Menu,Tray,add,显示菜单(&Z)`t%MenuHotKey%,Menu_Tray_Show
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
	Menu,Tray,add,所有菜单项(&T),RunA_MenuObj_Show
	Menu,Tray,add,设置RunAny(&D)`t%RunASetHotKey%,Settings_Gui
	Menu,Tray,add,关于RunAny(&A)...,Menu_About
	Menu,Tray,add,检查更新(&U),Check_Update
	Menu,Tray,add
	Menu,Tray,add,重启(&R)`t%RunAReloadHotKey%,Menu_Reload
	Menu,Tray,add,停用(&S)`t%RunASuspendHotKey%,Menu_Suspend
	Menu,Tray,add,退出(&X)`t%RunAExitHotKey%,Menu_Exit
	Menu,Tray,Default,显示菜单(&Z)`t%MenuHotKey%
	Menu,Tray,Click,1
	;[RunAny菜单图标初始化]
	try {
		Menu,Tray,Icon,% MenuIconS[1],% MenuIconS[2]
		Menu,Tray,Icon,显示菜单(&Z)`t%MenuHotKey%,% ZzIconS[1],% ZzIconS[2],%MenuTrayIconSize%
		Menu,Tray,Icon,修改菜单(&E)`t%TreeHotKey1%,% TreeIconS[1],% TreeIconS[2],%MenuTrayIconSize%
		Menu,Tray,Icon,修改文件(&F)`t%TreeIniHotKey1%,% EditFileIconS[1],% EditFileIconS[2],%MenuTrayIconSize%
		If(MENU2FLAG){
			Menu,Tray,Icon,显示菜单2(&2)`t%MenuHotKey2%,% ZzIconS[1],% ZzIconS[2],%MenuTrayIconSize%
			Menu,Tray,Icon,修改菜单2(&W)`t%TreeHotKey2%,% TreeIconS[1],% TreeIconS[2],%MenuTrayIconSize%
			Menu,Tray,Icon,修改文件2(&G)`t%TreeIniHotKey2%,% EditFileIconS[1],% EditFileIconS[2],%MenuTrayIconSize%
		}
		Menu,Tray,Icon,所有菜单项(&T),imageres.dll,112,%MenuTrayIconSize%
		Menu,Tray,Icon,插件管理(&C)`t%PluginsManageHotKey%,% PluginsManageIconS[1],% PluginsManageIconS[2],%MenuTrayIconSize%
		Menu,Tray,Icon,启动管理(&Q)`t%RunCtrlManageHotKey%,% RunCtrlManageIconS[1],% RunCtrlManageIconS[2],%MenuTrayIconSize%
		Menu,Tray,Icon,设置RunAny(&D)`t%RunASetHotKey%,% MenuIconS[1],% MenuIconS[2],%MenuTrayIconSize%
		Menu,Tray,Icon,关于RunAny(&A)...,% AnyIconS[1],% AnyIconS[2],%MenuTrayIconSize%
		Menu,Tray,Icon,检查更新(&U),% CheckUpdateIconS[1],% CheckUpdateIconS[2],%MenuTrayIconSize%
	} catch e {
		TrayTip,,% "托盘菜单图标错误：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message,5,3
	}
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
	Critical
	Run,%A_AhkPath% /force /restart "%A_ScriptFullPath%"
	ExitApp
return
Menu_Suspend:
	Menu,tray,ToggleCheck,停用(&S)`t%RunASuspendHotKey%
	Suspend
return
Menu_Exit:
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
;~;【🔎Everything搜索所有exe程序】
;══════════════════════════════════════════════════════════════════
EverythingIsRun(){
	global EvPathRun
	evExist:=true
	evAdminRun:=A_IsAdmin ? "-admin" : ""
	DetectHiddenWindows,On
	;获取everything路径
	if(WinExist("ahk_exe Everything.exe")){
		WinGet, EvPathRun, ProcessPath, ahk_exe Everything.exe
		ev := new everything
		;RunAny管理员权限运行后发现Everything非管理员权限则重新以管理员权限运行
		if(!ev.GetIsAdmin() && A_IsAdmin && EvPathRun){
			SplitPath, EvPathRun, name, dir
			SetWorkingDir,%dir%
			Run,%EvPathRun% -exit
			Run,%EvPathRun% -startup %evAdminRun%
			Sleep,500
			ShowTrayTip("","RunAny与Everything权限不一致自动调整后启动",10,17)
			Gosub,Menu_Reload
		}
	}else{
		EvPathRun:=Get_Transform_Val(EvPath)
		if(EvPathRun && FileExist(EvPathRun) && !InStr(FileExist(EvPathRun), "D")){
			SplitPath, EvPathRun, name, dir
			SetWorkingDir,%dir%
			Run,%EvPathRun% -startup %evAdminRun%
			Sleep,500
		}else if(FileExist(A_ScriptDir "\Everything\Everything.exe")){
			SetWorkingDir,%A_ScriptDir%\Everything
			Run,%A_ScriptDir%\Everything\Everything.exe -startup %evAdminRun%
			EvPath=%A_ScriptDir%\Everything\Everything.exe
			EvPathRun:=EvPath
			Sleep,500
		}else{
			TrayTip,,RunAny需要Everything快速识别无路径应用`n
			(
* 运行Everything后再重启RunAny
* 或在RunAny设置中配置Everything正确安装路径`n* 或www.voidtools.com下载安装
			),10,2
			evExist:=false
		}
		SetWorkingDir,%A_ScriptDir%
	}
	DetectHiddenWindows,Off
	return evExist
}
;[校验Everything是否可正常返回搜索结果]
EverythingCheck:
DeleteFile(A_Temp "\" RunAnyZz "\RunAnyEv.ahk")
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
RegWrite,REG_SZ,HKEY_CURRENT_USER\SOFTWARE\RunAny,EvTotResults,`%val`%
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
),%A_Temp%\%RunAnyZz%\RunAnyEv.ahk
Sleep, 200
Run,%A_AhkPath%%A_Space%"%A_Temp%\%RunAnyZz%\RunAnyEv.ahk"
return
EverythingCheckResults:
	RegRead,EvTotResults,HKEY_CURRENT_USER\SOFTWARE\RunAny,EvTotResults
	if(EvTotResults>0){
		SetTimer,EverythingCheckResults,Off
		Gosub,RunAny_SearchBar
		ShowTrayTip("","Everything索引更新完成",5,17)
		Gosub,Menu_Reload
	}
return
EverythingQuery(EvCommandStr){
	ev := new everything
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
		if(!FileExist(objFullPathName))
			continue
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
					if(MenuObj.HasKey(objFileNameNoExeExt)){
						MenuObj[objFileNameNoExeExt]:=objFullPathName
						MenuObjSearch[objFileName]:=objFullPathName
					}
				}else if(chooseNewFlag && objFullPathNameVersionOld=objFullPathNameVersionNew){
					MenuObjEv[objFileNameNoExeExt]:=objFullPathName
					if(MenuObj.HasKey(objFileNameNoExeExt)){
						MenuObj[objFileNameNoExeExt]:=objFullPathName
						MenuObjSearch[objFileName]:=objFullPathName
					}
				}
				continue
			}
			;版本相同则取最新修改时间，时间相同或小于则不改变
			if(EvExeMTimeNew && !chooseNewFlag){
				continue
			}
		}
		MenuObjEv[objFileNameNoExeExt]:=objFullPathName
		if(MenuObj.HasKey(objFileNameNoExeExt)){
			MenuObj[objFileNameNoExeExt]:=objFullPathName
			MenuObjSearch[objFileName]:=objFullPathName
		}
	}
	return ev.GetNumFileResults()
}
EverythingNoPathSearchStr(){
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
			outVar:=RegExReplace(itemVar,"iS)^([^|]+?\.[a-zA-Z0-9-_]+)($| .*)","$1")	;去掉参数
			;[过滤掉所有不是无路径的菜单项]
			if(InStr(EvCommandStr,"|^" outVar "$|")){
				MenuObjEvPathEmptyReason[itemVar]:="重复的无路径应用"
				continue
			}else if(itemMode!=1 && itemMode!=8){
				MenuObjEvPathEmptyReason[itemVar]:="启动模式不是程序"
				continue
			}else if(outVar="iexplore.exe" && FileExist(A_ProgramFiles "\Internet Explorer\iexplore.exe")){
				MenuObj["iexplore"]:=A_ProgramFiles "\Internet Explorer\iexplore.exe"
				continue
			}else if(itemMode=1 && (InStr(outVar,"..\") || RegExMatch(outVar,"S)\\|\/|\:|\*|\?|\""|\<|\>|\|") || RegExMatch(outVar,"S)^%.*?%$") )){
				MenuObjEvPathEmptyReason[outVar]:="启动软件名带有特殊字符"
				continue
			}else if(itemMode=1 && (FileExist(A_WinDir "\" outVar) || FileExist(A_WinDir "\system32\" outVar))){
				MenuObjEvPathEmptyReason[outVar]:="属于Windows和System32系统路径软件"
				continue
			}else if(itemMode=8){
				MenuObjEvPathEmptyReason[outVar]:="插件脚本函数格式"
				if(RegExMatch(itemVar,"iS).+?\[.+?\]%?\(.*?%"".+?""%.*?\)")){
					outVar:=RegExReplace(itemVar,"iS).+?\[.+?\]%?\(.*?%""(.+?)""%.*?\)","$1")
					if(InStr(outVar,"..\")
						|| RegExMatch(outVar,"S)\\|\/|\:|\*|\?|\""|\<|\>|\|") 
						|| RegExMatch(outVar,"S)^%.*?%$") 
						|| FileExist(A_WinDir "\" outVar) || FileExist(A_WinDir "\system32\" outVar)){
						continue
					}
				}else{
					continue
				}
			}
			outVarStr:=outVar
			;正则转义特殊字符
			if(RegExMatch(outVarStr, RegexEscapeNoPointStr)){
				outVarStr:=StrListEscapeReplace(outVarStr, RegexEscapeNoPointList, "\")
			}
			outVarStr:=StrReplace(outVarStr,".","\.")
			EvCommandStr.="^" outVarStr "$|"
			outVarNoExeExt:=RegExReplace(outVar,"iS)\.exe$","")
			MenuObj[outVarNoExeExt]:=""
			MenuObjSearch[outVar]:=""
		}
	}
	if(EvCommandStr!=""){
		EvCommandStr:=SubStr(EvCommandStr, 1, -StrLen("|"))
		EvCommandStr:="regex:""" EvCommandStr """"
	}
	return EvCommandStr
}
;[使用everything搜索单个exe程序]
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
;[IPC方式和everything进行通讯，修改于AHK论坛]
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
	;设置正则表达式搜索
	SetRegex(aValue)
	{
		this.eMatchWholeWord := aValue
		dllcall(everyDLL "\Everything_SetRegex",int,aValue)
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
		Gosub,Desktop_Append
		Gosub,Menu_Reload
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
-办公(&Work)|doc docx xls xlsx ppt pptx wps et dps
	word(&W)|winword.exe
	Excel(&E)|excel.exe
	PPT(&T)|powerpnt.exe
	;以【--】开头名称表示2级分类
	--WPS(&S)
		WPS(&W)|WPS.exe
		ET(&E)|et.exe
		WPP(&P)|wpp.exe
	--
-网址(U&RL)
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
	;左手回车	<+Space|{Enter}::
	;左手删除	LShift & CapsLock|{Delete}::
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

#Include RunAnyGui.ahk