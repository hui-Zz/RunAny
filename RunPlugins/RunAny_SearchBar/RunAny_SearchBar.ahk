;*************************************************
;* 【RA搜索框，菜单项搜索、ev搜索、浏览器书签搜索等】
;*************************************************
global RunAny_Plugins_Version:="1.1.5"
global RunAny_Plugins_Icon:="shell32.dll,23"

;【使用说明地址】：https://docs.qq.com/doc/DWHZnWFdlS0VxYUl1
;tong

;----------------------------------------【RA插件功能】----------------------------------------
class RunAnyObj {
	;以下任选一个写入RA配置文件
	;RA搜索框	LCtrl & d|RunAny_SearchBar[toggle_searchBar]()
	;RA搜索框	LCtrl & d|RunAny_SearchBar[toggle_searchBar](%getZz%)
	toggle_searchBar(getZz:=""){
		toggleSearchBar(getZz)
	}
}
;-------------------------------------------------------------------------------------------
Label_RAScript: ; 将工作目录设置为RA
	global RA_path := ""
	SplitPath, A_AhkPath, , RA_path
	SetWorkingDir, %RA_path%

Label_Include: ; 加载汉字转拼音
	#Include %A_AhkPath%\..\RunPlugins\RunAny_ObjReg.ahk
	; https://www.autoahk.com/archives/37300 汉字转拼音，不需要则删除下面两行
	#Include *i %A_AhkPath%\..\RunPlugins\Lib\ChToPy.ahk
	ChToPy.log4ahk_load_all_dll_path()

Label_ScriptSetting: ; 脚本前参数设置
	Process, Priority, , Realtime					; 脚本高优先级
	#MenuMaskKey vkE8
	#NoTrayIcon             						; 不显示托盘图标
	#Persistent										; 让脚本持久运行(关闭或ExitApp)
	#SingleInstance Force							; 单例运行
	#WinActivateForce								; 强制激活窗口
	#MaxHotkeysPerInterval 200						; 时间内按热键最大次数
	#HotkeyModifierTimeout 100						; 按住modifier后(不用释放后再按一次)可隐藏多个当前激活窗口
	SetBatchLines, -1								; 脚本全速执行
	SetControlDelay -1								; 控件修改命令自动延时,-1无延时，0最小延时
	CoordMode Menu Window							; 坐标相对活动窗口
	CoordMode Mouse Screen							; 鼠标坐标相对于桌面(整个屏幕)
	ListLines, Off									; 不显示最近执行的脚本行
	SendMode Input									; 更速度和可靠方式发送键盘点击
	SetTitleMatchMode 1								; 窗口标题模糊匹配;RegEx正则匹配
	DetectHiddenWindows off							; 显示隐藏窗口

;----------------------------------------【初始化】----------------------------------------
Label_DefVar: ; 初始化变量
	global SearchBar_Version:="1.1.5" ; 版本
	global INI := A_ScriptDir "\RunAny_SearchBar.ini" ; 配置文件
	global RA_FrequencyINI := A_ScriptDir "\Frequency\RA_Frequency.ini" ; 使用频率文件
	global SearchBar_Custom_Ahk_Path := A_ScriptDir "\RunAny_SearchBar_Custom.ahk" ; 使用频率文件
	global FontType := "Microsoft YaHei" ; 字体类型
	global INI_Path, RunAEvFullPathIniDir
	global RA_Frequency_Obj := Object()
	; 上方单选框对应功能
	Gosub, Init_Custom_Fun
	; 搜索框样式
	global x_pos,y_pos,pos_mode,Edit_color,Edit_text_size,Edit_trans,Edit_width,Radio_un_color,Radio_un_text_size,Radio_color,Radio_text_size
	; 提示框样式
	global ListView_text_size,ListView_h,Candidates_num_max,Candidates_show_num_max,width_1,width_2,width_3
	; 特色功能
	global Edit_stop_time,is_auto_fill,is_run_first,is_auto_CapsLock,CapsLock_List,is_remember_content,ChangeIMEHotKey,SaveFrequency,ShowFrequency
	global Web_Search_Close_Caps,Candidate_Tooltip
	; 辅助功能
	global Auto_Reload_MTime,Alt_Auto_Run
	; 热键功能
	global Forward_Switch,Backward_Switch,Empty_Content,Content_Menu
	global Up_Switch,Down_Switch,Select_Enter,InfoText_WheelUp,InfoText_WheelDown

Label_ReadINI:	; 读取INI文件配置
	if !FileExist(INI)
		initINI()

	iniread, is_exist_Screen, %INI%, %A_ScreenWidth%*%A_ScreenHeight%, 搜索框x轴位置
	Screen_Section := is_exist_Screen="ERROR" ? "1920*1080" : A_ScreenWidth "*" A_ScreenHeight
	iniread, x_pos, %INI%, %Screen_Section%, 搜索框x轴位置, 0.5
	iniread, y_pos, %INI%, %Screen_Section%, 搜索框y轴位置, 0.25
	iniread, pos_mode, %INI%, %Screen_Section%, 搜索框位置模式, 1

	iniread, Edit_color, %INI%, %Screen_Section%, 输入框字体颜色, black
	iniread, Edit_text_size, %INI%, %Screen_Section%, 输入框字体大小, 25
	iniread, Edit_trans, %INI%, %Screen_Section%, 输入框透明度, 220
	iniread, Edit_width, %INI%, %Screen_Section%, 输入框宽度, 800

	iniread, Radio_un_color, %INI%, %Screen_Section%, 上方搜索选项未选中时字体颜色, black
	Radio_un_text_size := Edit_text_size -11, Radio_text_size := Edit_text_size -10
	iniread, Radio_color, %INI%, %Screen_Section%, 上方搜索选项选中时字体颜色, 1e90ff
	ListView_text_size := Radio_un_text_size
	iniread, Candidates_font_color, %INI%, %Screen_Section%, 候选框字体颜色, black
	iniread, Candidates_num_max, %INI%, %Screen_Section%, 候选框内最大行数, 150
	iniread, Candidates_show_num_max, %INI%, %Screen_Section%, 候选框显示最大行数, 15
	iniread, ListView_column_ratio, %INI%, %Screen_Section%, 候选框内三列比例, 0.08:0.28:0.64
	ListView_column_ratio := StrSplit(ListView_column_ratio, ":")
	width_1 := ListView_column_ratio[1],width_2 := ListView_column_ratio[2],width_3 := ListView_column_ratio[3]

	; 读取基础配置
	iniread, is_auto_fill, %INI%, 基础配置,输入框是否自动填充, 1
	iniread, Edit_stop_time, %INI%, 基础配置,自动填充后禁用输入时间, 500
	iniread, is_run_first, %INI%, 基础配置,是否回车自动执行第一个候选项, 1
	iniread, is_auto_CapsLock, %INI%, 基础配置,是否自动开启大写, 1
	iniread, CapsLock_List1, %INI%, 基础配置,对应菜单开启大写, 1|2
	iniread, ChangeIMEHotKey, %INI%, 基础配置,切换输入法快捷键, %A_Space%
	CapsLock_List := Object() 
	Loop, parse, CapsLock_List1, |
    	CapsLock_List[A_LoopField] := A_LoopField 
	iniread, is_remember_content, %INI%, 基础配置,是否记住上次执行内容, 0
	iniread, Auto_Reload_MTime, %INI%, 基础配置,配置更改自动重启时间, 2000
	iniread, Alt_Auto_Run, %INI%, 基础配置,Alt选择并执行, 1
	iniread, SaveFrequency, %INI%, 基础配置,记录使用频率, 1
	iniread, ShowFrequency, %INI%, 基础配置,显示使用频率, 1
	iniread, Web_Search_Close_Caps, %INI%, 基础配置,进入网页搜索后关闭大写, 1
	iniread, Candidate_Tooltip, %INI%, 基础配置,候选项选中提示, 1

	; 读取热键配置
	iniread, Forward_Switch, %INI%, 热键配置,正序切换, Tab
	iniread, Backward_Switch, %INI%, 热键配置,逆序切换, \
	iniread, Empty_Content, %INI%, 热键配置,清空输入框, Delete
	iniread, Content_Menu, %INI%, 热键配置,功能菜单热键, ``

	iniread, Up_Switch, %INI%, 热键配置,向上选择, Up
	iniread, Down_Switch, %INI%, 热键配置,向下选择, Down
	iniread, Select_Enter, %INI%, 热键配置,选中执行, Space

	iniread, InfoText_WheelUp, %INI%, 热键配置,信息提示上滚轮, PgUp
	iniread, InfoText_WheelDown, %INI%, 热键配置,信息提示下滚轮, PgDn

	; 读取自定义网页(关键字)搜索
	global Web_Search_Str := "|run"
	global Web_Search_key := Object(),Web_Search_Name := Object(),Web_Search_Url := Object()
	iniread, Custom_Web_Search, %INI%, 自定义关键字搜索
	Loop, parse, Custom_Web_Search, `n, `r  ; 在 `r 之前指定 `n, 这样可以同时支持对 Windows 和 Unix 文件的解析.
	{
	    Array := StrSplit(A_LoopField , "=", ,3)
	    key := Array[1]
	    Loop, parse, key, |
	    {
	    	Web_Search_key[A_LoopField] := 1
	   		Web_Search_Name[A_LoopField] := Array[2]
	   		Web_Search_Url[A_LoopField] := Array[3]
	   		Web_Search_Str .= "|" A_LoopField
	    }
	}
	; 根据DPI调整显示候选数量
	If (A_ScreenDPI=96){
	}Else If (A_ScreenDPI=120){
		Edit_width *= 1.25*0.9
		ListView_h *= 1.25
		Candidates_show_num_max := Format("{:d}", Candidates_show_num_max/1.25+1)
	}Else If (A_ScreenDPI=144){
		Edit_width *= 1.5*0.9
		ListView_h *= 1.5
		Candidates_show_num_max := Format("{:d}", Candidates_show_num_max/1.5+2)
	}Else{
		Edit_width *= A_ScreenDPI/100*0.9
		ListView_h *= A_ScreenDPI/100
		Candidates_show_num_max := Format("{:d}", Candidates_show_num_max/A_ScreenDPI*100+3)
	}

Label_ReadRAINI: ; 读取RAINI文件生成菜单项
	global rAAhkMatch  := "RunAny.ahk ahk_class AutoHotkey" ; RA ahk路径
	global MenuIconSize,ShowGetZzLen
	; 从RA配置文件中读取无路径缓存路径
	SplitPath, A_AhkPath, , RunAnyConfigDir
	IniRead, RunAEvFullPathIniDir, %RunAnyConfigDir%\RunAnyConfig.ini, Config, RunAEvFullPathIniDir, %A_Space%
	If (RunAEvFullPathIniDir="")
		INI_Path := A_AppData "\RunAny"
	Else
		Transform, INI_Path, Deref, % RunAEvFullPathIniDir
	IniRead, MenuIconSize, %RunAnyConfigDir%\RunAnyConfig.ini, Config, MenuIconSize, 24	;菜单图标大小
	ShowGetZzLen := 15
	; 读取菜单项配置文件
	INI_EvFullPath := INI_Path "\RunAnyEvFullPath.ini"	
	INI_MenuObj := INI_Path "\RunAnyMenuObj.ini"
	INI_MenuObjIcon := INI_Path "\RunAnyMenuObjIcon.ini"
	INI_MenuObjExt := INI_Path "\RunAnyMenuObjExt.ini"
	If (!FileExist(INI_MenuObj) || !FileExist(INI_MenuObjIcon) || !FileExist(INI_MenuObjExt)){
		Send_WM_COPYDATA("runany[ShowTrayTip](SearchBar搜索框,首次运行无法读取RA菜单信息，请将本插件设置为【自启】后重启RA！如已设置为【自启】，请耐心等待【RA】启动初始化，将自动重启生效！,20,17)", rAAhkMatch)
	}
	global EvFullPath := Object() ; 无路径缓存
	global MenuObj := Object() ; 程序全路径
	global MenuObjIcon := Object() ; 程序对应图标路径
	global MenuObjExt := Object() ; 对应后缀菜单

	EvFullPath := ReadFromINI(INI_EvFullPath,2)
	MenuObjIcon := ReadFromINI(INI_MenuObjIcon,2)
	Loop, read, %INI_MenuObj%
	{
		If (A_Index!=1){
			equalPos := InStr(A_LoopReadLine, "=")
			If (MenuObjIcon.HasKey(SubStr(A_LoopReadLine, 1, equalPos-1)) || !EvFullPath.HasKey(SubStr(A_LoopReadLine, 1, equalPos-1) ".exe"))
				MenuObj[SubStr(A_LoopReadLine, 1, equalPos-1)] := SubStr(A_LoopReadLine, equalPos+1)
		}
	}
	MenuObjExt := ReadFromINI(INI_MenuObjExt,2)

Label_ReadExtRunList: ; 读取内部关联
    global openExtRunList := Object() ; 内部关联路径加参数
    global openExtRunList_Parm := Object() ; 内部关联参数
    global openExtRunList_num := ReadExtRunList(RunAnyConfigDir "\RunAnyConfig.ini") ; 读取内部关联返回数量

