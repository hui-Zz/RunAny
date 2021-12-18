;*************************************************
; 【RA搜索框：搜索菜单项，后缀菜单、自定义搜索等】
;*************************************************
;tong
/*1.使用方法：
	1.下载安装【RunAny】 https://hui-zz.gitee.io/runany/#/
	2.将【tong_SearchBar.ahk】、【Lib】添加至【RunAny】的【RunPlugins】文件夹，在RunAny中【开启】并设置为【自启】
		Lib文件夹存放的是汉字转拼音功能
	3.打开RunAny.ini或RunAny2.ini文件，添加以下内容，可自定义快捷键，下列是shift+D开启
		RA搜索栏	+d|RunAny_SearchBar[toggle_searchBar]()
	4.使用3中快捷键开启

  2.使用说明：
	1.当候选项当候选项剩下一个时，自动填充 is_auto_fill，可关闭
	2.加号可移动搜索框
	3.双击提示框可执行
	4.有候选项是回车执行第一个
	5.可以选择是否自动为大写，is_auto_CapsLock ，可关闭
	6.自动填充后是否禁用一段时间输入，Edit_stop_time，可选择

  3.快捷键说明：
	1.tab键正序切换功能，右shift逆序切换功能
	2.alt快速选择第1个候选项，alt+1、2、3。。。9分别快速选择第1-9对应候选项
	3.Delete快速清空
	4.上下键快速选择提示框

  4.添加功能说明：
	1.【自定义样式】Radio_names中添加对应功能名称
	2.【自定义样式】RA_suffix、RA_menu在Radio_names中的对应位置，如未调整顺序则为默认
	3.【单选框对应功能】中按序号添加对应功能
;-----------------------------------------【更新说明】-----------------------------------------
v1.0.3: 2021年12月
	1.添加拼音搜索和首字母搜索(基于kazhafeizhale的ChToPy脚本),同时RA菜单项值匹配菜单项名称，不再匹配路径
	2.不再使用onMessage.ahk
*/

global RunAny_Plugins_Version:="1.0.3"
global RunAny_Plugins_Icon:="shell32.dll,23"
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
#Include %A_ScriptDir%\RunAny_ObjReg.ahk
;https://www.autoahk.com/archives/37300 汉字转拼音，不需要则删除下面两行
#Include %A_ScriptDir%\Lib\ChToPy.ahk
ChToPy.log4ahk_load_all_dll_path()

;----------------------------------------【RA插件功能】----------------------------------------
class RunAnyObj {
	;RA搜索栏	+d|RunAny_SearchBar[toggle_searchBar]()
	toggle_searchBar(){
		Gosub, toggleSearchBar
	}
}
;----------------------------------------【自定义样式】----------------------------------------
Label_Custom:
	;搜索框样式
	global x_pos := 0								;搜索框x轴位置，0默认为中心位置
	global y_pos := A_ScreenHeight*0.2				;搜索框y轴位置
	global is_fixed := 1							;1表示每次打开搜索框都固定位置，0表示每次打开搜索框都为上次位置
	global Edit_color := "black"					;输入框字体颜色
	global Edit_text_size := 25						;输入框字体大小
	global Edit_trans := 220						;输入框字体透明度
	global Edit_width := 800						;输入框宽度

	;上方单选框样式
	global Radio_un_color := "black"				;单选框控件未选中时字体颜色
	global Radio_un_text_size := 14					;单选框控件未选中时字体大小
	global Radio_color := "1e90ff"					;单选框控件选中时字体颜色
	global Radio_text_size := Radio_un_text_size+1	;单选框控件未选中时字体大小
	;上方单选框对应功能
	global Radio_names := ["RA后缀菜单","RA菜单项","百度一下"]	;上方选项的单选框控件ID-设置项
	global RA_suffix := 1							;RA后缀菜单 在Radio_names中的位置，默认为1，与上面对应
	global RA_menu := 2								;RA菜单项 在Radio_names中的位置，默认为2，与上面对应
	global Radio_Default := 2						;默认单选框

	;提示框样式
	global ListView_text_size := 12					;提示框字体
	global ListView_h := 25.2						;提示框单列高度：10-21.5；11-24.2；12-25.2；13-27.2；14-29.2；15-32.2；16-34.2；17-35.2；18-36.2；19-39.2；20-41.2
	global Candidates_num_max := 50					;候选项个数，超出9的部分不能使用alt+数字键快速选取
	global width_1 := 0.1,width_2 := 0.4,width_3 := 0.5		;第一、二、三列占中宽度的比列

	;特色功能
	global Edit_stop_time := 500					;输入框自动填充后将会禁用[一段时间]键盘鼠标，避免输入过快，自动填充后又输入
	global is_auto_fill := 1						;当候选项剩下一个时，是否自动填充
	global is_run_first := 1						;当输入框内容与菜单项名称不完全相同，但有候选项时是否自动执行第一个
	global is_auto_CapsLock := 1					;是否打开输入框自动开启大写，因为加入了拼音，所以不需要中文输入搜索了

