/*
【定时提醒休息时间】
*/
global RunAny_Plugins_Version:="1.1.0"
#NoEnv                  ;~不检查空变量为环境变量
#Persistent             ;~让脚本持久运行
#NoTrayIcon             ;~不显示托盘图标
#SingleInstance,Force   ;~运行替换旧实例
ListLines,Off           ;~不显示最近执行的脚本行
SetBatchLines,-1        ;~脚本全速执行(默认10ms)
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
SetTimer,Rest_Time,2700000	;45分钟
return
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
Rest_Time:
	CoordMode,ToolTip
	If(A_Hour=9){
		AskTime("早上好")
	}Else If(A_Hour=12){
		AskTime("中午午休……")
	}Else If(A_Hour=18){
		AskTime("下班了~")
	}Else If(A_Hour>=0 && A_Hour<=3){
		ToolTip,【明天可以睡懒觉吗？】,A_ScreenWidth/2-105,0
	}Else{
		; Speak("休息一下吧")
		; ToolTip,【起来走走`|休息眼睛`|注意喝水】,A_ScreenWidth/2-105,0
	}
	SetTimer,RemoveToolTip,30000
return
RemoveToolTip:
	SetTimer,RemoveToolTip,Off
	ToolTip
return

;~;[把定时提醒文本显示到屏幕上]
AskTime(ask){
	ToolTip,【%ask%!】,A_ScreenWidth/2-105,0
	Speak(ask)
}
;~;[使用系统自带语音播报提醒文字]
Speak(say){
	try{
		spovice:=ComObjCreate("sapi.spvoice")
		spovice.Speak(say)
	} catch e {
		TrayTip,,% "出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message,3,1
	}
}