Label_Init: ;搜索框GUI初始化
	global index_temp := Radio_Default							; 临时变量，用于tab切换减少时间复杂度
	global WinID := ""											; 窗口ID
	global InfoText_Hwnd := ""
	global My_Edit_Hwnd := ""									; 输入框ID
	global Content := "",Content_Execute := ""					; 输入框内容
	global Move_Hwnd := ""										; 加号对应的Hwnd
	global ListView_Hwnd := ""									; 候选项对应的Hwnd
	global len_Radio := Radio_names.Length()					; 上方选项的单选框控件数量
	global Candidates_num := -1									; 候选项个数
	global is_hide := 0											; 表示是否是隐藏效果
	global Radio_H_ALL,Edit_H,ListBox_width,ListView_H1,ImageListID			; 辅助变量
	global CandidateList,CandidateList_ExtraInfo,Edit_OutputVar	; 候选框、输入框内容
	global is_can_run_fun:=False,Candidate_Index:=0				; 没有匹配项不执行
	global menu_pos_x,menu_pos_y,menu_pos_mouse:=1				; 菜单弹出位置
	global menu_key,menu_value,menu_tip_name,menu_copy_name		; 菜单对应的k，v
	global menu_is_running:=0									; exe是否运行中
	global menu_item := Object()								; 记录当前菜单的名称，用于添加前缀
	global menu_Prefix := ["&1  ","&2  ","&3  ","&Q ","&W ","&E  ","&A  ","&S  ","&D  ","&Z  ","&X  ","&C  "]
	global Search_32770 := 0, Search_32770_id := "",Content_Path := 0
	global WintoHide := 1
	global is_Web_Searching := 0 								; 正在网页搜索
	global NowPath := ""
	global RunningCandidateList,RunningCandidateComplete 		; 正在运行软件缓存
	global LastMonitorNum := 0 									; 上次显示的显示器编号
	OnMessage( 0x201 , "move_Win")								; 用于拖拽移动
	CustomColor := "6b9ac9"										; 用于背景透明的颜色

	Gui +LastFound +ToolWindow +AlwaysOnTop -Caption -DPIScale +hwndWinID 
	Gui Color, %CustomColor%
	Gosub, Label_Font_Radio_un
	global InfoText_width := Edit_width * 0.382
;----------------------------------------【自定义功能区】----------------------------------------
	For ki, kv in Radio_names
	{
		If (ki=1)
			Gui Add, Radio,-Background  x%InfoText_width% y0  gRadioEvent  HwndSearch_Hwnd_%ki%, %kv%-F%ki%
		Else
			Gui Add, Radio,-Background x%Radio_X% y%Radio_Y%  gRadioEvent HwndSearch_Hwnd_%ki%, %kv%-F%ki%
		tmp := Search_Hwnd_%ki%
		ControlGetPos, Radio_X, Radio_Y, Radio_W, Radio_H, , ahk_id %tmp%
		If ((Radio_X+Radio_W)>Edit_width+InfoText_width){
			Radio_X := InfoText_width + Radio_W + 15
			Radio_Y += Radio_H + 15
			Radio_H_ALL += Radio_H +15
			ControlMove, , InfoText_width, Radio_Y, Radio_W*1.05, Radio_H*1.2,ahk_id %tmp%
		}Else{
			Radio_X += Radio_W + 15
			ControlMove, , , , Radio_W*1.05, Radio_H*1.2,ahk_id %tmp%
		}
	}
;--------------------------------------------------------------------------------------------
	Gui font, s%Edit_text_size% c%Edit_color%,%FontType%
	ControlGetPos, , , , Radio_H, , ahk_id %Search_Hwnd_1%
	Radio_H_ALL += Radio_H + 10
	Gui Add, Edit, HwndMy_Edit_Hwnd -WantReturn x%InfoText_width% y%Radio_H_ALL% w%Edit_width% vContent
	ControlGetPos, , , , Edit_H, , ahk_id %My_Edit_Hwnd%
	Move_Picture_pos_x := Edit_width + 1 + InfoText_width
	Gui, Add, Picture, -Background x%Move_Picture_pos_x% y%Radio_H_ALL% w-1 h%Edit_H% HwndMove_Hwnd gPluseEvent, ZzIcon.dll
	ControlGetPos, , Move_Y, Move_W, Move_H, , ahk_id %Move_Hwnd%
	ListBox_width := Edit_width + Move_W
	ListBox_Y_Pos := Move_Y + Move_H + 10
	Gui font, s%ListView_text_size% c%Candidates_font_color%,%FontType%
	; 双缓冲: +LV0x10000
	Gui Add, ListView,x%InfoText_width% y%ListBox_Y_Pos% w%ListBox_width% vCommandChoice R2 -LV0x10 -Multi +AltSubmit -HScroll HwndListView_Hwnd ggGiveEdit, 序号|菜单名称|菜单值
	Gui Add, ListView,x%InfoText_width% y%ListBox_Y_Pos% w%ListBox_width% R1 -Multi +AltSubmit -HScroll HwndListView_temp_Hwnd , 序号|菜单名称|菜单值
	Gui, ListView, CommandChoice
	ControlGetPos, , , , ListView_H1, , ahk_id %ListView_temp_Hwnd%
	ControlGetPos, , , , ListView_H2, , ahk_id %ListView_Hwnd%
	ListView_h := ListView_H2 - ListView_H1
	InfoText_width_real := InfoText_width - 10
	InfoText_height := ListView_H1 + ListView_h * (Candidates_show_num_max-1) + ListBox_Y_Pos
	Gui Add,edit, -Background Border readonly x0 y0 w%InfoText_width_real% h%InfoText_height% HwndInfoText_Hwnd
	GuiControl, Disable, %ListView_temp_Hwnd%
	GuiControl, Hide, %ListView_temp_Hwnd%
	GuiControl, Hide, %InfoText_Hwnd%
	Gui Add, Button, x39 y69 w75 h23 Hidden Default gLabel_Submit, 确定(&Y)
	WinSet, TransColor, %CustomColor% %Edit_trans%

	Gosub, Label_Font_Radio
	GuiControl, Hide, CommandChoice
	SelectWhichRadio(0,0)
	SelectWhichRadio(Radio_Default,0)
	Gosub, Label_Create_Menu
	Gosub, Label_Create_Hotkey

Label_ExtraFun: ; 额外功能添加
	If (ShowFrequency=1){
		width_2 -= 0.03
		width_3 -= 0.04
		LV_InsertCol(4,"Center","计数")
	}

Label_CheckVersion:	; 检查插件版本
	FileCreateDir, %A_ScriptDir%\backup
	iniread, SearchBar_Version_INI, %INI%, 基础配置, 配置版本, "1.0.0"
	iniread, SearchBar_Custom_Version, %INI%, 基础配置, 自定义配置版本, "1.0.0"
	SearchBar_Version_INI_Comp := GetVersionComp(SearchBar_Version_INI)
	SearchBar_Custom_Version_Comp := GetVersionComp(SearchBar_Custom_Version)
	If (SearchBar_Version_INI_Comp<1146){
		FileRemoveDir, %A_ScriptDir%\Chrome_Bookmarks, 1
		is_need_Reload := 1
		FileCopy, %INI%, %A_ScriptDir%\backup, 1
		initINI()
		IniWrite, %SearchBar_Version%, %INI%, 基础配置, 配置版本
	}
	If (SearchBar_Custom_Version_Comp<1146){
		is_need_Reload := 1
		FileCopy, %SearchBar_Custom_Ahk_Path%, %A_ScriptDir%\backup, 1
		initCustomAHK()
		IniWrite, %SearchBar_Version%, %INI%, 基础配置, 自定义配置版本
	}
	If (is_need_Reload=1)
		Gosub,SearchBar_Reload

Label_ExtraRadio: ; 额外的搜索功能
	If (RA_Everything!=""){
		global RA_Everything_EvPath,EVSearch_in_Explorer,EvCommand := "",EV_File_Priority_Show
		iniread, RA_Everything_EvPath, %INI%, EV搜索配置, EV路径, %A_Space%
		iniread, EVSearch_in_Explorer, %INI%, EV搜索配置, 资源管理器中EV按目录搜索, 1
		iniread, EV_File_Priority_Show, %INI%, EV搜索配置, 文件优先展示, 1
		Transform, RA_Everything_EvPath, Deref, % RA_Everything_EvPath
		Gosub,Label_RA_Everything
		If (EVSearch_in_Explorer=1){
			GroupAdd, Explorer, ahk_class ExploreWClass		; win资源管理器（下面三个都是）
			GroupAdd, Explorer, ahk_class CabinetWClass
			GroupAdd, Explorer, ahk_class WorkerW
			GroupAdd, Explorer, ahk_exe Q-Dir_x64.exe 		; Q-Dir资源管理器
			GroupAdd, Explorer, ahk_class TTOTAL_CMD 		; TC资源管理器
		}
		global everyDLL:="Everything.dll"
		if(FileExist(RA_path "\Everything.dll"))
			everyDLL:=DllCall("LoadLibrary", str, "Everything.dll") ? "Everything.dll" : "Everything64.dll"
		else if(FileExist(RA_path "\Everything64.dll"))
			everyDLL:=DllCall("LoadLibrary", str, "Everything64.dll") ? "Everything64.dll" : "Everything.dll"
		global FileAssocIcon := Object()
		global ev := new everything
		ev.SetMax(Candidates_num_max)
		iniread, EvCommand, %INI%, EV搜索配置, EV搜索规则, edge
		If (EvCommand="")
			IniRead, EvCommand, %RA_path%\RunAnyConfig.ini, Config, EvCommand,%A_Space%
	}
	If (RA_ChromeBookmarks!=""){
		global Chrome_Bookmarks_Obj := Object()
		global RA_ChromeBookmarks_Type,RA_ChromeBookmarks_Path
		global ChromeBookmarks_FrequencyINI := A_ScriptDir "\Frequency\ChromeBookmarks_Frequency.ini" ;书签频率配置表
		global ChromeBookmarks_Frequency_Obj := Object()				; 书签对应频率
		iniread, RA_ChromeBookmarks_Type, %INI%, 浏览器书签搜索配置, 浏览器类型, edge
		iniread, RA_ChromeBookmarks_Path, %INI%, 浏览器书签搜索配置, 书签路径, %A_Space%
		Transform, RA_ChromeBookmarks_Path, Deref, % RA_ChromeBookmarks_Path
		Gosub,Label_RA_ChromeBookmarks
	}

Label_Frequency: ; 读取候选项使用频率
	If (SaveFrequency=1){
		FileCreateDir, %A_ScriptDir%\Frequency
		Lable_ReadFreINI(0)
	}

Label_WindowsMonitor: ; 获取windows显示器信息
	OnMessage(0x007E, "Monitor_Change")
	SysGet, MonitorCount, MonitorCount
	global MonitorAreaObjects := Object()
	Loop, %MonitorCount%
	{
	    MonitorAreaObject := Object()
	    SysGet, Monitor, Monitor, %A_Index%
	    MonitorAreaObject[1] := MonitorLeft
	    MonitorAreaObject[2] := MonitorTop
	    MonitorAreaObject[3] := MonitorRight
	    MonitorAreaObject[4] := MonitorBottom
	    SysGet, Monitor, MonitorWorkArea, %A_Index%
	    MonitorAreaObject[5] := MonitorLeft
	    MonitorAreaObject[6] := MonitorTop
	    MonitorAreaObject[7] := MonitorRight
	    MonitorAreaObject[8] := MonitorBottom
	    MonitorAreaObjects[A_Index] := MonitorAreaObject
	}

Label_Return: ; 结束标志
	initResetINI()
	SetTimer,Label_ClearMEM,-10000 ;
	#Include *i %A_ScriptDir%\RunAny_SearchBar_Custom.ahk
Return

Label_Submit: ; 确认提交
	Critical On
	Thread, NoTimers, True
	ControlGetFocus, Control_Focus, ahk_id %WinID%
	If (is_Web_Searching=1){
		GuiControlGet, Content, ,%My_Edit_Hwnd%
		Array := StrSplit(Content, "  ",,2)
		Web_Search := StrReplace(Web_Search_Url[Array[1]], "{query}", LTrim(Array[2], " "))
		Web_Search := StrReplace(Web_Search, "{URIquery}", URIEncode(LTrim(Array[2], " ")))
		Web_Search := Deref(Web_Search)
		Run, %Web_Search%
		Return
	}
	If (!is_can_run_fun)
		Return
	Gosub, Label_SubmitBefore
	if (Search_32770!=0){
		If (Search_32770_Path=""){
			If (index_temp=RA_menu)	
				Search_32770_Path := MenuObj[Content_Execute]
			Else If (index_temp=RA_Everything)
				Search_32770_Path := Content_Execute
		}
		SplitPath, Search_32770_Path , OutFileName, OutDir
		If (Content_Path=1){
			Search_32770_Path := OutDir
			Search_32770_Name := ""
		}Else{
			FileGetAttrib, Attributes, %Search_32770_Path%
			if !InStr(Attributes, "D"){
				Search_32770_Path := OutDir
				Search_32770_Name := OutFileName
			}Else{
				Search_32770_Name := ""
			}
		}
		If (Search_32770=1)
			Change32770Path(Search_32770_Path,Search_32770_id,Search_32770_Name)
		Else If (Search_32770=2)
			ChangeRAPath(Content_Execute,Search_32770_id)
		Content_Path := 0
		Search_32770_Path := ""
		gosub, Label_HideSearchBar
		Thread, NoTimers, False
		Critical Off
		Return
	}
	toggleSearchBar()
	if IsLabel("fun_" index_temp)
		Gosub, fun_%index_temp%
	Else
		Send_WM_COPYDATA("runany[ShowTrayTip](SearchBar搜索框,对应功能未定义，请在【RunAny_SearchBar_Custom.ahk】中添加后重启插件，可以通过右键点击功能项快速打开,20,17)", rAAhkMatch)
	ChangeFrequency()
return

;----------------------------------------【自带功能】----------------------------------------
suffix_fun:	; 后缀菜单功能
	If (Content_Execute!="")
		showSwitchToolTip("后缀: " . Content,2500)
	Else
		showSwitchToolTip("输入空",2500)
	result := Send_WM_COPYDATA("runany[Remote_Menu_Ext_Show](" Content_Execute ")", rAAhkMatch)
Return

menu_fun: ; 菜单项功能
	MenuObjContent := MenuObj[Content_Execute]
	If (InStr(Content_Execute, ":*X:"))
		Sleep,100
	If (RegExMatch(MenuObjContent,"i)http://|https://|www\.|ftp://.*")){
		If (openExtRunList["html"]){
			WEB_Open_Exe := openExtRunList["html"] " " openExtRunList_Parm["html"]
			Run, %WEB_Open_Exe% "%MenuObjContent%" 
		}Else 
			Run, %MenuObjContent%
	}Else If (RegExMatch(MenuObjContent,"S).+?\[.+?\]%?\(.*?\)")){
		result := Send_WM_COPYDATA(MenuObjContent, rAAhkMatch)
	}Else{
		result := Send_WM_COPYDATA("runany[Remote_Menu_Run](" Content_Execute ")", rAAhkMatch)
	}
Return