;----------------------------------------【初始化】----------------------------------------
Label_ScriptSetting: ;脚本前参数设置
	Process, Priority, , High						;脚本高优先级
	#MenuMaskKey vkE8
	#NoEnv											;不检查空变量是否为环境变量
	#NoTrayIcon             						;~不显示托盘图标
	#Persistent										;让脚本持久运行(关闭或ExitApp)
	#SingleInstance Force							;单例运行
	#WinActivateForce								;强制激活窗口
	#MaxHotkeysPerInterval 200						;时间内按热键最大次数
	#HotkeyModifierTimeout 100						;按住modifier后(不用释放后再按一次)可隐藏多个当前激活窗口
	SetBatchLines, -1								;脚本全速执行
	SetControlDelay -1								;控件修改命令自动延时,-1无延时，0最小延时
	CoordMode Menu Window							;坐标相对活动窗口
	CoordMode Mouse Screen							;鼠标坐标相对于桌面(整个屏幕)
	ListLines, Off									;不显示最近执行的脚本行
	SendMode Input									;更速度和可靠方式发送键盘点击
	SetTitleMatchMode 2								;窗口标题模糊匹配;RegEx正则匹配
	DetectHiddenWindows on							;显示隐藏窗口

Label_ReadINI:	;读取INI文件生成菜单项
	;从RA配置文件中读取无路径缓存路径
	SplitPath, A_AhkPath, , RunAnyConfigDir
	IniRead, RunAEvFullPathIniDir, %RunAnyConfigDir%\RunAnyConfig.ini, Config, RunAEvFullPathIniDir, %A_Space%
	If (RunAEvFullPathIniDir="")
		INI_Path := A_AppData "\RunAny"
	Else
		Transform, INI_Path, Deref, % StrReplace(RunAEvFullPathIniDir, "AppData", "A_AppData")
	;读取菜单项配置文件
	INI_MenuObj := INI_Path "\RunAnyMenuObj.ini"
	INI_MenuObjIcon := INI_Path "\RunAnyMenuObjIcon.ini"
	INI_MenuObjExt := INI_Path "\RunAnyMenuObjExt.ini"
	global MenuObj := Object()                    	;~程序全路径
	global MenuObjIcon := Object()                  ;~程序对应图标路径
	global MenuObjExt := Object()					;~对应后缀菜单
	Loop, read, %INI_MenuObj%
	{
		If (A_Index!=1){
			item := StrSplit(A_LoopReadLine, "=")
			MenuObj[(item[1])] := item[2]
		}
	}
	Loop, read, %INI_MenuObjIcon%
	{
		If (A_Index!=1){
			item := StrSplit(A_LoopReadLine, "=")
			MenuObjIcon[(item[1])] := item[2]
		}
	}
	Loop, read, %INI_MenuObjExt%
	{
		If (A_Index!=1){
			item := StrSplit(A_LoopReadLine, "=")
			MenuObjExt[(item[1])] := item[2]
		}
	}

Label_Init: ;搜索框GUI初始化
	global rAAhkMatch  := "RunAny.ahk ahk_class AutoHotkey"		;RA ahk路径
	global index_temp := Radio_Default							;临时变量，用于tab切换减少时间复杂度
	global WinID := ""											;窗口ID
	global My_Edit_Hwnd := ""									;输入框ID
	global Content := ""										;输入框内容
	global ListView_Hwnd := ""									;ListView_Hwnd
	global len_Radio := Radio_names.Length()					;上方选项的单选框控件数量
	global Candidates_num := -1									;候选项个数
	global is_hide := 0											;表示是否是隐藏效果
	OnMessage( 0x201 , "move_Win")								;用于拖拽移动

	CustomColor := "6b9ac9"										;用于背景透明的颜色
	Gui +LastFound +ToolWindow +AlwaysOnTop -Caption -DPIScale +hwndWinID
	Gui Color, %CustomColor%
	Gosub, Label_Font_Radio_un

