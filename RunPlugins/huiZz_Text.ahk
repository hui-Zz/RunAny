;**************************************
;* 【ObjReg文本操作脚本(文本函数.ini)】 *
;*                          by hui-Zz *
;**************************************
global RunAny_Plugins_Version:="1.0.2"
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
	;~;[输出短语]
	Send_Str_Zz(strZz){
		Candy_Saved:=ClipboardAll
		Clipboard:=strZz
		SendInput,^v
		Sleep,200
		Clipboard:=Candy_Saved
	}
	;[文本多行合并]
	;参数说明：getZz：选中的文本内容
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
	;参数说明：getZz：选中的文本内容
	;searchStr：查找的文本内容
	;replaceStr：用来替换查找到的文本
	text_replace_zz(getZz:="",searchStr:="",replaceStr:="",formatStr:=""){
		if(searchStr="" && replaceStr!=""){
			getZz:=RegExReplace(getZz,"([a-z0-9$])([A-Z])","$1" Chr(3) "$2")
			searchStr:=Chr(3)
		}
		getZz:=StrReplace(getZz,searchStr,replaceStr)
		if(formatStr!="")
			getZz:=Format(formatStr,getZz)
		this.Send_Str_Zz(getZz)
	}
	;[文本格式化]
	;参数说明：getZz：选中的文本内容
	;formatStr：格式化选项，详情查看(https://wyagd001.github.io/zh-cn/docs/commands/Format.htm)
	text_format_zz(getZz:="",formatStr:=""){
		textResult:=""
		Loop, parse, getZz, `n, `r
		{
			getZzLoop:=A_LoopField
			if(!Trim(A_LoopField)){
				textResult.=getZzLoop . "`n"
				continue
			}
			textResult.=Format(formatStr,getZzLoop) . "`n"
		}
		textResult:=RTrim(textResult,"`n")
		this.Send_Str_Zz(textResult)
	}
	;[变量命名]
	;参数说明：getZz：选中的文本内容
	;varStr：变量命名格式符号
	;formatStr：格式化选项，详情查看(https://wyagd001.github.io/zh-cn/docs/commands/Format.htm)
	;splitStr：分割用的字符，一般不用传使用默认值 ,._-|
	text_var_name_zz(getZz:="",varStr:="",formatStr:="",splitStr:=" ,._-|"){
		textResult:=""
		Loop, parse, getZz, `n, `r
		{
			getZzList:=[]
			formatLoop:=formatStr
			getZzLoop:=A_LoopField
			if(!Trim(A_LoopField)){
				textResult.=getZzLoop . "`n"
				continue
			}
			Loop, Parse, getZzLoop, %splitStr%
			{
				str:=RegExReplace(A_LoopField,"([a-z0-9$])([A-Z])","$1|$2")
				str:=RegExReplace(str,"^\|")
				if(InStr(str,"|")){
					Loop, Parse, str, |
					{
						getZzList.Push(A_LoopField)
					}
				}else{
					getZzList.Push(A_LoopField)
				}
			}
			lastFormat:=RegExReplace(formatLoop, ".*(\{[^{}]*\})","$1")
			RegExReplace(formatLoop,"\{.*?\}","",formatCount)
			if(getZzList.MaxIndex()-formatCount>0){
				loop,% getZzList.MaxIndex()-formatCount
				{
					formatLoop.=varStr . lastFormat
				}
			}
			textResult.=Format(formatLoop,getZzList*) . "`n"
		}
		textResult:=RTrim(textResult,"`n")
		this.Send_Str_Zz(textResult)
	}
	;[文本排序]
	;参数说明：
	;options：排序选项，详情查看(https://wyagd001.github.io/zh-cn/docs/commands/Sort.htm)
	text_sort_zz(getZz:="",options:=""){
		Sort,getZz,%options%
		this.Send_Str_Zz(getZz)
	}
	;[便捷运行磁力链接]
	;参数说明：getZz：选中的文本内容
	;downApp：磁链下载软件
	text_magnet_zz(getZz:="",downApp:=""){
		url:=getZz
		if(!InStr(url,"magnet:?xt=urn:btih:")=1){
			url:="magnet:?xt=urn:btih:" url
		}
		if(downApp)
			downApp:=downApp A_Space
		Run,%downApp%%url%
	}
	;[便捷替换粘贴文本]
	text_paste_zz(getZz:=""){
		SendInput,^v
		Clipboard:=getZz
	}
	;[百度剪贴板内容]
	text_baidu_zz(){
		Run,https://www.baidu.com/s?wd=%Clipboard%
	}
	;[选中文本比较剪贴板]
	;参数说明：getZz：选中的文本内容
	;compareApp：文本对比软件
	text_compare_zz(getZz:="",compareApp:=""){
		if(compareApp){
			fs:="选择文本"+A_Now
			fc:="剪贴板文本"+A_Now
			FileAppend,%getZz%,%A_Temp%\%fs%.txt
			FileAppend,%Clipboard%,%A_Temp%\%fc%.txt
			Run,%compareApp% %A_Temp%\%fs%.txt %A_Temp%\%fc%.txt
		}
	}
	;[批量添加序号]
	;参数说明：getZz：选中的文本内容
	;seqNumStr：序号形式
	text_seq_num_zz(getZz:="",seqNumStr:=""){
		textResult:=""
		ignoreNum:=0
		Loop, parse, getZz, `n, `r
		{
			getZzLoop:=A_LoopField
			if(!Trim(A_LoopField)){
				textResult.=getZzLoop . "`n"
				ignoreNum++
				continue
			}
			textResult.=(A_Index-ignoreNum) seqNumStr getZzLoop . "`n"
		}
		textResult:=RTrim(textResult,"`n")
		this.Send_Str_Zz(textResult)
	}
}

;独立使用方式
;~ F1::
	;~ RunAnyObj.text_merge_zz("  1`n	2`n3")
;~ return
