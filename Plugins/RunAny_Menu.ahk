/*
【RunAny菜单透明插件】
* 1. 菜单自动透明
* 2. 菜单自动选中第一项
*/
global RunAny_Menu_version:="1.5.31"
#NoTrayIcon
#SingleInstance,Force
;等待RunAny菜单显示，最多等待3秒
WinWait, ahk_class #32768, , 3
if !ErrorLevel
{
	;【将菜单为变半透明，(0-255)表示(透明-不透明)】
	WinSet, Transparent, 225, ahk_class #32768
	;【自动选中第一项菜单】
;	SendInput,{Down}
}
ExitApp
