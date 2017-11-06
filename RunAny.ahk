/*
╔══════════════════════════════════════════════════
║【RunAny】一劳永逸的快速启动工具 v4.8 @2017.11.06 不同后缀不同菜单
║ https://github.com/hui-Zz/RunAny
║ by Zz 建议：hui0.0713@gmail.com
║ 讨论QQ群：[246308937]、3222783、493194474
╚══════════════════════════════════════════════════
*/
#Persistent			;~让脚本持久运行
#NoEnv					;~不检查空变量为环境变量
#SingleInstance,Force	;~运行替换旧实例
#WinActivateForce		;~强制激活窗口
Process Priority,,High	;~进程优先级高
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
MenuTray()			;~托盘菜单
global MenuObj:=Object()		;~程序全径
global MenuObjKey:=Object()	;~程序热键
global MenuObjName:=Object()	;~程序别名
global MenuObjExt:=Object()	;~后缀对应菜单
;══════════════════════════════════════════════════════════════════
;~;[初始化菜单显示热键]
MenuKey:=Var_Read("MenuKey","``")
MenuWinKey:=Var_Read("MenuWinKey",0)
MenuKey2:=Var_Read("MenuKey2")
MenuWinKey2:=Var_Read("MenuWinKey2",0)
EvKey:=Var_Read("EvKey")
EvWinKey:=Var_Read("EvWinKey",0)
OneKey:=Var_Read("OneKey")
OneWinKey:=Var_Read("OneWinKey",0)
TreeKey1:=Var_Read("TreeKey1")
TreeWinKey1:=Var_Read("TreeWinKey1",0)
TreeKey2:=Var_Read("TreeKey2")
TreeWinKey2:=Var_Read("TreeWinKey2",0)
;~;[设定RunAny菜单自定义热键]
try{
	MenuHotKey:=MenuWinKey ? "#" . MenuKey : MenuKey
	Hotkey, IfWinNotActive, ahk_group DisableGUI
	Hotkey,%MenuHotKey%,Menu_Show,On
}catch{
	gosub,Menu_Set
	MsgBox,16,请设置正确热键,%MenuHotKey%`nRunAny菜单自定义热键设置不正确
}
if(MenuKey2 && MENU2FLAG){
	try{
		MenuHotKey2:=MenuWinKey2 ? "#" . MenuKey2 : MenuKey2
		Hotkey,%MenuHotKey2%,Menu_Show2,On
	}catch{
		gosub,Menu_Set
		MsgBox,16,请设置正确热键,%MenuHotKey2%`n菜单2自定义热键设置不正确
	}
}
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
if(TreeKey1){
	try{
		TreeHotKey1:=TreeWinKey1 ? "#" . TreeKey1 : TreeKey1
		Hotkey,%TreeHotKey1%,Menu_Edit1,On
	}catch{
		gosub,Menu_Edit1
		MsgBox,16,请设置正确热键,%TreeHotKey1%`n修改菜单(1)热键设置不正确
	}
}
if(TreeKey2){
	try{
		TreeHotKey2:=TreeWinKey2 ? "#" . TreeKey2 : TreeKey2
		Hotkey,%TreeHotKey2%,Menu_Edit2,On
	}catch{
		gosub,Menu_Edit1
		MsgBox,16,请设置正确热键,%TreeHotKey2%`n修改菜单(2)热键设置不正确
	}
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
		if(EvPath && RegExMatch(EvPath,"iS)^.*?\.exe$")){
			Run,%EvPath% -startup
			Sleep,1000
			break
		}else{
			gosub,Menu_Set
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
	gosub,Menu_About
	gosub,Menu_Show
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
;~;[树型菜单图标集]
global ImageListID := IL_Create(7)
IL_Add(ImageListID, "shell32.dll", 1)
IL_Add(ImageListID, "shell32.dll", 2)
IL_Add(ImageListID, EXEIconS[1], EXEIconS[2])
IL_Add(ImageListID, FolderIconS[1], FolderIconS[2])
IL_Add(ImageListID, LNKIconS[1], LNKIconS[2])
IL_Add(ImageListID, TreeIconS[1], TreeIconS[2])
IL_Add(ImageListID, UrlIconS[1], UrlIconS[2])
;#菜单加载完后，预读完成"修改菜单"的GUI图标
Loop, parse, iniVar1, `n, `r
{
	Z_ReadLine=%A_LoopField%
	Set_Icon(Z_ReadLine,false)
}
if(menu2){
	Loop, parse, iniVar2, `n, `r
	{
		Z_ReadLine=%A_LoopField%
		Set_Icon(Z_ReadLine,false)
	}
}
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
				appName:=RegExReplace(menuDiy[2],"iS)\.exe$")
				if(MenuObj[appName]){
					MenuObj[menuDiy[1]]:=MenuObj[appName]
				}else{
					MenuObj[menuDiy[1]]:=menuDiy[2]
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
					Menu_Add(menuRoot[menuLevel],menuDiy[1],fast,menuRoot,menuWebRoot,menuWebList,webRootShow)
				}
			}else if(RegExMatch(Z_ReadLine,"iS)^(\\\\|.:\\).*?\.exe$")){
				;~;[生成完全路径的应用]
				SplitPath,Z_ReadLine,fileName,,,nameNotExt
				MenuObj[nameNotExt]:=Z_ReadLine
				if(fast){
					Menu_Add_Fast(menuRoot[menuLevel],nameNotExt)
				}else{
					Menu_Add(menuRoot[menuLevel],nameNotExt,fast,menuRoot,menuWebRoot,menuWebList,webRootShow)
				}
			}else{
				;~;[生成已取到的应用]
				appName:=RegExReplace(Z_ReadLine,"iS)\.exe$")
				if(!MenuObj[appName])
					MenuObj[appName]:=Z_ReadLine
				if(fast){
					Menu_Add_Fast(menuRoot[menuLevel],appName)
				}else{
					Menu_Add(menuRoot[menuLevel],appName,fast,menuRoot,menuWebRoot,menuWebList,webRootShow)
				}
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
Menu_Add(menuName,menuItem,fast,menuRoot,menuWebRoot,menuWebList,webRootShow){
	if not menuName
		return
	try {
		item:=MenuObj[(menuItem)]
		itemLen:=StrLen(item)
		SplitPath, item,,, FileExt  ; 获取文件扩展名.
		if(HideUnSelect)
			Menu,%menuName%,add,%menuItem%,Menu_Run
		if(InStr(item,";",,0,1)=itemLen){  ; {短语}
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
		if(InStr(item,"\",,0,1)=itemLen){  ; {目录}
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
		}else if FileExt in EXE,ICO,ANI,CUR
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
	Menu,Tray,Icon,启动菜单(&Z),% TreeIconS[1],% TreeIconS[2]
	Menu,Tray,Icon,修改菜单(&E),% EXEIconS[1],% EXEIconS[2]
	Menu,Tray,Icon,修改文件(&F),SHELL32.dll,134
	If(MENU2FLAG){
		Menu,Tray,Icon,修改菜单2(&W),% EXEIconS[1],% EXEIconS[2]
		Menu,Tray,Icon,修改文件2(&G),SHELL32.dll,134
	}
	Menu,Tray,Icon,设置RunAny(&D),% AnyIconS[1],% AnyIconS[2]
	Menu,Tray,Icon,关于RunAny(&A)...,% MenuIconS[1],% MenuIconS[2]
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
;══════════════════════════════════════════════════════════════════
Menu_Edit:
	global TVFlag:=false
	;~;[功能菜单初始化]
	treeRoot:=Object()
	global moveRoot:=Object()
	moveRoot[1]:="moveMenu" . both
	Menu,% moveRoot[1],add
	global moveLevel:=0
	global exeIconNum:=7
	;~;[树型菜单初始化]
	Gui, Destroy
	Gui, +Resize
	Gui, Font,, Microsoft YaHei
	Gui, Add, TreeView,vRunAnyTV w450 r30 -Readonly AltSubmit Checked hwndHTV gTVClick ImageList%ImageListID%
	Gui, Add, Progress,vMyProgress w450 cBlue
	GuiControl, Hide, MyProgress
	GuiControl, -Redraw, RunAnyTV
	;~;[读取菜单配置内容写入树形菜单]
	Loop, parse, iniFileVar, `n, `r
	{
		Z_ReadLine=%A_LoopField%
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
			TV_Add(Z_ReadLine,treeRoot[treeLevel],Set_Icon(Z_ReadLine,false))
		}
	}
	GuiControl, +Redraw, RunAnyTV
	try{
		Menu,TVMenu,Delete
	}catch{}
	TVMenu("TVMenu")
	TVMenu("GuiMenu")
	Gui, Menu, GuiMenu
	Gui, Show, , %RunAnyZz%菜单树管理(%both%)(右键操作)
return
Menu_Edit1:
	both:=1
	iniFile:=iniPath
	iniFileVar:=iniVar1
	gosub,Menu_Edit
return
Menu_Edit2:
	both:=2
	iniFile:=iniPath2
	iniFileVar:=iniVar2
	gosub,Menu_Edit
return
#If WinActive(RunAnyZz "菜单树管理(" both ")(右键操作)")
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
	~F2::TVFlag:=true
	Tab::Send_Zz(A_Tab)
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
	Menu, %addMenu%, Add,快捷键菜单管理, TVKey
	Menu, %addMenu%, Icon,快捷键菜单管理, SHELL32.dll,40
}
;~;[后缀判断图标Gui]
Set_Icon(itemVar,editVar=true){
	SplitPath, itemVar,,, FileExt  ; 获取文件扩展名.
	itemLen:=StrLen(itemVar)
	if(RegExMatch(itemVar,"S)^-+[^-]+.*"))
		return "Icon6"
	if(RegExMatch(itemVar,"S)^-+"))
		return "Icon1"
	if(InStr(itemVar,";")=1 || itemVar="")
		return "Icon2"
	if(InStr(itemVar,"\",,0,1)=itemLen)
		return "Icon4"
	;~;[获取全路径]
	FileName:=Get_Obj_Path(itemVar)
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
    ;~ SplitPath, FileName, , , FileExt  ; 获取文件扩展名.
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
    }
    if not IconNumber  ; 此扩展名还没有相应的图标, 所以进行加载.
    {
		; 获取与此文件扩展名关联的高质量小图标:
		if not DllCall("Shell32\SHGetFileInfo" . (A_IsUnicode ? "W":"A"), "str", FileName
            , "uint", 0, "ptr", &sfi, "uint", sfi_size, "uint", 0x101)  ; 0x101 为 SHGFI_ICON+SHGFI_SMALLICON
		{
			IconNumber = 3  ; 显示默认应用图标.
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
	MsgBox, 35, 菜单树保存, 是：保存后重启生效`n否：刷新后继续修改`n取消：取消保存
	IfMsgBox Yes
	{
		gosub,Menu_Save
		Reload
	}
	IfMsgBox No
	{
		gosub,Menu_Save
		gosub,Menu_Edit
	}
return
TvKey:
	Gui,33:Destroy
	Gui,33:Margin,30,20
	Gui,33:Add,GroupBox,xm-10 y+5 w200 h55,快捷键打开%RunAnyZz%菜单树管理(1)
	Gui,33:Add,Hotkey,xm+10 yp+25 w120 vvTreeKey1,%TreeKey1%
	Gui,33:Add,Checkbox,Checked%TreeWinKey1% xm+140 yp+5 vvTreeWinKey1,Win
	If(MENU2FLAG){
		Gui,33:Add,GroupBox,xm-10 y+20 w200 h55,快捷键打开%RunAnyZz%菜单树管理(2)
		Gui,33:Add,Hotkey,xm+10 yp+25 w120 vvTreeKey2,%TreeKey2%
		Gui,33:Add,Checkbox,Checked%TreeWinKey2% xm+140 yp+5 vvTreeWinKey2,Win
	}
	Gui,33:Add,Button,Default xm+16 y+20 w75 GSetTreeOK,确定(&Y)
	Gui,33:Add,Button,x+5 w75 GSetCancel,取消(&C)
	Gui,33:Show,,%RunAnyZz%快捷键打开修改菜单
return
SetTreeOK:
	Gui,Submit
	global vIniConfig:=IniConfig
	Reg_Set(vTreeKey1,TreeKey1,"TreeKey1")
	Reg_Set(vTreeWinKey1,TreeWinKey1,"TreeWinKey1")
	Reg_Set(vTreeKey2,TreeKey2,"TreeKey2")
	Reg_Set(vTreeWinKey2,TreeWinKey2,"TreeWinKey2")
	MsgBox,65,,设置成功，是否要重新打开RunAny生效？
	IfMsgBox Ok
		Reload
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
				selTextList.Insert(ItemText)
				DelListID.Insert(ItemID)
			}
			ItemID:=moveID
			Loop
			{
				ItemID := TV_GetNext(ItemID, "Full")
				if(ItemID=moveNextID)	; 如果遍历到树末节点则跳出
					break
				TV_GetText(ItemText, ItemID)
				moveTextList.Insert(ItemText)
				DelListID.Insert(ItemID)
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
	Menu,% moveRoot[moveLevel],add,%moveItem%, :%moveMenuName%
	try Menu,% moveRoot[moveLevel],Icon,%moveItem%,% TreeIconS[1],% TreeIconS[2]
	moveLevel+=1
	moveRoot[moveLevel]:=moveMenuName
}
TV_MoveMenuClean(){
	;[清空功能菜单]
	Menu,TVMenu,Delete
	Menu,GuiMenu,Delete
	Menu,moveMenu%both%,DeleteAll
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
;~;[设置选项]
Menu_Set:
	Gui,66:Destroy
	Gui,66:Font,,Microsoft YaHei
	Gui,66:Margin,30,20
	Gui,66:Add,Tab,x10 y10 w420 h420,RunAny设置|Everything设置|一键搜索|图标+TC设置
	Gui,66:Tab,RunAny设置,,Exact
	Gui,66:Add,GroupBox,xm-10 y+5 w400 h50,RunAny设置
	Gui,66:Add,Checkbox,Checked%AutoRun% xm yp+25 vvAutoRun,开机自动启动
	Gui,66:Add,Checkbox,Checked%IniConfig% x+18 vvIniConfig,RunAnyConfig.ini移动盘绿色配置
	Gui,66:Add,GroupBox,xm-10 y+10 w400 h65,RunAny应用菜单
	Gui,66:Add,Checkbox,Checked%HideFail% xm yp+20 vvHideFail,隐藏失效项
	Gui,66:Add,Checkbox,Checked%HideRecent% x+30 vvHideRecent,隐藏最近运行
	Gui,66:Add,Checkbox,Checked%HideWeb% xm yp+20 vvHideWeb,隐藏网址
	Gui,66:Add,Checkbox,Checked%HideSend% x+42 vvHideSend,隐藏短语(仅选中后显示)
	Gui,66:Add,GroupBox,xm-10 y+10 w400 h65,RunAny选中文字菜单
	Gui,66:Add,Checkbox,Checked%OneKeyWeb% xm yp+20 vvOneKeyWeb,网址一键打开
	Gui,66:Add,Checkbox,Checked%OneKeyFolder% x+18 vvOneKeyFolder,文件夹路径一键打开
	Gui,66:Add,Checkbox,Checked%OneKeyFile% xm yp+20 vvOneKeyFile,文件路径一键
	Gui,66:Add,Checkbox,Checked%HideUnSelect% x+18 vvHideUnSelect gUnCheckWebSend,显示应用菜单
	Gui,66:Add,GroupBox,xm-10 y+10 w195 h55,RunAny菜单自定义热键
	Gui,66:Add,Hotkey,xm yp+20 w130 vvMenuKey,%MenuKey%
	Gui,66:Add,Checkbox,Checked%MenuWinKey% xm+135 yp+3 vvMenuWinKey,Win
	If(MENU2FLAG){
		Gui,66:Add,GroupBox,x+15 yp-23 w195 h55,菜单2自定义热键
		Gui,66:Add,Hotkey,xp+10 yp+20 w130 vvMenuKey2,%MenuKey2%
		Gui,66:Add,Checkbox,Checked%MenuWinKey2% xp+135 yp+3 vvMenuWinKey2,Win
	}else{
		Gui,66:Add,Button,x+15 yp-5 w150 GSetMenu2,开启第2个菜单
	}
	Gui,66:Add,GroupBox,xm-10 y+20 w400 h100,屏蔽RunAny程序列表（逗号分隔）
	Gui,66:Add,Edit,xm yp+25 w380 r3 vvDisableApp,%DisableApp%
	
	Gui,66:Tab,Everything设置,,Exact
	Gui,66:Add,GroupBox,xm-10 y+20 w400 h55,一键Everything [搜索选中文字、激活、隐藏]
	Gui,66:Add,Hotkey,xm+10 yp+20 w130 vvEvKey,%EvKey%
	Gui,66:Add,Checkbox,Checked%EvWinKey% xm+150 yp+3 vvEvWinKey,Win
	Gui,66:Add,GroupBox,xm-10 y+20 w400 h100,Everything安装路径（支持相对路径..\为RunAny相对上级目录）
	Gui,66:Add,Button,xm yp+30 w50 GSetEvPath,选择
	Gui,66:Add,Edit,xm+60 yp w320 r3 vvEvPath,%EvPath%
	Gui,66:Add,GroupBox,xm-10 y+20 w400 h140,Everything搜索参数（搜索结果程序可无路径用RunAny运行）
	Gui,66:Add,Button,xm yp+20 w50 GSetEvCommand,修改
	Gui,66:Add,Text,xm+60 yp,!C:\*Windows*为排除系统缓存和系统程序
	Gui,66:Add,Text,xm+60 yp+15,file:*.exe|*.lnk|后面以此格式类推增加后缀
	Gui,66:Add,Edit,ReadOnly xm+10 yp+25 w370 r3 vvEvCommand,%EvCommand%
	
	Gui,66:Tab,一键搜索,,Exact
	Gui,66:Add,GroupBox,xm-10 y+20 w400 h260,一键搜索选中文字
	Gui,66:Add,Hotkey,xm yp+30 w130 vvOneKey,%OneKey%
	Gui,66:Add,Checkbox,Checked%OneWinKey% xm+135 yp+3 vvOneWinKey,Win
	Gui,66:Add,Checkbox,Checked%OneKeyMenu% x+18 vvOneKeyMenu,绑定菜单1为一键搜索
	Gui,66:Add,Text,xm yp+40 w325,一键搜索网址(`%s为选中文字的替代参数，多行搜索多个网址)
	Gui,66:Add,Edit,xm yp+20 w385 r8 vvOnePath,%OnePath%
	
	Gui,66:Tab,图标+TC设置,,Exact
	Gui,66:Add,GroupBox,xm-10 y+10 w400 h220,图标自定义设置（文件路径,序号）
	Gui,66:Add,Text,xm yp+30 w80,树节点图标
	Gui,66:Add,Edit,xm+70 yp w310 r1 vvTreeIcon,%TreeIcon%
	Gui,66:Add,Text,xm yp+30 w80,文件夹图标
	Gui,66:Add,Edit,xm+70 yp w310 r1 vvFolderIcon,%FolderIcon%
	Gui,66:Add,Text,xm yp+30 w80,网址图标
	Gui,66:Add,Edit,xm+70 yp w310 r1 vvUrlIcon,%UrlIcon%
	Gui,66:Add,Text,xm yp+30 w80,EXE图标
	Gui,66:Add,Edit,xm+70 yp w310 r1 vvEXEIcon,%EXEIcon%
	Gui,66:Add,Text,xm yp+30 w80,准备图标
	Gui,66:Add,Edit,xm+70 yp w310 r1 vvMenuIcon,%MenuIcon%
	Gui,66:Add,Text,xm yp+30 w80,托盘图标
	Gui,66:Add,Edit,xm+70 yp w310 r1 vvAnyIcon,%AnyIcon%
	Gui,66:Add,GroupBox,xm-10 y+25 w400 h90,TotalCommander安装路径（TC打开RunAny中的文件夹）
	Gui,66:Add,Button,xm yp+20 w50 GSetTcPath,选择
	Gui,66:Add,Edit,xm+60 yp w320 r3 vvTcPath,%TcPath%
	
	Gui,66:Tab
	Gui,66:Add,Button,Default xm y+35 w75 GSetOK,确定(&Y)
	Gui,66:Add,Button,x+5 w75 GSetCancel,取消(&C)
	Gui,66:Add,Button,x+5 w75 GSetReSet,重置
	Gui,66:Show,,%RunAnyZz%设置
	return
;~;[关于]
Menu_About:
	Gui,99:Destroy
	Gui,99:Margin,20,20
	Gui,99:Font,Bold,Microsoft YaHei
	Gui,99:Add,Text,y+10, 【%RunAnyZz%】一劳永逸的快速启动工具 v4.8 @2017.11.06 不同后缀不同菜单
	Gui,99:Font
	Gui,99:Add,Text,y+10, 默认启动菜单热键为``(Esc键下方的重音符键)
	Gui,99:Add,Text,y+10, 右键任务栏RunAny图标自定义菜单、热键、图标等配置
	Gui,99:Add,Text,y+10
	Gui,99:Font,,Consolas
	Gui,99:Add,Text,y+10, by Zz 建议：hui0.0713@gmail.com
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
	GuiControl,, vEvPath, %evFilePath%
return
SetTcPath:
	FileSelectFile, tcFilePath, 3, , TC安装路径, (Totalcmd.exe;Totalcmd64.exe)
	GuiControl,, vTcPath, %tcFilePath%
return
SetEvCommand:
	MsgBox,Everything搜索参数语法请打开Everything参照`nEverything-帮助(H)-搜索语法`n`n编辑参数完后请务必复制参数到Everthing搜索`n检验是否达到预定效果，以免出现错误
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
	global vIniConfig
	if(vIniConfig || FileExist(RunAnyConfig)){
		IniWrite,%vIniConfig%,%RunAnyConfig%,Config,IniConfig
	}
	Reg_Set(vDisableApp,DisableApp,"DisableApp")
	Reg_Set(vHideFail,HideFail,"HideFail")
	Reg_Set(vHideUnSelect,HideUnSelect,"HideUnSelect")
	Reg_Set(vHideRecent,HideRecent,"HideRecent")
	Reg_Set(vHideWeb,HideWeb,"HideWeb")
	Reg_Set(vHideSend,HideSend,"HideSend")
	Reg_Set(vMenuKey,MenuKey,"MenuKey")
	Reg_Set(vMenuWinKey,MenuWinKey,"MenuWinKey")
	Reg_Set(vMenuKey2,MenuKey2,"MenuKey2")
	Reg_Set(vMenuWinKey2,MenuWinKey2,"MenuWinKey2")
	Reg_Set(vEvKey,EvKey,"EvKey")
	Reg_Set(vEvWinKey,EvWinKey,"EvWinKey")
	Reg_Set(vEvPath,EvPath,"EvPath")
	Reg_Set(vEvCommand,EvCommand,"EvCommand")
	Reg_Set(vOneKey,OneKey,"OneKey")
	Reg_Set(vOneWinKey,OneWinKey,"OneWinKey")
	Reg_Set(vOnePath,OnePath,"OnePath")
	Reg_Set(vOneKeyWeb,OneKeyWeb,"OneKeyWeb")
	Reg_Set(vOneKeyFolder,OneKeyFolder,"OneKeyFolder")
	Reg_Set(vOneKeyFile,OneKeyFile,"OneKeyFile")
	Reg_Set(vOneKeyMenu,OneKeyMenu,"OneKeyMenu")
	Reg_Set(vTcPath,TcPath,"TcPath")
	Reg_Set(vTreeIcon,TreeIcon,"TreeIcon")
	Reg_Set(vFolderIcon,FolderIcon,"FolderIcon")
	Reg_Set(vUrlIcon,UrlIcon,"UrlIcon")
	Reg_Set(vEXEIcon,EXEIcon,"EXEIcon")
	Reg_Set(vAnyIcon,AnyIcon,"AnyIcon")
	Reg_Set(vMenuIcon,MenuIcon,"MenuIcon")
	Reg_Set(TreeKey1,"","TreeKey1")
	Reg_Set(TreeWinKey1,0,"TreeWinKey1")
	Reg_Set(TreeKey2,"","TreeKey2")
	Reg_Set(TreeWinKey2,0,"TreeWinKey2")
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
setMenu2:
	MsgBox,33,开启第2个菜单,确定开启第2个菜单吗？
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
	if(vIniConfig){
		IniWrite,%vGui%,%RunAnyConfig%,Config,%sz%
	}else{
		if(vGui!=var){
			RegWrite, REG_SZ, HKEY_CURRENT_USER, SOFTWARE\RunAny, %sz%, %vGui%
		}
	}
}
;══════════════════════════════════════════════════════════════════
;~;[托盘菜单]
MenuTray(){
	Menu,Tray,NoStandard
	Menu,Tray,Icon,% MenuIconS[1],% MenuIconS[2]
	Menu,Tray,add,启动菜单(&Z),Menu_Show
	Menu,Tray,add,修改菜单(&E),Menu_Edit1
	Menu,Tray,add,修改文件(&F),Menu_Ini
	Menu,Tray,add
	Menu,Tray,add,设置RunAny(&D),Menu_Set
	Menu,Tray,Add,关于RunAny(&A)...,Menu_About
	Menu,Tray,add
	If(MENU2FLAG){
		Menu,Tray,add,启动菜单2(&2),Menu_Show2
		Menu,Tray,add,修改菜单2(&W),Menu_Edit2
		Menu,Tray,add,修改文件2(&G),Menu_Ini2
		Menu,Tray,add
	}
	Menu,Tray,add,重启(&R),Menu_Reload
	Menu,Tray,add,挂起(&S),Menu_Suspend
	Menu,Tray,add,退出(&X),Menu_Exit
	Menu,Tray,Default,启动菜单(&Z)
	Menu,Tray,Click,1
}
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