;----------------------------------------【自定义功能区】----------------------------------------
	For ki, kv in Radio_names
	{
		If (ki=1)
			Gui Add, Radio,-Background  x0 y0  gChangeRadio  HwndSearch_Hwnd_%ki%, %kv%
		Else
			Gui Add, Radio,-Background yn  gChangeRadio HwndSearch_Hwnd_%ki%, %kv%
		tmp := Search_Hwnd_%ki%
		ControlGetPos, , , Radio_W, Radio_H, , ahk_id %tmp%
		ControlMove, , , , Radio_W*1.05, Radio_H+5,ahk_id %tmp%
	}
;--------------------------------------------------------------------------------------------

	Gui font, s%Edit_text_size% c%Edit_color%,Segoe UI
	ControlGetPos, , , , Radio_H, , ahk_id %Search_Hwnd_1%
	Radio_H += 10
	Gui Add, Edit, HwndMy_Edit_Hwnd x0 y%Radio_H% w%Edit_width% vContent gChangeEdit
	ControlGetPos, , , , Edit_H, , ahk_id %My_Edit_Hwnd%
	Gui Add, Text,+Border -Background x%Edit_width% y%Radio_H% h%Edit_H% HwndMove_Hwnd, +
	ControlGetPos, , ,Move_W , , , ahk_id %Move_Hwnd%
	ListBox_width := Edit_width + Move_W
	Gui font, s%ListView_text_size% c%Edit_color%,Segoe UI
	Gui Add, ListView,xs w%ListBox_width% vCommandChoice -Multi +AltSubmit -HScroll HwndListView_Hwnd gGiveEdit, 序号|菜单名称|菜单值
	Gui Add, Button, x39 y69 w75 h23 Hidden Default gLabel_Submit, 确定(&Y)
	WinSet, TransColor, %CustomColor% %Edit_trans%

	;开启时的默认单选框设置
	DefaultHwnd := Search_Hwnd_%Radio_Default%
	GuiControl, , %DefaultHwnd%, 1
	Gosub, Label_Font_Radio
	GuiControl, Font, %DefaultHwnd%
	GuiControl, Hide, CommandChoice
	Gui Show, xCenter y%y_pos% Hide
Return

Label_Submit: ;确认提交
	Gosub, Label_Submit_Before
	Gosub, toggleSearchBar
	Gosub, fun_%index_temp%
return

;----------------------------------------【单选框对应功能】----------------------------------------
;请按照Radio_names对应的顺序填写

fun_1:	;激活指定后缀的菜单
	If (Content!="")
		showSwitchToolTip("后缀: " . Content,2500)
	Else
		showSwitchToolTip("输入空",2500)
	result := Send_WM_COPYDATA("runany[Remote_Menu_Ext_Show](" Content ")", rAAhkMatch)
Return

fun_2:	;打开指定菜单
	if(RegExMatch(MenuObj[Content],"S).+?\[.+?\]%?\(.*?\)")){
		result := Send_WM_COPYDATA(MenuObj[Content], rAAhkMatch)
	}else{
		result := Send_WM_COPYDATA("runany[Remote_Menu_Run](" Content ")", rAAhkMatch)
	}
Return

fun_3:	;百度一下
	Run https://www.baidu.com/s?wd=%Content%
Return
;----------------------------------------------------------------------------------------------

Label_Submit_Before: ;提交之前的操作
	If (index_temp=RA_suffix || index_temp=RA_menu){
		RowNumber := LV_GetNext()
		If (RowNumber!=0){
			LV_GetText(Content, LV_GetNext(), 2)
		}Else If (LV_GetCount()!=0 && is_run_first){
			LV_GetText(Content, 1, 2)
		}Else
			GuiControlGet, Content, ,%My_Edit_Hwnd%
	}Else{
		GuiControlGet, Content, ,%My_Edit_Hwnd%
	}
Return

GuiEscape:	;ESC关闭窗口
	Gosub, hide_searchBar
Return

