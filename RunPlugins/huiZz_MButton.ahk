;*****************************
;*【鼠标中键任意位置拖拽窗口】 *
;*    网页中键后台打开页面    *
;*    双击中键置顶窗口状态    *
;*             by hui-Zz     *
;*****************************
global RunAny_Plugins_Version:="1.06.26"
#NoEnv                  ;~不检查空变量为环境变量
#NoTrayIcon             ;~不显示托盘图标
#WinActivateForce       ;~强制激活窗口
#SingleInstance,Force   ;~运行替换旧实例
ListLines,Off           ;~不显示最近执行的脚本行
SendMode,Input          ;~使用更速度和可靠方式发送键鼠点击
SetBatchLines,-1        ;~脚本全速执行(默认10ms)
SetControlDelay,0       ;~控件修改命令自动延时(默认20)
SetTitleMatchMode,2     ;~窗口标题模糊匹配
CoordMode,Menu,Window   ;~坐标相对活动窗口
;**************************************************************************
GroupAdd,maxApp,ahk_exe vmware-vmx.exe
GroupAdd,maxApp,ahk_exe TeamViewer.exe
GroupAdd,maxApp,ahk_exe dota2.exe
GroupAdd,maxApp,ahk_exe League of Legends.exe
GroupAdd,browserApp,ahk_exe chrome.exe
GroupAdd,browserApp,ahk_exe QQBrowser.exe
#If !WinActive("ahk_group maxApp") ;特定最大化程序下屏蔽
	MButton:: ; 如不屏蔽中键原功能在前缀加~，但这样拖拽窗口时会实时激活
		CoordMode,Mouse ; 切换到屏幕绝对坐标
		MouseGetPos,Zz_MouseStartX,Zz_MouseStartY,Zz_MouseWin
		WinGet,winstat,MinMax,ahk_id %Zz_MouseWin%
		if(winstat<>1){
			WinGetPos,Zz_OldPosX,Zz_OldPosY,,,ahk_id %Zz_MouseWin%
			SetTimer,Zz_WatchMouse,10 ; 跟踪鼠标拖拽
		}else if(WinActive("ahk_group browserApp")){ ; 浏览器不最大化中键仍为拖拽
			SendInput,^{LButton} ; 【网页中键后台打开】(默认为浏览器最大化时)
		}
;		KeyWait,MButton,,t0.2 ; 双击判断，等待第二次按键
;		if(errorlevel<>1){
;			KeyWait,MButton,d,t0.1 ; 判断第二次按键是否是鼠标中键
;			if(errorlevel=0){
;				WinSet,AlwaysOnTop,Toggle,ahk_id %Zz_MouseWin% ; 【切换窗口置顶】
;			}
;		}
	return
	Zz_WatchMouse:
		GetKeyState,Zz_MButtonState,MButton,P
		if Zz_MButtonState=U ; 释放则完成
		{
			SetTimer,Zz_WatchMouse,off
			return
		}
		GetKeyState,Zz_EscapeState,Escape,P
		if Zz_EscapeState=D ; 按Esc则还原
		{
			SetTimer,Zz_WatchMouse,off
			WinMove,ahk_id %Zz_MouseWin%,,%Zz_OldPosX%,%Zz_OldPosY%
			return
		}
		; 【重新定位该窗口以匹配鼠标坐标的变化：】
		CoordMode,Mouse
		SetWinDelay,-1 ; 使得窗口移动无延迟
		MouseGetPos,Zz_MouseX,Zz_MouseY
		WinGetPos,Zz_WinX,Zz_WinY,,,ahk_id %Zz_MouseWin%
		WinMove,ahk_id %Zz_MouseWin%,,Zz_WinX+Zz_MouseX-Zz_MouseStartX,Zz_WinY+Zz_MouseY-Zz_MouseStartY
		; 更新坐标
		Zz_MouseStartX:=Zz_MouseX
		Zz_MouseStartY:=Zz_MouseY
	return
#If
