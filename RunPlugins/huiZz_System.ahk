;**************************************
;* 【ObjReg系统操作脚本[系统函数.ini]】 *
;*                          by hui-Zz *
;**************************************
global RunAny_Plugins_Version:="1.0.8"
#NoTrayIcon             ;~不显示托盘图标
#Persistent             ;~让脚本持久运行
#WinActivateForce       ;~强制激活窗口
#SingleInstance,Force   ;~运行替换旧实例
ListLines,Off           ;~不显示最近执行的脚本行
SendMode,Input          ;~使用更速度和可靠方式发送键鼠点击
SetBatchLines,-1        ;~脚本全速执行(默认10ms)
SetControlDelay,0       ;~控件修改命令自动延时(默认20)
SetWinDelay,0           ;~执行窗口命令自动延时(默认100)
SetTitleMatchMode,2     ;~窗口标题模糊匹配
CoordMode,Menu,Window   ;~坐标相对活动窗口
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
#Include %A_ScriptDir%\RunAny_ObjReg.ahk

class RunAnyObj {
	;[显示系统隐藏文件]
	;参数说明：
	;hide：0-隐藏文件；1-显示隐藏文件
	;sys：0-隐藏系统文件；1-显示系统文件
	;ext：1-隐藏文件后缀；0-显示文件后缀
	;refresh：1-自动刷新生效；0-手动刷新
	system_hidefile_zz(hide=0,sys=0,ext=0,refresh=1){
		DetectHiddenWindows,On
		hideFileRegPath:="Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
		RegWrite,REG_DWORD,HKEY_CURRENT_USER,%hideFileRegPath%,Hidden,%hide%
		RegWrite,REG_DWORD,HKEY_CURRENT_USER,%hideFileRegPath%,HideFileExt,%ext%
		RegWrite,REG_DWORD,HKEY_CURRENT_USER,%hideFileRegPath%,ShowSuperHidden,%sys%
		if(refresh){
			if !WinActive("ahk_class Program Manager") && !WinActive("ahk_class Progman")
			{
				ComObjCreate("Shell.Application").ToggleDesktop
				Sleep,200
			}
			SendInput,{F5}
		}
	}
	;[定位注册表路径]
	;参数说明：getZz：选中的文本内容
	system_regedit_zz(getZz:=""){
		if(WinExist("ahk_exe regedit.exe")){
			ToolTip,注册表已打开`n要关闭情况下才能进行定位
			Sleep,3000
			ToolTip
			return
		}
		getZz:=StrReplace(getZz,"HKCU","HKEY_CURRENT_USER")
		getZz:=StrReplace(getZz,"HKLM","HKEY_LOCAL_MACHINE")
		shell:=ComObjCreate("WScript.Shell")
		strRegAddress:="计算机\" getZz
		shell.RegWrite("HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit\LastKey",strRegAddress)
		shell.Run("RegEdit.exe")
	}
	;[获取本地IP]
	;参数说明：output：1-输出IP；0-显示IP并复制到剪贴板
	system_ip_zz(output=0){
		ip:=this.cmdClipReturn("for /f ""tokens=4"" %a in ('route print^|findstr 0.0.0.0.*0.0.0.0') do echo %a",%output%)
		ip:=StrReplace(ip,"`r`n")
		ip:=StrReplace(ip," ")
		if(output){
			Clipboard:=ip
			SendInput,^v
		}else{
			ToolTip,%ip%
			Sleep,3000
			ToolTip
		}
	}
	;[ping选中地址]
	system_ping_zz(getZz:=""){
		Run,% ComSpec " /C ping " getZz " -t"
	}
	/*
	【隐藏运行cmd命令并将结果存入剪贴板后取回 @hui-Zz】
	*/
	cmdClipReturn(command,save=0){
		cmdInfo:=""
		if(save)
			Clip_Saved:=ClipboardAll
		try{
			Clipboard=
			Run,% ComSpec " /C " command " | CLIP", , Hide
			ClipWait,2
			cmdInfo:=Clipboard
		}catch{}
		if(save)
			Clipboard:=Clip_Saved
		return cmdInfo
	}
	;[重启桌面]
	system_explorer_zz(){
		DetectHiddenWindows, Off
		Process,Close,explorer.exe
		;~ WinWaitClose,ahk_exe explorer.exe
		;~ Run,explorer.exe
	}
	;[复制选中文件路径] v1.0.7
	;复制文件说明：path路径, name名称, dir目录, ext后缀, nameNoExt无后缀名称, drive盘符
	;复制快捷方式说明：lnkTarget指向路径, lnkDir指向目录, lnkArgs参数, lnkDesc注释, lnkIcon图标文件名, lnkIconNum图标编号, lnkRunState初始运行方式
	system_file_path_zz(path:="",copy:=""){
		textResult:=""
		Loop, parse, path, `n, `r, %A_Space%%A_Tab%
		{
			if(!A_LoopField)
				continue
			SplitPath, A_LoopField, name, dir, ext, nameNoExt, drive
			if(ext="lnk")
				FileGetShortcut, %A_LoopField%, lnkTarget, lnkDir, lnkArgs, lnkDesc, lnkIcon, lnkIconNum, lnkRunState
			textResult.=(copy="path") ? A_LoopField "`n" : %copy% "`n"
		}
		Clipboard:=Trim(textResult, ",`n ")
	}
	;[创建目标快捷方式]
	;参数说明：getZz：选中的文件路径
	;target：需要发送的目标路径,默认当前目录
	;lnk：快捷方式名,默认是选中文件名
	system_create_shortcut(getZz,target:="",lnk:=""){
		SplitPath, getZz, name, dir, ext, nameNoExt
		if(target="")
			target:=dir
		if(lnk="")
			lnk:=nameNoExt ".lnk"
		FileCreateShortcut, %getZz%, %target%\%lnk%
	}
	;[控制系统音量增减] v1.0.5
	;参数说明：
	;flag：0-减少音量；1-增加音量；2-固定音量
	;amount：音量调整比例0-100%
	system_sound_volume(flag = 1,amount = 10){
		if(flag=0){
			SoundSet, -%amount%
		}else if(flag=1){
			SoundSet, +%amount%
		}else if(flag=2){
			SoundSet, %amount%
		}
	}
	;[管理员权限运行选中目标]
	;注：仅限于右键可以用管理员身份运行的后缀文件
	system_runas_zz(getZz:=""){
		Run *RunAs "%getZz%"
	}
}

;独立使用方式
;~ F2::
	;~ RunAnyObj.system_ip_zz(0)
;~ return
