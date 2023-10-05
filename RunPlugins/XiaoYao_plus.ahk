;************************
;* 【文件分类，解散文件夹，ImageMagick功能，ffmpeg功能等，以及可以直接在runany.ini中使用更多的变量】
;************************



global RunAny_Plugins_Version:="1.3.5"
#NoTrayIcon             ;~不显示托盘图标
#Persistent             ;~让脚本持久运行
#SingleInstance,Force   ;~运行替换旧实例
;********************************************************************************
#Include %A_ScriptDir%\RunAny_ObjReg.ahk

;══════════════════════当前窗口的路径获取════════════════════════════════════════════════════
SetTitleMatchMode, RegEx
GroupAdd, Explorer, ahk_class CabinetWClass
GroupAdd, Explorer, ahk_class ExploreWClass
ComObjError(0)


Label_Return: ;结束标志
	SetTimer,Label_ClearMEM,-1000 ;清理内存
Return

class RunAnyObj {

;══════════════════════获取选中文件的更多变量(多个选中)════════════════════════════════════════════════════
RA_plus(getZz,plusxy_Path,func){
																;完整路径
	filebatch5:= ShellFolder(hWnd)								;当前资源管理器打开的窗口的路径, 不支持win11多标签
	filebatch6:= getfiles4()									;当前资源管理器打开的窗口的路径, 支持win11多标签，但需要设置，文件夹选项-查看-勾选"在标题栏中显示完整路径 
    filebatch := getfiles(getZz)								;完整路径，(多选文件时，自动加上双引号""并空格隔开，  	示例："Path1" "Path2" "Path3")
    filebatch2 := getfiles2(getZz)								;完整路径，(多选文件时，自动加上双引号""并逗号,隔开，  	示例："Path1","Path2","Path3")
    filebatch3 := getfiles3(getZz)								;完整路径，(多选文件时，逗号,加空格隔开  	示例：Path1, Path2, Path3)

	fileName2 := system_file_path_zz(getZz,"name")				;名称[换行输出选中的多个文件]
	fileNameNoExt2 := system_file_path_zz(getZz,"NameNoExt")	;无后缀名称[换行输出选中的多个文件]

	filetest :=StrSplit(getZz, "\")
	filebatch4 := filetest[filetest.MaxIndex() - 1]  			;获取选中文件的目录的名称 示例：C:\win10\娱乐 获取的是 win10	
;══════════════════════获取选中文件的更多变量(单个选中)════════════════════════════════════════════════════
	filedir :=""					; %filedir%				目录
	fileExt :=""					; %fileExt%				后缀
	fileNameNoExt :=""				; %fileNameNoExt%		无后缀名称
	fileDrive :=""					; %fileDrive%			盘符
	filelnkTarget :=""				; %filelnkTarget%		lnk指向路径
	filelnkDir :=""					; %filelnkDir%			lnk指向目录
	filelnkArgs :=""				; %filelnkArgs%			lnk参数
	filelnkDesc :=""				; %filelnkDesc%			lnk注释
	filelnkIcon :=""				; %filelnkIcon%			lnk图标文件名
	filelnkIconNum :=""				; %filelnkIconNum%		lnk图标编号
	filedirlnkRunState :=""			; %filedirlnkRunState%	lnk初始运行方式
Loop, parse, getZz, `n, `r, %A_Space%%A_Tab%
	{
		if(!A_LoopField)
			continue
		SplitPath, A_LoopField, name, dir, ext, nameNoExt, drive
		if(ext="lnk")
			FileGetShortcut, %A_LoopField%, lnkTarget, lnkDir, lnkArgs, lnkDesc, lnkIcon, lnkIconNum, lnkRunState
		fileName:=name
		filedir:=dir
		fileExt:=ext
		fileNameNoExt:=nameNoExt
		fileDrive:=drive
		filelnkTarget:=lnkTarget
		filelnkDir:=lnkDir
		filelnkArgs:=lnkArgs
		filelnkDesc:=lnkDesc
		filelnkIcon:=lnkIcon
		filelnkIconNum:=lnkIconNum
		filedirlnkRunState:=lnkRunState
	}

switch func
	{

	case 1:
		SendInput, ^a
		RunAny_Send_WM_COPYDATA("Menu_Show", "RunAny.ahk ahk_class AutoHotkey")
	case 2:		;保存到RunAny.ini为：百度搜索选中文件|XiaoYao_plus[RA_plus](%getZz%,,2)				
		Loop, parse, fileNameNoExt2, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		Run https://www.baidu.com/s?wd=%xiaoyaoStr%
   		 }
	case 3:		;保存到RunAny.ini为：添加到开机自启|XiaoYao_plus[RA_plus](%getZz%,,3)		
		RunWait reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v "%fileNameNoExt%" /t REG_SZ /d %filebatch% /f 
		ttip("添加成功",1500)		
	case 4:		;移动文件到桌面|XiaoYao_plus[RA_plus](%getZz%,,4)		
		FileMove, %getZz%, %A_Desktop%
	case 5:		;移动文件夹到桌面|XiaoYao_plus[RA_plus](%getZz%,,5)		
		FileMoveDir, %getZz%, %A_Desktop%\%fileName%
	case 6:		;创建新文件夹[选中]|XiaoYao_plus[RA_plus](%getZz%,,6)				
		FileCreateDir, %filedir%\%fileNameNoExt%
		;创建一个新的目录, 以选中文件的名称命名
	case 7:		;保存到RunAny.ini为：解散文件夹|XiaoYao_plus[RA_plus](%getZz%,,7)		
		;将选中文件夹中的所有内容提取到文件夹外并删除该文件夹
		;当要解散的文件夹里有文件跟上级目录里的文件重名时, 提示是否覆盖
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr,name,dir
		redir:=dir
		RunWait %ComSpec% /c "pushd "%xiaoyaoStr%" && for /r `%a in (*) do move /-Y "`%a" "%redir%""
		RunWait %ComSpec% /c "pushd "%xiaoyaoStr%" && for /d `%a in (*) do rd "`%a"", , Hide
		RunWait %ComSpec% /c "rd "%xiaoyaoStr%"", , Hide
   		 }
		ttip("解散成功",1000)
	case 8:	;起始(删除一整行);
		Send {Home}
		Send +{End}  
		Send {delete}    
	case 9:
		send {home}
		send +{end}
		send ^c   ;输出ctrl+c,复制一整行
	case 10:	;保存到RunAny.ini为：当前目录打开CMD|XiaoYao_plus[RA_plus](,,10)	
			Run %ComSpec% /k pushd "%filebatch5%"
	case 11:	;保存到RunAny.ini为：ev搜当前目录|XiaoYao_plus[RA_plus](,%"Everything.exe"%,11)
			Run %plusxy_Path% -p "%filebatch6%"
			;ev搜当前目录		
	case 13:	;创建日期文件夹|XiaoYao_plus[RA_plus](,,13)
		Runwait %ComSpec% /c pushd "%filebatch6%" && md "%A_YYYY%%A_MM%%A_DD%", , Hide
		ttip("创建",1000)
		;创建以今天日期为文件夹名的新文件夹
	case 14:	;文件分类
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr, name, dir, ext, nameNoExt, drive
		rename1:=name
		redir:=dir
		reext:=ext
		
		Runwait %ComSpec% /c pushd "%redir%" && md "%reext%", , Hide
		RunWait %ComSpec% /c "move /Y "%xiaoyaoStr%" "%redir%\%reext%"", , Hide
		}
		ttip("分类成功",1500)
	case 15:	;颜色神偷
		MouseGetPos, mouseX, mouseY
		; 获得鼠标所在坐标，把鼠标的 X 坐标赋值给变量 mouseX ，同理 mouseY
		PixelGetColor, color, %mouseX%, %mouseY%, RGB
		; 调用 PixelGetColor 函数，获得鼠标所在坐标的 RGB 值，并赋值给 color
		StringRight color,color,6
		; 截取 color（第二个 color）右边的6个字符，因为获得的值是这样的：#RRGGBB，一般我们只需要 RRGGBB 部分。把截取到的值再赋给 color（第一个 color）。
		clipboard = %color%
		; 把 color 的值发送到剪贴板


;Bandizip功能-----------------------------------
	case 1001:		
		Run %plusxy_Path% bx -target:auto %filebatch%
	case 1002:		
		Run %plusxy_Path% bx -o:"%filedir%" %filebatch%
	case 1003:		
		Run %plusxy_Path% cd "%filedir%\压缩包.zip" %filebatch%
	case 1004:		
		Run %plusxy_Path% bc -aoa -o:"%filedir%" %filebatch%	
;保存到RunAny.ini为：		
;Bz智能解压|XiaoYao_plus[RA_plus](%getZz%,%"Bandizip.exe"%,1001)
;Bz解压(非智能)|XiaoYao_plus[RA_plus](%getZz%,%"Bandizip.exe"%,1002)
;Bz压缩|XiaoYao_plus[RA_plus](%getZz%,%"Bandizip.exe"%,1003)
;Bz分别压缩|XiaoYao_plus[RA_plus](%getZz%,%"Bandizip.exe"%,1004)


;Snipaste功能-----------------------------------
	case 2001:
		detectApp("Snipaste.exe",plusxy_Path)
		Run %plusxy_Path% snip
	case 2002:
		If (getZz!="")
			Run %plusxy_Path% paste --files %getZz%
		Else
			Run %plusxy_Path% paste
	case 2003:
		Run %plusxy_Path% snip -o pin
		ttip("贴图成功",500)
	case 2004:
		Run %plusxy_Path% snip --full -o clipboard
		ttip("放入剪切板",500) 
	case 2005:
		Run %plusxy_Path% snip -o quick-save
		ttip("存入文件夹",500)
	case 2006:
		If (getZz!="")
			Run %plusxy_Path% paste --plain %getZz%
		Else
			Run %plusxy_Path% paste --plain
	case 2007:
			Run %plusxy_Path% whiteboard
;保存到RunAny.ini为：
;sinp截图|XiaoYao_plus[RA_plus]("%getZz%",%"Snipaste.exe"%,2001)
;sinp选中图片贴图|XiaoYao_plus[RA_plus]("%getZz%",%"Snipaste.exe"%,2002)
;截图后贴图|XiaoYao_plus[RA_plus]("%getZz%",%"Snipaste.exe"%,2003)
;全屏截图放剪切板|XiaoYao_plus[RA_plus]("%getZz%",%"Snipaste.exe"%,2004)
;截图放快速文件夹|XiaoYao_plus[RA_plus]("%getZz%",%"Snipaste.exe"%,2005)
;纯文本贴图|XiaoYao_plus[RA_plus]("%getZz%",%"Snipaste.exe"%,2006)
;白板|XiaoYao_plus[RA_plus]("%getZz%",%"Snipaste.exe"%,2007)

;7zip功能-----------------------------------
	case 4001:		
		Run %plusxy_Path% x %filebatch%
	case 4002:		
		Run %plusxy_Path% a %filebatch%	
	case 4003:			
				Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr,name,dir
		redir:=dir
		Run %plusxy_Path% x "%xiaoyaoStr%" -o"%redir%" -y -aou
		}
	case 4004:		
		Run %plusxy_Path% a "%filedir%\压缩包.zip" %filebatch%
	case 4005:		
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr, name, dir, ext, nameNoExt, drive
		redir:=dir
		renameNoExt:=nameNoExt
		Run %plusxy_Path% a "%redir%\%reNameNoExt%.zip" "%xiaoyaoStr%"
		}

	