showSwitchToolTip(Msg="", ShowTime=1000, is_input=0) { ;ToolTip形式显示
	If (is_input=1){
		CoordMode, Caret, Window
		ToolTip, %Msg%, A_CaretX, A_CaretY+60
	}Else{
		MouseGetPos, xpos, ypos 
		ToolTip, %Msg%, xpos, ypos-30
		SetTimer, Timer_Remove_ToolTip, %ShowTime%
	}
	Return
	
	Timer_Remove_ToolTip:  ;移除ToolTip
		SetTimer, Timer_Remove_ToolTip, Off
		ToolTip
	Return
}

ChangeRadio(CtrlHwnd){	;单选框改变时的样式改变
	Gosub, Label_Font_Radio_un
	hwnd := Search_Hwnd_%index_temp%
	GuiControl, Font, %hwnd%
	Gosub, Label_Font_Radio
	GuiControl, Font, %CtrlHwnd%
	Loop, %len_Radio%
	{
		hwnd := Search_Hwnd_%index_temp%
		GuiControlGet, OutputVar,, %hwnd%
		If (OutputVar=1){
			break
		}
		If (index_temp=len_Radio)
			index_temp := 1
		Else
			index_temp := Mod(index_temp+1, len_Radio+1)
	}
}
Return
;----------------------------------------【单选框对应触发提示对应】----------------------------------------

ChangeEdit(){	;输入框改变时触发
	match_flag := 1	;用于那些功能出发下方提示框
	GuiControlGet, OutputVar, ,%My_Edit_Hwnd%
	If (index_temp=RA_suffix){			;激活指定后缀的菜单触发
		CandidateList:=getCandidateSuffix(OutputVar,Candidates_num_max)
		LV_ModifyCol(2, ,"后缀名")
		LV_ModifyCol(3, ,"菜单名称")
	}Else If (index_temp=RA_menu){		;打开指定菜单
		CandidateList:=getCandidateMenu(OutputVar,Candidates_num_max)
		LV_ModifyCol(2, ,"菜单名称")
		LV_ModifyCol(3, ,"菜单值")
	}Else{
		match_flag := 0
	}
	ListCount := CandidateList.Length()/3	;数组对应的3元组数量（key、val、ico_path）
	GuiControl, Move, CommandChoice, % "h" ListView_h + ListView_h * (ListCount > 9 ? 10 : ListCount) + 5	;设置对应的提示框高度
	LV_Delete()							;删除提示框内容以刷新
	ImageListID := IL_Create(ListCount)	;创建对应图片
	LV_SetImageList(ImageListID)
	Loop, %ListCount%{					;ListView插入对应值
		key := CandidateList[3*A_Index-2]
		val := CandidateList[3*A_Index-1]
		ico := StrSplit(CandidateList[3*A_Index], ",")
		IL_Add(ImageListID, ico[1], ico[2])
		LV_Add("Icon" . A_Index,"-" . A_Index, key, val)
	}
	LV_ModifyCol(1,Edit_width*width_1)		;设置算元祖对应宽度
	LV_ModifyCol(2,Edit_width*width_2)
	LV_ModifyCol(3,Edit_width*width_3)
	GuiControl, % ListCount ? "Show" : "Hide", CommandChoice 	;根据数量是否显示提示框
	If (is_hide = 0)
		Gui, Show, AutoSize
	If ( match_flag && ListCount=0 && OutputVar){		;无匹配时提醒
		showSwitchToolTip("无匹配项！",0,1)
	}else if(is_auto_fill && Candidates_num=2){	;剩下一个选项自动填充
		Candidates_num := -1
		Autocomplete(1)
		if (Edit_stop_time){
			GuiControl, +ReadOnly, %My_Edit_Hwnd%
			Sleep, %Edit_stop_time%
			GuiControl, -ReadOnly, %My_Edit_Hwnd%
		}
	}Else{
		ToolTip
	}
}

GiveEdit:	;在提示框内输入按键自动跳转到输入框，双击执行对应功能
	If (A_GuiEvent = "K"){
		ControlFocus,,ahk_id %My_Edit_Hwnd%
	}Else If (A_GuiEvent = "DoubleClick"){
		Gosub, Label_Submit
	}
Return

;------------------------------------------------------------------------------------------------------
Autocomplete(index:=1){	;自动补全
	GuiControlGet, OutputVar, ,%My_Edit_Hwnd%
	LV_GetText(item, index, 2)
	If (item!=""){
		GuiControl, Text, %My_Edit_Hwnd%, %item%
		SendInput {End}
	}
}

