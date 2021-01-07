/*
【RunAny菜单辅助插件（建议自启）】
*/
global RunAny_Plugins_Version:="2.0.5"
#NoEnv                  ;~不检查空变量为环境变量
#NoTrayIcon             ;~不显示托盘图标
#Persistent             ;~让脚本持久运行
#SingleInstance,Force   ;~运行替换旧实例
ListLines,Off           ;~不显示最近执行的脚本行
SendMode,Input          ;~使用更速度和可靠方式发送键鼠点击
SetBatchLines,-1        ;~脚本全速执行(默认10ms)
DetectHiddenWindows, On

;[RunAny菜单透明化]
GroupAdd,menuApp,ahk_exe RunAny.exe
;[桌面右键菜单透明化]
GroupAdd,menuApp,ahk_exe explorer.exe
GroupAdd,menuApp,ahk_exe DesktopMgr64.exe

;GroupAdd,menuApp,ahk_exe AutoHotkey.exe  ;如果使用AHK运行RunAny 打开此注释

;（0-255）[0全透明-255完全不透明程度]
透明度:=Var_Read("RunAnyMenuTransparent",225)

;[想要关闭菜单透明化，可以注释掉下面这行定时器]
SetTimer,Transparent_Show,10

return

;循环等待菜单显示
Transparent_Show:
	if(WinActive("ahk_group menuApp") && A_TimeIdle<1000 && WinExist("ahk_class #32768")){
		WinSet,Transparent,%透明度%,ahk_class #32768
	}
return

#If WinActive("ahk_exe RunAny.exe") ;|| WinActive("ahk_exe AutoHotkey.exe")  ;如果使用AHK运行RunAny 打开此注释

~RButton Up::
	WinWait,ahk_class #32768,, 1
	if ErrorLevel
		return
	MenuClick(Var_Read("RunAnyMenuRButtonRun",3))
return

~Space Up::
	WinWait,ahk_class #32768,, 1
	if ErrorLevel
		return
	MenuClick(Var_Read("RunAnyMenuSpaceRun",2))
return

~MButton Up::
	WinWait,ahk_class #32768,, 1
	if ErrorLevel
		return
	MenuClick(Var_Read("RunAnyMenuMButtonRun",0))
return

~XButton1 Up::
	WinWait,ahk_class #32768,, 1
	if ErrorLevel
		return
	MenuClick(Var_Read("RunAnyMenuXButton1Run",0))
return

~XButton2 Up::
	WinWait,ahk_class #32768,, 1
	if ErrorLevel
		return
	MenuClick(Var_Read("RunAnyMenuXButton2Run",0))
return

#If

MenuClick(buttonRun){
	HoldKeyList:={"HoldEnterRun":1,"HoldCtrlRun":2,"HoldShiftRun":3,"HoldCtrlShiftRun":4,"HoldCtrlWinRun":5,"HoldShiftWinRun":6,"HoldCtrlShiftWinRun":7}
	for k, v in HoldKeyList
	{
		if(v<=3){
			j:=Var_Read(k,v)
		}else if (k="HoldCtrlShiftRun"){
			j:=Var_Read(k,11)
		}else if (k="HoldCtrlWinRun"){
			j:=Var_Read(k,5)
		}else if (k="HoldShiftWinRun"){
			j:=Var_Read(k,31)
		}else if (k="HoldCtrlShiftWinRun"){
			j:=Var_Read(k,4)
		}
		if(j=buttonRun){
			if(v=1){
				Click
			}else if(v=2){
				SendInput,{Ctrl Down}
				Click
				SendInput,{Ctrl Up}
			}else if(v=3){
				SendInput,{Shift Down}
				Click
				SendInput,{Shift Up}
			}else if(v=4){
				SendInput,{Ctrl Down}{Shift Down}
				Click
				SendInput,{Ctrl Up}{Shift Up}
			}else if(v=5){
				SendInput,{Ctrl Down}{LWin Down}
				Click
				SendInput,{Ctrl Up}{LWin Up}
			}else if(v=6){
				SendInput,{Shift Down}{LWin Down}
				Click
				SendInput,{Shift Up}{LWin Up}
			}else if(v=7){
				SendInput,{Ctrl Down}{Shift Down}{LWin Down}
				Click
				SendInput,{Ctrl Up}{Shift Up}{LWin Up}
			}
		}
	}
}
Var_Read(rValue,defVar=""){
	if(FileExist(A_ScriptDir "\..\RunAnyConfig.ini")){
		IniRead, regVar,%A_ScriptDir%\..\RunAnyConfig.ini, Config, %rValue%,% defVar ? defVar : A_Space
	}
	return regVar!="" ? regVar: defVar
}