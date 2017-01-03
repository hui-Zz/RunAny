/*
╔═════════════════════════════════
║【RunMenuZz】超轻便自由的快速启动应用工具 v1.6
║ 联系：hui0.0713@gmail.com
║ 讨论QQ群：3222783、271105729、493194474
║ by Zz @2016.12.29
╚═════════════════════════════════
*/
#Persistent			;~让脚本持久运行
#NoEnv					;~不检查空变量为环境变量
#SingleInstance,Force	;~运行替换旧实例
ListLines,Off			;~不显示最近执行的脚本行
SetBatchLines,-1		;~脚本全速执行(默认10ms)
SetControlDelay,0		;~控件修改命令自动延时(默认20)
SetWorkingDir,%A_ScriptDir%	;~脚本当前工作目录
SplitPath,A_ScriptFullPath,,,,fileNotExt
Menu,Tray,Icon,RunMenuZz.ico

iniFile:=fileNotExt ".ini"
IfNotExist,%iniFile%
	gosub,iniFileWrite
gosub,MenuTray

SetTimer,CountTime,1000 ;1秒
global MenuObj:=Object()
menuRoot:=Object()
menuRoot.Insert("AppMenu")
menuLevel:=1

;~;[设定自定义显示菜单热键]
IniRead,menuKey,%iniFile%,key
try{
	Hotkey,%menuKey%,MenuShow,On
}catch{
	MsgBox,1,,[key]`n%menuKey%`t<—热键语法不正确`n`n`n详细请参照AutoHotkey按键列表，需要打开吗？
	IfMsgBox OK
		Run,http://ahkcn.sourceforge.net/docs/KeyList.htm
	return
}

;~;[读取软件安装目录下所有exe]
IniRead,appPath,%iniFile%,appPath
Loop,parse,appPath,`n
{
	IfExist,%A_LoopField%
	{
		Loop,%A_LoopField%\*.exe,0,1
		{
			;~ fileName:=RegExReplace(A_LoopFileName,"iS)\.exe$","")
			MenuObj[(A_LoopFileName)]:=A_LoopFileLongPath
		}
	}else{
		TrayTip,,路径不对： %A_LoopField%,3,1
	}
}

;~;[读取自定义树形菜单设置]
Loop, read, RunMenu.ini
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
	}else if(RegExMatch(Z_ReadLine,"iS)^(\\\\|.:\\).*?\.exe$")){
		;~ ;[生成完全路径的应用]
		SplitPath,Z_ReadLine,fileName,,,nameNotExt
		MenuObj[nameNotExt]:=Z_ReadLine
		Menu_Add(menuRoot[menuLevel],nameNotExt)
	}else{
		;[生成所有的应用菜单项]
		menuDiy:=StrSplit(Z_ReadLine,"|")
		if(!RegExMatch(menuDiy[1],"iS)\.exe$"))
			menuDiy[1].=".exe"
		if(menuDiy[2]){
			if(MenuObj[menuDiy[2]]){
				MenuObj[menuDiy[1]]:=MenuObj[menuDiy[2]]
			}else{
				MenuObj[menuDiy[1]]:=menuDiy[2]
			}
		}
		Menu_Add(menuRoot[menuLevel],menuDiy[1])
	}
}

if(ini){
	TrayTip,,RunMenuZz菜单初始化完成,3,1
	Run,%iniFile%
}
ToolTip
ToolTip,,,,2
mTime:=0
SetTimer,CountTime,Off
ini=true
return

