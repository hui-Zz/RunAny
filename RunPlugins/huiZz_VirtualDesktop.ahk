;***********************************
;*【在任务栏上滚动鼠标切换虚拟桌面】 
;*                      by hui-Zz  
;***********************************
global RunAny_Plugins_Version:="1.0.0"
#NoEnv                  ;~不检查空变量为环境变量
#NoTrayIcon             ;~不显示托盘图标
#SingleInstance,Force   ;~运行替换旧实例
ListLines,Off           ;~不显示最近执行的脚本行
SetBatchLines,-1        ;~脚本全速执行(默认10ms)
;**************************************************************************
#If MouseIsOver()
WheelUp::SendInput,^#{Left}
WheelDown::SendInput,^#{Right}

MouseIsOver() {
	GroupAdd,TrayWndUI,ahk_class Shell_TrayWnd
	GroupAdd,TrayWndUI,ahk_class Shell_SecondaryTrayWnd
    MouseGetPos,,, Win
    return WinExist("ahk_group TrayWndUI ahk_id " . Win)
}
#If