;保存到RunAny.ini为：
;7z解压|XiaoYao_plus[RA_plus](%getZz%,%"SmartZip.exe"%,4001)
;7z压缩|XiaoYao_plus[RA_plus](%getZz%,%"SmartZip.exe"%,4002)
;7z解压1|XiaoYao_plus[RA_plus](%getZz%,%"SmartZip.exe"%,4003)
;7z压缩1|XiaoYao_plus[RA_plus](%getZz%,%"SmartZip.exe"%,4004)
;7z分别压缩|XiaoYao_plus[RA_plus](%getZz%,%"SmartZip.exe"%,4005)

;IObitUnlocker解除占用功能-----------------------------------
	case 5001:		
		Run %plusxy_Path% /None %filebatch2%
	case 5002:		
		Run %plusxy_Path% /Delete %filebatch2%
	case 5003:		
		Run %plusxy_Path% /Copy %filebatch2% "D:\下载"
	case 5004:		
		Run %plusxy_Path% /Move %filebatch2% "D:\下载"
;保存到RunAny.ini为：
;解锁[#]|XiaoYao_plus[RA_plus](%getZz%,%"IObitUnlocker.exe"%,5001)
;删除[#]|XiaoYao_plus[RA_plus](%getZz%,%"IObitUnlocker.exe"%,5002)
;复制到D下载[#]|XiaoYao_plus[RA_plus](%getZz%,%"IObitUnlocker.exe"%,5003)
;移动到D下载[#]|XiaoYao_plus[RA_plus](%getZz%,%"IObitUnlocker.exe"%,5004)


	}
}

;托盘悬浮---------------------------------------------------------------------------
TaskbarTray2(){
;托盘悬浮|XiaoYao_plus[TaskbarTray2]()		
  CoordMode, Mouse, Screen
  MouseGetPos, X, Y
  IfWinActive, ahk_class NotifyIconOverflowWindow
    WinHide, ahk_class NotifyIconOverflowWindow
  Else
  {
    DetectHiddenWindows, On
    WinMove, ahk_class NotifyIconOverflowWindow, , %X%, %Y%
    WinShow, ahk_class NotifyIconOverflowWindow
    WinActivate, ahk_class NotifyIconOverflowWindow
    SetTimer, NIOFHide, 100
  }
Return
NIOFHide:
  IfWinNotActive, ahk_class NotifyIconOverflowWindow
  {
    WinHide, ahk_class NotifyIconOverflowWindow
    SetTimer, NIOFHide, OFF
  }
Return
	}

;生成随机密码---------------------------------------------------------------------------
;kind:类型 W大写 w小写 d数字 可以组合 length:长度
	RandomPass2(kind:="Wwd",length:=8){
		Clipboard:=	RandomPass(kind,length)
		ttip("生成成功并放入剪贴板",1000)
}

;══════════════════════════════════移动选中文件/文件夹到══════════════════════════════════	
movefile1(getZz,Des_path){	
		ttip("提示：跨盘区移动`n文件越大，等待时间越久",1000)
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr,name,dir
		rename1:=name
		redir:=dir
		FileMoveDir, %xiaoyaoStr%, %Des_path%\%rename1%	
		Run %ComSpec% /c "pushd "%redir%" && move /-Y "%rename1%" "%Des_path%""
}
		ttip("提示：`n如果目标目录存在`n同名文件/文件夹，将移动失败",7000)
}	
;══════════════════════════════════复制选中文件/文件夹到══════════════════════════════════	
copyfile1(getZz,Des_path){	
		ttip("提示：跨盘区移动`n文件越大，等待时间越久",1000)
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr,name,dir
		rename1:=name
		redir:=dir
		FileCopyDir, %xiaoyaoStr%, %Des_path%\%rename1%	
		Run %ComSpec% /c "pushd "%redir%" && xcopy /h /-y "%rename1%" "%Des_path%""
}
}		
;══════════════════════════════════只复制文件夹的骨架══════════════════════════════════	
copyfile2(getZz,Des_path){	
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr,name,dir
		rename1:=name
		redir:=dir
		RunWait, robocopy "%xiaoyaoStr%" "%Des_path%\%rename1%" /e /minage:19000101, , Hide
}
	ttip("复制成功",1000)
}	