Timer_Remove_check: ;鼠标点击其他区域自动隐藏
	if !WinActive("ahk_id" WinID){
		Gosub, hide_searchBar
		SetTimer, Timer_Remove_check, Off
	}
Return

toggleSearchBar:	;激活或关闭RA搜索栏
	if WinActive("ahk_id" WinID){
		SetTimer, Timer_Remove_check, Off
		Gosub, hide_searchBar
	}
	Else{
		is_hide := 0
		If (is_auto_CapsLock)
			SetCapsLockState, On
		If (is_fixed=0){
			Gui Show
		}
		else If (x_pos=0)
			Gui Show, xCenter y%y_pos%
		Else
			Gui Show, x%x_pos% y%y_pos%
		WinActivate,ahk_id %WinID%
		ControlFocus,,ahk_id %My_Edit_Hwnd%
		SetTimer, Timer_Remove_check, 25
	}
Return

hide_searchBar:	;隐藏搜索栏
	ToolTip
	If (is_auto_CapsLock)
		SetCapsLockState, Off
	is_hide := 1
	GuiControl, Text, %My_Edit_Hwnd%
	GuiControl, Hide, CommandChoice
	Gui Hide

Return

move_Win(){ ;左键移动窗口
    PostMessage, 0xA1, 2
}

;----------------------------------------【字体样式Lable】----------------------------------------
Label_Font_Radio_un: ;Radio未选中字体样式
	Gui font, c%Radio_un_color% s%Radio_un_text_size%, Segoe UI
Return

Label_Font_Radio: ;Radio选中字体样式
	Gui Font, c%Radio_color% s%Radio_text_size%, Segoe UI
Return
;----------------------------------------------------------------------------------------------

;进程间传递消息
Send_WM_COPYDATA(ByRef StringToSend, ByRef TargetScriptTitle)
{
    VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)  ; 分配结构的内存区域.
    ; 首先设置结构的 cbData 成员为字符串的大小, 包括它的零终止符:
    SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)  ; 操作系统要求这个需要完成.
    NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)  ; 设置 lpData 为到字符串自身的指针.
    Prev_DetectHiddenWindows := A_DetectHiddenWindows
    Prev_TitleMatchMode := A_TitleMatchMode
    DetectHiddenWindows On
    SetTitleMatchMode 2
    TimeOutTime := 4000  ; 可选的. 等待 receiver.ahk 响应的毫秒数. 默认是 5000
    ; 必须使用发送 SendMessage 而不是投递 PostMessage.
    SendMessage, 0x004A, 0, &CopyDataStruct,, %TargetScriptTitle%  ; 0x004A 为 WM_COPYDAT
    DetectHiddenWindows %Prev_DetectHiddenWindows%  ; 恢复调用者原来的设置.
    SetTitleMatchMode %Prev_TitleMatchMode%         ; 同样.
    return ErrorLevel  ; 返回 SendMessage 的回复给我们的调用者.
}

;获取菜单候选项
getCandidateMenu(Content,Candidates_num_max){
	If (Content="")
		Return
	CandidateList := Object()
	full_match := 0	;有完全匹配项则不会重复搜索，消除自动补全BUG
	Candidates_num := 1
	temp_kv := ""	;消除临近重复选项，，例如快捷键的
    For ki, kv in MenuObj
	{
		If (kv="")
			Continue
		targ := ChToPy.allspell(ki)
		a := InStr(ki, Content) || InStr(ChToPy.allspell_muti(ki), Content) || InStr(ChToPy.initials_muti(ki), Content)
		If (a!=0){
			If (kv=temp_kv){
				Continue
			}Else{
				temp_kv := kv
			}
			ico_path := MenuObjIcon[ki]
			If (ico_path="")
				ico_path := "shell32.dll,4"
			CandidateList.push(ki,kv,ico_path)
			Candidates_num +=1
		}
		If (ki=Content){
			full_match := 1
		}
		If ( Candidates_num > Candidates_num_max){
			break
		}
    }
    Candidates_num := Candidates_num=1 ? 0 : Candidates_num
    Candidates_num := full_match ? 1 : Candidates_num
    Return CandidateList
}

