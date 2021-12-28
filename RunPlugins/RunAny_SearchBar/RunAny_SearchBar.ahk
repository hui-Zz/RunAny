;*************************************************
;* 【RA搜索框：搜索菜单项，后缀菜单、自定义搜索等】
;*************************************************
;tong
/*1.使用方法：
	1.下载安装【RunAny】 https://hui-zz.gitee.io/runany/#/
	2.在插件管理中将本插件设置为自启，并重启RA，完成第一次使用的初始化
	3.打开RunAny.ini或RunAny2.ini文件，添加以下内容，可自定义快捷键，下列是shift+D开启
		RA搜索框	+d|RunAny_SearchBar[toggle_searchBar]()
		RA搜索框	+d|RunAny_SearchBar[toggle_searchBar](%getZz%)
		上面两个任选一个添加，第二个菜单项可以实现划词搜索
	4.使用3中快捷键开启

  2.使用说明：
	1.加号可移动搜索框
	2.双击候选项可执行
	3.可以选择输入框是否自动填充
	4.可以选择自动填充后禁用输入时间，0代表不禁用
	5.可以选择是否回车自动执行第一个候选项
	6.可以选择是否自动开启大写
	7.可以选择是否记住上次执行内容
	8.可以选择插件配置更改自动重启时间，0代表更改后不重启
	9.可设置输入框出现的位置模式，0代表上次位置，1代表固定位置，2代表鼠标位置
	-----插件配置可通过右键加号打开进行设置-----

  3.快捷键说明：
	1.tab键正序切换功能，右shift逆序切换功能
	2.alt快速选择第1个候选项，alt+1、2、3。。。9分别快速选择第1-9对应候选项
	3.Delete快速清空输入框
	4.上下键快速选择候选项

  4.添加自定义搜索说明：
	1.【RunAny_SearchBar_Custom.ahk】中【Radio_names】添加对应功能名称
	2.【RunAny_SearchBar_Custom.ahk】中【RA_suffix】、【RA_menu】与步骤1中【后缀菜单】、【菜单项】位置对应
	3.【RunAny_SearchBar_Custom.ahk】中【单选框对应功能】中按序号添加对应功能
	-----【RunAny_SearchBar_Custom.ahk】将在第一次运行后自动生成-----
	-----【RunAny_SearchBar_Custom.ahk】可通过右键输入框上方搜索功能项打开-----
	重要：事先声明没有AHK基础不建议自行修改，如出现错误无法解决，请删除RunAny_SearchBar_Custom.ahk，将会自动初始化
  
  5.文件说明
	1.【RunAny_SearchBar.ahk】搜索框主文件，一般下载后会更新此文件
	2.【RunAny_SearchBar.ini】搜索框配置文件，修改搜索框样式，第一次运行后自动生成，可自行备份
	3.【RunAny_SearchBar_Custom.ahk】自定义搜索功能文件，无此需求请勿乱改，可自定义添加不同的搜索功能（可以与别人分享的自己写的搜索功能），第一次运行后自动生成，可自行备份，【不用自启】
	4.【RunAny_SearchBar.ini】和【RunAny_SearchBar_Custom.ahk】文件删除后自动生成
;-----------------------------------------【更新说明】-----------------------------------------
v1.0.3: 2021年12月
	1.添加拼音搜索和首字母搜索(基于kazhafeizhale的ChToPy脚本),同时RA菜单项值匹配菜单项名称，不再匹配路径
	2.不再使用onMessage.ahk
v1.0.4: 2021年12月22日
	1.新增首次运行没有自启时的提示信息
	2.插件可设置为鼠标位置
	3.增加配置文件，可根据当前屏幕分辨率设置外观
	4.解决缩放显示问题
	5.新增可接收getZz参数
	6.新增可以选择记住上次执行的内容
	7.新增右键加号可以打开配置文件
v1.0.5: 2021年12月23日
	1.功能与插件分离，自定义搜索功能用户可通过RunAny_SearchBar_Custom.ahk文件保存
	2.自定义搜索堆叠优化，上方垂直堆叠
	3.新增右键搜索功能项可以打开功能配置文件
	4.新增配置文件打开方式为RA内部关联
v1.0.6: 2021年12月24日
	1.修复使用RA内部关联打开配置文件包含变量无法读取的错误
	2.修复ListView图像列表内存占用问题，降低内存占用
	3.修复长按退格键导致下方候选框残留问题
v1.0.7: 2021年12月25日
	1.新增能够为每个搜索功能设置是否开启大写，对应配置项：对应菜单开启大写
	2.新增基于系统设置的切换输入法快捷键实现自动切换输入法，对应配置项：切换输入法快捷键
	3.增加URI转义，修复网页搜索内容存在%等无法搜索的问题，见【RunAny_SearchBar_Custom.ahk】中百度一下搜索功能
v1.0.8: 2021年12月26日
	1.修复MenuObj包含无路径缓存内容，造成重复，修复思路基于无路径缓存的MenuObj无对应图标：MenuObjIcon中不存的且EvFullPath中存在的被排除
v1.0.9: 2021年12月27日
	1.修复点击切换搜索功能时，候选项没有刷新
	2.汉字转拼音插件在多音字方面处理存在问题，当出现多个多音词（例如“的”），会产生指数及增长，导致程序崩溃
v1.1.0: 2021年12月28日
	1.优化代码，可以更好的自定义搜索功能（例如实现chrome|edge收藏夹）
*/