;══════════════════════════════════ImageMagick功能══════════════════════════════════	
ImageMagick(getZz,plusxy_Path,formatExt,func){
    filebatch := getfiles(getZz)								;完整路径，(多选文件时，自动加上双引号""并空格隔开，  	示例："Path1" "Path2" "Path3")
	filedir :=""					; %filedir%				目录
Loop, parse, getZz, `n, `r, %A_Space%%A_Tab%
	{
		if(!A_LoopField)
			continue
		SplitPath, A_LoopField, name, dir, ext, nameNoExt, drive
		if(ext="lnk")
			FileGetShortcut, %A_LoopField%, lnkTarget, lnkDir, lnkArgs, lnkDesc, lnkIcon, lnkIconNum, lnkRunState
		filedir:=dir
	}
switch func
	{
	case 1:		
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr, name, dir, ext, nameNoExt, drive
		redir:=dir
		renameNoExt:=nameNoExt
		Run %plusxy_Path% convert "%xiaoyaoStr%" "%redir%\转换_%reNameNoExt%.%formatExt%", , Hide 
		}
		ttip("转换成功",1000)		
	case 2:		
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr, name, dir, ext, nameNoExt, drive
		redir:=dir
		renameNoExt:=nameNoExt
		renameExt:=ext
		Run %plusxy_Path% convert "%xiaoyaoStr%" -quality %formatExt% -strip "%redir%\压缩%formatExt%_%reNameNoExt%.%renameExt%", , Hide 
		}
		ttip("压缩成功",1000)
	case 3:		
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr, name, dir, ext, nameNoExt, drive
		redir:=dir
		renameNoExt:=nameNoExt
		renameExt:=ext
		Run %plusxy_Path% convert "%xiaoyaoStr%" -rotate %formatExt% "%redir%\旋转%formatExt%_%reNameNoExt%.%renameExt%", , Hide 
		}
		ttip("旋转成功",1000)		
	case 4:		
		Run %plusxy_Path% convert %filebatch% %formatExt% "%filedir%\%A_YYYY%%A_MM%%A_DD%_%A_Hour%%A_Min%%A_Sec%.jpg", , Hide 
		ttip("拼接成功",1000)		
	case 5:		
		Run %plusxy_Path% clipboard: "%formatExt%\剪贴_%A_YYYY%%A_MM%%A_DD%_%A_Hour%%A_Min%%A_Sec%.jpg", , Hide 
		ttip("保存成功",1000)	
	case 6:				
		Run %plusxy_Path% montage %filebatch% -geometry +10+10 -tile %formatExt% "%filedir%\高级拼接.jpg", , Hide 
		;Run %plusxy_Path% montage -mode concatenate -tile %formatExt% %filebatch%  -background white -geometry 300x200+10+10 "%filedir%\高级拼接.jpg", , Hide
		ttip("拼接成功",1000)
	case 7:		
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr, name, dir, ext, nameNoExt, drive
		redir:=dir
		renameNoExt:=nameNoExt
		renameExt:=ext
		Run %plusxy_Path% convert "%xiaoyaoStr%" -thumbnail %formatExt% "%redir%\缩略图%formatExt%_%reNameNoExt%.%renameExt%", , Hide 
		}
		ttip("生成成功",1000)		
	case 8:		
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr, name, dir, ext, nameNoExt, drive
		redir:=dir
		renameNoExt:=nameNoExt
		renameExt:=ext
		Run %plusxy_Path% convert "%xiaoyaoStr%" -resize %formatExt% "%redir%\尺寸%formatExt%_%reNameNoExt%.%renameExt%", , Hide 
		}
		ttip("尺寸调整成功",1000)
	case 9:		
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr, name, dir, ext, nameNoExt, drive
		redir:=dir
		renameNoExt:=nameNoExt
		Run %plusxy_Path% convert "%xiaoyaoStr%" -flatten -background white -alpha remove "%redir%\白色背景_%reNameNoExt%.%formatExt%", , Hide 
		}
		ttip("转换成功",1000)
		
	case 10:	
		InputBox, userInput, 请输入垂直拼接的统一宽度, 如想设置拼接的宽度为800，就输入：800`n`n提示：高度会按比例自动进行缩放，保持纵横比，无需设置, , ,200
		If Trim(userInput) = ""
	{

	}
