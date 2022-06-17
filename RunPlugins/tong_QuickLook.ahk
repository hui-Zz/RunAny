﻿;****************************
;* 【基于RA内部关联实现快速预览：空格打开，ESC关闭】 *
;****************************
global RunAny_Plugins_Version:="1.0.4"
global RunAny_Plugins_Icon:="shell32.dll,246"
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

Label_RA_Script: ;将工作目录设置为RA
	SplitPath, A_AhkPath, , RA_path
	SetWorkingDir, %RA_path%
	#Include %A_WorkingDir%\RunAny_ObjReg.ahk

Label_ScriptSetting: ;脚本前参数设置
	Process, Priority, , High						;脚本高优先级
	#NoTrayIcon 									;不显示托盘图标
	#Persistent										;让脚本持久运行(关闭或ExitApp)
	#SingleInstance,Force 							;运行替换旧实例
	#WinActivateForce								;强制激活窗口
	#MaxHotkeysPerInterval 200						;时间内按热键最大次数
	#HotkeyModifierTimeout 100						;按住modifier后(不用释放后再按一次)可隐藏多个当前激活窗口
	SetControlDelay -1								;控件修改命令自动延时,-1无延时，0最小延时
	CoordMode Menu Window							;坐标相对活动窗口
	CoordMode Mouse Screen							;鼠标坐标相对于桌面(整个屏幕)
	ListLines, Off									;不显示最近执行的脚本行
	SendMode Input									;更速度和可靠方式发送键盘点击
	SetTitleMatchMode 2								;窗口标题模糊匹配;RegEx正则匹配
	DetectHiddenWindows on							;显示隐藏窗口

Label_Custom: ;用户自定义资源管理器
	;添加资源管理器（需要生效的在此添加，不需要的注释或删除）
	GroupAdd, Explorer, ahk_class ExploreWClass		;win资源管理器（下面三个都是）
	GroupAdd, Explorer, ahk_class CabinetWClass
	GroupAdd, Explorer, ahk_class WorkerW
	GroupAdd, Explorer, ahk_exe Q-Dir_x64.exe 		;Q-Dir资源管理器
	GroupAdd, Explorer, ahk_exe Everything.exe 		;Everything资源管理器
	GroupAdd, Explorer, ahk_exe XYplorer.exe 		;XYplorer资源管理器
	GroupAdd, Explorer, ahk_exe dopus.exe 			;Directory Opus资源管理器
	GroupAdd, Explorer, ahk_exe TOTALCMD.EXE 		;TC资源管理器
	GroupAdd, Explorer, ahk_exe doublecmd.exe 		;DC资源管理器
	GroupAdd, Explorer, ahk_class _cls_desk_ 		;酷呆桌面
	GroupAdd, Explorer, ahk_exe DesktopMgr64.exe  	;腾讯桌面

	;获取选中文件信息最多等待1.5s的应用
	GroupAdd, ClipWaitGUI, ahk_exe TOTALCMD.EXE  	;TC资源管理器
	GroupAdd, ClipWaitGUI, ahk_exe TCMDX64.EXE  	;TC资源管理器64位
	GroupAdd, ClipWaitGUI, ahk_exe TCMDX32.EXE  	;TC资源管理器32位

Label_DefVar: ;初始化变量
	global SpaceExePidObj := Object()
	global openExtRunList := Object()
	global RunAEvFullPathIniDir

Label_ReadExtRunList: ;读取内部关联
	SplitPath, A_AhkPath, , RA_path
	IniRead, RunAEvFullPathIniDir, %RA_path%\RunAnyConfig.ini, Config, RunAEvFullPathIniDir, %A_Space%
	If (RunAEvFullPathIniDir="")
		RunAEvFullPathIniDir := A_AppData "\RunAny"
	Transform, RunAEvFullPathIniDir, Deref, % RunAEvFullPathIniDir
	IniRead, openExtVar, %RA_path%\RunAnyConfig.ini, OpenExt
	Loop, parse, openExtVar, `n, `r
	{
		INI_Open_Exe_Parm := ""
		itemList := StrSplit(A_LoopField,"=",,2)
		Transform, INI_Open_Exe, Deref, % itemList[1]
		INI_Open_Exe_Parm_Pos := InStr(INI_Open_Exe, ".exe ")
		If (INI_Open_Exe_Parm_Pos!=0){
			INI_Open_Exe_Parm := SubStr(INI_Open_Exe, INI_Open_Exe_Parm_Pos+5)
			INI_Open_Exe := SubStr(INI_Open_Exe, 1, INI_Open_Exe_Parm_Pos+3)
		}
		INI_Open_Exe := GetOpenExe(INI_Open_Exe)
		If (INI_Open_Exe!=""){
			Loop, parse,% itemList[2], %A_Space%
			{
				extLoopField:=RegExReplace(A_LoopField,"^\.","")
				If (INI_Open_Exe_Parm="")
					openExtRunList[extLoopField] := INI_Open_Exe
				Else
					openExtRunList[extLoopField] := INI_Open_Exe A_Space INI_Open_Exe_Parm
			}
		}	
	}
