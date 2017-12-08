/*
╔══════════════════════════════════════════════════
║【RunAny】一劳永逸的快速启动工具 v5.0 @2017.12.08 Logic重构计划(去GUI)
║ https://github.com/hui-Zz/RunAny
║ by Zz 建议：hui0.0713@gmail.com
║ 讨论QQ群：[246308937]、3222783、493194474
╚══════════════════════════════════════════════════
*/
#Persistent			;~让脚本持久运行
#NoEnv					;~不检查空变量为环境变量
#SingleInstance,Force	;~运行替换旧实例
#WinActivateForce		;~强制激活窗口
;~ Process Priority,,High	;~进程优先级高
ListLines,Off			;~不显示最近执行的脚本行
CoordMode,Menu			;~相对于整个屏幕
SetBatchLines,-1		;~脚本全速执行
SetWorkingDir,%A_ScriptDir%	;~脚本当前工作目录
;~ StartTick:=A_TickCount	;若要评估出menu时间
global RunAnyZz:="RunAny"	;名称
global RunAnyConfig:="RunAnyConfig.ini" ;~配置文件
global fast:=true	;~启用预先快速无图标
Gosub,Var_Set		;~参数初始化
Gosub,Run_Exist		;~调用判断依赖
global MenuObj:=Object()		;~程序全径
global MenuObjKey:=Object()	;~程序热键
global MenuObjName:=Object()	;~程序别名
global MenuObjParam:=Object()	;~程序参数
global MenuObjExt:=Object()	;~后缀对应菜单
;══════════════════════════════════════════════════════════════════
;~;[初始化菜单显示热键]
Hotkey, IfWinNotActive, ahk_group DisableGUI
HotKeyList:=["MenuHotKey","MenuHotKey2","EvHotKey","OneHotKey","TreeIniHotKey1","TreeIniHotKey2","RunAReloadHotKey","RunASuspendHotKey","RunAExitHotKey"]
RunList:=["Menu_Show","Menu_Show2","Ev_Show","One_Show","Menu_Ini","Menu_Ini2","Menu_Reload","Menu_Suspend","Menu_Exit"]
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
For ki, kv in HotKeyList
{
	StringReplace,keyV,kv,Hot
	StringReplace,winkeyV,kv,Hot,Win
	if(%keyV%){
		if(!MENU2FLAG && ki in 2,6,8){
			continue
		}
		%kv%:=%winkeyV% ? "#" . %keyV% : %keyV%
		try{
			Hotkey,% %kv%,% RunList[ki],On
		}catch{
			;~ gosub,Menu_Set
			;~ if(ki!=1 && ki!=2)
				;~ SendInput,^{Tab}
			MsgBox,16,RunAny热键配置不正确,% "热键错误：" %kv% "`n请设置正确热键后重启RunAny"
		}
	}
}
Gosub,MenuTray	;~托盘菜单
;══════════════════════════════════════════════════════════════════
;~;[初始化everything安装路径]
evExist:=true
EvPath:=Var_Read("EvPath")
DetectHiddenWindows,On
while !WinExist("ahk_exe Everything.exe")
{
	Sleep,100
	if(A_Index>10){
		if(EvPath && RegExMatch(EvPath,"iS)^.*?\.exe$")){
			Run,%EvPath% -startup
			Sleep,300
			break
		}else{
			;~ gosub,Menu_Set
			MsgBox,17,,RunAny需要Everything极速识别程序的路径`n请使用以下任意一种方式：`n* 运行Everything后重启RunAny`n* 设置RunAny中Everything正确安装路径`n* 下载Everything并安装后再运行RunAny：http://www.voidtools.com/
			IfMsgBox Ok
				Run,http://www.voidtools.com/
			evExist:=false
			break
		}
	}
}
DetectHiddenWindows,Off
;~;[使用everything读取整个系统所有exe]
If(evExist){
	everythingQuery()
	if(!EvPath){
		;>>发现Everything已运行则取到路径
		WinGet, EvPath, ProcessPath, ahk_exe Everything.exe
	}
}
;══════════════════════════════════════════════════════════════════
;~;[后缀图标初始化]
Gosub,Icon_FileExt_Set
;#应用菜单数组#网址菜单名数组及地址队列#
menuRoot:=Object()
menuWebRoot:=Object()
menuWebList:=Object()
menuRoot.Insert(RunAnyZz)
menuWebRoot.Insert(RunAnyZz . "Web")
menuWebRoot.Insert(RunAnyZz)
;~;[快速创建无图标应用菜单]
if(fast){
	Menu_Read(iniVar1,true,menuRoot,1,menuWebRoot,menuWebList,false)
}
;~;[读取带图标的自定义应用菜单]
Menu_Read(iniVar1,false,menuRoot,1,menuWebRoot,menuWebList,false)
Menu,% menuRoot[1],Add

