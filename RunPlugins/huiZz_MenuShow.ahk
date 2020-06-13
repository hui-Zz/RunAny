/*
【系统全局右键菜单透明】
*/
global RunAny_Plugins_Version:="1.0.0"
#NoEnv                  ;~不检查空变量为环境变量
#NoTrayIcon             ;~不显示托盘图标
#SingleInstance,Force   ;~运行替换旧实例
SetBatchLines,-1        ;~脚本全速执行(默认10ms)
DetectHiddenWindows, On

;（0-255）0全透明-255完全不透明程度
透明度:=225

;循环等待菜单显示
loop
{
	WinSet,Transparent,%透明度%,ahk_class #32768
} Until % WinActive("ahk_class #32768")
