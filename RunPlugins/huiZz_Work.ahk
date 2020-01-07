;*************************
;* 【ObjReg工作相关脚本】 *
;*************************
global RunAny_Plugins_Version:="1.0.0"
#NoTrayIcon             ;~不显示托盘图标
#Persistent             ;~让脚本持久运行
#SingleInstance,Force   ;~运行替换旧实例
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
#Include %A_ScriptDir%\RunAny_ObjReg.ahk

class RunAnyObj {
	;[快捷一键发送邮件]
	;保存到RunAny.ini为：发送邮件|huiZz_Work[mailto](addressee,subject,body,cc,bcc)
	;选中文本发送邮件|huiZz_Work[mailto](收件人地址,邮件主题,%getZz%)
	;选中地址发送剪贴板内容邮件|huiZz_Work[mailto](%getZz%,邮件主题,%Clipboard%)
	;参数说明:
	; mailto：收件人地址，可多个用;分隔
	;     cc：抄送人地址，可多个用;分隔
	;    bcc：密件抄送人地址，可多个用;分隔
	;subject：邮件主题
	;   body：邮件内容
	mailto(addressee,subject,body,cc="",bcc=""){
		Run,mailto:%addressee%?cc=%cc%&bcc=%bcc%&subject=%subject%&body=%body%
	}
	;[老板键Win]最小化其他窗口，打开指定程序
	;保存到RunAny.ini为：老板键Win|huiZz_Work[boss_win](notepad.exe)
	;老板键Win无路径|huiZz_Work[boss_win](%"winword.exe"%)
	boss_win(program){
		SendInput,#d
		Sleep,100
		DetectHiddenWindows, Off
		if(!WinExist("ahk_exe" . program)){
			Run,%program%
		}else{
			WinActivate,ahk_exe %program%
		}
		return
	}
	
}

;独立使用方式
;F1::
	;RunAnyObj.你的函数名(参数1,参数2)
;return