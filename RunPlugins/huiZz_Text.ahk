;**************************************
;* 【ObjReg文本操作脚本[文本函数.ini]】 *
;*                          by hui-Zz *
;**************************************
global RunAny_Plugins_Version:="1.2.2"
#NoEnv                  ;~不检查空变量为环境变量
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

	;[文本多行合并]
	;参数说明：getZz：选中的文本内容
	;splitStr：换行符替换的分隔文本(默认空格，逗号为特殊字符，转义写成`,)
	text_merge_zz(getZz:="",splitStr:=" "){
		textResult:=""
		Loop, parse, getZz, `n, `r
		{
			str=%A_LoopField%
			if(str!="")
				textResult.=str . splitStr
		}
		StringTrimRight, textResult, textResult, 1
		Send_Str_Zz(textResult)
	}
	;[文本替换]
	;参数说明：getZz：选中的文本内容
	;searchStr：查找的文本内容
	;replaceStr：用来替换查找到的文本
	text_replace_zz(getZz:="",searchStr:="",replaceStr:=""){
		Send_Str_Zz(StrReplace(getZz,searchStr,replaceStr))
	}
	;[文本批量替换] v1.2.2
	;参数说明：getZz：选中的文本内容
	;replaceStr：用来替换查找到的文本
	;searchStrs：多个查找的文本内容，最多支持8个
	text_replace_batch_zz(getZz:="",replaceStr:="",searchStrs*){
		for index,searchStr in searchStrs
		{
			getZz:=StrReplace(getZz,searchStr,replaceStr)
		}
		Send_Str_Zz(getZz)
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
		textResult:=RegExReplace(textResult,"`n$")
		Send_Str_Zz(textResult)
	}
	;[Markdown格式化]
	;参数说明：getZz：选中的文本内容
	;formatStr：格式化选项，详情查看(https://wyagd001.github.io/zh-cn/docs/commands/Format.htm)
	text_format_md_zz(getZz:="",formatStr:="",surround:=0){
		textResult:=""
		removeFlag:=false
		escapeList:=StrSplit("\.*?+[{|()^$")
		regStr:=StrReplace(formatStr,"{1}",Chr(3))
		For k, v in escapeList
			regStr:=StrReplace(regStr,v,"\" v)
		regStr:=StrReplace(regStr,Chr(3),"(.*?)")
		Loop, parse, getZz, `n, `r
		{
			getZzLoop:=A_LoopField
			if(!Trim(A_LoopField)){
				textResult.=getZzLoop . "`n"
				continue
			}
			if(RegExMatch(getZzLoop,"S)^" regStr "$")){
				textResult.=RegExReplace(getZzLoop,"S)^" regStr "$","$1") . "`n"
				removeFlag:=true
			}
			if(removeFlag)
				continue
			textResult.=Format(formatStr,getZzLoop) . "`n"
		}
		textResult:=RegExReplace(textResult,"`n$")
		Send_Str_Zz(textResult)
		if(surround && !InStr(getZz,"`n")){
			getZzLen:=StrLen(getZz)
			surroundKeyNum:=StrLen(StrReplace(textResult,getZz)) / 2
			SendInput,{Left %surroundKeyNum%}
			SendInput,+{Left %getZzLen%}
		}
	}
	;[变量命名]
	;参数说明：getZz：选中的文本内容
	;varStr：变量命名格式符号
	;formatStr：格式化选项，详情查看(https://wyagd001.github.io/zh-cn/docs/commands/Format.htm)
	;splitStr：分割用的字符，一般不用传使用默认值 ,._-|
	text_var_name_zz(getZz:="",varStr:="",formatStr:="",splitStr:=" ,._-|/\"){
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
			if(getZzList.MaxIndex()=1){
				textResult.=getZzLoop . "`n"
				continue
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
		textResult:=RegExReplace(textResult,"`n$")
		Send_Str_Zz(textResult)
	}
	;[文本排序]
	;参数说明：
	;options：排序选项，详情查看(https://wyagd001.github.io/zh-cn/docs/commands/Sort.htm)
	text_sort_zz(getZz:="",options:=""){
		Sort,getZz,%options%
		Send_Str_Zz(getZz)
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
	;[选中文字用指定编辑器打开]
	;参数说明：getZz：选中的文本内容
	;editApp：编辑器软件
	text_edit_zz(getZz:="",editApp:=""){
		if(editApp){
			DetectHiddenWindows, Off
			if(!WinExist("ahk_exe" . editApp)){
				Run,%editApp%
				WinWait,ahk_exe %editApp%
			}
			WinActivate,ahk_exe %editApp%
			Sleep,200
			Send_Str_Zz(getZz)
		}
	}
	;[选中内容与剪贴板内容互换]
	text_paste_zz(getZz:=""){
		SendInput,^v
		Sleep,200
		Clipboard:=getZz
	}
	;[百度剪贴板内容]
	text_baidu_zz(){
		Run,https://www.baidu.com/s?wd=%Clipboard%
	}
	;[复制或输出文件文本的内容]
	;参数说明：getZz：选中的文件 或 传递文件路径(可使用无路径)
	;isSend：0-显示并保存到剪贴板；1-输出结果
	;encoding：使用不同编码读取文件
	text_file_content(getZz:="",isSend=0,encoding:=""){
		if(encoding!=""){
			try{
				FileEncoding,%encoding%
			}catch e{
				MsgBox,16,文件编码出错,% "请设置正确的编码读取!`n参考：https://wyagd001.github.io/zh-cn/docs/commands/FileEncoding.htm"
				. "`n`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
			}
		}
		FileRead, fileVar, %getZz%
		if(fileVar!="")
			Send_Or_Show(fileVar,isSend)
	}
	;[比较工具(Beyond Compare)比较选中文本内容和剪贴板]
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
	;arab：0-中文数字；1-阿拉伯数字
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
			numIndex:=(arab=1) ? numIndex : n2c(numIndex)
			textResult.=numIndex seqNumStr getZzLoop . "`n"
		}
		textResult:=RegExReplace(textResult,"`n$")
		Send_Str_Zz(textResult)
	}
	;[文本删除重复行保留顺序]
	;参数说明：getZz：选中的文本内容
	text_remove_repeat(getZz:=""){
		textResult:=""
		textResultObj:={}
		textResultList:=[]
		Loop, parse, getZz, `n, `r
		{
			getZzLoop:=A_LoopField
			textResultObj[getZzLoop]:=A_Index
			textResultList.Push(getZzLoop)
		}
		For k, v in textResultList
		{
			if(textResultObj[v] <> ""){
				textResult.=v . "`n"
				textResultObj.Delete(v)
			}
		}
		textResult:=RegExReplace(textResult,"`n$")
		Send_Str_Zz(textResult)
	}
	;[中文数字互转]
	;参数说明：getZz：选中的文本内容
	;cn：0-转为阿拉伯数字；1-转为中文数字
	text_cn2_zz(getZz:="",cn=0){
		Send_Str_Zz(cn ? n2c(getZz) : c2n(getZz))
	}
	;[文本编码转换]
	;参数说明：getZz：选中的文本内容
	;sCode：要转换的文本编码
	;cCode：转换后的文本编码
	;isShow：是否显示文本编码(1显示;0隐藏)
	;保存到RunAny.ini为：
	;uri转中文|huiZz_Text[text_encode_zz](%getZz%,uri,cn)
	;中文转uri|huiZz_Text[text_encode_zz](%getZz%,cn,uri)
	;unicode转中文|huiZz_Text[text_encode_zz](%getZz%,unicode,cn)
	;中文转unicode|huiZz_Text[text_encode_zz](%getZz%,cn,unicode)
	text_encode_zz(getZz:="",sCode:="",cCode:="",isShow:=true){
		if(getZz="" || sCode="" || cCode=""){
			ToolTip,没有选中文本或指定需要转换的编码格式
			Sleep,2000
			ToolTip
			return
		}
		if(sCode="uri"){
			textResult:=URI_Decode(getZz)
		}else if(sCode="unicode"){
			textResult:=Unicode_Decode(getZz)
		}else if(sCode="cn"){
			if(cCode="uri"){
				textResult:=URI_Encode(getZz)
			}else if(cCode="unicode"){
				textResult:=CN2uXXXX(getZz)
			}
		}
		Send_Str_Zz(textResult)
		if(isShow){
			ToolTip,%textResult%
			Sleep,3000
			if(A_TimeIdle>1000)
				Sleep,3000
			ToolTip
		}
	}
	;~;[文本加密]
	;【注意：key不要包含中文和中文标点符号】
	;保存到RunAny.ini为：
	;选中文本加密|huiZz_Text[encrypt](%getZz%,youkey1)
	;选中加密到剪贴板|huiZz_Text[encrypt](%getZz%,youkey1,0)
	encrypt(text,key,isSend=1){
		Send_Or_Show(encryptstr(text,key),isSend)
	}
	;~;[文本解密]
	;【注意：key不要包含中文和中文标点符号】
	;保存到RunAny.ini为：
	;text：被解密文本；key：你的加密key
	;文本解密输出|huiZz_Text[decrypt](被解密文本,youkey1)
	;选中文本解密|huiZz_Text[decrypt](%getZz%,youkey1)
	;选中解密到剪贴板|huiZz_Text[decrypt](%getZz%,youkey1,0)
	decrypt(text,key,isSend=1){
		Send_Or_Show(decryptstr(text,key),isSend)
	}
	runany_encrypt(text,key){
		return RegExReplace(encryptstr(text,key),"`r`n$")
	}
	runany_decrypt(text,key){
		return RegExReplace(decryptstr(text,key),"`r`n$")
	}
	;[文本谷歌翻译]
	;参数说明：getZz：选中的文本内容
	;from：需要翻译的文字语言，默认自动
	;to：翻译结果的语言，默认英文
	;保存到RunAny.ini为：选中翻译为英文|huiZz_Translate[google_translate](%getZz%,auto,en)
	;选中翻译为中文|huiZz_Translate[google_translate](%getZz%,auto,zh-CN)
	google_translate(getZz,from,to,isSend=0){
		textResult:=GoogleTranslate(getZz,from,to)
		Send_Or_Show(textResult,isSend,5000)
	}
	google_translate_auto(getZz,from:="auto",to:="zh-CN",isSend=0){
		if(!RegExMatch(getZz,"S)[\p{Han}]+")){
			to:="zh-CN"
		}else if(!RegExMatch(getZz,"S)[a-zA-Z]+")){
			to:="en"
		}
		textResult:=GoogleTranslate(getZz,from,to)
		Send_Or_Show(textResult,isSend,5000)
	}
	runany_google_translate(getZz,from,to){
		return GoogleTranslate(getZz,from,to)
	}

;══════════════════════════大括号以上是RunAny菜单调用的函数══════════════════════════

}

;════════════════════════════以下是脚本自己调用依赖的函数════════════════════════════

;~;输出结果
Send_Str_Zz(strZz){
	ClipSaved:=ClipboardAll
	;切换Win10输入法为英文
	try DllCall("SendMessage",UInt,DllCall("imm32\ImmGetDefaultIMEWnd",Uint,WinExist("A")),UInt,0x0283,Int,0x002,Int,0x00)
	Clipboard:=strZz
	SendInput,^v
	Sleep,200
	Clipboard:=ClipSaved
}
;~;输出结果还是仅显示保存到剪贴板
Send_Or_Show(textResult,isSend:=0,sTime:=3000){
	textResult:=RegExReplace(textResult,"`r`n$")
	if(isSend){
		Send_Str_Zz(textResult)
		return
	}
	Clipboard:=textResult
	ToolTip,%textResult%
	Sleep,%sTime%
	if(A_TimeIdle>1000)
		Sleep,%sTime%
	ToolTip
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
;[中文转换为URI编码]
URI_Encode(Str, All := False)
{
	Static doc := ComObjCreate("HTMLfile")
	Try
	{
		doc.write("<body><script>document.body.innerText = encodeURI" . (All ? "Component" : "") . "(""" . Str . """);</script>")
		Return, doc.body.innerText, doc.body.innerText := ""
	}
}
;[URI编码转换为中文]
URI_Decode(Str)
{
	Static doc := ComObjCreate("HTMLfile")
	Try
	{
		doc.write("<body><script>document.body.innerText = decodeURIComponent(""" . Str . """);</script>")
		Return, doc.body.innerText, doc.body.innerText := ""
	}
}
;[中文转Unicode编码]properties配置文件可以使用这种格式
CN2uXXXX(cnStr) ; in: "爱尔兰之狐" out: "\u7231\u5C14\u5170\u4E4B\u72D0"
{	; by https://github.com/cocobelgica/AutoHotkey-JSON
	while RegExMatch(cnStr, "[^\x20-\x7e]", ch) {
		ustr := Asc(ch), esc_ch := "\u", n := 12
		while (n >= 0)
			esc_ch .= Chr((x:=(ustr>>n) & 15) + (x<10 ? 48 : 55))
			, n -= 4
		StringReplace, cnStr, cnStr, % ch, % esc_ch, A
	}
	return, cnStr
}
;[Unicode编码转换为中文]
Unicode_Decode(Str)
{
	Static doc := ComObjCreate("HTMLfile")
	Try
	{
		doc.write("<body><script>document.body.innerText = unescape(""" . Str . """);</script>")
		Return, doc.body.innerText, doc.body.innerText := ""
	}
}

;------------[文本加解密]开始------------
;https://www.autohotkey.com/boards/viewtopic.php?f=6&t=1108&hilit=password+encryption
encryptStr(str="",pass="")
{
If !(enclen:=(strput(str,"utf-16")*2))
    return "Error: Nothing to Encrypt"
If !(passlen:=strput(pass,"utf-8")-1)
    return "Error: No Pass"
enclen:=mod(enclen,4) ? (enclen) : (enclen-2)
Varsetcapacity(encbin,enclen,0)
strput(str,&encbin,enclen/2,"utf-16")
Varsetcapacity(passbin,passlen+=mod((4-mod(passlen,4)),4),0)
strput(pass,&passbin,strlen(pass),"utf-8")
_encryptbin(&encbin,enclen,&passbin,passlen)
return _crypttobase64(&encbin,enclen)
}

decryptStr(str="",pass="")
{
If !((strput(str,"utf-16")*2))
    return "Error: Nothing to Decrypt"
If !((passlen:=strput(pass,"utf-8")-1))
    return "Error: No Pass"
Varsetcapacity(passbin,passlen+=mod((4-mod(passlen,4)),4),0)
strput(pass,&passbin,strlen(pass),"utf-8")
enclen:=_cryptfrombase64(str,encbin)
_decryptbin(&encbin,enclen,&passbin,passlen)
return strget(&encbin,"utf-16")
}

_MCode(mcode)
{
  static e := {1:4, 2:1}, c := (A_PtrSize=8) ? "x64" : "x86"
  if (!regexmatch(mcode, "^([0-9]+),(" c ":|.*?," c ":)([^,]+)", m))
    return
  if (!DllCall("crypt32\CryptStringToBinary", "str", m3, "uint", 0, "uint", e[m1], "ptr", 0, "uint*", s, "ptr", 0, "ptr", 0))
    return
  p := DllCall("GlobalAlloc", "uint", 0, "ptr", s, "ptr")
  if (c="x64")
    DllCall("VirtualProtect", "ptr", p, "ptr", s, "uint", 0x40, "uint*", op)
  if (DllCall("crypt32\CryptStringToBinary", "str", m3, "uint", 0, "uint", e[m1], "ptr", p, "uint*", s, "ptr", 0, "ptr", 0))
    return p
  DllCall("GlobalFree", "ptr", p)
}

_encryptbin(bin1pointer,bin1len,bin2pointer,bin2len){
  static encrypt := _MCode("2,x86:U1VWV4t0JBCLTCQUuAAAAAABzoPuBIsWAcKJFinCAdAPr8KD6QR164tsJByLfCQYi3QkEItMJBSLH7gAAAAAixYBwjHaiRYx2inCAdAPr8KDxgSD6QR154PHBIPtBHXQuAAAAABfXl1bww==,x64:U1ZJicpJidNMidZMidlIAc64AAAAAEiD7gSLFgHCiRYpwgHQD6/CSIPpBHXpuAAAAABBixhMidZMidmLFgHCMdqJFjHaKcIB0A+vwkiDxgRIg+kEdeVJg8AESYPpBHXbuAAAAABeW8M=") ;reserved
b:=0
Loop % bin1len/4
{
a:=numget(bin1pointer+0,bin1len-A_Index*4,"uint")
numput(a+b,bin1pointer+0,bin1len-A_Index*4,"uint")
b:=(a+b)*a
}
Loop % bin2len/4
{
c:=numget(bin2pointer+0,(A_Index-1)*4,"uint")
b:=0
Loop % bin1len/4
{
a:=numget(bin1pointer+0,(A_Index-1)*4,"uint")
numput((a+b)^c,bin1pointer+0,(A_Index-1)*4,"uint")
b:=(a+b)*a
}
}
}

_decryptbin(bin1pointer,bin1len,bin2pointer,bin2len){
  static decrypt := _MCode("2,x86:U1VWV4tsJByLfCQYAe+D7wSLH7gAAAAAi3QkEItMJBSLFjHaKcKJFgHQD6/Cg8YEg+kEdeuD7QR11LgAAAAAi3QkEItMJBQBzoPuBIsWKcKJFgHQD6/Cg+kEde24AAAAAF9eXVvD,x64:U1ZJicpJidNNAchJg+gEuAAAAABBixhMidZMidmLFjHaKcKJFgHQD6/CSIPGBEiD6QR16UmD6QR140yJ1kyJ2UgBzrgAAAAASIPuBIsWKcKJFgHQD6/CSIPpBHXruAAAAABeW8M=") ;reserved

Loop % bin2len/4
{
c:=numget(bin2pointer+0,bin2len-A_Index*4,"uint")
b:=0
Loop % bin1len/4
{
a:=numget(bin1pointer+0,(A_Index-1)*4,"uint")
numput(a:=(a^c)-b,bin1pointer+0,(A_Index-1)*4,"uint")
b:=(a+b)*a
}
}
b:=0
Loop % bin1len/4
{
a:=numget(bin1pointer+0,bin1len-A_Index*4,"uint")
numput(a:=a-b,bin1pointer+0,bin1len-A_Index*4,"uint")
b:=(a+b)*a
}
}

_crypttobase64(binpointer,binlen)
{
    s:=0
    DllCall("crypt32\CryptBinaryToStringW","ptr",binpointer,"uint",binlen,"uint",1,"ptr",   0,"uint*",s)
    VarSetCapacity(out,s*2,0)
    DllCall("crypt32\CryptBinaryToStringW","ptr",binpointer,"uint",binlen,"uint",1,"ptr",&out,"uint*",s)
    return strget(&out,"utf-16")
}

_cryptfrombase64(string,byref bin)
{
    DllCall("crypt32\CryptStringToBinaryW", "wstr",string,"uint",0,"uint",1,"ptr",0,"uint*",s,"ptr",0,"ptr",0)
    VarSetCapacity(bin,s,0)
    DllCall("crypt32\CryptStringToBinaryW", "wstr",string,"uint",0,"uint",1,"ptr",&bin,"uint*",s,"ptr",0,"ptr",0)
    return s
}
;------------[文本加解密]结束------------

;-------------[文本翻译]开始-------------
;https://www.autohotkey.com/boards/viewtopic.php?f=6&t=63835
GoogleTranslate(str, from := "auto", to := "en")  {
   static JS := CreateScriptObj(), _ := JS.( GetJScript() ) := JS.("delete ActiveXObject; delete GetObject;")
   
   json := SendRequest(JS, str, to, from, proxy := "")
   oJSON := JS.("(" . json . ")")

   if !IsObject(oJSON[1])  {
      Loop % oJSON[0].length
         trans .= oJSON[0][A_Index - 1][0]
   }
   else  {
      MainTransText := oJSON[0][0][0]
      Loop % oJSON[1].length  {
         trans .= "`n+"
         obj := oJSON[1][A_Index-1][1]
         Loop % obj.length  {
            txt := obj[A_Index - 1]
            trans .= (MainTransText = txt ? "" : "`n" txt)
         }
      }
   }
   if !IsObject(oJSON[1])
      MainTransText := trans := Trim(trans, ",+`n ")
   else
      trans := MainTransText . "`n+`n" . Trim(trans, ",+`n ")

   from := oJSON[2]
   trans := Trim(trans, ",+`n ")
   Return trans
}

SendRequest(JS, str, tl, sl, proxy) {
   static http
   ComObjError(false)
   if !http
   {
      http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
      ( proxy && http.SetProxy(2, proxy) )
      http.open( "get", "https://translate.google.cn", 1 )
      http.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0")
      http.send()
      http.WaitForResponse(-1)
   }
   http.open( "POST", "https://translate.google.cn/translate_a/single?client=webapp&sl="
      . sl . "&tl=" . tl . "&hl=" . tl
      . "&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&ie=UTF-8&oe=UTF-8&otf=0&ssel=0&tsel=0&pc=1&kc=1"
      . "&tk=" . JS.("tk").(str), 1 )

   http.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded;charset=utf-8")
   http.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0")
   http.send("q=" . URIEncode(str))
   http.WaitForResponse(-1)
   Return http.responsetext
}

URIEncode(str, encoding := "UTF-8")  {
   VarSetCapacity(var, StrPut(str, encoding))
   StrPut(str, &var, encoding)

   While code := NumGet(Var, A_Index - 1, "UChar")  {
      bool := (code > 0x7F || code < 0x30 || code = 0x3D)
      UrlStr .= bool ? "%" . Format("{:02X}", code) : Chr(code)
   }
   Return UrlStr
}

GetJScript()
{
   script =
   (
      var TKK = ((function() {
        var a = 561666268;
        var b = 1526272306;
        return 406398 + '.' + (a + b);
      })());

      function b(a, b) {
        for (var d = 0; d < b.length - 2; d += 3) {
            var c = b.charAt(d + 2),
                c = "a" <= c ? c.charCodeAt(0) - 87 : Number(c),
                c = "+" == b.charAt(d + 1) ? a >>> c : a << c;
            a = "+" == b.charAt(d) ? a + c & 4294967295 : a ^ c
        }
        return a
      }

      function tk(a) {
          for (var e = TKK.split("."), h = Number(e[0]) || 0, g = [], d = 0, f = 0; f < a.length; f++) {
              var c = a.charCodeAt(f);
              128 > c ? g[d++] = c : (2048 > c ? g[d++] = c >> 6 | 192 : (55296 == (c & 64512) && f + 1 < a.length && 56320 == (a.charCodeAt(f + 1) & 64512) ?
              (c = 65536 + ((c & 1023) << 10) + (a.charCodeAt(++f) & 1023), g[d++] = c >> 18 | 240,
              g[d++] = c >> 12 & 63 | 128) : g[d++] = c >> 12 | 224, g[d++] = c >> 6 & 63 | 128), g[d++] = c & 63 | 128)
          }
          a = h;
          for (d = 0; d < g.length; d++) a += g[d], a = b(a, "+-a^+6");
          a = b(a, "+-3^+b+-f");
          a ^= Number(e[1]) || 0;
          0 > a && (a = (a & 2147483647) + 2147483648);
          a `%= 1E6;
          return a.toString() + "." + (a ^ h)
      }
   )
   Return script
}

CreateScriptObj() {
   static doc
   doc := ComObjCreate("htmlfile")
   doc.write("<meta http-equiv='X-UA-Compatible' content='IE=9'>")
   Return ObjBindMethod(doc.parentWindow, "eval")
}
;-------------[文本翻译]结束-------------

;独立使用方式
;~ F1::
	;~ RunAnyObj.text_merge_zz("  1`n	2`n3")
;~ return