if (userInput != "") {
MsgBox, 4, 提示, 是否添加文件名水印？（不支持中文名的图片）
IfMsgBox Yes 
{
	Runwait %ComSpec% /c pushd "%filedir%" && md "临时存放_xiaoyao", , Hide
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr, name, dir, ext, nameNoExt, drive
		rename11:=name
		redir:=dir
		renameNoExt:=nameNoExt
		output1 = `"%dir%`\临时存放_xiaoyao`\暂时%name%`"
		output2 = `"%dir%`\临时存放_xiaoyao`\%name%`"
		fname_list .= A_Space output2
		Runwait %plusxy_Path% convert "%xiaoyaoStr%" -resize %userInput%x %output1%, , Hide 
		Runwait %plusxy_Path% convert %output1% -background white -fill black -pointsize 20 -gravity north -splice 0x27 -annotate +0+5 "%nameNoExt%" %output2%, , Hide 
		}
		Runwait %plusxy_Path% convert %fname_list% -append "%filedir%\%A_YYYY%%A_MM%%A_DD%_%A_Hour%%A_Min%%A_Sec%.jpg", , Hide
		output3 = %filedir%`\临时存放_xiaoyao
		FileRemoveDir, %output3%, 1
				ttip("拼接成功",1000)
} 
else
{
Runwait %ComSpec% /c pushd "%filedir%" && md "临时存放_xiaoyao", , Hide
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr, name, dir, ext, nameNoExt, drive
		rename11:=name
		redir:=dir
		renameNoExt:=nameNoExt
		output1 = `"%dir%`\临时存放_xiaoyao`\%name%`"
		fname_list .= A_Space output1
		Runwait %plusxy_Path% convert "%xiaoyaoStr%" -resize %userInput%x %output1%, , Hide 
		}
		Runwait %plusxy_Path% convert %fname_list% -append "%filedir%\%A_YYYY%%A_MM%%A_DD%_%A_Hour%%A_Min%%A_Sec%.jpg", , Hide
		output3 = %filedir%`\临时存放_xiaoyao
		FileRemoveDir, %output3%, 1
				ttip("拼接成功",1000)
}												
}
	case 11:	
		InputBox, userInput, 请输入水平拼接的统一高度, 如想设置拼接的高度为800，就输入：800`n`n提示：宽度会按比例自动进行缩放，保持纵横比，无需设置, , ,200
		If Trim(userInput) = ""
	{

	}
if (userInput != "") {
MsgBox, 4, 提示, 是否添加文件名水印？（不支持中文名的图片）
IfMsgBox Yes 
{
	Runwait %ComSpec% /c pushd "%filedir%" && md "临时存放_xiaoyao", , Hide
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr, name, dir, ext, nameNoExt, drive
		rename11:=name
		redir:=dir
		renameNoExt:=nameNoExt
		output1 = `"%dir%`\临时存放_xiaoyao`\暂时%name%`"
		output2 = `"%dir%`\临时存放_xiaoyao`\%name%`"
		fname_list .= A_Space output2
		Runwait %plusxy_Path% convert "%xiaoyaoStr%" -resize x%userInput% %output1%, , Hide 
		Runwait %plusxy_Path% convert %output1% -background white -fill black -pointsize 20 -gravity north -splice 0x27 -annotate +0+5 "%nameNoExt%" %output2%, , Hide 
		}
		Runwait %plusxy_Path% convert %fname_list% +append "%filedir%\%A_YYYY%%A_MM%%A_DD%_%A_Hour%%A_Min%%A_Sec%.jpg", , Hide
		output3 = %filedir%`\临时存放_xiaoyao
		FileRemoveDir, %output3%, 1
		ttip("拼接成功",1000)
} 
else 
{
Runwait %ComSpec% /c pushd "%filedir%" && md "临时存放_xiaoyao", , Hide
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr, name, dir, ext, nameNoExt, drive
		rename11:=name
		redir:=dir
		renameNoExt:=nameNoExt
		output1 = `"%dir%`\临时存放_xiaoyao`\%name%`"
		fname_list .= A_Space output1
		Runwait %plusxy_Path% convert "%xiaoyaoStr%" -resize x%userInput% %output1%, , Hide 
		}
		Runwait %plusxy_Path% convert %fname_list% +append "%filedir%\%A_YYYY%%A_MM%%A_DD%_%A_Hour%%A_Min%%A_Sec%.jpg", , Hide
		output3 = %filedir%`\临时存放_xiaoyao
		FileRemoveDir, %output3%, 1
		ttip("拼接成功",1000)
}												
}
case 12:
	InputBox, userInput, 请输入需要生成的图片尺寸, 示例：`n800x600`n如只想指定宽度为800像素，而高度则按比例自动调整`n800x`n如只想指定高度为600像素，而宽度则按比例自动调整`nx600`n如果希望强制将图像拉伸到指定尺寸，可以在尺寸参数后添加感叹号`n800x600`!, , ,300 , , , , ,800x600
		If Trim(userInput) = ""
	{

	}
	if (userInput != "") {
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr, name, dir, ext, nameNoExt, drive
		redir:=dir
		renameNoExt:=nameNoExt
		renameExt:=ext
		Run %plusxy_Path% convert "%xiaoyaoStr%" -resize %userInput% "%redir%\尺寸%userInput%_%reNameNoExt%.%renameExt%", , Hide 
		}
		ttip("尺寸调整成功",1000)
}
case 13:
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr, name, dir, ext, nameNoExt, drive
		redir:=dir
		renameNoExt:=nameNoExt
		renameExt:=ext
		Run %plusxy_Path% convert "%xiaoyaoStr%" %formatExt% "%redir%\镜像旋转%formatExt%_%reNameNoExt%.%renameExt%", , Hide 
		}
		ttip("旋转成功",1000)
case 15:		
		InputBox, userInput, 请输入合并pdf的统一宽度, 如想设置合并pdf的宽度为800，就输入：800`n`n提示：高度会按比例自动进行缩放，保持纵横比，无需设置, , ,200
		If Trim(userInput) = ""
	{

	}
		if (userInput != "") {
		Runwait %ComSpec% /c pushd "%filedir%" && md "临时存放_xiaoyao", , Hide
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr, name, dir, ext, nameNoExt, drive
		rename11:=name
		redir:=dir
		renameNoExt:=nameNoExt
		output1 = `"%dir%`\临时存放_xiaoyao`\%name%`"
		fname_list .= A_Space output1
		Runwait %plusxy_Path% convert "%xiaoyaoStr%" -resize %userInput%x -density 0 %output1%, , Hide 
		}
		Runwait %plusxy_Path% convert %fname_list% "%filedir%\%A_YYYY%%A_MM%%A_DD%_%A_Hour%%A_Min%%A_Sec%.pdf", , Hide
		output3 = %filedir%`\临时存放_xiaoyao
		FileRemoveDir, %output3%, 1
		ttip("合并成功",1000)
		}
case 17:		
		Run %plusxy_Path% convert -delay %formatExt% -loop 0 %filebatch% "%filedir%\%A_YYYY%%A_MM%%A_DD%_%A_Hour%%A_Min%%A_Sec%.gif", , Hide 
		ttip("保存成功",1000)	
case 18:
			InputBox, userInput, 请输入高级拼接的格式, 示例：3排3列就输入3x3, , , , , , , ,3x3
		If Trim(userInput) = ""
	{

	}
if (userInput != "") {
MsgBox, 4, 提示, 是否添加文件名水印？（不支持中文名的图片）
IfMsgBox Yes 
{
	Runwait %ComSpec% /c pushd "%filedir%" && md "临时存放_xiaoyao", , Hide
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr, name, dir, ext, nameNoExt, drive
		rename11:=name
		redir:=dir
		renameNoExt:=nameNoExt
		output1 = `"%dir%`\临时存放_xiaoyao`\暂时%name%`"
		output2 = `"%dir%`\临时存放_xiaoyao`\%name%`"
		fname_list .= A_Space output2
		Runwait %plusxy_Path% convert "%xiaoyaoStr%" -resize 340x313 -background white -gravity center -extent 340x313 %output1%, , Hide 
		Runwait %plusxy_Path% convert %output1% -background white -fill black -pointsize 20 -gravity south -splice 0x27 -annotate +0+5 "%nameNoExt%" %output2%, , Hide 
		}
		Runwait %plusxy_Path% montage %fname_list% -geometry +10+10 -tile %userInput% "%filedir%\%A_YYYY%%A_MM%%A_DD%_%A_Hour%%A_Min%%A_Sec%.jpg", , Hide 
		output3 = %filedir%`\临时存放_xiaoyao
		FileRemoveDir, %output3%, 1
				ttip("拼接成功",1000)
} 
else
{
Runwait %ComSpec% /c pushd "%filedir%" && md "临时存放_xiaoyao", , Hide
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr, name, dir, ext, nameNoExt, drive
		rename11:=name
		redir:=dir
		renameNoExt:=nameNoExt
		output1 = `"%dir%`\临时存放_xiaoyao`\%name%`"
		fname_list .= A_Space output1
		Runwait %plusxy_Path% convert "%xiaoyaoStr%" -resize 340x313 -background white -gravity center -extent 340x313 %output1%, , Hide 
		}
		Runwait %plusxy_Path% montage %fname_list% -geometry +10+10 -tile %userInput% "%filedir%\%A_YYYY%%A_MM%%A_DD%_%A_Hour%%A_Min%%A_Sec%.jpg", , Hide 
		output3 = %filedir%`\临时存放_xiaoyao
		FileRemoveDir, %output3%, 1
				ttip("拼接成功",1000)
}												
}			
						
}
}	
;══════════════════════════════════ffmpeg功能══════════════════════════════════	
ffmpeg(getZz,plusxy_Path,formatExt,func){
    filebatch := getfiles(getZz)								;完整路径，(多选文件时，自动加上双引号""并空格隔开，  	示例："Path1" "Path2" "Path3")
	filedir :=""					; %filedir%				目录
	fileExt :=""					; %fileExt%				后缀
	fileNameNoExt :=""				; %fileNameNoExt%		无后缀名称
	filebatch7 := getfiles7(getZz)
Loop, parse, getZz, `n, `r, %A_Space%%A_Tab%
	{
		if(!A_LoopField)
			continue
		SplitPath, A_LoopField, name, dir, ext, nameNoExt, drive
		if(ext="lnk")
			FileGetShortcut, %A_LoopField%, lnkTarget, lnkDir, lnkArgs, lnkDesc, lnkIcon, lnkIconNum, lnkRunState
		filedir:=dir
		fileExt:=ext
		fileNameNoExt:=nameNoExt
	}
switch func
	{
	case 1:		
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr, name, dir, ext, nameNoExt, drive
		redir:=dir
		renameNoExt:=nameNoExt
		RunWait %plusxy_Path% -i "%xiaoyaoStr%" -c:v copy -c:a copy -y "%redir%\转换_%reNameNoExt%.%formatExt%"
		}
		ttip("转换成功",1000)
	case 2:		
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr, name, dir, ext, nameNoExt, drive
		redir:=dir
		renameNoExt:=nameNoExt
		renameExt:=ext
		RunWait %plusxy_Path% -i "%xiaoyaoStr%" -af "volume=%formatExt%" -y "%redir%\%reNameNoExt%_%formatExt%.%renameExt%"
		}
		ttip("转换成功",1000)
	case 3:		
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr, name, dir, ext, nameNoExt, drive
		redir:=dir
		renameNoExt:=nameNoExt
		renameExt:=ext
		RunWait %plusxy_Path% -i "%xiaoyaoStr%" -y "%redir%\转换_%reNameNoExt%.%formatExt%"
		}
		ttip("转换成功",1000)
	case 4:		
		ttip("正在提取`n温馨提示`n音轨文件越大`n抽取时间越久",7000)
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr, name, dir, ext, nameNoExt, drive
		redir:=dir
		renameNoExt:=nameNoExt
		renameExt:=ext
		RunWait %plusxy_Path% -i "%xiaoyaoStr%" -map 0:a:0 -c:a copy -y "%redir%\%reNameNoExt%_音频1.wav"
		RunWait %plusxy_Path% -i "%xiaoyaoStr%" -map 0:a:1 -c:a copy -y "%redir%\%reNameNoExt%_音频2.wav"
		RunWait %plusxy_Path% -i "%xiaoyaoStr%" -map 0:a:2 -c:a copy -y "%redir%\%reNameNoExt%_音频3.wav", , Hide
		RunWait %plusxy_Path% -i "%xiaoyaoStr%" -map 0:a:3 -c:a copy -y "%redir%\%reNameNoExt%_音频4.wav", , Hide
		}
		ttip("提取成功",1000)
	case 5:		
		ttip("正在提取`n温馨提示`n字幕文件越大`n抽取时间越久",7000)
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr, name, dir, ext, nameNoExt, drive
		redir:=dir
		renameNoExt:=nameNoExt
		renameExt:=ext
		RunWait %plusxy_Path% -i "%xiaoyaoStr%" -map 0:s:0 -y "%redir%\%reNameNoExt%_字幕1.ass", , Hide
		RunWait %plusxy_Path% -i "%xiaoyaoStr%" -map 0:s:1 -y "%redir%\%reNameNoExt%_字幕2.ass", , Hide
		RunWait %plusxy_Path% -i "%xiaoyaoStr%" -map 0:s:2 -y "%redir%\%reNameNoExt%_字幕3.ass", , Hide
		RunWait %plusxy_Path% -i "%xiaoyaoStr%" -map 0:s:3 -y "%redir%\%reNameNoExt%_字幕4.ass", , Hide
		RunWait %plusxy_Path% -i "%xiaoyaoStr%" -map 0:s:4 -y "%redir%\%reNameNoExt%_字幕5.ass", , Hide
		RunWait %plusxy_Path% -i "%xiaoyaoStr%" -map 0:s:5 -y "%redir%\%reNameNoExt%_字幕6.ass", , Hide
		RunWait %plusxy_Path% -i "%xiaoyaoStr%" -map 0:s:6 -y "%redir%\%reNameNoExt%_字幕7.ass", , Hide
		RunWait %plusxy_Path% -i "%xiaoyaoStr%" -map 0:s:7 -y "%redir%\%reNameNoExt%_字幕8.ass", , Hide
		RunWait %plusxy_Path% -i "%xiaoyaoStr%" -map 0:s:8 -y "%redir%\%reNameNoExt%_字幕9.ass", , Hide	
		RunWait %plusxy_Path% -i "%xiaoyaoStr%" -map 0:s:9 -y "%redir%\%reNameNoExt%_字幕10.ass", , Hide
		}
		ttip("提取成功",1500)
	case 6:		
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr, name, dir, ext, nameNoExt, drive
		redir:=dir
		renameNoExt:=nameNoExt
		renameExt:=ext
		RunWait %plusxy_Path% -i "%xiaoyaoStr%" -c:v libx264 -crf 23 -preset medium -c:a copy "%redir%\压缩_%reNameNoExt%.mp4"
		}
		ttip("转换成功",1000)
	case 7:		
		Loop, parse, getZz, `n, `r
   	 	{
       		 xiaoyaoStr:=A_LoopField
		SplitPath, xiaoyaoStr, name, dir, ext, nameNoExt, drive
		redir:=dir
		renameNoExt:=nameNoExt
		renameExt:=ext
		RunWait %plusxy_Path% -i "%xiaoyaoStr%" -c:v copy -an "%redir%\无声_%reNameNoExt%.%renameExt%"
		}
		ttip("转换成功",1000)
	case 8:	
		RunWait %plusxy_Path% %filebatch7% -c:v copy -c:a copy "%filedir%\合并视频.mp4"

}
	}