Radio_Everything: ; EV搜索功能
	If (Control_Focus="Edit1")
		Run %EvPath% -search "%Content%"
	Else
		FilePathRun(Content_Execute)
Return

Radio_ChromeBookmarks: ; 浏览器书签搜索功能
	Chrome_Bookmarks_Content := Chrome_Bookmarks_Obj[Content_Execute]
	If (openExtRunList["html"]) {
	 	WEB_Open_Exe := openExtRunList["html"] " " openExtRunList_Parm["html"]
		Run, %WEB_Open_Exe% "%Chrome_Bookmarks_Content%" 
	}
	Else 
		Run, %Chrome_Bookmarks_Content%
Return

Label_SubmitBefore: ; 提交之前的操作
	GuiControlGet, Content, ,%My_Edit_Hwnd%
	If (index_temp=RA_suffix || index_temp=RA_menu || index_temp=RA_ChromeBookmarks){
		executeCandidateWhich(2)
	}Else If (index_temp=RA_Everything){		
		executeCandidateWhich(3)
	}Else{		
		temp := "Execute"
		If (IsLabel("Label_Custom_ListView_" temp))
			Gosub, Label_Custom_ListView_%temp%
	}
Return

GuiEscape: ; ESC关闭窗口
	Gosub, Label_HideSearchBar
Return

showSwitchToolTip(Msg="", ShowTime=1000, is_input=0) { ; ToolTip形式显示
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

SelectWhichRadio(index,is_Change_CapsLock_State:=1){ ; 改变搜索功能
	If (index_temp=index){
		SelectWhichRadioExtro(index)
		Return
	}
	LV_Modify(LV_GetNext(), "-Focus -Select -Vis")
	CandidateList_ExtraInfo := ""
	If (is_Web_Searching=0){
		ico_file_name := Radio_names[index]
		ico_file_path := A_ScriptDir "\Icos\" ico_file_name ".ico"
		If FileExist(ico_file_path)
			GuiControl,, %Move_Hwnd%, %ico_file_path%
		Else
			GuiControl,, %Move_Hwnd%, ZzIcon.dll
	}
	GuiControl, Hide, CommandChoice
	GuiControl, Hide, %InfoText_Hwnd%
	CandidateList:=""
	index := index<=len_Radio ? index : len_Radio
	ControlFocus,,ahk_id %My_Edit_Hwnd%
	Gosub, Label_Font_Radio_un
	hwnd := Search_Hwnd_%index_temp%
	GuiControl, Font, %hwnd%
	Gosub, Label_Font_Radio
	hwnd := Search_Hwnd_%index%
	GuiControl, , %hwnd%, 1
	GuiControl, Font, %hwnd%
	index_temp := index
	If (is_Change_CapsLock_State=1)
		Gosub, Change_CapsLock_State
	SelectWhichRadioExtro(index)
}

SelectWhichRadioExtro(index){ ; 切换搜索功能时的额外功能
	If (EVSearch_in_Explorer=1 && NowPath!=""){
		If (index=RA_Everything){
			If (NowPath!=""){
				GuiControl, Text, %My_Edit_Hwnd%, %NowPath%%A_Space%
				SendInput {End}
			}
		}Else{
			GuiControlGet, Content, ,%My_Edit_Hwnd%
			If (InStr(Content, NowPath))
				GuiControl, Text, %My_Edit_Hwnd%
		}
	}
}

;----------------------------------------【单选框对应触发提示对应】----------------------------------------
Lable_ShowCandidate: ; 显示候选项
	IL_Destroy(ImageListID)				; 删除图像列表，降低内存
	match_flag := 1						; 用于那些功能出发下方提示框
	RASearchCommand := ""
	RASearchCommandPos := InStr(Edit_OutputVar, "  ")
	If (RASearchCommandPos!=0)
		RASearchCommand := SubStr(Edit_OutputVar, 1, RASearchCommandPos-1)
	If (Web_Search_key.HasKey(RASearchCommand)){
		ico_file_name := Web_Search_Name[RASearchCommand]
		showSwitchToolTip(Web_Search_Name[RASearchCommand],0,1)
		If (is_Web_Searching=0){
			If (Web_Search_Close_Caps=1)
				SetCapsLockState, Off
			is_Web_Searching := 1
		}
	}Else If (RASearchCommand="run"){
		If (index_temp!=RA_menu){
			SelectWhichRadio(RA_menu)
			Return
		}
		if (LTrim(SubStr(Edit_OutputVar, 4))="")
			showSwitchToolTip("【已运行软件】扫描中......",0,1)
		CandidateList:=getRunningCandidate(MenuObj,4,MenuObjIcon)
		LV_ModifyCol(2, ,"后缀名")
		LV_ModifyCol(3, ,"菜单名称")
	}Else{
		ico_file_name := Radio_names[index_temp]
		If (is_Web_Searching=1){
			If (is_auto_CapsLock=1 && CapsLock_List.HasKey(index_temp))
				SetCapsLockState, On
			is_Web_Searching := 0
		}
		If (index_temp=RA_suffix){			; 激活指定后缀的菜单触发
			CandidateList:=getCandidateCommon(MenuObjExt,3,MenuObjIcon,3)
			LV_ModifyCol(2, ,"后缀名")
			LV_ModifyCol(3, ,"菜单名称")
		}Else If (index_temp=RA_menu){		; 打开指定菜单
			CandidateList:=getCandidateCommon(MenuObj,4,MenuObjIcon)
			LV_ModifyCol(2, ,"菜单名称")
			LV_ModifyCol(3, ,"菜单值")
		}Else If (index_temp=RA_Everything){
			CandidateList:=getCandidateEverything()
			LV_ModifyCol(2, ,"文件名")	; 第2列的标题
			LV_ModifyCol(3, ,"路径")		; 第3列的标题
		}Else If (index_temp=RA_ChromeBookmarks){
			CandidateList:=getCandidateCommon(Chrome_Bookmarks_Obj,44,,2)	; Chrome_Bookmarks_Obj表示浏览器书签对象，44表示默认图标的序号，中间空的表示图标对象，2表示使用第2列内容获取图标
			LV_ModifyCol(2, ,"书签名")	; 第2列的标题
			LV_ModifyCol(3, ,"网址")		; 第3列的标题
		}Else{
			temp := "Show"
			If (IsLabel("Label_Custom_ListView_" temp))
				Gosub, Label_Custom_ListView_%temp%
			Else
				match_flag := 0
		}
	}
	Gosub,Lable_ChangIco
	column := LV_GetCount("Column")
	If (ShowFrequency!=1)
		column += 1
	ListCount := CandidateList.Length()/column	; 数组对应的3元组数量（key、val、ico_path）
	If !(ListCount_Before>Candidates_show_num_max && ListCount>Candidates_show_num_max)
		GuiControl, Move, CommandChoice, % "h" ListView_H1 + ListView_h * ((ListCount > (Candidates_show_num_max-1) ? Candidates_show_num_max : ListCount)-1) ;设置对应的提示框高度
	ImageListID := IL_Create(ListCount)	; 创建对应图片
	LV_SetImageList(ImageListID)
	If (ListCount_Before < ListCount){
		Loop, %ListCount%{					; ListView插入对应值
			key := CandidateList[4*A_Index-3]
			val := CandidateList[4*A_Index-2]
			ico := StrSplit(CandidateList[4*A_Index-1], ",")
			fre := CandidateList[4*A_Index]
			IL_Add(ImageListID, ico[1], ico[2])
			If (A_Index <= ListCount_Before){
				If (ShowFrequency=1)
					LV_Modify(A_Index,, "-" . A_Index, key, val, fre)
				Else
					LV_Modify(A_Index,, "-" . A_Index, key, val)
			}Else{
				If (ShowFrequency=1)
					LV_Add("Icon" . A_Index,"-" . A_Index, key, val, fre)
				Else
					LV_Add("Icon" . A_Index,"-" . A_Index, key, val)
			}
		}
	}Else If (ListCount_Before > ListCount){
		Loop, %ListCount_Before%{					; ListView插入对应值
			If (A_Index <= ListCount){
				key := CandidateList[4*A_Index-3]
				val := CandidateList[4*A_Index-2]
				ico := StrSplit(CandidateList[4*A_Index-1], ",")
				fre := CandidateList[4*A_Index]
				IL_Add(ImageListID, ico[1], ico[2])
				If (ShowFrequency=1)
					LV_Modify(A_Index,, "-" . A_Index, key, val, fre)
				Else
					LV_Modify(A_Index,, "-" . A_Index, key, val)
			}Else{
				LV_Delete(ListCount+1)
			}
		}
	}Else{
		Loop, %ListCount%{					; ListView插入对应值
			key := CandidateList[4*A_Index-3]
			val := CandidateList[4*A_Index-2]
			ico := StrSplit(CandidateList[4*A_Index-1], ",")
			fre := CandidateList[4*A_Index]
			IL_Add(ImageListID, ico[1], ico[2])
			If (ShowFrequency=1)
				LV_Modify(A_Index,, "-" . A_Index, key, val, fre)
			Else
				LV_Modify(A_Index,, "-" . A_Index, key, val)
		}
	}
	ListCount_Before := ListCount
	width_remainder := 1
	Loop, %column%{
		If (A_Index=column)
			LV_ModifyCol(A_Index,Edit_width*width_remainder)
		Else{
			width := width_%A_Index%
			LV_ModifyCol(A_Index,Edit_width*width) 
			width_remainder -= width
		}
	}
	If (!ListCount || is_Web_Searching = 1)
		Gosub, Lable_CloseListView
	Else
		GuiControl, Show, CommandChoice 	; 根据数量是否显示提示框
	If (is_hide = 0)
		Gui, Show, AutoSize
	If ( match_flag && (ListCount=0||ListCount="") && Edit_OutputVar){		; 无匹配时提醒
		is_can_run_fun := False
		If (is_Web_Searching!=1)
			showSwitchToolTip("无匹配项！",0,1)
	}else if(is_auto_fill && Candidates_num=2 && !InStr(Web_Search_Str,"|" Edit_OutputVar)){	; 剩下一个选项自动填充
		is_can_run_fun := True
		Candidates_num := -1
		Autocomplete(1,0)
		if (Edit_stop_time){
			GuiControl, +ReadOnly, %My_Edit_Hwnd%
			Sleep, %Edit_stop_time%
			GuiControl, -ReadOnly, %My_Edit_Hwnd%
		}
	}Else If (Edit_OutputVar=""){
		is_can_run_fun := True
		ToolTip
	}Else{
		is_can_run_fun := True
		ToolTip
	}
Return

Lable_ChangIco: ; 改变图标
	If (ico_file_name!=ico_file_name_old){
		ico_file_path := A_ScriptDir "\Icos\" ico_file_name ".ico"
		If FileExist(ico_file_path)
			GuiControl,, %Move_Hwnd%, %ico_file_path%
		Else{
			GuiControl,, %Move_Hwnd%, ZzIcon.dll
		}
		ico_file_name_old := ico_file_name
	}
Return


Lable_CloseListView:	; 关闭候选框
	LV_Delete()							; 删除提示框内容以刷新
	IL_Destroy(ImageListID)				; 删除图像列表，降低内存
	ListCount_Before := 0
	ListCount := 0
	GuiControl, Hide, CommandChoice
Return


gGiveEdit:	; 在提示框内输入按键自动跳转到输入框，双击执行对应功能
	If (A_GuiEvent = "K"){
		key := GetKeyName(Format("vk{:x}", A_EventInfo))
		If (A_EventInfo!=93 && A_EventInfo!=229 && key!="AppsKey" && key!="CapsLock"){
			LV_Modify(LV_GetNext(), "-Focus -Select -Vis")
			ControlFocus,,ahk_id %My_Edit_Hwnd%
		}
	}Else If (Candidate_Tooltip !=0 &&  (A_GuiEvent = "Normal" || A_GuiEvent = "I")){
		Gosub, ListView_ToolTip
	}Else If (A_GuiEvent = "DoubleClick"){
		Gosub, Label_Submit
	}
Return

SetTimer_WinWaitFocusEdit: ; 定时聚焦于输入框
	ControlGetFocus, Control_Focus, ahk_id %WinID%
	ControlGet, FocusCtrlHwnd, Hwnd ,, %Control_Focus%, ahk_id %WinID%
	if (FocusCtrlHwnd=My_Edit_Hwnd){
		GuiControl, Hide, %InfoText_Hwnd%
	}
Return

;------------------------------------------------------------------------------------------------------
Autocomplete(index:=1,is_run:=1){ ; 自动补全
	If (Alt_Auto_Run=0)
		is_run := 0
	If (is_run){
		Sleep, 100
		Candidate_Index := index
		Gosub, Label_Submit
	}Else{
		LV_GetText(item, index, 2)
		If (item!=""){
			GuiControl, Text, %My_Edit_Hwnd%, %item%
			SendInput {End}
		}
	}
}

move_Win(){ ; 左键移动窗口
    PostMessage, 0xA1, 2
}

toggleSearchBar(getZz:=""){	; 激活或关闭RA搜索框
	CoordMode, Mouse , Screen
	MouseGetPos, OutputVarX, OutputVarY
	MonitorNum := getMonitorNum(OutputVarX,OutputVarY)
	If (WinActive("ahk_id" WinID) && MonitorNum=LastMonitorNum){
		SetTimer, Timer_Remove_check, Off
		Gosub, Label_HideSearchBar
	}Else {
		LastMonitorNum := MonitorNum
		If (EVSearch_in_Explorer=1){
			If (WinActive("ahk_group Explorer")){
				WinGet, win_id, ID, A
				NowPath := getNowPath(win_id)
			}Else
				NowPath := ""
		}	
		Search_32770 := 0
		if WinActive("ahk_class #32770")
			Search_32770 := 1
		Else If WinActive("RunCtrl - 启动项 ahk_exe RunAny.exe")
			Search_32770 := 2
		If (Search_32770!=0){
			WinGetPos, X32770, Y32770, W32770, H32770, A
			WinGet, Search_32770_id, ID, A
			x_pos32770 := X32770 + (W32770-ListBox_width)/2 - InfoText_width
			y_pos32770 := Y32770
			If (index_temp=RA_menu||index_temp=RA_Everything)
				SelectWhichRadio(index_temp)
			Else
				SelectWhichRadio(RA_menu)
		}
		is_hide := 0
		Gosub, Change_CapsLock_State
		if (Search_32770!=0){
			Gui Show, x%x_pos32770% y%y_pos32770%
		}Else{
			If (pos_mode=0){
				Gui Show
			}Else If (pos_mode=1){
				x_pos_show := MonitorAreaObjects[MonitorNum][5] + Abs(MonitorAreaObjects[MonitorNum][7]-MonitorAreaObjects[MonitorNum][5])*x_pos - (ListBox_width/2) - InfoText_width
				y_pos_show := MonitorAreaObjects[MonitorNum][6] + Abs(MonitorAreaObjects[MonitorNum][8]-MonitorAreaObjects[MonitorNum][6])*y_pos - (Radio_H_ALL+Edit_H/2)
				Gui Show, x%x_pos_show% y%y_pos_show%
			}Else If (pos_mode=2){
				CoordMode, Mouse, Screen
				MouseGetPos, xMouse, yMouse
				xMouse -= (ListBox_width/2)
				yMouse -= (Radio_H_ALL+Edit_H/2)
				Gui Show, x%xMouse% y%yMouse%
			}
		}
		WinActivate,ahk_id %WinID%
		ControlFocus,,ahk_id %My_Edit_Hwnd%
		SendInput %ChangeIMEHotKey%
		If (getZz)
			GuiControl, Text, %My_Edit_Hwnd%, %getZz%
		Else If (is_remember_content)
			GuiControl, Text, %My_Edit_Hwnd%, %Content%
		SendInput {End}
		SetTimer, Timer_Remove_check, 10
		SetTimer, SetTimer_WinWaitFocusEdit, 200
		SelectWhichRadio(index_temp)
	}
}

getMonitorNum(X,Y){ ; 获取显示器编号
    Loop,% MonitorAreaObjects.Length()
    {
        If (X>=MonitorAreaObjects[A_Index][1] && X<=MonitorAreaObjects[A_Index][3] && Y>=MonitorAreaObjects[A_Index][2] && Y<=MonitorAreaObjects[A_Index][4])
        	Return A_Index
    }
    Return 1
}

Timer_Remove_check: ; 鼠标点击其他区域自动隐藏
	GuiControlGet, Edit_OutputVar, ,%My_Edit_Hwnd%
	If (Edit_OutputVar_before != Edit_OutputVar Or index_temp_before != index_temp){
		Edit_OutputVar_before := Edit_OutputVar
		index_temp_before := index_temp
		Gosub, Lable_ShowCandidate
	}
	If !WinActive("ahk_id" WinID){
		If WinActive("ahk_class tooltips_class32"){
			ToolTip
		}Else{	
			Gosub, Label_HideSearchBar
			SetTimer, Timer_Remove_check, Off
		}
	}
Return

Label_HideSearchBar: ; 隐藏搜索框
	Search_32770 := 0
	ToolTip
	If (is_auto_CapsLock)
		SetCapsLockState, Off
	is_hide := 1
	GuiControl, Text, %My_Edit_Hwnd%
	LV_Modify(LV_GetNext(), "-Focus -Select -Vis")
	GuiControl, Hide, CommandChoice
	GuiControl, Hide, %InfoText_Hwnd%
	Gui Hide
	SetTimer, SetTimer_WinWaitFocusEdit, Off
	SetTimer, Timer_Remove_check, Off
	SetTimer,Label_ClearMEM,-60000
	
	Edit_OutputVar_before := ""
	is_Web_Searching := 0
	ico_file_name := Radio_names[index_temp]
	RunningCandidateComplete:=0
	Gosub,Lable_ChangIco
Return

;----------------------------------------【字体样式Lable】----------------------------------------
Label_Font_Radio_un: ; Radio未选中字体样式
	Gui font, c%Radio_un_color% s%Radio_un_text_size%, %FontType%
Return

Label_Font_Radio: ; Radio选中字体样式
	Gui Font, c%Radio_color% s%Radio_text_size%, %FontType%
Return
;----------------------------------------------------------------------------------------------


Send_WM_COPYDATA(ByRef StringToSend, ByRef TargetScriptTitle,ByRef TimeOutTime:=4000){ ;进程间传递消息
    VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)  ; 分配结构的内存区域.
    ; 首先设置结构的 cbData 成员为字符串的大小, 包括它的零终止符:
    SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)  ; 操作系统要求这个需要完成.
    NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)  ; 设置 lpData 为到字符串自身的指针.
    Prev_DetectHiddenWindows := A_DetectHiddenWindows
    Prev_TitleMatchMode := A_TitleMatchMode
    DetectHiddenWindows On
    SetTitleMatchMode 2
    TimeOutTime := TimeOutTime  ; 可选的. 等待 receiver.ahk 响应的毫秒数. 默认是 5000
    ; 必须使用发送 SendMessage 而不是投递 PostMessage.
    SendMessage, 0x004A, 0, &CopyDataStruct,, %TargetScriptTitle%, , , , %TimeOutTime%  ; 0x004A 为 WM_COPYDAT
    DetectHiddenWindows %Prev_DetectHiddenWindows%  ; 恢复调用者原来的设置.
    SetTitleMatchMode %Prev_TitleMatchMode%         ; 同样.
    return ErrorLevel  ; 返回 SendMessage 的回复给我们的调用者.
}

