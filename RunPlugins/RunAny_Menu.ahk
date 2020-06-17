/*
【RunAny菜单辅助插件】
*/
global RunAny_Plugins_Version:="2.0.2"
#NoEnv                  ;~不检查空变量为环境变量
#NoTrayIcon             ;~不显示托盘图标
#Persistent             ;~让脚本持久运行
#SingleInstance,Force   ;~运行替换旧实例
ListLines,Off           ;~不显示最近执行的脚本行
DetectHiddenWindows, On

;[RunAny菜单透明化]
GroupAdd,menuApp,ahk_exe RunAny.exe
;[桌面右键菜单透明化]
GroupAdd,menuApp,ahk_exe explorer.exe

;GroupAdd,menuApp,ahk_exe AutoHotkey.exe

;（0-255）[0全透明-255完全不透明程度]
透明度:=225

;[想要关闭菜单透明化，可以注释掉下面这行定时器]
SetTimer,Transparent_Show,10

return

;循环等待菜单显示
Transparent_Show:
	if(WinActive("ahk_group menuApp") && A_TimeIdle<1000 && WinExist("ahk_class #32768")){
		WinSet,Transparent,%透明度%,ahk_class #32768
	}
return

#If WinActive("ahk_group menuApp")

~RButton Up::
	if(!WinActive("ahk_exe RunAny.exe"))
		return
	WinWait,ahk_class #32768,, 1
	if ErrorLevel
		return
	;判断如果RunAny菜单已显示，点击右键 = 模拟按住Shift键点击：快捷修改菜单项
	SendInput,{Shift Down}
	Click
	SendInput,{Shift Up}
return

~Space Up::
	WinWait,ahk_class #32768,, 1
	if ErrorLevel
		return
	;判断如果RunAny菜单已显示，按空格键 = 模拟回车键(打开注释可以先方向键下按2次后回车)：快捷运行
	;SendInput,{Down 2}
	SendInput,{Enter}
return

#If