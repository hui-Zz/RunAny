;****************************
;* 【RunCtrl公共规则函数库】 *
;****************************
global RunAny_Plugins_Version:="1.0.0"
#NoTrayIcon             ;~不显示托盘图标
#Persistent             ;~让脚本持久运行
#SingleInstance,Force   ;~运行替换旧实例
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
#Include %A_ScriptDir%\RunAny_ObjReg.ahk

class RunAnyObj {
	rule_true(){
		return true
	}
	rule_false(){
		return false
	}
	;电脑开机后的运行时长(秒)
	rule_boot_time(){
		return A_TickCount/1000
	}
	;当前电脑名称
	rule_computer_name(){
		return A_ComputerName
	}
	;当前登录用户名称
	rule_user_name(){
		return A_UserName
	}
	;当前windows系统版本：WIN_7, WIN_8, WIN_VISTA, WIN_2003, WIN_XP, WIN_2000, Windows10版本为具体的版本号数字
	rule_system_version(){
		return A_OSVersion
	}
	;当前操作系统为64位
	rule_system_is_64bit(){
		return A_Is64bitOS
	}
	/*
	验证当前内网ip地址
	ip 验证的ip（模糊匹配）
	*/
	rule_ip_internal(ip=""){
		if(!ip)
			return false
		cmdResult:=cmdClipReturn("for /f ""tokens=4"" %a in ('route print^|findstr 0.0.0.0.*0.0.0.0') do echo %a")
		return InStr(cmdResult,ip) ? true : false
	}
	/*
	【验证当前连接的Wifi名称】（后台静默）
	ssid wifi名称
	*/
	rule_wifi_silence(ssid){
		cmdResult:=cmdClipReturn("netsh wlan show interface | findstr ""`\<SSID""")
		return RegExMatch(cmdResult, "\s*SSID\s*:\s" . ssid . "$") ? true : false
	}
	/*
	【判断exe程序今天是否运行过】
	runName 启动项名称+后缀
	*/
	rule_run_today(runName){
		cmdResult:=cmdClipReturn("dir %windir%\Prefetch /b/a/o-d |findstr /i """ runName """")
		flist:=StrSplit(cmdResult,"`r`n")
		if(flist && flist[1]){
			lastRun:=% A_WinDir . "\Prefetch\" . flist[1]
			FileGetTime, lastRunTime, %lastRun%
		}
		if(lastRunTime){
			FormatTime, t1, %A_Now%, yyyyMMdd
			FormatTime, t2, %lastRunTime%, yyyyMMdd
			t1 -= %t2%, Days
			return !t1 ? true : false
		}else{
			return false
		}
	}
	/*
	【判断最近打开文件今天是否打开过】
	runName 启动项名称+后缀
	*/
	rule_run_today_file(runName){
		cmdResult:=cmdClipReturn("dir %appdata%\Microsoft\Windows\Recent /b/a/o-d |findstr /i """ runName """")
		flist:=StrSplit(cmdResult,"`r`n")
		if(flist && flist[1]){
			lastRun:=% A_AppData . "\Microsoft\Windows\Recent\" . flist[1] . ".lnk"
			FileGetTime, lastRunTime, %lastRun%
		}
		if(lastRunTime){
			FormatTime, t1, %A_Now%, yyyyMMdd
			FormatTime, t2, %lastRunTime%, yyyyMMdd
			t1 -= %t2%, Days
			return !t1 ? true : false
		}else{
			return false
		}
	}


;══════════════════════════大括号以上是RunAny菜单调用的函数══════════════════════════

}

;════════════════════════════以下是脚本自己调用依赖的函数════════════════════════════


/*
【隐藏运行cmd命令并将结果存入剪贴板后取回 @hui-Zz】
*/
cmdClipReturn(command){
	cmdInfo:=""
	Clip_Saved:=ClipboardAll
	try{
		Clipboard=
		Run,% ComSpec " /C " command " | CLIP", , Hide
		ClipWait,2
		cmdInfo:=Clipboard
	}catch{}
	Clipboard:=Clip_Saved
	return cmdInfo
}

;独立使用RunAnyObj菜单内函数方式
;F1::
	;RunAnyObj.你的函数名(参数1,参数2)
;return