Menu_RASearchCommand_run: ; 已运行软件
	Menu_RASearchCommand := SubStr(A_ThisMenuItem, 1, InStr(A_ThisMenuItem,"->")-1)
	Menu_RASearchCommand_Pos := InStr(A_ThisMenuItem,"|")
	If (Menu_RASearchCommand_Pos!=0)
		Menu_RASearchCommand := SubStr(Menu_RASearchCommand, 1, InStr(A_ThisMenuItem,"|")-1)
	GuiControl, Text, %My_Edit_Hwnd%, %Menu_RASearchCommand%%A_Space%%A_Space%
	SendInput {End}
	Gosub,Lable_ShowCandidate
Return

AddMenu(MenuItemName,LabelOrSubmenu,IcoPath,IcoNum){ ; 添加菜单项
	Menu, RA_SearchBar, Add, %MenuItemName%, %LabelOrSubmenu%
	try	Menu, RA_SearchBar, Icon, %MenuItemName%, %IcoPath%, %IcoNum%, %MenuIconSize%
	menu_item.push(MenuItemName)
}

Hotkey_Menu: ; 热键显示的菜单
	ControlGetFocus, Control_Focus, ahk_id %WinID%
	ControlGet, FocusCtrlHwnd, Hwnd ,, %Control_Focus%
	if (FocusCtrlHwnd=My_Edit_Hwnd){
		menu_pos_x := A_CaretX
		menu_pos_y := A_CaretY + Edit_H
		MenuFix(FocusCtrlHwnd)
	}Else if (FocusCtrlHwnd=InfoText_Hwnd){
		Gosub, Menu_RAOneKeyReach
	}Else{
		SendInput, {AppsKey}
	}
Return

MenuFix(CtrlHwnd){ ; 根据位置显示不同菜单
	Menu, RA_SearchBar, DeleteAll
	If (CtrlHwnd=My_Edit_Hwnd){
		Gosub, Edit_Menu
		CandidateIndex := 1
	}Else If (CtrlHwnd=ListView_Hwnd){
		Gosub, ListView_Menu
		CandidateIndex := LV_GetNext() ? LV_GetNext() : 1
	}Else {
		Gosub, Plus_Menu
	}
	index := 0
	For Key, Val in menu_item{
		Menu, RA_SearchBar, Rename, %Val%,% menu_Prefix[Key] Val
		If (Mod(Key, 3) = 1 && Key!=1){
			tarIndex := Key + index++
			Menu, RA_SearchBar, Insert, %tarIndex%&
		}
	}
	If (Edit_OutputVar && is_can_run_fun){
		ico := StrSplit(CandidateList[4*CandidateIndex-1], ",")
		new_menu_key := StrReplace(menu_key, "&")
		If (new_menu_key=""){
			new_menu_key := Edit_OutputVar
		}
		If (StrLen(new_menu_key)>ShowGetZzLen)
			new_menu_key := substr(new_menu_key,1,ShowGetZzLen) "..."
		If (menu_is_running=1)
			Menu, RA_SearchBar, Insert, 1&, （已运行）%menu_tip_name%：%new_menu_key%, Menu_Run
		Else
			Menu, RA_SearchBar, Insert, 1&, %menu_tip_name%：%new_menu_key%, Menu_Run
		If (ico[1])
			try Menu, RA_SearchBar, Icon, 1&, % ico[1],% ico[2], %MenuIconSize%
		Else
			try Menu, RA_SearchBar, Icon, 1&, shell32.dll,253, %MenuIconSize%
	}Else{
		If (is_can_run_fun)
			Menu, RA_SearchBar, Insert, 1&, 菜单：空, Menu_Run
		Else
			Menu, RA_SearchBar, Insert, 1&, 菜单：无匹配, Menu_Run
		try Menu, RA_SearchBar, Icon, 1&, imageres.dll, 5, %MenuIconSize%
	}
	Menu, RA_SearchBar, Insert, 2&
	menu_item:=[]
	Menu, RA_SearchBar, Show, %menu_pos_x%, %menu_pos_y%
}

Menu_OpenINIPath: ; 打开所在路径
	Gosub, Label_HideSearchBar
	OpenFilePath(INI,openExtRunList["folder"] " " openExtRunList_Parm["folder"])
Return

Menu_OpenRAPath: ; RA路径
	Gosub, Label_HideSearchBar
	OpenFilePath(A_AhkPath,openExtRunList["folder"] " " openExtRunList_Parm["folder"])
Return

Menu_OpenEvFullPath: ; 无路径缓存路径
	Gosub, Label_HideSearchBar
	OpenFilePath(INI_Path,openExtRunList["folder"] " " openExtRunList_Parm["folder"])
Return

Menu_Reload: ; 重启搜索框
	RegRead, RunAny_SearchBar_RAEvFullPathIniTime_reg, HKEY_CURRENT_USER\Software\RunAny, RunAny_SearchBar_RAEvFullPathIniTime
	FileGetTime, RunAny_SearchBar_RAEvFullPathIniTime, %INI_EvFullPath%, M  ; 获取修改时间.
	If (RunAny_SearchBar_RAEvFullPathIniTime_reg!=RunAny_SearchBar_RAEvFullPathIniTime){
		RegWrite, REG_SZ, HKEY_CURRENT_USER\Software\RunAny, RunAny_SearchBar_RAEvFullPathIniTime, %RunAny_SearchBar_RAEvFullPathIniTime%
		Send_WM_COPYDATA("RunAny_SearchBar", rAAhkMatch)
	}
	Gosub, SearchBar_Reload
Return

SearchBar_Reload: ; 重启搜索框
	Gosub,Label_HideSearchBar
	try Reload
	Sleep, 1000
	Run, %A_AhkPath%%A_Space%"%A_ScriptFullPath%"
	ExitApp
Return

Menu_ReGenerate: ; 重新初始化搜索框
	MsgBox, 305, 搜索框初始化！,配置文件将全部重新生成！`n`n确定要初始化吗？
	IfMsgBox OK
	{
		Critical On
		result := Send_WM_COPYDATA("RunAny_SearchBar", rAAhkMatch)
		Send_WM_COPYDATA("runany[ShowTrayTip](SearchBar搜索框,重新初始化成功!,20,17)", rAAhkMatch)
		FileCopy, %INI%, %A_ScriptDir%\backup, 1
		FileCopy, %SearchBar_Custom_Ahk_Path%, %A_ScriptDir%\backup, 1
		initINI()
		initCustomAHK()
		Gosub,SearchBar_Reload
	}
Return

Menu_ReloadRA: ; 重启RA
	result := Send_WM_COPYDATA("Menu_Reload", rAAhkMatch,1)
Return

Menu_Run: ; 运行软件
	Gosub, Label_Submit
Return

Menu_OpenINI: ; 打开配置文件
	EditFile(INI,openExtRunList["ini"] " " openExtRunList_Parm["ini"])
Return

Menu_OpenCustom: ; 打开自定义文件
	EditFile(A_ScriptDir "\RunAny_SearchBar_Custom.ahk", openExtRunList["ahk"] " " openExtRunList_Parm["ahk"])
Return

Menu_OpenHelp: ; 打开帮助文档
	If (openExtRunList["html"]){
		WEB_Open_Exe := openExtRunList["html"] " " openExtRunList_Parm["html"]
		Run, %WEB_Open_Exe% "https://docs.qq.com/doc/DWHZnWFdlS0VxYUl1"
	}Else 
		Run, "https://docs.qq.com/doc/DWHZnWFdlS0VxYUl1" 
Return

Menu_RunAdmin: ; 管理员运行软件
	Content := menu_key
	Gosub, Label_HideSearchBar
	Run,*RunAs %menu_value%
	ChangeFrequency()
Return

Menu_CloseApp: ; 关闭软件
	Gosub, Label_HideSearchBar
	SplitPath, menu_value , , , ,OutNameNoExt
	CloseApp(OutNameNoExt ".exe",MenuObjIcon[menu_key],menu_key)
Return

Menu_OpenExePath: ; 打开exe软件路径
	Gosub, Label_HideSearchBar
	OpenFilePath(menu_value,openExtRunList["folder"] " " openExtRunList_Parm["folder"])
Return

Menu_OpenLnkPath: ; 打开lnk软件路径
	Gosub, Label_HideSearchBar
	OpenFilePath(menu_value,openExtRunList["folder"] " " openExtRunList_Parm["folder"],1)
Return

Menu_CopyExePath: ; 复制软件路径
	SplitPath, menu_value , , OutDir
	Clipboard := OutDir
	Send_WM_COPYDATA("runany[ShowTrayTip](【软件路径】已复制," OutDir ",20,17)", rAAhkMatch)
Return

Menu_RAOneKeyReach_Edit: ; RA一键直达-搜索框
	ControlFocus,,ahk_id %My_Edit_Hwnd%
	SendInput, ^a
	result := Send_WM_COPYDATA("Menu_Show", rAAhkMatch, 10)