;══════════════════════════════════将选中文件内容保存为文本文件══════════════════════════════════
;将选中文字保存为文本文件[默认保存到桌面]，自动抓取选中文字的前面5个字符作为文件名。	
Storetext(getZz,plusxy_Path,formatExt){
		clip:= getZz
		StringReplace, First, clip, `r`n, , All	;将剪贴板中的换行符 rn 替换为空，以便生成文件名
		StringLeft,First,First,5	;将前 5 个字符赋给 First 变量作为文件名的一部分
		FileAppend, %clip%, %formatExt%\%First%_%A_YYYY%%A_MM%%A_DD%_%A_Hour%%A_Min%%A_Sec%.txt		;将剪贴板的内容追加到指定路径的文本文件中，文件名由 First 和 .txt 组成
		RunWait %plusxy_Path% "%formatExt%\%First%_%A_YYYY%%A_MM%%A_DD%_%A_Hour%%A_Min%%A_Sec%.txt"
}	
	

;══════════════════════════════════RA_plus2:直接在ini里可编辑的功能══════════════════════════════════	
	;RA_plus2处理
	RA_plus2(getZz:="", RA_Path:="", commond:="", param:="", isBatch := 0){
		commond := RA_Path " " commond
		this.dealMyfunc(getZz, commond, param, isBatch)
	}
	
	;RA_plus2处理
	RA_plus2Box(getZz:="", RA_Path:="", commond:="", param:="", MsgTitles :="", MsgKes := "", isBatch := 0){
		
		msgKeyList := StrSplit(MsgKes, "|")
		MsgTitleList := StrSplit(MsgTitles, "|")
		For index, key in msgKeyList {
			InputBox, OutputVar , % MsgTitleList[index] , , , , , , , zh-CN, , 
			if(StrLen(OutputVar) == 0) {
				MsgBox, , 警告, 输入信息为空, 2000
				Return
			}
			commond := StrReplace(commond, key, OutputVar)
			param := StrReplace(param, key, OutputVar)
		}
		; MsgBox, % commond "`n" param
		commond := RA_Path " " commond
		this.dealMyfunc(getZz, commond, param, isBatch)
	}
	;任务处理
	dealMyfunc(path, commond, param, isBatch := 0){
		if(isBatch) {
			textResult:=""
			Loop, parse, path, `n, `r, %A_Space%%A_Tab%
			{
				if(!A_LoopField)
					continue
				SplitPath, A_LoopField, name, dir, ext, nameNoExt
				textResult.= """" A_LoopField """ "
			}
			RunCommond(textResult, name, dir, ext, nameNoExt, param, commond)
		} else {
			Loop, parse, path, `n, `r, %A_Space%%A_Tab%
			{
				if(!A_LoopField)
					continue
				SplitPath, A_LoopField, name, dir, ext, nameNoExt
				textResult := """" A_LoopField """ "
				RunCommond(textResult, name, dir, ext, nameNoExt, param, commond)
			}
		}
	}
