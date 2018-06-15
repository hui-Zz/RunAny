/*
╔══════════════════════════════════════════════════
║【RunAny】一劳永逸的快速启动工具 v5.4.0 @2018.06.15
║ https://github.com/hui-Zz/RunAny
║ by hui-Zz 建议：hui0.0713@gmail.com
║ 讨论QQ群：[246308937]、3222783、493194474
╚══════════════════════════════════════════════════
*/
#NoEnv                  ;~不检查空变量为环境变量
#Persistent             ;~让脚本持久运行
#WinActivateForce       ;~强制激活窗口
#SingleInstance,Force   ;~运行替换旧实例
ListLines,Off           ;~不显示最近执行的脚本行
AutoTrim,On             ;~自动去除变量中前导和尾随空格制表符
SendMode,Input          ;~使用更速度和可靠方式发送键鼠点击
CoordMode,Menu          ;~相对于整个屏幕
SetBatchLines,-1        ;~脚本全速执行
SetWorkingDir,%A_ScriptDir% ;~脚本当前工作目录
;~ StartTick:=A_TickCount   ;若要评估出menu初始化时间
global RunAnyZz:="RunAny"   ;名称
global RunAnyConfig:="RunAnyConfig.ini" ;~配置文件
global PluginsDir:="RunPlugins"	;~插件目录
global RunAny_update_version:="5.4.0"
global RunAny_update_time:="2018.06.15"
Gosub,Var_Set       ;~参数初始化
Gosub,Run_Exist     ;~调用判断依赖
Gosub,Plugins_Read  ;~插件脚本读取
global MenuObj:=Object()        ;~程序全径
global MenuObjKey:=Object()     ;~程序热键
global MenuObjName:=Object()    ;~程序别名
global MenuObjParam:=Object()   ;~程序参数
global MenuObjExt:=Object()     ;~后缀对应菜单
global MenuExeList:=Object()    ;~程序数据数组
global MenuTreeKey:=Object()    ;~分类热键
global MenuObjTree1:=Object()   ;~分类目录程序全数据1
global MenuObjTree2:=Object()   ;~分类目录程序全数据2
MenuObj.SetCapacity(10240)
MenuExeList.SetCapacity(1024)
;══════════════════════════════════════════════════════════════════
;~;[初始化菜单显示热键]
Hotkey, IfWinNotActive, ahk_group DisableGUI
HotKeyList:=["MenuHotKey","MenuHotKey2","EvHotKey","OneHotKey","TreeHotKey1","TreeHotKey2","TreeIniHotKey1","TreeIniHotKey2","RunASetHotKey","RunAReloadHotKey","RunASuspendHotKey","RunAExitHotKey","PluginsManageHotKey"]
RunList:=["Menu_Show1","Menu_Show2","Ev_Show","One_Show","Menu_Edit1","Menu_Edit2","Menu_Ini","Menu_Ini2","Menu_Set","Menu_Reload","Menu_Suspend","Menu_Exit","Plugins_Manage"]
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
Gosub,MenuTray	;~托盘菜单
if(errorKeyStr){
	gosub,Menu_Set
	if(ki!=1 && ki!=2)
		SendInput,^{Tab}
	MsgBox,16,RunAny热键配置不正确,% "热键错误：`n" errorKeyStr "`n请设置正确热键后重启RunAny"
	return
}
;══════════════════════════════════════════════════════════════════
;~;[初始化everything安装路径]
evExist:=true
EvPath:=Var_Read("EvPath")
DetectHiddenWindows,On
while !WinExist("ahk_exe Everything.exe")
{
	Sleep,100
	if(A_Index>10){
		EvPathRun:=Get_Transform_Val(EvPath)
		if(EvPathRun && FileExist(EvPathRun)){
			Run,%EvPathRun% -startup
			Sleep,300
			break
		}else if(FileExist(A_ScriptDir "\Everything\Everything.exe")){
			Run,%A_ScriptDir%\Everything\Everything.exe -startup
			EvPath=%A_ScriptDir%\Everything\Everything.exe
			Sleep,2000
			break
		}else{
			gosub,Menu_Set
			MsgBox,17,,RunAny需要Everything极速识别程序的路径`n请使用以下任意一种方式：`n
				(
* 运行Everything后重启RunAny`n* 设置RunAny中Everything正确安装路径`n* 下载Everything并安装后再运行RunAny：http://www.voidtools.com/
				)
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
;~;[如果需要自动关闭everything]
if(EvAutoClose && EvPath){
	EvPathRun:=Get_Transform_Val(EvPath)
	Run,%EvPathRun% -exit
}
DetectHiddenWindows,Off
;══════════════════════════════════════════════════════════════════
;~;[后缀图标初始化]
Gosub,Icon_FileExt_Set
;#应用菜单数组#网址菜单名数组及地址队列#
menuRoot1:=Object(),menuWebRoot1:=Object(),menuWebList1:=Object()
;菜单级别：初始为根菜单RunAny
menuRoot1.Push(RunAnyZz . "1")
menuWebRoot1.Push(RunAnyZz . "Web1")
menuWebRoot1.Push(RunAnyZz . "1")
MenuObjTree1[RunAnyZz . "1"]:=Object()
global menu2:=MENU2FLAG
;~;[读取带图标的自定义应用菜单]
Menu_Read(iniVar1,menuRoot1,1,menuWebRoot1,menuWebList1,false,1)
Menu,% menuRoot1[1],Add
;~;[如果有第2菜单则开始加载]
if(menu2){
	menuRoot2:=Object(),menuWebRoot2:=Object(),menuWebList2:=Object()
	menuRoot2.Push(RunAnyZz . "2")
	menuWebRoot2.Push(RunAnyZz . "Web2")
	menuWebRoot2.Push(RunAnyZz . "2")
	MenuObjTree2[RunAnyZz . "2"]:=Object()
	Menu_Read(iniVar2,menuRoot2,1,menuWebRoot2,menuWebList2,false,2)
}
;~;[在图标加载前先运行插件]
Gosub,AutoRun_Effect
;~;[循环为菜单中EXE程序添加图标，过程较慢]
For k, v in MenuExeList
{
	try{
		Menu,% v["menuName"],Icon,% v["menuItem"],% v["itemPath"]
	}catch{}
}
;#菜单已经加载完毕，托盘图标变化
try Menu,Tray,Icon,% AnyIconS[1],% AnyIconS[2]
;#如果是第一次运行#
if(ini){
	ini:=false
	TrayTip,,RunAny菜单初始化完成`n右击任务栏图标设置,3,1
	gosub,Menu_About
	gosub,Menu_Show1
}
Gosub,GuiIcon_Set
if(ReloadEditFlag){
	RegWrite, REG_SZ, HKEY_CURRENT_USER, SOFTWARE\RunAny, ReloadEditFlag, 0
	gosub,Menu_Edit
}

return

;══════════════════════════════════════════════════════════════════
;~;[读取配置并开始创建菜单]
;══════════════════════════════════════════════════════════════════
Menu_Read(iniReadVar,menuRootFn,menuLevel,menuWebRootFn,menuWebList,webRootShow,TREE_NO){
	Loop, parse, iniReadVar, `n, `r
	{
		try{
			Z_LoopField=%A_LoopField%
			if(InStr(Z_LoopField,";")=1 || Z_LoopField=""){
				continue
			}
			if(InStr(Z_LoopField,"-")=1){
				;~;[生成节点树层级结构]
				menuItem:=RegExReplace(Z_LoopField,"S)^-+")
				menuLevel:=StrLen(RegExReplace(Z_LoopField,"S)(^-+).*","$1"))
				if(InStr(menuItem,"|")){
					menuItems:=StrSplit(menuItem,"|")
					menuItem:=menuItems[1]
					;~;[读取菜单关联后缀]
					Loop, parse,% menuItems[2],%A_Space%
					{
						MenuObjExt[(A_LoopField)]:=menuItem
					}
				}
				if(menuItem!=""){
					Menu,%menuItem%,add
					try Menu,% menuRootFn[menuLevel],add,%menuItem%,:%menuItem%
					try Menu,% menuRootFn[menuLevel],Icon,%menuItem%,% TreeIconS[1],% TreeIconS[2]
					Menu,%menuItem%,Delete, 1&
					menuLevel+=1	;比初始根菜单加一级
					menuRootFn[menuLevel]:=menuItem		;从这之后内容项都添加到该级别菜单中
					if(!IsObject(MenuObjTree%TREE_NO%[menuItem]))
						MenuObjTree%TREE_NO%[menuItem]:=Object()
					;~;[分割Tab获取菜单自定义热键]
					if(InStr(menuItem,"`t")){
						menuKeyStr:=RegExReplace(menuItem, "S)\t+", A_Tab)
						menuKeys:=StrSplit(menuKeyStr,"`t")
						if(menuKeys[2]){
							MenuTreeKey[menuKeys[2]]:=menuItem
							Hotkey,% menuKeys[2],Menu_Key_Show,On
						}
					}
				}else if(menuRootFn[menuLevel]){
					Menu,% menuRootFn[menuLevel],Add
					MenuObjTree%TREE_NO%[(menuRootFn[menuLevel])].Push(Z_LoopField)
				}
				continue
			}
			if(menuRootFn[menuLevel]="")
				continue
			;除短语和网址以外的项目转换配置中%%的变量
			itemLen:=StrLen(Z_LoopField)
			if(InStr(Z_LoopField,";",,0,1)!=itemLen && !RegExMatch(Z_LoopField,"iS)([\w-]+://?|www[.]).*")){
				Z_LoopField:=Get_Transform_Val(Z_LoopField)
			}
			;~添加到分类目录程序全数据
			MenuObjTree%TREE_NO%[(menuRootFn[menuLevel])].Push(Z_LoopField)
			MenuObjEXE:=Object()	;~软件对象
			flagEXE:=false			;~添加exe菜单项目
			IconFail:=false			;~是否显示无效项图标
			if(InStr(Z_LoopField,"|")){
				;~;[生成有前缀备注的应用]
				menuDiy:=StrSplit(Z_LoopField,"|")
				appName:=RegExReplace(menuDiy[2],"iS)\.exe($| .*)")	;去掉后缀或参数，取应用名
				item:=MenuObj[appName]
				if(item){
					SplitPath, item,,, FileExt  ; 获取文件扩展名.
					appParm:=RegExReplace(menuDiy[2],"iS).*?\." FileExt "($| .*)","$1")	;去掉应用名，取参数
					MenuObjParam[menuDiy[1]]:=item . appParm
					flagEXE:=true
				}else{
					item:=menuDiy[2]
					if(RegExMatch(item,"iS).*?\.exe .*"))
						item:=RegExReplace(item,"iS)(.*?\.exe) .*","$1")	;只去参数
					SplitPath, item,,, FileExt  ; 获取文件扩展名.
					;~;如果是有效全路径或系统程序则保留显示
					if(RegExMatch(item,"iS)^(\\\\|.:\\).*?\.exe$") && FileExist(item))
						flagEXE:=true
					else if(FileExist(A_WinDir "\" item) || FileExist(A_WinDir "\system32\" item))
						flagEXE:=true
					;~;如果是有效程序、不隐藏失效、不是exe程序则添加该菜单项功能
					if(flagEXE || !HideFail || FileExt!="exe")
						MenuObjParam[menuDiy[1]]:=menuDiy[2]
				}
				if(FileExt="exe"){
					if(flagEXE){
						MenuObjEXE["menuName"]:=menuRootFn[menuLevel]
						MenuObjEXE["menuItem"]:=menuDiy[1]
						MenuObjEXE["itemPath"]:=item
						MenuExeList.Push(MenuObjEXE)
					}else{
						IconFail:=true
					}
					if(!HideFail)
						flagEXE:=true
					;~;[添加菜单项]
					if(flagEXE){
						Menu,% menuRootFn[menuLevel],add,% menuDiy[1],Menu_Run
						if(IconFail)
							Menu,% menuRootFn[menuLevel],Icon,% menuDiy[1],SHELL32.dll,124
					}
				}else{
					Menu_Add(menuRootFn[menuLevel],menuDiy[1],MenuObjParam[menuDiy[1]],menuRootFn,menuWebRootFn,menuWebList,webRootShow)
				}
				;~;[分割Tab获取应用自定义热键]
				if(InStr(menuDiy[1],"`t")){
					menuKeyStr:=RegExReplace(menuDiy[1], "S)\t+", A_Tab)
					menuKeys:=StrSplit(menuKeyStr,"`t")
					if(menuKeys[2]){
						MenuObjKey[menuKeys[2]]:=MenuObjParam[menuDiy[1]]
						MenuObjName[menuKeys[2]]:=menuKeys[1]
						Hotkey,% menuKeys[2],Menu_Key_Run,On
					}
				}
				continue
			}
			;~;[生成完全路径的应用]
			if(RegExMatch(Z_LoopField,"iS)^(\\\\|.:\\).*?\.exe$")){
				SplitPath,Z_LoopField,fileName,,,nameNotExt
				MenuObj[nameNotExt]:=Z_LoopField
				if(FileExist(Z_LoopField)){
					MenuObjEXE["menuName"]:=menuRootFn[menuLevel]
					MenuObjEXE["menuItem"]:=nameNotExt
					MenuObjEXE["itemPath"]:=Z_LoopField
					MenuExeList.Push(MenuObjEXE)
					flagEXE:=true
				}else{
					IconFail:=true
				}
				if(!HideFail)
					flagEXE:=true
				;~;[添加菜单项]
				if(flagEXE){
					Menu,% menuRootFn[menuLevel],add,% nameNotExt,Menu_Run
					if(IconFail)
						Menu,% menuRootFn[menuLevel],Icon,% menuDiy[1],SHELL32.dll,124
				}
				continue
			}
			;~;[生成已取到的应用]
			if(RegExMatch(Z_LoopField,"iS)\.exe$")){
				appName:=RegExReplace(Z_LoopField,"iS)\.exe$")
				if(MenuObj[appName]){
					flagEXE:=true
				}else if(FileExist(A_WinDir "\" Z_LoopField) || FileExist(A_WinDir "\system32\" Z_LoopField)){
					flagEXE:=true
					MenuObj[appName]:=Z_LoopField
				}else if(!HideFail){
					MenuObj[appName]:=Z_LoopField
				}
				if(flagEXE){
					MenuObjEXE["menuName"]:=menuRootFn[menuLevel]
					MenuObjEXE["menuItem"]:=appName
					MenuObjEXE["itemPath"]:=MenuObj[appName]
					MenuExeList.Push(MenuObjEXE)
				}else{
					IconFail:=true
				}
				if(!HideFail)
					flagEXE:=true
				;~;[添加菜单项]
				if(flagEXE){
					Menu,% menuRootFn[menuLevel],add,% appName,Menu_Run
					if(IconFail)
						Menu,% menuRootFn[menuLevel],Icon,% appName,SHELL32.dll,124
				}
			}else{
				if(!MenuObj[Z_LoopField])
					MenuObj[Z_LoopField]:=Z_LoopField
				Menu_Add(menuRootFn[menuLevel],Z_LoopField,MenuObj[Z_LoopField],menuRootFn,menuWebRootFn,menuWebList,webRootShow)
			}
		} catch e {
			MsgBox,16,构建菜单出错,% "菜单名：" menuRootFn[menuLevel] "`n菜单项：" A_LoopField "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
		}
	}
	For key, value in MenuObjParam
	{
		MenuObj[key]:=value
	}
	;#添加网址菜单的批量搜索功能
	Loop,% menuWebRootFn.MaxIndex()
	{
		if(A_Index!=1){	;忽略比较menuWebRootFn第1层web菜单
			webRoot:=menuWebRootFn[A_Index]
			if(webRoot = menuRootFn[1]){
				if(webRootShow){
					Menu,% menuWebRootFn[1],add
					Menu,% menuWebRootFn[1],add,&1批量搜索,Web_Run
					Menu,% menuWebRootFn[1],Icon,&1批量搜索,% UrlIconS[1],% UrlIconS[2]
				}else if(menu2){
					Menu,% menuWebRootFn[1],add	;避免菜单2无网址而报错
				}
			}else{
				if(menu2){
					Menu,%webRoot%,add	;避免菜单2无网址而报错
				}
				Menu,%webRoot%,add,&1批量搜索%webRoot%,Web_Run
				Menu,%webRoot%,Icon,&1批量搜索%webRoot%,% UrlIconS[1],% UrlIconS[2]
			}
		}
	}
}
;══════════════════════════════════════════════════════════════════
;~;[生成菜单(判断后缀创建图标)]
Menu_Add(menuName,menuItem,item,menuRootFn,menuWebRootFn,menuWebList,webRootShow){
	if(!menuName || !item)
		return
	try {
		itemLen:=StrLen(item)
		SplitPath, item,,, FileExt  ; 获取文件扩展名.
		if(InStr(item,";",,0,1)=itemLen){  ; {短语}
			Menu,%menuName%,add,%menuItem%,Menu_Run
			Menu,%menuName%:,add,%menuItem%,Menu_Run
			Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,2
			Menu,%menuName%:,Icon,%menuItem%,SHELL32.dll,2
			if(menuName = menuRootFn[1]){
				Menu,% menuWebRootFn[1],Add,%menuItem%,Menu_Run
				Menu,% menuWebRootFn[1],Icon,%menuItem%,SHELL32.dll,2
				webRootShow:=true
			}else{
				Menu,% menuWebRootFn[1],Add,%menuName%:, :%menuName%:
			}
			if(HideSend)
				Menu,%menuName%,Delete,%menuItem%
			return
		}
		if(InStr(item,"::",,0,1)=itemLen-1){	; {发送热键}
			Menu,%menuName%,add,%menuItem%,Menu_Run
			Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,100
			return
		}
		if(RegExMatch(item,"iS)([\w-]+://?|www[.]).*")){  ; {网址}
			website:=RegExReplace(item,"iS)[\w-]+://?((\w+\.)+\w+).*","$1")
			webIcon:=A_ScriptDir "\RunIcon\" website ".ico"
			Menu,%menuName%,add,%menuItem%,Menu_Run
			Menu,%menuName%:,add,%menuItem%,Menu_Run
			if(FileExist(webIcon)){
				try{
					Menu,%menuName%,Icon,%menuItem%,%webIcon%,0
					Menu,%menuName%:,Icon,%menuItem%,%webIcon%,0
				} catch e {
					Menu,%menuName%,Icon,%menuItem%,% UrlIconS[1],% UrlIconS[2]
					Menu,%menuName%:,Icon,%menuItem%,% UrlIconS[1],% UrlIconS[2]
				}
			}else{
				Menu,%menuName%,Icon,%menuItem%,% UrlIconS[1],% UrlIconS[2]
				Menu,%menuName%:,Icon,%menuItem%,% UrlIconS[1],% UrlIconS[2]
			}
			;~ [添加到网址菜单]
			if(menuName = menuRootFn[1]){
				Menu,% menuWebRootFn[1],Add,%menuItem%,Menu_Run
				if(FileExist(webIcon)){
					Menu,% menuWebRootFn[1],Icon,%menuItem%,%webIcon%,0
				}else{
					Menu,% menuWebRootFn[1],Icon,%menuItem%,% UrlIconS[1],% UrlIconS[2]
				}
				webRootShow:=true
			}else{
				Menu,% menuWebRootFn[1],Add,%menuName%:, :%menuName%:
			}
			menuWebList[(menuName ":")].=menuItem "`n"	; 添加到批量搜索
			if(!HideWeb)
				menuWebList[(menuName)].=menuItem "`n"	; 添加到批量搜索
			;~ [创建网址所在的不重复菜单节点]
			menuWebSame:=false
			Loop,% menuWebRootFn.MaxIndex()
			{
				if(menuWebRootFn[A_Index]=menuName || menuWebRootFn[A_Index]=menuName ":"){
					menuWebSame:=true
					break
				}
			}
			if(!menuWebSame){
				menuWebRootFn.Push(menuName ":")
				if(!HideWeb)
					menuWebRootFn.Push(menuName)
			}
			if(HideWeb)
				Menu,%menuName%,Delete,%menuItem%
			return
		}
		Menu,%menuName%,add,%menuItem%,Menu_Run
		if(InStr(FileExist(item), "D")){  ; {目录}
			Menu,%menuName%,Icon,%menuItem%,% FolderIconS[1],% FolderIconS[2]
		}else if(Ext_Check(item,itemLen,".lnk")){  ; {快捷方式}
			try{
				FileGetShortcut, %item%, OutItem, , , , OutIcon, OutIconNum
				if(OutIcon){
					Menu,%menuName%,Icon,%menuItem%,%OutIcon%,%OutIconNum%
				}else{
					Menu,%menuName%,Icon,%menuItem%,%OutItem%
				}
			} catch e {
				Menu,%menuName%,Icon,%menuItem%,% LNKIconS[1],% LNKIconS[2]
			}
		}else{  ; {处理未知的项目图标}
			If(FileExt){
				try{
					RegRead, regFileExt, HKEY_CLASSES_ROOT, .%FileExt%
					RegRead, regFileIcon, HKEY_CLASSES_ROOT, %regFileExt%\DefaultIcon
					regFileIconS:=StrSplit(regFileIcon,",")
					Menu,%menuName%,Icon,%menuItem%,% regFileIconS[1],% regFileIconS[2]
				}catch{}
			}else if(!HideFail){
				Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,124
			}else{
				Menu,%menuName%,Delete,%menuItem%
			}
		}
	} catch e {
		MsgBox,16,判断后缀创建菜单项出错,% "菜单名：" menuName "`n菜单项：" menuItem "`n路径：" item "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
	}
}
Menu_Show1:
	if(GetKeyState("Ctrl")){
		Run,%iniPath%
		return
	}
	MENU_NO:=1
	iniFileShow:=iniPath
	gosub,Menu_Show
return
Menu_Show2:
	MENU_NO:=2
	iniFileShow:=iniPath2
	gosub,Menu_Show
return
;~;[显示菜单]
Menu_Show:
	try{
		global selectZz:=Get_Zz()
		RunAnyMenu:=A_ScriptDir "\" PluginsDir "\RunAny_Menu.ahk"
		if(ahkFlag && FileExist(RunAnyMenu) && PluginsObjList["RunAny_Menu.ahk"]){
			Run,%ahkExePath%%A_Space%%RunAnyMenu%
		}
		if(selectZz!=""){
			if(Candy_isFile){
				SplitPath, selectZz,,, FileExt  ; 获取文件扩展名.
				try{
					extMenuName:=MenuObjExt[FileExt]
					if(extMenuName){
						if(MenuObjTree%MENU_NO%[extMenuName].MaxIndex()=1){
							itemContent:=MenuObjTree%MENU_NO%[extMenuName][1]
							MenuShowMenuRun:=Get_Obj_Name(itemContent)
							gosub,Menu_Run
						}else{
							if(!HideAddItem){
								Menu,%extMenuName%,Insert, ,0【添加到此菜单】,Menu_Add_File_Item
								Menu,%extMenuName%,Default,0【添加到此菜单】
								Menu,%extMenuName%,Icon,0【添加到此菜单】,SHELL32.dll,166
							}
							Menu,%extMenuName%,Show
							if(!HideAddItem)
								Menu,%extMenuName%,Delete,0【添加到此菜单】
						}
					}else{
						if(!HideAddItem)
							Menu_Add_Del_Temp(1,MENU_NO,"0【添加到此菜单】","Menu_Add_File_Item","SHELL32.dll","166")
						Menu,% menuRoot%MENU_NO%[1],Show
						if(!HideAddItem)
							Menu_Add_Del_Temp(0,MENU_NO,"0【添加到此菜单】")
					}
				}catch{
					Menu,% menuRoot%MENU_NO%[1],Show
				}
				return
			}
			if(MENU_NO=1){
				openFlag:=false
				Loop, parse, selectZz, `n, `r, %A_Space%%A_Tab%
				{
					if(!A_LoopField)
						continue
					;一键打开网址
					if(OneKeyWeb && RegExMatch(A_LoopField,"iS)([\w-]+://?|www[.]).*")){
						Run_Search(A_LoopField,"",BrowserPath)
						openFlag:=true
						continue
					}
					;一键磁力下载
					if(OneKeyMagnet && InStr(A_LoopField,"magnet:?xt=urn:btih:")=1){
						Run,%A_LoopField%
						openFlag:=true
						continue
					}
					if(RegExMatch(A_LoopField,"S)^(\\\\|.:\\)")){
						;一键打开目录
						if(OneKeyFolder && InStr(FileExist(A_LoopField), "D")){
							If(TcPathRun){
								Run,%TcPathRun%%A_Space%"%A_LoopField%"
							}else{
								Run,%A_LoopField%
							}
							openFlag:=true
							continue
						}
						;一键打开文件
						if(OneKeyFile && Fileexist(A_LoopField)){
							Run,%A_LoopField%
							openFlag:=true
							continue
						}
					}
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
			if(!HideUnSelect){
				Menu,% menuWebRoot%MENU_NO%[1],Show
				return
			}
		}
		;#其他弹出应用菜单#
		Menu,% menuRoot%MENU_NO%[1],Show
	}catch{}
return
;~;[菜单热键显示]
Menu_Key_Show:
	global selectZz:=Get_Zz()
	try {
		thisMenuName:=menuTreekey[(A_ThisHotkey)]
		Menu,% thisMenuName,Show
	}catch{}
return
;~;[菜单运行]
Menu_Run:
	any:=MenuObj[(A_ThisMenuItem)]
	if(MenuShowMenuRun){
		any:=MenuObj[(MenuShowMenuRun)]
		MenuShowMenuRun:=""
	}
	SplitPath, any, , dir
	if(dir)
		SetWorkingDir,%dir%
	if(!HideRecent && !RegExMatch(A_ThisMenuItem,"S)^&1|2"))
		gosub,Menu_Recent
	try {
		anyLen:=StrLen(any)
		If(InStr(any,";",,0,1)=anyLen){
			StringLeft, any, any, anyLen-1
			Send_Str_Zz(any,true)	;[输出短语]
			return
		}
		If(InStr(any,"::",,0,1)=anyLen-1){
			StringLeft, any, any, anyLen-2
			Send_Key_Zz(any)	;[输出热键]
			return
		}
		;[按住Ctrl键打开应用所在目录，只有目录则直接打开]
		If(!selectZz && !Candy_isFile && (GetKeyState("Ctrl") || InStr(FileExist(any), "D"))){
			If(TcPathRun){
				Run,%TcPathRun%%A_Space%"%any%"
			}else if(InStr(FileExist(any), "D")){
				Run,%any%
			}else{
				Run,% "explorer.exe /select," any
			}
			return
		}
		if(selectZz!=""){
			firstFile:=RegExReplace(selectZz,"(.*)(\n|\r).*","$1")  ;取第一行
			if(Candy_isFile=1 || Fileexist(selectZz) || Fileexist(firstFile)){
				if(GetKeyState("Ctrl")){
					gosub,Menu_Add_File_Item
					return
				}
				selectZzStr:=""
				Loop, parse, selectZz, `n, `r, %A_Space%%A_Tab%
				{
					if(!A_LoopField)
						continue
					selectZzStr.="""" . A_LoopField . """" . A_Space
				}
				StringTrimRight, selectZzStr, selectZzStr, 1
				if(GetKeyState("Shift")){
					Run,*RunAs %any%%A_Space%%selectZzStr%
					return
				}
				Run,%any%%A_Space%%selectZzStr%
			}else if(RegExMatch(any,"iS)([\w-]+://?|www[.]).*")){
				Run_Search(any,selectZz)
			}else{
				Run,%any%
			}
			return
		}
		If(GetKeyState("Shift")){	;[按住Shift则是管理员身份运行]
			Run,*RunAs %any%
		}else{
			menuKeys:=StrSplit(A_ThisMenuItem,"`t")
			thisMenuName:=menuKeys[1]
			if(thisMenuName && RegExMatch(thisMenuName,"S).*?_:(\d{1,2})$")){
				menuTrNum:=RegExReplace(thisMenuName,"S).*?_:(\d{1,2})$","$1")
				Run_Tr(any,menuTrNum,true)
			}else{
				Run,%any%
			}
		}
	} catch e {
		MsgBox,16,%A_ThisMenuItem%运行出错,% "运行路径：" any "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
	}finally{
		SetWorkingDir,%A_ScriptDir%
	}
return
;~;[菜单热键运行]
Menu_Key_Run:
	any:=menuObjkey[(A_ThisHotkey)]
	thisMenuName:=MenuObjName[(A_ThisHotkey)]
	SplitPath, any, , dir
	if(dir)
		SetWorkingDir,%dir%
	try {
		anyLen:=StrLen(any)
		If(InStr(any,"::",,0,1)=anyLen-1){
			StringLeft, any, any, anyLen-2
			Send_Key_Zz(any)	;[输出热键]
			return
		}
		If(InStr(any,";",,0,1)=anyLen){
			StringLeft, any, any, anyLen-1
			Send_Str_Zz(any,true)	;[输出短语]
			return
		}
		selectZz:=Get_Zz()
		if(selectZz){
			firstFile:=RegExReplace(selectZz,"(.*)(\n|\r).*","$1")  ;取第一行
			if(Candy_isFile=1 || Fileexist(selectZz) || Fileexist(firstFile)){
				selectZzStr:=""
				Loop, parse, selectZz, `n, `r, %A_Space%%A_Tab%
				{
					if(!A_LoopField)
						continue
					selectZzStr.="""" . A_LoopField . """" . A_Space
				}
				StringTrimRight, selectZzStr, selectZzStr, 1
				Run,%any%%A_Space%%selectZzStr%
			}else if(RegExMatch(any,"iS)([\w-]+://?|www[.]).*")){
				Run_Search(any,selectZz)
			}else{
				Run_Zz(any)
			}
		}else{
			if(thisMenuName && RegExMatch(thisMenuName,"S).*?_:(\d{1,2})$")){
				menuTrNum:=RegExReplace(thisMenuName,"S).*?_:(\d{1,2})$","$1")
				Run_Tr(any,menuTrNum)
			}else{
				Run_Zz(any)
			}
		}
	} catch e {
		MsgBox,16,%thisMenuName%运行出错,% "运行路径：" any "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
	}finally{
		SetWorkingDir,%A_ScriptDir%
	}
return
;~;[菜单最近运行]
Menu_Recent:
	if(!MenuCommonList[1]){
		MenuCommonList[1]:="&1 " A_ThisMenuItem
		MenuObj[MenuCommonList[1]]:=any
		Menu,% menuRoot1[1],Add,% MenuCommonList[1],Menu_Run
	}else if(MenuCommonList[1]!="&1" A_Space A_ThisMenuItem){
		if(!MenuCommonList[2]){
			MenuCommonList[2]:="&2" A_Space A_ThisMenuItem
			MenuObj[MenuCommonList[2]]:=any
			Menu,% menuRoot1[1],Add,% MenuCommonList[2],Menu_Run
		}else if(MenuCommonList[1] && MenuCommonList[2]){
			MenuCommon1:=MenuCommonList[1]
			MenuCommon2:=MenuCommonList[2]
			MenuCommonList[1]:="&1" A_Space A_ThisMenuItem
			MenuCommonList[2]:=RegExReplace(MenuCommon1,"&1","&2")
			MenuObj[MenuCommonList[1]]:=any
			MenuObj[MenuCommonList[2]]:=MenuObj[(MenuCommon1)]
			Menu,% menuRoot1[1],Rename,% MenuCommon1,% MenuCommonList[1]
			Menu,% menuRoot1[1],Rename,% MenuCommon2,% MenuCommonList[2]
		}
	}
return
;~;[所有菜单(添加/删除)临时项]
Menu_Add_Del_Temp(addDel=1,TREE_NO=1,mName="",LabelName="",mIcon="",mIconNum=""){
	if(!mName)
		return
	For kk, vv in MenuObjTree%TREE_NO%
	{
		if(addDel){
			Menu,%kk%,Insert, ,%mName%,%LabelName%
			Menu,%kk%,Icon,%mName%,%mIcon%,%mIconNum%
		}else{
			Menu,%kk%,Delete,%mName%
		}
	}
}
;~;[执行批量搜索]
Web_Run:
	webName:=RegExReplace(A_ThisMenuItem,"iS)^&1批量搜索")
	if(webName){
		webList:=(A_ThisHotkey=MenuHotKey2) ? menuWebList2[(webName)] : menuWebList1[(webName)]
	}else{
		webList:=(A_ThisHotkey=MenuHotKey2) ? menuWebList2[(menuRoot2[1])] : menuWebList1[(menuRoot1[1])]
	}
	if(JumpSearch){
		gosub,Web_Search
	}else{
		MsgBox,33,开始批量搜索%webName%,确定用【%selectZz%】批量搜索以下网站：`n%webList%
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
			Run_Search(any,selectZz,BrowserPath)
		}
	}
return
Run_Zz(program){
	fullPath:=Get_Obj_Path(program)
	path:=fullPath ? fullPath : program
	DetectHiddenWindows, Off
	If !WinExist("ahk_exe" . path)
		Run,%program%
	else
		WinGet,l,List,ahk_exe %path%
		if l=1
			If WinActive("ahk_exe" . path)
				WinMinimize
			else
				WinActivate
		else
			WinActivateBottom,ahk_exe %path%
	return
}
Run_Tr(program,trNum,newOpen=false){
	fullPath:=Get_Obj_Path(program)
	path:=fullPath ? fullPath : program
	DetectHiddenWindows, Off
	If(newOpen || !WinExist("ahk_exe" . path)){
		Run,%program%
		WinWait,ahk_exe %path%
		;~ WinSet,Style,-0xC00000,
		try WinSet,Style,-0x40000,ahk_exe %path%
		WinSet,Transparent,% trNum/100*255,ahk_exe %path%
	}else
		Run_Zz(program)
	return
}
Run_Search(any,selectZz="",browser=""){
	browserRun:=browser ? browser A_Space : browser
	if(InStr(any,"%s",true)){
		Run,% browserRun StrReplace(any,"%s",selectZz)
	}else if(InStr(any,"%S",true)){
		Run,% browserRun StrReplace(any,"%S",SkSub_UrlEncode(selectZz))
	}else{
		Run,%browserRun%%any%%selectZz%
	}
}
;══════════════════════════════════════════════════════════════════
;~;[一键Everything][搜索选中文字][激活][隐藏]
Ev_Show:
	selectZz:=Get_Zz()
	if(RegExMatch(selectZz,"S)^(\\\\|.:\\).*?$")){
		SplitPath,selectZz,fileName
		selectZz:=fileName
	}
	EvPathRun:=Get_Transform_Val(EvPath)
	IfWinExist ahk_class EVERYTHING
		if selectZz
			Run % EvPathRun " -search """ selectZz """"
		else
			IfWinNotActive
				WinActivate
			else
				WinMinimize
	else
		Run % EvPathRun (selectZz ? " -search """ selectZz """" : "")
return
;~;[一键搜索]
One_Show:
	selectZz:=Get_Zz()
	gosub,One_Search
return
One_Search:
	Loop,parse,OneKeyUrl,`n
	{
		if(A_LoopField){
			Run_Search(A_LoopField,selectZz,BrowserPath)
		}
	}
return
;~;[检查后缀名]
Ext_Check(name,len,ext){
	len_ext:=StrLen(ext)
	site:=InStr(name,ext,,0,1)
	return site!=0 && site=len-len_ext+1
}
;~;[输出短语]
Send_Str_Zz(strZz,tf=false){
	if(tf){
		strZz:=Get_Transform_Val(strZz)
	}
	Candy_Saved:=ClipboardAll
	Clipboard:=strZz
	SendInput,^v
	Sleep,200
	Clipboard:=Candy_Saved
}
;~;[输出热键]
Send_Key_Zz(keyZz){
	SendInput,%keyZz%
}
;~;[获取选中]
Get_Zz(){
	global Candy_isFile
	Candy_Saved:=ClipboardAll
	Clipboard=
	SendInput,^c
	ClipWait,%ClipWaitTime%
	If(ErrorLevel){
		Clipboard:=Candy_Saved
		return
	}
	Candy_isFile:=DllCall("IsClipboardFormatAvailable","UInt",15)
	CandySel=%Clipboard%
	Clipboard:=Candy_Saved
	return CandySel
}
;~;[文本转换为URL编码]
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
;~;获取变量展开转换后的值
Get_Transform_Val(var){
	try{
		Transform,varTemp,Deref,%var%
		return varTemp
	}catch{
		return var
	}
}
;~;[获取分类名称]
Get_Tree_Name(z_item,show_key=true){
	if(InStr(z_item,"|")){
		menuDiy:=StrSplit(z_item,"|")
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
Get_Obj_Name(z_item){
	if(InStr(z_item,"|")){
		menuDiy:=StrSplit(z_item,"|")
		return menuDiy[1]
	}else if(RegExMatch(z_item,"iS)^(\\\\|.:\\).*?\.exe$")){
		SplitPath,itemContent,fileName,,,menuItem
		return menuItem
	}else{
		return RegExReplace(z_item,"iS)\.exe$")
	}
}
;~;[获取应用路径]
Get_Obj_Path(z_item){
	obj_path:=""
	if(InStr(z_item,"|")){
		menuDiy:=StrSplit(z_item,"|")
		obj_path:=MenuObj[menuDiy[1]]
	}else{
		z_item:=RegExReplace(z_item,"iS)(\.exe)($| .*)","$1")	;去掉参数，取路径
		if(RegExMatch(z_item,"iS)^(\\\\|.:\\).*?\.exe$")){
			obj_path:=z_item
		}else{
			appName:=RegExReplace(z_item,"iS)\.exe$")
			obj_path:=MenuObj[appName]
		}
	}
	if(RegExMatch(obj_path,"iS).*?\.exe .*")){
		obj_path:=RegExReplace(obj_path,"iS)(\.exe)($| .*)","$1")
	}
	if(!InStr(obj_path,"..\")){
		return obj_path
	}else{
		val:=RegExReplace(obj_path,"\.\.\\.*?$")
		path:=StrReplace(obj_path,val)
		absolute:=funcPath2AbsoluteZz(path,val)
		return absolute ? absolute : obj_path
	}
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
	EvExtFalg:=false
	fileValue:=RegExReplace(filePath,"iS)(.*?\..*?)($| .*)","$1")	;去掉参数
	SplitPath, fileValue, fName,, fExt  ; 获取扩展名
	Loop,% EvCommandExtList.MaxIndex()
	{
		EvCommandExtStr:=StrReplace(EvCommandExtList[A_Index],"*.")
		if(fExt=EvCommandExtStr){
			EvExtFalg:=true
			break
		}
	}
	if(!EvExtFalg && fExt)
		return false
	else
		return true
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
	itemName:=itemGlobalHotKey:=itemGlobalKey:=X_ThisMenuItem:=""
	fileName:=Get_Item_Run_Path(selectZz)
	Z_ThisMenu:=A_ThisMenu
	Z_ThisMenuItem:=A_ThisMenuItem
	if(Z_ThisMenuItem="0【添加到此菜单】"){
		X_ThisMenuItem:=Z_ThisMenuItem
		itemContent:=MenuObjTree%TREE_NO%[Z_ThisMenu][(MenuObjTree%TREE_NO%[Z_ThisMenu].MaxIndex())]
		Z_ThisMenuItem:=Get_Obj_Name(itemContent)
	}
	if(!Z_ThisMenu)
		return
	menuGuiFlag:=false
	thisMenuItemStr:=X_ThisMenuItem="0【添加到此菜单】" ? "" : "菜单项（" Z_ThisMenuItem "）的上面"
	thisMenuStr:=Z_ThisMenu=RunAnyZz . TREE_NO ? "新增项会在『根目录』分类下" : "新增项会在『" Z_ThisMenu "』分类下"
	gosub,Menu_Item_Edit
return
;~;[保存新添加的菜单项]
SetSaveItem:
	Gui,SaveItem:Submit,NoHide
	saveText:=tabText:=itemGlobalKeyStr:=""
	menuFlag:=false	;判断是否定位到要插入的菜单位置
	endFlag:=false		;判断是否插入到末尾
	rootFlag:=true		;判断是否为根目录
	itemIndex:=0
	splitStr:=vitemName && vfileName ? "|" : ""
	if(vitemGlobalKey){
		if(!vitemName){
			MsgBox, 48, ,设置热键后必须填写菜单项名
			return
		}
		if(!vfileName && InStr(vitemName,"-")!=1){
			MsgBox, 48, ,应用设置热键后必须填写启动路径
			return
		}
		itemGlobalKey:=vitemGlobalWinKey ? "#" . vitemGlobalKey : vitemGlobalKey
		itemGlobalKeyStr:=A_Tab . itemGlobalKey
	}
	Gui,SaveItem:Destroy
	;~;[读取菜单内容插入新菜单项到RunAny.ini]
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
			menuItem:=Get_Obj_Name(itemContent)
			if(menuItem=Z_ThisMenuItem){
				if(X_ThisMenuItem!="0【添加到此菜单】"){
					saveText.=tabText . vitemName . itemGlobalKeyStr . splitStr . vfileName . "`n"
				}else{
					endFind:=true
				}
				menuFlag:=false
			}else if (Z_ThisMenuItem="" && (X_ThisMenuItem="" || X_ThisMenuItem="0【添加到此菜单】")){
				endFind:=true
				menuFlag:=false
			}
		}
		saveText.=A_LoopField . "`n"
		if(endFind){
			saveText.=tabText . vitemName . itemGlobalKeyStr . splitStr . vfileName . "`n"
			endFind:=false
		}
	}
	if(saveText){
		stringtrimright, saveText, saveText, 1
		FileDelete,%iniFileShow%
		FileAppend,%saveText%,%iniFileShow%
		Reload
	}
return
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
;~;[菜单配置Gui]
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
Menu_Edit:
	global TVFlag:=false
	;~;[功能菜单初始化]
	treeRoot:=Object()
	global moveRoot:=Object()
	moveRoot[1]:="moveMenu" . both
	Menu,% moveRoot[1],add
	global moveLevel:=0
	;~;[树型菜单初始化]
	Gui, Destroy
	Gui, +Resize
	Gui, Font,, Microsoft YaHei
	Gui, Add, TreeView,vRunAnyTV w450 r30 -Readonly AltSubmit Checked hwndHTV gTVClick ImageList%ImageListID%
	Gui, Add, Progress,vMyProgress w450 cBlue
	GuiControl, Hide, MyProgress
	GuiControl, -Redraw, RunAnyTV
	;~;[读取菜单配置内容写入树形菜单]
	Loop, parse, iniFileVar, `n, `r, %A_Space%%A_Tab%
	{
		if(A_LoopField=""){
			continue
		}
		if(InStr(A_LoopField,"-")=1){
			;~;[生成节点树层级结构]
			treeLevel:=StrLen(RegExReplace(A_LoopField,"S)(^-+).+","$1"))
			if(RegExMatch(A_LoopField,"S)^-+[^-]+.*")){
				if(treeLevel=1){
					treeRoot.InsertAt(treeLevel,TV_Add(A_LoopField,,"Bold Icon6"))
				}else{
					treeRoot.InsertAt(treeLevel,TV_Add(A_LoopField,treeRoot[treeLevel-1],"Bold Icon6"))
				}
				TV_MoveMenu(A_LoopField)
			}else if(A_LoopField="-"){
				treeLevel:=0
				TV_Add(A_LoopField,,"Bold Icon8")
			}else{
				TV_Add(A_LoopField,treeRoot[treeLevel],"Bold Icon8")
			}
		}else{
			TV_Add(A_LoopField,treeRoot[treeLevel],Set_Icon(A_LoopField,false))
		}
	}
	GuiControl, +Redraw, RunAnyTV
	try Menu,TVMenu,Delete
	TVMenu("TVMenu")
	TVMenu("GuiMenu")
	Gui, Menu, GuiMenu
	Gui, Show, , %RunAnyZz%菜单树管理【%both%】(双击修改，右键操作)
return
Menu_Edit1:
	both:=1
	iniFileWrite:=iniPath
	iniFileVar:=iniVar1
	gosub,Menu_Edit
return
Menu_Edit2:
	both:=2
	iniFileWrite:=iniPath2
	iniFileVar:=iniVar2
	gosub,Menu_Edit
return
#If WinActive(RunAnyZz "菜单树管理【" both "】(双击修改，右键操作)")
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
	F2::gosub,TVEdit
	Tab::Send_Str_Zz(A_Tab)
#If
GuiContextMenu:
PGuiContextMenu:
	If (A_GuiControl = "RunAnyTV") {
		TV_Modify(A_EventInfo, "Select Vis")
		Menu, TVMenu, Show
	}
	If (A_GuiControl = "RunAnyLV") {
		LV_Modify(A_EventInfo, "Select Vis")
		Menu, LVMenu, Show
	}
return
GuiSize:
PGuiSize:
	if A_EventInfo = 1
		return
	GuiControl, Move, RunAnyTV, % "H" . (A_GuiHeight-10) . " W" . (A_GuiWidth - 20)
	GuiControl, Move, RunAnyLV, % "H" . (A_GuiHeight-10) . " W" . (A_GuiWidth - 20)
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
	if(!flag)
		Menu, %addMenu%, Add,注释, TVComments
	;~ Menu, %addMenu%, Add
	Menu, %addMenu%, Add,移动到..., :moveMenu%both%
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
	itemName:=fileName:=itemGlobalHotKey:=itemGlobalKey:=selectZz:=""
	menuGuiFlag:=true
	gosub,Menu_Item_Edit
return
TVEdit:
	selID:=TV_GetSelection()
	TV_GetText(ItemText, selID)
	;分解已有菜单项到编辑框中
	itemGlobalWinKey:=0
	itemName:=fileName:=itemGlobalHotKey:=itemGlobalKey:=selectZz:=""
	if(InStr(ItemText,"|") || InStr(ItemText,"-")=1){
		menuDiy:=StrSplit(ItemText,"|")
		itemName:=menuDiy[1]
		fileName:=menuDiy[2]
		;~;[分割Tab获取应用自定义热键]
		if(InStr(menuDiy[1],"`t")){
			menuKeyStr:=RegExReplace(menuDiy[1], "S)\t+", A_Tab)
			menuKeys:=StrSplit(menuKeyStr,"`t")
			if(menuKeys[2]){
				itemName:=menuKeys[1]
				itemGlobalHotKey:=menuKeys[2]
				itemGlobalKey:=menuKeys[2]
				if(InStr(menuKeys[2],"#")){
					itemGlobalWinKey:=1
					itemGlobalKey:=StrReplace(menuKeys[2], "#")
				}
			}
		}
	}else{
		fileName:=ItemText
	}
	menuGuiFlag:=true
	gosub,Menu_Item_Edit
return
Menu_Item_Edit:
	SaveLabel:=menuGuiFlag ? "SetSaveItemGui" : "SetSaveItem"
	PromptStr:=menuGuiFlag ? "需要" : "请点击此"
	SplitPath, fileName, fName,, fExt  ; 获取扩展名
	Gui,SaveItem:Destroy
	Gui,SaveItem:Margin,20,20
	Gui,SaveItem:Font,,Microsoft YaHei
	Gui,SaveItem:Add, GroupBox,xm y+10 w500 h210,新增菜单项
	Gui,SaveItem:Add, Text, xm+10 y+30 y35 w60, 菜单项名：
	Gui,SaveItem:Add, Edit, x+5 yp-3 w250 vvitemName GFileNameChange, %itemName%
	Gui,SaveItem:Add, Text, x+20 yp+3 w80, Tab制表符
	Gui,SaveItem:Add, Text, xm+10 y+15 w60, 全局热键：
	Gui,SaveItem:Add, Hotkey,x+5 yp-3 w150 vvitemGlobalKey,%itemGlobalKey%
	Gui,SaveItem:Add, Checkbox,Checked%itemGlobalWinKey% x+5 yp+3 vvitemGlobalWinKey,Win
	Gui,SaveItem:Add, Text, x+20 yp w200, %itemGlobalHotKey%
	Gui,SaveItem:Add, Text, xm+10 y+10 w100, 分 隔 符 ：  |
	Gui,SaveItem:Add, Text, x+10 yp w350 cRed vvPrompt GSetSaveItemFullPath, 注意：RunAny不支持当前后缀无路径运行，%PromptStr%使用全路径
	if(InStr(itemName,"-")){
		Gui,SaveItem:Add, Text, xm+10 y+10 w60,文件后缀：
	}else{
		Gui,SaveItem:Add, Button, xm+5 y+6 w60 GSetItemPath,启动路径
	}
	if(fExt="lnk"){
		Gui,SaveItem:Add, Button, xm+5 y+2 w60 GSetShortcut,快捷目标
		Gui,SaveItem:Add, Edit, x+10 yp-22 w400 r3 vvfileName GFileNameChange, %fileName%
	}else{
		Gui,SaveItem:Add, Edit, x+10 yp w400 r3 vvfileName GFileNameChange, %fileName%
	}
	Gui,SaveItem:Font
	Gui,SaveItem:Add,Button,Default xm+150 y+10 w75 G%SaveLabel%,保存(&Y)
	Gui,SaveItem:Add,Button,x+20 w75 GSetCancel,取消(&C)
	Gui,SaveItem:Add, Text, xm y+25, %thisMenuStr% %thisMenuItemStr%
	Gui,SaveItem:Show,,新增菜单项 - %RunAnyZz%
	GuiControl,SaveItem:Hide, vPrompt
	thisMenuStr:=thisMenuItemStr:=""
	gosub,FileNameChange
return
SetSaveItemGui:
	Gui,SaveItem:Submit,NoHide
	itemGlobalKeyStr:=""
	if(vitemGlobalKey){
		if(!vitemName){
			MsgBox, 48, ,设置热键后必须填写菜单项名
			return
		}
		if(!vfileName && InStr(vitemName,"-")!=1){
			MsgBox, 48, ,应用设置热键后必须填写启动路径
			return
		}
		itemGlobalKey:=vitemGlobalWinKey ? "#" . vitemGlobalKey : vitemGlobalKey
		itemGlobalKeyStr:=A_Tab . itemGlobalKey
	}
	splitStr:=vitemName && vfileName ? "|" : ""
	saveText:=vitemName . itemGlobalKeyStr . splitStr . vfileName
	Gui,SaveItem:Destroy
	Gui,1:Default
	TV_Modify(selID, , saveText)
	TV_Modify(selID, "Select Vis")
	TV_Modify(selID, Set_Icon(saveText))
	if(ItemText!=saveText)
		TVFlag:=true
	if(!itemName && selID && RegExMatch(saveText,"S)^-+[^-]+.*")){
		insertID:=TV_Add("",selID)
		TV_Modify(selID, "Bold Expand")
		TV_Modify(insertID, "Select Vis")
		SendMessage, 0x110E, 0, TV_GetSelection(), , ahk_id %HTV%
		addID:=
		TV_MoveMenuClean()
	}
return
FileNameChange:
	Gui,SaveItem:Submit, NoHide
	filePath:=!vfileName && vitemName ? vitemName : vfileName
	if(filePath){
		if(Check_Obj_Ext(filePath))
			GuiControl, SaveItem:Hide, vPrompt
		else
			GuiControl, SaveItem:Show, vPrompt
	}
return
SetItemPath:
	FileSelectFile, fileSelPath, , , 启动文件路径
	if(fileSelPath){
		GuiControl,, vfileName, % Get_Item_Run_Path(fileSelPath)
		gosub,FileNameChange
	}
return
SetSaveItemFullPath:
	if(selectZz && !menuGuiFlag){
		GuiControl, SaveItem:, vfileName, %selectZz%
		GuiControl, SaveItem:Hide, vPrompt
	}
return
SetShortcut:
	Gui,SaveItem:Submit, NoHide
	filePath:=!vfileName && vitemName ? vitemName : vfileName
	filePath:=Get_Obj_Path(filePath)	;补全路径
	if(!filePath)	;如果没补全，还原原选中文件地址
		filePath:=selectZz
	SplitPath, filePath, ,, fExt  ; 获取扩展名
	if(filePath && fExt="lnk"){
		FileGetShortcut, %filePath%, exePath, OutDir, exeArgs
		exeArgs:=exeArgs ? A_Space exeArgs : ""
		if(exePath)
			GuiControl, SaveItem:, vfileName, %exePath%%exeArgs%
	}else{
		gosub,SetSaveItemFullPath
	}
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
		}else{
			ItemText:=";" ItemText
		}
		TV_Modify(CheckID, ,ItemText)
	}
return
TVSave:
	MsgBox, 35, 菜单树保存, 是：保存后重启生效`n否：保存重启后继续修改`n取消：取消保存
	IfMsgBox Yes
	{
		gosub,Menu_Save
		Reload
	}
	IfMsgBox No
	{
		gosub,Menu_Save
		RegWrite, REG_SZ, HKEY_CURRENT_USER, SOFTWARE\RunAny, ReloadEditFlag, 1
		Reload
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
			fileID:=TV_Add(I_LoopField,parentID,Set_Icon(exePath))
			TVFlag:=true
		}
	}
return
TVImportFolder:
	selID:=TV_GetSelection()
	parentID:=TV_GetParent(selID)
	FileSelectFolder, folderName, , 0
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
				folderID:=TV_Add(A_LoopFileName,parentID,Set_Icon(A_LoopFileFullPath))
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
		selTextList.Push(ItemText)
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
					MsgBox,65,,图标下载成功，是否要重新打开RunAny生效？
					IfMsgBox Ok
						Reload
				}
			}
		} catch e {
			WebsiteIconError(webSiteInput)
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
				WebsiteIconError(errDown)
			GuiControl, Hide, MyProgress
			MsgBox,65,,图标下载完成，是否要重新打开RunAny生效？
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
			WebsiteIconError(errDown)
		GuiControl, Hide, MyProgress
		MsgBox,65,,图标下载完成，是否要重新打开RunAny生效？
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
WebsiteIconError(errDown){
	MsgBox,以下网站图标无法下载，请单选后点[网站图标]按钮重新指定网址下载，`n或手动添加对应图标到[%A_ScriptDir%\RunIcon]`n`n%errDown%
}
;~;[上下移动项目]
TV_Move(moveMode = true){
	selID:=TV_GetSelection()
	moveID:=moveMode ? TV_GetNext(selID) : TV_GetPrev(selID)	; 向下：moveID为下个节点ID，向上：上个节点ID
	if(moveID!=0){
		TV_GetText(selVar, selID)
		TV_GetText(moveVar, moveID)
		selTreeFalg:=RegExMatch(selVar,"S)^-+[^-]+.*")
		moveTreeFalg:=RegExMatch(moveVar,"S)^-+[^-]+.*")
		selNextID:=moveMode ? moveID : TV_GetNext(selID)	; 向下：moveID即为树末节点，向上：选中树的下个同级节点为树末节点
		moveNextID:=!moveMode ? selID : TV_GetNext(moveID)	; 向上：selID即为树末节点，向下：目标树的下个同级节点为树末节点
		if((selTreeFalg || moveTreeFalg) && selNextID && moveNextID){
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
				TV_Add(selTextList[A_Index],moveID,Set_Icon(selTextList[A_Index]))
			}
			; 遍历添加目标树内容到选中树
			Loop,% moveTextList.MaxIndex()
			{
				TV_Add(moveTextList[A_Index],selID,Set_Icon(moveTextList[A_Index]))
			}
		}
		;~ [互换选中目标节点的名称]
		TV_Modify(selID, , moveVar)
		TV_Modify(moveID, , selVar)
		TV_Modify(selID, "-Select -focus")
		TV_Modify(moveID, "Select Vis")
		TV_Modify(selID, Set_Icon(moveVar))
		TV_Modify(moveID, Set_Icon(selVar))
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
;~;[后缀判断图标Gui]
Set_Icon(itemVar,editVar=true){
	;变量转换实际值
	itemVar:=Get_Transform_Val(itemVar)
	SplitPath, itemVar,,, FileExt  ; 获取文件扩展名.
	itemLen:=StrLen(itemVar)
	if(InStr(itemVar,";")=1 || itemVar="")
		return "Icon0"
	if(InStr(itemVar,";",,0,1)=itemLen)
		return "Icon2"
	if(RegExMatch(itemVar,"S)^-+[^-]+.*"))
		return "Icon6"
	if(RegExMatch(itemVar,"S)^-+"))
		return "Icon8"
	if(InStr(FileExist(itemVar), "D"))
		return "Icon4"
	if(InStr(itemVar,"::",,0,1)=itemLen-1)	; {发送热键}
		return "Icon9"
	;~;[获取全路径]
	FileName:=Get_Obj_Path(itemVar)
	if(!editVar && FileName="" && FileExt = "exe")
		return "Icon3"
	if(FileName="cmd.exe")
		FileName=%A_WinDir%\system32\cmd.exe
	;~;[获取网址图标]
	if(RegExMatch(FileName,"iS)([\w-]+://?|www[.]).*")){
		if(editVar){
			return "Icon7"
		}
		try{
			website:=RegExReplace(FileName,"iS)[\w-]+://?((\w+\.)+\w+).*","$1")
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
	;~;[编辑后图标重新加载]
	if(editVar && !FileName && FileExt = "exe"){
		;~;[编辑后通过everything重新添加应用图标]
		diyText:=StrSplit(itemVar,"|")
		exeText:=(diyText[2]) ? diyText[2] : diyText[1]
		exeQueryPath:=exeQuery(exeText)
		if(exeQueryPath){
			FileName:=exeQueryPath
		}else{
			return "Icon3"
		}
	}
	; 计算 SHFILEINFO 结构需要的缓存大小.
	sfi_size := A_PtrSize + 8 + (A_IsUnicode ? 680 : 340)
	VarSetCapacity(sfi, sfi_size)
	;【下面开始处理未知的项目图标】
    if FileExt in EXE,ICO,ANI,CUR
    {
        ExtID := FileExt  ; 特殊 ID 作为占位符.
        IconNumber = 0  ; 进行标记这样每种类型就含有唯一的图标.
    }
    else  ; 其他的扩展名/文件类型, 计算它们的唯一 ID.
    {
        ExtID = 0  ; 进行初始化来处理比其他更短的扩展名.
        Loop 7     ; 限制扩展名为 7 个字符, 这样之后计算的结果才能存放到 64 位值.
        {
            StringMid, ExtChar, FileExt, A_Index, 1
            if not ExtChar  ; 没有更多字符了.
                break
            ; 把每个字符与不同的位位置进行运算来得到唯一 ID:
            ExtID := ExtID | (Asc(ExtChar) << (8 * (A_Index - 1)))
        }
        ; 检查此文件扩展名的图标是否已经在图像列表中. 如果是,
        ; 可以避免多次调用并极大提高性能,
        ; 尤其对于包含数以百计文件的文件夹而言:
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
			IconArray%ExtID% := IconNumber
		}
	}
	return "Icon" . IconNumber
}
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
		If TV_Get( _EventInfo, "Checked" )									;项目的复选标记
		{
			If TV_GetChild( _EventInfo )										;项目的节点
				ToggleAllTheWay( _EventInfo, False )							;复选标记所有的孩子一路下来
		}
		Else																	;它未被选中
		{
			If TV_GetChild( _EventInfo )										;它是一个节点
				ToggleAllTheWay( _EventInfo, True )							;取消选中所有的孩子一直向下
			If TV_Get( TV_GetParent( _EventInfo ), "Checked") 				;父节点选中怎么样？
			{
				locItemId := TV_GetParent( _EventInfo )						;父节点检查标记：获取父ID
				While locItemId													;循环一路向上
				{
					TV_Modify( locItemId , "-Check" )							;它的未选中：检查！
					locItemId := TV_GetParent( locItemId )					;获取下一个父ID
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
;~;[插件管理]
;══════════════════════════════════════════════════════════════════
Plugins_Manage:
gosub,Plugins_Read
global ColumnName:=1
global ColumnStatus:=2
global ColumnAutoRun:=3
global ColumnCloseRun:=4
DetectHiddenWindows,On
Gui,P:Destroy
Gui,P:Default
Gui,P:+Resize
Gui,P:Font, s10, Microsoft YaHei
Gui,P:Add, Listview, xm w500 r15 grid AltSubmit vRunAnyLV glistview, 插件文件|运行状态|自动启动|插件描述
;~;[读取启动项内容写入列表]
GuiControl,P: -Redraw, RunAnyLV
For runn, runv in PluginsObjList
{
	runStatus:=Check_IsRun(PluginsPathList[runn]) ? "启动" : ""
	pluginsConfig:=runv ? "启用" : ""
	if(!PluginsPathList[runn])
		pluginsConfig:="未找到"
	LV_Add("", runn, runStatus, pluginsConfig, PluginsTitleList[runn])
}
GuiControl,P: +Redraw, RunAnyLV
LVMenu("LVMenu")
LVMenu("ahkGuiMenu")
Gui,P: Menu, ahkGuiMenu
LVModifyCol(65,ColumnStatus,ColumnAutoRun)
Gui,P:Show, , %RunAnyZz% 插件管理 %RunAny_update_version%
DetectHiddenWindows,Off
return

LVMenu(addMenu){
	flag:=addMenu="ahkGuiMenu" ? true : false
	Menu, %addMenu%, Add,% flag ? "启动" : "启动`tF1", LVRun
	try Menu, %addMenu%, Icon,% flag ? "启动" : "启动`tF1", %ahkExePath%,2
	Menu, %addMenu%, Add,% flag ? "编辑" : "编辑`tF2", LVEdit
	Menu, %addMenu%, Icon,% flag ? "编辑" : "编辑`tF2", SHELL32.dll,134
	Menu, %addMenu%, Add,% flag ? "自启" : "自启`tF3", LVEnable
	Menu, %addMenu%, Icon,% flag ? "自启" : "自启`tF3", SHELL32.dll,166
	Menu, %addMenu%, Add,% flag ? "关闭" : "关闭`tF4", LVClose
	Menu, %addMenu%, Icon,% flag ? "关闭" : "关闭`tF4", SHELL32.dll,28
	Menu, %addMenu%, Add,% flag ? "挂起" : "挂起`tF5", LVSuspend
	try Menu, %addMenu%, Icon,% flag ? "挂起" : "挂起`tF5", %ahkExePath%,3
	Menu, %addMenu%, Add,% flag ? "暂停" : "暂停`tF6", LVPause
	try Menu, %addMenu%, Icon,% flag ? "暂停" : "暂停`tF6", %ahkExePath%,4
	Menu, %addMenu%, Add,% flag ? "删除" : "删除`tF7", LVDel
	Menu, %addMenu%, Icon,% flag ? "删除" : "删除`tF7", SHELL32.dll,132
	Menu, %addMenu%, Add,% flag ? "下载" : "下载`tF8", LVAdd
	Menu, %addMenu%, Icon,% flag ? "下载" : "下载`tF8", SHELL32.dll,194
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
	menuItem:="删除"
	gosub,LVApply
	return
LVApply:
	Gui,P:Default
	DetectHiddenWindows,On      ;~显示隐藏窗口
	Row:=LV_GetNext(0, "F")
	RowNumber:=0
	if(Row && menuItem="删除"){
		MsgBox,35,确认删除？(Esc取消),确定删除选中的插件配置？(不会删除文件)
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
			SplitPath, runValue, name,, ext  ; 获取扩展名
			if(ahkFlag && ext="ahk"){
				Run,%ahkExePath%%A_Space%%FilePath%
			}else{
				Run,%FilePath%
			}
			LV_Modify(RowNumber, "", , "启动")
		}else if(menuItem="编辑"){
			PostMessage, 0x111, 65401,,, %FilePath% ahk_class AutoHotkey
		}else if(menuItem="挂起"){
			PostMessage, 0x111, 65404,,, %FilePath% ahk_class AutoHotkey
			LVStatusChange(RowNumber,FileStatus,"挂起")
		}else if(menuItem="暂停"){
			PostMessage, 0x111, 65403,,, %FilePath% ahk_class AutoHotkey
			LVStatusChange(RowNumber,FileStatus,"暂停")
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
			if(FileAutoRun!="未找到" && FileAutoRun!="启用"){
				IniWrite,1,%RunAnyConfig%,Plugins,%FileName%
				LV_Modify(RowNumber, "", , ,"启用")
			}else if(FileAutoRun="启用"){
				IniWrite,0,%RunAnyConfig%,Plugins,%FileName%
				LV_Modify(RowNumber, "", , ,"禁用")
			}
		}else if(menuItem="删除"){
			IfMsgBox Yes
			{
				DelRowList := RowNumber . ":" . DelRowList
				IniDelete,%RunAnyConfig%,Plugins,%FileName%
			}
		}
	}
	if(menuItem="删除"){
		IfMsgBox Yes
		{
			stringtrimright, DelRowList, DelRowList, 1
			loop, parse, DelRowList, :
				LV_Delete(A_loopfield)
		}
	}
	DetectHiddenWindows,Off
return
#If WinActive(RunAnyZz A_Space "插件管理" A_Space RunAny_update_version)
	F1::gosub,LVRun
	F2::gosub,LVEdit
	F3::gosub,LVEnable
	F4::gosub,LVClose
	F5::gosub,LVSuspend
	F6::gosub,LVPause
	F7::gosub,LVDel
	F8::gosub,LVAdd
#If
listview:
    if A_GuiEvent = DoubleClick
    {
		menuItem:="启动"
		gosub,LVApply
    }
return
PGuiEscape:
	Gui,P:Destroy
return
LVAdd:
	Gui,D:Destroy
	Gui,D:Default
	Gui,D:Font, s10, Microsoft YaHei
	Gui,D:Add, Listview, xm w480 r10 grid AltSubmit Checked vRunAnyDownLV, 插件文件|状态|版本号|插件描述
	;~;[读取启动项内容写入列表]
	GuiControl,D: -Redraw, RunAnyDownLV
	For pi, pv in pluginsDownList
	{
		runStatus:=PluginsPathList[pv] ? "已下载" : "未下载"
		LV_Add("", pv, runStatus, Plugins_Read_Version(PluginsPathList[pv]), PluginsTitleList[pv])
	}
	GuiControl,D: +Redraw, RunAnyDownLV
	Menu, ahkDownMenu, Add,下载, LVDown
	Menu, ahkDownMenu, Icon,下载, SHELL32.dll,194
	Gui,D: Menu, ahkDownMenu
	LVModifyCol(65,ColumnStatus,ColumnAutoRun)
	Gui,D:Show, , %RunAnyZz% 插件下载 %RunAny_update_version%
return
LVDown:
	if(!Check_Github()){
		MsgBox,网络异常，无法从https://github.com/hui-Zz/RunAny上读取最新版本文件，请手动下载
		return
	}
	TrayTip,,RunAny开始下载插件，请稍等……,2,1
	gosub,AhkExeDown
	Loop
	{
		RowNumber := LV_GetNext(RowNumber)
		if not RowNumber
			RowNumber := LV_GetNext(RowNumber, "Checked")  ; 再找勾选的行
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		LV_GetText(FileName, RowNumber, ColumnName)
		LV_GetText(FileStatus, RowNumber, ColumnStatus)
		if(FileStatus="未下载"){
			URLDownloadToFile,%RunAnyGithubDir%/RunPlugins/%FileName% ,%A_ScriptDir%\%PluginsDir%\%FileName%
		}
	}
	TrayTip,,RunAny插件下载成功，自动重启后请重新查看,3,1
	Sleep,2000
	Reload
return
AhkExeDown:
	IfNotExist,%A_ScriptDir%\%PluginsDir%
		FileCreateDir, %A_ScriptDir%\%PluginsDir%
	if(!ahkFlag){
		URLDownloadToFile,%RunAnyGithubDir%/RunPlugins/AHK.exe ,%A_ScriptDir%\%PluginsDir%\AHK.exe
	}
	FileGetSize, ahkSize, %A_ScriptDir%\%PluginsDir%\AHK.exe
	if(ahkSize<1189888)
		URLDownloadToFile,%RunAnyGithubDir%/RunPlugins/AHK.exe ,%A_ScriptDir%\%PluginsDir%\AHK.exe
return
;[判断脚本当前状态]
LVStatusChange(RowNumber,FileStatus,lvItem){
	item:=lvItem
	if(FileStatus="挂起" && lvItem="暂停"){
		lvItem:="挂起暂停"
	}else if(FileStatus="暂停" && lvItem="挂起"){
		lvItem:="暂停挂起"
	}else if(FileStatus!="启动"){
		StringReplace, lvItem, FileStatus, %item%
	}
	if(lvItem="")
		lvItem:="启动"
	LV_Modify(RowNumber, "", ,lvItem)
	LV_ModifyCol()
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
/*
【判断启动项当前是否已经运行】（RunAnyCtrl）
runNamePath 进程名或者启动项路径
*/
Check_IsRun(runNamePath){
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
;══════════════════════════════════════════════════════════════════
;~;[设置选项]
Menu_Set:
	if(GetKeyState("Ctrl")){
		gosub,Menu_Config
		return
	}
	Gui,66:Destroy
	Gui,66:Font,,Microsoft YaHei
	Gui,66:Margin,30,20
	Gui,66:Add,Tab,x10 y10 w520 h500,RunAny设置|配置热键|Everything设置|一键搜索|图标+TC设置
	Gui,66:Tab,RunAny设置,,Exact
	Gui,66:Add,GroupBox,xm-10 y+5 w500 h50,RunAny设置
	Gui,66:Add,Checkbox,Checked%AutoRun% xm yp+25 vvAutoRun,开机自动启动
	Gui,66:Add,Checkbox,Checked%IniConfig% x+118 vvIniConfig,RunAnyConfig.ini移动盘绿色配置
	Gui,66:Add,GroupBox,xm-10 y+15 w500 h80,RunAny应用菜单
	Gui,66:Add,Checkbox,Checked%HideFail% xm yp+20 vvHideFail,隐藏失效项
	Gui,66:Add,Checkbox,Checked%HideRecent% x+130 vvHideRecent,隐藏最近运行
	Gui,66:Add,Checkbox,Checked%HideWeb% xm yp+20 vvHideWeb,隐藏网址（选中文字显示）
	Gui,66:Add,Checkbox,Checked%HideSend% x+46 vvHideSend,隐藏短语（选中文字显示）
	Gui,66:Add,Checkbox,Checked%HideAddItem% xm yp+20 vvHideAddItem,隐藏【添加到此菜单】
	Gui,66:Add,GroupBox,xm-10 y+15 w500 h70,RunAny选中文字菜单
	Gui,66:Add,Checkbox,Checked%HideUnSelect% xm yp+20 vvHideUnSelect gUnCheckWebSend,选中文字依然显示应用菜单
	Gui,66:Add,Text,xm yp+25 w120,选中后直接一键打开：
	Gui,66:Add,Checkbox,Checked%OneKeyWeb% x+20 yp vvOneKeyWeb,网址
	Gui,66:Add,Checkbox,Checked%OneKeyFile% x+10 yp vvOneKeyFile,文件路径
	Gui,66:Add,Checkbox,Checked%OneKeyFolder% x+10 yp vvOneKeyFolder,文件夹路径
	Gui,66:Add,Checkbox,Checked%OneKeyMagnet% x+10 yp vvOneKeyMagnet,磁力链接
	Gui,66:Add,GroupBox,xm-10 y+15 w225 h55,RunAny菜单自定义热键 %MenuHotKey%
	Gui,66:Add,Hotkey,xm yp+20 w150 vvMenuKey,%MenuKey%
	Gui,66:Add,Checkbox,Checked%MenuWinKey% xm+155 yp+3 vvMenuWinKey,Win
	If(MENU2FLAG){
		Gui,66:Add,GroupBox,x+35 yp-23 w225 h55,菜单2自定义热键 %MenuHotKey2%
		Gui,66:Add,Hotkey,xp+10 yp+20 w150 vvMenuKey2,%MenuKey2%
		Gui,66:Add,Checkbox,Checked%MenuWinKey2% xp+155 yp+3 vvMenuWinKey2,Win
	}else{
		Gui,66:Add,Button,x+35 yp-5 w150 GSetMenu2,开启第2个菜单
	}
	Gui,66:Add,GroupBox,xm-10 y+25 w500 h115,屏蔽RunAny程序列表（逗号分隔）
	Gui,66:Add,Edit,xm yp+25 w480 r4 vvDisableApp,%DisableApp%
	
	Gui,66:Tab,配置热键,,Exact
	Gui,66:Add,GroupBox,xm-10 y+30 w225 h55,修改菜单管理(1)：%TreeHotKey1%
	Gui,66:Add,Hotkey,xm yp+20 w150 vvTreeKey1,%TreeKey1%
	Gui,66:Add,Checkbox,Checked%TreeWinKey1% xm+155 yp+3 vvTreeWinKey1,Win
	If(MENU2FLAG){
		Gui,66:Add,GroupBox,x+35 yp-23 w225 h55,修改菜单管理(2)：%TreeHotKey2%
		Gui,66:Add,Hotkey,xp+10 yp+20 w150 vvTreeKey2,%TreeKey2%
		Gui,66:Add,Checkbox,Checked%TreeWinKey2% xp+155 yp+3 vvTreeWinKey2,Win
	}
	Gui,66:Add,GroupBox,xm-10 y+30 w225 h55,修改菜单文件(1)：%TreeIniHotKey1%
	Gui,66:Add,Hotkey,xm yp+20 w150 vvTreeIniKey1,%TreeIniKey1%
	Gui,66:Add,Checkbox,Checked%TreeIniWinKey1% xm+155 yp+3 vvTreeIniWinKey1,Win
	If(MENU2FLAG){
		Gui,66:Add,GroupBox,x+35 yp-23 w225 h55,修改菜单文件(2)：%TreeIniHotKey2%
		Gui,66:Add,Hotkey,xp+10 yp+20 w150 vvTreeIniKey2,%TreeIniKey2%
		Gui,66:Add,Checkbox,Checked%TreeIniWinKey2% xp+155 yp+3 vvTreeIniWinKey2,Win
	}
	Gui,66:Add,GroupBox,xm-10 y+30 w225 h55,插件管理：%PluginsManageHotKey%
	Gui,66:Add,Hotkey,xm yp+20 w150 vvPluginsManageKey,%PluginsManageKey%
	Gui,66:Add,Checkbox,Checked%PluginsManageWinKey% xm+155 yp+3 vvPluginsManageWinKey,Win
	
	Gui,66:Add,GroupBox,xm-10 y+30 w225 h55,设置RunAny：%RunASetHotKey%
	Gui,66:Add,Hotkey,xm yp+20 w150 vvRunASetKey,%RunASetKey%
	Gui,66:Add,Checkbox,Checked%RunASetWinKey% xm+155 yp+3 vvRunASetWinKey,Win
	Gui,66:Add,GroupBox,x+35 yp-23 w225 h55,重启RunAny：%RunAReloadHotKey%
	Gui,66:Add,Hotkey,xp+10 yp+20 w150 vvRunAReloadKey,%RunAReloadKey%
	Gui,66:Add,Checkbox,Checked%RunAReloadWinKey% xp+155 yp+3 vvRunAReloadWinKey,Win
	Gui,66:Add,GroupBox,xm-10 y+30 w225 h55,停用RunAny：%RunASuspendHotKey%
	Gui,66:Add,Hotkey,xm yp+20 w150 vvRunASuspendKey,%RunASuspendKey%
	Gui,66:Add,Checkbox,Checked%RunASuspendWinKey% xm+155 yp+3 vvRunASuspendWinKey,Win
	Gui,66:Add,GroupBox,x+35 yp-23 w225 h55,退出RunAny：%RunAExitHotKey%
	Gui,66:Add,Hotkey,xp+10 yp+20 w150 vvRunAExitKey,%RunAExitKey%
	Gui,66:Add,Checkbox,Checked%RunAExitWinKey% xp+155 yp+3 vvRunAExitWinKey,Win
	
	Gui,66:Tab,Everything设置,,Exact
	Gui,66:Add,GroupBox,xm-10 y+20 w500 h55,一键Everything [搜索选中文字、激活、隐藏]
	Gui,66:Add,Hotkey,xm+10 yp+20 w150 vvEvKey,%EvKey%
	Gui,66:Add,Checkbox,Checked%EvWinKey% xm+170 yp+3 vvEvWinKey,Win
	Gui,66:Add,Checkbox,Checked%EvAutoClose% x+38 vvEvAutoClose,Everything自动关闭(不常驻)
	Gui,66:Add,GroupBox,xm-10 y+30 w500 h100,Everything安装路径（支持内置变量和相对路径..\为RunAny相对上级目录）
	Gui,66:Add,Button,xm yp+30 w50 GSetEvPath,选择
	Gui,66:Add,Edit,xm+60 yp w420 r3 vvEvPath,%EvPath%
	Gui,66:Add,GroupBox,xm-10 y+30 w500 h140,Everything搜索参数（搜索结果程序可无路径用RunAny运行）
	Gui,66:Add,Button,xm yp+20 w50 GSetEvCommand,修改
	Gui,66:Add,Text,xm+60 yp,!C:\*Windows*为排除系统缓存和系统程序
	Gui,66:Add,Text,xm+60 yp+15,file:*.exe|*.lnk|后面类推增加想要的后缀
	Gui,66:Add,Edit,ReadOnly xm+10 yp+25 w470 r3 vvEvCommand,%EvCommand%
	
	Gui,66:Tab,一键搜索,,Exact
	Gui,66:Add,GroupBox,xm-10 y+20 w500 h260,一键搜索选中文字
	Gui,66:Add,Hotkey,xm yp+30 w150 vvOneKey,%OneKey%
	Gui,66:Add,Checkbox,Checked%OneWinKey% xm+155 yp+3 vvOneWinKey,Win
	Gui,66:Add,Checkbox,Checked%OneKeyMenu% x+38 vvOneKeyMenu,绑定菜单1为一键搜索
	Gui,66:Add,Text,xm yp+40 w325,一键搜索网址(`%s为选中文字的替代参数，多行搜索多个网址)
	Gui,66:Add,Edit,xm yp+20 w485 r8 vvOneKeyUrl,%OneKeyUrl%
	Gui,66:Add,Text,xm y+40 w325,非默认浏览器打开网址(适用一键搜索和一键直达)
	Gui,66:Add,Button,xm yp+20 w50 GSetBrowserPath,选择
	Gui,66:Add,Edit,xm+60 yp w420 r3 vvBrowserPath,%BrowserPath%
	
	Gui,66:Tab,图标+TC设置,,Exact
	Gui,66:Add,GroupBox,xm-10 y+20 w500 h230,图标自定义设置（图片或图标文件路径 , 序号不填默认1）
	Gui,66:Add,Button,xm yp+30 w80 GSetAnyIcon,RunAny图标
	Gui,66:Add,Edit,xm+82 yp w400 r1 vvAnyIcon,%AnyIcon%
	Gui,66:Add,Button,xm yp+30 w80 GSetMenuIcon,准备图标
	Gui,66:Add,Edit,xm+82 yp w400 r1 vvMenuIcon,%MenuIcon%
	Gui,66:Add,Button,xm yp+30 w80 GSetTreeIcon,分类图标
	Gui,66:Add,Edit,xm+82 yp w400 r1 vvTreeIcon,%TreeIcon%
	Gui,66:Add,Button,xm yp+30 w80 GSetFolderIcon,文件夹图标
	Gui,66:Add,Edit,xm+82 yp w400 r1 vvFolderIcon,%FolderIcon%
	Gui,66:Add,Button,xm yp+30 w80 GSetUrlIcon,网址图标
	Gui,66:Add,Edit,xm+82 yp w400 r1 vvUrlIcon,%UrlIcon%
	Gui,66:Add,Button,xm yp+30 w80 GSetEXEIcon,EXE图标
	Gui,66:Add,Edit,xm+82 yp w400 r1 vvEXEIcon,%EXEIcon%
	Gui,66:Add,GroupBox,xm-10 y+30 w500 h100,TotalCommander安装路径（TC打开RunAny中的文件夹）
	Gui,66:Add,Button,xm yp+20 w50 GSetTcPath,选择
	Gui,66:Add,Edit,xm+60 yp w420 r3 vvTcPath,%TcPath%

	Gui,66:Tab
	Gui,66:Add,Button,Default xm+100 y+90 w75 GSetOK,确定(&Y)
	Gui,66:Add,Button,x+15 w75 GSetCancel,取消(&C)
	Gui,66:Add,Button,x+15 w75 GSetReSet,重置
	Gui,66:Add,Text,x+40 yp+5 w75 GMenu_Config,RunAnyConfig.ini
	Gui,66:Show,,%RunAnyZz%设置
	return
;~;[关于]
Menu_About:
	Gui,99:Destroy
	Gui,99:Margin,20,20
	Gui,99:Font,Bold,Microsoft YaHei
	Gui,99:Add,Text,y+10, 【%RunAnyZz%】一劳永逸的快速启动工具 v%RunAny_update_version% @%RunAny_update_time% 
	Gui,99:Font
	Gui,99:Add,Text,y+10, 默认启动菜单热键为``(Esc键下方的重音符键,Win+``输出``)
	Gui,99:Add,Text,y+10, 右键任务栏RunAny图标自定义菜单、热键、图标等配置
	Gui,99:Add,Text,y+10
	Gui,99:Font,,Consolas
	Gui,99:Add,Text,y+10, 作者：hui-Zz 建议：hui0.0713@gmail.com
	Gui,99:Add,Link,y+10,<a href="https://github.com/hui-Zz/RunAny">GitHub：https://github.com/hui-Zz/RunAny</a>
	Gui,99:Add,Text,y+10, 讨论QQ群：
	Gui,99:Add,Link,y+10,<a href="https://jq.qq.com/?_wv=1027&k=445Ug7u">246308937【RunAny快速启动一劳永逸】</a>
	Gui,99:Add,Link,y+10,<a href="https://jq.qq.com/?_wv=1027&k=43uBHer">3222783【AutoHotkey高级群】</a>
	Gui,99:Add,Link,y+10,<a href="https://jq.qq.com/?_wv=1027&k=43trxF5">493194474【软客】</a>
	Gui,99:Font
	Gui,99:Show,,关于%RunAnyZz%
	hCurs:=DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt") ;IDC_HAND
	OnMessage(0x200,"WM_MOUSEMOVE")
	return
SetEvPath:
	FileSelectFile, evFilePath, 3, Everything.exe, Everything安装路径, (Everything.exe)
	if(evFilePath)
		GuiControl,, vEvPath, %evFilePath%
return
SetTcPath:
	FileSelectFile, tcFilePath, 3, , TC安装路径, (Totalcmd.exe;Totalcmd64.exe)
	if(tcFilePath)
		GuiControl,, vTcPath, %tcFilePath%
return
SetBrowserPath:
	FileSelectFile, browserFilePath, 3, , 程序路径, (*.exe)
	if(browserFilePath)
		GuiControl,, vBrowserPath, %BrowserPath%
return
SetAnyIcon:
SetMenuIcon:
SetTreeIcon:
SetFolderIcon:
SetUrlIcon:
SetEXEIcon:
	setEdit:=StrReplace(A_ThisLabel, "Set", "v")
	FileSelectFile, filePath, 3, , 图标图片路径
	if(filePath)
		GuiControl,, %setEdit%, %filePath%
return
SetEvCommand:
	MsgBox,Everything搜索参数语法请打开Everything参照`nEverything-帮助(H)-搜索语法`n
		(
		`n编辑参数完后请务必复制参数到Everthing搜索`n检验是否达到预定效果，以免出现错误
		)
	GuiControl,-ReadOnly,vEvCommand
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
	SetValueList:=["IniConfig","DisableApp"]
	SetValueList.Push("HideFail", "HideUnSelect", "HideRecent", "HideWeb", "HideSend", "HideAddItem")
	SetValueList.Push("MenuKey", "MenuWinKey","MenuAddItemKey","MenuAddItemWinKey")
	SetValueList.Push("EvKey", "EvWinKey", "EvPath","EvCommand","EvAutoClose")
	SetValueList.Push("OneKey", "OneWinKey", "OneKeyUrl", "OneKeyWeb", "OneKeyFolder", "OneKeyMagnet", "OneKeyFile", "OneKeyMenu")
	SetValueList.Push("BrowserPath", "TcPath", "TreeIcon", "FolderIcon", "UrlIcon", "EXEIcon", "AnyIcon", "MenuIcon")
	SetValueList.Push("TreeKey1", "TreeWinKey1", "TreeIniKey1", "TreeIniWinKey1", "PluginsManageKey", "PluginsManageWinKey")
	SetValueList.Push("RunASetKey", "RunASetWinKey", "RunAReloadKey", "RunAReloadWinKey", "RunASuspendKey", "RunASuspendWinKey", "RunAExitKey", "RunAExitWinKey")
	If(MENU2FLAG){
		SetValueList.Push("MenuKey2", "MenuWinKey2", "TreeKey2", "TreeWinKey2", "TreeIniKey2", "TreeIniWinKey2")
	}
	OneKeyUrl:=StrReplace(OneKeyUrl, "`n", "|")
	vOneKeyUrl:=StrReplace(vOneKeyUrl, "`n", "|")
	For vi, vv in SetValueList
	{
		vValue:="v" . vv
		Reg_Set(%vValue%,%vv%,vv)
	}
	Reload
return
SetCancel:
	Gui,Destroy
return
SetReSet:
	MsgBox,49,重置RunAny配置,此操作会删除RunAny所有注册表配置，以及删除本地配置文件%RunAnyConfig%，确认删除重置吗？
	IfMsgBox Ok
	{
		RegDelete, HKEY_CURRENT_USER, SOFTWARE\RunAny
		RegDelete, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, RunAny
		FileDelete, %RunAnyConfig%
		Reload
	}
return
setMenu2:
	MsgBox,33,开启第2个菜单,确定开启第2个菜单吗？`n会在目录生成RunAny2.ini`n（还原1个菜单可以删除或重命名RunAny2.ini）
	IfMsgBox Ok
	{
		text2=;这里添加第2菜单内容
		FileAppend,%text2%,%iniPath2%
		gosub,Menu_Edit2
	}
return
UnCheckWebSend:
	GuiControlGet, outPutVar, , vHideUnSelect
	If(outPutVar){
		GuiControl,, vHideWeb, 0
		GuiControl,, vHideSend, 0
	}
return
Reg_Set(vGui, var, sz){
	if(vGui!=var){
		RegWrite, REG_SZ, HKEY_CURRENT_USER, SOFTWARE\RunAny, %sz%, %vGui%
		IniWrite,%vGui%,%RunAnyConfig%,Config,%sz%
	}
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
;══════════════════════════════════════════════════════════════════
;~;[初始化]
;══════════════════════════════════════════════════════════════════
Var_Set:
	;~;[RunAny设置参数]
	RegRead, AutoRun, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, RunAny
	AutoRun:=AutoRun ? 1 : 0
	RegRead, ReloadEditFlag, HKEY_CURRENT_USER, Software\RunAny, ReloadEditFlag
	ReloadEditFlag:=ReloadEditFlag ? 1 : 0
	;优先读取配置文件，后读注册表
	global IniConfig:=1
	if(FileExist(RunAnyConfig)){
		IniRead,IniConfig,%RunAnyConfig%,Config,IniConfig,1
		RegRead, regVar, HKEY_CURRENT_USER, Software\RunAny, IniConfig
		if ErrorLevel
			IniConfig:=1
	}
	global HideFail:=Var_Read("HideFail",0)
	global HideUnSelect:=Var_Read("HideUnSelect",0)
	global HideRecent:=Var_Read("HideRecent",0)
	global HideWeb:=Var_Read("HideWeb",0)
	global HideSend:=Var_Read("HideSend",0)
	global HideAddItem:=Var_Read("HideAddItem",0)
	global OneKeyWeb:=Var_Read("OneKeyWeb",1)
	global OneKeyFolder:=Var_Read("OneKeyFolder",1)
	global OneKeyMagnet:=Var_Read("OneKeyMagnet",1)
	global OneKeyFile:=Var_Read("OneKeyFile",1)
	global OneKeyMenu:=Var_Read("OneKeyMenu",0)
	global EvCommand:=Var_Read("EvCommand","!C:\*Windows* !?:\$RECYCLE.BIN* file:*.exe|*.lnk|*.ahk|*.bat|*.cmd")
	global EvAutoClose:=Var_Read("EvAutoClose",0)
	global BrowserPath:=Var_Read("BrowserPath")
	global TcPath:=Var_Read("TcPath")
	global TcPathRun:=Get_Transform_Val(TcPath)
	global OneKeyUrl:=Var_Read("OneKeyUrl","https://www.baidu.com/s?wd=%s")
	OneKeyUrl:=StrReplace(OneKeyUrl, "|", "`n")
	global ClipWaitTime:=Var_Read("ClipWaitTime",0.1)	;隐藏配置
	global JumpSearch:=Var_Read("JumpSearch",0)			;隐藏配置
	DisableApp:=Var_Read("DisableApp","vmware-vmx.exe,TeamViewer.exe,War3.exe,dota2.exe,League of Legends.exe")
	EvCommandVar:=RegExReplace(EvCommand,"i).*file:(\*\.[^\s]*).*","$1")
	global EvCommandExtList:=StrSplit(EvCommandVar,"|")
	Loop,parse,DisableApp,`,
	{
		GroupAdd,DisableGUI,ahk_exe %A_LoopField%
	}
	EnvGet, LocalAppData, LocalAppData
	gosub,Icon_Set
	global lpszUrl:="https://raw.githubusercontent.com"
	global RunAnyGithubDir:=lpszUrl . "/hui-Zz/RunAny/master"
	global MenuCommonList:={}
	;~[定期自动检查更新]
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
;~;[图标初始化]
Icon_Set:
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
	global AnyIcon:=Var_Read("AnyIcon",iconAny)
	global AnyIconS:=StrSplit(AnyIcon,",")
	global MenuIcon:=Var_Read("MenuIcon",iconMenu)
	global MenuIconS:=StrSplit(MenuIcon,",")
	global TreeIcon:=Var_Read("TreeIcon",iconTree)
	global TreeIconS:=StrSplit(TreeIcon,",")
	global MoveIconS:=StrSplit(MoveIcon,",")
	global UpIconS:=StrSplit(UpIcon,",")
	global DownIconS:=StrSplit(DownIcon,",")
return
;~;[后缀图标初始化]
Icon_FileExt_Set:
	FolderIcon:=Var_Read("FolderIcon","shell32.dll,4")
	global FolderIconS:=StrSplit(FolderIcon,",")
	UrlIcon:=Var_Read("UrlIcon","shell32.dll,44")
	global UrlIconS:=StrSplit(UrlIcon,",")
	EXEIcon:=Var_Read("EXEIcon","shell32.dll,3")
	global EXEIconS:=StrSplit(EXEIcon,",")
	LNKIcon:="shell32.dll,264"
	if(A_OSVersion="WIN_XP"){
		LNKIcon:="shell32.dll,30"
	}
	global LNKIconS:=StrSplit(LNKIcon,",")
	;[RunAny菜单图标初始化]
	Menu,Tray,Icon,启动菜单(&Z)`t%MenuHotKey%,% TreeIconS[1],% TreeIconS[2]
	Menu,Tray,Icon,修改菜单(&E)`t%TreeHotKey1%,% EXEIconS[1],% EXEIconS[2]
	Menu,Tray,Icon,修改文件(&F)`t%TreeIniHotKey1%,SHELL32.dll,134
	If(MENU2FLAG){
		Menu,Tray,Icon,启动菜单2(&2)`t%MenuHotKey2%,% TreeIconS[1],% TreeIconS[2]
		Menu,Tray,Icon,修改菜单2(&W)`t%TreeHotKey2%,% EXEIconS[1],% EXEIconS[2]
		Menu,Tray,Icon,修改文件2(&G)`t%TreeIniHotKey2%,SHELL32.dll,134
	}
	Menu,Tray,Icon,设置RunAny(&D)`t%RunASetHotKey%,% AnyIconS[1],% AnyIconS[2]
	Menu,Tray,Icon,关于RunAny(&A)...,% MenuIconS[1],% MenuIconS[2]
	Menu,Tray,Icon,插件管理(&C)`t%PluginsManageHotKey%,shell32.dll,166
	Menu,Tray,Icon,检查更新(&U),shell32.dll,14
	Menu,exeTestMenu,add,SetCancel	;只用于测试应用图标正常添加
return
;~;[调用判断]
Run_Exist:
	;#判断菜单配置文件初始化#
	global iniPath:=A_ScriptDir "\" RunAnyZz ".ini"
	global iniPath2:=A_ScriptDir "\" RunAnyZz "2.ini"
	global iniFile:=iniPath
	global iniVar1:=""
	global both:=1
	IfNotExist,%iniFile%
	{
		TrayTip,,RunAny初始化中...,2,1
		gosub,First_Run
	}
	FileRead, iniVar1, %iniPath%
	;#判断第2菜单ini#
	global MENU2FLAG:=false
	IfExist,%iniPath2%
	{
		global iniVar2:=""
		global MENU2FLAG:=true
		FileRead, iniVar2, %iniPath2%
	}
	;#判断配置文件
	if(!FileExist(RunAnyConfig)){
		IniWrite,%IniConfig%,%RunAnyConfig%,Config,IniConfig
	}
	global iniFileVar:=iniVar1
	;#判断Everything拓展DLL文件#
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
			URLDownloadToFile,https://raw.githubusercontent.com/hui-Zz/RunAny/master/%everyDLL%,%A_ScriptDir%\%everyDLL%
			Reload
		}
	}
	global ahkFlag:=false
	global ahkExePath:=A_ScriptDir "\" PluginsDir "\AHK.exe"
	if(FileExist(ahkExePath)){
		ahkFlag:=true
	}
	pluginsDownList:=["RunAny_Menu.ahk","huiZz_MButton.ahk","huiZz_RestTime.ahk"]
return
;~;[RunAny的AHK脚本插件]
Plugins_Read:
	global PluginsObjList:=Object()
	global PluginsPathList:=Object()
	global PluginsTitleList:=Object()
	Loop,%A_ScriptDir%\%PluginsDir%\*.ahk,0	;Plugins目录下AHK脚本
	{
		PluginsObjList[(A_LoopFileName)]:=0
		PluginsPathList[(A_LoopFileName)]:=A_LoopFileFullPath
		PluginsTitleList[(A_LoopFileName)]:=Plugins_Read_Title(A_LoopFileFullPath)
	}
	Loop,%A_ScriptDir%\%PluginsDir%\*.*,2		;Plugins目录下文件夹内同名AHK脚本
	{
		IfExist,%A_ScriptDir%\%PluginsDir%\%A_LoopFileName%.ahk
		{
			PluginsObjList[(A_LoopFileName . ".ahk")]:=0
			PluginsPathList[(A_LoopFileName . ".ahk")]:=A_LoopFileFullPath
			PluginsTitleList[(A_LoopFileName . ".ahk")]:=Plugins_Read_Title(A_LoopFileFullPath)
		}
	}
	IniRead,pluginsVar,%RunAnyConfig%,Plugins
	Loop, parse, pluginsVar, `n, `r
	{
		varList:=StrSplit(A_LoopField,"=")
		SplitPath,% varList[1], name,, ext, name_no_ext
		PluginsObjList[(varList[1])]:=varList[2]
		if(FileExist(A_ScriptDir "\" PluginsDir "\" varList[1]))
			PluginsPathList[(varList[1])]:=A_ScriptDir "\" PluginsDir "\" varList[1]
		if(FileExist(A_ScriptDir "\" PluginsDir "\" name_no_ext "\" varList[1]))
			PluginsPathList[(varList[1])]:=A_ScriptDir "\" PluginsDir "\" name_no_ext "\" varList[1]
	}
	For ki, kv in PluginsObjList
	{
		IniWrite,%kv%,%RunAnyConfig%,Plugins,%ki%
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
GuiIcon_Set:
	;~;[树型菜单图标集]
	global ImageListID := IL_Create(9)
	IL_Add(ImageListID, "shell32.dll", 1)
	IL_Add(ImageListID, "shell32.dll", 2)
	IL_Add(ImageListID, EXEIconS[1], EXEIconS[2])
	IL_Add(ImageListID, FolderIconS[1], FolderIconS[2])
	IL_Add(ImageListID, LNKIconS[1], LNKIconS[2])
	IL_Add(ImageListID, TreeIconS[1], TreeIconS[2])
	IL_Add(ImageListID, UrlIconS[1], UrlIconS[2])
	IL_Add(ImageListID, "shell32.dll", 50)
	IL_Add(ImageListID, "shell32.dll", 100)
	;#菜单加载完后，预读完成"修改菜单"的GUI图标
	Loop, parse, iniVar1, `n, `r, %A_Space%%A_Tab%
	{
		Set_Icon(A_LoopField,false)
	}
	if(menu2){
		Loop, parse, iniVar2, `n, `r, %A_Space%%A_Tab%
		{
			Set_Icon(A_LoopField,false)
		}
	}
return
;~;[自动启动生效]
AutoRun_Effect:
	gosub,AhkExeDown
	try {
		if(ahkFlag){
			For runn, runv in PluginsPathList	;循环启动项
			{
				;需要自动启动的项
				if(PluginsObjList[runn]){
					runValue:=RegExReplace(runv,"iS)(.*?\.exe)($| .*)","$1")	;去掉参数
					SplitPath, runValue, name,, ext  ; 获取扩展名
					if(ext="ahk"){
						Run,%ahkExePath%%A_Space%%runv%
					}else{
						Run,%runv%
					}
				}
			}
		}
	} catch e {
		MsgBox,16,自动启动出错,% "启动项名：" runn "`n启动项路径：" runv "`n出错脚本：" e.File "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
	}
return
;~;[随RunAny自动关闭]
AutoClose_Effect:
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
Check_Github(){
	return DllCall("Wininet.dll\InternetCheckConnection", "Ptr", &lpszUrl, "UInt", 0x1, "UInt", 0x0, "Int")
}
Check_Update:
	checkUpdateFlag:=true
	gosub,Auto_Update
return
Auto_Update:
	if(FileExist(A_Temp "\RunAny_Update.bat"))
		FileDelete, %A_Temp%\RunAny_Update.bat
	;[下载最新的更新脚本]
	if(!Check_Github()){
		MsgBox,网络异常，无法从https://github.com/hui-Zz/RunAny上读取最新版本文件
		return
	}
	URLDownloadToFile,%RunAnyGithubDir%/RunAny.ahk ,%A_Temp%\temp_RunAny.ahk
	versionReg=iS)^\t*\s*global RunAny_update_version:="([\d\.]*)"
	Loop, read, %A_Temp%\temp_RunAny.ahk
	{
		if(RegExMatch(A_LoopReadLine,versionReg)){
			versionStr:=RegExReplace(A_LoopReadLine,versionReg,"$1")
			break
		}
		if(A_LoopReadLine="404: Not Found"){
			MsgBox,文件下载异常，更新失败！
			return
		}
	}
	if(versionStr){
		if(RunAny_update_version<versionStr){
			MsgBox,33,RunAny检查更新,检测到RunAny有新版本`n`n%RunAny_update_version%`t版本更新后=>`t%versionStr%`n`n是否更新到最新版本？`n覆盖老版本文件，如有修改过RunAny.ahk请注意备份！
			IfMsgBox Ok
			{
				TrayTip,,RunAny下载最新版本并替换老版本...,5,1
				gosub,Config_Update
				URLDownloadToFile,%RunAnyGithubDir%/RunAny.exe ,%A_Temp%\temp_RunAny.exe
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
	if(InStr(EvCommand,"!C:\*Windows* file:*.exe")=1){
		vEvCommand:=StrReplace(EvCommand,"!C:\*Windows* file:*.exe","!C:\*Windows* !?:\$RECYCLE.BIN* file:*.exe")
		Reg_Set(vEvCommand,EvCommand,"EvCommand")
	}
	IfNotExist %A_ScriptDir%\实用配置
		FileCreateDir,%A_ScriptDir%\实用配置
	configDownList:=["实用命令.ini","搜索网址.ini","热键映射.ini"]
	For i, v in configDownList
	{
		URLDownloadToFile,%RunAnyGithubDir%/实用配置/%v% ,%A_ScriptDir%\实用配置\%v%
	}
return
RunAny_Update:
Run,https://github.com/hui-Zz/RunAny/wiki/RunAny版本更新历史
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
;~;[托盘菜单]
MenuTray:
	Menu,Tray,NoStandard
	Menu,Tray,Icon,% MenuIconS[1],% MenuIconS[2]
	Menu,Tray,add,启动菜单(&Z)`t%MenuHotKey%,Menu_Show1
	Menu,Tray,add,修改菜单(&E)`t%TreeHotKey1%,Menu_Edit1
	Menu,Tray,add,修改文件(&F)`t%TreeIniHotKey1%,Menu_Ini
	Menu,Tray,add
	Menu,Tray,add,设置RunAny(&D)`t%RunASetHotKey%,Menu_Set
	Menu,Tray,Add,关于RunAny(&A)...,Menu_About
	Menu,Tray,Add,插件管理(&C)`t%PluginsManageHotKey%,Plugins_Manage
	Menu,Tray,Add,检查更新(&U),Check_Update
	Menu,Tray,add
	If(MENU2FLAG){
		Menu,Tray,add,启动菜单2(&2)`t%MenuHotKey2%,Menu_Show2
		Menu,Tray,add,修改菜单2(&W)`t%TreeHotKey2%,Menu_Edit2
		Menu,Tray,add,修改文件2(&G)`t%TreeIniHotKey2%,Menu_Ini2
		Menu,Tray,add
	}
	Menu,Tray,add,重启(&R)`t%RunAReloadHotKey%,Menu_Reload
	Menu,Tray,add,停用(&S)`t%RunASuspendHotKey%,Menu_Suspend
	Menu,Tray,add,退出(&X)`t%RunAExitHotKey%,Menu_Exit
	Menu,Tray,Default,启动菜单(&Z)`t%MenuHotKey%
	Menu,Tray,Click,1
return
Menu_Ini:
	Run,%iniPath%
return
Menu_Ini2:
	Run,%iniPath2%
return
Menu_Config:
	Run,%RunAnyConfig%
return
Menu_Reload:
	Reload
return
Menu_Suspend:
	Menu,tray,ToggleCheck,停用(&S)`t%RunASuspendHotKey%
	Suspend
return
Menu_Exit:
	gosub,AutoClose_Effect
	ExitApp
return
RemoveToolTip:
	SetTimer,RemoveToolTip,Off
	ToolTip
return
ExitSub:
	gosub,AutoClose_Effect
	ExitApp
return
;══════════════════════════════════════════════════════════════════
;~;[使用everything搜索所有exe程序]
everythingQuery(){
	ev := new everything
	;查询字串设为everything
	ev.SetSearch(EvCommand)
	;执行搜索
	ev.Query()
	while,% !ev.GetTotResults()
	{
		if(A_Index>300){
			MsgBox,16,Everything启动异常,Everything不能读取磁盘文件，`n请打开Everything设置以下其中一项：`n* 以管理员身份运行(A)`n* 安装Everything服务(S)
			break
		}
		Sleep, 100
		ev.Query()
	}
	Loop,% ev.GetTotResults()
	{
		Z_Index:=A_Index-1
		MenuObj[(RegExReplace(ev.GetResultFileName(Z_Index),"iS)\.exe$",""))]:=ev.GetResultFullPathName(Z_Index)
	}
}
;~;[使用everything搜索单个exe程序]
exeQuery(exeName){
	ev := new everything
	str := exeName . " !C:\*Windows*"
	;查询字串设为全字匹配
	ev.SetMatchWholeWord(true)
	ev.SetSearch(str)
	;执行搜索
	ev.Query()
	return ev.GetResultFullPathName(0)
}
;~;[修改于AHK论坛，IPC方式和everything进行通讯]
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
	IE(&E)|C:\Program Files (x86)\Internet Explorer\iexplore.exe
	;2级分隔符【--】
	--
	StrokesPlus鼠标手势|StrokesPlus.exe
	Ditto剪贴板|Ditto.exe
-办公(Wo&rk)|doc docx xls xlsx ppt pptx wps et dps
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
	异次元软件|http://www.iplaysoft.com/search/?s=548512288484505211&q=
	淘宝(&T)|https://s.taobao.com/search?q=
	京东(&D)|https://search.jd.com/Search?keyword=`%s&enc=utf-8
	知乎(&Z)|https://www.zhihu.com/search?type=content&q=
	B站|http://search.bilibili.com/all?keyword=
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
-其他(&Other)
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
global ini:=true
return