Return

Menu_RAOneKeyReach: ; RA一键直达
	result := Send_WM_COPYDATA("Menu_Show", rAAhkMatch, 10)
Return

Menu_Copy_menu_key: ; 复制菜单名称
	Clipboard := menu_key
	Send_WM_COPYDATA("runany[ShowTrayTip](【菜单名称】已复制," menu_key ",20,17)", rAAhkMatch)
Return

Menu_Copy_menu_value: ; 复制菜单值
	Clipboard := menu_value
	Send_WM_COPYDATA("runany[ShowTrayTip](【" menu_copy_name "】已复制," menu_value ",20,17)", rAAhkMatch)
Return

Menu_Frequency_zero: ; 计数清零
	MsgBox, 1,, 确定将【%menu_key%】计数清零吗？
	IfMsgBox OK
		ChangeFrequency(menu_key,,0)
Return

Menu_Run_Search_32770:
	If (index_temp=RA_menu){	
		Content := menu_key
		Content_Path := 0
	}Else{
		Search_32770_Path := menu_value
	}
	Gosub,Label_Submit
Return

Menu_OpenExePath_Search_32770:
	If (index_temp=RA_menu){		
		Content := menu_key
		Content_Path := 1
	}Else{
		Search_32770_Path := menu_value
	}
	Gosub,Label_Submit
Return

Plus_Menu: ; 加号菜单
	AddMenu("路径-搜索框","Menu_OpenINIPath","imageres.dll",5)
	AddMenu("路径-RunAny","Menu_OpenRAPath","imageres.dll",5)
	AddMenu("路径-无路径缓存","Menu_OpenEvFullPath","imageres.dll",5)
	AddMenu("重启-搜索框","Menu_Reload","shell32.dll",239)
	AddMenu("重启-初始化搜索框","Menu_ReGenerate","shell32.dll",298)
	AddMenu("重启-RA","Menu_ReloadRA","ZzIcon.dll",2)
	AddMenu("打开-配置文件","Menu_OpenINI","imageres.dll",65)
	AddMenu("打开-自定义文件","Menu_OpenCustom","imageres.dll",103)
	AddMenu("打开-帮助文档","Menu_OpenHelp","imageres.dll",100)
	AddMenu("指令",":RA_SearchBar_Instruction","imageres.dll",102)
Return

Edit_Menu: ; 输入框菜单
	GuiControlGet, Edit_OutputVar, ,%My_Edit_Hwnd%
	If (Edit_OutputVar="" || !is_can_run_fun){
		Gosub, Plus_Menu
	}Else{
		MenuValueMenu(1)
	}
	If (Search_32770=0 && Edit_OutputVar!=""){
		AddMenu("Ra-一键直达","Menu_RAOneKeyReach_Edit","ZzIcon.dll",1)
	}
Return

ListView_Menu: ; 候选项菜单
	MenuValueMenu(LV_GetNext())
Return

MenuValueMenu(index){ ;不同菜单项对应菜单
	menu_is_running := 0
	LV_GetText(menu_key, index, 2)
	LV_GetText(menu_value, index, 3)
	SplitPath, menu_value , , , OutExtension, OutNameNoExt
	OutExtension := StrSplit(OutExtension, A_Space)[1]
	ico := StrSplit(CandidateList[4*index-1], ",")
	FileGetAttrib, Attributes, %menu_value%
	If (Search_32770!=0 && RegExMatch(menu_value, "[a-zA-Z]:\\")){
		if InStr(Attributes, "D"){
			menu_tip_name := "路径"
			AddMenu("打开路径","Menu_Run_Search_32770","imageres.dll",5)
			AddMenu("打开上层路径","Menu_OpenExePath_Search_32770","imageres.dll",5)
		}Else{
			menu_tip_name := "文件"
			AddMenu("打开文件","Menu_Run_Search_32770","imageres.dll",5)
			AddMenu("打开所在路径","Menu_OpenExePath_Search_32770","imageres.dll",5)
		}
		Return
	}
	if InStr(Attributes, "D"){
		menu_tip_name := "路径"
		AddMenu("打开路径","Menu_Run","imageres.dll",5)
		menu_copy_name := "路径"
	}Else If (RegExMatch(menu_value,"S).+?\[.+?\]%?\(.*?\)")){
		menu_tip_name := "插件"
		AddMenu("运行插件","Menu_Run",ico[1],ico[2])
		menu_copy_name := "插件名称"
	}Else If (RegExMatch(menu_value,"i)http://|https://|www\.|ftp://.*")){
		menu_tip_name := "网址"
		AddMenu("打开网址","Menu_Run",ico[1],ico[2])
		menu_copy_name := "网址"
	}Else If (OutExtension=""){
		menu_tip_name := "菜单"
		If (new_menu_key=""){
			temp := Radio_names[index_temp]
			menu_tip_name := "内容"
		}
		If (ico[1])
			AddMenu("运行-" temp,"Menu_Run",ico[1],ico[2])
		Else
			AddMenu("运行-" temp,"Menu_Run","shell32.dll",56)
		menu_copy_name := "菜单值"
	}Else If (OutExtension="exe" || OutExtension="msc"){
		menu_tip_name := "软件"
		Process,Exist,%OutNameNoExt%.exe
		AddMenu("运行软件","Menu_Run",ico[1],ico[2])
		AddMenu("管理员运行","Menu_RunAdmin","imageres.dll",74)
		if(ErrorLevel=0){
			AddMenu("关闭软件","Menu_CloseApp","imageres.dll",162)
			Menu, RA_SearchBar, Disable, 关闭软件
		}
		Else{
			AddMenu("关闭软件*","Menu_CloseApp","imageres.dll",162)
			menu_is_running := 1
		}
		AddMenu("打开软件路径","Menu_OpenExePath","imageres.dll",5)
		AddMenu("复制-软件路径","Menu_CopyExePath","imageres.dll",150)
		menu_copy_name := "软件全路径"
	}Else{
		menu_tip_name := "文件"
		AddMenu("打开文件","Menu_Run",ico[1],ico[2])
		AddMenu("打开文件目录","Menu_OpenExePath","imageres.dll",5)
		If (OutExtension="lnk")
			AddMenu("打开lnk目标文件目录","Menu_OpenLnkPath","shell32.dll",264)
		menu_copy_name := "文件全路径"
	}
	GuiControlGet, CommandChoice_isVisible, Visible, CommandChoice
	if(CommandChoice_isVisible){
		AddMenu("复制-" menu_copy_name,"Menu_Copy_menu_value","imageres.dll",150)
		AddMenu("复制-菜单名称","Menu_Copy_menu_key","imageres.dll",151)
		AddMenu("计数清零","Menu_Frequency_zero","imageres.dll",151)
	}
}

GuiContextMenu(GuiHwnd, CtrlHwnd, EventInfo, IsRightClick, X, Y){ ; 右键功能
	Critical, On
	If (CtrlHwnd=ListView_Hwnd){
		If (menu_pos_mouse=1){
			MouseGetPos, menu_pos_x, menu_pos_y
		}Else{
			menu_pos_x := A_GuiX + Edit_width * (width_1 + width_2)
			menu_pos_y := A_GuiY + ListView_h * 0.5
			menu_pos_mouse := 1
		}
	}Else{
		MouseGetPos, menu_pos_x, menu_pos_y
	}
	MenuFix(CtrlHwnd)
	Critical, Off
}

PluseEvent(CtrlHwnd, GuiEvent, EventInfo, ErrLevel:=""){ ; 加号功能
	If (GuiEvent="DoubleClick"){
		EditFile(INI,openExtRunList["ini"] " " openExtRunList_Parm["ini"])
	}
}

RadioEvent(CtrlHwnd, GuiEvent, EventInfo, ErrLevel:=""){ ; 单选框改变时的样式改变
	If (GuiEvent = "Normal"){
		GuiControlGet, OutputVar, Focus 
		SelectWhichRadio( StrReplace(OutputVar, "button"))
	}Else If (GuiEvent = "DoubleClick"){
		EditFile(A_ScriptDir "\RunAny_SearchBar_Custom.ahk", openExtRunList["ahk"] " " openExtRunList_Parm["ahk"])
	}
}