global RunAny_Plugins_Version:="1.1.0"
global RunAny_Plugins_Icon:="shell32.dll,23"
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
#Include %A_ScriptDir%\..\RunAny_ObjReg.ahk
;https://www.autoahk.com/archives/37300 汉字转拼音，不需要则删除下面两行
#Include %A_ScriptDir%\..\Lib\ChToPy.ahk
ChToPy.log4ahk_load_all_dll_path()

;----------------------------------------【RA插件功能】----------------------------------------
class RunAnyObj {
	;RA搜索框	+d|RunAny_SearchBar[toggle_searchBar]()
	;RA搜索框	+d|RunAny_SearchBar[toggle_searchBar](%getZz%)
	toggle_searchBar(getZz:=""){
		toggleSearchBar(getZz)
	}
}
;----------------------------------------【自定义样式】----------------------------------------
Label_Custom:
	;上方单选框对应功能
	Gosub, Init_Custom_Fun
	;搜索框样式
	global x_pos,y_pos,pos_mode,Edit_color,Edit_text_size,Edit_trans,Edit_width,Radio_un_color,Radio_un_text_size,Radio_color,Radio_text_size
	;提示框样式
	global ListView_text_size,ListView_h,Candidates_num_max,Candidates_show_num_max,width_1,width_2,width_3
	;特色功能
	global Edit_stop_time,is_auto_fill,is_run_first,is_auto_CapsLock,CapsLock_List,is_remember_content,ChangeIMEHotKey
	;辅助功能
	global Auto_Reload_MTime,INI_Open_Exe,AHK_Open_Exe

;----------------------------------------【初始化】----------------------------------------
Label_ScriptSetting: ;脚本前参数设置
	Process, Priority, , High						;脚本高优先级
	#MenuMaskKey vkE8
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

