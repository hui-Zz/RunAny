/*
【RunAny菜单辅助插件】
*/
global RunAny_Plugins_Version:="2.0.0"
#NoEnv                  ;~不检查空变量为环境变量
#NoTrayIcon             ;~不显示托盘图标
#SingleInstance,Force   ;~运行替换旧实例
SetBatchLines,-1        ;~脚本全速执行(默认10ms)
DetectHiddenWindows, On

GroupAdd,menuApp,ahk_exe RunAny.exe
;GroupAdd,menuApp,ahk_exe AutoHotkey.exe

#If WinActive("ahk_group menuApp")

~RButton Up::
	WinWait ahk_class #32768,, 1
	if ErrorLevel
		return
	;判断如果RunAny菜单已显示，点击右键 = 模拟按住Shift键点击：快捷修改菜单项
	SendInput,{Shift Down}
	Click
	SendInput,{Shift Up}
return

~Space Up::
	WinWait ahk_class #32768,, 1
	if ErrorLevel
		return
	;判断如果RunAny菜单已显示，按空格键 = 模拟方向键下按2次后按回车：快捷运行
	SendInput,{Down 2}
	SendInput,{Enter}
return

#If