getCandidateCommon(Obj,default_Icon_number:=4,ObjIcon:="",WhichToExe:=2){ ; 获取搜索结果
	If (Edit_OutputVar="")
		Return
	CandidateList := Object()
	full_match := 0	; 有完全匹配项则不会重复搜索，消除自动补全BUG
	Candidates_num := 1
	NoRepeatObj := Object()
	If (SaveFrequency=1){
		If (index_temp=RA_menu)
			Frequency_Obj := RA_Frequency_Obj
		Else If (index_temp=RA_ChromeBookmarks)
			Frequency_Obj := ChromeBookmarks_Frequency_Obj
	}
    For ki, kv in Obj
	{
		If (kv="")
			Continue
		a := InStr(ki, Edit_OutputVar) || InStr(ChToPy.allspell(ki), Edit_OutputVar) || InStr(ChToPy.initials(ki), Edit_OutputVar)
		If (EvFullPath.HasKey(kv) || RegExMatch(kv, "iS)[a-z]:\\.*")) {
			SplitPath, kv, OutFileName
			OutFileName := RegExReplace(OutFileName, "iS)()\.exe.*","$1")
			a := a || InStr(OutFileName, Edit_OutputVar)
		}Else If (RegExMatch(kv, "iSU)(http:|https:|www\.|ftp:)//(.*)/.*", OutUrl)){
			OutUrl := RegExReplace(OutUrl2, "iS)www\.|\.com|\.cn|\.top|\.net")
			a := a || InStr(OutUrl, Edit_OutputVar)
		}	
		If (!NoRepeatObj.HasKey(kv) && a!=0){
			ico_path := WhichToExe=2?ObjIcon[ki]:ObjIcon[kv]
			if (Search_32770!=0){
				If !(RegExMatch(kv, "[a-zA-Z]:\\"))
					Continue
			}
			If (ico_path=""){
				match_content := SubStr(kv,1,10)
				If (RegExMatch(kv,"iS).+?\[.+?\]%?\(.*?\)")){
					ico_path := "shell32.dll," 131
				}Else If RegExMatch(match_content,"iS)http://|https://|www\.|ftp://.*"){
					ico_path := "shell32.dll," 44
				}Else If RegExMatch(match_content, "iS)[a-z]:\\.*"){
					ico_path := "shell32.dll," 4
				}Else{
					ico_path := "shell32.dll," default_Icon_number
				}
			}
			If (SaveFrequency=1){
				Frequency := Frequency_Obj[ki]
				insertPos := 0
				Loop, % CandidateList.Length()/4{ ; ListView插入对应值
					Fre := CandidateList[4*A_Index]
					If (Fre>Frequency)
						insertPos += 1
					Else{
						Break
					}
				}
				CandidateList.InsertAt(4*insertPos+1,ki,kv,ico_path,Frequency)
			}Else
				CandidateList.Push(ki,kv,ico_path,0)
			Candidates_num +=1
			NoRepeatObj[kv]:=1
		}
		If (ki=Edit_OutputVar){
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

getCandidateEverything(){ ; 获取EV搜索结果
	If (Edit_OutputVar="")
		Return
	CandidateList := Object()
	CandidateList_ExtraInfo := Object()
	evSearchStr := Edit_OutputVar " " EvCommand
    ev.SetSearch(evSearchStr)
    if(!ev.Query()){
    	Critical on
    	Thread, NoTimers , True
    	DetectHiddenWindows on
    	If (!WinExist("ahk_exe Everything.exe"))
    		Run,%RA_Everything_EvPath% -startup
    	WinWait, ahk_exe Everything.exe, ,5
    	DetectHiddenWindows off
    	Thread, NoTimers , false
    	Critical off
    	Return getCandidateEverything()
    }
    evresCount := ev.GetTotResults()
    evresCount := evresCount<=Candidates_num_max?evresCount:Candidates_num_max
    Loop,% evresCount
	{
		ResultFileName := ev.GetResultFileName(A_Index-1)
		objFullPathName := ev.GetResultFullPathName(A_Index-1)
		FileGetAttrib, Attributes, %objFullPathName%
		if InStr(Attributes, "D")
			ico_path := "shell32.dll," 4
		Else{
			SplitPath, ResultFileName , , , OutExtension
			ico_path := openExtRunList[OutExtension]
			If (ico_path=""){
				If (OutExtension="lnk")
					ico_path := "shell32.dll," 264
				Else If (OutExtension="exe") && !InStr(objFullPathName, Onedrive){
					ico_path := objFullPathName
				}Else{
					If (OutExtension="exe")
						ico_path := "shell32.dll," 1
					Else
						ico_path := GetFileAssocIcon(OutExtension)
					If (ico_path="" || ico_path="None")
						ico_path := "shell32.dll," 1
				}
			}
		}
		FileGetSize, FileSize, %objFullPathName%
		FileGetTime, FileTime, %objFullPathName%
		FileSize := FileSizeFormat(FileSize)
		FormatTime, FileTime , %FileTime%
		ExtraInfo := Object()
		ExtraInfo["文件大小"] := FileSize
		ExtraInfo["文件修改时间"] := FileTime
		if (!InStr(Attributes, "D") && EV_File_Priority_Show=1){
			CandidateList.InsertAt(1,ResultFileName,objFullPathName,ico_path,0)
			CandidateList_ExtraInfo.InsertAt(1,ExtraInfo)
		}Else{		
			CandidateList.Push(ResultFileName,objFullPathName,ico_path,0)
			CandidateList_ExtraInfo.Push(ExtraInfo)
		}
	}
    Return CandidateList
}

FileSizeFormat(FileSize){ ; 格式化文件大小
	unit := 0
	Loop, 5{
		If (FileSize<1024)
			Break
		Else{
			FileSize := FileSize/1024
			unit ++
		}
	}
	If (unit=0)
		unit := "B"
	Else If (unit=1)
		unit := "KB"
	Else If (unit=2)
		unit := "MB"
	Else If (unit=3)
		unit := "GB"
	Else If (unit=4)
		unit := "TB"
	return Round(FileSize, 2) " " unit
}

getRunningCandidate(Obj,default_Icon_number:=4,ObjIcon:="",WhichToExe:=2){ ; 获取已运行软件搜索结果
	NoRepeatObj := Object()
	runContent := LTrim(SubStr(Edit_OutputVar, 4))
	If (RunningCandidateComplete=1 && runContent){
		CandidateList := Object()
		Loop, % RunningCandidateList.Length()/4
		{
			ki := RunningCandidateList[4*A_Index-3]
			kv := RunningCandidateList[4*A_Index-2]
			a := InStr(ki, runContent) || InStr(ChToPy.allspell(ki), runContent) || InStr(ChToPy.initials(ki), runContent)
			SplitPath, kv, OutFileName
			OutFileName := RegExReplace(OutFileName, "iS)()\.exe.*","$1")
			a := a || InStr(OutFileName, runContent)
			If (a){
				ico_path := WhichToExe=2?ObjIcon[ki]:ObjIcon[kv]
				CandidateList.Push(ki,kv,ico_path,0)
				NoRepeatObj[kv]:=1		
			}
		}
	    Return CandidateList
	}
	RunningCandidateList := Object()
    For ki, kv in Obj
	{
		If (kv="")
			Continue
		SplitPath, kv, OutFileName, OutDir, OutExtension
		OutFileName := StrSplit(OutFileName, A_Space)[1]
		OutExtension := StrSplit(OutExtension, A_Space)[1]
		If (OutExtension!="exe")
			Continue
		Process,Exist,%OutFileName%
		if(!NoRepeatObj.HasKey(OutFileName) && ErrorLevel!=0){
			WinGet, OutputVar, ProcessPath , ahk_pid %ErrorLevel%
			If (OutputVar="" || OutputVar=OutDir "\" OutFileName){
				ico_path := WhichToExe=2?ObjIcon[ki]:ObjIcon[kv]
				RunningCandidateList.Push(ki,kv,ico_path,0)
				NoRepeatObj[OutFileName]:=1		
			}
		}
		RunningCandidateComplete := 1
    }
    Return RunningCandidateList
}

executeCandidateWhich(whichColumn:=2){ ; 执行搜索结果的哪一列
	RowNumber := LV_GetNext()
	If (RowNumber!=0){
		LV_GetText(Content_Execute, LV_GetNext(), whichColumn)
	}Else If (LV_GetCount()!=0 && is_run_first){		
		If (Candidate_Index != 0)	
			LV_GetText(Content_Execute, Candidate_Index, whichColumn)
		Else
			LV_GetText(Content_Execute, 1, whichColumn)
		Candidate_Index := 0		
	}Else{
		GuiControlGet, Content_Execute, ,%My_Edit_Hwnd%
	}
}

initResetINI() { ; 定时重新加载配置文件
	FileGetTime, mtime_ini_path, %INI%, M ; 获取修改时间.
	FileGetTime, mtime_CustomAHK_path, %A_ScriptDir%\RunAny_SearchBar_Custom.ahk, M ; 获取修改时间.
	RegWrite, REG_SZ, HKEY_CURRENT_USER\Software\RunAny, %INI%, %mtime_ini_path%
	RegWrite, REG_SZ, HKEY_CURRENT_USER\Software\RunAny, %A_ScriptDir%\RunAny_SearchBar_Custom.ahk, %mtime_CustomAHK_path%
	if (Auto_Reload_MTime>0)
	{
		SetTimer, Auto_Reload_MTime, %Auto_Reload_MTime%
	}
}

Auto_Reload_MTime: ; 定时重新加载脚本
	RegRead, mtime_ini_path_reg, HKEY_CURRENT_USER\Software\RunAny, %INI%
	RegRead, mtime_CustomAHK_path_reg, HKEY_CURRENT_USER\Software\RunAny, %A_ScriptDir%\RunAny_SearchBar_Custom.ahk
	FileGetTime, mtime_ini_path, %INI%, M ; 获取修改时间.
	FileGetTime, mtime_CustomAHK_path, %A_ScriptDir%\RunAny_SearchBar_Custom.ahk, M ; 获取修改时间.
	if (mtime_ini_path_reg != mtime_ini_path || mtime_CustomAHK_path_reg != mtime_CustomAHK_path)
		Gosub,SearchBar_Reload
Return

Init_Custom_Fun: ; 执行自定义功能标签
	FileGetTime, mtime_CustomAHK_path, %A_ScriptDir%\RunAny_SearchBar_Custom.ahk, M ; 获取修改时间.
	if !mtime_CustomAHK_path{
		initCustomAHK()
		Gosub,SearchBar_Reload
	}
	temp := "Fun"
	if IsLabel("Label_Custom_" temp)
		Gosub, Label_Custom_%temp%
Return

Change_CapsLock_State: ; 改变大小写状态
	If (is_auto_CapsLock){
		If CapsLock_List.HasKey(index_temp)
			SetCapsLockState, On
		Else
			SetCapsLockState, Off
	}
Return

initCustomAHK(){ ; 初始化自定义搜索功能的AHK
	FileDelete, %SearchBar_Custom_Ahk_Path%
	FileAppend,
(
;*************************************************
;* 【RA搜索框自定义功能（不用自启）】
;*************************************************
;tong
;【重要】：事先声明没有AHK基础不建议自行修改本文件，如出现错误无法解决，请关闭RA后删除本文件，将会自动初始化本文件
;【说明】：如果改动了本文件，请自行备份，避免丢失，重新下载RunAny_SearchBar.ahk不会覆盖本文件
;【建议】：自定义的变量和辅助函数加上建议使用 SearchCustom_ 前缀避免重名冲突
;【添加自定义搜索功能步骤】：【百度一下】为参考案例
	;1.【Radio_names】添加对应功能名称
	;2.【RA_suffix】、【RA_menu】与步骤1中【后缀菜单】、【菜单项】位置对应，请务必一一对应
	;3.【单选框对应功能】中按序号添加与【Radio_names】对应的功能
;------------------------------------------【自定义变量】-----------------------------------------
Label_Custom_Fun:
	global Radio_names := ["RA后缀","RA菜单","Ev搜索","浏览器书签"]
	global RA_suffix := 1			;后缀菜单对应位置
	global RA_menu := 2				;菜单项对应位置
	global RA_Everything := 3 		;Everything搜索功能
	global RA_ChromeBookmarks := 4 	;浏览器标签搜索
	global Radio_Default := 2		;默认搜索对应位置，默认为菜单项
Return

;----------------------------------------【单选框对应功能】----------------------------------------
fun_1:	;后缀菜单
	Gosub, suffix_fun
Return

fun_2:	;菜单项
	Gosub, menu_fun
Return

fun_3:	;EV搜索
	Gosub, Radio_Everything
Return

fun_4:	;浏览器标签搜索
	Gosub, Radio_ChromeBookmarks
Return

;----------------------------------------【辅助函数位置】----------------------------------------
	), %A_ScriptDir%\RunAny_SearchBar_Custom.ahk, UTF-8
}

CloseApp(program,Icopath:="",name:=""){ ; 关闭指定软件
	ico := StrSplit(Icopath, ",")
	ico_path := ico[1], ico_num := ico[2]
	If (name="")
		name := program
	file_name := A_Temp "\RunAny\RunPlugins\SearchBarCloseApp.ahk"
	if(!FileExist(A_Temp "\RunAny\RunPlugins"))
		FileCreateDir, %A_Temp%\RunAny\RunPlugins
	if(FileExist(file_name))
		FileDelete, %file_name%
	FileAppend,
	(
#NoEnv
#SingleInstance Force
try
	Menu, Tray, Icon, %ico_path%, %ico_num%
is_success := 0
Process,Exist,%program%
if(ErrorLevel=0){
	is_success := 2
}Else{
	PostMessage,0x0012 ,,,,ahk_exe %program%
	Loop, 5{
		Process,Exist,%program%
		if(ErrorLevel=0){
			is_success := 1
			break
		}
		Sleep, 100
	}
	If (is_success = 0){
		Process, Close, %program%
		Loop, 5{
			Process,Exist,%program%
			if(ErrorLevel=0){
				is_success := 1
				break
			}
			Sleep, 100
		}
	}
}
If (is_success=0)
	TrayTip, %name%：%program%, 关闭【失败】, 10, 20
Else If (is_success=1)
	TrayTip, %name%：%program%, 关闭【成功】, 10, 20
Else If (is_success=2)
	TrayTip, %name%：%program%, 相关进程【不存在】, 10, 20
Menu, Tray, Icon, shell32, 278
Sleep, 10000
ExitApp
	),%file_name%
	Run,*RunAs %A_AhkPath%%A_Space%%file_name%
}

ReadFromINI(INI_Path,Start_Index:=1) { ; 从INI文件读取至指定对象
	INIObj := Object()
	Loop, read, %INI_Path%
	{
		If (A_Index>=Start_Index){
			equalPos := InStr(A_LoopReadLine, "=")
			INIObj[SubStr(A_LoopReadLine, 1, equalPos-1)] := SubStr(A_LoopReadLine, equalPos+1)
		}
	}
	Return INIObj
}

EditFile(filePath,openExe:="edit") { ; 编辑指定文件
	if(!FileExist(ini)){
		MsgBox,16,%ini%,没有找到配置文件：%ini%
		Return
	}
	try
		Run,%openExe% "%filePath%"
	catch
		try
			Run,edit "%filePath%"
		Catch
			Run,notepad.exe "%filePath%"
}

OpenFilePath(OpenFile,Folder_Open_Exe:="explorer.exe /select,",OpenLnk:=0) { ; 打开文件路径,OpenLnk=1,仅打开lnk目标文件夹OpenLnk=2，全打开
	SplitPath, OpenFile, , , ext
	If (OpenLnk=0||OpenLnk=2){
		try
			Run, %Folder_Open_Exe% "%OpenFile%"
		Catch 
			Run, % "explorer.exe /select," OpenFile
	}
	if(OpenLnk=1 && ext="lnk"){
		FileGetShortcut, %OpenFile%, lnkTarget
		try
			Run, %Folder_Open_Exe% "%lnkTarget%"
		Catch {
			Run, % "explorer.exe /select," lnkTarget
		}
	}
}

URIEncode(str, encoding := "UTF-8") { ; URI转义
   VarSetCapacity(var, StrPut(str, encoding))
   StrPut(str, &var, encoding)

   While code := NumGet(Var, A_Index - 1, "UChar")  {
      bool := (code > 0x7F || code < 0x30 || code = 0x3D)
      UrlStr .= bool ? "%" . Format("{:02X}", code) : Chr(code)
   }
   Return UrlStr
}

initINI() { ; 初始化INI
	FileDelete, %INI%
	FileAppend,;使用说明: https://docs.qq.com/doc/DWHZnWFdlS0VxYUl1`n, %INI%
	FileAppend,;【RA搜索框配置文件】`n, %INI%
	FileAppend,;【说明】：后续版本如有新的配置项，请删除本文件重新生成或对比后自行修改添加`n, %INI%
	FileAppend,[基础配置]`n, %INI%
	FileAppend,配置版本=%SearchBar_Version%`n, %INI%
	FileAppend,自定义配置版本=%SearchBar_Version%`n, %INI%
	FileAppend,输入框是否自动填充=1`n, %INI%
	FileAppend,自动填充后禁用输入时间=500`n, %INI%
	FileAppend,是否回车自动执行第一个候选项=1`n, %INI%
	FileAppend,是否自动开启大写=1`n, %INI%
	FileAppend,对应菜单开启大写=1|2|4`n, %INI%
	FileAppend,切换输入法快捷键=`n, %INI%
	FileAppend,是否记住上次执行内容=0`n, %INI%
	FileAppend,配置更改自动重启时间=2000`n, %INI%
	FileAppend,Alt选择并执行=1`n, %INI%
	FileAppend,记录使用频率=1`n, %INI%
	FileAppend,显示使用频率=1`n, %INI%
	FileAppend,进入网页搜索后关闭大写=1`n, %INI%
	FileAppend,候选项选中提示=1`n, %INI%

	FileAppend,[热键配置]`n, %INI%
	FileAppend,正序切换=Tab`n, %INI%
	FileAppend,逆序切换=\`n, %INI%
	FileAppend,清空输入框=Delete`n, %INI%
	FileAppend,功能菜单热键=```n, %INI%
	FileAppend,向上选择=Up`n, %INI%
	FileAppend,向下选择=Down`n, %INI%
	FileAppend,选中执行=Space`n, %INI%
	FileAppend,信息提示上滚轮=PgUp`n, %INI%
	FileAppend,信息提示下滚轮=PgDn`n, %INI%

	FileAppend,[自定义关键字搜索]`n, %INI%
	FileAppend,;网页使用{URIquery}，非网页使用{query}`n, %INI%
	FileAppend,bd|百度|baidu=百度一下=https://www.baidu.com/s?wd={URIquery}`n, %INI%
	FileAppend,bz|B站|bzhan=B站=https://search.bilibili.com/all?keyword={URIquery}`n, %INI%
	FileAppend,zh|知乎|zhihu=知乎=https://www.zhihu.com/search?type=content&q={URIquery}`n, %INI%
	FileAppend,gh|github=github=https://github.com/search?q={URIquery}`n, %INI%
	FileAppend,ev=Ev搜索=`%EvPath`% -search "{query}"`n, %INI%

	FileAppend,[EV搜索配置]`n, %INI%
	FileAppend,;默认为RA中设置的EV路径和搜索规则`n, %INI%
	FileAppend,EV路径=`n, %INI%
	FileAppend,EV搜索规则=`n, %INI%
	FileAppend,文件优先展示=1`n, %INI%
	FileAppend,资源管理器中EV按目录搜索=1`n, %INI%

	FileAppend,[浏览器书签搜索配置]`n, %INI%
	FileAppend,;支持edge|chrome类型，可以自动识别edge和chrome书签路径`n, %INI%
	FileAppend,浏览器类型=edge`n, %INI%
	FileAppend,书签路径=`n, %INI%
	
	FileAppend,;【说明】：可针对不同分辨率显示器设置样式，请自行添加，默认为【1080P】的设置，详细参数说明请看RA官网说明或加RA群246308937`n, %INI%
	FileAppend,[搜索框样式配置]`n, %INI%
	FileAppend,[1920*1080]`n, %INI%
	FileAppend,搜索框x轴位置=0.5`n, %INI%
	FileAppend,搜索框y轴位置=0.2`n, %INI%
	FileAppend,搜索框位置模式=1`n, %INI%

	FileAppend,输入框字体颜色=black`n, %INI%
	FileAppend,输入框字体大小=25`n, %INI%
	FileAppend,输入框透明度=220`n, %INI%
	FileAppend,输入框宽度=800`n, %INI%
	
	FileAppend,上方搜索选项未选中时字体颜色=black`n, %INI%
	FileAppend,上方搜索选项选中时字体颜色=1e90ff`n, %INI%

	FileAppend,候选框字体颜色=black`n, %INI%
	FileAppend,候选框内最大行数=150`n, %INI%
	FileAppend,候选框显示最大行数=15`n, %INI%
	FileAppend,候选框内三列比例=0.08:0.28:0.64`n, %INI%
}

ChangeFrequency(Content:="",Frequency_Obj:="",Frequency:="",index:=""){ ; 更新使用频率
	If (SaveFrequency!=1)
		Return
	Content := Content=""?Content_Execute:Content
	index := index=""?index_temp:index
	If (index=RA_menu){
		Frequency_Obj := Frequency_Obj=""?RA_Frequency_Obj:Frequency_Obj
		FileReadLine, RecentComputer, %RA_FrequencyINI%, 1
	}Else If (index=RA_ChromeBookmarks){
		Frequency_Obj := Frequency_Obj=""?ChromeBookmarks_Frequency_Obj:Frequency_Obj
		FileReadLine, RecentComputer, %ChromeBookmarks_FrequencyINI%, 1
	}
	If (RecentComputer!=ComputerName)
		Lable_ReadFreINI(index)
	Frequency := Frequency=""?Frequency_Obj[Content]+1:Frequency
	If (Frequency="")
		Frequency_Obj[Content] := 1
	Else
		Frequency_Obj[Content] := Frequency
	If (index=RA_menu)
		SetTimer,Lable_Save_RA_menu_Frequency,-5000
	Else If (index=RA_ChromeBookmarks)
		SetTimer,Lable_Save_RA_ChromeBookmarks_Frequency,-5000
}

getFocusCtrlHwnd(){ ; 获取焦点控件
	ControlGetFocus, Control_Focus, ahk_id %WinID%
	ControlGet, FocusCtrlHwnd, Hwnd ,, %Control_Focus%
	Return FocusCtrlHwnd
}

GetVersionComp(SearchBar_Version_INI){ ; 获取版本字符串
	NewStr := StrReplace(SearchBar_Version_INI, ".")
	If (StrLen(NewStr)=3){
		NewStr := NewStr . "0"
	}
	Return NewStr
}

Change32770Path(dir,win_id,file_name:=""){ ; 改变保存对话框路径
	Control, Disable,, edit1, ahk_id %win_id%
	ControlFocus, edit1, ahk_id %win_id%
	ControlSetText, edit1, %dir%, ahk_id %win_id%
	ControlSend, edit1,{Enter}, ahk_id %win_id%
	Control, Enable,, edit1, ahk_id %win_id%
	WinActivate,ahk_id %win_id%
	ControlSetText, edit1, %file_name%, ahk_id %win_id%
	ControlSend, edit1, {End}, ahk_id %win_id%
}

ChangeRAPath(Content,win_id){ ; RA选择菜单项或路径
	Control, Disable,, edit1, ahk_id %win_id%
	ControlFocus, edit1, ahk_id %win_id%
	ControlSetText, edit1, %Content%, ahk_id %win_id%
	ControlSend, edit1, {End}, ahk_id %win_id%
	Control, Enable,, edit1, ahk_id %win_id%
	WinActivate,ahk_id %win_id%
}

Lable_ReadFreINI(index:=0){ ; 读取频率INI文件
	If (RA_menu!="" && (index=RA_menu||index=0)){
		Loop, read, %RA_FrequencyINI%
		{
			Fre := StrSplit(A_LoopReadLine, "=====")
			If (MenuObj.HasKey(Fre[1])){
				RA_Frequency_Obj[Fre[1]] := Fre[2]
			}
		}
	}
	If (RA_ChromeBookmarks!="" && (index=RA_ChromeBookmarks||index=0)){
		Loop, read, %ChromeBookmarks_FrequencyINI%
		{
			Fre := StrSplit(A_LoopReadLine, "=====")
			If (Chrome_Bookmarks_Obj.HasKey(Fre[1])){
				ChromeBookmarks_Frequency_Obj[Fre[1]] := Fre[2]
			}
		}
	}

}

Lable_Save_RA_menu_Frequency: ; 保存RA频率
	saveFrequency(RA_FrequencyINI,RA_Frequency_Obj)
Return

Lable_Save_RA_ChromeBookmarks_Frequency: ; 保存浏览器书签频率
	saveFrequency(ChromeBookmarks_FrequencyINI,ChromeBookmarks_Frequency_Obj)
Return

saveFrequency(FrequencyINI,Frequency_Obj){ ; 记录使用频率INI
	file := FileOpen(FrequencyINI, "w")
	File.WriteLine(ComputerName)
	For ki, kv in Frequency_Obj {
		file.WriteLine(ki "=====" kv)
	}
	file.Close()
}

Label_Create_Menu: ; 创建菜单
	Menu, RA_SearchBar, Add
	Menu, RA_SearchBar, DeleteAll
	Menu, RA_SearchBar_Instruction, Add, run->查看已运行软件, Menu_RASearchCommand_run
	Menu, RA_SearchBar_Instruction, Icon, run->查看已运行软件, shell32.dll, 77, %MenuIconSize%
	Menu, RA_SearchBar_Instruction, Add
	Loop, parse, Custom_Web_Search, `n, `r
	{

	    Array := StrSplit(A_LoopField , "=", ,3)
	    key := Array[1]
	    Name := Array[2]
	    ico_file_path := A_ScriptDir "\Icos\" Name ".ico"
	    Menu, RA_SearchBar_Instruction, Add, %key%->%Name%, Menu_RASearchCommand_run
	    If FileExist(ico_file_path)
			Menu, RA_SearchBar_Instruction, Icon, %key%->%Name%, %ico_file_path%,, %MenuIconSize%
		Else
			Menu, RA_SearchBar_Instruction, Icon, %key%->%Name%, shell32.dll, 77, %MenuIconSize%
	}
Return

Label_Create_Hotkey: ; 创建热键
	Hotkey, IfWinActive, ahk_id %WinID%
	if (Forward_Switch != "") ; 正序切换
		Hotkey, %Forward_Switch%, Lable_Hotkey_Forward_Switch
	if (Backward_Switch != "") ; 逆序切换
		Hotkey, %Backward_Switch%, Lable_Hotkey_Backward_Switch
	if (Empty_Content != "") ; 清空输入框
		Hotkey, %Empty_Content%, Lable_Hotkey_Empty_Content
	if (Content_Menu != "") ; 功能菜单热键
		Hotkey, %Content_Menu%, Lable_Hotkey_Content_Menu

	if (InfoText_WheelUp != "") ; 信息提示上滚轮
		Hotkey, %InfoText_WheelUp%, Lable_Hotkey_InfoText_WheelUp
	if (InfoText_WheelDown != "") ; 信息提示下滚轮
		Hotkey, %InfoText_WheelDown%, Lable_Hotkey_InfoText_WheelDown

	Hotkey, If, (WinActive("ahk_id" WinID) && !WinExist("ahk_class #32768"))
	if (Up_Switch != "") ; 向上选择
		Hotkey, %Up_Switch%, Lable_Hotkey_Up_Switch
	if (Down_Switch != "") ; 向下选择
		Hotkey, %Down_Switch%, Lable_Hotkey_Down_Switch

	Hotkey, If, (WinActive("ahk_id" WinID) && getFocusCtrlHwnd()=ListView_Hwnd && !WinExist("ahk_class #32768"))
	if (Select_Enter != "") ; 选中执行
		Hotkey, %Select_Enter%, Lable_Hotkey_Select_Enter
Return
;----------------------------------------【热键绑定标签】----------------------------------------
Lable_Hotkey_Forward_Switch:
	SelectWhichRadio(Mod(index_temp+1, len_Radio+1)=0 ? 1 : Mod(index_temp+1, len_Radio+1))
Return

Lable_Hotkey_Backward_Switch:
	SelectWhichRadio(Mod(index_temp-1, len_Radio+1)=0 ? len_Radio : Mod(index_temp-1, len_Radio+1))
Return

Lable_Hotkey_Empty_Content:
	ControlFocus,,ahk_id %My_Edit_Hwnd%
	GuiControl, Text, %My_Edit_Hwnd%
	GuiControl, Hide, CommandChoice
Return

Lable_Hotkey_Content_Menu:
	menu_pos_mouse := 0
	Gosub, Hotkey_Menu
Return

Lable_Hotkey_InfoText_WheelUp:
	ControlClick, , ahk_id %InfoText_Hwnd%, , WheelUp
Return

Lable_Hotkey_InfoText_WheelDown:
	ControlClick, , ahk_id %InfoText_Hwnd%, , WheelDown
Return

Lable_Hotkey_Up_Switch:
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

Lable_Hotkey_Down_Switch:
	ControlFocus,,ahk_id %ListView_Hwnd%
	RowNumber := LV_GetNext(0)
	If (RowNumber = 0 || RowNumber=LV_GetCount()){
		LV_Modify(1, "+Focus +Select +Vis")
	}Else{
		LV_Modify(RowNumber+1, "+Focus +Select +Vis")
	}
Return

Lable_Hotkey_Select_Enter:
	SendInput {Enter}
Return

Label_WinWait32770: ; 等待激活32770
	global Complete32770HwndsObj := Object()
	loop
	{
		WinWaitActive ,ahk_class #32770
		32770Hwnd := WinActive("A")
		If !Complete32770HwndsObj.HasKey(32770Hwnd){
			Complete32770HwndsObj[32770Hwnd]:=1
			Sleep,100
			Change32770Path("C:\Users\tong\OneDrive\softwares\TotalLanch\KBLAutoSwitch",32770Hwnd)
		}
		Loop
		{
			For K, V in Complete32770HwndsObj
				WinWaitNotActive ,ahk_id %K%
			If !Complete32770HwndsObj.HasKey(WinActive("A")){
				SetTimer, CheckSpace32770Hwnds,-1000
				Break
			}
		}
	}
Return

CheckSpace32770Hwnds:
	For K, V in Complete32770HwndsObj
	{
		If !WinExist("ahk_id" K)
			Complete32770HwndsObj.Delete(K)
	}
Return

Label_ClearMEM: ; 清理内存
	pid:=() ? DllCall("GetCurrentProcessId") : pid
    h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
    DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
    DllCall("CloseHandle", "Int", h)
Return

RegExMatchAllContent(ByRef Haystack, NeedleRegEx, SubPat=""){ ; 正则全匹配
	arr := [], startPos := 1
	while ( pos := RegExMatch(Haystack, NeedleRegEx, match, startPos) ) {
		AAA:=match%SubPat%
		arr.push(match%SubPat%)
		startPos := pos + StrLen(match)
	}
	return arr.MaxIndex() ? arr : ""
}

Get_Zz(copyKey:="^c",extraHotKey:=""){ ; 获取选中内容
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

;-------------------------------------------【额外功能函数】------------------------------------------
Label_RA_Everything: ; 获取EV路径
	If (FileExist(RA_Everything_EvPath))
		Return
	SplitPath, A_AhkPath, , RunAnyConfigDir
	IniRead, RA_Everything_EvPath, %RunAnyConfigDir%\RunAnyConfig.ini, Config, EvPath, %A_Space%
	Transform, RA_Everything_EvPath, Deref, % RA_Everything_EvPath
	If (RA_Everything_EvPath="")
		WinGet, RA_Everything_EvPath, ProcessPath, ahk_exe Everything.exe
	global EvPath := RA_Everything_EvPath
Return

Label_RA_ChromeBookmarks: ; 读取浏览器书签
	StartTick:=A_TickCount
	If (!FileExist(RA_ChromeBookmarks_Path)){
		If (RA_ChromeBookmarks_Type="edge")
			RA_ChromeBookmarks_Path := "C:\Users\" A_UserName "\AppData\Local\Microsoft\Edge\User Data\Default\Bookmarks"
		Else
			RA_ChromeBookmarks_Path := "C:\Users\" A_UserName "\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"
	}
	If (RA_ChromeBookmarks_Type="edge")
		Chrome_Bookmarks_RegEx = "name": ".*?\s*.*?\s*.*?\s*"type": "url",\s*"url": ".*"
	Else
		Chrome_Bookmarks_RegEx = "name": ".*\s*"type": "url",\s* "url": ".*"
	Chrome_Bookmarks_INI_path := A_ScriptDir "\Chrome_Bookmarks\Chrome_Bookmarks_" RA_ChromeBookmarks_Type ".txt"
	RegRead, mtime_RA_ChromeBookmarks_Path_reg, HKEY_CURRENT_USER\Software\RunAny, %RA_ChromeBookmarks_Path%
	FileGetTime, mtime_RA_ChromeBookmarks_Path, %RA_ChromeBookmarks_Path%, M  ; 获取修改时间.
	If !FileExist(RA_ChromeBookmarks_Path){

	}Else If (!FileExist(Chrome_Bookmarks_INI_path) || mtime_RA_ChromeBookmarks_Path_reg != mtime_RA_ChromeBookmarks_Path){
		FileCreateDir, %A_ScriptDir%\Chrome_Bookmarks
		FileRead, Chrome_Bookmarks,*P65001 %RA_ChromeBookmarks_Path%
		Chrome_Bookmarks_name_RegEx = iS)"name": ".*"
		Chrome_Bookmarks_url_RegEx = iS)"url": ".*"
		Chrome_Bookmarks := RegExMatchAllContent(Chrome_Bookmarks, Chrome_Bookmarks_RegEx)
		file := FileOpen(Chrome_Bookmarks_INI_path, "w")
		t2 := A_TickCount
		loop % Chrome_Bookmarks.Length()
		{
			Chrome_Bookmarks_Item := Chrome_Bookmarks[A_Index]
			RegExMatch(Chrome_Bookmarks_Item, Chrome_Bookmarks_name_RegEx, Chrome_Bookmarks_name, 1)
			RegExMatch(Chrome_Bookmarks_Item, Chrome_Bookmarks_url_RegEx, Chrome_Bookmarks_url, 1)
			FileAppend_Content := SubStr(Chrome_Bookmarks_name, 10, -1) "=====" SubStr(Chrome_Bookmarks_url, 9, -1)
			file.WriteLine(FileAppend_Content)
			t1:=A_TickCount-StartTick
			If (t1>5000 && (t2-t1)>500){
				t2 = t1
				progress_Bookmarks := A_Index/Chrome_Bookmarks.Length()*100
				progress_Bookmarks := Round(progress_Bookmarks, 2)
				ToolTip,RA搜索框---当前浏览器书签较多，检索中(第一次比较慢)`n当前进度:%progress_Bookmarks%`%
			}
		}
		file.Close()
		ToolTip
		RegWrite, REG_SZ, HKEY_CURRENT_USER\Software\RunAny, %RA_ChromeBookmarks_Path%, %mtime_RA_ChromeBookmarks_Path%
	}
	Loop, read, %Chrome_Bookmarks_INI_path%
	{
		item := StrSplit(A_LoopReadLine, "=====")
		Chrome_Bookmarks_Obj[(item[1])] := item[2]
	}
Return

getNowPath(winid:=""){ ; 获取当前文件管理器路径
	WinGet,ahkExe,ProcessName,ahk_id %winid%
	WinGetClass,ahkClass,ahk_id %winid%
	WinGetText,winText,ahk_id %winid%
	If (ahkExe="explorer.exe"){
		If (ahkClass="WorkerW" || ahkClass="Shell_TrayWnd" || ahkClass="Progman"){
			Now_Path := "" 
		}Else{
			RegExMatch(winText, "m)^地址:\s(.*)", OutputVar)
			Now_Path := OutputVar1
		}
	}Else If (ahkExe="Q-Dir_x64.exe"){
		Loop, parse, winText, `n, `r  ; 在 `r 之前指定 `n, 这样可以同时支持对 Windows 和 Unix 文件的解析.
		{
			If (A_Index=1){
				Now_Path := A_LoopField
				Break
			}
		}
	}Else If (ahkClass="TTOTAL_CMD"){
		Loop, parse, winText, `n, `r  ; 在 `r 之前指定 `n, 这样可以同时支持对 Windows 和 Unix 文件的解析.
		{
			If (A_Index=3){
				Now_Path :=  RTrim(A_LoopField, ">")
				Break
			}
		}
	}
	If (Now_Path="桌面")
		Now_Path := "C:\Users\" . A_UserName . "\Desktop"
	Else If (Now_Path="下载")
		Now_Path := "C:\Users\" . A_UserName . "\Downloads"
	Else If (Now_Path="文档")
		Now_Path := "C:\Users\" . A_UserName . "\Documents"
	Else If (Now_Path="图片")
		Now_Path := "C:\Users\" . A_UserName . "\Pictures"
	Else If (Now_Path="视频")
		Now_Path := "C:\Users\" . A_UserName . "\Videos"
	Else If (Now_Path="音乐")
		Now_Path := "C:\Users\" . A_UserName . "\Music"
	Else If (Now_Path="此电脑")
		Now_Path := ""
	Return Now_Path
}

GetFileAssocIcon(ext){ ; 获取文件图标
	If (FileAssocIcon[ext]!="None" || FileAssocIcon[ext]!=""){
		Return FileAssocIcon[ext]
	}
	RegRead,  Name, HKEY_CLASSES_ROOT, .%ext%,
	if ErrorLevel {
		FileAssocIcon[ext] := "None"
		return "None"
	}
	RegRead, DefaultIcon, HKCR, %Name%\DefaultIcon,
	if ErrorLevel {
		FileAssocIcon[ext] := "None"
		return "None"
	}
	FileAssocIcon[ext] := DefaultIcon
	return DefaultIcon
}

FilePathRun(FilePath){ ; 内部关联程序运行文件
	FileGetAttrib, Attributes, %FilePath%
	If InStr(Attributes, "D")
		FileExt := "folder"
	Else{
		SplitPath, FilePath,,, FileExt ; 获取文件扩展名.
		If (FileExt="")
			FileExt := SubStr(FilePath,InStr(FilePath, ".",,0))
		If (FileExt="lnk"){		
			FileGetShortcut, %FilePath%, FilePath
			SplitPath, FilePath,,, FileExt
			If (FileExt="")
				FileExt := SubStr(FilePath,InStr(FilePath, ".",,0))
		}
	}
	FilePathOpenExe := openExtRunList[FileExt]
	FilePathOpenExe_Parm := openExtRunList_Parm[FileExt]
	try
		Run, %FilePathOpenExe% %FilePathOpenExe_Parm% "%FilePath%"
	Catch{
		Try
			Run, "%FilePath%"
		Catch
			Run, "%A_ScriptDir%"
	}
}

class everything
{
	__New(){
		this.hModule := DllCall("LoadLibrary", str, everyDLL)
	}
	__Get(aName){
	}
	__Set(aName, aValue){
	}
	__Delete(){
		DllCall("FreeLibrary", "UInt", this.hModule) 
		return
	}
	SetMax(aValue){
		this.eSearch := aValue
		dllcall(everyDLL "\Everything_SetMax",int,aValue)
		return
	}
	SetSearch(aValue){
		this.eSearch := aValue
		dllcall(everyDLL "\Everything_SetSearch",str,aValue)
		return
	}
	SetMatchWholeWord(aValue){ ; 设置全字匹配
		this.eMatchWholeWord := aValue
		dllcall(everyDLL "\Everything_SetMatchWholeWord",int,aValue)
		return
	}
	SetRegex(aValue){ ; 设置正则表达式搜索
		this.eMatchWholeWord := aValue
		dllcall(everyDLL "\Everything_SetRegex",int,aValue)
		return
	}
	Query(aValue=1){ ; 执行搜索动作
		return dllcall(everyDLL "\Everything_Query",int,aValue)
	}
	GetIsAdmin(){ ; 返回管理员权限状态
		return dllcall(everyDLL "\Everything_IsAdmin")
	}
	GetTotResults(){ ; 返回匹配总数
		return dllcall(everyDLL "\Everything_GetTotResults")
	}
	GetNumFileResults(){ ; 返回可见文件结果的数量
		return dllcall(everyDLL "\Everything_GetNumFileResults")
	}
	GetResultFileName(aValue){ ; 返回文件名
		return strget(dllcall(everyDLL "\Everything_GetResultFileName",int,aValue))
	}
	GetResultFullPathName(aValue,cValue=512){ ; 返回文件全路径
		VarSetCapacity(bValue,cValue*2)
		dllcall(everyDLL "\Everything_GetResultFullPathName",int,aValue,str,bValue,int,cValue)
		return bValue
	}
}

Deref(String) { ; 变量转换
    spo := 1
    out := ""
    while (fpo:=RegexMatch(String, "(%(.*?)%)|``(.)", m, spo))
    {
        out .= SubStr(String, spo, fpo-spo)
        spo := fpo + StrLen(m)
        if (m1){
        	var := %m2%
        	If (var="")
        		out .= m1
        	Else
            	out .= var
        }
        else switch (m3)
        {
            case "a": out .= "`a"
            case "b": out .= "`b"
            case "f": out .= "`f"
            case "n": out .= "`n"
            case "r": out .= "`r"
            case "t": out .= "`t"
            case "v": out .= "`v"
            default: out .= m3
        }
    }
    return out SubStr(String, spo)
}

ListView_ToolTip: ; 显示文件提示
	RowNumber := LV_GetNext()
	menu_pos_y := Radio_H_ALL + Edit_H
	If (WinActive("ahk_id" WinID) && RowNumber!=0){
		LV_GetText(title1, 0, 2)
		LV_GetText(title2, 0, 3)
		LV_GetText(Text1, RowNumber, 2)
		LV_GetText(Text2, RowNumber, 3)
		ToolTip_Str := title1 "：`n" Text1 "`n`n" title2 "：`n" StrReplace(Text2, "``n", "`n")
		Count1 := 0
		For K,V in CandidateList_ExtraInfo[RowNumber] {
			V := StrReplace(V, "``n", "")
			ToolTip_Str := ToolTip_Str "`n`n" K "：`n" V
			Count1 ++
		}
		menu_pos_y := menu_pos_y - ListView_h/2*Count1
		GuiControl, Text, %InfoText_Hwnd%, %ToolTip_Str%
		If (ToolTip_Str="")
			GuiControl, Hide, %InfoText_Hwnd%
		Else
			GuiControl, Show, %InfoText_Hwnd%
		Gui, Show, AutoSize
	}
Return

Monitor_Change(ByRef wParam,ByRef lParam){ ; 分辨率改变消息
    SetTimer, Menu_Reload, -1000
}

;-----------------------------------【内部关联功能】-----------------------------------------------
ReadExtRunList(Open_Ext,openExtList:=""){ ; 读取内部关联
	openExtListObj := Object()
	Loop, parse, openExtList, |
	    openExtListObj[A_LoopField]:=1
	if (openExtListObj.Count()=0)
        openExtListObj := 0
    Open_Ext_Abs := GetAbsPath(Open_Ext)
    SplitPath, Open_Ext_Abs, OutFileName
    If (OutFileName="RunAnyConfig.ini")
        ReadExtRunList_RA(Open_Ext_Abs,openExtListObj)
    Return openExtRunList.Count()
}

ReadExtRunList_RA(openExtConfig,openExtListObj){ ; 读取RA内部关联
    IniRead, openExtVar, %openExtConfig%, OpenExt
    openExtVar := StrReplace(openExtVar, "`%A_ScriptDir`%", "`%A_WorkingDir`%")
    SplitPath, openExtConfig, OutFileName, OutDir
    WorkingDirOld := A_WorkingDir
    SetWorkingDir, %OutDir%
    Loop, parse, openExtVar, `n, `r
    {
        File_Open_Exe_Parm := ""
        itemList := StrSplit(A_LoopField,"=",,2)
        File_Open_Exe := itemList[1]
        File_Open_Exe_Parm_Pos := InStr(File_Open_Exe, ".exe ")
        If (File_Open_Exe_Parm_Pos!=0){
            File_Open_Exe_Parm := SubStr(File_Open_Exe, File_Open_Exe_Parm_Pos+5)
            File_Open_Exe := SubStr(File_Open_Exe, 1, File_Open_Exe_Parm_Pos+3)
        }
        File_Open_Exe := GetOpenExe(File_Open_Exe,openExtConfig)
        If (File_Open_Exe!=""){
            Loop, parse,% itemList[2], %A_Space%
            {
            	if (openExtListObj!=0 && openExtListObj.Count()=0)
            		Break
                extLoopField:=RegExReplace(A_LoopField,"^\.","")
                If(extLoopField="http" or extLoopField="https" or extLoopField="www" or extLoopField="ftp")
                    extLoopField := "html"
                if (openExtListObj=0 || openExtListObj.HasKey(extLoopField)){
                	openExtRunList[extLoopField] := File_Open_Exe
                	openExtRunList_Parm[extLoopField] := File_Open_Exe_Parm
                	openExtListObj.Delete(extLoopField)
                }
            }
        }
    }
    SetWorkingDir %WorkingDirOld%
    WorkingDirOld := A_WorkingDir
}

GetOpenExe(Open_Exe,RunAnyConfigPath){ ; 获取打开后缀的应用（RA无路径）
    IniRead, RunAEvFullPathIniDir, %RunAnyConfigPath%, Config, RunAEvFullPathIniDir, %A_Space%
    If (RunAEvFullPathIniDir="")
        RunAnyEvFullPath := A_AppData "\RunAny\RunAnyEvFullPath.ini"
    Else{
        Transform, RunAnyEvFullPath, Deref, % RunAEvFullPathIniDir
        RunAnyEvFullPath := RunAnyEvFullPath "\RunAnyEvFullPath.ini"
    }
    If (Open_Exe="")
        Return Open_Exe
    Open_Exe_Abs := GetAbsPath(Open_Exe)
    If !FileExist(Open_Exe_Abs)
        IniRead, Open_Exe, %RunAnyEvFullPath%, FullPath, %Open_Exe%, %Open_Exe%
    Else
        Open_Exe := Open_Exe_Abs
    Return Open_Exe
}

GetAbsPath(filePath){ ; 获取文件绝对路径
    Transform, filePath, Deref, %filePath%
    SplitPath, filePath, OutFileName, OutDir
    WorkingDirOld := A_WorkingDir
    SetWorkingDir, %OutDir%
    filePath := A_WorkingDir "\" OutFileName
    SetWorkingDir %WorkingDirOld%
    WorkingDirOld := A_WorkingDir
    Return filePath
}

;-----------------------------------------软件内热建-----------------------------------------
#If WinActive("ahk_id" WinID) ; 搜索框的热键

LAlt::Autocomplete(1,0)
LAlt & 1::Autocomplete(1)
LAlt & 2::Autocomplete(2)
LAlt & 3::Autocomplete(3)
LAlt & 4::Autocomplete(4)
LAlt & 5::Autocomplete(5)
LAlt & 6::Autocomplete(6)
LAlt & 7::Autocomplete(7)
LAlt & 8::Autocomplete(8)
LAlt & 9::Autocomplete(9)

F1::SelectWhichRadio(1)
F2::SelectWhichRadio(2)
F3::SelectWhichRadio(3)
F4::SelectWhichRadio(4)
F5::SelectWhichRadio(5)
F6::SelectWhichRadio(6)
F7::SelectWhichRadio(7)
F8::SelectWhichRadio(8)
F9::SelectWhichRadio(9)
F10::SelectWhichRadio(10)
F11::SelectWhichRadio(11)
F12::SelectWhichRadio(12)

#If (WinActive("ahk_id" WinID) && !WinExist("ahk_class #32768"))
Return

#If (WinActive("ahk_id" WinID) && getFocusCtrlHwnd()=ListView_Hwnd && !WinExist("ahk_class #32768"))
Return