;获取后缀候选项
getCandidateSuffix(Content,Candidates_num_max){
	If (Content="")
		Return
	CandidateList := Object()
	full_match := 0	;有完全匹配项则不会重复搜索，消除自动补全BUG
	Candidates_num := 1
    For ki, kv in MenuObjExt													
	{
		a := InStr(ki, Content)
		If (a!=0){
			ico_path := MenuObjIcon[kv]
			If (ico_path="")
				ico_path := "shell32.dll,3"
			CandidateList.push(ki,kv,ico_path)
			Candidates_num +=1
		}
		If (ki=Content){
			full_match := 1
		}
		If ( Candidates_num > Candidates_num_max){
			break
		}
    }
    Candidates_num := Candidates_num=1 ? 0 : Candidates_num
    Candidates_num := full_match ? 1 : Candidates_num
    Return CandidateList
}

;----------------------------------------------------------------------------------------------

#If WinActive("ahk_id" WinID)	;搜索框的热键，可自行更改，因为要判断是否激活了搜索框，所以不能做成RA插件功能
Tab::	;TAB键快速正序切换，loop循环保证意外发生，循环其实不会走完一遍
	ControlFocus,,ahk_id %My_Edit_Hwnd%
	Loop, %len_Radio%
	{
		hwnd := Search_Hwnd_%index_temp%
		GuiControlGet, OutputVar,, %hwnd%
		If (OutputVar=1){
			Gosub, Label_Font_Radio_un
			GuiControl, Font, %hwnd%
			If (index_temp=len_Radio){
				hwnd := Search_Hwnd_1
				index_temp := 1
			}Else{
				temp := index_temp + 1 
				hwnd := Search_Hwnd_%temp%
				index_temp := Mod(index_temp+1, len_Radio+1)
			}
			Gosub, Label_Font_Radio
			GuiControl, , %hwnd%, 1
			GuiControl, Font, %hwnd%
			Break
		}
		index_temp := Mod(index_temp+1, len_Radio+1)
	}
	ChangeEdit()
Return
RShift::	;右边shift键快速逆序切换
	ControlFocus,,ahk_id %My_Edit_Hwnd%
	Loop, %len_Radio%
	{
		hwnd := Search_Hwnd_%index_temp%
		GuiControlGet, OutputVar,, %hwnd%
		If (OutputVar=1){
			Gosub, Label_Font_Radio_un
			GuiControl, Font, %hwnd%
			If (index_temp=1){
				hwnd := Search_Hwnd_%len_Radio%
				index_temp := len_Radio
			}Else{
				temp := index_temp - 1 
				hwnd := Search_Hwnd_%temp%
				index_temp := Mod(index_temp-1, len_Radio+1)
			}
			Gosub, Label_Font_Radio
			GuiControl, , %hwnd%, 1
			GuiControl, Font, %hwnd%
			Break
		}
		index_temp := Mod(index_temp-1, len_Radio+1)
	}
	ChangeEdit()
Return
;左Lat自动补全
LAlt::Autocomplete(1)
LAlt & 1::Autocomplete(1)
LAlt & 2::Autocomplete(2)
LAlt & 3::Autocomplete(3)
LAlt & 4::Autocomplete(4)
LAlt & 5::Autocomplete(5)
LAlt & 6::Autocomplete(6)
LAlt & 7::Autocomplete(7)
LAlt & 8::Autocomplete(8)
LAlt & 9::Autocomplete(9)

Delete::	;delet自动情况输入框
	ControlFocus,,ahk_id %My_Edit_Hwnd%
	GuiControl, Text, %My_Edit_Hwnd%
	GuiControl, Hide, CommandChoice
Return

Up::		;上下选择
	ControlFocus,,ahk_id %ListView_Hwnd%
	RowNumber := LV_GetNext(0)
	If (RowNumber = 0){
		LV_Modify(1, "+Focus +Select +Vis")
	}Else If (RowNumber = 1){
		LV_Modify(LV_GetCount(), "+Focus +Select +Vis")
	}
	Else{
		LV_Modify(RowNumber-1, "+Focus +Select +Vis")
	}
Return

Down::
	ControlFocus,,ahk_id %ListView_Hwnd%
	RowNumber := LV_GetNext(0)
	If (RowNumber = 0 || RowNumber=LV_GetCount()){
		LV_Modify(1, "+Focus +Select +Vis")
	}Else{
		LV_Modify(RowNumber+1, "+Focus +Select +Vis")
	}
Return