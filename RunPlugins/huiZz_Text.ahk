;**************************************
;* 【ObjReg文本操作脚本[文本函数.ini]】 *
;*                          by hui-Zz *
;**************************************
global RunAny_Plugins_Version:="1.0.5"
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
#Include %A_ScriptDir%\RunAny_ObjReg.ahk

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
	;arab：0-中文数字；1-阿拉伯数字
	;seqNumStr：序号形式
	text_seq_num_zz(getZz:="",seqNumStr:="",arab:=1){
		textResult:=""
		ignoreNum:=0
		removeFlag:=false
		Loop, parse, getZz, `n, `r
		{
			getZzLoop:=A_LoopField
			if(arab=1 && RegExMatch(getZzLoop,"^\d+" seqNumStr)){
				textResult.=RegExReplace(getZzLoop,"^\d+" seqNumStr) . "`n"
				removeFlag:=true
			}else if(RegExMatch(getZzLoop,"^[零一二三四五六七八九十百千万亿兆京垓]+" seqNumStr)){
				textResult.=RegExReplace(getZzLoop,"^[零一二三四五六七八九十百千万亿兆京垓]+" seqNumStr) . "`n"
				removeFlag:=true
			}
			if(removeFlag)
				continue
			if(!Trim(A_LoopField)){
				textResult.=getZzLoop . "`n"
				ignoreNum++
				continue
			}
			numIndex:=A_Index-ignoreNum
			numIndex:=(arab=1) ? numIndex : this.n2c(numIndex)
			textResult.=numIndex seqNumStr getZzLoop . "`n"
		}
		textResult:=RTrim(textResult,"`n")
		this.Send_Str_Zz(textResult)
	}
	;数字转中文   by FeiYue
	n2c(n){
		if !(n ~= "^[1-9]\d*$")    ;当不是整数
			return
		static a:=StrSplit("零一二三四五六七八九")
			, b:=StrSplit("十百千万十百千亿十百千兆十百千京十百千垓")
		c:=d:="", k:=StrLen(n)
		Loop, Parse, n
			c.=a[A_LoopField+1] . b[k-A_Index]
		if StrLen(c)>(max:=2*b.MaxIndex()+1)
			d:=SubStr(c,1,-max+2), c:=SubStr(c,-max+3)
		c:=RegExReplace(c,"零(十|百|千)","零")
		c:=RegExReplace(c,"零{4}(万|亿|兆|京)","零")
		c:=RegExReplace(c,"零+(万|亿|兆|京)","$1零")
		c:=RegExReplace(c,"零+(?=零|$)")
		return, d . c
	}
	;中文转数字   by FeiYue
	c2n(c){
		static a:={"零":0,一:1,二:2,两:2,三:3,四:4,五:5
			,六:6,七:7,八:8,九:9,十:10,百:100,千:1000
			,万:10000,亿:10**8,兆:10**12,京:10**16,垓:10**20}
		c:=RegExReplace(c,"[[:ascii:]]")
		c:=SubStr(c,1,1)="十" ? "一" c:c
		r:=StrSplit(c), q:=w:=bak:=1, n:=0
		Loop, % i:=r.MaxIndex()
			if (v:=Round(a[r[i--]]))>1000
				w*=(v>bak ? v//bak : v), bak:=v, q:=1
			else if (v>=10)
				q:=v
			else n+=v*q*w
		return, n
	}
	;[中文数字互转]
	;参数说明：getZz：选中的文本内容
	;cn：0-转为阿拉伯数字；1-转为中文数字
	text_cn2_zz(getZz:="",cn=0){
		this.Send_Str_Zz(cn ? this.n2c(getZz) : this.c2n(getZz))
	}
}

;独立使用方式
;~ F1::
	;~ RunAnyObj.text_merge_zz("  1`n	2`n3")
;~ return