Return

;获取打开后缀的应用(无路径)
GetOpenExe(OpenExe){
	If !FileExist(OpenExe)
		IniRead, OpenExe, %RunAEvFullPathIniDir%\RunAnyEvFullPath.ini, FullPath, %OpenExe%, %OpenExe%
	Return OpenExe
}

;获取选中内容
Get_Zz(copyKey:="^c",extraHotKey:=""){
	global Candy_isFile
	global Candy_Select
	Candy_isFile:=0
	try Candy_Saved:=ClipboardAll
	Clipboard=
	if(GetZzCopyKey!="" && GetZzCopyKeyApp!="" && WinActive("ahk_group GetZzCopyKeyAppGUI"))
		copyKey:=GetZzCopyKey
	SendInput,%copyKey%
	SendInput,{Ctrl up}
	if WinActive("ahk_group ClipWaitGUI"){
		ClipWait,1.5
	}else{
		ClipWait,0.1
	}
	If(ErrorLevel){
		Clipboard:=Candy_Saved
		SendInput,{%extraHotKey%}
		return ""
	}
	Candy_isFile:=DllCall("IsClipboardFormatAvailable","UInt",15)
	If !Candy_isFile
		SendInput,{%extraHotKey%}
	CandySel=%Clipboard%
	Candy_Select=%ClipboardAll%
	Clipboard:=Candy_Saved
	return CandySel
}

;判断是否已激活已开启的程序pid
WinActiveSpaceExePid(){
	WinGet, PID, PID, A
	If SpaceExePidObj.HasKey(PID)
		return true
	else
		return false
}

;对于手动关闭的程序pid从SpaceExePidObj中去除
CheckSpaceExePid:
	If SpaceExePidObj.Length()=0 {
		SetTimer,CheckSpaceExePid,Off
		return
	}
	For SpaceExePidObj_K, SpaceExePidObj_V in SpaceExePidObj
	{
		If !WinExist("ahk_pid" SpaceExePidObj_K)
			SpaceExePidObj.Delete(SpaceExePidObj_K)
	}
Return

RunFile: ;内部关联程序运行选中文件
	selectFile:=RegExReplace(selectFile,"S)(.*)(\n|\r).*","$1")  ;取第一行
	SplitPath, selectFile,FileName,, FileExt  ; 获取文件扩展名.
	If (FileExt="lnk") {
		FileGetShortcut, %selectFile%, selectFile
		SplitPath, selectFile,FileName,, FileExt
	}Else If (FileExt=""){
		FileGetSize, FileSize, %selectFile%
		if FileSize=0
			FileExt := "folder"
		Else
			FileExt := "file"
	}
	selectFileOpenExe := openExtRunList[FileExt]
	try
		Run, %selectFileOpenExe% "%selectFile%",,,OutputVarPID
	Catch {
		try {
			Run, "%selectFile%", , , OutputVarPID
		}Catch {
			SendInput {Enter}
		}
	}
	SpaceExePidObj[OutputVarPID] := OutputVarPID ;保存已开启的程序pid
	SetTimer,CheckSpaceExePid,5000 ;对于手动关闭的程序pid从中去除
Return

;在资源管理器中生效
#if WinActive("ahk_group Explorer")
Space::
	ControlGetFocus, OutputVar, A
	If RegExMatch(OutputVar, "iS).*edit.*"){
		SendInput,{Space}
		Return
	}
	selectFile := Get_Zz(copyKey:="^c","Space")
	If (Candy_isFile)
		Gosub, RunFile
Return

;激活已开启的程序pid，则ESC关闭程序
#if WinActiveSpaceExePid()
Esc::
	WinGet, PID, PID, A
	WinClose,A
	Loop 5
	{
		If !WinExist("ahk_pid" PID)
			Break
		Sleep 100
	}
	If !WinExist("ahk_pid" PID)
		SpaceExePidObj.Delete(PID)
	If WinActive("ahk_exe Everything.exe")
		SendInput,{Tab}
Return