;#如果是第一次运行#
if(ini){
	ini:=false
	TrayTip,,RunAny菜单初始化完成`n右击任务栏图标设置,3,1
	;~ gosub,Menu_About
	;~ gosub,Menu_Show
}
;~;[如果有第2菜单则开始加载]
global menu2:=MENU2FLAG
if(menu2){
	menuRoot2:=Object()
	menuWebRoot2:=Object()
	menuWebList2:=Object()
	menuRoot2.Insert(RunAnyZz . "2")
	menuWebRoot2.Insert(RunAnyZz . "Web2")
	menuWebRoot2.Insert(RunAnyZz . "2")
	Menu_Read(iniVar2,false,menuRoot2,1,menuWebRoot2,menuWebList2,false)
}
;~ TrayTip,,% A_TickCount-StartTick "毫秒",3,17
;#菜单已经加载完毕，托盘图标变化
try Menu,Tray,Icon,% AnyIconS[1],% AnyIconS[2]
return
;══════════════════════════════════════════════════════════════════
;~;[读取配置并开始创建菜单]
;══════════════════════════════════════════════════════════════════
Menu_Read(iniReadVar,fast,menuRoot,menuLevel,menuWebRoot,menuWebList,webRootShow){
	Loop, parse, iniReadVar, `n, `r
	{
		try{
			Z_ReadLine=%A_LoopField%
			if(InStr(Z_ReadLine,";")=1 || Z_ReadLine=""){
				continue
			}
			if(InStr(Z_ReadLine,"-")=1){
				;~;[生成节点树层级结构]
				menuItem:=RegExReplace(Z_ReadLine,"S)^-+")
				menuLevel:=StrLen(RegExReplace(Z_ReadLine,"S)(^-+).*","$1"))
				if(InStr(menuItem,"|")){
					menuItems:=StrSplit(menuItem,"|")
					menuItem:=menuItems[1]
					Loop, parse,% menuItems[2],%A_Space%
					{
						MenuObjExt[(A_LoopField)]:=menuItem
					}
				}
				if(menuItem){
					Menu,%menuItem%,add
					Menu,% menuRoot[menuLevel],add,%menuItem%,:%menuItem%
					Menu,% menuRoot[menuLevel],Icon,%menuItem%,% TreeIconS[1],% TreeIconS[2]
					menuLevel+=1
					menuRoot[menuLevel]:=menuItem
				}else if((fast || menu2) && menuRoot[menuLevel]){
					Menu,% menuRoot[menuLevel],Add
				}
				continue
			}
			if(InStr(Z_ReadLine,"|")){
				;~;[生成有前缀备注的应用]
				menuDiy:=StrSplit(Z_ReadLine,"|")
				appName:=RegExReplace(menuDiy[2],"iS)\.exe($| .*)")	;去掉后缀或参数，取应用名
				item:=MenuObj[appName]
				if(MenuObj[appName]){
					MenuObj[menuDiy[1]]:=RegExReplace(menuDiy[2],"S)^" appName "\.exe",MenuObj[appName])
				}else{
					MenuObj[menuDiy[1]]:=menuDiy[2]
					item:=menuDiy[2]
				}
				;~;[分割Tab获取应用自定义热键]
				if(InStr(menuDiy[1],"`t")){
					menuKeyStr:=RegExReplace(menuDiy[1], "S)\t+", A_Tab)
					menuKeys:=StrSplit(menuKeyStr,"`t")
					if(menuKeys[2]){
						MenuObjKey[menuKeys[2]]:=MenuObj[menuDiy[1]]
						MenuObjName[menuKeys[2]]:=menuKeys[1]
						Hotkey,% menuKeys[2],Menu_Key_Run,On
					}
				}
				if(fast){
					Menu_Add_Fast(menuRoot[menuLevel],menuDiy[1])
				}else{
					Menu_Add(menuRoot[menuLevel],menuDiy[1],item,fast,menuRoot,menuWebRoot,menuWebList,webRootShow)
				}
				continue
			}
			if(RegExMatch(Z_ReadLine,"iS)^(\\\\|.:\\).*?\.exe$")){
				;~;[生成完全路径的应用]
				SplitPath,Z_ReadLine,fileName,,,nameNotExt
				MenuObj[nameNotExt]:=Z_ReadLine
				if(fast){
					Menu_Add_Fast(menuRoot[menuLevel],nameNotExt)
				}else{
					Menu_Add(menuRoot[menuLevel],nameNotExt,Z_ReadLine,fast,menuRoot,menuWebRoot,menuWebList,webRootShow)
				}
				continue
			}
			;~;[生成已取到的应用]
			appName:=RegExReplace(Z_ReadLine,"iS)\.exe$")
			if(!MenuObj[appName])
				MenuObj[appName]:=Z_ReadLine
			if(fast){
				Menu_Add_Fast(menuRoot[menuLevel],appName)
			}else{
				Menu_Add(menuRoot[menuLevel],appName,MenuObj[appName],fast,menuRoot,menuWebRoot,menuWebList,webRootShow)
			}
		} catch e {
			MsgBox,16,构建菜单出错,% "菜单名：" menuRoot[menuLevel] "`n菜单项：" Z_ReadLine "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
		}
	}
	;#添加网址菜单的批量搜索功能
	Loop,% menuWebRoot.MaxIndex()
	{
		if(A_Index!=1){	;忽略比较menuWebRoot第1层web菜单
			webRoot:=menuWebRoot[A_Index]
			if(webRoot = menuRoot[1]){
				if(webRootShow){
					Menu,% menuWebRoot[1],add
					Menu,% menuWebRoot[1],add,&1批量搜索,Web_Run
					Menu,% menuWebRoot[1],Icon,&1批量搜索,% UrlIconS[1],% UrlIconS[2]
				}else if(menu2){
					Menu,% menuWebRoot[1],add	;避免菜单2无网址而报错
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
Menu_Add(menuName,menuItem,item,fast,menuRoot,menuWebRoot,menuWebList,webRootShow){
	if not menuName
		return
	try {
		;~ item:=MenuObj[(menuItem)]
		itemLen:=StrLen(item)
		SplitPath, item,,, FileExt  ; 获取文件扩展名.
		if(HideUnSelect)
			Menu,%menuName%,add,%menuItem%,Menu_Run
		if(item && InStr(item,";",,0,1)=itemLen){  ; {短语}
			Menu,%menuName%,add,%menuItem%,Menu_Run
			Menu,%menuName%:,add,%menuItem%,Menu_Run
			Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,2
			Menu,%menuName%:,Icon,%menuItem%,SHELL32.dll,2
			if(menuName = menuRoot[1]){
				Menu,% menuWebRoot[1],Add,%menuItem%,Menu_Run
				Menu,% menuWebRoot[1],Icon,%menuItem%,SHELL32.dll,2
				webRootShow:=true
			}else{
				Menu,% menuWebRoot[1],Add,%menuName%:, :%menuName%:
			}
			if(HideSend)
				Menu,%menuName%,Delete,%menuItem%
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
			if(menuName = menuRoot[1]){
				Menu,% menuWebRoot[1],Add,%menuItem%,Menu_Run
				if(FileExist(webIcon)){
					Menu,% menuWebRoot[1],Icon,%menuItem%,%webIcon%,0
				}else{
					Menu,% menuWebRoot[1],Icon,%menuItem%,% UrlIconS[1],% UrlIconS[2]
				}
				webRootShow:=true
			}else{
				Menu,% menuWebRoot[1],Add,%menuName%:, :%menuName%:
			}
			menuWebList[(menuName ":")].=menuItem "`n"	; 添加到批量搜索
			if(!HideWeb)
				menuWebList[(menuName)].=menuItem "`n"	; 添加到批量搜索
			;~ [创建网址所在的不重复菜单节点]
			menuWebSame:=false
			Loop,% menuWebRoot.MaxIndex()
			{
				if(menuWebRoot[A_Index]=menuName || menuWebRoot[A_Index]=menuName ":"){
					menuWebSame:=true
					break
				}
			}
			if(!menuWebSame){
				menuWebRoot.Insert(menuName ":")
				if(!HideWeb)
					menuWebRoot.Insert(menuName)
			}
			if(HideWeb)
				Menu,%menuName%,Delete,%menuItem%
			return
		}
		if(!fast)
			Menu,%menuName%,add,%menuItem%,Menu_Run
		if(item && InStr(item,"\",,0,1)=itemLen){  ; {目录}
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
		}else if FileExt in EXE,ICO
		{
			Menu,%menuName%,Icon,%menuItem%,%item%
		}else{  ; {处理未知的项目图标}
			If(FileExist(item)){
				RegRead, regFileExt, HKEY_CLASSES_ROOT, .%FileExt%
				RegRead, regFileIcon, HKEY_CLASSES_ROOT, %regFileExt%\DefaultIcon
				regFileIconS:=StrSplit(regFileIcon,",")
				Menu,%menuName%,Icon,%menuItem%,% regFileIconS[1],% regFileIconS[2]
			}else if(!HideFail){
				Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,124
			}else{
				Menu,%menuName%,Delete,%menuItem%
			}
		}
	} catch e {
		;应用路径错误或图标无法读取情况
		try{
			if(HideFail){
				If(FileExist(item)){
					Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,124
				}else{
					Menu,%menuName%,Delete,%menuItem%
				}
			}else{
				Menu,%menuName%,Icon,%menuItem%,% EXEIconS[1],% EXEIconS[2]
			}
		} catch e {
			MsgBox,16,创建菜单项出错,% "菜单名：" menuName "`n菜单项：" menuItem "`n路径：" item "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
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
	try{
		global selectZz:=Get_Zz()
		if(selectZz){
			if(Candy_isFile){
				SplitPath, selectZz,,, FileExt  ; 获取文件扩展名.
				try{
					Menu,% MenuObjExt[(FileExt)],Show
				}catch{
					Menu,% menuRoot[1],Show
				}
				return
			}
			;一键打开网址
			if(OneKeyWeb && RegExMatch(selectZz,"iS)([\w-]+://?|www[.]).*")){
				Run,%selectZz%
				return
			}
			if(RegExMatch(selectZz,"S)^(\\\\|.:\\)")){
				;一键打开目录
				if(OneKeyFolder && InStr(FileExist(selectZz), "D")){
					If(TcPath){
						Run,%TcPath%%A_Space%"%selectZz%"
					}else{
						Run,%selectZz%
					}
					return
				}
				;一键打开文件
				if(OneKeyFile && Fileexist(selectZz)){
					Run,%selectZz%
					return
				}
			}
			;#绑定菜单1为一键搜索
			if(OneKeyMenu){
				gosub,One_Search
				return
			}
			;#选中文本弹出网址菜单#
			if(!HideUnSelect){
				Menu,% menuWebRoot[1],Show
				return
			}
		}
		;#其他弹出应用菜单#
		Menu,% menuRoot[1],Show
	}catch{}
return
Menu_Show2:
	try{
		global selectZz:=Get_Zz()
		;#选中文本弹出网址菜单，其他弹出应用菜单#
		if(selectZz && !HideUnSelect && Candy_isFile!=1){
			Menu,% menuWebRoot2[1],Show
		}else{
			Menu,% menuRoot2[1],Show
		}
	}catch{}
return
;~;[菜单运行]
Menu_Run:
	any:=MenuObj[(A_ThisMenuItem)]
	SplitPath, any, , dir
	SetWorkingDir,%dir%
	if(!HideRecent && !RegExMatch(A_ThisMenuItem,"S)^&1|2"))
		gosub,Menu_Recent
	try {
		anyLen:=StrLen(any)
		If(InStr(any,";",,0,1)=anyLen){
			StringLeft, any, any, anyLen-1
			Send_Zz(any)	;[输出短语]
			return
		}
		If(GetKeyState("Ctrl") || InStr(any,"\",,0,1)=anyLen){	;[按住Ctrl是打开应用目录]
			If(TcPath){
				Run,%TcPath%%A_Space%"%any%"
			}else{
				Run,% "explorer.exe /select," any
			}
			return
		}
		try {
			if(selectZz){
				if(Candy_isFile=1 || Fileexist(selectZz)){
					if(GetKeyState("Shift")){
						Run,*RunAs %any%%A_Space%"%selectZz%"
					}else{
						Run,%any%%A_Space%"%selectZz%"
					}
				}else if(RegExMatch(any,"iS)([\w-]+://?|www[.]).*")){
					if(InStr(any,"%s")){
						Run,% RegExReplace(any,"S)%s",selectZz)
					}else{
						Run,%any%%selectZz%
					}
				}else{
					Run,%any%
				}
				return
			}
		} catch {}
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
	selectZz:=Get_Zz()
	any:=menuObjkey[(A_ThisHotkey)]
	thisMenuName:=MenuObjName[(A_ThisHotkey)]
	SplitPath, any, , dir
	SetWorkingDir,%dir%
	try {
		anyLen:=StrLen(any)
		If(InStr(any,";",,0,1)=anyLen){
			StringLeft, any, any, anyLen-1
			Send_Zz(any)	;[输出短语]
			return
		}
		try {
			if(selectZz){
				if(Candy_isFile=1 || Fileexist(selectZz)){
					Run,%any%%A_Space%"%selectZz%"
				}else if(RegExMatch(any,"iS)([\w-]+://?|www[.]).*")){
					if(InStr(any,"%s")){
						Run,% RegExReplace(any,"S)%s",selectZz)
					}else{
						Run,%any%%selectZz%
					}
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
		} catch {}
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
	webName:=RegExReplace(A_ThisMenuItem,"iS)^&1批量搜索")
	if(webName){
		webList:=(A_ThisHotkey=MenuHotKey2) ? menuWebList2[(webName)] : menuWebList[(webName)]
	}else{
		webList:=(A_ThisHotkey=MenuHotKey2) ? menuWebList2[(menuRoot2[1])] : menuWebList[(menuRoot[1])]
	}
	MsgBox,33,开始批量搜索%webName%,确定用【%selectZz%】批量搜索以下网站：`n%webList%
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
Run_Zz(program){
	If !WinExist("ahk_exe" program)
		Run,%program%
	else
		WinGet,l,List,ahk_exe %program%
		if l=1
			If WinActive("ahk_exe" program)
				WinMinimize
			else
				WinActivate
		else
			WinActivateBottom,ahk_exe %program%
	return
}
Run_Tr(program,trNum,newOpen=false){
	If(newOpen || !WinExist("ahk_exe" program)){
		Run,%program%
		WinWait,ahk_exe %program%
		;~ WinSet,Style,-0xC00000,
		try WinSet,Style,-0x40000,ahk_exe %program%
		WinSet,Transparent,% trNum/100*255,ahk_exe %program%
	}else
		Run_Zz(program)
	return
}
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
;~;[一键搜索]
One_Show:
	selectZz:=Get_Zz()
	gosub,One_Search
return
One_Search:
	Loop,parse,OnePath,`n
	{
		if(A_LoopField){
			if(InStr(A_LoopField,"%s")){
				Run,% RegExReplace(A_LoopField,"%s",selectZz)
			}else{
				Run,% A_LoopField selectZz
			}
		}
	}
return
;══════════════════════════════════════════════════════════════════
;~;[初始化]
;══════════════════════════════════════════════════════════════════
Var_Set:
	;~;[RunAny设置参数]
	RegRead, AutoRun, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, RunAny
	AutoRun:=AutoRun ? 1 : 0
	global IniConfig:=0
	if(FileExist(RunAnyConfig)){
		IniRead,IniConfig,%RunAnyConfig%,Config,IniConfig
	}
	global HideFail:=Var_Read("HideFail",0)
	global HideUnSelect:=Var_Read("HideUnSelect",0)
	global HideRecent:=Var_Read("HideRecent",0)
	global HideWeb:=Var_Read("HideWeb",0)
	global HideSend:=Var_Read("HideSend",0)
	global OneKeyWeb:=Var_Read("OneKeyWeb",1)
	global OneKeyFolder:=Var_Read("OneKeyFolder",1)
	global OneKeyFile:=Var_Read("OneKeyFile",1)
	global OneKeyMenu:=Var_Read("OneKeyMenu",0)
	global EvCommand:=Var_Read("EvCommand","!C:\*Windows* file:*.exe|*.lnk|*.ahk|*.bat|*.cmd")
	TcPath:=Var_Read("TcPath")
	OnePath:=Var_Read("OnePath","https://www.baidu.com/s?wd=%s")
	DisableApp:=Var_Read("DisableApp","vmware-vmx.exe,TeamViewer.exe")
	Loop,parse,DisableApp,`,
	{
		GroupAdd,DisableGUI,ahk_exe %A_LoopField%
	}
	gosub,Icon_Set
	global MenuCommonList:={}
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
	if(Ext_Check(A_ScriptName,StrLen(A_ScriptName),".exe")){
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
	;[使系统程序不被无全路径而误隐藏图标]
	MenuObj["cmd"]:="cmd.exe"
	MenuObj["explorer"]:="explorer.exe"
	;[RunAny菜单图标初始化]
	Menu,Tray,Icon,启动菜单(&Z)`t%MenuHotKey%,% TreeIconS[1],% TreeIconS[2]
	;~ Menu,Tray,Icon,修改菜单(&E)`t%TreeHotKey1%,% EXEIconS[1],% EXEIconS[2]
	Menu,Tray,Icon,修改文件(&F)`t%TreeIniHotKey1%,SHELL32.dll,134
	If(MENU2FLAG){
		;~ Menu,Tray,Icon,修改菜单2(&W)`t%TreeHotKey2%,% EXEIconS[1],% EXEIconS[2]
		Menu,Tray,Icon,修改文件2(&G)`t%TreeIniHotKey2%,SHELL32.dll,134
	}
	;~ Menu,Tray,Icon,设置RunAny(&D)`t%RunASetHotKey%,% AnyIconS[1],% AnyIconS[2]
	;~ Menu,Tray,Icon,关于RunAny(&A)...,% MenuIconS[1],% MenuIconS[2]
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
		gosub,First_Run
	FileRead, iniVar1, %iniPath%
	;#判断第2菜单ini#
	IfExist,%iniPath2%
	{
		global iniVar2:=""
		global MENU2FLAG:=true
		FileRead, iniVar2, %iniPath2%
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
return
;~;[检查后缀名]
Ext_Check(name,len,ext){
	len_ext:=StrLen(ext)
	site:=InStr(name,ext,,0,1)
	return site!=0 && site=len-len_ext+1
}
;~;[读取注册表]
Var_Read(rValue,defVar=""){
	if(IniConfig){
		IniRead, regVar,%RunAnyConfig%, Config, %rValue%, %defVar%
	}else{
		RegRead, regVar, HKEY_CURRENT_USER, SOFTWARE\RunAny, %rValue%
	}
	if(regVar)
		if(InStr(regVar,"ZzIcon.dll") && !FileExist(A_ScriptDir "\ZzIcon.dll"))
			return defVar
		else
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
	;~ if WinActive("ahk_class TTOTAL_CMD")
		;~ ClipWait,0.2
	;~ else
		ClipWait,0.1
	If(ErrorLevel){
		Clipboard:=Candy_Saved
		return
	}
	Candy_isFile:=DllCall("IsClipboardFormatAvailable","UInt",15)
	CandySel=%Clipboard%
	Clipboard:=Candy_Saved
	return CandySel
}
;~;[获取应用路径]
Get_Obj_Path(Z_ReadLine){
	if(InStr(Z_ReadLine,"|")){
		menuDiy:=StrSplit(Z_ReadLine,"|")
		return MenuObj[menuDiy[1]]
	}else if(RegExMatch(Z_ReadLine,"iS)^(\\\\|.:\\).*?\.exe$")){
		return Z_ReadLine
	}else{
		appName:=RegExReplace(Z_ReadLine,"iS)\.exe$")
		return MenuObj[appName]
	}
}
;══════════════════════════════════════════════════════════════════
;~;[菜单配置Gui]
SetCancel:
return
;══════════════════════════════════════════════════════════════════
;~;[托盘菜单]
MenuTray:
	Menu,Tray,NoStandard
	Menu,Tray,Icon,% MenuIconS[1],% MenuIconS[2]
	Menu,Tray,add,启动菜单(&Z)`t%MenuHotKey%,Menu_Show
	;~ Menu,Tray,add,修改菜单(&E)`t%TreeHotKey1%,Menu_Edit1
	Menu,Tray,add,修改文件(&F)`t%TreeIniHotKey1%,Menu_Ini
	Menu,Tray,add
	;~ Menu,Tray,add,设置RunAny(&D)`t%RunASetHotKey%,Menu_Set
	;~ Menu,Tray,Add,关于RunAny(&A)...,Menu_About
	;~ Menu,Tray,add
	If(MENU2FLAG){
		Menu,Tray,add,启动菜单2(&2)`t%MenuHotKey2%,Menu_Show2
		;~ Menu,Tray,add,修改菜单2(&W)`t%TreeHotKey2%,Menu_Edit2
		Menu,Tray,add,修改文件2(&G)`t%TreeIniHotKey2%,Menu_Ini2
		Menu,Tray,add
	}
	Menu,Tray,add,重启(&R)`t%RunAReloadHotKey%,Menu_Reload
	Menu,Tray,add,挂起(&S)`t%RunASuspendHotKey%,Menu_Suspend
	Menu,Tray,add,退出(&X)`t%RunAExitHotKey%,Menu_Exit
	;~ Menu,Tray,Default,启动菜单(&Z)`t%MenuHotKey%
	Menu,Tray,Default,重启(&R)`t%RunAReloadHotKey%
	Menu,Tray,Click,1
return
Menu_Ini:
	Run,%iniPath%
return
Menu_Ini2:
	Run,%iniPath2%
return
Menu_Reload:
	Reload
return
Menu_Suspend:
	Menu,tray,ToggleCheck,挂起(&S)`t%RunASuspendHotKey%
	Suspend
return
Menu_Exit:
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
-常用(&App)
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
-编辑(&Edit)
	记事本(&N)|notepad.exe
	--
	winword.exe
	excel.exe
	powerpnt.exe
-图片(im&G)
	画图(&T)|mspaint.exe
	ACDSee.exe
	XnView.exe
	IrfanView.exe
-影音(&Video)
	cloudmusic.exe
	--
	QQPlayer.exe
	PotPlayer.exe
-网址(&Web)
	百度(&B)|https://www.baidu.com/s?wd=
	翻译(&F)|http://translate.google.cn/#auto/zh-CN/
	淘宝(&T)|https://s.taobao.com/search?q=
	--
	RunAny地址|https://github.com/hui-Zz/RunAny
-文件(&File)
	WinRAR.exe
-系统(&Sys)
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