;══════════════════════════════════隐藏/显示桌面图标══════════════════════════════════	
HideOrShowDesktop()
{
	ControlGet, class, Hwnd,, SysListView321, ahk_class Progman
	If class =
		ControlGet, class, Hwnd,, SysListView321, ahk_class WorkerW
 
	If DllCall("IsWindowVisible", UInt,class)
		WinHide, ahk_id %class%
	Else
		WinShow, ahk_id %class%
}
;══════════════════════════════════隐藏/显示任务栏══════════════════════════════════
ToggleTaskbar()
{
    ; 获取任务栏窗口句柄
    WinGet, taskbarHwnd, ID, ahk_class Shell_TrayWnd
    
    ; 判断任务栏可见性
    if DllCall("IsWindowVisible", "UInt", taskbarHwnd)
    {
        ; 隐藏任务栏
        WinHide, ahk_id %taskbarHwnd%
    }
    else
    {
        ; 显示任务栏
        WinShow, ahk_id %taskbarHwnd%
    }
}
;══════════════════════════════════文字竖排══════════════════════════════════
Texttest1(getZz)
{
text := getZz
verticalText := ""
Loop, Parse, text
{
    word := Trim(A_LoopField)

    Loop, Parse, word
    {
        character := Trim(A_LoopField)
        verticalText .= character . "`n"
    }

    ;verticalText .= "`n"
}
ClipSaved := ClipboardAll  ; 保存剪贴板内容
Clipboard := verticalText  ; 将竖排后的文字复制到剪贴板

; 发送快捷键 Ctrl + V，将竖排后的文字粘贴到选中的区域，并替换掉原有的选中文字
SendInput ^v
ClipWait  ; 等待剪贴板数据被粘贴

Clipboard := ClipSaved  ; 还原剪贴板内容
ClipSaved := ""  ; 清空剪贴板保存的内容
}
;══════════════════════════════════ReNamer功能══════════════════════════════════
ReNamer(getZz,plusxy_Path,rnp_Path, func)
{
	filebatch := getfiles(getZz)
switch func
	{
	case 1:
		Run %plusxy_Path% /enqueue %filebatch%
	case 2:
		Run %plusxy_Path% /preset "%rnp_Path%" %filebatch%
	case 3:
		Run %plusxy_Path% /preset "%rnp_Path%" %filebatch%
	case 4:
		Run %plusxy_Path% /preset "%rnp_Path%" %filebatch%		
}
}
;══════════════════════════════════创建新文件夹══════════════════════════════════
Batch_file1()
{
MsgBox, 4, 请选择要创建的类型, `n文件夹（选择是）`n`n 文件（选择否）
        if ErrorLevel
            return
IfMsgBox Yes 
    {
        InputBox, 文件夹名称, , 文件夹名称：, , 300, 123, ,,,,新建文件夹
        if ErrorLevel
            return

        InputBox, 文件夹个数, , 创建文件夹个数：, , 300, 123
        if ErrorLevel
            return

InputBox, 存放路径, , 输入存放路径：, , 300, 123
if ErrorLevel
    return

        Loop, %文件夹个数%
        {
            FileCreateDir % 存放路径 "\" 文件夹名称 A_index
        }
    }
else
{
        InputBox, 文件名, , 文本文件名：, , 300, 123, ,,,,新建文本文件
        if ErrorLevel
            return
        InputBox, 文件格式, , 输入文件格式：, , 300, 123, ,,,,txt
        if ErrorLevel
            return            
        InputBox, 文件个数, , 创建文件个数：, , 300, 123
        if ErrorLevel
            return
        InputBox, 存放路径, , 输入存放路径：, , 300, 123
        if ErrorLevel
            return
        Loop, %文件个数%
        {
        FileAppend, , % 存放路径 "\" 文件名 A_index "." 文件格式
        }
    }

    Gui, Destroy
return
}
;══════════════════════════════════文字反转══════════════════════════════════
ReverseString1(getZz)
{
	 reversedText := ReverseString(getZz)
	 ClipSaved := ClipboardAll  ; 保存剪贴板内容
	 Clipboard := reversedText
	 ; 发送快捷键 Ctrl + V，将竖排后的文字粘贴到选中的区域，并替换掉原有的选中文字
SendInput ^v
ClipWait  ; 等待剪贴板数据被粘贴

Clipboard := ClipSaved  ; 还原剪贴板内容
ClipSaved := ""  ; 清空剪贴板保存的内容
}
;══════════════════════════════════文档定位══════════════════════════════════
locationpath(plusxy_Path)
{
WinGetActiveTitle, str
str := StrReplace(str, "[只读]", "")
str := StrReplace(str, "[兼容模式]", "")
;MsgBox % str

IfWinActive ahk_exe Notepad2.exe
{
    result := RegExMatch(str, ".*(?=\s\[.*\])", match)
;MsgBox % match

run %plusxy_Path% -s "%match% !.lnk !.url"
}
else if WinActive("ahk_exe Notepad3.exe")
{
    result := RegExMatch(str, ".*(?=\s\[.*\])", match)
;MsgBox % match
run %plusxy_Path% -s "%match% !.lnk !.url"
}
else
{
regex := "(.*)\s-\s.*"
result := RegExReplace(str, regex, "$1")
;MsgBox % result
run %plusxy_Path% -s "%result% !.lnk !.url"
}
}
;══════════════════════════════════BCompare比较选中文字和剪贴板文字══════════════════════════════════
bcompare(getZz,plusxy_Path,func){
		filebatch := getfiles(getZz)

switch func
	{
	case 1:	
		Runwait %ComSpec% /c pushd "%A_MyDocuments%" && md "临时存放_xiaoyao", , Hide	;在 我的文档 目录下建立一个临时文件夹
		clip:= getZz
		FileAppend, %clip%, %A_MyDocuments%\临时存放_xiaoyao\文本1.txt		;将选中文字的内容追加到指定路径的文本文件中
		clip2:= clipboard
		FileAppend, %clip2%, %A_MyDocuments%\临时存放_xiaoyao\文本2.txt		;将选中文字的内容追加到指定路径的文本文件中
		run %plusxy_Path% "%A_MyDocuments%\临时存放_xiaoyao\文本1.txt" "%A_MyDocuments%\临时存放_xiaoyao\文本2.txt" ;执行比较命令
		Sleep, 2000  ; 等待 2000 毫秒，即 2 秒
		FileRemoveDir, %A_MyDocuments%`\临时存放_xiaoyao, 1	;删除临时文件夹
	case 2:
		run %plusxy_Path% %filebatch%
}	
}
;══════════════════════════════════cpdf功能══════════════════════════════════	