Label_ReadINI:	;读取INI文件配置收缩框
	global SearchBar_Version:="1.1.0"
	global INI
	INI = %A_ScriptDir%\RunAny_SearchBar.ini
	if !FileExist(INI)
		initINI()
	iniread, x_pos, %INI%, %A_ScreenWidth%*%A_ScreenHeight%, 搜索框x轴位置, 0.5
	iniread, y_pos, %INI%, %A_ScreenWidth%*%A_ScreenHeight%, 搜索框y轴位置, 0.25
	iniread, pos_mode, %INI%, %A_ScreenWidth%*%A_ScreenHeight%, 搜索框位置模式, 1

	iniread, Edit_color, %INI%, %A_ScreenWidth%*%A_ScreenHeight%, 输入框字体颜色, black
	iniread, Edit_text_size, %INI%, %A_ScreenWidth%*%A_ScreenHeight%, 输入框字体大小, 25
	iniread, Edit_trans, %INI%, %A_ScreenWidth%*%A_ScreenHeight%, 输入框透明度, 220
	iniread, Edit_width, %INI%, %A_ScreenWidth%*%A_ScreenHeight%, 输入框宽度, 800

	iniread, Radio_un_color, %INI%, %A_ScreenWidth%*%A_ScreenHeight%, 上方搜索选项未选中时字体颜色, black
	Radio_un_text_size := Edit_text_size -11
	Radio_text_size := Edit_text_size -10
	iniread, Radio_color, %INI%, %A_ScreenWidth%*%A_ScreenHeight%, 上方搜索选项选中时字体颜色, 1e90ff

	ListView_text_size := Radio_un_text_size
	iniread, Candidates_num_max, %INI%, %A_ScreenWidth%*%A_ScreenHeight%, 候选框内最大行数, 50
	iniread, Candidates_show_num_max, %INI%, %A_ScreenWidth%*%A_ScreenHeight%, 候选框显示最大行数, 10
	iniread, ListView_column_ratio, %INI%, %A_ScreenWidth%*%A_ScreenHeight%, 候选框内三列比例, 0.08:0.28:0.64
	ListView_column_ratio := StrSplit(ListView_column_ratio, ":")
	width_1 := ListView_column_ratio[1],width_2 := ListView_column_ratio[2],width_3 := ListView_column_ratio[3]

	iniread, is_auto_fill, %INI%, %A_ScreenWidth%*%A_ScreenHeight%,输入框是否自动填充, 1
	iniread, Edit_stop_time, %INI%, %A_ScreenWidth%*%A_ScreenHeight%,自动填充后禁用输入时间, 500
	iniread, is_run_first, %INI%, %A_ScreenWidth%*%A_ScreenHeight%,是否回车自动执行第一个候选项, 1
	iniread, is_auto_CapsLock, %INI%, %A_ScreenWidth%*%A_ScreenHeight%,是否自动开启大写, 1
	iniread, CapsLock_List1, %INI%, %A_ScreenWidth%*%A_ScreenHeight%,对应菜单开启大写, 1|2
	iniread, ChangeIMEHotKey, %INI%, %A_ScreenWidth%*%A_ScreenHeight%,切换输入法快捷键, %A_Space%
	CapsLock_List := Object() 
	Loop, parse, CapsLock_List1, |
    	CapsLock_List[A_LoopField] := A_LoopField 
	iniread, is_remember_content, %INI%, %A_ScreenWidth%*%A_ScreenHeight%,是否记住上次执行内容, 0

	iniread, Auto_Reload_MTime, %INI%, %A_ScreenWidth%*%A_ScreenHeight%,配置更改自动重启时间, 2000
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
	initResetINI()

