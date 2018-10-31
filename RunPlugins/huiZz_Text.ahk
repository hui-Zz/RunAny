;********************************
;*    【ObjReg文本操作脚本】     *
;*                  by hui-Zz   *
;********************************
global RunAny_Plugins_Version:="1.0.0"
#NoEnv                  ;~不检查空变量为环境变量
#NoTrayIcon             ;~不显示托盘图标
#Persistent			 ;~让脚本持久运行
#WinActivateForce       ;~强制激活窗口
#SingleInstance,Force   ;~运行替换旧实例
ListLines,Off           ;~不显示最近执行的脚本行
SendMode,Input          ;~使用更速度和可靠方式发送键鼠点击
SetBatchLines,-1        ;~脚本全速执行(默认10ms)
SetControlDelay,0       ;~控件修改命令自动延时(默认20)
SetWinDelay,0            ;~执行窗口命令自动延时(默认100)
SetTitleMatchMode,2     ;~窗口标题模糊匹配
CoordMode,Menu,Window   ;~坐标相对活动窗口
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
#Include RunAny_ObjReg.ahk

class RunAnyObj {
	;[文本多行合并]
	;参数说明：
	;getZz：选中的文本内容
	;splitStr：换行符替换的分隔文本(默认空格，逗号为特殊字符，转义写成`,)
	text_merge_zz(getZz:="",splitStr:=" "){
		textResult:=""
		Loop, parse, getZz, `n, `r
		{
			str=%A_LoopField%
			textResult.=str . splitStr
		}
		StringTrimRight, textResult, textResult, 1
		this.Send_Str_Zz(textResult)
	}
	;[文本替换]
	;参数说明：
	;getZz：选中的文本内容
	;searchStr：查找的文本内容
	;replaceStr：用来替换查找到的文本
	text_replace_zz(getZz:="",searchStr:="",replaceStr:=""){
		this.Send_Str_Zz(StrReplace(getZz,searchStr,replaceStr))
	}
	;[文本格式化]
	;参数说明：
	;getZz：选中的文本内容
	;formatStr：格式化选项，详情查看(https://wyagd001.github.io/zh-cn/docs/commands/Format.htm)
	text_format_zz(getZz:="",formatStr:=""){
		this.Send_Str_Zz(Format(formatStr,getZz))
	}
	;[文本排序]
	;参数说明：
	;options：排序选项，详情查看(https://wyagd001.github.io/zh-cn/docs/commands/Sort.htm)
	text_sort_zz(getZz:="",options:=""){
		Sort,getZz,%options%
		this.Send_Str_Zz(getZz)
	}
	;~ [便捷运行磁力链接]
	text_magnet_zz(getZz:="",downApp:=""){
		url:=getZz
		if(!InStr(url,"magnet:?xt=urn:btih:")=1){
			url:="magnet:?xt=urn:btih:" url
		}
		if(downApp)
			downApp:=downApp A_Space
		Run,%downApp%%url%
	}
	;~;[输出短语]
	Send_Str_Zz(strZz){
		Candy_Saved:=ClipboardAll
		Clipboard:=strZz
		SendInput,^v
		Sleep,200
		Clipboard:=Candy_Saved
	}
}

;独立使用方式
;~ F1::
	;~ RunAnyObj.text_merge_zz("  1`n	2`n3")
;~ return