;══════════════════════════════════下一个功能══════════════════════════════════

;══════════════════════════════════下一个功能══════════════════════════════════
}


;-----------------------------------【辅助函数】---------------------------------------------------------------------------
;检测软件是否开启，如果开启则跳过，否则开启
detectApp(exe:="",path:="",waitTime=3){
	If (exe!=""){
		Process,Exist,%exe%
		if(ErrorLevel=0)
		{
			Run,%path%
			ToolTip, %exe%启动中
			WinWaitActive , ahk_exe %exe%, ,%waitTime%
		}
	}
	ToolTip
	Sleep, 100
}


Label_ClearMEM: ;清理内存
	pid:=() ? DllCall("GetCurrentProcessId") : pid
	h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
	DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
	DllCall("CloseHandle", "Int", h)
Return


ttip(text,time){
	ToolTip,%text%
	sleep %time%
	ToolTip
Return
}

;══════════════════════════多选时，自动加上双引号""并空格隔开，  	示例："Path1" "Path2" "Path3"══════════════════════════════════
getfiles(getZz){
		files := ""
		line := getZz
		Loop, parse, line , `n, `r
		{
				files := files " """ A_LoopField """"
		}
		if(StrLen(files) < 1) {
			Return
		}
   Return files
}

;══════════════════════════多选时，自动加上双引号""并逗号,隔开  	示例："Path1","Path2","Path3"══════════════════════════════════
getfiles2(getZz){
		files := ""
		line := getZz
		Loop, parse, line , `n, `r
		{
				files := files ",""" A_LoopField """"
		}
		if(StrLen(files) < 1) {
			Return
		}
   Return files
}

;══════════════════════════多选时，逗号,加空格隔开  	示例：Path1, Path2, Path3══════════════════════════════════
getfiles3(getZz){
		files := ""
		line := getZz
		Loop, parse, line , `n, `r
		{
				files := files ", " A_LoopField
		}
		if(StrLen(files) < 1) {
			Return
		}
   Return files
}
;══════════════════════════多选时，逗号,加空格隔开  	示例：-i Path1, Path2, Path3══════════════════════════════════
getfiles7(getZz){
		files := ""
		line := getZz
		Loop, parse, line , `n, `r
		{
				files := files "-i """ A_LoopField """" " "
		}
		if(StrLen(files) < 1) {
			Return
		}
   Return files
}


;═════════════════════════当前窗口的路径获取══════════════════════════
ShellFolder(hWnd=0)
{
If   hWnd || (hWnd :=   WinExist("ahk_class (?:Cabinet|Explore)WClass"))
   {
      For window in ComObjCreate("Shell.Application").Windows
         doc :=   window.Document
      Until   (window.hWnd = hWnd)
}
      
      sFolder :=   doc.folder.self.path, sFocus :=   doc.focuseditem.name

      Return   sFolder
   }	
   
   
;═════════════════════════第二种方法：当前窗口的路径获取══════════════════════════
;需要 文件夹选项-查看-勾选"在标题栏中显示完整路径"
getfiles4(){

	WinGetTitle, this_title, ahk_class CabinetWClass 
	folder := this_title
if (folder = "文档")
{
    folder := A_MyDocuments
}
else if (folder = "此电脑","回收站", "网上邻居", "控制面板", "我的电脑","快速访问","主文件夹")
{
    folder := "c:\Windows"
}
else if (folder = "图片")
{
    folder := getSpec("My Pictures")
}
else if (folder = "桌面")
{
    folder := getSpec("Desktop")
}
else if (folder = "视频","库\视频")
{
    folder := getSpec("My Video")
}
else if (folder = "音乐","库\音乐")
{
    folder := getSpec("My Music")
}
else if (folder = "下载")
{
    folder := getSpec("{7D83EE9B-2244-4E70-B1F5-5393042AF1E4}")
}
else if (folder = "收藏")
{
    folder := getSpec("Favorites")
}
else if (folder = "OneDrive")
{
    folder := getSpec("{24D89E24-2F19-4534-9DDE-6A6671FBB8FE}")
}
else if (folder = "图库")
{
    folder := getSpec("My Pictures")
}

return folder
}	

;══════════════════════════从注册表获取特殊路径══════════════════════════════════
getSpec(str)
{
	Loop, Reg, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders, KVR
	{
		 if a_LoopRegType = key
			value =
		else
		{
			RegRead, value
			if ErrorLevel
				value = *error*
		}
		;~ MsgBox, 4, , %a_LoopRegName% = %value% (%a_LoopRegType%)`n`nContinue?
		;~ IfMsgBox, NO, break
		if (a_LoopRegName=str)  ;桌面在注册表中为Desktop，注意加上引号
			break
	}
	;~ dir:=ParseCmdLine(value)
	;~ StringTrimRight,UserProfileDir, A_AppData, 16 
	;~ StringReplace, dir, value, `%USERPROFILE`%, % UserProfileDir, All
	Transform,dir,Deref,%value%
	return dir
}
/*
;功能： 从注册表获取特殊路径,此方法以支持以下特殊路径，AutoHotkey虽然支持一些特殊路径但还是不全。
;原理：遍历HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders
;可获得路径包括以下特殊位置
CD Burning
PrintHood
{374DE290-123F-4565-9164-39C4925E467B}
Templates
Start Menu
Startup
SendTo
Recent
Programs
Personal
NetHood
My Video
My Pictures
My Music
Local AppData
History
Favorites
Desktop
Cookies
Cache
AppData
*/

;══════════════════════════════════[复制选中文件路径]HuiZz v1.0.7══════════════════════════════════
	;复制文件说明：path路径, name名称, dir目录, ext后缀, nameNoExt无后缀名称, drive盘符
	;复制快捷方式说明：lnkTarget指向路径, lnkDir指向目录, lnkArgs参数, lnkDesc注释, lnkIcon图标文件名, lnkIconNum图标编号, lnkRunState初始运行方式
system_file_path_zz(getZz,copy:=""){
		textResult:=""
		Loop, parse, getZz, `n, `r, %A_Space%%A_Tab%
		{
			if(!A_LoopField)
				continue
			SplitPath, A_LoopField, name, dir, ext, nameNoExt, drive
			if(ext="lnk")
				FileGetShortcut, %A_LoopField%, lnkTarget, lnkDir, lnkArgs, lnkDesc, lnkIcon, lnkIconNum, lnkRunState
			textResult.=(copy="path") ? A_LoopField "`n" : %copy% "`n"
		}
		xiaoyaopath:=Trim(textResult, ",`n ")
		return xiaoyaopath
	}

;══════════════════════════════════生成随机密码══════════════════════════════════	
RandomPass(kind:="Wwd",length:=8){
;类型 W大写 w小写 d数字 可以组合
char := [1,2,3,4,5,6,7,8,9,"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",0,1,2,3,4,5,6,7,8,9]
char[0] := 0 ;定义数组
option := kind
kind = 0 ;必须先赋值  不然后面的加法无效
kind := InStr(option,"W",1) ? kind+100 : kind ;InStr区分大小写
kind := InStr(option,"w",1) ? kind+10 : kind
kind := InStr(option,"d") ? kind+1 : kind
if kind=111
	min:=0,max:=61
else if kind=110
	min:=10,max:=61
else if kind=11
	min:=0,max:=35
else if kind=101
	min:=36,max:=71
else if kind=1
	min:=0,max=9
else if kind=10
	min:=10,max=35
else if kind=100
	min:=36,max=61
loop % length
{
Random, l, %min%, %max%
str .= char[l]
}
return str
}
;══════════════════════════════════RA_plus2:直接在ini里可编辑的功能══════════════════════════════════	
RunCommond(path, name, dir, ext, nameNoExt, param, commond) {
	allValue := { "path": path, "name": name, "dir": dir, "ext": ext, "nameNoExt": nameNoExt}
	paramList := StrSplit(param, "|")
	for index, pair in paramList
	{
		; 拆分键值对，获取键和值
		keyValue := StrSplit(pair, "=")
		key := keyValue[1]
		tvalue := keyValue[2]
		paramValue := StrSplit(tvalue, "#")
		facValue := ""
		for idx, pv in paramValue
		{
			remainder := Mod(idx, 2)
			if(remainder == 0) {
				facValue.= allValue[pv]
			} else {
				facValue.= pv
			}
		}
		if(InStr(tvalue, "path") == 0) {
			facValue := """" facValue """"
		}
		; 输出当前键和值
		; MsgBox % "Key: " . key . "--Value: " . facValue
		commond := StrReplace(commond, key, facValue)
	}
	; MsgBox, % commond
	RunWait, % commond
	; SetTimer, RemoveToolTip, -5000
	; return
}
;══════════════════════════════════选中文字反转══════════════════════════════════	
; 定义一个函数，用于反转字符串
ReverseString(str) {
    reversed := ""
    Loop, Parse, str
    {
        reversed := A_LoopField . reversed
    }
    return reversed
}