;~;[生成菜单]
Menu_Add(menuName,menuItem){
	try {
		item:=MenuObj[(menuItem)]
		menuItem:=RegExReplace(menuItem,"iS)\.exe$")
		Menu,%menuName%,add,%menuItem%,MenuRun
		ToolTip,%item%,A_ScreenWidth-200,A_ScreenHeight-200,2
		if(RegExMatch(item,"iS)\.lnk$")){
			FileGetShortcut,% item,LnkEXE
			MsgBox,% LnkEXE
			Menu,%menuName%,Icon,%menuItem%,%LnkEXE%,0
		}else if(RegExMatch(item,"iS)\.ahk$")){
			Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,74
		}else if(RegExMatch(item,"iS)\.(bat|cmd)$")){
			Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,73
		;~ }else if(RegExMatch(item,"S)\b(([\w-]+://?|www[.])[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|/)))")){
			;~ Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,44
		}else{
			Menu,%menuName%,Icon,%menuItem%,% item,0
		}
	} catch e {
		Menu,%menuName%,Icon,%menuItem%,SHELL32.dll,124
	}
}
CountTime:
	global mTime
	mTime+=1
	if mTime>2
		ToolTip,%mTime%,A_ScreenWidth-60,A_ScreenHeight
	return
;~;[显示菜单]
MenuShow:
	if(mTime=0 || mTime>1){
		try{
			Menu,% menuRoot[1],Show
		}catch{
			MsgBox,菜单显示错误，请检查%iniFile%中[menuName]下面的菜单配置
		}
	}
	return
;~;[菜单运行]
MenuRun:
	try {
		Run,% MenuObj[(A_ThisMenuItem ".exe")]
	} catch e {
		MsgBox,% "运行路径不正确：" MenuObj[(A_ThisMenuItem ".exe")]
	}
	return

;~;[托盘菜单]
MenuTray:
	Menu,Tray,NoStandard
	Menu,Tray,add,菜单(&Z),MenuShow
	Menu,Tray,add,重启(&R),Menu_Reload
	Menu,Tray,add
	Menu,Tray,add,挂起(&S),Menu_Suspend
	Menu,Tray,add,暂停(&A),Menu_Pause
	Menu,Tray,add,退出(&X),Menu_Exit
	Menu,Tray,Default,菜单(&Z)
	Menu,Tray,Click,1
return
Menu_Reload:
	Reload
return
Menu_Suspend:
	Menu,tray,ToggleCheck,挂起(&S)
	Suspend
return
Menu_Pause:
	Menu,tray,ToggleCheck,暂停(&A)
	Pause
return
Menu_Exit:
	ExitApp
return
;~;[配置生成]
iniFileWrite:
	ini:=true
	FileAppend,% ";【RunMenuZz】超轻便自由的快速启动应用工具 v1.6`n;联系：hui0.0713@gmail.com 讨论QQ群：3222783、271105729、493194474`n;by Zz @2016.11.06`n;初次使用请先按一下F1显示菜单`n",%iniFile%
	FileAppend,% "[key]`nF1`n;【自定义显示菜单热键】参照AutoHotkey按键列表`n;单键如:【``】【F1】【LWin】【RAlt】【AppsKey】`n;组合键如：左Alt+z:【<!z】左Win+z:【<#z】左Ctrl+``:【<^``】右Shift+/:【>+/】`n`n",%iniFile%
	FileAppend,% "[appPath]`n;【软件安装根目录】`n;已加入系统[运行]路径的目录无需添加,如：C:\Windows的应用`nC:\Program Files\`nC:\Program Files (x86)\`n`n[menuName]`n;【自定义树形启动菜单】`n;如果有多个同名应用，请加上全路径`n;目录前-为1级目录,--为2级以此类推,分隔符亦是如此`n`n;1.6版本开始移至RunMenu.ini文件中加快读取",%iniFile%
	FileAppend,% "cmd.exe`n-`n-app`n计算器|calc.exe`n--img`n  画图|mspaint.exe`n  ---`n  截图|SnippingTool.exe`n--sys`n  ---media`n     wmplayer.exe`n--佳软`n  StrokesPlus.exe`n  TC|Totalcmd64.exe`n  Everything.exe`n-edit`n  notepad.exe`n  写字板|wordpad.exe`n-`nIE(&E)|C:\Program Files\Internet Explorer\iexplore.exe`n-`n设置|Control.exe`n",%A_ScriptDir%\RunMenu.ini
return