Label_ReadRAINI:	;读取RAINI文件生成菜单项
	global rAAhkMatch  := "RunAny.ahk ahk_class AutoHotkey"		;RA ahk路径
	;从RA配置文件中读取无路径缓存路径
	SplitPath, A_AhkPath, , RunAnyConfigDir
	IniRead, RunAEvFullPathIniDir, %RunAnyConfigDir%\RunAnyConfig.ini, Config, RunAEvFullPathIniDir, %A_Space%
	If (RunAEvFullPathIniDir="")
		INI_Path := A_AppData "\RunAny"
	Else
		Transform, INI_Path, Deref, % RunAEvFullPathIniDir
	;从RA配置文件中ini、ahk后缀关联程序
	IniRead, openExtVar, %RunAnyConfigDir%\RunAnyConfig.ini, OpenExt
	Loop, parse, openExtVar, `n, `r
	{
		itemList:=StrSplit(A_LoopField,"=",,2)
		openExtIniList[itemList[1]]:=itemList[2]
		Loop, parse,% itemList[2], %A_Space%
		{
			StringLower, ExtVar, A_LoopField 
			if (ExtVar="ini")
				Transform, INI_Open_Exe, Deref, % itemList[1]
			Else if(ExtVar="ahk")
				Transform, AHK_Open_Exe, Deref, % itemList[1]
		}
	}
	If !FileExist(INI_Open_Exe){
		IniRead, INI_Open_Exe, %INI_Path%\RunAnyEvFullPath.ini, FullPath, %INI_Open_Exe%, %A_Space%
		If !FileExist(INI_Open_Exe)
			INI_Open_Exe := ""
	}
	If !FileExist(AHK_Open_Exe){
		IniRead, AHK_Open_Exe, %INI_Path%\RunAnyEvFullPath.ini, FullPath, %AHK_Open_Exe%, %A_Space%
		If !FileExist(AHK_Open_Exe)
			AHK_Open_Exe := ""
	}
	;读取菜单项配置文件
	INI_EvFullPath := INI_Path "\RunAnyEvFullPath.ini"	
	INI_MenuObj := INI_Path "\RunAnyMenuObj.ini"
	INI_MenuObjIcon := INI_Path "\RunAnyMenuObjIcon.ini"
	INI_MenuObjExt := INI_Path "\RunAnyMenuObjExt.ini"
	If (!FileExist(INI_MenuObj) || !FileExist(INI_MenuObjIcon) || !FileExist(INI_MenuObjExt)){
		Send_WM_COPYDATA("runany[ShowTrayTip](RA搜索框插件,首次运行无法读取RA菜单信息，请将本插件设置为【自启】后重启RA！如已设置为【自启】，请耐心等待【RA】启动初始化，将自动重启生效！,20,17)", rAAhkMatch)
	}
	global EvFullPath := Object()                   ;~无路径缓存
	global MenuObj := Object()                    	;~程序全路径
	global MenuObjIcon := Object()                  ;~程序对应图标路径
	global MenuObjExt := Object()					;~对应后缀菜单
	Loop, read, %INI_EvFullPath%
	{
		If (A_Index!=1){
			item := StrSplit(A_LoopReadLine, "=")
			EvFullPath[(item[1])] := item[2]
		}
	}
	Loop, read, %INI_MenuObjIcon%
	{
		If (A_Index!=1){
			item := StrSplit(A_LoopReadLine, "=")
			MenuObjIcon[(item[1])] := item[2]
		}
	}
	Loop, read, %INI_MenuObj%
	{
		If (A_Index!=1){
			item := StrSplit(A_LoopReadLine, "=")
			If (MenuObjIcon.HasKey(item[1]) || !EvFullPath.HasKey(item[1] ".exe"))
				MenuObj[(item[1])] := item[2]
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
	global index_temp := Radio_Default							;临时变量，用于tab切换减少时间复杂度
	global WinID := ""											;窗口ID
	global My_Edit_Hwnd := ""									;输入框ID
	global Content := ""										;输入框内容
	global Move_Hwnd := ""										;加号对应的Hwnd
	global ListView_Hwnd := ""									;候选项对应的Hwnd
	global len_Radio := Radio_names.Length()					;上方选项的单选框控件数量
	global Candidates_num := -1									;候选项个数
	global is_hide := 0											;表示是否是隐藏效果
	global Radio_H_ALL,Edit_H,ListBox_width,ListView_H1,ImageListID			;辅助变量
	global CandidateList,Edit_OutputVar							;候选框、输入框内容
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
			Gui Add, Radio,-Background x%Radio_X% y%Radio_Y%  gChangeRadio HwndSearch_Hwnd_%ki%, %kv%
		tmp := Search_Hwnd_%ki%
		ControlGetPos, Radio_X, Radio_Y, Radio_W, Radio_H, , ahk_id %tmp%
		If ((Radio_X+Radio_W)>Edit_width){
			Radio_X := Radio_W + 15
			Radio_Y += Radio_H + 15
			Radio_H_ALL += Radio_H +15
			ControlMove, , 0, Radio_Y, Radio_W*1.05, Radio_H*1.2,ahk_id %tmp%
		}Else{
			Radio_X += Radio_W + 15
			ControlMove, , , , Radio_W*1.05, Radio_H*1.2,ahk_id %tmp%
		}
	}
;--------------------------------------------------------------------------------------------

	Gui font, s%Edit_text_size% c%Edit_color%,Segoe UI
	ControlGetPos, , , , Radio_H, , ahk_id %Search_Hwnd_1%
	Radio_H_ALL += Radio_H + 10
	Gui Add, Edit, HwndMy_Edit_Hwnd x0 y%Radio_H_ALL% w%Edit_width% vContent gChangeEdit
	ControlGetPos, , , , Edit_H, , ahk_id %My_Edit_Hwnd%
	Gui Add, Text,+Border -Background x%Edit_width% y%Radio_H_ALL% h%Edit_H% HwndMove_Hwnd, +
	ControlGetPos, , ,Move_W , , , ahk_id %Move_Hwnd%
	ListBox_width := Edit_width + Move_W
	Gui font, s%ListView_text_size% c%Edit_color%,Segoe UI
	Gui Add, ListView,xs w%ListBox_width% vCommandChoice R2 -Multi +AltSubmit -HScroll HwndListView_Hwnd gGiveEdit, 序号|菜单名称|菜单值
	Gui Add, ListView,xs w%ListBox_width% R1 -Multi +AltSubmit -HScroll HwndListView_temp_Hwnd , 序号|菜单名称|菜单值
	Gui, ListView, CommandChoice
	ControlGetPos, , , , ListView_H1, , ahk_id %ListView_temp_Hwnd%
	ControlGetPos, , , , ListView_H2, , ahk_id %ListView_Hwnd%
	ListView_h := ListView_H2 - ListView_H1
	GuiControl, Disable, %ListView_temp_Hwnd%
	GuiControl, Hide, %ListView_temp_Hwnd%
	Gui Add, Button, x39 y69 w75 h23 Hidden Default gLabel_Submit, 确定(&Y)
	WinSet, TransColor, %CustomColor% %Edit_trans%

	;开启时的默认单选框设置
	DefaultHwnd := Search_Hwnd_%Radio_Default%
	GuiControl, , %DefaultHwnd%, 1
	Gosub, Label_Font_Radio
	GuiControl, Font, %DefaultHwnd%
	GuiControl, Hide, CommandChoice
	x_pos := A_ScreenWidth*x_pos - (ListBox_width/2)
	y_pos := A_ScreenHeight*y_pos - (Radio_H_ALL+Edit_H/2)
	Gui Show, x%x_pos% y%y_pos% Hide
Return

Label_Submit: ;确认提交
	Gosub, Label_Submit_Before
	toggleSearchBar("")
	if IsLabel("fun_" index_temp)
		Gosub, fun_%index_temp%
	Else
		Send_WM_COPYDATA("runany[ShowTrayTip](RA搜索框插件,对应功能未定义，请在【RunAny_SearchBar_Custom.ahk】中添加后重启插件，可以通过右键点击功能项快速打开,20,17)", rAAhkMatch)
return

;单选框对应功能
suffix_fun:	;后缀菜单功能
	If (Content!="")
		showSwitchToolTip("后缀: " . Content,2500)
	Else
		showSwitchToolTip("输入空",2500)
	result := Send_WM_COPYDATA("runany[Remote_Menu_Ext_Show](" Content ")", rAAhkMatch)
Return

menu_fun:	;菜单项功能
	if(RegExMatch(MenuObj[Content],"S).+?\[.+?\]%?\(.*?\)")){
		result := Send_WM_COPYDATA(MenuObj[Content], rAAhkMatch)
	}else{
		result := Send_WM_COPYDATA("runany[Remote_Menu_Run](" Content ")", rAAhkMatch)
	}
Return

;加载用户自定义功能
#Include *i %A_ScriptDir%\RunAny_SearchBar_Custom.ahk

Label_Submit_Before: ;提交之前的操作
	If (index_temp=RA_suffix || index_temp=RA_menu){
		executeCandidateWhich(2)
	}Else{
		temp := "Execute"
		If (IsLabel("Label_Custom_ListView_" temp))
			Gosub, Label_Custom_ListView_%temp%
		Else
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
	Gosub, changeCapsLockState
	ChangeEdit()
}
Return
;----------------------------------------【单选框对应触发提示对应】----------------------------------------

ChangeEdit(){	;输入框改变时触发
	LV_Delete()							;删除提示框内容以刷新
	IL_Destroy(ImageListID)				;删除图像列表，降低内存
	match_flag := 1	;用于那些功能出发下方提示框
	GuiControlGet, Edit_OutputVar, ,%My_Edit_Hwnd%
	If (index_temp=RA_suffix){			;激活指定后缀的菜单触发
		CandidateList:=getCandidateCommon(MenuObjExt,3,MenuObjIcon,3)
		LV_ModifyCol(2, ,"后缀名")
		LV_ModifyCol(3, ,"菜单名称")
	}Else If (index_temp=RA_menu){		;打开指定菜单
		CandidateList:=getCandidateCommon(MenuObj,4,MenuObjIcon)
		LV_ModifyCol(2, ,"菜单名称")
		LV_ModifyCol(3, ,"菜单值")
	}Else{
		temp := "Show"
		If (IsLabel("Label_Custom_ListView_" temp))
			Gosub, Label_Custom_ListView_%temp%
		Else
			match_flag := 0
	}
	column := LV_GetCount("Column")
	ListCount := CandidateList.Length()/column	;数组对应的3元组数量（key、val、ico_path）
	GuiControl, Move, CommandChoice, % "h" ListView_H1 + ListView_h * ((ListCount > (Candidates_show_num_max-1) ? Candidates_show_num_max : ListCount)-1) ;设置对应的提示框高度
	ImageListID := IL_Create(ListCount)	;创建对应图片
	LV_SetImageList(ImageListID)
	Loop, %ListCount%{					;ListView插入对应值
		key := CandidateList[3*A_Index-2]
		val := CandidateList[3*A_Index-1]
		ico := StrSplit(CandidateList[3*A_Index], ",")
		IL_Add(ImageListID, ico[1], ico[2])
		LV_Add("Icon" . A_Index,"-" . A_Index, key, val)
	}
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
	GuiControl, % ListCount ? "Show" : "Hide", CommandChoice 	;根据数量是否显示提示框
	If (is_hide = 0)
		Gui, Show, AutoSize
	If ( match_flag && ListCount=0 && Edit_OutputVar){		;无匹配时提醒
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
	CandidateList := ""
	SetTimer, close_ListView, 100
}

close_ListView:	;如果为空则关闭候选框
	GuiControlGet, OutputVar, ,%My_Edit_Hwnd%
	If (!OutputVar){
		LV_Delete()							;删除提示框内容以刷新
		IL_Destroy(ImageListID)				;删除图像列表，降低内存
		GuiControl, Hide, CommandChoice
	}
	SetTimer, close_ListView, Off
Return


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

toggleSearchBar(getZz:=""){	;激活或关闭RA搜索框
	if WinActive("ahk_id" WinID){
		SetTimer, Timer_Remove_check, Off
		Gosub, hide_searchBar
	}
	Else{
		is_hide := 0
		Gosub, changeCapsLockState
		If (pos_mode=0){
			Gui Show
		}Else If (pos_mode=1){
			Gui Show, x%x_pos% y%y_pos%
		}Else If (pos_mode=2){
			CoordMode, Mouse, Screen
			MouseGetPos, xMouse, yMouse
			xMouse -= (ListBox_width/2)
			yMouse -= (Radio_H_ALL+Edit_H/2)
			Gui Show, x%xMouse% y%yMouse%
		}
		WinActivate,ahk_id %WinID%
		ControlFocus,,ahk_id %My_Edit_Hwnd%
		SendInput %ChangeIMEHotKey%
		If (getZz)
			GuiControl, Text, %My_Edit_Hwnd%, %getZz%
		Else If (is_remember_content)
			GuiControl, Text, %My_Edit_Hwnd%, %Content%
		SendInput {End}
		SetTimer, Timer_Remove_check, 25
	}
}

hide_searchBar:	;隐藏搜索框
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

GuiContextMenu(GuiHwnd, CtrlHwnd, EventInfo, IsRightClick, X, Y){	;右键功能
	If (Move_Hwnd=CtrlHwnd) {
		EditFile(INI,INI_Open_Exe)
	}
	WinGetClass, CtrlClass, ahk_id %CtrlHwnd%
	If (CtrlClass="Button"){
		EditFile(A_ScriptDir "\RunAny_SearchBar_Custom.ahk",AHK_Open_Exe)
	}
}

getCandidateCommon(Obj,default_Icon_number:=4,ObjIcon:="",WhichToExe:=2){
	If (Edit_OutputVar="")
		Return
	CandidateList := Object()
	full_match := 0	;有完全匹配项则不会重复搜索，消除自动补全BUG
	Candidates_num := 1
	temp_kv := ""	;消除临近重复选项，，例如快捷键的
    For ki, kv in Obj
	{
		If (kv="")
			Continue
		a := InStr(ki, Edit_OutputVar) || InStr(ChToPy.allspell(ki), Edit_OutputVar) || InStr(ChToPy.initials(ki), Edit_OutputVar)
		If (a!=0){
			If (kv=temp_kv){
				Continue
			}Else{
				temp_kv := kv
			}
			ico_path := WhichToExe=2?ObjIcon[ki]:ObjIcon[kv]
			If (ico_path="")
				ico_path := "shell32.dll," default_Icon_number
			CandidateList.push(ki,kv,ico_path)
			Candidates_num +=1
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

executeCandidateWhich(whichColumn:=2){
	RowNumber := LV_GetNext()
		If (RowNumber!=0){
			LV_GetText(Content, LV_GetNext(), whichColumn)
		}Else If (LV_GetCount()!=0 && is_run_first){
			LV_GetText(Content, 1, whichColumn)
		}Else
			GuiControlGet, Content, ,%My_Edit_Hwnd%
}

initResetINI() { ;定时重新加载配置文件
	FileGetTime, mtime_ini_path, %INI%, M  ; 获取修改时间.
	FileGetTime, mtime_CustomAHK_path, %A_ScriptDir%\RunAny_SearchBar_Custom.ahk, M  ; 获取修改时间.
	RegWrite, REG_SZ, HKEY_CURRENT_USER\Software\RunAny, %INI%, %mtime_ini_path%
	RegWrite, REG_SZ, HKEY_CURRENT_USER\Software\RunAny, %A_ScriptDir%\RunAny_SearchBar_Custom.ahk, %mtime_CustomAHK_path%
	if (Auto_Reload_MTime>0)
	{
		SetTimer, Auto_Reload_MTime, %Auto_Reload_MTime%
	}
}

Auto_Reload_MTime: ;定时重新加载脚本
	RegRead, mtime_ini_path_reg, HKEY_CURRENT_USER\Software\RunAny, %INI%
	RegRead, mtime_CustomAHK_path_reg, HKEY_CURRENT_USER\Software\RunAny, %A_ScriptDir%\RunAny_SearchBar_Custom.ahk
	FileGetTime, mtime_ini_path, %INI%, M  ; 获取修改时间.
	FileGetTime, mtime_CustomAHK_path, %A_ScriptDir%\RunAny_SearchBar_Custom.ahk, M  ; 获取修改时间.
	if (mtime_ini_path_reg != mtime_ini_path || mtime_CustomAHK_path_reg != mtime_CustomAHK_path)
	{
		try Reload
	}
Return

Init_Custom_Fun:  ;执行自定义功能标签
	FileGetTime, mtime_CustomAHK_path, %A_ScriptDir%\RunAny_SearchBar_Custom.ahk, M  ; 获取修改时间.
	if !mtime_CustomAHK_path{
		initCustomAHK()
		Reload
	}
	temp := "Fun"
	if IsLabel("Label_Custom_" temp)
		Gosub, Label_Custom_%temp%
Return

changeCapsLockState:	;改变大小写状态
	If (is_auto_CapsLock){
		If CapsLock_List.HasKey(index_temp)
			SetCapsLockState, On
		Else
			SetCapsLockState, Off
	}
Return

initCustomAHK(){	;初始化自定义搜索功能的AHK
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
	global Radio_names := ["后缀菜单","菜单项","百度一下"]
	global RA_suffix := 1		;后缀菜单对应位置
	global RA_menu := 2			;菜单项对应位置
	global Radio_Default := 2	;默认搜索对应位置，默认为菜单项
Return

;----------------------------------------【单选框对应功能】----------------------------------------
fun_1:	;后缀菜单
	Gosub, suffix_fun
Return

fun_2:	;菜单项
	Gosub, menu_fun
Return

fun_3:	;百度一下
	URIContent:=URIEncode(Content)	;网页搜索时内容进行URI转义
	Run https://www.baidu.com/s?wd=`%URIContent`%
Return

;----------------------------------------【辅助函数位置】----------------------------------------
	), %A_ScriptDir%\RunAny_SearchBar_Custom.ahk, UTF-8
}

EditFile(filePath,openExe:="notepad.exe") { ;打开指定文件
	openExe := openExe ? openExe : "notepad.exe"
	try{
		if(!FileExist(ini)){
			MsgBox,16,%ini%,没有找到配置文件：%ini%
		}Else{
			Run,%openExe% "%filePath%"
		}
	}catch{
		MsgBox,16,%ini%,无法打开配置文件：%filePath%
	}
}

URIEncode(str, encoding := "UTF-8")  {	;URI转义
   VarSetCapacity(var, StrPut(str, encoding))
   StrPut(str, &var, encoding)

   While code := NumGet(Var, A_Index - 1, "UChar")  {
      bool := (code > 0x7F || code < 0x30 || code = 0x3D)
      UrlStr .= bool ? "%" . Format("{:02X}", code) : Chr(code)
   }
   Return UrlStr
}

initINI() { ;初始化INI
	FileAppend,;【RA搜索框配置文件】`n, %INI%
	FileAppend,;【说明】：后续版本如有新的配置项，请对比后自行修改添加`n, %INI%
	FileAppend,[基础配置]`n, %INI%
	FileAppend,配置版本=%SearchBar_Version%`n, %INI%
	FileAppend,;【说明】：本配置文件可针对不同分辨率显示器分别设置，请自行添加，默认为【1080P】的设置，详细参数说明请看RA官网说明或入群自问`n, %INI%
	FileAppend,[1920*1080]`n, %INI%
	FileAppend,搜索框x轴位置=0.5`n, %INI%
	FileAppend,搜索框y轴位置=0.25`n, %INI%
	FileAppend,搜索框位置模式=1`n, %INI%

	FileAppend,输入框字体颜色=black`n, %INI%
	FileAppend,输入框字体大小=25`n, %INI%
	FileAppend,输入框透明度=220`n, %INI%
	FileAppend,输入框宽度=800`n, %INI%

	FileAppend,上方搜索选项未选中时字体颜色=black`n, %INI%
	FileAppend,上方搜索选项选中时字体颜色=1e90ff`n, %INI%

	FileAppend,候选框内最大行数=50`n, %INI%
	FileAppend,候选框显示最大行数=10`n, %INI%
	FileAppend,候选框内三列比例=0.08:0.28:0.64`n, %INI%

	FileAppend,输入框是否自动填充=1`n, %INI%
	FileAppend,自动填充后禁用输入时间=500`n, %INI%
	FileAppend,是否回车自动执行第一个候选项=1`n, %INI%
	FileAppend,是否自动开启大写=1`n, %INI%
	FileAppend,对应菜单开启大写=1|2`n, %INI%
	FileAppend,切换输入法快捷键=`n, %INI%
	FileAppend,是否记住上次执行内容=0`n, %INI%

	FileAppend,配置更改自动重启时间=2000`n, %INI%
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
	Gosub, changeCapsLockState
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
	Gosub, changeCapsLockState
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