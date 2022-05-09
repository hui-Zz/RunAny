;══════════════════════════════════════════════════════════════════
;~;[添加编辑新添加的菜单项]
Menu_Add_File_Item:
	if(iniFileShow=iniPath){
		iniFileVar:=iniVar1
		TREE_NO:=1
	}else{
		iniFileVar:=iniVar2
		TREE_NO:=2
	}
	;初始化要添加的内容
	itemGlobalWinKey:=0
	hotStrOption:=hotStrShow:=itemGlobalHotKey:=itemGlobalKey:=X_ThisMenuItem:=ItemText:=""
	itemPath:=Get_Item_Run_Path(getZz)
	SplitPath, itemPath, fName,, fExt, itemName
	Z_ThisMenu:=RTrim(A_ThisMenu)
	Z_ThisMenuItem:=A_ThisMenuItem
	if(Z_ThisMenuItem=RUNANY_SELF_MENU_ITEM3){
		X_ThisMenuItem:=Z_ThisMenuItem
		itemContent:=MenuObjTree%TREE_NO%[Z_ThisMenu][(MenuObjTree%TREE_NO%[Z_ThisMenu].MaxIndex())]
		Z_ThisMenuItem:=Get_Obj_Transform_Name(itemContent)
	}
	if(!Z_ThisMenu)
		return
	menuGuiFlag:=false
	menuGuiEditFlag:=false
	thisMenuItemStr:=X_ThisMenuItem=RUNANY_SELF_MENU_ITEM3 ? "" : "菜单项（" Z_ThisMenuItem "）的上面"
	thisMenuStr:=Z_ThisMenu=RunAnyZz . "File" . TREE_NO 
		? "新增项会在『根目录』分类下（如果没有用“-”回归1级会添加在最末的菜单内）" 
		: "新增项会在『" Z_ThisMenu "』分类下"
	Gosub,Menu_Item_Edit
return
;~;[保存新添加的菜单项]
SetSaveItem:
	Gui,SaveItem:Submit,NoHide
	saveText:=tabText:=itemGlobalKeyStr:=""
	menuFlag:=false		;判断是否定位到要插入的菜单位置
	endFlag:=false		;判断是否插入到末尾
	rootFlag:=true		;判断是否为根目录
	inputFlag:=false	;判断是否插入
	itemIndex:=0
	splitStr:=vitemName && vitemPath ? "|" : ""
	if(vitemGlobalKey){
		if(!vitemName){
			MsgBox, 48, ,设置热键后必须填写菜单项名
			return
		}
		if(!vitemPath && InStr(vitemName,"-")!=1){
			MsgBox, 48, ,应用设置热键后必须填写启动路径
			return
		}
		itemGlobalKeySave:=vitemGlobalWinKey ? "#" . vitemGlobalKey : vitemGlobalKey
		itemGlobalKeyStr:=A_Tab . itemGlobalKeySave
		if(vitemGlobalKey!=itemGlobalKey || vitemGlobalWinKey!=itemGlobalWinKey){
			if(InStr(iniVar1,itemGlobalKeyStr "|") || InStr(iniVar2,itemGlobalKeyStr "|")){
				MsgBox, 48, ,该全局热键已经被其他菜单应用使用
				return
			}
		}
	}
	;保存热字符串
	if(vhotStrShow){
		if(vhotStrShow!=hotStrShow || vhotStrOption!=hotStrOption){
			vhotStrSave:=vhotStrOption ? vhotStrOption . vhotStrShow : ":*X:" vhotStrShow
			if(InStr(iniVar1,vhotStrSave "|") || InStr(iniVar2,vhotStrSave "|")){
				MsgBox, 48, ,该热字符串已经被其他菜单应用使用
				return
			}
		}
		vitemName.=vhotStrSave
	}
	Gui,SaveItem:Destroy
	;[读取菜单内容插入新菜单项到RunAny.ini]
	Loop, parse, iniFileVar, `n, `r
	{
		itemContent=%A_LoopField%
		if(InStr(itemContent,"-")=1){
			rootFlag:=false
			treeContent:=Get_Tree_Name(itemContent,false)
			if(itemContent="-")
				rootFlag:=true
			if(treeContent=Z_ThisMenu){	;定位到要插入的菜单位置
				menuFlag:=true
				;计算出前面添加的制表符数量
				treeLevel:=StrLen(RegExReplace(itemContent,"S)(^-+).+","$1"))
				tabText:=Set_Tab(treeLevel)
			}
		}else if(rootFlag && (Z_ThisMenu=RunAnyZz . TREE_NO)){	;如果要添加到根目录
			menuFlag:=true
		}
		if(menuFlag){
			menuItem:=Get_Obj_Transform_Name(itemContent)
			if(menuItem=Z_ThisMenuItem){
				if(X_ThisMenuItem!=RUNANY_SELF_MENU_ITEM3){
					saveText.=tabText . vitemName . itemGlobalKeyStr . splitStr . vitemPath . "`n"
					inputFlag:=true
				}else{
					endFind:=true
				}
				menuFlag:=false
			}else if (Z_ThisMenuItem="" && (X_ThisMenuItem="" || X_ThisMenuItem=RUNANY_SELF_MENU_ITEM3)){
				endFind:=true
				menuFlag:=false
			}
		}
		saveText.=A_LoopField . "`n"
		if(endFind && !inputFlag){
			saveText.=tabText . vitemName . itemGlobalKeyStr . splitStr . vitemPath . "`n"
			endFind:=false
			inputFlag:=true
		}
	}
	if(saveText){
		if(!inputFlag){
			saveText.=tabText . vitemName . itemGlobalKeyStr . splitStr . vitemPath . "`n"
		}
		stringtrimright, saveText, saveText, 1
		FileDelete,%iniFileShow%
		FileAppend,%saveText%,%iniFileShow%
		Gosub,Menu_Reload
	}
return
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
;~;【——🎫菜单配置Gui——】
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
Menu_Edit_Gui:
	global TVFlag:=false
	global FailFlag:=false
	;[功能菜单初始化]
	treeRoot:=Object()
	global moveRoot:=Object()
	moveRoot[1]:="moveMenu" . both
	Menu,% moveRoot[1],add
	global moveLevel:=0
	;[树型菜单初始化]
	Gui, MenuEdit:Destroy
	Gui, MenuEdit:Default
	Gui, MenuEdit:+Resize
	Gui, MenuEdit:Font,s10, Microsoft YaHei
	Gui, MenuEdit:Add, TreeView,vRunAnyTV w600 r30 -Readonly AltSubmit Checked hwndHTV gTVClick ImageList%TreeImageListID%
	Gui, MenuEdit:Add, Progress,vMyProgress w450 cBlue
	GuiControl, MenuEdit:Hide, MyProgress
	GuiControl, MenuEdit:-Redraw, RunAnyTV
	Tv:=new treeview(HTV)
	;[读取菜单配置内容写入树形菜单]
	Loop, parse, iniFileVar, `n, `r, %A_Space%%A_Tab%
	{
		if(A_LoopField=""){
			continue
		}
		if(InStr(A_LoopField,"-")=1){
			;[生成节点树层级结构]
			treeLevel:=StrLen(RegExReplace(A_LoopField,"S)(^-+).+","$1"))
			if(RegExMatch(A_LoopField,"S)^-+[^-]+.*")){
				if(treeLevel=1){
					treeRoot.InsertAt(treeLevel,TV_Add(A_LoopField,,Set_Icon(TreeImageListID,A_LoopField,false)))
				}else{
					treeRoot.InsertAt(treeLevel,TV_Add(A_LoopField,treeRoot[treeLevel-1],Set_Icon(TreeImageListID,A_LoopField,false)))
				}
				TV_MoveMenu(A_LoopField)
			}else if(A_LoopField="-"){
				treeLevel:=0
				TV_Add(A_LoopField,,"Bold Icon8")
			}else{
				TV_Add(A_LoopField,treeRoot[treeLevel],"Bold Icon8")
			}
		}else if(A_LoopField="|" || A_LoopField="||"){
			TV_Add(A_LoopField,treeRoot[treeLevel],"Bold Icon8")
		}else if(InStr(A_LoopField,";")=1){
			hwnd:=TV_Add(A_LoopField,treeRoot[treeLevel],"Icon8")
			Tv.modify({hwnd:hwnd,fore:0x00A000})
		}else{
			FailFlag:=false
			itemIcon:=Set_Icon(TreeImageListID,A_LoopField,false)
			hwnd:=TV_Add(A_LoopField,treeRoot[treeLevel],itemIcon)
			if(itemIcon="Icon3" || FailFlag){
				Tv.modify({hwnd:hwnd,fore:0x999999})
			}
		}
	}
	GuiControl, MenuEdit:+Redraw, RunAnyTV
	TVMenu("TVMenu")
	TVMenu("GuiMenu")
	Gui, MenuEdit:Menu, GuiMenu
	Gui, MenuEdit:Show, , %RunAnyZz%菜单树管理【%both%】%RunAny_update_version% %RunAny_update_time%%AdminMode%(双击修改，右键操作)
	if(TVEditItem!=""){
		ItemEdit:=Get_Obj_Name(TVEditItem)
		ItemID = 0
		Loop
		{
			ItemID := TV_GetNext(ItemID, "Full")
			if not ItemID
				break
			TV_GetText(ItemText, ItemID)
			ItemName:=Get_Obj_Transform_Name(ItemText)
			if(ItemName=ItemEdit){
				TV_Modify(ItemID, "Expand Select")
				selIDTVEdit:=ItemID
				Gosub,TVEdit
				break
			}
		}
		TVEditItem=
	}
return
Menu_Edit1:
	both:=1
	iniFileWrite:=iniPath
	iniFileVar:=iniVar1
	Gosub,Menu_Edit_Gui
return
Menu_Edit2:
	both:=2
	iniFileWrite:=iniPath2
	iniFileVar:=iniVar2
	Gosub,Menu_Edit_Gui
return
#If WinActive(RunAnyZz "菜单树管理【" both "】")
	F5::
	PGDN::
		Gosub,TVDown
		return
	F6::
	PGUP::
		Gosub,TVUp
		return
	F3::Gosub,TVAdd
	F4::Gosub,TVAddTree
	F8::Gosub,TVImportFile
	F9::Gosub,TVImportFolder
	^s::Gosub,TVSave
	Esc::Gosub,MenuEditGuiClose
	F2::Gosub,TVEdit
	Tab::Send_Str_Zz(A_Tab)
#If
;~;[创建头部及右键功能菜单]
TVMenu(addMenu){
	flag:=(addMenu="GuiMenu") ? true : false
	Menu, %addMenu%, Add,% flag ? "保存" : "保存`tCtrl+S", TVSave
	Menu, %addMenu%, Icon,% flag ? "保存" : "保存`tCtrl+S", SHELL32.dll,194
	Menu, %addMenu%, Add,% flag ? "添加应用" : "添加应用`tF3", TVAdd
	Menu, %addMenu%, Icon,% flag ? "添加应用" : "添加应用`tF3", SHELL32.dll,3
	Menu, %addMenu%, Add,% flag ? "添加分类" : "添加分类`tF4", TVAddTree
	Menu, %addMenu%, Icon,% flag ? "添加分类" : "添加分类`tF4", SHELL32.dll,4
	Menu, %addMenu%, Add,% flag ? "编辑" : "编辑`tF2", TVEdit
	Menu, %addMenu%, Icon,% flag ? "编辑" : "编辑`tF2", SHELL32.dll,134
	Menu, %addMenu%, Add,% flag ? "删除" : "删除`tDel", TVDel
	Menu, %addMenu%, Icon,% flag ? "删除" : "删除`tDel", SHELL32.dll,132
	if(!flag)
		Menu, %addMenu%, Add,注释, TVComments
	;~ Menu, %addMenu%, Add
	Menu, %addMenu%, Add,移动到..., :moveMenu%both%
	try Menu, %addMenu%, Icon,移动到...,% MoveIconS[1],% MoveIconS[2]
	Menu, %addMenu%, Add,% flag ? "向下" : "向下`t(F5/PgDn)", TVDown
	try Menu, %addMenu%, Icon,% flag ? "向下" : "向下`t(F5/PgDn)",% DownIconS[1],% DownIconS[2]
	Menu, %addMenu%, Add,% flag ? "向上" : "向上`t(F6/PgUp)", TVUp
	try Menu, %addMenu%, Icon,% flag ? "向上" : "向上`t(F6/PgUp)",% UpIconS[1],% UpIconS[2]
	Menu, %addMenu%, Add
	Menu, %addMenu%, Add,% flag ? "多选导入" : "多选导入`tF8", TVImportFile
	Menu, %addMenu%, Icon,% flag ? "多选导入" : "多选导入`tF8", SHELL32.dll,55
	Menu, %addMenu%, Add,% flag ? "批量导入" : "批量导入`tF9", TVImportFolder
	Menu, %addMenu%, Icon,% flag ? "批量导入" : "批量导入`tF9", SHELL32.dll,46
	Menu, %addMenu%, Add,桌面导入, Desktop_Import
	Menu, %addMenu%, Icon,桌面导入, SHELL32.dll,35
	Menu, %addMenu%, Add,网站图标, Website_Icon
	Menu, %addMenu%, Icon,网站图标, SHELL32.dll,14
}
TVClick:
	if (A_GuiEvent == "e"){
		;~;完成编辑时
		TV_GetText(selVar, A_EventInfo)
		TV_Modify(A_EventInfo, Set_Icon(TreeImageListID,selVar))
		if(addID && RegExMatch(selVar,"S)^-+[^-]+.*")){
			insertID:=TV_Add("",A_EventInfo)
			TV_Modify(A_EventInfo, "Bold Expand")
			TV_Modify(insertID, "Select Vis")
			SendMessage, 0x110E, 0, TV_GetSelection(), , ahk_id %HTV%
			addID:=
			Gosub,TV_MoveMenuClean
		}
		TVFlag:=true
	}else if (A_GuiEvent == "K"){
		if (A_EventInfo = 46)
			Gosub,TVDel
	}else if (A_GuiEvent == "DoubleClick"){
		TV_GetText(selVar, A_EventInfo)
		if(!RegExMatch(selVar,"S)^-+[^-]+.*"))
			Gosub,TVEdit
	}else if (A_GuiEvent == "Normal" && A_GuiControl = "RunAnyTV") {
		TV_Modify(A_EventInfo, "Select Vis")
		TV_CheckUncheckWalk(A_GuiEvent,A_EventInfo,A_GuiControl)
	}
return
TVAdd:
	Gui, MenuEdit:Default
	selID:=TV_Add("",TV_GetParent(TV_GetSelection()),TV_GetSelection())
	itemGlobalWinKey:=0
	itemName:=itemPath:=hotStrOption:=hotStrShow:=itemGlobalHotKey:=itemGlobalKey:=getZz:=""
	menuGuiFlag:=true
	menuGuiEditFlag:=false
	Gosub,Menu_Item_Edit
return
TVAddTree:
	Gui, MenuEdit:Default
	selID:=TV_Add("",TV_GetParent(TV_GetSelection()),TV_GetSelection())
	TV_GetText(parentTreeName, TV_GetParent(TV_GetSelection()))
	itemName:=RegExReplace(parentTreeName,"S)(^-+).*","$1") "-"
	itemGlobalWinKey:=0
	itemPath:=hotStrOption:=hotStrShow:=itemGlobalHotKey:=itemGlobalKey:=getZz:=""
	menuGuiFlag:=true
	menuGuiEditFlag:=false
	ToolTip,% "菜单分类开头是" itemName "表示新建 " StrLen(itemName) "级目录",195,270
	SetTimer,RemoveToolTip,3500
	Gosub,Menu_Item_Edit
return
TVEdit:
	Gui,MenuEdit:Default
	selID:=TV_GetSelection()
	if(selIDTVEdit!="")
		selID:=selIDTVEdit
	TV_GetText(ItemText, selID)
	;分解已有菜单项到编辑框中
	Gosub,TVEdit_GuiVal
	menuGuiFlag:=true
	menuGuiEditFlag:=true
	selIDTVEdit:=""
	if(RunCtrlMenuItemFlag){
		Gui, MenuEdit:Destroy
		GuiControlSet("CtrlRun","vRunCtrlRunValue"
			,(itemName!="" && itemTrNum!="" && itemTrNum!=0) ? itemName "_:" itemTrNum : (itemName!="") ? itemName : itemPath)
		RunCtrlMenuItemFlag:=false
	}else{
		Gosub,Menu_Item_Edit
	}
return
TVEdit_GuiVal:
	itemGlobalWinKey:=itemTrNum:=setItemMode:=0
	itemName:=itemPath:=hotStrOption:=hotStrShow:=itemGlobalHotKey:=itemGlobalKey:=getZz:=""
	if(ItemText="|" || ItemText=";|" || ItemText="||" || ItemText=";||"){
		itemPath:=ItemText
	}else if(InStr(ItemText,"|") || InStr(ItemText,"-")=1){
		menuDiy:=StrSplit(ItemText,"|",,2)
		itemName:=menuDiy[1]
		itemPath:=menuDiy[2]
		;[分割Tab获取应用自定义热键]
		menuKeyStr:=RegExReplace(menuDiy[1], "S)\t+", A_Tab)
		menuKeys:=StrSplit(menuKeyStr,"`t")
		itemName:=menuKeys[1]
		if(InStr(menuKeyStr,"`t") && menuKeys[2]){
			itemGlobalHotKey:=menuKeys[2]
			itemGlobalKey:=menuKeys[2]
			if(InStr(menuKeys[2],"#")){
				itemGlobalWinKey:=1
				itemGlobalKey:=StrReplace(menuKeys[2], "#")
			}
		}
		;[设置透明度]
		if(RegExMatch(itemName,"S).*?_:(\d{1,2})$")){
			itemTrNum:=RegExReplace(itemName,"S).*?_:(\d{1,2})$","$1")
			itemName:=RegExReplace(itemName,"S)(.*)_:\d{1,2}$","$1")
		}
		;[设置热字符串启动方式]
		if(RegExMatch(itemName,"S):[*?a-zA-Z0-9]+?:[^:]*")){
			hotStr:=RegExReplace(itemName,"S)^[^:]*?(:[*?a-zA-Z0-9]+?:[^:]*)","$1")
			hotStrOption:=RegExReplace(hotstr,"S)^(:[*?a-zA-Z0-9]+?:)[^:]*","$1")
			hotStrShow:=RegExReplace(hotstr,"S)^:[^:]*?X[^:]*?:")
			itemName:=RegExReplace(itemName,"S)^([^:]*?):[*?a-zA-Z0-9]+?:[^:]*","$1")
		}
	}else{
		itemPath:=ItemText
	}
return
;~;【新增修改菜单项Gui】
Menu_Item_Edit:
	SaveLabel:=menuGuiFlag ? "SetSaveItemGui" : "SetSaveItem"
	PromptStr:=menuGuiFlag ? "需要" : "点击此处"
	setItemMode:=Get_Menu_Item_Mode(ItemText,true)
	If(setItemMode=2 || setItemMode=3){
		itemPath:=StrReplace(itemPath,"``t","`t")
		itemPath:=StrReplace(itemPath,"``n","`n")
	}
	if(InStr(itemName,"-")=1){
		treeYNum:=20
		itemNameText:="菜单分类"
	}else{
		treeYNum:=10
		itemNameText:="菜单项名"
	}
	SplitPath, itemPath, fName,, fExt, name_no_ext
	itemIconName:=itemName ? itemName : name_no_ext
	itemIconFile:=IconFolderList[menuItemIconFileName(itemIconName)]
	Gui,SaveItem:Destroy
	if(menuGuiFlag)
		Gui,SaveItem:+ownerMenuEdit
	Gui,SaveItem:Margin,20,20
	Gui,SaveItem:+Resize
	Gui,SaveItem:Font,,Microsoft YaHei
	Gui,SaveItem:Add, Text, xm+10 y+20 y20 w60, %itemNameText%：
	Gui,SaveItem:Add, Edit, x+5 yp-3 w350 vvitemName GEditItemPathChange, %itemName%
	Gui,SaveItem:Add, Picture, x+50 yp+3 w64 h-1 vvPictureIconAdd gSetItemIconPath, %itemIconFile%
	Gui,SaveItem:Add, Text,yp+8 w72 cGreen vvTextIconAdd gSetItemIconPath BackgroundTrans, 点击添加图标
	Gui,SaveItem:Add, Text,yp w72 cGreen vvTextIconDown gSetItemIconDown BackgroundTrans, 下载网站图标
	if(InStr(itemName,"-")!=1){
		Gui,SaveItem:Add, Text, xm+10 y+4 w60 vvTextHotStr, 热字符串：
		Gui,SaveItem:Font,,Consolas
		Gui,SaveItem:Add, Edit, x+5 yp-1 w60 vvhotStrOption, % hotStrShow="" ? ":*X:" : hotStrOption
		Gui,SaveItem:Add, Edit, x+5 yp w90 vvhotStrShow GHotStrShowChange, %hotStrShow%
		Gui,SaveItem:Font,,Microsoft YaHei
		Gui,SaveItem:Add, Text, x+5 yp+3 w55 vvTextTransparent,透明度(`%)
		Gui,SaveItem:Add, Slider, x+5 yp ToolTip w135 r1 vvitemTrNum,%itemTrNum%
	}
	Gui,SaveItem:Add,Text, xm+10 y+%treeYNum%+10 w100, 制 表 符 ：  Tab
	Gui,SaveItem:Add,Text, xm+10 y+%treeYNum% w60, 全局热键：
	Gui,SaveItem:Add,Hotkey,x+5 yp-3 w150 vvitemGlobalKey,%itemGlobalKey%
	Gui,SaveItem:Add,Checkbox,Checked%itemGlobalWinKey% x+5 yp+3 vvitemGlobalWinKey,Win
	Gui,SaveItem:Add,Text, x+5 yp cBlue w200 BackgroundTrans, %itemGlobalHotKey%
	Gui,SaveItem:Add,Text, xm+10 y+15 w100, 分 隔 符 ：  |
	Gui,SaveItem:Add,Text, xm+90 yp w355 cRed vvExtPrompt GSetSaveItemFullPath, 注意：RunAny不支持当前后缀无路径运行，%PromptStr%使用全路径
	Gui,SaveItem:Add, DropDownList,x+30 yp-5 w120 AltSubmit vvItemMode GChooseItemMode Choose%setItemMode%
		,启动路径|短语模式|模拟打字短语|热键映射|AHK热键映射|网址|文件夹|插件脚本函数
	
	Gui,SaveItem:Add,Text, xm+10 yp w60 vvSetFileSuffix,后缀菜单：
	Gui,SaveItem:Add,Button, xm+6 y+%treeYNum% w60 vvSetItemPath GSetItemPath,启动路径
	Gui,SaveItem:Font,,Consolas
	Gui,SaveItem:Add,Edit, x+10 yp WantTab w510 r5 vvitemPath GEditItemPathChange, %itemPath%
	Gui,SaveItem:Font,,Microsoft YaHei
	Gui,SaveItem:Add,Button, xm+6 yp w60 vvSetMenuPublic GSetMenuPublic,公共菜单
	Gui,SaveItem:Add,Button, xm+6 yp w60 vvSetMenuText GSetMenuText,文本菜单
	Gui,SaveItem:Add,Button, xm+6 yp w60 vvSetMenuFile GSetMenuFile,文件菜单
	Gui,SaveItem:Add,Button, xm+6 yp w60 vvSetMenuWindow GSetMenuWindow,软件菜单
	Gui,SaveItem:Add,Button, xm+6 yp+27 w60 vvSetFileRelativePath GSetFileRelativePath,相对路径
	Gui,SaveItem:Add,Button, xm+6 yp+27 w60 vvSetItemPathGetZz GSetItemPathGetZz,选中变量
	Gui,SaveItem:Add,Button, xm+6 yp+27 w60 vvSetItemPathClipboard GSetItemPathClipboard, 剪贴板 
	Gui,SaveItem:Add,Button, xm+6 yp+27 w60 vvSetShortcut GSetShortcut,快捷目标
	Gui,SaveItem:Add,Button, xm+6 yp+27 w60 vvSetSendStrEncrypt GSetSendStrEncrypt,加密短语

	Gui,SaveItem:Add,Button,Default xm+220 y+15 w75 vvSaveItemSaveBtn G%SaveLabel%,保存
	Gui,SaveItem:Add,Button,x+20 w75 vvSaveItemCancelBtn GSetCancel,取消
	Gui,SaveItem:Add,Text, xm+10 w590 cBlue vvStatusBar, %thisMenuStr% %thisMenuItemStr%
	Gui,SaveItem:Show,H365,新增修改菜单项 - %RunAnyZz% - 支持拖放应用 %RunAny_update_version% %RunAny_update_time%%AdminMode%
	GuiControl,SaveItem:Hide, vExtPrompt
	if(fExt!="lnk")
		GuiControl,SaveItem:Hide, vSetShortcut
	if(itemIconFile || setItemMode!=6){
		GuiControl,SaveItem:Hide, vTextIconDown
		if(itemIconFile){
			GuiControl,SaveItem:Hide, vTextIconAdd
		}
	}
	if(hotStrShow=""){
		GuiControl,SaveItem:Hide, vhotStrOption
		GuiControl,SaveItem:Move, vhotStrShow, x95 y47
	}
	itemNameText:=thisMenuStr:=thisMenuItemStr:=""
	Gosub,EditItemPathChange
return
;[保存新增修改菜单项内容]
SetSaveItemGui:
	Gui,SaveItem:Submit,NoHide
	itemGlobalKeyStr:=""
	if(vitemGlobalKey){
		if(!vitemName){
			MsgBox, 48, ,设置热键后必须填写菜单项名
			return
		}
		if(!vitemPath && InStr(vitemName,"-")!=1){
			MsgBox, 48, ,应用设置热键后必须填写启动路径
			return
		}
		itemGlobalKeySave:=vitemGlobalWinKey ? "#" . vitemGlobalKey : vitemGlobalKey
		itemGlobalKeyStr:=A_Tab . itemGlobalKeySave
		if(vitemGlobalKey!=itemGlobalKey || vitemGlobalWinKey!=itemGlobalWinKey){
			if(InStr(iniVar1,itemGlobalKeyStr "|") || InStr(iniVar2,itemGlobalKeyStr "|")){
				MsgBox, 48, ,该全局热键已经被其他菜单应用使用
				return
			}
		}
	}
	;保存热字符串
	if(vhotStrShow){
		if(vhotStrShow!=hotStrShow || vhotStrOption!=hotStrOption){
			vhotStrSave:=vhotStrOption ? vhotStrOption . vhotStrShow : ":*X:" vhotStrShow
			if(InStr(iniVar1,vhotStrSave "|") || InStr(iniVar2,vhotStrSave "|")){
				MsgBox, 48, ,该热字符串已经被其他菜单应用使用
				return
			}
		}
		vitemName.=vhotStrSave
	}
	if(vitemTrNum && vitemTrNum<100){
		vitemName.="_:" vitemTrNum
	}
	splitStr:=vitemName && vitemPath ? "|" : ""
	vitemPath:=StrReplace(vitemPath,"`t","``t")
	vitemPath:=StrReplace(vitemPath,"`n","``n")
	saveText:=vitemName . itemGlobalKeyStr . splitStr . vitemPath
	Gui,SaveItem:Destroy
	Gui,MenuEdit:Default
	TV_Modify(selID, , saveText)
	TV_Modify(selID, "Select Vis")
	TV_Modify(selID, Set_Icon(TreeImageListID,saveText))
	if(ItemText!=saveText)
		TVFlag:=true
	if(!menuGuiEditFlag && selID && RegExMatch(saveText,"S)^-+[^-]+.*")){
		insertID:=TV_Add("",selID)
		TV_Modify(selID, "Bold Expand")
		TV_Modify(insertID, "Select Vis")
		SendMessage, 0x110E, 0, TV_GetSelection(), , ahk_id %HTV%
		addID:=
		Gosub,TV_MoveMenuClean
	}
return
#If WinActive("新增修改菜单项 - " RunAnyZz " - 支持拖放应用")
	~^v::
		if(InStr(Clipboard,"|")){
			Sleep,200
			ItemText:=Trim(Clipboard)
			MsgBox,36,,是否需要把RunAny菜单项值，自动添加到各个编辑框中？
			IfMsgBox Yes
			{
				Gosub,TVEdit_GuiVal
				GuiControlSet("SaveItem","vitemGlobalKey",itemGlobalKey)
				GuiControlSet("SaveItem","vitemPath",itemPath)
				Gui,SaveItem:Submit, NoHide
				if(itemGlobalKey!="" && vitemGlobalKey=""){
					MsgBox, 48,,% itemGlobalHotKey "`n无法设置到全局热键的编辑框里，变为保存在菜单项名中`n"
					. "建议有特殊热键的菜单项，后续修改直接打开RunAny.ini来编辑生效"
					GuiControlSet("SaveItem","vitemName",menuDiy[1])
					GuiControlSet("SaveItem","vhotStrOption")
					GuiControlSet("SaveItem","vhotStrShow")
					GuiControlSet("SaveItem","vitemTrNum")
					GuiControlSet("SaveItem","vitemGlobalWinKey")
					Sleep,200
					GuiControlHide("SaveItem","vhotStrOption","vhotStrShow","vitemTrNum","vitemGlobalKey","vitemGlobalWinKey")
				}else{
					GuiControlSet("SaveItem","vitemName",itemName)
					GuiControlSet("SaveItem","vhotStrOption",hotStrOption)
					GuiControlSet("SaveItem","vhotStrShow",hotStrShow)
					GuiControlSet("SaveItem","vitemTrNum",itemTrNum)
					GuiControlSet("SaveItem","vitemGlobalWinKey",itemGlobalWinKey)
				}
			}
		}
	return
#If
EditItemPathChange:
	Gui,SaveItem:Submit, NoHide
	if(InStr(vitemName,"-")=1){
		GuiControlHide("SaveItem","vItemMode","vSetItemPath","vSetFileRelativePath","vSetItemPathGetZz","vSetItemPathClipboard","vSetShortcut")
		GuiControlShow("SaveItem","vSetFileSuffix","vSetMenuPublic","vSetMenuText","vSetMenuFile","vSetMenuWindow")
		GuiControl,SaveItem:Move, vSetFileSuffix, y+160
		GuiControl,SaveItem:Move, vSetMenuPublic, y+180
		GuiControl,SaveItem:Move, vSetMenuText, y+210
		GuiControl,SaveItem:Move, vSetMenuFile, y+240
		GuiControl,SaveItem:Move, vSetMenuWindow, y+270
	}else{
		GuiControlHide("SaveItem","vSetFileSuffix","vSetMenuPublic","vSetMenuText","vSetMenuFile","vSetMenuWindow")
		GuiControlShow("SaveItem","vItemMode","vSetItemPath","vSetFileRelativePath","vSetItemPathGetZz","vSetItemPathClipboard")
		filePath:=!vitemPath && vitemName ? vitemName : vitemPath
		itemPathMode:=StrReplace(filePath,"%getZz%",Chr(3))
		itemPathMode:=Get_Transform_Val(itemPathMode)
		getItemMode:=Get_Menu_Item_Mode(itemPathMode)
		if(filePath){
			if(getItemMode!=1 || EvDemandSearch || Check_Obj_Ext(filePath)){
				GuiControl, SaveItem:Hide, vExtPrompt
			}else{
				GuiControl, SaveItem:Show, vExtPrompt
			}
			fileValue:=RegExReplace(filePath,"iS)(.*?\.[a-zA-Z0-9-_]+)($| .*)","$1")	;去掉参数
			SplitPath, fileValue, fName,, fExt  ; 获取扩展名
			if(fExt="exe" || fExt="lnk"){
				GuiControlShow("SaveItem","vTextTransparent","vitemTrNum")
				if(fExt="lnk")
					GuiControlShow("SaveItem","vSetShortcut")
			}else{
				GuiControlHide("SaveItem","vTextTransparent","vitemTrNum")
			}
		}
		GuiControl, SaveItem:Choose, vItemMode,% getItemMode=60 ? 1 : getItemMode
	}
	if(SendStrDcKey!="" && encryptFlag && (getItemMode=2 || getItemMode=3)){
		GuiControlShow("SaveItem","vSetSendStrEncrypt")
	}else{
		GuiControlHide("SaveItem","vSetSendStrEncrypt")
	}
return
HotStrShowChange:
	Gui,SaveItem:Submit, NoHide
	if(vhotStrShow){
		GuiControl,SaveItem:Show, vhotStrOption
		GuiControl,SaveItem:Move, vhotStrShow, x160 y47
	}
return
;[启动模式变换]
ChooseItemMode:
	Gui,SaveItem:Submit, NoHide
	itemPathMode:=StrReplace(vitemPath,"%getZz%",Chr(3))
	itemPathMode:=Get_Transform_Val(itemPathMode)
	getItemMode:=Get_Menu_Item_Mode(itemPathMode)
	if((vItemMode=1 || vItemMode!=2) && getItemMode=2){	;清除短语
		StringTrimRight, vitemPath, vitemPath, 1
	}else if((vItemMode=1 || vItemMode!=3) && getItemMode=3){		;清除打字短语
		StringTrimRight, vitemPath, vitemPath, 2
	}else if((vItemMode=1 || vItemMode!=4) && getItemMode=4){		;清除热键映射
		StringTrimRight, vitemPath, vitemPath, 2
	}else if((vItemMode=1 || vItemMode!=5) && getItemMode=5){		;清除AHK热键映射
		StringTrimRight, vitemPath, vitemPath, 3
	}
	if(InStr(vitemName,"-")=1)
		return
	if(vItemMode=2 && getItemMode!=2){
		vitemPath.=";"
		GuiControl, SaveItem:,vStatusBar,此模式可把保存的短语 输出到任意位置
	}else if(vItemMode=3 && getItemMode!=3){
		vitemPath.=";;"
		GuiControl, SaveItem:,vStatusBar,此模式除输出短语外 ``n和``r转换为Enter键击  ``t转换为Tab键击  ``b转换为Backspace键击
	}else if(vItemMode=4 && getItemMode!=4){
		vitemPath.="::"
		GuiControl, SaveItem:,vStatusBar,此模式可以模拟人手发送键击 把全局热键映射成其他热键 ^代表Ctrl键 !代表Alt键 #代表Win键 +代表Shift键
	}else if(vItemMode=5 && getItemMode!=5){
		vitemPath.=":::"
		GuiControl, SaveItem:,vStatusBar,此模式可以映射发送任意已运行AHK脚本中的热键键击
	}
	GuiControl, SaveItem:, vitemPath, %vitemPath%
	Gosub,EditItemPathChange
return
SetMenuPublic:
	Gui,SaveItem:Submit, NoHide
	GuiControl, SaveItem:, vStatusBar,有public的菜单分类在任意不同情况菜单中都会显示
	GuiControl, SaveItem:, vitemPath, %vitemPath% public
return
SetMenuFile:
	Gui,SaveItem:Submit, NoHide
	GuiControl, SaveItem:, vStatusBar,有file的菜单分类会在选中文件内容的时候显示
	GuiControl, SaveItem:, vitemPath, %vitemPath% file
return
SetMenuWindow:
	webUrl:=rule_check_network(RunAnyGiteePages) ? RunAnyGiteePages : RunAnyGithubPages
	Run,% webUrl "/RunAny/#/CONFIG?id=软件专属菜单"
return
SetMenuText:
	Gui,SaveItem:Submit, NoHide
	GuiControl, SaveItem:, vStatusBar,有text的菜单分类会在选中文本内容的时候显示
	GuiControl, SaveItem:, vitemPath, %vitemPath% text
return
SetItemPath:
	FileSelectFile, fileSelPath, , , 启动文件路径
	if(fileSelPath){
		GuiControl, SaveItem:, vitemPath, % Get_Item_Run_Path(fileSelPath)
		Gosub,EditItemPathChange
	}
return
SetItemPathGetZz:
	GuiControl, SaveItem:, vStatusBar,`%getZz`%在运行时会转换为你鼠标选中的文本内容
	GuiControl, SaveItem:Focus, vitemPath
	Send_Str_Zz("%getZz%")
return
SetItemPathClipboard:
	GuiControl, SaveItem:, vStatusBar,`%Clipboard`%在运行时会转换为剪贴板里的文本内容
	GuiControl, SaveItem:Focus, vitemPath
	Send_Str_Zz("%Clipboard%")
return
SetSendStrEncrypt:
	Gui,SaveItem:Submit, NoHide
	if(vItemMode=2){
		if(RegExMatch(vitemPath,"S).+\$;$")){
			vitemPath:=RegExReplace(vitemPath,"\$;$")
			GuiControl, SaveItem:, vitemPath, % SendStrDecrypt(vitemPath) ";"
			return
		}
		vitemPath:=RegExReplace(vitemPath,";$")
		GuiControl, SaveItem:, vitemPath, % SendStrEncrypt(vitemPath) "$;"
	}else if(vItemMode=3){
		if(RegExMatch(vitemPath,"S).+\$;;$")){
			vitemPath:=RegExReplace(vitemPath,"\$;;$")
			GuiControl, SaveItem:, vitemPath, % SendStrDecrypt(vitemPath) ";;"
			return
		}
		vitemPath:=RegExReplace(vitemPath,";;$")
		GuiControl, SaveItem:, vitemPath, % SendStrEncrypt(vitemPath) "$;;"
	}
return
;[全路径转换为RunAnyCtrl的相对路径]
SetFileRelativePath:
	Gui,SaveItem:Submit, NoHide
	if(InStr(vitemPath,"`%A_ScriptDir`%\")=1){
		funcResult:=RegExReplace(vitemPath,"S)^`%A_ScriptDir`%\\")
		funcResult:=funcPath2AbsoluteZz(funcResult,A_ScriptFullPath)
		headPath=
	}else{
		headPath=`%A_ScriptDir`%\
		funcResult:=funcPath2RelativeZz(vitemPath,A_ScriptFullPath)
	}
	if(funcResult=-1){
		GuiControl, SaveItem:,vStatusBar,路径有误
		return
	}
	if(funcResult=-2){
		GuiControl, SaveItem:,vStatusBar,与RunAny不在同一磁盘，不能转换为相对路径
		return
	}
	if(funcResult){
		GuiControl, SaveItem:, vitemPath, %headPath%%funcResult%
		Gosub,EditItemPathChange
	}
return
SetItemIconPath:
	Gui,SaveItem:Submit, NoHide
	if(!vitemName && !vitemPath){
		MsgBox, 48, ,菜单项名和启动路径不能同时为空时设置图标
		return
	}
	FileSelectFile, iconSelPath, , , 图标文件路径, (%IconFileSuffix%)
	if(iconSelPath){
		SplitPath, vitemPath, fName,, fExt, name_no_ext
		itemIconName:=vitemName ? vitemName : name_no_ext
		itemIconName:=menuItemIconFileName(itemIconName)
		if(FileExist(itemIconFile) && iconSelPath!=itemIconFile){
			CreateDir(A_Temp "\" RunAnyZz "\" RunIcon)
			SplitPath, itemIconFile, iName
			FileMove, %itemIconFile%, %A_Temp%\%RunAnyZz%\RunIcon\%iName%,1
		}
		if(InStr(vitemName,"-")=1){
			iconCopyDir:=MenuIconDir
		}else if(RegExMatch(vitemPath,"iS)([\w-]+://?|www[.]).*")){
			iconCopyDir:=WebIconDir
		}else{
			iconCopyDir:=ExeIconDir
		}
		SplitPath, iconSelPath,,, iExt
		FileCopy, %iconSelPath%, %iconCopyDir%\%itemIconName%.%iExt%, 1
		Gosub,SetSaveItemGui
	}
return
SetItemIconDown:
	try {
		Gui,SaveItem:Submit, NoHide
		if(!vitemName && !vitemPath){
			MsgBox, 48, ,菜单项名和启动路径不能同时为空时设置图标
			return
		}
		if(RegExMatch(vitemPath,"iS)^([\w-]+://?|www[.]).*")){
			website:=RegExReplace(vitemPath,"iS)[\w-]+://?((\w+\.)+\w+).*","$1")
			webIcon:=WebIconDir "\" menuItemIconFileName(vitemName) ".ico"
			InputBox, webSiteInput, 下载网站图标,确认或修改下面的默认地址并下载图标ico文件`n`n如果下载错误或界面变空要重新下载图标`n`n
			(
请打开【修改菜单】界面选中后点“网站图标”按钮,,,,,,,,http://%website%/favicon.ico
			)
			if !ErrorLevel
			{
				URLDownloadToFile(webSiteInput,webIcon)
				MsgBox,65,,图标下载成功，是否要重新打开RunAny生效？
				IfMsgBox Ok
					Gosub,Menu_Reload
			}
		}
	} catch e {
		WebsiteIconError(webSiteInput)
	}
return
SetSaveItemFullPath:
	if(getZz && !menuGuiFlag){
		GuiControl, SaveItem:, vitemPath, %getZz%
		GuiControl, SaveItem:Hide, vPrompt
	}
return
SetShortcut:
	Gui,SaveItem:Submit, NoHide
	filePath:=!vitemPath && vitemName ? vitemName : vitemPath
	filePath:=Get_Obj_Path(filePath)	;补全路径
	if(!filePath)	;如果没补全，还原原选中文件地址
		filePath:=getZz
	SplitPath, filePath, ,, fExt  ; 获取扩展名
	if(filePath && fExt="lnk"){
		FileGetShortcut, %filePath%, exePath, OutDir, exeArgs
		exeArgs:=exeArgs ? A_Space exeArgs : ""
		if(exePath){
			GuiControl, SaveItem:, vitemPath, %exePath%%exeArgs%
		}
	}else{
		Gosub,SetSaveItemFullPath
	}
	Gosub,EditItemPathChange
return
TVDown:
	TV_Move(true)
return
TVUp:
	TV_Move(false)
return
TVDel:
	Gui, MenuEdit:Default
	selText:=""
	DelListID:=Object()
	CheckID = 0
	Loop
	{
		CheckID := TV_GetNext(CheckID, "Checked")
		if not CheckID
			break
		TV_GetText(ItemText, CheckID)
		selText.=ItemText "`n"
		DelListID.Push(CheckID)
	}
	if(!selText){
		MsgBox,64,,请最少勾选一项
		return
	}
	if(RegExMatch(selText,"S)^-+[^-]+.*"))
		MsgBox,51,请确认(Esc取消),确定删除勾中的【以及它下面的所有子项目】？(注意)`n%selText%
	else
		MsgBox,51,请确认(Esc取消),确定删除勾中的？`n%selText%
	IfMsgBox Yes
	{
		Loop,% DelListID.MaxIndex()
		{
			TV_Delete(DelListID[A_Index])
		}
		TVFlag:=true
		Gosub,TV_MoveMenuClean
	}
return
TVComments:
	Gui, MenuEdit:Default
	CheckID = 0
	Loop
	{
		CheckID := TV_GetNext(CheckID, "Checked")
		if not CheckID
			break
		TV_GetText(ItemText, CheckID)
		if(InStr(ItemText,";")=1){
			StringTrimLeft, ItemText, ItemText, 1
			Tv.modify({hwnd:CheckID,fore:0x000000})
		}else{
			ItemText:=";" ItemText
			Tv.modify({hwnd:CheckID,fore:0x00A000})
		}
		TV_Modify(CheckID, ,ItemText)
	}
return
TVSave:
	MsgBox, 4131, 菜单树保存, 是：保存后重启生效`n否：保存重启后继续修改`n取消：取消保存
	IfMsgBox Yes
	{
		Gosub,Menu_Save
		Gosub,Menu_Reload
	}
	IfMsgBox No
	{
		RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\RunAny, ReloadGosub, Menu_Edit%both%
		Gosub,Menu_Save
		Gosub,Menu_Reload
	}
return
Menu_Save:
	ItemID = 0
	tabText:=""
	saveText:=""
	Loop
	{
		ItemID := TV_GetNext(ItemID, "Full")
		if not ItemID
			break
		TV_GetText(ItemText, ItemID)
		;~;根据保存菜单树生成菜单ini文件
		treeLevel:=StrLen(RegExReplace(ItemText,"S)(^-+).+","$1"))
		if(RegExMatch(ItemText,"S)^-+[^-]+.*")){
			saveText.=Set_Tab(treeLevel-1) . ItemText . "`n"
			tabText:=Set_Tab(treeLevel)
		}else if(ItemText="-"){
			tabText:=""
			saveText.=tabText . ItemText . "`n"
		}else if(RegExMatch(ItemText,"S)^-+")){
			tabText:=Set_Tab(treeLevel)
			saveText.=tabText . ItemText . "`n"
		}else{
			saveText.=tabText . ItemText . "`n"
		}
	}
	if(saveText){
		FileDelete,%iniFileWrite%
		FileAppend,%saveText%,%iniFileWrite%
	}
return
;[制表符设置]
Set_Tab(tabNum){
	tabText:=""
	Loop,%tabNum%
	{
		tabText.=A_Tab
	}
	return tabText
}
;~;[多选导入]
TVImportFile:
	Gui, MenuEdit:Default
	selID:=TV_GetSelection()
	TV_GetText(ItemText, selID)
	if(InStr(ItemText,"-")=1){
		parentID:=selID
		TV_Modify(selID, "Bold Expand")
	}else{
		parentID:=TV_GetParent(selID)
	}
	FileSelectFile, exeName, M35, , 选择多项要导入的EXE(快捷方式), (*.exe;*.lnk)
	Loop,parse,exeName,`n
	{
		if(A_Index=1){
			lnkPath:=A_LoopField
		}else{
			I_LoopField:=A_LoopField
			exePath:=lnkPath "\" I_LoopField
			if Ext_Check(I_LoopField,StrLen(I_LoopField),".lnk"){
				FileGetShortcut,%lnkPath%\%I_LoopField%,exePath
				if Ext_Check(exePath,StrLen(exePath),".exe")
					SplitPath,exePath,I_LoopField
			}
			fileID:=TV_Add(I_LoopField,parentID,Set_Icon(TreeImageListID,exePath))
			TVFlag:=true
		}
	}
return
;~;[批量导入]
TVImportFolder:
	Gui, MenuEdit:Default
	selID:=TV_GetSelection()
	TV_GetText(ItemText, selID)
	if(InStr(ItemText,"-")=1){
		parentID:=selID
		TV_Modify(selID, "Bold Expand")
	}else{
		parentID:=TV_GetParent(selID)
	}
	FileSelectFolder, folderName, , 0
	if(folderName){
		MsgBox,33,导入文件夹所有exe和lnk,确定导入  %folderName%  及子文件夹下所有程序和快捷方式吗？
		IfMsgBox Ok
		{
			Loop,%folderName%\*.lnk,0,1
			{
				lnkID:=TV_Add(A_LoopFileName,parentID,Set_Icon(TreeImageListID,A_LoopFileFullPath))
			}
			Loop,%folderName%\*.exe,0,1
			{
				folderID:=TV_Add(A_LoopFileName,parentID,Set_Icon(TreeImageListID,A_LoopFileFullPath))
			}
			TVFlag:=true
		}
	}
return
Website_Icon:
	selText:=""
	selTextList:=Object()
	CheckID = 0
	Loop
	{
		CheckID := TV_GetNext(CheckID, "Checked")
		if not CheckID
			break
		TV_GetText(ItemText, CheckID)
		selText.=ItemText "`n"
		selTextList.Push(ItemText)
	}
	if(selTextList.MaxIndex()=1){
		try {
			diyText:=StrSplit(ItemText,"|",,2)
			webText:=(diyText[2]) ? diyText[2] : diyText[1]
			if(RegExMatch(webText,"iS)^([\w-]+://?|www[.]).*")){
				website:=RegExReplace(webText,"iS)[\w-]+://?((\w+\.)+\w+).*","$1")
				webIcon:=WebIconDir "\" menuItemIconFileName(diyText[1]) ".ico"
				InputBox, webSiteInput, 重新下载网站图标,可以重新下载图标并匹配网址`n`n请修改以下网址再点击下载,,,,,,,,http://%website%/favicon.ico
				if !ErrorLevel
				{
					URLDownloadToFile(webSiteInput,webIcon)
					MsgBox,65,,图标下载成功，是否要重新打开RunAny生效？
					IfMsgBox Ok
						Gosub,Menu_Reload
				}
			}
		} catch e {
			WebsiteIconError(webSiteInput)
		}
		return
	}
	if(selText){
		MsgBox,33,下载网站图标,确定下载以下选中的网站图标：`n(下载的图标在%WebIconDir%)`n%selText%
		IfMsgBox Ok
		{
			Loop,% selTextList.MaxIndex()
			{
				GuiControl, Show, MyProgress
				ItemText:=selTextList[A_Index]
				Gosub,Website_Icon_Down
			}
			if(errDown!="")
				WebsiteIconError(errDown)
			GuiControl, Hide, MyProgress
			MsgBox,65,,图标下载完成，是否要重新打开RunAny生效？
			IfMsgBox Ok
				Gosub,Menu_Reload
		}
		return
	}
	MsgBox,33,下载网站图标,确定下载RunAny内所有网站图标吗？`n(下载的图标在%WebIconDir%)
	IfMsgBox Ok
	{
		errDown:=""
		ItemID = 0
		Loop
		{
			ItemID := TV_GetNext(ItemID, "Full")
			if not ItemID
				break
			TV_GetText(ItemText, ItemID)
			if(InStr(ItemText,";")=1 || ItemText="")
				continue
			GuiControl, Show, MyProgress
			Gosub,Website_Icon_Down
		}
		if(errDown!="")
			WebsiteIconError(errDown)
		GuiControl, Hide, MyProgress
		MsgBox,65,,图标下载完成，是否要重新打开RunAny生效？
		IfMsgBox Ok
			Gosub,Menu_Reload
	}
return
Website_Icon_Down:
	try {
		diyText:=StrSplit(ItemText,"|",,2)
		webText:=(diyText[2]) ? diyText[2] : diyText[1]
		if(RegExMatch(webText,"iS)^([\w-]+://?|www[.]).*")){
			website:=RegExReplace(webText,"iS)[\w-]+://?((\w+\.)+\w+).*","$1")
			webIcon:=WebIconDir "\" menuItemIconFileName(diyText[1]) ".ico"
			URLDownloadToFile("http://" website "/favicon.ico",webIcon)
			GuiControl,, MyProgress, +10
		}
	} catch e {
		errDown.="http://" website "/favicon.ico`n"
	}
return
WebsiteIconError(errDown){
	MsgBox,64,,以下网站图标无法下载，请单选后点[网站图标]按钮重新指定网址下载，`n或手动添加对应图标到[%WebIconDir%]`n`n%errDown%
}
;~;[上下移动项目]
TV_Move(moveMode = true){
	Gui, MenuEdit:Default
	selID:=TV_GetSelection()
	moveID:=moveMode ? TV_GetNext(selID) : TV_GetPrev(selID)	; 向下：moveID为下个节点ID，向上：上个节点ID
	if(moveID!=0){
		TV_GetText(selVar, selID)
		TV_GetText(moveVar, moveID)
		selTreeFlag:=RegExMatch(selVar,"S)^-+[^-]+.*")
		moveTreeFlag:=RegExMatch(moveVar,"S)^-+[^-]+.*")
		selNextID:=moveMode ? moveID : TV_GetNext(selID)	; 向下：moveID即为树末节点，向上：选中树的下个同级节点为树末节点
		moveNextID:=!moveMode ? selID : TV_GetNext(moveID)	; 向上：selID即为树末节点，向下：目标树的下个同级节点为树末节点
		if((selTreeFlag || moveTreeFlag) && selNextID && moveNextID){
			DelListID:=Object()		; 需要删除的旧节点
			selTextList:=Object()	; 选中树的所有节点名列表
			moveTextList:=Object()	; 目标树的所有节点名列表
			ItemID:=selID
			Loop
			{
				ItemID := TV_GetNext(ItemID, "Full")
				if(ItemID=selNextID)	; 如果遍历到树末节点则跳出
					break
				TV_GetText(ItemText, ItemID)
				selTextList.Push(ItemText)
				DelListID.Push(ItemID)
			}
			ItemID:=moveID
			Loop
			{
				ItemID := TV_GetNext(ItemID, "Full")
				if(ItemID=moveNextID)	; 如果遍历到树末节点则跳出
					break
				TV_GetText(ItemText, ItemID)
				moveTextList.Push(ItemText)
				DelListID.Push(ItemID)
			}
			; 遍历旧节点数组删除
			Loop,% DelListID.MaxIndex()
			{
				TV_Delete(DelListID[A_Index])
			}
			; 遍历添加选中树内容到目标树
			Loop,% selTextList.MaxIndex()
			{
				TV_Add(selTextList[A_Index],moveID,Set_Icon(TreeImageListID,selTextList[A_Index]))
			}
			; 遍历添加目标树内容到选中树
			Loop,% moveTextList.MaxIndex()
			{
				TV_Add(moveTextList[A_Index],selID,Set_Icon(TreeImageListID,moveTextList[A_Index]))
			}
		}
		;~ [互换选中目标节点的名称]
		TV_Modify(selID, , moveVar)
		TV_Modify(moveID, , selVar)
		TV_Modify(selID, "-Select -focus")
		TV_Modify(moveID, "Select Vis")
		TV_Modify(selID, Set_Icon(TreeImageListID,moveVar))
		TV_Modify(moveID, Set_Icon(TreeImageListID,selVar))
		TVFlag:=true
	}
}
;~;[批量移动项目到指定树节点]
TV_MoveMenu(moveMenuName){
	moveItem:=RegExReplace(moveMenuName,"S)^-+")
	moveLevel:=StrLen(RegExReplace(moveMenuName,"S)(^-+).*","$1"))
	Menu,%moveMenuName%,add,%moveMenuName%,Move_Menu
	try {
		Menu,% moveRoot[moveLevel],add,%moveItem%, :%moveMenuName%
	} catch e {
		TrayTip,,% "右键操作菜单创建错误：" moveMenuName "`n出错命令：" e.What 
			. "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message,10,3
	}
	try Menu,% moveRoot[moveLevel],Icon,%moveItem%,% TreeIconS[1],% TreeIconS[2]
	moveLevel+=1
	moveRoot[moveLevel]:=moveMenuName
}
TV_MoveMenuClean:
	Gui, MenuEdit:Default
	try{
		;[清空功能菜单]
		Menu,TVMenu,DeleteAll
		Menu,GuiMenu,DeleteAll
		Menu,moveMenu%both%,DeleteAll
	}catch{}
	;[重建]
	ItemID = 0
	Loop
	{
		ItemID := TV_GetNext(ItemID, "Full")
		if not ItemID
			break
		TV_GetText(ItemText, ItemID)
		if(RegExMatch(ItemText,"S)^-+[^-]+.*")){
			TV_MoveMenu(ItemText)
		}
	}
	TVMenu("TVMenu")
	TVMenu("GuiMenu")
	Gui, MenuEdit:Menu, GuiMenu
return
;~;[移动节点后保存原来级别和自动变更名称(死了好多脑细胞)]
Move_Menu:
	Gui, MenuEdit:Default
	ItemID = 0
	MoveID = 0
	CheckID = 0
	DelListID:=Object()
	;[获取目标节点]
	Loop
	{
		ItemID := TV_GetNext(ItemID, "Full")
		if not ItemID
			break
		TV_GetText(ItemText, ItemID)
		if(ItemText=A_ThisMenuItem){
			MoveID:=ItemID
		}
	}
	;[获取选中节点并移动到目标节点下]
	if(MoveID){
		parentL:=StrLen(RegExReplace(A_ThisMenuItem,"S)(^-+).*","$1"))
		moveLevelID:=
		moveLevelList:=Object()
		moveLevelList[parentL]:=MoveID
		cpLevel:=0
		Loop
		{
			CheckID := TV_GetNext(CheckID, "Checked")
			if not CheckID
				break
			TV_GetText(ItemText, CheckID)
			;[对比选中节点到目标节点的级别，进行加减"-"级别匹配]
			if(InStr(ItemText,"-")=1){
				cItem:=RegExReplace(ItemText,"S)^-+")
				cLevel:=StrLen(RegExReplace(ItemText,"S)(^-+).*","$1"))
				;[如已有比选中节点高一级则它为父级,否则为目标节点级别]
				pLevel:=(moveLevelList[cLevel+Abs(cpLevel)]) ? cLevel+Abs(cpLevel) : parentL
				cpLevel:=cLevel-pLevel	;选中节点与目标的级别差
				if(cpLevel>1){	;选中节点比目标大于1级
					Loop,% cpLevel - 1
					{
						ItemText:=RegExReplace(ItemText,"S)^-")
					}
				}else if(cpLevel<1){	;选中节点比目标小于1级
					Loop,% Abs(1 - cpLevel)
					{
						ItemText:="-" . ItemText
					}
				}
				cLevel:=StrLen(RegExReplace(ItemText,"S)(^-+).*","$1"))
				if(Abs(cLevel-pLevel)=1){	;选中节点与目标差1级
					if(cItem){
						;[是节点不是分隔符]
						moveLevelID:=TV_Add(ItemText,moveLevelList[cLevel-1],Set_Icon(TreeImageListID,ItemText))
						moveLevelList[cLevel]:=moveLevelID
						MoveID:=moveLevelID
					}else{
						;[遇到分隔符则改变树型]
						TV_Add(ItemText,moveLevelList[cLevel-1],Set_Icon(TreeImageListID,ItemText))
						MoveID:=moveLevelList[cLevel-1]
					}
				}
			}else{
				moveLevelID:=TV_Add(ItemText,MoveID,Set_Icon(TreeImageListID,ItemText))
			}
			DelListID.Push(CheckID)
			TVFlag:=true
		}
		;[删除原先节点]
		Loop,% DelListID.MaxIndex()
		{
			TV_Delete(DelListID[A_Index])
		}
		;[焦点到移动后新节点]
		TV_Modify(moveLevelID, "VisFirst")
		TV_Modify(moveLevelID, "Select")
		Gosub,TV_MoveMenuClean
	}
return
;══════════════════════════════════════════════════════════════════
;~;【——🧩插件Gui——】
;══════════════════════════════════════════════════════════════════
Plugins_Gui:
	if(A_ThisHotkey!=PluginsManageKey && GetKeyState("Ctrl")){
		Open_Folder_Path(A_ScriptDir "\" PluginsDir)
		return
	}
	Critical  ;防止短时间内打开多次界面出现问题
	Gosub,Plugins_Read
	;根据网络自动选择对应插件说明网页地址
	pagesPluginsUrl:=RunAnyGiteePages . "/runany/#"
	if(!rule_check_network(RunAnyGiteePages)){
		pagesPluginsUrl:=RunAnyGithubPages . "/RunAny/#"
	}
	pagesPlugins:=pagesPluginsUrl . "/plugins-help?id="
	pagesRunCtrl:=pagesPluginsUrl . "/run-ctrl?id="
	global PluginsHelpList:={"huiZz_QRCode.ahk":pagesPlugins "huizz_qrcode二维码脚本使用方法"}
	PluginsHelpList["huiZz_Window.ahk"]:=pagesPlugins "huizz_window窗口操作插件使用方法"
	PluginsHelpList["huiZz_System.ahk"]:=pagesPlugins "huizz_system系统操作插件使用方法"
	PluginsHelpList["huiZz_Text.ahk"]:=pagesPlugins "huizz_text文本操作插件使用方法"
	PluginsHelpList["RunAny_SearchBar.ahk"]:=pagesPluginsUrl "/plugins/runany-searchbar"
	PluginsHelpList["RunCtrl_Common.ahk"]:=pagesRunCtrl "runctrl_commonahk插件-公共规则函数库"
	PluginsHelpList["RunCtrl_Network.ahk"]:=pagesRunCtrl "runctrl_networkahk插件-网络规则函数库"
	global ColumnName:=1
	global ColumnStatus:=2
	global ColumnAutoRun:=3
	global ColumnContent:=5
	global PluginsImageListID:=IL_Create(6)
	Plugins_LV_Icon_Set(PluginsImageListID)
	listViewColumnName1:=!PluginsListViewSwap ? "独立" : RunAnyZz
	listViewColumnName2:=!PluginsListViewSwap ? RunAnyZz : "独立"
	Gui,PluginsManage:Destroy
	Gui,PluginsManage:Default
	Gui,PluginsManage:+Resize
	Gui,PluginsManage:Font, s10, Microsoft YaHei
	Gui,PluginsManage:Add, Listview, xm w730 r13 grid AltSubmit Checked vRunAnyPluginsLV1 hwndPLLV1 gPluginsListView1
		, %listViewColumnName1%插件脚本|运行状态|自动启动|插件描述|插件说明地址
	GuiControl,PluginsManage: -Redraw, RunAnyPluginsLV1
	LV_SetImageList(PluginsImageListID)
	NPLLV1 := New ListView(PLLV1)
	NPLLV_Index:=0
	For runn, runv in PluginsObjList
	{
		SplitPath,runn,,,,pname_no_ext
		if(!PluginsListViewSwap){
			if(PluginsObjRegGUID[pname_no_ext] || pname_no_ext="RunAny_Menu" || pname_no_ext="RunAny_ObjReg")
				Continue
		}else if(!PluginsObjRegGUID[pname_no_ext] && pname_no_ext!="RunAny_Menu" && pname_no_ext!="RunAny_ObjReg"){
			Continue
		}
		NPLLV_Index++
		runStatus:=rule_check_is_run(PluginsPathList[runn]) ? "启动" : ""
		pluginsConfig:=runv ? "自启" : ""
		if(!PluginsPathList[runn])
			pluginsConfig:="未找到"
		pluginsConfigChenk:=pluginsConfig="自启" ? "Check" : ""
		LV_Add(LVPluginsSetIcon(PluginsImageListID,runn) " " pluginsConfigChenk, runn, runStatus, pluginsConfig, PluginsNameList[runn], PluginsHelpList[runn])
		if(pluginsConfig!="自启" && !runStatus)
			NPLLV1.Color(NPLLV_Index,0x999999)
	}
	LV_ModifyCol(ColumnStatus, "SortDesc")  ; 排序
	LVModifyCol(65,ColumnStatus,ColumnAutoRun)
	GuiControl,PluginsManage: +Redraw, RunAnyPluginsLV1

	Gui,PluginsManage:Add, Listview, xm y+10 w730 r12 grid AltSubmit Checked vRunAnyPluginsLV2 hwndPLLV2 gPluginsListView2
		, %listViewColumnName2%插件脚本|运行状态|自动启动|插件描述|插件说明地址
	GuiControl,PluginsManage: -Redraw, RunAnyPluginsLV2
	LV_SetImageList(PluginsImageListID)
	NPLLV2 := New ListView(PLLV2)
	NPLLV_Index:=0
	For runn, runv in PluginsObjList
	{
		SplitPath,runn,,,,pname_no_ext
		if(!PluginsListViewSwap){
			if(!PluginsObjRegGUID[pname_no_ext] && pname_no_ext!="RunAny_Menu" && pname_no_ext!="RunAny_ObjReg")
				Continue
		}else if(PluginsObjRegGUID[pname_no_ext] || pname_no_ext="RunAny_Menu" || pname_no_ext="RunAny_ObjReg"){
			Continue
		}
		NPLLV_Index++
		runStatus:=rule_check_is_run(PluginsPathList[runn]) ? "启动" : ""
		pluginsConfig:=runv ? "自启" : ""
		if(!PluginsPathList[runn])
			pluginsConfig:="未找到"
		pluginsConfigChenk:=pluginsConfig="自启" ? "Check" : ""
		LV_Add(LVPluginsSetIcon(PluginsImageListID,runn) " " pluginsConfigChenk, runn, runStatus, pluginsConfig, PluginsNameList[runn], PluginsHelpList[runn])
		if(pluginsConfig!="自启" && !runStatus)
			NPLLV2.Color(NPLLV_Index,0x999999)
	}
	LV_ModifyCol(ColumnStatus, "SortDesc")  ; 排序
	LVModifyCol(65,ColumnStatus,ColumnAutoRun)
	GuiControl,PluginsManage: +Redraw, RunAnyPluginsLV2
	LVMenu("LVMenu")
	LVMenu("ahkGuiMenu")
	Gui,PluginsManage: Menu, ahkGuiMenu
	Gui,PluginsManage:Show, , %RunAnyZz% 插件管理 - 支持拖放 %RunAny_update_version% %RunAny_update_time%%AdminMode%
	Critical,Off
return

LVMenu(addMenu){
	flag:=addMenu="ahkGuiMenu" ? true : false
	Menu, %addMenu%, Add,% flag ? "启动" : "启动`tF1", LVPluginsRun
	try Menu, %addMenu%, Icon,% flag ? "启动" : "启动`tF1", %A_AhkPath%,2
	Menu, %addMenu%, Add,% flag ? "编辑" : "编辑`tF2", LVPluginsEdit
	Menu, %addMenu%, Icon,% flag ? "编辑" : "编辑`tF2", SHELL32.dll,134
	Menu, %addMenu%, Add,% flag ? "自启" : "自启`tF3", LVPluginsEnable
	Menu, %addMenu%, Icon,% flag ? "自启" : "自启`tF3", SHELL32.dll,166
	Menu, %addMenu%, Add,% flag ? "关闭" : "关闭`tF4", LVPluginsClose
	Menu, %addMenu%, Icon,% flag ? "关闭" : "关闭`tF4", SHELL32.dll,28
	Menu, %addMenu%, Add,% flag ? "挂起" : "挂起`tF5", LVPluginsSuspend
	try Menu, %addMenu%, Icon,% flag ? "挂起" : "挂起`tF5", %A_AhkPath%,3
	Menu, %addMenu%, Add,% flag ? "暂停" : "暂停`tF6", LVPluginsPause
	try Menu, %addMenu%, Icon,% flag ? "暂停" : "暂停`tF6", %A_AhkPath%,4
	Menu, %addMenu%, Add,% flag ? "移除" : "移除`tF7", LVPluginsDel
	Menu, %addMenu%, Icon,% flag ? "移除" : "移除`tF7", SHELL32.dll,132
	Menu, %addMenu%, Add,% flag ? "下载插件" : "下载插件`tF8", LVPluginsAdd
	Menu, %addMenu%, Icon,% flag ? "下载插件" : "下载插件`tF8", SHELL32.dll,123
	Menu, %addMenu%, Add,% flag ? "插件说明" : "插件说明`tF9", LVPluginsHelp
	Menu, %addMenu%, Icon,% flag ? "插件说明" : "插件说明`tF9", SHELL32.dll,92
	Menu, %addMenu%, Add,% flag ? "插件库" : "插件库`tF10", LVPluginsLib
	Menu, %addMenu%, Icon,% flag ? "插件库" : "插件库`tF10", SHELL32.dll,42
	Menu, %addMenu%, Add,% flag ? "新建插件" : "新建插件`tF11", LVPluginsCreate
	Menu, %addMenu%, Icon,% flag ? "新建插件" : "新建插件`tF11", SHELL32.dll,1
	if(!flag)
		Menu, %addMenu%, Add, 上下交换, LVPluginsSwap
}
LVPluginsRun:
	menuItem:="启动"
	Gosub,LVApply
return
LVPluginsEdit:
	menuItem:="编辑"
	Gosub,LVApply
return
LVPluginsEnable:
	menuItem:="自启"
	Gosub,LVApply
return
LVPluginsClose:
	menuItem:="关闭"
	Gosub,LVApply
return
LVPluginsSuspend:
	menuItem:="挂起"
	Gosub,LVApply
return
LVPluginsPause:
	menuItem:="暂停"
	Gosub,LVApply
return
LVPluginsDel:
	menuItem:="移除"
	Gosub,LVApply
return
LVPluginsHelp:
	menuItem:="帮助"
	Gosub,LVApply
return
LVPluginsSwap:
	IniWrite,% !PluginsListViewSwap,%RunAnyConfig%,Config,PluginsListViewSwap
	Gosub,Plugins_Gui
return
LVApply:
	Gui,PluginsManage:Default
	GuiControlGet, focusGuiName, FocusV
	if(focusGuiName="RunAnyPluginsLV1"){
		Gui, ListView, RunAnyPluginsLV1
	}else if(focusGuiName="RunAnyPluginsLV2"){
		Gui, ListView, RunAnyPluginsLV2
	}
	DetectHiddenWindows,On      ;~显示隐藏窗口
	Row:=LV_GetNext(0, "F")
	RowNumber:=0
	if(Row && menuItem="移除"){
		MsgBox,35,确认移除？(Esc取消),确定移除选中的插件配置？(不会删除文件)
		DelRowList:=""
	}
	Loop
	{
		RowNumber := LV_GetNext(RowNumber)  ; 在前一次找到的位置后继续搜索.
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		LV_GetText(FileName, RowNumber, ColumnName)
		LV_GetText(FileStatus, RowNumber, ColumnStatus)
		LV_GetText(FileAutoRun, RowNumber, ColumnAutoRun)
		FilePath:=PluginsPathList[FileName]
		if(menuItem="启动"){
			runValue:=RegExReplace(FilePath,"iS)(.*?\.exe)($| .*)","$1")	;去掉参数
			try {
				SplitPath, runValue, name, dir, ext  ; 获取扩展名
				if(dir && FileExist(dir)){
					SetWorkingDir,%dir%
				}
				if(A_AhkPath && ext="ahk"){
					Run,%A_AhkPath%%A_Space%"%FilePath%"
				}else{
					Run,%FilePath%
				}
				LV_Modify(RowNumber, "", , "启动")
			} finally {
				SetWorkingDir,%A_ScriptDir%
			}
		}else if(menuItem="编辑"){
			Plugins_Edit(FilePath)
		}else if(menuItem="挂起"){
			PostMessage, 0x111, 65404,,, %FilePath% ahk_class AutoHotkey
			LVStatusChange(PluginsImageListID,RowNumber,FileStatus,"挂起",FileName)
		}else if(menuItem="暂停"){
			PostMessage, 0x111, 65403,,, %FilePath% ahk_class AutoHotkey
			LVStatusChange(PluginsImageListID,RowNumber,FileStatus,"暂停",FileName)
		}else if(menuItem="关闭"){
			runValue:=RegExReplace(FilePath,"iS)(.*?\.exe)($| .*)","$1")	;去掉参数
			SplitPath, runValue, name,, ext  ; 获取扩展名
			if(ext="ahk"){
				PostMessage, 0x111, 65405,,, %FilePath% ahk_class AutoHotkey
				runStatus:=""
			}else if(name){
				Process,Close,%name%
				if ErrorLevel
					runStatus:=""
			}
			LV_Modify(RowNumber, "", , runStatus)
		}else if(menuItem="自启"){
			if(FileAutoRun!="未找到" && FileAutoRun!="自启"){
				IniWrite,1,%RunAnyConfig%,Plugins,%FileName%
				LV_Modify(RowNumber, "", , ,"自启")
			}else if(FileAutoRun="自启"){
				IniWrite,0,%RunAnyConfig%,Plugins,%FileName%
				LV_Modify(RowNumber, "", , ,"禁用")
			}
		}else if(menuItem="移除"){
			IfMsgBox Yes
			{
				DelRowList := RowNumber . ":" . DelRowList
				IniDelete,%RunAnyConfig%,Plugins,%FileName% ;删除插件管理数据
				SplitPath,FileName,,,,o_name_no_ext
				IniDelete,%RunAny_ObjReg_Path%,objreg,%o_name_no_ext% ;删除插件注册数据
			}
		}else if(menuItem="帮助"){
			if(PluginsHelpList[FileName]){
				Run,% PluginsHelpList[FileName]
			}else{
				Plugins_Edit(FilePath)
			}
		}
	}
	if(menuItem="移除"){
		IfMsgBox Yes
		{
			stringtrimright, DelRowList, DelRowList, 1
			loop, parse, DelRowList, :
				LV_Delete(A_loopfield)
		}
	}
	DetectHiddenWindows,Off
return
;[插件脚本编辑操作]
Plugins_Edit(FilePath){
	try{
		if(Trim(PluginsEditor," `t`r`n")!=""){
			Run,% Get_Obj_Path_Transform(PluginsEditor) A_Space """" FilePath """"
		}else{
			PostMessage, 0x111, 65401,,, %FilePath% ahk_class AutoHotkey
		}
	}catch{
		try{
			RegRead, AhkSetup, HKEY_LOCAL_MACHINE\SOFTWARE\Classes\AutoHotkeyScript
			if(AhkSetup){
				Run,edit "%FilePath%"
			}else{
				Run,notepad.exe "%FilePath%"
			}
		}catch{
			Run,notepad.exe "%FilePath%"
		}
	}
}
#If WinActive(RunAnyZz " 插件管理 - 支持拖放 " RunAny_update_version A_Space RunAny_update_time)
	F1::Gosub,LVPluginsRun
	F2::Gosub,LVPluginsEdit
	F3::Gosub,LVPluginsEnable
	F4::Gosub,LVPluginsClose
	F5::Gosub,LVPluginsSuspend
	F6::Gosub,LVPluginsPause
	F7::Gosub,LVPluginsDel
	F8::Gosub,LVPluginsAdd
	F9::Gosub,LVPluginsHelp
	F10::Gosub,LVPluginsLib
	F11::Gosub,LVPluginsCreate
#If
PluginsListView1:
PluginsListView2:
	LV_Num:=A_ThisLabel="PluginsListView1" ? 1 : 2
    if A_GuiEvent = DoubleClick
    {
		menuItem:="启动"
		Gosub,LVApply
    }else if(A_GuiEvent = "I"){
		Gui,ListView,% PLLV%LV_Num%
		LV_GetText(FileName, A_EventInfo, 1)
		LV_GetText(FileAutoRun, A_EventInfo, 3)
		if(errorlevel == "c" && FileAutoRun="自启"){
			IniWrite,0,%RunAnyConfig%,Plugins,%FileName%
			NPLLV%LV_Num%.Color(A_EventInfo,0x999999)
			LV_Modify(A_EventInfo, "", , ,"禁用")
		}else if(errorlevel == "C" && FileAutoRun="禁用"){
			IniWrite,1,%RunAnyConfig%,Plugins,%FileName%
			NPLLV%LV_Num%.Color(A_EventInfo,0x000000)
			LV_Modify(A_EventInfo, "", , ,"自启")
		}
	}
return
;~;【插件-下载插件】
LVPluginsAdd:
	Gosub,PluginsDownVersion
	Gui,PluginsDownload:Destroy
	Gui,PluginsDownload:Default
	Gui,PluginsDownload:+Resize
	Gui,PluginsDownload:Font, s10, Microsoft YaHei
	Gui,PluginsDownload:Add, Listview, xm w620 r17 grid AltSubmit Checked BackgroundF6F6E8 vRunAnyDownLV, 插件文件|状态|版本号|最新版本|插件描述
	GuiControl,PluginsDownload: -Redraw, RunAnyDownLV
	global PluginsDownImageListID:=IL_Create(6)
	Plugins_LV_Icon_Set(PluginsDownImageListID)
	LV_SetImageList(PluginsDownImageListID)
	For pk, pv in pluginsDownList
	{
		runStatus:=PluginsPathList[pk] ? "已下载" : "未下载"
		if(runStatus="已下载" && checkGithub)
			runStatus:=PluginsVersionList[pk] < pv ? "可更新" : "已最新"
		runCheck:=runStatus="可更新" ? " Select Check" : ""
		LV_Add(LVPluginsSetIcon(PluginsDownImageListID,pk) runCheck, pk, runStatus, PluginsVersionList[pk]
			, checkGithub ? pv : "网络异常",checkGithub ? pluginsNameList[pk] : PluginsNameList[pk])
	}
	GuiControl,PluginsDownload: +Redraw, RunAnyDownLV
	Menu, ahkDownMenu, Add,全部勾选, LVPluginsCheck
	Menu, ahkDownMenu, Icon,全部勾选, SHELL32.dll,145
	Menu, ahkDownMenu, Add,下载勾选的插件脚本, LVDown
	Menu, ahkDownMenu, Icon,下载勾选的插件脚本, SHELL32.dll,123
	Gui,PluginsDownload: Menu, ahkDownMenu
	LVModifyCol(65,ColumnStatus,ColumnAutoRun)
	Gui,PluginsDownload:Show, , %RunAnyZz% 插件下载 %RunAny_update_version% %RunAny_update_time%%AdminMode%
return
LVPluginsCheck:
	LV_Modify(0, "Check Focus")   ; 勾选所有.
return
LVPluginsCreate:
newObjRegCount:=1
Loop,%A_ScriptDir%\%PluginsDir%\RunAny_NewObjReg_*.ahk
{
	newObjRegCount++
}
loop
{
	InputBox, newObjRegInput, ObjReg新建插件脚本名称,`n  新建插件脚本（默认自动启动），名称建议为`n`n  作者名_功能.ahk,,,,,,,,RunAny_NewObjReg_%newObjRegCount%.ahk
	if !ErrorLevel
	{
		if(!FileExist(A_ScriptDir "\" PluginsDir "\" newObjRegInput))
			break
		else
			MsgBox, 48, 文件重名, 已有同名的脚本存在，请重新输入
	}else{
		return
	}
}
SplitPath, newObjRegInput,,,,inputNameNotExt
;[新建ObjReg插件脚本模板]
FileAppend,
(
;************************
;* 【ObjReg插件脚本 %newObjRegCount%】
;************************
global RunAny_Plugins_Version:="1.0.0"
#NoTrayIcon             ;~不显示托盘图标
#Persistent             ;~让脚本持久运行
#SingleInstance,Force   ;~运行替换旧实例
;********************************************************************************
#Include `%A_ScriptDir`%\RunAny_ObjReg.ahk

class RunAnyObj {
	;[新建：你自己的函数]
	;保存到RunAny.ini为：菜单项名|你的脚本文件名%inputNameNotExt%[你的函数名](参数1,参数2)
	;你的函数名(参数1,参数2){
		;函数内容写在这里
`t`t
	;}
`t

;══════════════════════════大括号以上是RunAny菜单调用的函数══════════════════════════

}

;═══════════════════════════以下是脚本自己调用依赖的函数═══════════════════════════

;独立使用方式
;F1::
	;RunAnyObj.你的函数名(参数1,参数2)
;return
),%A_ScriptDir%\%PluginsDir%\%newObjRegInput%,UTF-8
IniWrite,1,%RunAnyConfig%,Plugins,%newObjRegInput%
Gosub,Plugins_Gui
Run,notepad.exe %A_ScriptDir%\%PluginsDir%\%newObjRegInput%
return
;~;【插件-脚本库Gui】
LVPluginsLib:
	PluginsDirPath:=StrReplace(PluginsDirPath, "|", "`n")
	Gui,PluginsLib:Destroy
	Gui,PluginsLib:Default
	Gui,PluginsLib:+OwnerPluginsManage
	Gui,PluginsLib:Margin,20,20
	Gui,PluginsLib:Font,,Microsoft YaHei
	Gui,PluginsLib:Add, GroupBox,xm y+10 w460 h220
	Gui,PluginsLib:Add, Text, xm+5 y+35 y35 w80,%A_Space%默认插件库：
	Gui,PluginsLib:Add, Text, x+5 yp,%A_ScriptDir%\%PluginsDir%
	Gui,PluginsLib:Add, Button, xm+10 y+15 w80 gSetPluginsDirPath,其他插件库：`n支持多行`n支持变量
	Gui,PluginsLib:Add, Edit, x+5 yp w350 r5 vvPluginsDirPath, %PluginsDirPath%
	Gui,PluginsLib:Add, Button, xm+10 y+10 w80 gSetPluginsEditor,插件编辑器：`n支持无路径%A_Tab%
	Gui,PluginsLib:Add, Edit, x+5 yp w350 r2 vvPluginsEditor, %PluginsEditor%
	Gui,PluginsLib:Font
	Gui,PluginsLib:Add,Button,Default xm+130 y+35 w75 GSavePluginsLib,保存(&S)
	Gui,PluginsLib:Add,Button,x+20 w75 GSetCancel,取消(&C)
	Gui,PluginsLib:Show,,%RunAnyZz% - 插件脚本库 %RunAny_update_version% %RunAny_update_time%
return
SetPluginsDirPath:
	Gui,PluginsLib:Submit, NoHide
	FileSelectFolder, pluginsLibFolder, , 0
	if(pluginsLibFolder){
		if(vPluginsDirPath){
			GuiControl,, vPluginsDirPath, %vPluginsDirPath%`n%pluginsLibFolder%
		}else{
			GuiControl,, vPluginsDirPath, %pluginsLibFolder%
		}
	}
return
SetPluginsEditor:
	FileSelectFile, pluginsLibFile, , , 插件编辑器路径
	if(pluginsLibFile){
		GuiControl,, vPluginsEditor, %pluginsLibFile%
	}
return
SavePluginsLib:
	Gui,PluginsLib:Submit, NoHide
	vPluginsDirPath:=RegExReplace(vPluginsDirPath,"S)[\n]+","|")
	IniWrite,%vPluginsDirPath%,%RunAnyConfig%,Config,PluginsDirPath
	IniWrite,%vPluginsEditor%,%RunAnyConfig%,Config,PluginsEditor
	Gui,PluginsLib:Destroy
	Gui,PluginsManage:Destroy
	Gosub,Plugins_Gui
return

LVDown:
	MsgBox,33,RunAny下载插件,是否下载插件？如有修改过插件代码请注意备份！`n
	(
仅仅更新下载 %A_ScriptDir%\%PluginsDir% 目录下的插件
(旧版文件会转移到%A_Temp%\%RunAnyZz%\%PluginsDir%)
	)
	IfMsgBox Ok
	{
		if(!rule_check_network(giteeUrl)){
			RunAnyDownDir:=githubUrl . RunAnyGithubDir
			if(!rule_check_network(githubUrl)){
				MsgBox,48,,网络异常，无法连接网络读取最新版本文件，请手动下载
				return
			}
		}
		downFlag:=false
		firstUpdateFlag:=false
		Loop
		{
			RowNumber := LV_GetNext(RowNumber, "Checked")  ; 再找勾选的行
			if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
				break
			LV_GetText(FileName, RowNumber, ColumnName)
			LV_GetText(FileStatus, RowNumber, ColumnStatus)
			LV_GetText(FileContent, RowNumber, ColumnContent)
			TrayTip,,RunAny开始下载%FileName%，请稍等……,3,17
			SetTimer, HideTrayTip, -3000
			pluginsDownPath=%PluginsDir%
			;如果插件需要创建目录
			if(RegExMatch(FileContent,"iS)\{\}$")){
				SplitPath, FileName, fName,, fExt, name_no_ext
				pluginsDownPath.="\" name_no_ext
				CreateDir(A_ScriptDir "\" pluginsDownPath)
			}
			;特殊插件下载依赖
			if(FileName="huiZz_QRCode.ahk"){
				TrayTip,,huiZz_QRCode需要下载quricol32.dll，请稍等……,3,17
				SetTimer, HideTrayTip, -3000
				URLDownloadToFile(RunAnyDownDir "/" PluginsDir "/" name_no_ext "/quricol32.dll",A_ScriptDir "\" pluginsDownPath "\quricol32.dll")
				Plugins_Down_Check("二维码插件quricol32.dll", A_ScriptDir "\" pluginsDownPath "\quricol32.dll")
				if(A_Is64bitOS){
					URLDownloadToFile(RunAnyDownDir "/" PluginsDir "/" name_no_ext "/quricol64.dll",A_ScriptDir "\" pluginsDownPath "\quricol64.dll")
					Plugins_Down_Check("二维码插件quricol64.dll", A_ScriptDir "\" pluginsDownPath "\quricol64.dll")
				}
			}else if(FileName="RunCtrl_Network.ahk"){
				TrayTip,,RunCtrl_Network.ahk需要下载组件JSON.ahk，请稍等……,3,17
				SetTimer, HideTrayTip, -3000
				URLDownloadToFile(RunAnyDownDir "/" PluginsDir "/Lib/JSON.ahk",A_ScriptDir "\" PluginsDir "\Lib\JSON.ahk")
				Plugins_Down_Check("RunCtrl_Network.ahk需要下载组件JSON.ahk", A_ScriptDir "\" PluginsDir "\Lib\JSON.ahk")
			}else if(FileName="RunAny_SearchBar.ahk"){
				TrayTip,,RunAny_SearchBar.ahk需要下载汉字转拼音组件ChToPy.ahk，请稍等……,3,17
				SetTimer, HideTrayTip, -3000
				URLDownloadToFile(RunAnyDownDir "/" PluginsDir "/Lib/ChToPy.ahk",A_ScriptDir "\" PluginsDir "\Lib\ChToPy.ahk")
				CreateDir(A_ScriptDir "\" PluginsDir "\Lib\ChToPy_dll_32")
				URLDownloadToFile(RunAnyDownDir "/" PluginsDir "/Lib/ChToPy_dll_32/cpp2ahk.dll",A_ScriptDir "\" PluginsDir "\Lib\ChToPy_dll_32\cpp2ahk.dll")
				if(A_Is64bitOS){
					CreateDir(A_ScriptDir "\" PluginsDir "\Lib\ChToPy_dll_64")
					URLDownloadToFile(RunAnyDownDir "/" PluginsDir "/Lib/ChToPy_dll_64/cpp2ahk.dll",A_ScriptDir "\" PluginsDir "\Lib\ChToPy_dll_64\cpp2ahk.dll")
					Sleep, 1000
					Plugins_Down_Check(PluginsDir "\Lib\ChToPy_dll_64\cpp2ahk.dll", A_ScriptDir "\" PluginsDir "\Lib\ChToPy_dll_64\cpp2ahk.dll")
				}
				Sleep, 1000
				Plugins_Down_Check("RunAny_SearchBar.ahk需要下载汉字转拼音组件ChToPy.ahk", A_ScriptDir "\" PluginsDir "\Lib\ChToPy.ahk")
				Plugins_Down_Check(PluginsDir "\Lib\ChToPy_dll_32\cpp2ahk.dll", A_ScriptDir "\" PluginsDir "\Lib\ChToPy_dll_32\cpp2ahk.dll")
			}
			;[下载插件脚本]
			IfExist,%A_ScriptDir%\%pluginsDownPath%\%FileName%
				FileMove,%A_ScriptDir%\%pluginsDownPath%\%FileName%,%A_Temp%\%RunAnyZz%\%pluginsDownPath%\%FileName%,1
			URLDownloadToFile(RunAnyDownDir "/" StrReplace(pluginsDownPath,"\","/") "/" FileName,A_ScriptDir "\" pluginsDownPath "\" FileName)
			Sleep,1000
			Plugins_Down_Check(FileName, A_ScriptDir "\" pluginsDownPath "\" FileName)
			downFlag:=true
			if(FileStatus="未下载"){
				firstUpdateFlag:=true
			}
		}
		if(downFlag){
			if(firstUpdateFlag){
				if(PluginsHelpList[FileName]){
					Run,%pagesPluginsUrl%
					Sleep,1000
					MsgBox, 64, ,RunAny插件下载成功，请在网页上阅读对应插件使用说明后使用
				}else{
					MsgBox, 64, ,RunAny插件下载成功，在插件管理界面点击“编辑”按钮可以阅读说明和进行配置
				}
			}
			RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\RunAny, ReloadGosub, Plugins_Gui
			Gosub,Menu_Reload
		}else{
			ToolTip,请至少选中一项
			SetTimer,RemoveToolTip,2000
		}
	}
return
;[加载插件脚本图标]
Plugins_LV_Icon_Set(PluginsImageListID){
	IL_Add(PluginsImageListID, A_AhkPath, 1)
	IL_Add(PluginsImageListID, A_AhkPath, 2)
	IL_Add(PluginsImageListID, A_AhkPath, 3)
	IL_Add(PluginsImageListID, A_AhkPath, 4)
	IL_Add(PluginsImageListID, A_AhkPath, 5)
	IL_Add(PluginsImageListID, FuncIconS[1], FuncIconS[2])
}
;[插件管理独立脚本一键关闭]
Plugins_Alone_Pause:
	Plugins_Alone("暂停")
return
Plugins_Alone_Suspend:
	Plugins_Alone("挂起")
return
Plugins_Alone_Close:
	Plugins_Alone("关闭")
return
Plugins_Alone(r){
	DetectHiddenWindows,On      ;~显示隐藏窗口
	For runn, runv in PluginsPathList
	{
		SplitPath,runv,,,,pname_no_ext
		if(PluginsObjRegGUID[pname_no_ext]){
			continue
		}
		if(r="暂停"){
			PostMessage, 0x111, 65403,,, %runv% ahk_class AutoHotkey
		}else if(r="挂起"){
			PostMessage, 0x111, 65404,,, %runv% ahk_class AutoHotkey
		}else if(r="关闭"){
			PostMessage, 0x111, 65405,,, %runv% ahk_class AutoHotkey
		}
	}
	DetectHiddenWindows,Off
}

LVPluginsSetIcon(PluginsImageListID,pname){
	if(PluginsIconList[pname]){
		FileIconS:=StrSplit(Get_Transform_Val(PluginsIconList[pname]),",")
		addNum:=IL_Add(PluginsImageListID, FileIconS[1], FileIconS[2])
		return "Icon" addNum
	}
	SplitPath,pname,,,,pname_no_ext
	if(PluginsObjRegGUID[pname_no_ext]){
		return "Icon6"
	}
	return "Icon2"
}
;[判断脚本当前状态]
LVStatusChange(PluginsImageListID,RowNumber,FileStatus,lvItem,FileName){
	item:=lvItem
	if(FileStatus="挂起" && lvItem="暂停"){
		LV_Modify(RowNumber, "Icon5", ,"挂起暂停")
		LV_ModifyCol()
		return
	}else if(FileStatus="暂停" && lvItem="挂起"){
		LV_Modify(RowNumber, "Icon5", ,"暂停挂起")
		LV_ModifyCol()
		return
	}else if(FileStatus!="启动"){
		StringReplace, lvItem, FileStatus, %item%
	}
	if(lvItem="")
		lvItem:="启动"
	if(lvItem="启动"){
		LV_Modify(RowNumber, LVPluginsSetIcon(PluginsImageListID,FileName), ,lvItem)
	}else if(lvItem="挂起"){
		LV_Modify(RowNumber, "Icon3", ,lvItem)
	}else if(lvItem="暂停"){
		LV_Modify(RowNumber, "Icon4", ,lvItem)
	}
	LV_ModifyCol()
}
;══════════════════════════════════════════════════════════════════
;~;【——🔗启动控制Gui——】
;══════════════════════════════════════════════════════════════════
RunCtrl_Manage_Gui:
	Gosub,RunCtrl_Read
	RunCtrlListBoxChoose:=1
	if(RunCtrlListBox!=""){
		RunCtrlListBoxChoose:=GetKeyByVal(RunCtrlListBoxList, RunCtrlListBox)
	}
	Gui,RunCtrlManage:Destroy
	Gui,RunCtrlManage:Default
	Gui,RunCtrlManage:+Resize
	Gui,RunCtrlManage:Font, s10, Microsoft YaHei
	Gui,RunCtrlManage:Add, ListBox, x16 w130 vRunCtrlListBox gRunCtrlListClick Choose%RunCtrlListBoxChoose%, %RunCtrlListBoxVar%
	Gui,RunCtrlManage:Add, Listview,x+15 w570 r15 grid AltSubmit vRunCtrlLV gRunCtrlListView, 启动项|类型|重复运行|管理员运行|运行方式|最后运行时间
	LVImageListID := IL_Create(11)
	Icon_Image_Set(LVImageListID)
	LV_SetImageList(LVImageListID)
	Gosub,RunCtrlListClick
	RunCtrlLVMenu("RunCtrlLVMenu")
	RunCtrlLVMenu("RunCtrlManageMenu")
	Gui,RunCtrlManage: Menu, RunCtrlManageMenu
	Gui,RunCtrlManage:Show, w755 , RunCtrl 启动管理 %RunAny_update_version% %RunAny_update_time%%AdminMode%(双击修改，右键操作)
	Sleep,200
	if(RuleNameStr="" || RunCtrlListBoxVar=""){
		MsgBox,64,,首次使用请阅读：`n1. 先点击“规则管理”按钮后再点击“添加默认规则”`n
		(
2. 然后返回界面点击“添加规则组”`n3. 最后再点击“添加启动应用”`n`n这样就可以自动根据不同规则判断来运行不同的程序了
		)
	}
return

RunCtrlListClick:
	if (A_GuiEvent = "Normal" || A_GuiEvent = "")
	{
		Gui,RunCtrlManage:Default
		Gui,RunCtrlManage:Submit, NoHide
		LV_delete()
		GuiControl,RunCtrlManage:-Redraw, RunCtrlLV
		For runn, runv in RunCtrlList[RunCtrlListBox].runList
		{
			LV_Add(Set_Icon(LVImageListID,runv.noPath ? Get_Obj_Path(runv.path) : runv.path,false,false,runv.path)
				, runv.path, runv.noPath ? "菜单项" : "全路径", runv.repeatRun ? "重复" : "", runv.adminRun ? "管理员" : ""
				, StrReplace(RunCtrlRunWayList[runv.runWay],"启动"), time_format(runv.lastRunTime))
		}
		GuiControl,RunCtrlManage:+Redraw, RunCtrlLV
		LV_ModifyCol()
		LV_ModifyCol(1,245)
		LV_ModifyCol(6,150)
	}else if A_GuiEvent = DoubleClick
	{
		Gosub,RunCtrlLVEdit
	}
return
RunCtrlListView:
    if A_GuiEvent = DoubleClick
    {
		Gosub,LVCtrlRunEdit
    }
return
;创建头部及右键功能菜单
RunCtrlLVMenu(addMenu){
	flag:=addMenu="RunCtrlManageMenu" ? true : false
	Menu, %addMenu%, Add,% flag ? "启动" : "启动`tF1", RunCtrlLVRun
	Menu, %addMenu%, Icon,% flag ? "启动" : "启动`tF1",% RunCtrlManageIconS[1],% RunCtrlManageIconS[2]
	Menu, %addMenu%, Add,% flag ? "添加规则组" : "添加规则组`tF3", RunCtrlLVAdd
	Menu, %addMenu%, Icon,% flag ? "添加规则组" : "添加规则组`tF3", SHELL32.dll,22
	Menu, %addMenu%, Add,% flag ? "添加启动应用" : "添加启动应用`tF4", LVCtrlRunAdd
	Menu, %addMenu%, Icon,% flag ? "添加启动应用" : "添加启动应用`tF4",% EXEIconS[1],% EXEIconS[2]
	Menu, %addMenu%, Add,% flag ? "编辑" : "编辑`tF2", RunCtrlLVEdit
	Menu, %addMenu%, Icon,% flag ? "编辑" : "编辑`tF2", SHELL32.dll,134
	Menu, %addMenu%, Add,% flag ? "移除" : "移除`tDel", RunCtrlLVDel
	Menu, %addMenu%, Icon,% flag ? "移除" : "移除`tDel", SHELL32.dll,132
	Menu, %addMenu%, Add,% flag ? "规则管理" : "规则管理`tF7", Rule_Manage_Gui
	Menu, %addMenu%, Icon,% flag ? "规则管理" : "规则管理`tF7", imageres.dll,112
	Menu, %addMenu%, Add,% flag ? "导入" : "导入`tF8", RunCtrlLVImport
	Menu, %addMenu%, Icon,% flag ? "导入" : "导入`tF8", SHELL32.dll,55
	Menu, %addMenu%, Add,% flag ? "下移" : "下移`t(F5/PgDn)", RunCtrlLVDown
	try Menu, %addMenu%, Icon,% flag ? "下移" : "下移`t(F5/PgDn)",% DownIconS[1],% DownIconS[2]
	Menu, %addMenu%, Add,% flag ? "上移" : "上移`t(F6/PgUp)", RunCtrlLVUp
	try Menu, %addMenu%, Icon,% flag ? "上移" : "上移`t(F6/PgUp)",% UpIconS[1],% UpIconS[2]
	Menu, %addMenu%, Add,% flag ? "全选" : "全选`tCtrl+A", RunCtrlLVSelect
}
RunCtrlLVDel:
	Gui,RunCtrlManage:Default
	if(RunCtrlListBox="")
		return
	GuiControlGet, focusGuiName, Focus
	if(focusGuiName="ListBox1"){
		MsgBox,35,确认移除规则组 %RunCtrlListBox%？(Esc取消),确定移除规则组：%RunCtrlListBox% ？`n【注意!】：同时会移除 %RunCtrlListBox% 下的所有启动项和规则条件！
		IfMsgBox Yes
		{
			IniDelete,%RunAnyConfig%,RunCtrlList,%RunCtrlListBox%
			IniDelete,%RunAnyConfig%,%RunCtrlListBox%_Run
			IniDelete,%RunAnyConfig%,%RunCtrlListBox%_Rule
			Gosub,RunCtrl_Manage_Gui
		}
	}
	if(focusGuiName!="SysListView321"){
		return
	}
	Row:=LV_GetNext(0, "F")
	RowNumber:=0
	if(Row){
		MsgBox,35,确认移除？(Esc取消),确定移除当前选中的启动项？
		DelRowList:=""
	}
	DelRunValList:=Object()
	Loop
	{
		RowNumber := LV_GetNext(RowNumber)  ; 在前一次找到的位置后继续搜索.
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		LV_GetText(RunCtrlRunValue, RowNumber, 1)
		LV_GetText(RunCtrlNoPath, RowNumber, 2)
		LV_GetText(RunCtrlRepeatRun, RowNumber, 3)
		LV_GetText(RunCtrlAdminRun, RowNumber, 4)
		LV_GetText(RunCtrlRunWay, RowNumber, 5)
		IfMsgBox Yes
		{
			DelRowList := RowNumber . ":" . DelRowList
			oldStr:=RunCtrlRunIniKeyJoin(RunCtrlNoPath="菜单项", RunCtrlRepeatRun="重复", RunCtrlAdminRun="管理员"
				, GetKeyByVal(RunCtrlRunWayList, RunCtrlRunWay "启动")) "=" RunCtrlRunValue
			DelRunValList[oldStr]:=true
			IniDelete, %RunCtrlLastTimeIni%, last_run_time, %RunCtrlRunValue%
		}
	}
	IfMsgBox Yes
	{
		DelRowList:=SubStr(DelRowList, 1, -StrLen(":"))
		loop, parse, DelRowList, :
			LV_Delete(A_loopfield)

		IniRead,ctrlAppsVar,%RunAnyConfig%,%RunCtrlListBox%_Run
		runContent:=""
		Loop, parse, ctrlAppsVar, `n, `r
		{
			runContent.=DelRunValList[A_LoopField] ? "" : A_LoopField "`n"
		}
		IniWrite,%runContent%,%RunAnyConfig%,%RunCtrlListBox%_Run
		Gosub,RunCtrl_Read
	}
return
#If WinActive("RunCtrl 启动管理 " RunAny_update_version A_Space RunAny_update_time)
	F1::Gosub,RunCtrlLVRun
	F2::Gosub,RunCtrlLVEdit
	F3::Gosub,RunCtrlLVAdd
	F4::Gosub,LVCtrlRunAdd
	Del::Gosub,RunCtrlLVDel
	F7::Gosub,Rule_Manage_Gui
	^a::Gosub,RunCtrlLVSelect
#If
RunCtrlLVUp:
RunCtrlLVDown:
	Gui,RunCtrlManage:Default
	Gui,RunCtrlManage:Submit, NoHide
	if(RunCtrlListBox=""){
		return
	}
	GuiControlGet, focusGuiName, Focus
	if(focusGuiName="ListBox1"){
		;上下移动规则组
		RunCtrlListContent:=""
		for i,v in RunCtrlListBoxList
		{
			if(A_ThisLabel="RunCtrlLVDown"){
				if(RunCtrlListBox=v){
					if((i + 1) > RunCtrlListBoxList.MaxIndex()){
						return
					}
					RunCtrlListContent.=RunCtrlListBoxList[i + 1] "=" RunCtrlListContentList[RunCtrlListBoxList[i + 1]] "`n"
					RunCtrlListContent.=v "=" RunCtrlListContentList[v] "`n"
				}else if(RunCtrlListBox!=RunCtrlListBoxList[i - 1]){
					RunCtrlListContent.=v "=" RunCtrlListContentList[v] "`n"
				}
			}else if(A_ThisLabel="RunCtrlLVUp"){
				if(RunCtrlListBox=v){
					if((i - 1) <= 0){
						return
					}
					RunCtrlListContent.=v "=" RunCtrlListContentList[v] "`n"
					RunCtrlListContent.=RunCtrlListBoxList[i - 1] "=" RunCtrlListContentList[RunCtrlListBoxList[i - 1]] "`n"
				}else if(RunCtrlListBox!=RunCtrlListBoxList[i + 1]){
					RunCtrlListContent.=v "=" RunCtrlListContentList[v] "`n"
				}
			}
		}
		RunCtrlListContent:=SubStr(RunCtrlListContent, 1, -StrLen("`n"))
		IniWrite,%RunCtrlListContent%,%RunAnyConfig%,RunCtrlList
		Gosub,RunCtrl_Manage_Gui
		return
	}
	RunRowNumber1 := LV_GetNext(0, "F")
	if not RunRowNumber1
		return
	if(A_ThisLabel="RunCtrlLVDown"){
		RunRowNumber2 := RunRowNumber1 + 1 
		RunRowCount := LV_GetCount()
		if(RunRowNumber2 > RunRowCount)
			return
	}else if(A_ThisLabel="RunCtrlLVUp"){
		RunRowNumber2 := RunRowNumber1 - 1 
		if(RunRowNumber2 <= 0)
			return
	}
	LV_GetText(RunCtrlRunValue1, RunRowNumber1, 1)
	LV_GetText(RunCtrlNoPath1, RunRowNumber1, 2)
	LV_GetText(RunCtrlRepeatRun1, RunRowNumber1, 3)
	LV_GetText(RunCtrlAdminRun1, RunRowNumber1, 4)
	LV_GetText(RunCtrlRunWay1, RunRowNumber1, 5)
	LV_GetText(RunCtrlLastRunTime1, RunRowNumber1, 6)

	LV_GetText(RunCtrlRunValue2, RunRowNumber2, 1)
	LV_GetText(RunCtrlNoPath2, RunRowNumber2, 2)
	LV_GetText(RunCtrlRepeatRun2, RunRowNumber2, 3)
	LV_GetText(RunCtrlAdminRun2, RunRowNumber2, 4)
	LV_GetText(RunCtrlRunWay2, RunRowNumber2, 5)
	LV_GetText(RunCtrlLastRunTime2, RunRowNumber2, 6)

	LV_Modify(RunRowNumber1,Set_Icon(LVImageListID,RunCtrlNoPath2 ? Get_Obj_Path(RunCtrlRunValue2) : RunCtrlRunValue2,false,false,RunCtrlRunValue2)
		,RunCtrlRunValue2,RunCtrlNoPath2,RunCtrlRepeatRun2,RunCtrlAdminRun2,RunCtrlRunWay2,RunCtrlLastRunTime2)
	LV_Modify(RunRowNumber2,Set_Icon(LVImageListID,RunCtrlNoPath1 ? Get_Obj_Path(RunCtrlRunValue1) : RunCtrlRunValue1,false,false,RunCtrlRunValue1)
		,RunCtrlRunValue1,RunCtrlNoPath1,RunCtrlRepeatRun1,RunCtrlAdminRun1,RunCtrlRunWay1,RunCtrlLastRunTime1)
	;顺序改变后写入配置文件
	runContent=
	Gui, ListView, RunCtrlLV
	Loop % LV_GetCount()
	{
		LV_GetText(RunCtrlRunValue, A_Index, 1)
		LV_GetText(RunCtrlNoPath, A_Index, 2)
		LV_GetText(RunCtrlRepeatRun, A_Index, 3)
		LV_GetText(RunCtrlAdminRun, A_Index, 4)
		LV_GetText(RunCtrlRunWay, A_Index, 5)
		runContent.=RunCtrlRunIniKeyJoin(RunCtrlNoPath="菜单项", RunCtrlRepeatRun="重复", RunCtrlAdminRun="管理员"
			, GetKeyByVal(RunCtrlRunWayList, RunCtrlRunWay "启动")) "=" RunCtrlRunValue "`n"
	}
	runContent:=SubStr(runContent, 1, -StrLen("`n"))
	IniWrite, %runContent%, %RunAnyConfig%, %RunCtrlListBox%_Run
	LV_Modify(0, "-Select")
	LV_Modify(RunRowNumber2, "Select Focus")
return
RunCtrlLVSelect:
	Gui,RunCtrlManage:Default
	LV_Modify(0, "Select Focus")   ; 选择所有.
return
RunCtrlLVRun:
	Gui,RunCtrlManage:Default
	Gui,RunCtrlManage:Submit, NoHide
	GuiControlGet, focusGuiName, Focus
	if(focusGuiName="ListBox1"){
		effectResult:=RunCtrl_RunRules(RunCtrlList[RunCtrlListBox],true)
	}else if(focusGuiName="SysListView321"){
		Gosub,LVCtrlRunRun
	}
return
RunCtrlLVAdd:
	RuleGroupName:=RuleGroupLogic2:=RuleMostRun:=RuleIntervalTime:=RuleGroupKey:=RunCtrlListBox:=""
	RuleEnable:=RuleGroupLogic1:=true
	RuleGroupWinKey:=false
	menuItem:="新建"
	Gosub,RunCtrlConfig
return
RunCtrlLVEdit:
	RuleGroupName:=RunCtrlListBox
	menuItem:="编辑"
	Gui,RunCtrlManage:Default
	GuiControlGet, focusGuiName, Focus
	if(focusGuiName="ListBox1"){
		RuleEnable:=RunCtrlList[RunCtrlListBox].enable
		RuleEnableText:=RuleEnable ? "Green" : ""
		RuleGroupLogic1:=RunCtrlList[RunCtrlListBox].ruleLogic
		RuleGroupLogic2:=RuleGroupLogic1 ? 0 : 1
		RuleMostRun:=RunCtrlList[RunCtrlListBox].ruleMostRun
		RuleMostRun:=RuleMostRun=0 ? "" : RuleMostRun
		RuleIntervalTime:=RunCtrlList[RunCtrlListBox].ruleIntervalTime
		RuleIntervalTime:=RuleIntervalTime=0 ? "" : RuleIntervalTime
		RuleGroupKey:=RunCtrlList[RunCtrlListBox].key
		RuleGroupWinKey:=0
		if(InStr(RuleGroupKey,"#")){
			RuleGroupWinKey:=1
			RuleGroupKey:=StrReplace(RuleGroupKey, "#")
		}
		Gosub,RunCtrlConfig
	}else if(focusGuiName="SysListView321"){
		Gosub,LVCtrlRunEdit
	}
return
;~;【启动控制-规则组配置Gui】
RunCtrlConfig:
	Gui,RunCtrlConfig:Destroy
	Gui,RunCtrlConfig:Default
	Gui,RunCtrlConfig:+Resize
	Gui,RunCtrlConfig:+OwnerRunCtrlManage
	Gui,RunCtrlConfig:Font,,Microsoft YaHei
	Gui,RunCtrlConfig:Margin,20,20
	Gui,RunCtrlConfig:Add, CheckBox, xm+5 y+15 Checked%RuleEnable% vvRuleEnable c%RuleEnableText%, 启用规则组
	Gui,RunCtrlConfig:Add, Text, x+30 yp w60, 全局热键：
	Gui,RunCtrlConfig:Add, Hotkey,x+5 yp-2 w130 h22 vvRuleGroupKey,%RuleGroupKey%
	Gui,RunCtrlConfig:Add, Checkbox, x+10 yp+3 w55 Checked%RuleGroupWinKey% vvRuleGroupWinKey,Win
	Gui,RunCtrlConfig:Add, Text, xm+5 yp+30 w60, 规则组名：
	Gui,RunCtrlConfig:Add, Edit, x+5 yp-3 w300 vvRuleGroupName, %RuleGroupName%
	Gui,RunCtrlConfig:Add, GroupBox,xm y+10 w500 h385 vFuncGroup,规则组设置
	Gui,RunCtrlConfig:Add, Radio, xm+10 yp+25 Checked%RuleGroupLogic1% vvRuleGroupLogic1, 与（全部规则都验证成立）(&A)
	Gui,RunCtrlConfig:Add, Radio, x+10 yp Checked%RuleGroupLogic2% vvRuleGroupLogic2, 或（一个规则即验证成立）(&O)
	Gui,RunCtrlConfig:Add, Text, xm+10 y+15 w100, 规则循环最大次数:
	Gui,RunCtrlConfig:Add, Edit, x+2 yp-3 Number w70 h20 vvRuleMostRun, %RuleMostRun%
	Gui,RunCtrlConfig:Add, Text, x+20 yp+3 w110, 循环间隔时间(秒):
	Gui,RunCtrlConfig:Add, Edit, x+2 yp-3 w100 h20 vvRuleIntervalTime, %RuleIntervalTime%
	Gui,RunCtrlConfig:Add, Button, xm+10 y+15 w85 GLVFuncAdd, + 增加规则(&A)
	Gui,RunCtrlConfig:Add, Button, x+10 yp w85 GLVFuncEdit, · 修改规则(&E)
	Gui,RunCtrlConfig:Add, Button, x+10 yp w85 GLVFuncRemove, - 减少规则(&D)
	Gui,RunCtrlConfig:Font, s10, Microsoft YaHei
	Gui,RunCtrlConfig:Add, Listview, xm+10 y+10 w480 r10 grid AltSubmit C808000 vFuncLV glistfunc, 规则名|中断|条件|条件值
	;[读取启动项设置的规则内容写入列表]
	GuiControl, RunCtrlConfig:-Redraw, FuncLV
	For k, v in RunCtrlList[RunCtrlListBox].ruleList
	{
		funcBoolean:=v.logic="1" ? "相等" : v.logic="0" ? "不相等" : RunCtrlLogicEnum[v.logic]
		if(!rulestatusList[v.name]){
			funcBoolean:="规则函数未找到"
		}else if(!ruletypelist[v.name] && v.file!="RunAny" && !rule_check_is_run(PluginsPathList[v.file ".ahk"])){
			funcBoolean:="规则插件未启动"
		}
		LV_Add("", v.name, v.ruleBreak, funcBoolean, v.value)
	}
	LV_ModifyCol(1)
	LV_ModifyCol(2)
	LV_ModifyCol(3)
	GuiControl, RunCtrlConfig:+Redraw, FuncLV
	Gui,RunCtrlConfig:Add,Button,Default xm+150 y+15 w75 vvFuncSave GRunCtrlLVSave,保存(&Y)
	Gui,RunCtrlConfig:Add,Button,x+20 w75 vvFuncCancel GSetCancel,取消(&C)
	Gui,RunCtrlConfig:Show, , RunCtrl 规则组 - %menuItem% %RunAny_update_version% %RunAny_update_time%%AdminMode%
return

RunCtrlLVSave:
	Gui,RunCtrlConfig:Submit, NoHide
	fnx:=250
	fny:=100
	if(!vRuleGroupName){
		ToolTip, 请填入规则组名,%fnx%,%fny%
		SetTimer,RemoveToolTip,3000
		return
	}
	if(RuleGroupName!=vRuleGroupName && RunCtrlList[vRuleGroupName]){
		ToolTip, 已存在相同的规则组名，请修改,%fnx%,%fny%
		SetTimer,RemoveToolTip,3000
		return
	}
	if(Instr(vRuleGroupName, A_SPACE)){
		StringReplace, vRuleGroupName, vRuleGroupName, %A_SPACE%, _, All
		GuiControl, RunCtrlConfig:, vRuleGroupName, %vRuleGroupName%
		ToolTip, 规则组名不能带有空格，请用_代替,%fnx%,%fny%
		SetTimer,RemoveToolTip,3000
		return
	}
	if(Instr(vRuleGroupName, A_Tab)){
		StringReplace, vRuleGroupName, vRuleGroupName, %A_Tab%, _, All
		GuiControl, RunCtrlConfig:, vRuleGroupName, %vRuleGroupName%
		ToolTip, 规则组名不能带有制表符，请用_代替,%fnx%,%fny%
		SetTimer,RemoveToolTip,3000
		return
	}
	;中文、数字、字母、下划线正则校验，根据Unicode字符属性Han来判断中文，RunAnyCtrl.ahk编码不能为ANSI
	if(!RegExMatch(vRuleGroupName,"^[\p{Han}A-Za-z0-9_]+$")){
		ToolTip, 规则组名只能为中文、数字、字母、下划线,%fnx%,%fny%
		SetTimer,RemoveToolTip,3500
		return
	}
	runContent:=ruleContent:=""
	Loop % LV_GetCount()
	{
		LV_GetText(RuleName, A_Index, 1)
		LV_GetText(FuncBreak, A_Index, 2)
		LV_GetText(FuncBoolean, A_Index, 3)
		LV_GetText(FuncValue, A_Index, 4)
		FuncBoolean:=GetKeyByVal(RunCtrlLogicEnum, FuncBoolean)
		FuncBoolean:=FuncBoolean="eq" ? 1 : FuncBoolean="ne" ? 0 : FuncBoolean
		FuncBreak:=FuncBreak ? "|" FuncBreak : ""
		ruleContent.=RuleName . "|" . FuncBoolean . FuncBreak . "=" . FuncValue . "`n"
	}
	;[写入配置文件]
	Gui,RunCtrlManage:Default
	ruleLogicVal:=vRuleGroupLogic1=1 ? 1 : 0
	ruleRunListVal=%vRuleEnable%|%ruleLogicVal%
	if(vRuleMostRun!=""){
		ruleRunListVal.="|" vRuleMostRun "|" vRuleIntervalTime
	}
	if(vRuleGroupKey!=""){
		if(vRuleMostRun=""){
			ruleRunListVal.="||"
		}
		vRuleGroupKey:=vRuleGroupWinKey ? "#" . vRuleGroupKey : vRuleGroupKey
		ruleRunListVal.="|" vRuleGroupKey
	}

	if(menuItem="编辑"){
		runCtrlListNo:=GetKeyByVal(RunCtrlListBoxList, RuleGroupName)
		;如果是修改规则组，先删除老规则组
		if(!(RuleGroupName==vRuleGroupName)){
			IniDelete, %RunAnyConfig%, RunCtrlList, %RuleGroupName%
			IniDelete, %RunAnyConfig%, %RuleGroupName%_Rule
			IniDelete, %RunAnyConfig%, %RuleGroupName%_Run
		}
		RunCtrlListContent:=""
		for i,v in RunCtrlListBoxList
		{
			if(i=runCtrlListNo){
				RunCtrlListContent.=vRuleGroupName "=" ruleRunListVal "`n"
			}else{
				RunCtrlListContent.=v "=" RunCtrlListContentList[v] "`n"
			}
		}
		RunCtrlListContent:=SubStr(RunCtrlListContent, 1, -StrLen("`n"))
		IniWrite, %RunCtrlListContent%, %RunAnyConfig%, RunCtrlList
	}else{
		IniWrite, %ruleRunListVal%, %RunAnyConfig%, RunCtrlList, %vRuleGroupName%
	}

	if(RunCtrlList[RuleGroupName]){
		For runn, runv in RunCtrlList[RuleGroupName].runList
		{
			runContent.=RunCtrlRunIniKeyJoin(runv.noPath,runv.repeatRun,runv.adminRun,runv.runWay) "=" runv.path "`n"
		}
		runContent:=SubStr(runContent, 1, -StrLen("`n"))
	}
	IniWrite, %runContent%, %RunAnyConfig%, %vRuleGroupName%_Run
	ruleContent:=SubStr(ruleContent, 1, -StrLen("`n"))
	IniWrite, %ruleContent%, %RunAnyConfig%, %vRuleGroupName%_Rule
	Gui,RunCtrlConfig:Destroy
	Gosub,RunCtrl_Manage_Gui
return
RunCtrlLVImport:
	Gui,RunCtrlConfig:Submit, NoHide
	runContent:=""
	IniRead,ctrlAppsVar,%RunAnyConfig%,%RunCtrlListBox%_Run
	FileSelectFile, selectName, M35, , 选择多个你要导入的启动项, (*.*)
	Loop,parse,selectName,`n
	{
		if(A_Index=1){
			dir:=A_LoopField
		}else{
			fullPath:=dir "\" A_LoopField
			SplitPath, fullPath, , , ext, name_no_ext
			runContent.="path=" fullPath "`n"
		}
	}
	runContent:=SubStr(runContent, 1, -StrLen("`n"))
	runContent:=ctrlAppsVar!="" ? ctrlAppsVar "`n" runContent : runContent
	IniWrite,%runContent%,%RunAnyConfig%,%RunCtrlListBox%_Run
	Gosub,RunCtrl_Manage_Gui
return
;══════════════════════════════════════════════════════════════════════════════════════════════════════
;[规则函数配置]
LVFuncAdd:
	menuFuncItem:="新建规则函数"
	RuleName:=FuncBoolean:=FuncValue:=""
	FuncBooleanNE:=FuncBooleanGE:=FuncBooleanLE:=FuncBooleanGT:=FuncBooleanLT:=FuncBooleanRegEx:=FuncBreak:=false
	FuncBooleanEQ:=true
	RuleNameChoose:=1
	Gosub,LVFuncConfig
return
LVFuncEdit:
	menuFuncItem:="修改规则函数"
	RowNumber:=LV_GetNext(0, "F")
	if not RowNumber
		return
	LV_GetText(RuleName, RowNumber, 1)
	LV_GetText(FuncBreak, RowNumber, 2)
	LV_GetText(FuncBoolean, RowNumber, 3)
	LV_GetText(FuncValue, RowNumber, 4)
	FuncBreak:=FuncBreak ? 1 : 0
	for k,v in RunCtrlLogicEnum
	{
		FuncBoolean%k%:=false
		if(v=FuncBoolean){
			FuncBoolean%k%:=true
		}
	}
	RuleNameChoose:=1
	loop, parse, rulenameStr, |
	{
		if(RuleName=A_LoopField){
			RuleNameChoose:=A_Index
			break
		}
	}
	FuncValue:=StrReplace(FuncValue,"``t","`t")
	FuncValue:=StrReplace(FuncValue,"``n","`n")
	Gosub,LVFuncConfig
return
;~;【启动控制-运行规则Gui】
LVFuncConfig:
	Gui,RunCtrlFunc:Destroy
	Gui,RunCtrlFunc:+Resize
	Gui,RunCtrlFunc:+OwnerRunCtrlConfig
	Gui,RunCtrlFunc:Font,,Microsoft YaHei
	Gui,RunCtrlFunc:Margin,20,10
	Gui,RunCtrlFunc:Add, Text, xm y+10 w60, 规则名：
	Gui,RunCtrlFunc:Add, DropDownList, xm+60 yp-3 Choose%RuleNameChoose% GDropDownRuleChoose vvRuleName, %RuleNameStr%
	Gui,RunCtrlFunc:Add, Text, x+10 yp+3 cblue w150 GClipboardRuleResultText vvRuleResultText, 
	Gui,RunCtrlFunc:Add, Radio, xm y+10 Checked%FuncBooleanEQ% vvFuncBooleanEQ, 相等 ( 真 &True 1 )
	Gui,RunCtrlFunc:Add, Radio, x+4 yp Checked%FuncBooleanNE% vvFuncBooleanNE, 不相等 ( 假 &False 0 )
	Gui,RunCtrlFunc:Add, Radio, xm y+10 Checked%FuncBooleanGE% vvFuncBooleanGE, 大于等于　　　　
	Gui,RunCtrlFunc:Add, Radio, x+6 yp Checked%FuncBooleanLE% vvFuncBooleanLE, 小于等于　　　　
	Gui,RunCtrlFunc:Add, Radio, xm y+10 Checked%FuncBooleanGT% vvFuncBooleanGT, 大于　　　　　　
	Gui,RunCtrlFunc:Add, Radio, x+6 yp Checked%FuncBooleanLT% vvFuncBooleanLT, 小于　　　　　　
	Gui,RunCtrlFunc:Add, Radio, x+6 yp Checked%FuncBooleanRegEx% vvFuncBooleanRegEx, 正则表达式
	Gui,RunCtrlFunc:Add, CheckBox, xm y+10 Checked%FuncBreak% vvFuncBreak, 不满足此条件就中断整个规则循环（建议排在其他规则前面）
	Gui,RunCtrlFunc:Add, Text, xm y+10 w350 vvRuleText, 条件值：（只判断规则真假，可不填写）
	Gui,RunCtrlFunc:Add, Text, xm yp w350 cblue vvRuleParamText, 条件值：（条件值变为参数传递到规则函数，只判断结果真假）
	; `n多个参数每行为一个参数，最多支持10个，保存会用|分隔
	Gui,RunCtrlFunc:Add, Edit, xm y+10 w350 r6 vvFuncValue GFuncValueChange, %FuncValue%
	Gui,RunCtrlFunc:Add, Button,Default xm+80 y+15 w75 vvFuncSave GLVFuncSave,保存(&Y)
	Gui,RunCtrlFunc:Add, Button,x+10 w75 vvFuncCancel GSetCancel,取消(&C)
	Gui,RunCtrlFunc:Show, , RunCtrl 修改规则函数 %RunAny_update_version% %RunAny_update_time%%AdminMode%
	Gosub,DropDownRuleChoose
return
LVFuncRemove:
	DelRowList:=""
	RowNumber:=0
	Loop
	{
		RowNumber := LV_GetNext(RowNumber)  ; 在前一次找到的位置后继续搜索.
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		DelRowList:=RowNumber . ":" . DelRowList
	}
	stringtrimright, DelRowList, DelRowList, 1
	loop, parse, DelRowList, :
		LV_Delete(A_loopfield)
return
LVFuncSave:
	Gui,RunCtrlFunc:Submit, NoHide
	fnx:=40
	fny:=230
	if(!vRuleName){
		ToolTip, 请选择使用的规则,%fnx%,%fny%
		SetTimer,RemoveToolTip,3000
		return
	}
	if(vFuncValue="" && !(vFuncBooleanEQ || vFuncBooleanNE)){
		ToolTip, 如果是大于或小于请填写条件值,%fnx%,%fny%
		SetTimer,RemoveToolTip,3000
		return
	}
	vFuncValue:=RTrim(vFuncValue,"`n")
	vFuncValue:=StrReplace(vFuncValue,"`t","``t")
	vFuncValue:=StrReplace(vFuncValue,"`n","``n")
	;[写入配置文件]
	Gui,RunCtrlFunc:Destroy
	Gui,RunCtrlConfig:Default
	for k,v in RunCtrlLogicEnum
	{
		if(vFuncBoolean%k%){
			funcBoolean:=k
		}
	}
	ruleLogic:=RunCtrlLogicEnum[funcBoolean]
	if(menuFuncItem="修改规则函数"){
		LV_Modify(RowNumber,"",vRuleName,vFuncBreak ? "*" : "",ruleLogic,vFuncValue)
	}else{
		LV_Add("",vRuleName,vFuncBreak ? "*" : "",ruleLogic,vFuncValue)
	}
	LV_ModifyCol(1)
	LV_ModifyCol(2)
	LV_ModifyCol(3)
	GuiControl, RunCtrlConfig:+Redraw, FuncLV
return
listfunc:
    if A_GuiEvent = DoubleClick
    {
		Gosub,LVFuncEdit
    }
return
DropDownRuleChoose:
	Gui,RunCtrlFunc:Submit, NoHide
	if(ruleparamList[vRuleName]){
		GuiControl, RunCtrlFunc:show, vRuleParamText
		GuiControl, RunCtrlFunc:hide, vRuleText
		if(FuncBooleanEQ){
			GuiControl, RunCtrlFunc:,vFuncBooleanEQ,1
		}else{
			GuiControl, RunCtrlFunc:,vFuncBooleanNE,1
		}
		GuiControl, RunCtrlFunc:Disable, vFuncBooleanGE
		GuiControl, RunCtrlFunc:Disable, vFuncBooleanLE
		GuiControl, RunCtrlFunc:Disable, vFuncBooleanGT
		GuiControl, RunCtrlFunc:Disable, vFuncBooleanLT
		GuiControl, RunCtrlFunc:Disable, vFuncBooleanRegEx
	}else{
		GuiControl, RunCtrlFunc:show, vRuleText
		GuiControl, RunCtrlFunc:hide, vRuleParamText
		GuiControl, RunCtrlFunc:enable, vFuncBooleanGE
		GuiControl, RunCtrlFunc:enable, vFuncBooleanLE
		GuiControl, RunCtrlFunc:enable, vFuncBooleanGT
		GuiControl, RunCtrlFunc:enable, vFuncBooleanLT
		GuiControl, RunCtrlFunc:enable, vFuncBooleanRegEx
	}
	GuiControl, RunCtrlFunc:,vRuleResultText,% RunCtrl_RuleResult(vRuleName, ruleitemList[vRuleName], vFuncValue)
return
ClipboardRuleResultText:
	Gui,RunCtrlFunc:Submit, NoHide
	GuiControlGet, OutputVar, ,vRuleResultText
	Clipboard:=OutputVar
	ToolTip, 已复制到剪贴板
	SetTimer,RemoveToolTip,2000
return
FuncValueChange:
	Gui,RunCtrlFunc:Submit, NoHide
	if(!InStr(rulefileList[vRuleName],"RunCtrl_Network.ahk")){
		Gosub,DropDownRuleChoose
	}
return
SetFilePath:
	FileSelectFile, filePath, 3, , 请选择导入的启动项, (*.ahk;*.exe)
	GuiControl, RunCtrlConfig:, vFilePath, %filePath%
return
;~;【启动控制-启动项Gui】
LVCtrlRunAdd:
	menuItem:="新建"
	RunCtrlRepeatRun:=RunCtrlAdminRun:=RunCtrlRunWay:=RunCtrlRunValue:=""
	RunCtrlNoPath:="菜单项"
	Gosub,LVCtrlRunConfig
return
LVCtrlRunEdit:
	menuItem:="编辑"
	Gosub,LVCtrlRunConfig
return
LVCtrlRunRun:
	Loop
	{
		RowNumber := LV_GetNext(RowNumber)  ; 在前一次找到的位置后继续搜索.
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		LV_GetText(RunCtrlRunValue, RowNumber, 1)
		LV_GetText(RunCtrlNoPath, RowNumber, 2)
		LV_GetText(RunCtrlRepeatRun, RowNumber, 3)
		LV_GetText(RunCtrlAdminRun, RowNumber, 4)
		LV_GetText(RunCtrlRunWay, RowNumber, 5)
		RunCtrl_RunApps(RunCtrlRunValue, RunCtrlNoPath="菜单项" ? 1 : 0, 1
			, RunCtrlAdminRun="管理员" ? 1 : 0, GetKeyByVal(RunCtrlRunWayList, RunCtrlRunWay "启动"))
	}
return
LVCtrlRunConfig:
	Gui, ListView, RunCtrlLV
	if(menuItem="编辑"){
		RunRowNumber := LV_GetNext(0, "F")
		if not RunRowNumber
			return
		LV_GetText(RunCtrlRunValue, RunRowNumber, 1)
		LV_GetText(RunCtrlNoPath, RunRowNumber, 2)
		LV_GetText(RunCtrlRepeatRun, RunRowNumber, 3)
		LV_GetText(RunCtrlAdminRun, RunRowNumber, 4)
		LV_GetText(RunCtrlRunWay, RunRowNumber, 5)
	}
	RunCtrlNoPath1:=RunCtrlNoPath="菜单项" ? 1 : 0
	RunCtrlNoPath2:=RunCtrlNoPath1 ? 0 : 1
	RunCtrlRepeatRun:=RunCtrlRepeatRun="重复" ? 1 : 0
	RunCtrlAdminRun:=RunCtrlAdminRun="管理员" ? 1 : 0
	RunCtrlRunWay:=GetKeyByVal(RunCtrlRunWayList, RunCtrlRunWay "启动")
	Gui,CtrlRun:Destroy
	Gui,CtrlRun:Default
	Gui,CtrlRun:+OwnerRunCtrlManage
	Gui,CtrlRun:Margin,20,20
	Gui,CtrlRun:Font,,Microsoft YaHei
	Gui,CtrlRun:Add, Radio, xm+10 yp+20 Checked%RunCtrlNoPath1% vvRunCtrlNoPath1, 菜单项(&Z)
	Gui,CtrlRun:Add, Radio, x+42 yp Checked%RunCtrlNoPath2% vvRunCtrlNoPath2, 全路径(&A)
	Gui,CtrlRun:Add, GroupBox, xm y+5 w410 h50
	Gui,CtrlRun:Add, CheckBox, xm+10 yp+20 Checked%RunCtrlRepeatRun% vvRunCtrlRepeatRun, 重复启动(&R)
	Gui,CtrlRun:Add, CheckBox, x+30 yp Checked%RunCtrlAdminRun% vvRunCtrlAdminRun, 管理员启动(&G)
	Gui,CtrlRun:Add, DropDownList, x+30 yp-3 Choose%RunCtrlRunWay% AltSubmit GDropDownRunWayChoose vvRunCtrlRunWay, % StrListJoin("|",RunCtrlRunWayList)
	Gui,CtrlRun:Add, Button, xm y+20 w100 h60 GSetRunCtrlRunValue,运行软件路径`n或%RunAnyZz%菜单项
	Gui,CtrlRun:Add, Edit, x+12 yp+1 w300 r3 -WantReturn vvRunCtrlRunValue, %RunCtrlRunValue%
	Gui,CtrlRun:Font
	Gui,CtrlRun:Add,Button,Default xm+100 y+25 w75 GSaveRunCtrlRunValue,保存(&Y)
	Gui,CtrlRun:Add,Button,x+20 w75 GSetCancel,取消(&C)
	Gui,CtrlRun:Show,,RunCtrl - %openExtItem%启动项 %RunAny_update_version% %RunAny_update_time%
return
SetRunCtrlRunValue:
	Gui,CtrlRun:Submit, NoHide
	if(vRunCtrlNoPath1){
		global RunCtrlMenuItemFlag:=true
		Gosub,Menu_Edit1
	}else if(vRunCtrlNoPath2){
		FileSelectFile, runPath, , , 启动程序路径
		if(runPath){
			GuiControlSet("CtrlRun","vRunCtrlRunValue",runPath)
		}
	}
return
DropDownRunWayChoose:
	Gui,CtrlRun:Submit, NoHide
	if(!A_IsAdmin && vRunCtrlRunWay=2 && vRunCtrlAdminRun)
		MsgBox,48,权限不允许！, %RunAnyZz% 没有管理员权限！无法置顶操作 勾选了“管理员启动”的软件`n%vRunCtrlRunValue%
return
SaveRunCtrlRunValue:
	Gui,CtrlRun:Submit, NoHide
	if(RunCtrlListBox=""){
		Gui,CtrlRun:Destroy
		return
	}
	oldStr:=RunCtrlRunIniKeyJoin(RunCtrlNoPath1,RunCtrlRepeatRun,RunCtrlAdminRun,RunCtrlRunWay) "=" RunCtrlRunValue
	newStr:=RunCtrlRunIniKeyJoin(vRunCtrlNoPath1,vRunCtrlRepeatRun,vRunCtrlAdminRun,vRunCtrlRunWay) "=" vRunCtrlRunValue
	if(oldStr=newStr){
		Gui,CtrlRun:Destroy
		return
	}
	if(vRunCtrlNoPath2 && !InStr(vRunCtrlRunValue,".")){
		ToolTip, 全路径是直接运行，不是运行RunAny菜单项，请填写正确的启动项,30,25
		SetTimer,RemoveToolTip,5000
		return
	}
	IniRead,ctrlAppsVar,%RunAnyConfig%,%RunCtrlListBox%_Run
	runContent:=""
	if(menuItem="编辑"){
		Loop, parse, ctrlAppsVar, `n, `r
		{
			runContent.=A_LoopField=oldStr ? newStr "`n" : A_LoopField "`n"
		}
		runContent:=SubStr(runContent, 1, -StrLen("`n"))
		if(RunCtrlRunValue!=vRunCtrlRunValue){
			IniDelete, %RunCtrlLastTimeIni%, last_run_time, %RunCtrlRunValue%
		}
	}else if(menuItem="新建"){
		runContent:=ctrlAppsVar!="" ? ctrlAppsVar "`n" newStr : newStr
	}
	IniWrite,%runContent%,%RunAnyConfig%,%RunCtrlListBox%_Run
	Gosub,RunCtrl_Manage_Gui
return
RunCtrlRunIniKeyJoin(runNoPath,runRepeat,runAdminRun,runRunWay){
	newNoPath:=runNoPath ? "menu" : "path"
	newRunRepeat:=runRepeat ? "|1" : "|"
	newAdminRun:=runAdminRun ? "|1" : "|"
	newRunWay:=(runRunWay!="" && runRunWay!="1") ? "|" runRunWay : ""
	newRunStr:=(newRunRepeat="|" && newAdminRun="|" && newRunWay="") ? "" : newRunRepeat newAdminRun newRunWay
	return newNoPath newRunStr
}
;══════════════════════════════════════════════════════════════════════════════════════════════════════
;~;【——🧬规则Gui——】
;══════════════════════════════════════════════════════════════════════════════════════════════════════
Rule_Manage_Gui:
	Gosub,RunCtrl_Read
	Gui,RuleManage:Destroy
	Gui,RuleManage:Default
	Gui,RuleManage:+Resize
	Gui,RuleManage:Font, s10, Microsoft YaHei
	Gui,RuleManage:Add, Listview, xm w685 r18 grid AltSubmit BackgroundF6F6E8 vRuleLV hwndRLV glistrule, 规则名|规则函数|状态|类型|参数|示例|规则插件名
	;[读取规则内容写入列表]
	GuiControl, -Redraw, RuleLV
	NRLV := New ListView(RLV)
	For kName, kVal in rulefileList
	{
		ruleStatus:=rulestatusList[kName] ? "正常" : "未找到"
		if(!ruletypelist[kName] && kVal!="RunAny.ahk" && !rule_check_is_run(PluginsPathList[kVal])){
			ruleStatus:="未启动"
		}
		ruleResult:=""
		if(ruleStatus="正常"){
			ruleResult:=InStr(kVal,"RunCtrl_Network.ahk") ? "http://ip-api.com/json" : RunCtrl_RuleResult(kName, ruleitemList[kName], "")
		}
		LV_Add("", kName, rulefuncList[kName], ruleStatus ,ruletypelist[kName] ? "变量" : "插件",ruleparamList[kName] ? "传参" : ""	,ruleResult , kVal)
		if(ruleStatus!="正常")
			NRLV.Color(A_Index,0x999999)
	}
	GuiControl, +Redraw, RuleLV
	Menu, ruleGuiMenu, Add, 新增, LVRulePlus
	Menu, ruleGuiMenu, Icon, 新增, SHELL32.dll,1
	Menu, ruleGuiMenu, Add, 修改, LVRuleEdit
	Menu, ruleGuiMenu, Icon, 修改, SHELL32.dll,134
	Menu, ruleGuiMenu, Add, 减少, LVRuleMinus
	Menu, ruleGuiMenu, Icon, 减少, SHELL32.dll,132
	Menu, ruleGuiMenu, Add, 添加最新默认规则, LVRuleDefault
	Menu, ruleGuiMenu, Icon, 添加最新默认规则, SHELL32.dll,194
	Menu, ruleGuiMenu, Add, 全选, LVRuleSelect
	Gui,RuleManage:Menu, ruleGuiMenu
	LV_ModifyCol()  ; 根据内容自动调整每列的大小.
	LV_ModifyCol(2,"Sort")
	Gui,RuleManage:Show, , RunCtrl 规则管理 %RunAny_update_version% %RunAny_update_time%%AdminMode%
return
LVRulePlus:
	menuRuleItem:="规则新建"
	RuleName:=RuleFunction:=RulePath:=""
	Gosub,RuleConfig_Gui
return
LVRuleEdit:
	RowNumber:=LV_GetNext(0, "F")
	if not RowNumber
		return
	LV_GetText(RuleName, RowNumber, 1)
	LV_GetText(RuleFunction, RowNumber, 2)
	LV_GetText(RuleType, RowNumber, 4)
	LV_GetText(RulePath, RowNumber, 7)
	menuRuleItem:="规则编辑"
	RuleTypeVar:=RuleType="变量" ? 1 : 0
	RuleTypeFunc:=RuleTypeVar=1 ? 0 : 1
	Gosub,RuleConfig_Gui
return
LVRuleSelect:
	LV_Modify(0, "Select Focus")   ; 选择所有.
return
LVRuleDefault:
	MsgBox,33,添加默认规则,需要添加最新版本的默认规则吗？`n（不影响原有规则，重复的规则不会添加）
	IfMsgBox Ok
	{
		ruleWriteStr:=ruleDefaultStr:=""
		RunCtrlRuleObj:={"电脑名":"A_ComputerName","用户名":"A_UserName","系统版本":"A_OSVersion","系统64位":"A_Is64bitOS"
			,"主屏幕宽度":"A_ScreenWidth","主屏幕高度":"A_ScreenHeight"
			,"本地时间":"A_Now","年":"A_YYYY","月":"A_MM","星期":"A_WDay","日":"A_DD","时":"A_Hour","分":"A_Min","秒":"A_Sec","剪贴板文字":"Clipboard"}
		For rName, rFunc in RunCtrlRuleObj
		{
			if(rulefileList[rName]!="0"){
				ruleWriteStr.=rName "|" rFunc "`n"
			}
		}
		ruleWriteStr:=SubStr(ruleWriteStr, 1, -StrLen("`n"))
		Sort, ruleWriteStr, CL
		Loop, Parse, ruleWriteStr, `n
		{
			IniWrite, 0, %RunAnyConfig%, RunCtrlRule, %A_LoopField%
		}
		RunCtrlRuleObj:={"开机时长(秒)":"rule_boot_time","电脑机型":"rule_chassis_types","运行状态":"rule_check_is_run","联网状态":"rule_check_network"}
		For rName, rFunc in RunCtrlRuleObj
		{
			if(!rulefileList[rName]){
				IniWrite, RunAny.ahk, %RunAnyConfig%, RunCtrlRule, %rName%|%rFunc%
			}
		}
		if(PluginsPathList["RunCtrl_Common.ahk"]){
			RunCtrlCommonRuleObj:={"内网IP":"rule_ip_internal","WiFi名":"rule_wifi_silence","验证注册表的值":"rule_check_regedit","验证ini配置的值":"rule_check_ini" 
				,"运行过(今天)":"rule_run_today","最近打开文件(今天)":"rule_run_today_file"}
			For rName, rFunc in RunCtrlCommonRuleObj
			{
				if(!rulefileList[rName]){
					IniWrite, RunCtrl_Common.ahk, %RunAnyConfig%, RunCtrlRule, %rName%|%rFunc%
				}
			}
			ruleDefaultStr.="`nRunCtrl_Common.ahk"
		}
		if(PluginsPathList["RunCtrl_Network.ahk"]){
			RunCtrlNetworkRuleObj:={"城市":"rule_ip_city","国家":"rule_ip_country","国家代码":"rule_ip_countryCode","省":"rule_ip_region","省缩写":"rule_ip_regionName"
				,"纬度":"rule_ip_lat","经度":"rule_ip_lon","时区":"rule_ip_timezone","运营商":"rule_ip_isp","外网IP":"rule_ip_external"}

			For rName, rFunc in RunCtrlNetworkRuleObj
			{
				if(!rulefileList[rName]){
					IniWrite, RunCtrl_Network.ahk, %RunAnyConfig%, RunCtrlRule, %rName%|%rFunc%
				}
			}
			ruleDefaultStr.="`nRunCtrl_Network.ahk"
		}
		if(ruleDefaultStr!=""){
			Msgbox,64,,请在“插件管理”窗口里设置 %ruleDefaultStr% `n插件为自动启动，`n只有插件运行时规则才会生效`n
		}
		Gosub,Rule_Manage_Gui
	}
return
;~;【规则-编辑Gui】
RuleConfig_Gui:
	Gui,RuleConfig:Destroy
	Gui,RuleConfig:+OwnerRuleManage
	Gui,RuleConfig:Font,,Microsoft YaHei
	Gui,RuleConfig:Margin,20,10
	Gui,RuleConfig:Add, Text, xm y+10 w60, 规则名：
	Gui,RuleConfig:Add, Edit, xm+60 yp-3 w450 vvRuleName, %RuleName%
	Gui,RuleConfig:Add, Text, xm y+10 w60, 规则类型：
	Gui,RuleConfig:Add, Radio, x+4 yp Checked%RuleTypeVar% GRuleTypeChange vvRuleTypeVar, 菜单变量
	Gui,RuleConfig:Add, Radio, x+4 yp Checked%RuleTypeFunc% GRuleTypeChange vvRuleTypeFunc, 插件函数
	Gui,RuleConfig:Add, Link, x+15 yp vvVarDocs,<a href="https://hui-zz.gitee.io/runany/#/article/built-in-variables">变量参考</a>
	Gui,RuleConfig:Add, Text, xm y+10 w60, 规则函数：
	Gui,RuleConfig:Add, Edit, xm+60 yp-3 w225 vvRuleFunction, %RuleFunction%
	Gui,RuleConfig:Add, DropDownList, x+5 yp+2 w220 vvRuleDLL GDropDownRuleList
	Gui,RuleConfig:Add, Button, xm-5 yp+30 w60 h60 vvSetRulePath GSetRulePath,规则路径 可自动识别函数名
	Gui,RuleConfig:Add, Edit, xm+60 yp w450 r3 vvRulePath GRulePathChange, %RulePath%
	Gui,RuleConfig:Add, Button,Default xm+180 y+10 w75 GLVRuleSave,保存(&Y)
	Gui,RuleConfig:Add, Button,x+10 w75 GSetCancel,取消(&C)
	Gui,RuleConfig:Show, , RunCtrl 规则编辑 %RunAny_update_version% %RunAny_update_time%%AdminMode%
	funcnameStr:=KnowAhkFuncZz(RulePath)
	GuiControl, RuleConfig:, vRuleDLL, |
	GuiControl, RuleConfig:, vRuleDLL, %funcnameStr%
	funcNameChoose:=1
	loop, parse, funcnameStr, |
	{
		if(RuleFunction=A_LoopField){
			funcNameChoose:=A_Index
			break
		}
	}
	GuiControl, RuleConfig:Choose, vRuleDLL, %funcNameChoose%
	Gosub,RuleTypeChange
return
LVRuleMinus:
	DelRowList:=""
	Row:=LV_GetNext(0, "F")
	RowNumber:=0
	if(Row)
		MsgBox,51,确认删除？(Esc取消),确定删除选中的规则项？`n【注意！】此操作会连带删除所有规则组中用到的这个规则
	Loop
	{
		RowNumber := LV_GetNext(RowNumber)  ; 在前一次找到的位置后继续搜索.
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		IfMsgBox Yes
		{
			LV_GetText(RuleName, RowNumber, 1)
			LV_GetText(RuleFunction, RowNumber, 2)
			LV_GetText(RulePath, RowNumber, 7)
			DelRowList:=RowNumber . ":" . DelRowList
			IniDelete, %RunAnyConfig%, RunCtrlRule, %RuleName%|%RuleFunction%
			;删除所有正在使用此规则的关联配置
			Change_Rule_Name(RuleName,"")
			Gosub,RunCtrl_Read
		}
	}
	IfMsgBox Yes
	{
		stringtrimright, DelRowList, DelRowList, 1
		loop, parse, DelRowList, :
			LV_Delete(A_loopfield)
	}
return
LVRuleSave:
	Gui,RuleConfig:Submit, NoHide
	if(vRuleTypeVar){
		vRulePath:=0
	}
	if(!vRuleName || !vRuleFunction || vRulePath=""){
		MsgBox, 48, ,请填入规则名、规则函数和规则路径
		return
	}
	if(InStr(vRuleName,"|")){
		MsgBox, 48, ,规则名不能包含有“|”分割符
		return
	}
	if(RuleName!=vRuleName && rulefileList[vRuleName]){
		MsgBox, 48, ,已存在相同的规则名，请修改
		return
	}
	if(vRuleTypeFunc){
		checkRulePath:=Get_Transform_Val(vRulePath)
		if(!FileExist(checkRulePath) && !FileExist(PluginsPathList[checkRulePath])){
			MsgBox, 48, ,规则路径AHK脚本不存在，请重新添加
			return
		}
	}
	;[写入配置文件]
	Gui,RuleManage:Default
	ruleVar:=vRuleTypeVar ? Get_Transform_Val("%" vRuleFunction "%") : "重启生效"
	ruleStatus:=!vRuleTypeVar ? "重启生效" : ruleVar!="" ? "正常" : "错误变量"
	if(menuRuleItem="规则编辑"){
		if(RuleName!=vRuleName || RuleFunction!=vRuleFunction){
			IniDelete, %RunAnyConfig%, RunCtrlRule, %RuleName%|%RuleFunction%
			;~ 变更所有正在使用此规则的启动项中关联规则名称
			if(RuleName!=vRuleName)
				Change_Rule_Name(RuleName,vRuleName)
		}
		LV_Modify(RowNumber,"",vRuleName,vRuleFunction,ruleStatus,vRuleTypeVar ? "变量" : "插件",ruleparamList[vRuleName] ? "传参" : "",ruleVar,vRulePath)
	}else{
		LV_Add("",vRuleName,vRuleFunction,ruleStatus,vRuleTypeVar ? "变量" : "插件",ruleparamList[vRuleName] ? "传参" : "",ruleVar,vRulePath)
	}
	IniWrite, %vRulePath%, %RunAnyConfig%, RunCtrlRule, %vRuleName%|%vRuleFunction%
	LV_ModifyCol()  ; 根据内容自动调整每列的大小.
	GuiControl, RuleManage:+Redraw, RuleLV
	Gosub,RunCtrl_Read
	Gui,RuleConfig:Destroy
return
listrule:
    if A_GuiEvent = DoubleClick
    {
		Gosub,LVRuleEdit
    }
return
SetRulePath:
	FileSelectFile, rulePath, 3, , 请选择要使用的的AutoHotkey规则脚本, (*.ahk)
	if(rulePath){
		Gui,RuleConfig:Submit, NoHide
		Get_Rule_Func_Name(rulePath,vRuleFunction)
		rulePath:=StrReplace(rulePath,A_ScriptDir "\" PluginsDir "\")
		rulePath:=StrReplace(rulePath,A_ScriptDir "\")
		GuiControl, RuleConfig:, vRulePath, %rulePath%
	}
return
RuleTypeChange:
	Gui,RuleConfig:Submit, NoHide
	if(vRuleTypeVar){
		GuiControlShow("RuleConfig","vVarDocs")
		GuiControlHide("RuleConfig","vRuleDLL","vSetRulePath","vRulePath")
	}else{
		GuiControlShow("RuleConfig","vRuleDLL","vSetRulePath","vRulePath")
		GuiControlHide("RuleConfig","vVarDocs")
		if(vRulePath="0"){
			GuiControl, RuleConfig:, vRulePath, RunCtrl_Common.ahk
			Gosub,RulePathChange
		}
	}
return
RulePathChange:
	Gui,RuleConfig:Submit, NoHide
	Get_Rule_Func_Name(vRulePath,vRuleFunction)
return
DropDownRuleList:
	Gui,RuleConfig:Submit, NoHide
	GuiControl, RuleConfig:, vRuleFunction, %vRuleDLL%
return
;[自动根据规则脚本的路径来变更函数下拉选择框和空规则函数]
Get_Rule_Func_Name(rulePath,vRuleFunction){
	if(rulePath){
		funcnameStr:=KnowAhkFuncZz(rulePath)
		GuiControl, RuleConfig:, vRuleDLL, |
		GuiControl, RuleConfig:, vRuleDLL, %funcnameStr%
		GuiControl, RuleConfig:Choose, vRuleDLL, 1
		if(!vRuleFunction && funcnameStr){
			Gosub,DropDownRuleList
		}
	}
}
;[变更所有正在使用此规则的启动项中关联规则名称]
Change_Rule_Name(rname,rnew){
	if(rname=rnew)
		Return
	for n,obj in RunCtrlList
	{
		runCtrlName:=obj.name
		for i,r in obj.ruleList
		{
			if(r.name=rname && runCtrlName!=""){
				IniDelete,%RunAnyConfig%,%runCtrlName%_Rule,% r.name "|" r.logic
				IniWrite,% r.value, %RunAnyConfig%, %runCtrlName%_Rule,% rnew "|" r.logic
			}
		}
	}
}
/*
【自动识别AHK脚本中的函数 by hui-Zz】
ahkPath AHK脚本路径
return AHK脚本所有函数用|分隔的字符串,没有返回""
*/
KnowAhkFuncZz(ahkPath){
	ahkPath:=Get_Transform_Val(ahkPath)
	if(FileExist(PluginsPathList[ahkPath])){
		ahkPath:=PluginsPathList[ahkPath]
	}
	funcName:=funcnameStr:=""
	StringReplace, checkPath, ahkPath,`%A_ScriptDir`%, %A_ScriptDir%
	if(FileExist(checkPath)){
		funcIndex:=0
		getFuncNameReg:="iS)^\t*\s*(?!if)([^\s\.,:=\(]*)\(.*?\)\t*\s*"
		getFuncNameReg1:=getFuncNameReg . "\{"
		getFuncNameReg2:=getFuncNameReg . "$"
		Loop, read, %checkPath%
		{
			if(RegExMatch(A_LoopReadLine,getFuncNameReg1)){
				funcnameStr.=RegExReplace(A_LoopReadLine,getFuncNameReg1,"$1") . "|"
			}
			if(funcName && A_Index=funcIndex && RegExMatch(A_LoopReadLine,"^\t*\s*\{\t*\s*$")){
				funcnameStr.=funcName . "|"
			}
			if(RegExMatch(A_LoopReadLine,getFuncNameReg2)){
				funcName:=RegExReplace(A_LoopReadLine,getFuncNameReg2,"$1")
				funcIndex:=A_Index+1
			}
		}
		stringtrimright, funcnameStr, funcnameStr, 1
	}
	return funcnameStr
}
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
;~;【——🔧设置选项Gui——】
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
Settings_Gui:
	if(!MenuIconFlag){
		TrayTip,,RunAny正在初始化，请完成后再打开设置,5,1
		return
	}
	Critical  ;防止短时间内打开多次界面出现问题
	HotKeyFlag:=MenuVarFlag:=OpenExtFlag:=AdvancedConfigFlag:=false
	GUI_WIDTH_66=700
	TAB_WIDTH_66=680
	GROUP_WIDTH_66=660
	GROUP_LISTVIEW_WIDTH_66=650
	GROUP_CHOOSE_EDIT_WIDTH_66=580
	GROUP_ICON_EDIT_WIDTH_66=550
	MARGIN_TOP_66=15
	ev := new everything
	Gui,66:Destroy
	Gui,66:Default
	Gui,66:+Resize
	Gui,66:Margin,30,20
	Gui,66:Font,,Microsoft YaHei
	Gui,66:Add,Tab3,x10 y10 w%TAB_WIDTH_66% vConfigTab gConfigTabSelect +Theme -Background
		,RunAny设置|热键配置|菜单变量|无路径缓存|搜索Everything|一键直达|内部关联|热字符串|图标设置|高级配置
	Gui,66:Tab,RunAny设置,,Exact
	Gui,66:Add,Checkbox,Checked%AutoRun% xm y+%MARGIN_TOP_66% vvAutoRun,开机自动启动
	Gui,66:Add,Checkbox,Checked%AdminRun% x+25 vvAdminRun,管理员权限运行所有软件和插件
	Gui,66:Add,Button,x+20 w245 h20 gSetScheduledTasks,系统任务计划方式：开机管理员启动%RunAnyZz%
	Gui,66:Add,GroupBox,xm-10 y+15 w%GROUP_WIDTH_66% h105,RunAny应用菜单
	Gui,66:Add,Checkbox,Checked%HideFail% xm yp+20 vvHideFail,隐藏失效项
	Gui,66:Add,Checkbox,Checked%HideSend% x+180 vvHideSend,隐藏短语
	Gui,66:Add,Checkbox,Checked%HideWeb% xm yp+20 vvHideWeb,隐藏带`%s网址
	Gui,66:Add,Checkbox,Checked%HideGetZz% x+163 vvHideGetZz,隐藏带`%getZz`%插件脚本
	Gui,66:Add,Checkbox,Checked%HideSelectZz% xm yp+20 vvHideSelectZz gSetHideSelectZz,隐藏选中目标提示
	Gui,66:Add,Checkbox,Checked%HideAddItem% x+144 vvHideAddItem,隐藏【添加到此菜单】
	Gui,66:Add,Checkbox,Checked%HideMenuTray% xm yp+20 vvHideMenuTray,隐藏底部“RunAny设置”
	Gui,66:Add,Edit,x+101 w30 h20 vvRecentMax,%RecentMax%
	Gui,66:Add,Text,x+5 yp+2,最近运行项数量 (0为隐藏)
	Gui,66:Add,Button,x+5 w50 h20 gSetClearRecentMax,清理

	Gui,66:Add,GroupBox,xm-10 y+15 w225 h55,RunAny菜单热键 %MenuHotKey%
	Gui,66:Add,Hotkey,xm yp+20 w150 vvMenuKey,%MenuKey%
	Gui,66:Add,Checkbox,Checked%MenuWinKey% xm+155 yp+3 w55 vvMenuWinKey gSetMenuWinKey,Win
	If(MENU2FLAG){
		Gui,66:Add,GroupBox,x+60 yp-23 w225 h55,菜单2热键 %MenuHotKey2%
		Gui,66:Add,Hotkey,xp+10 yp+20 w150 vvMenuKey2,%MenuKey2%
		Gui,66:Add,Checkbox,Checked%MenuWinKey2% xp+155 yp+3 w55 vvMenuWinKey2 gSetMenuWinKey2,Win
	}else{
		Gui,66:Add,Button,x+60 yp-5 w150 GSetMenu2,开启第2个菜单
	}

	Gui,66:Add,GroupBox,xm-10 y+25 w%GROUP_WIDTH_66% h110,RunAny.ini文件设置
	Gui,66:Add,Edit,xm yp+20 w50 h20 vvAutoReloadMTime,%AutoReloadMTime%
	Gui,66:Add,Text,x+5 yp+2,(毫秒)  RunAny.ini修改后自动重启，0为不自动重启
	Gui,66:Add,Checkbox,xm yp+25 Checked%RunABackupRule% vvRunABackupRule,自动备份
	Gui,66:Add,Text,x+5 yp,最多备份数量
	Gui,66:Add,Edit,x+5 yp-2 w70 h20 vvRunABackupMax,%RunABackupMax%
	Gui,66:Add,Text,x+5 yp+2,备份文件名格式
	Gui,66:Add,Edit,x+5 yp-2 w236 h20 vvRunABackupFormat,%RunABackupFormat%
	Gui,66:Add,Button,xm yp+25 GSetRunABackupDir,RunAny.ini自动备份目录
	Gui,66:Add,Edit,x+11 yp+2 w400 r1 vvRunABackupDir,%RunABackupDir%
	
	Gui,66:Add,GroupBox,xm-10 y+25 w%GROUP_WIDTH_66% vvDisableAppGroup,屏蔽RunAny程序列表（英文逗号分隔）
	Gui,66:Font,,Consolas
	Gui,66:Add,Edit,xm yp+25 r4 -WantReturn vvDisableApp,%DisableApp%
	Gui,66:Font,,Microsoft YaHei
	
	Gui,66:Tab,热键配置,,Exact
	Gui,66:Add,GroupBox,xm-10 y+%MARGIN_TOP_66% w%GROUP_WIDTH_66% h125 vvMultiHotkey,RunAny多种方式启动菜单（与第三方软件热键冲突则取消勾选）
	Gui,66:Add,Checkbox,Checked%MenuDoubleCtrlKey% xm yp+20 vvMenuDoubleCtrlKey,双击Ctrl键
	Gui,66:Add,Checkbox,Checked%MenuDoubleAltKey% x+166 vvMenuDoubleAltKey,双击Alt键
	Gui,66:Add,Checkbox,Checked%MenuDoubleLWinKey% xm yp+20 vvMenuDoubleLWinKey,双击左Win键
	Gui,66:Add,Checkbox,Checked%MenuDoubleRWinKey% x+152 vvMenuDoubleRWinKey,双击右Win键
	Gui,66:Add,Checkbox,Checked%MenuCtrlRightKey% xm yp+20 w160 vvMenuCtrlRightKey,按住Ctrl再按鼠标右键
	Gui,66:Add,Checkbox,Checked%MenuShiftRightKey% x+86 vvMenuShiftRightKey,按住Shift再按鼠标右键
	Gui,66:Add,Checkbox,Checked%MenuXButton1Key% xm yp+20 vvMenuXButton1Key,鼠标X1键
	Gui,66:Add,Checkbox,Checked%MenuXButton2Key% x+171 vvMenuXButton2Key,鼠标X2键
	Gui,66:Add,Checkbox,Checked%MenuMButtonKey% xm yp+20 vvMenuMButtonKey,鼠标中键（需要关闭插件huiZz_MButton.ahk）

	Gui,66:Add,Link,xm y+%MARGIN_TOP_66% w%GROUP_WIDTH_66%
		,%RunAnyZz%热键配置列表（双击修改，按F2可手写AHK使用特殊热键，<a href="https://wyagd001.github.io/zh-cn/docs/KeyList.htm">如Space、CapsLock、Tab等</a>）
	Gui,66:Add,Listview,xm yp+20 w%GROUP_LISTVIEW_WIDTH_66% r16 AltSubmit -ReadOnly -Multi vRunAnyHotkeyLV glistviewHotkey, 热键AHK写法|热键说明|热键变量名
	kvLenMax:=0
	GuiControl, 66:-Redraw, RunAnyHotkeyLV
	For ki, kv in HotKeyList
	{
		StringReplace,keyV,kv,Hot
		StringReplace,winkeyV,kv,Hot,Win
		if(!MENU2FLAG){
			if ki in 2,7,9
			{
				continue
			}
		}
		%kv%:=%winkeyV% ? "#" . %keyV% : %keyV%
		LV_Add("", %kv%, HotKeyTextList[ki], kv)
		if(StrLen(%kv%)>kvLenMax)
			kvLenMax:=StrLen(%kv%)
	}
	LV_ModifyCol()
	if(kvLenMax<13)
		LV_ModifyCol(1,"AutoHdr")  ;列宽调整为标题对齐
	GuiControl, 66:+Redraw, RunAnyHotkeyLV
	
	Gui,66:Tab,菜单变量,,Exact
	Gui,66:Add,Text,xm y+%MARGIN_TOP_66% w%GROUP_WIDTH_66%,自定义配置RunAny菜单中可以使用的变量
	Gui,66:Add,Button, xm yp+30 w50 GLVMenuVarAdd, + 增加
	Gui,66:Add,Button, x+10 yp w50 GLVMenuVarEdit, · 修改
	Gui,66:Add,Button, x+10 yp w50 GLVMenuVarRemove, - 减少
	Gui,66:Add,Link, x+15 yp-5,使用方法：变量两边加百分号如：<a href="https://hui-zz.gitee.io/runany/#/article/built-in-variables">`%变量名`%</a>`n
	(
编辑菜单项的启动路径中 或 RunAny.ini文件中使用
	)
	Gui,66:Add,Listview,xm yp+40 r16 grid AltSubmit vRunAnyMenuVarLV glistviewMenuVar, 菜单变量名|类型|菜单变量值（动态变量不同电脑会自动变化）
	RunAnyMenuVarImageListID:=IL_Create(2)
	IL_Add(RunAnyMenuVarImageListID,AnyIconS[1],AnyIconS[2])
	IL_Add(RunAnyMenuVarImageListID,"shell32.dll",71)
	IL_Add(RunAnyMenuVarImageListID,"shell32.dll",25)
	GuiControl, 66:-Redraw, RunAnyMenuVarLV
	LV_SetImageList(RunAnyMenuVarImageListID)
	For mVarName, mVarVal in MenuVarIniList
	{
		mtypeIcon:=(MenuVarTypeList[mVarName]=1) ? "Icon1" : (MenuVarTypeList[mVarName]=2) ? "Icon3" : "Icon2"
		mtypeStr:=(MenuVarTypeList[mVarName]=1) ? "RunAny变量(动态)" : (MenuVarTypeList[mVarName]=2) ? "系统环境变量(动态)" : "用户变量(固定值)"
		LV_Add(mtypeIcon, mVarName, mtypeStr, mVarVal)
	}
	LV_ModifyCol()
	GuiControl, 66:+Redraw, RunAnyMenuVarLV

	evCurrentRunPath:=get_process_path("Everything.exe")
	emptyReasonStr:="无路径说明"
	if(!evCurrentRunPath){
		emptyReasonStr:="Everything未启动"
	}else if(!EvNo && !RunAEvFullPathSyncFlag){
		emptyReasonStr:="自动更新中...可以重新打开设置查看或点击EV更新同步"
	}
	Gui,66:Tab,无路径缓存,,Exact
	Gui,66:Add,Text,xm y+%MARGIN_TOP_66%,RunAny菜单中无路径的缓存全路径
	Gui,66:Add,Button,x+10 yp-5 GSetRunAEvFullPathIniDir,无路径缓存文件目录
	Gui,66:Add,Edit,x+11 yp+2 w300 r1 GSetRunAEvFullPathIniDirHint vvRunAEvFullPathIniDir,%RunAEvFullPathIniDir%
	Gui,66:Add,Button, xm yp+35 w50 GLVMenuObjPathAdd, + 增加
	Gui,66:Add,Button, x+10 yp w50 GLVMenuObjPathEdit, · 修改
	Gui,66:Add,Button, x+10 yp w50 GLVMenuObjPathRemove, - 减少
	Gui,66:Add,Button, x+10 yp w50 GLVMenuObjPathSelect, A 全选
	Gui,66:Add,Button, x+10 yp w75 GLVMenuObjPathSync, EV更新同步
	Gui,66:Add,Text, x+15 yp-5,无路径说明：每次新增或移动无路径应用文件后`n会使用Everything获得它最新的运行全路径
	Gui,66:Add,Listview,xm yp+40 r16 grid AltSubmit vRunAnyMenuObjPathLV hwndWLJLV glistviewMenuObjPath, 无路径应用名(不能有等号=)|当前电脑运行全路径（来自Everything）|%emptyReasonStr%
	RunAnyMenuObjPathImageListID := IL_Create(11)
	Icon_Image_Set(RunAnyMenuObjPathImageListID)
	GuiControl, 66:-Redraw, RunAnyMenuObjPathLV
	LV_SetImageList(RunAnyMenuObjPathImageListID)
	NWLJLV := New ListView(WLJLV)
	Loop, parse, evFullPathIniVar, `n, `r
	{
		if(A_LoopField="")
			continue
		varList:=StrSplit(A_LoopField,"=",,2)
		LV_Add(varList[2]="" ? "Icon3" : Set_Icon(RunAnyMenuObjPathImageListID,varList[2],false,false,varList[2])
		    , varList[1], varList[2], MenuObjEvPathEmptyReason[(varList[1])])
		if(!varList[2])
			NWLJLV.Color(A_Index,0x999999)
	}
	if(emptyReasonStr="无路径说明"){
		LV_ModifyCol()
	}else{
		LV_ModifyCol("Auto")
	}
	LV_ModifyCol(1, 155)
	LV_ModifyCol(2, 350)
	LV_ModifyCol(1, "Sort")  ; 排序
	GuiControl, 66:+Redraw, RunAnyMenuObjPathLV
	
	Gui,66:Tab,搜索Everything,,Exact
	EvIsAdmin:=ev.GetIsAdmin()
	EvIsAdminStatus:=EvIsAdmin ? "管理员权限" : "非管理员"
	EvAllSearch:=EvDemandSearch ? 0 : 1
	Gui,66:Add,Text,xm y+%MARGIN_TOP_66%,Everything当前权限：【%EvIsAdminStatus%】
	Gui,66:Add,Checkbox,Checked%EvAutoClose% x+20 yp vvEvAutoClose,Everything自动关闭(不常驻后台)
	if(EvPath!=""){
		Gui,66:Add,Button,x+10 w80 h20 gSetEvReindex,重建索引
	}
	Gui,66:Add,Text,xm yp+28,% "Everything当前运行路径：" evCurrentRunPath
	Gui,66:Add,GroupBox,xm-10 y+12 w%GROUP_WIDTH_66% h55,一键Everything [搜索选中文字，支持多选文件、再按为隐藏/激活] %EvHotKey%
	Gui,66:Add,Hotkey,xm+10 yp+20 w130 vvEvKey,%EvKey%
	Gui,66:Add,Checkbox,Checked%EvWinKey% xm+150 yp+3 vvEvWinKey,Win
	Gui,66:Add,Checkbox,Checked%EvShowExt% x+27 vvEvShowExt,搜索带文件后缀
	Gui,66:Add,Checkbox,Checked%EvShowFolder% x+5 vvEvShowFolder,搜索选中文件夹内部
	Gui,66:Add,GroupBox,xm-10 y+25 w%GROUP_WIDTH_66% h60 vvEvSetupGroup,Everything安装路径（支持菜单变量和相对路径 \..\代表上一级目录）
	Gui,66:Add,Button,xm yp+20 w50 GSetEvPath,选择
	Gui,66:Add,Edit,xm+60 yp+2 w%GROUP_CHOOSE_EDIT_WIDTH_66% vvEvPath,%EvPath%
	Gui,66:Add,GroupBox,xm-10 y+20 w%GROUP_WIDTH_66% vvEvCommandGroup,RunAny调用Everything搜索参数（搜索结果可在RunAny无路径运行，Everything异常请尝试重建索引）
	Gui,66:Add,Radio,Checked%EvDemandSearch% xm yp+25 cBlack vvEvDemandSearch gSetEvDemandSearch
		,按需搜索模式（推荐，只搜索RunAny菜单的无路径文件进行匹配路径，速度快，支持生成更新无路径应用缓存）
	Gui,66:Add,Radio,Checked%EvAllSearch% xm yp+25 cBlack vvEvAllSearch gSetEvAllSearch
		,全磁盘搜索模式（搜索全磁盘指定后缀的文件，然后匹配RA菜单取得路径，开机首次加载缓慢，无路径缓存无效！）
	Gui,66:Add,Checkbox,Checked%EvExeVerNew% xm yp+25 vvEvExeVerNew,搜索结果优先最新版本的同名exe
	Gui,66:Add,Checkbox,Checked%EvExeMTimeNew% x+23 vvEvExeMTimeNew,搜索结果优先最新修改时间的同名文件
	Gui,66:Add,Button,xm y+20 w50 GSetEvCommand,修改
	Gui,66:Font,,Consolas
	Gui,66:Add,Text,xm+60 yp-10,% StrReplace(EvCommandDefault,"Temp\* ","Temp\* `n") "`n表示默认排除搜索系统目录、回收站、临时目录、软件数据目录等，注意中间空格间隔"
	; Gui,66:Add,Text,xm+60 yp+15,file:*.exe|*.lnk|后面类推增加想要的后缀
	Gui,66:Add,Edit,xm y+10 r5 -WantReturn ReadOnly vvEvCommand,%EvCommand%
	Gui,66:Font,,Microsoft YaHei
	Gosub,SetEvAllSearch
	
	Gui,66:Tab,一键直达,,Exact
	Gui,66:Add,Button, xm-10 y+%MARGIN_TOP_66% w50 GRunA_One_Key_Down, @ 在线
	Gui,66:Add,Button, x+5 yp w50 GLVRunAnyOneKeyAdd, + 增加
	Gui,66:Add,Button, x+5 yp w50 GLVRunAnyOneKeyEdit, · 修改
	Gui,66:Add,Button, x+5 yp w50 GLVRunAnyOneKeyRemove, - 减少
	Gui,66:Add,Link, x+20 yp-5,【正则一键直达】（仅菜单1热键触发，不想触发的菜单项放入菜单2中）`n
	(
<a href="https://wyagd001.github.io/zh-cn/docs/misc/RegEx-QuickRef.htm">AHK正则选项</a>：i) 不区分大小写匹配  m) 多行匹配模式  S) 研究模式来提高性能
	)
	Gui,66:Add,Listview,xm-10 yp+40 w%GROUP_WIDTH_66% r12 grid AltSubmit -ReadOnly Checked vRunAnyOneKeyLV hwndYJLV glistviewRunAnyOneKey
		, 选中内容逐行匹配正则（多行整体匹配使用正则选项 m）|一键直达说明|状态|一键直达运行（支持无路径、RunAny插件写法）
	GuiControl, 66:-Redraw, RunAnyOneKeyLV
	NYJLV := New ListView(YJLV)
	For onekeyName, onekeyVal in OneKeyRunList
	{
		LV_Add(OneKeyDisableList[onekeyName] ? "" : "Check", OneKeyRegexList[onekeyName], onekeyName
			,OneKeyDisableList[onekeyName] ? "禁用" : "启用" ,onekeyName="一键公式计算" ? "内置功能输出结果" : onekeyVal)
		if(OneKeyDisableList[onekeyName])
			NYJLV.Color(A_Index,0x999999)
	}
	LV_ModifyCol()
	LV_ModifyCol(1,240)
	LV_ModifyCol(2, "Sort Auto")  ; 排序
	GuiControl, 66:+Redraw, RunAnyOneKeyLV
	Gui,66:Add,GroupBox,xm-10 y+10 w%GROUP_WIDTH_66% h240 vvOneKeyUrlGroup,一键搜索选中文字 %OneHotKey%
	Gui,66:Add,Hotkey,xm yp+30 w150 vvOneKey,%OneKey%
	Gui,66:Add,Checkbox,Checked%OneWinKey% xm+155 yp+3 vvOneWinKey,Win
	Gui,66:Add,Checkbox,Checked%OneKeyMenu% x+38 vvOneKeyMenu,绑定菜单1热键为一键搜索
	Gui,66:Add,Text,xm y+15 w325,一键搜索网址(`%s为选中文字的替代参数，多行搜索多个网址)
	Gui,66:Add,Edit,xm yp+20 r3 vvOneKeyUrl,%OneKeyUrl%
	Gui,66:Add,Text,xm y+15 w600,一键搜索非默认浏览器打开网址（新版一键网址直达请在上面列表中设置一键打开网址：浏览器.exe "`%getZz`%"）
	Gui,66:Add,Button,xm yp+20 w50 GSetBrowserPath,选择
	Gui,66:Add,Edit,xm+60 yp r2 -WantReturn vvBrowserPath,%BrowserPath%
	
	Gui,66:Tab,内部关联,,Exact
	Gui,66:Add,Text,xm y+%MARGIN_TOP_66%,内部关联RunAny.ini菜单内不同后缀的文件，使用指定软件打开
	Gui,66:Add,Text,xm yp x+5 cRed, （对资源管理器选中的文件无效！）
	Gui,66:Add,Button, xm yp+30 w50 GLVOpenExtAdd, + 增加
	Gui,66:Add,Button, x+10 yp w50 GLVOpenExtEdit, · 修改
	Gui,66:Add,Button, x+10 yp w50 GLVOpenExtRemove, - 减少
	Gui,66:Add,Text, x+10 yp-5 w360,特殊类型：网址http https www ftp等`n文件夹folder（原来使用TC、DO第三方软件打开文件夹的功能）
	Gui,66:Add,Listview,xm yp+40 r16 grid AltSubmit -Multi vRunAnyOpenExtLV glistviewOpenExt, RunAny菜单内文件后缀(用空格分隔)|打开方式(支持无路径)
	kvLenMax:=0
	GuiControl, 66:-Redraw, RunAnyOpenExtLV
	For mOpenExtName, mOpenExtRun in openExtIniList
	{
		LV_Add("", mOpenExtRun, mOpenExtName)
		if(StrLen(mOpenExtRun)>kvLenMax)
			kvLenMax:=StrLen(mOpenExtRun)
	}
	LV_ModifyCol()
	if(kvLenMax<22)
		LV_ModifyCol(1,"AutoHdr")  ;列宽调整为标题对齐
	GuiControl, 66:+Redraw, RunAnyOpenExtLV
	
	Gui,66:Tab,热字符串,,Exact
	Gui,66:Add,GroupBox,xm-10 y+%MARGIN_TOP_66% w%GROUP_WIDTH_66% vvHotStrGroup,热字符串设置
	Gui,66:Add,Checkbox,Checked%HideHotStr% xm yp+40 vvHideHotStr,隐藏热字符串提示
	Gui,66:Add,Text,xm yp+40 w250,按几个字符出现提示 (默认3个字符)
	Gui,66:Add,Edit,xm+200 yp-3 w200 r1 vvHotStrHintLen,%HotStrHintLen%
	Gui,66:Add,Text,xm yp+50 w250,提示启动路径最长字数 (0为隐藏)
	Gui,66:Add,Edit,xm+200 yp-3 w200 r1 vvHotStrShowLen,%HotStrShowLen%
	Gui,66:Add,Text,xm yp+50 w250,提示显示时长 (毫秒)
	Gui,66:Add,Edit,xm+200 yp-3 w200 r1 vvHotStrShowTime,%HotStrShowTime%
	Gui,66:Add,Text,xm yp+50 w250,提示显示透明度百分比 (`%)
	Gui,66:Add,Slider,xm+200 yp ToolTip w200 r1 vvHotStrShowTransparent,%HotStrShowTransparent%
	Gui,66:Add,Text,xm yp+50 w250,提示相对于鼠标坐标 X (可为负数)：
	Gui,66:Add,Edit,xm+200 yp-3 w200 r1 vvHotStrShowX,%HotStrShowX%
	Gui,66:Add,Text,xm yp+50 w250,提示相对于鼠标坐标 Y (可为负数)：
	Gui,66:Add,Edit,xm+200 yp-3 w200 r1 vvHotStrShowY,%HotStrShowY%
	if(encryptFlag){
		Gui,66:Add,Text,xm yp+50 w250 GMenu_Config,短语key（huiZz_Text）：
		Gui,66:Add,Edit,xm+200 yp-3 Password w200 cWhite r1 vvSendStrEcKey,%SendStrEcKey%
	}
	Gui,66:Add,Text,xm yp+50 cBlue,提示文字自动消失后，而且后续输入字符不触发热字符串功能`n需要按Tab/回车/句点/空格等键之后才会再次进行提示
	
	Gui,66:Tab,图标设置,,Exact
	Gui,66:Add,Checkbox,Checked%HideMenuTrayIcon% xm-5 y+%MARGIN_TOP_66% vvHideMenuTrayIcon gSetHideMenuTrayIcon,隐藏任务栏托盘图标
	Gui,66:Add,Text,x+10 yp,RunAny菜单图标大小(像素)
	Gui,66:Add,Edit,x+3 yp w30 h20 vvMenuIconSize,%MenuIconSize%
	Gui,66:Add,Text,x+15 yp,任务栏托盘右键图标大小(像素)
	Gui,66:Add,Edit,x+3 yp w30 h20 vvMenuTrayIconSize,%MenuTrayIconSize%
	Gui,66:Add,GroupBox,xm-10 yp+30 w%GROUP_WIDTH_66% h275,图标自定义设置（图片或图标文件路径 , 序号不填默认1）
	Gui,66:Add,Button,xm yp+20 w80 GSetAnyIcon,RunAny图标
	Gui,66:Add,Edit,xm+85 yp+1 w%GROUP_ICON_EDIT_WIDTH_66% r1 vvAnyIcon,%AnyIcon%
	Gui,66:Add,Button,xm yp+35 w80 GSetMenuIcon,准备图标
	Gui,66:Add,Edit,xm+85 yp+1 w%GROUP_ICON_EDIT_WIDTH_66% r1 vvMenuIcon,%MenuIcon%
	Gui,66:Add,Button,xm yp+35 w80 GSetTreeIcon,分类图标
	Gui,66:Add,Edit,xm+85 yp+1 w%GROUP_ICON_EDIT_WIDTH_66% r1 vvTreeIcon,%TreeIcon%
	Gui,66:Add,Button,xm yp+35 w80 GSetFolderIcon,文件夹图标
	Gui,66:Add,Edit,xm+85 yp+1 w%GROUP_ICON_EDIT_WIDTH_66% r1 vvFolderIcon,%FolderIcon%
	Gui,66:Add,Button,xm yp+35 w80 GSetUrlIcon,网址图标
	Gui,66:Add,Edit,xm+85 yp+1 w%GROUP_ICON_EDIT_WIDTH_66% r1 vvUrlIcon,%UrlIcon%
	Gui,66:Add,Button,xm yp+35 w80 GSetEXEIcon,EXE图标
	Gui,66:Add,Edit,xm+85 yp+1 w%GROUP_ICON_EDIT_WIDTH_66% r1 vvEXEIcon,%EXEIcon%
	Gui,66:Add,Button,xm yp+35 w80 GSetFuncIcon,脚本插件函数
	Gui,66:Add,Edit,xm+85 yp+1 w%GROUP_ICON_EDIT_WIDTH_66% r1 vvFuncIcon,%FuncIcon%
	Gui,66:Add,GroupBox,xm-10 y+25 w%GROUP_WIDTH_66% h185,%RunAnyZz%图标识别库（支持多行, 要求图标名与菜单项名相同, 不包含热字符串和全局热键）
	Gui,66:Add,Text, xm yp+20 w380,如图标文件名可以为：-常用(&&App).ico、cmd.png、百度(&&B).ico
	if(ResourcesExtractExist)
		Gui,66:Add,Button,x+5 yp w110 GMenu_Exe_Icon_Create,生成所有EXE图标
	Gui,66:Add,Button,xm yp+30 w50 GSetIconFolderPath,选择
	Gui,66:Add,Edit,xm+60 yp w%GROUP_CHOOSE_EDIT_WIDTH_66% r6 vvIconFolderPath,%IconFolderPath%

	Gui,66:Tab,高级配置,,Exact
	Gui,66:Add,Link,xm y+%MARGIN_TOP_66% w%GROUP_WIDTH_66%,%RunAnyZz%高级配置列表，请理解说明后修改（双击或按F2进行修改）
	Gui,66:Add,Listview,xm yp+20 r18 grid AltSubmit -ReadOnly -Multi vAdvancedConfigLV glistviewAdvancedConfig, 1或有值=启用，0或空=停用|单位|配置说明|配置脚本|配置项名
	AdvancedConfigImageListID:=IL_Create(2)
	IL_Add(AdvancedConfigImageListID,(A_OSVersion="WIN_7") ? "imageres.dll" : "shell32.dll",(A_OSVersion="WIN_XP") ? 145 : (A_OSVersion="WIN_7") ? 102 : 297)
	IL_Add(AdvancedConfigImageListID,"shell32.dll",132)
	GuiControl, 66:-Redraw, AdvancedConfigLV
	LV_SetImageList(AdvancedConfigImageListID)
	LV_Add(JumpSearch ? "Icon1" : "Icon2", JumpSearch,, "跳过点击批量搜索时的确认弹窗","","JumpSearch")
	LV_Add(ShowGetZzLen ? "Icon1" : "Icon2", ShowGetZzLen,"字", "[选中] 菜单第一行显示选中文字最大截取字数","","ShowGetZzLen")
	LV_Add(ClipWaitApp ? "Icon1" : "Icon2", ClipWaitApp,"逗号分隔", "[选中] 指定软件解决剪贴板等待时间过短获取不到选中内容（多个用,分隔）","","ClipWaitApp")
	LV_Add(ClipWaitApp ? "Icon1" : "Icon2", ClipWaitTime,"秒", "[选中] 指定软件获取选中目标到剪贴板等待时间，全局其他软件默认0.1秒","","ClipWaitTime")
	LV_Add(GetZzCopyKey ? "Icon1" : "Icon2", GetZzCopyKey,"热键", "[选中] 自定义在一些软件界面获取选中内容的热键","","GetZzCopyKey")
	LV_Add(GetZzCopyKey ? "Icon1" : "Icon2", GetZzCopyKeyApp,"逗号分隔", "[选中] 自定义在哪些软件界面改变获取选中内容热键","","GetZzCopyKeyApp")
	LV_Add(HoldCtrlRun ? "Icon1" : "Icon2", HoldCtrlRun,"", "[按住Ctrl键] 回车或点击菜单项（选项数字可互用） 2:打开该软件所在目录","","HoldCtrlRun")
	LV_Add(HoldShiftRun ? "Icon1" : "Icon2", HoldShiftRun,"", "[按住Shift键] 回车或点击菜单项（选项数字可互用） 5:打开多功能菜单运行方式","","HoldShiftRun")
	LV_Add(HoldCtrlShiftRun ? "Icon1" : "Icon2", HoldCtrlShiftRun,"", "[按住Ctrl+Shift键] 回车或点击菜单项（选项数字可互用） 3:编辑该菜单项","","HoldCtrlShiftRun")
	LV_Add(HoldCtrlWinRun ? "Icon1" : "Icon2", HoldCtrlWinRun,""
		, "[按住Ctrl+Win键] 回车或点击菜单项（选项数字可互用） 11:以管理员权限运行 12:最小化运行 13:最大化运行 14:隐藏运行(部分有效)","","HoldCtrlWinRun")
	LV_Add(HoldShiftWinRun ? "Icon1" : "Icon2", HoldShiftWinRun,""
		, "[按住Shift+Win键] 回车或点击菜单项（选项数字可互用） 31:复制运行路径 32:输出运行路径 33:复制软件名 34:输出软件名 35:复制软件名+后缀 36:输出软件名+后缀","","HoldShiftWinRun")
	LV_Add(HoldCtrlShiftWinRun ? "Icon1" : "Icon2", HoldCtrlShiftWinRun,"", "[按住Ctrl+Shift+Win键] 回车或点击菜单项（选项数字可互用） 4:强制结束该软件名进程","","HoldCtrlShiftWinRun")
	if(RunAnyMenuSpaceFlag)
		LV_Add(RunAnyMenuSpaceRun ? "Icon1" : "Icon2", RunAnyMenuSpaceRun,"", "[按空格键] 运行菜单项（只能复制上面已设置的选项数字）","RunAny_Menu.ahk","RunAnyMenuSpaceRun")
	if(RunAnyMenuRButtonFlag)
		LV_Add(RunAnyMenuRButtonRun ? "Icon1" : "Icon2", RunAnyMenuRButtonRun,"", "[按右键] 运行菜单项（只能复制上面已设置的选项数字）","RunAny_Menu.ahk","RunAnyMenuRButtonRun")
	if(RunAnyMenuMButtonFlag)
		LV_Add(RunAnyMenuMButtonRun ? "Icon1" : "Icon2", RunAnyMenuMButtonRun,"", "[按中键] 运行菜单项（只能复制上面已设置的选项数字）","RunAny_Menu.ahk","RunAnyMenuMButtonRun")
	if(RunAnyMenuXButton1Flag)
		LV_Add(RunAnyMenuXButton1Run ? "Icon1" : "Icon2", RunAnyMenuXButton1Run,"", "[按XButton1键] 运行菜单项（只能复制上面已设置的选项数字）","RunAny_Menu.ahk","RunAnyMenuXButton1Run")
	if(RunAnyMenuXButton2Flag)
		LV_Add(RunAnyMenuXButton2Run ? "Icon1" : "Icon2", RunAnyMenuXButton2Run,"", "[按XButton2键] 运行菜单项（只能复制上面已设置的选项数字）","RunAny_Menu.ahk","RunAnyMenuXButton2Run")
	LV_Add(HoldKeyShowTime ? "Icon1" : "Icon2", HoldKeyShowTime,"毫秒", "按键运行菜单项复制运行路径、软件名等提示信息的显示时间","RunAny_Menu.ahk","HoldKeyShowTime")
	if(RunAnyMenuTransparentFlag)
		LV_Add(RunAnyMenuTransparent ? "Icon1" : "Icon2", RunAnyMenuTransparent,"", "RunAny菜单和右键菜单透明度数值（0全透明-255不透明）","RunAny_Menu.ahk","RunAnyMenuTransparent")
	LV_Add(RUNANY_SELF_MENU_ITEM1 ? "Icon1" : "Icon2", RUNANY_SELF_MENU_ITEM1,, "RunAny自身功能的菜单项名称修改1：&1批量搜索","","RUNANY_SELF_MENU_ITEM1")
	LV_Add(RUNANY_SELF_MENU_ITEM2 ? "Icon1" : "Icon2", RUNANY_SELF_MENU_ITEM2,, "RunAny自身功能的菜单项名称修改2：RunAny设置","","RUNANY_SELF_MENU_ITEM2")
	LV_Add(RUNANY_SELF_MENU_ITEM3 ? "Icon1" : "Icon2", RUNANY_SELF_MENU_ITEM3,, "RunAny自身功能的菜单项名称修改3：0【添加到此菜单】","","RUNANY_SELF_MENU_ITEM3")
	LV_Add(RUNANY_SELF_MENU_ITEM4 ? "Icon1" : "Icon2", RUNANY_SELF_MENU_ITEM4,, "RunAny自身功能的菜单项名称修改4：-【显示菜单全部】","","RUNANY_SELF_MENU_ITEM4")
	LV_Add(DebugMode ? "Icon1" : "Icon2", DebugMode,, "[调试模式] 实时显示菜单运行的信息","","DebugMode")
	LV_Add(DebugMode ? "Icon1" : "Icon2", DebugModeShowTime,"毫秒", "[调试模式] 实时显示菜单运行信息的自动隐藏时间","","DebugModeShowTime")
	LV_Add(DebugMode ? "Icon1" : "Icon2", DebugModeShowTrans,"%", "[调试模式] 实时显示菜单运行信息的透明度","","DebugModeShowTrans")
	LV_Add(DisableExeIcon ? "Icon1" : "Icon2", DisableExeIcon,, "菜单中exe程序不加载本身图标","","DisableExeIcon")
	LV_Add(RunAEncoding ? "Icon1" : "Icon2", RunAEncoding,, "使用指定编码读取RunAny.ini（默认ANSI）","","RunAEncoding")
	LV_Add(AutoGetZz ? "Icon1" : "Icon2", AutoGetZz,, "【慎改】菜单程序运行自动带上当前选中文件，关闭后需要手动加%getZz%才可以获取到","","AutoGetZz")
	LV_Add(EvNo ? "Icon1" : "Icon2", EvNo,, "【慎改】不使用Everything模式，所有无路径应用缓存需要手动新增修改","","EvNo")
	LV_ModifyCol(2,"Auto Center")
	LV_ModifyCol(3,"Auto")
	LV_ModifyCol(4,"Auto")
	LV_ModifyCol(5,"Auto")
	GuiControl, 66:+Redraw, AdvancedConfigLV

	Gui,66:Tab
	Gui,66:Add,Button,Default w75 vvSetOK GSetOK,确定
	Gui,66:Add,Button,w75 vvSetCancel GSetCancel,取消
	Gui,66:Add,Button,w75 vvSetReSet GSetReSet,重置
	Gui,66:Add,Text,w75 vvMenu_Config GMenu_Config,RunAnyConfig.ini
	Gui,66:Show,w%GUI_WIDTH_66%,%RunAnyZz%设置 %RunAny_update_version% %RunAny_update_time%%AdminMode%
	Critical,Off
	k:=v:=mVarName:=mVarVal:=mOpenExtName:=mOpenExtRun:=""
	SetValueList:=["AdminRun"]
	;[手写AHK热键情况下不根据Hotkey热键控件保存，避免清空手写热键值]
	Gui,66:Submit, NoHide
	For ki, kv in RunHotKeyList
	{
		keyV:=StrReplace(kv,"Hot")
		winkeyV:=StrReplace(kv,"Hot","Win")
		if(v%keyV%="" && %kv%!=""){
			GuiControl,Disable,v%keyV%
			GuiControl,Disable,v%winkeyV%
		}else{
			SetValueList.Push(keyV)
			SetValueList.Push(winkeyV)
		}
	}
return
ConfigTabSelect:
	Gui,66:Submit, NoHide
	if(ConfigTab="无路径缓存"){
		Gui,ListView,% WLJLV
	}else if(ConfigTab="一键直达"){
		Gui,ListView,% YJLV
	}
return
;~;【关于Gui】
Menu_About:
	aboutWebHeight:=( 96 / A_ScreenDPI ) * 120 + 380
	marginTop:=( 96 / A_ScreenDPI ) * 50
	Gui,99:Destroy
	Gui,99:Color,FFFFFF
	Gui,99:Add, ActiveX, x0 y0 w570 h%aboutWebHeight% voWB, shell explorer
	oWB.Navigate("about:blank")
	versionTime:=RegExReplace(RunAny_update_time, "[^\d\.]*([\d\.]+)[^\d\.]*", "$1")
	versionUrlEncode:=StrReplace(SkSub_UrlEncode("v" RunAny_update_version),"%","`%")
vHtml = 
(
<html>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title>name</title>
<body style="font-family:Microsoft YaHei;margin:30px;background:url(https://hui-zz.gitee.io/runany/assets/images/RunAnyMp_120x120.png) no-repeat center top;">
<br><br>
<h2 align="center" style="margin-top:%marginTop%px;">
【%RunAnyZz%】一劳永逸的快速启动工具
<br>
<img alt="GitHub stars" src="https://raster.shields.io/github/stars/hui-Zz/RunAny.svg?style=social&logo=github"/>
<img alt="GitHub forks" src="https://raster.shields.io/github/forks/hui-Zz/RunAny?style=social"/>
<img alt="history" src="https://raster.shields.io/badge/2017--2022-white.svg?label=Time&style=social&logo=github"/>
</h2>
<b>当前版本：</b><img alt="当前版本" style="vertical-align:middle" src="https://raster.shields.io/badge/RunAny-%versionUrlEncode%-blue.svg?style=flat-square"/>
<br>
<b>最新版本：</b><img alt="GitHub release" style="vertical-align:middle" src="https://raster.shields.io/github/v/release/hui-Zz/RunAny.svg?label=RunAny&style=flat-square&color=red"/>
<img alt="Autohotkey" style="vertical-align:middle" src="https://raster.shields.io/badge/autohotkey-1.1.33.10-green.svg?style=flat-square&logo=autohotkey"/>
<br>
默认启动菜单热键为 <b><font color="red"><kbd>``</kbd></font></b>（Esc键下方的重音符键~`` ）
<br>
注意：想打字打出 <font color="red"><kbd>``</kbd></font> 的时候，按 <font color="red"><kbd>Win</kbd> + <kbd>``</kbd></font>
<br><br>
<li>按住<kbd>Shift</kbd>+回车键 或+鼠标左键打开 <b>多功能菜单运行方式</b></li>
<li>按住<kbd>Ctrl</kbd>+回车键 或+鼠标左键打开 软件所在的目录</li>
<li>按住<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+回车键 或+鼠标左键打开 快速跳转到编辑该菜单项</li>
<li>按住<kbd>Ctrl</kbd>+<kbd>Win</kbd>+鼠标左键打开 以管理员身份来运行</li>
<br>
【右键任务栏RA图标进行设置】
<br><br>
作者：hui-Zz 建议：hui0.0713@gmail.com
</body>
</html>
)
	oWB.document.write(vHtml)
	oWB.Refresh()
	Gui,99:Font,s11 Bold cRed,Microsoft YaHei
	Gui,99:Add,Link,xm+18 y+10,赞助支持作者：<a href="https://hui-zz.gitee.io/runany/#/ABOUT">https://hui-zz.gitee.io/runany/#/ABOUT</a>
	Gui,99:Font,s11 Bold cBlack,Microsoft YaHei
	Gui,99:Add,Link,xm+18 y+10,国内Gitee文档：<a href="https://hui-zz.gitee.io/RunAny">https://hui-zz.gitee.io/RunAny</a>
	Gui,99:Add,Link,xm+18 y+10,Github文档：<a href="https://hui-zz.github.io/RunAny">https://hui-zz.github.io/RunAny</a>
	Gui,99:Add,Link,xm+18 y+10,Github地址：<a href="https://github.com/hui-Zz/RunAny">https://github.com/hui-Zz/RunAny</a>
	Gui,99:Add,Text,y+10, 讨论QQ群：
	Gui,99:Add,Link,x+8 yp,<a href="https://jq.qq.com/?_wv=1027&k=445Ug7u">246308937【RunAny快速启动一劳永逸】</a>`n
	Gui,99:Font
	Gui,99:Show,AutoSize Center,关于%RunAnyZz% %RunAny_update_version% %RunAny_update_time%%AdminMode%
	hCurs:=DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt") ;IDC_HAND
	OnMessage(0x200,"WM_MOUSEMOVE")
return
SetEvPath:
	FileSelectFile, evFilePath, 3, Everything.exe, Everything安装路径, (Everything.exe)
	if(evFilePath)
		GuiControl,, vEvPath, %evFilePath%
return
SetIconFolderPath:
	Gui,66:Submit, NoHide
	FileSelectFolder, iconFolderName, , 0
	if(iconFolderName){
		if(vIconFolderPath){
			GuiControl,, vIconFolderPath, %vIconFolderPath%`n%iconFolderName%
		}else{
			GuiControl,, vIconFolderPath, %iconFolderName%
		}
	}
return
SetRunABackupDir:
	Gui,66:Submit, NoHide
	FileSelectFolder, dir, , 0
	if(dir){
		GuiControl,, vRunABackupDir, %dir%
	}
return
SetRunAEvFullPathIniDir:
	Gui,66:Submit, NoHide
	FileSelectFolder, dir, , 0
	if(dir){
		GuiControl,, vRunAEvFullPathIniDir, %dir%
	}
return
SetRunAEvFullPathIniDirHint:
	ToolTip, ⚠ 无路径缓存文件 请不要设置在网盘同步文件夹里面！`n防止把其他电脑上的软件路径同步过来造成混乱, 370, 45
	SetTimer,RemoveToolTip,4000
return
SetBrowserPath:
	FileSelectFile, browserFilePath, 3, , 程序路径, (*.exe)
	if(browserFilePath)
		GuiControl,, vBrowserPath, %browserFilePath%
return
SetOpenExtRun:
	FileSelectFile, openExtPath, , , 启动文件路径
	if(openExtPath){
		GuiControl,, vopenExtRun, %openExtPath%
	}
return
SetAnyIcon:
SetMenuIcon:
SetTreeIcon:
SetFolderIcon:
SetUrlIcon:
SetEXEIcon:
SetFuncIcon:
	setEdit:=StrReplace(A_ThisLabel, "Set", "v")
	FileSelectFile, filePath, 3, , 图标图片路径
	if(filePath)
		GuiControl,, %setEdit%, %filePath%
return
SetEvCommand:
	MsgBox,64,Everything搜索参数语法,请打开Everything参照`nEverything-帮助(H)-搜索语法`n`n
		(
修改以下文本框参数后，请务必复制参数到Everthing搜索
检验是否有搜索到RunAny菜单中的程序，避免出现错误
		)
	GuiControl,-ReadOnly,vEvCommand
return
SetOK:
	Gui,66:Submit, NoHide
	if(!vEvDemandSearch && !InStr(vEvCommand,"file:*.exe")){
		MsgBox, 48, 提示：, 搜索Everything - 全磁盘搜索模式 - 请修改搜索参数编辑框
			, 指定搜索后缀`n`n空格间隔后写入 file:*.exe|*.lnk|*.ahk|*.bat|*.cmd`n`n否则开机加载会非常缓慢！
		return
	}
	Gui,66:Hide
	vConfigDate:=A_MM A_DD
	if(vAutoRun!=AutoRun){
		AutoRun:=vAutoRun
		if(AutoRun){
			RegWrite, REG_SZ, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, RunAny, %A_ScriptDir%\%Z_ScriptName%
		}else{
			RegDelete, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, RunAny
		}
	}
	if(vSendStrEcKey!=SendStrEcKey){
		vSendStrEcKey:=SendStrEncrypt(vSendStrEcKey,RunAnyZz vConfigDate)
	}else{
		vSendStrEcKey:=SendStrEncrypt(SendStrDcKey,RunAnyZz vConfigDate)
	}
	SetValueList.Push("ConfigDate","AutoReloadMTime","RunABackupRule","RunABackupMax","RunABackupFormat","RunABackupDir","RunAEvFullPathIniDir","DisableApp"
		,"EvPath","EvCommand","EvAutoClose","EvShowExt","EvShowFolder","EvExeVerNew","EvExeMTimeNew","EvDemandSearch"
		,"HideFail","HideWeb","HideGetZz","HideSend","HideAddItem","HideMenuTray","HideSelectZz","RecentMax"
		,"OneKeyUrl","OneKeyMenu","BrowserPath","IconFolderPath"
		,"HideMenuTrayIcon","MenuIconSize","MenuTrayIconSize","MenuIcon","AnyIcon","TreeIcon","FolderIcon","UrlIcon","EXEIcon","FuncIcon"
		,"HideHotStr","HotStrHintLen","HotStrShowLen","HotStrShowTime","HotStrShowTransparent","HotStrShowX","HotStrShowY","SendStrEcKey"
		,"MenuDoubleCtrlKey", "MenuDoubleAltKey", "MenuDoubleLWinKey", "MenuDoubleRWinKey"
		,"MenuCtrlRightKey", "MenuShiftRightKey", "MenuXButton1Key", "MenuXButton2Key", "MenuMButtonKey")
	;[回车转换成竖杠保存到ini配置文件]
	OneKeyUrl:=RegExReplace(OneKeyUrl,"S)[\n]+","|")
	vOneKeyUrl:=RegExReplace(vOneKeyUrl,"S)[\n]+","|")
	IconFolderPath:=RegExReplace(IconFolderPath,"S)[\n]+","|")
	vIconFolderPath:=RegExReplace(vIconFolderPath,"S)[\n]+","|")
	For vi, vv in SetValueList
	{
		vValue:="v" . vv
		Var_Set(%vValue%,%vv%,vv)
	}
	;[保存热键配置列表]
	if(HotKeyFlag){
		Gui, ListView, RunAnyHotkeyLV
		Loop % LV_GetCount()
		{
			LV_GetText(RunAHotKey, A_Index, 1)
			LV_GetText(RunAHotKeyVal, A_Index, 3)
			keyV:=StrReplace(RunAHotKeyVal,"Hot")
			winkeyV:=StrReplace(RunAHotKeyVal,"Hot","Win")
			v_keyV:=StrReplace(RunAHotKey,"#")
			v_winkeyV:=InStr(RunAHotKey,"#")
			IniWrite,%v_keyV%,%RunAnyConfig%,Config,%keyV%
			IniWrite,%v_winkeyV%,%RunAnyConfig%,Config,%winkeyV%
		}
	}
	;[保存自定义菜单变量]
	if(MenuVarFlag){
		Gui, ListView, RunAnyMenuVarLV
		IniWrite, delete=1, %RunAnyConfig%, MenuVar
		IniDelete, %RunAnyConfig%, MenuVar, delete
		Loop % LV_GetCount()
		{
			LV_GetText(menuVarName, A_Index, 1)
			LV_GetText(menuVarVal, A_Index, 3)
			IniWrite,%menuVarVal%,%RunAnyConfig%,MenuVar,%menuVarName%
		}
	}
	;[保存无路径应用缓存]
	if(MenuObjPathFlag){
		Gui, ListView, RunAnyMenuObjPathLV
		FileDelete, %RunAnyEvFullPathIni%
		IniWrite, delete=1, %RunAnyEvFullPathIni%, FullPath
		IniDelete, %RunAnyEvFullPathIni%, FullPath, delete
		Loop % LV_GetCount()
		{
			LV_GetText(menuObjPathName, A_Index, 1)
			LV_GetText(menuObjPathVal, A_Index, 2)
			IniWrite,%menuObjPathVal%,%RunAnyEvFullPathIni%,FullPath,%menuObjPathName%
		}
	}
	;[保存一键直达]
	if(RunAnyOneKeyFlag){
		Gui, ListView, RunAnyOneKeyLV
		IniWrite, delete=1, %RunAnyConfig%, OneKey
		IniDelete, %RunAnyConfig%, OneKey, delete
		OneKeyDisableSaveList:=[]
		Loop % LV_GetCount()
		{
			LV_GetText(oneKeyRegex, A_Index, 1)
			LV_GetText(oneKeyName, A_Index, 2)
			LV_GetText(oneKeyStatus, A_Index, 3)
			LV_GetText(oneKeyRegexRun, A_Index, 4)
			if(oneKeyName="一键公式计算")
				oneKeyRegexRun=
			IniWrite,%oneKeyRegex%,%RunAnyConfig%,OneKey,%oneKeyName%_Regex
			IniWrite,%oneKeyRegexRun%,%RunAnyConfig%,OneKey,%oneKeyName%_Run
			if(oneKeyStatus="禁用")
				OneKeyDisableSaveList.Push(oneKeyName)
		}
		Var_Set(StrListJoin("|",OneKeyDisableSaveList),OneKeyDisableStr,"OneKeyDisableList")
	}
	;[保存内部关联打开后缀列表]
	if(OpenExtFlag){
		Gui, ListView, RunAnyOpenExtLV
		IniWrite, delete=1, %RunAnyConfig%, OpenExt
		IniDelete, %RunAnyConfig%, OpenExt, delete
		Loop % LV_GetCount()
		{
			LV_GetText(openExtName, A_Index, 1)
			LV_GetText(openExtRun, A_Index, 2)
			IniWrite,%openExtName%,%RunAnyConfig%,OpenExt,%openExtRun%
		}
	}
	;[保存高级配置]
	if(AdvancedConfigFlag){
		Gui, ListView, AdvancedConfigLV
		Loop % LV_GetCount()
		{
			LV_GetText(AdvancedConfigVal, A_Index, 1)
			LV_GetText(AdvancedConfigName, A_Index, 5)
			Var_Set(AdvancedConfigVal,%AdvancedConfigName%,AdvancedConfigName)
		}
	}
	Gosub,Menu_Reload
return
SetHideSelectZz:
	GuiControlGet, outPutVar, , vHideSelectZz
	GuiControl,, vHideSelectZz2, %outPutVar%
return
SetScheduledTasks:
	cmdClipReturn("""schtasks /create /tn """ RunAnyZz "启动"" /tr " A_AhkPath " /sc onlogon /rl HIGHEST""")
	Run,taskschd.msc
	if(rule_chassis_types()>=8){
		Sleep,1000
		MsgBox, 64, 任务计划%RunAnyZz%创建完成, 在每次系统登录时会以管理员权限启动%RunAnyZz%`n`n
		(
【注意】`n当前电脑是笔记本，如果需要笔记本使用电池开机也会自动启动%RunAnyZz%
`n请找到任务计划程序库-%RunAnyZz%启动-右键属性-“条件”里面-
取消勾选“只有在计算机使用交流电源时才启动此任务”
		)
	}
	GuiControl,,vAutoRun,0
return
SetClearRecentMax:
	RegDelete, HKEY_CURRENT_USER\SOFTWARE\RunAny, MenuCommonList
return
SetEvReindex:
	Gui,66:Submit, NoHide
	Run,% Get_Transform_Val(vEvPath) " -reindex"
return
SetReSet:
	MsgBox,49,重置RunAny配置,此操作会删除RunAny所有注册表配置`n以及删除本地配置文件%RunAnyConfig%！`n还有所有的规则启动配置！`n确认删除重置吗？
	IfMsgBox Ok
	{
		RegDelete, HKEY_CURRENT_USER\SOFTWARE\RunAny
		RegDelete, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, RunAny
		FileDelete, %RunAnyConfig%
		Gosub,Menu_Reload
	}
return
SetEvAllSearch:
	Gui,66:Submit, NoHide
	if(vEvDemandSearch){
		Gui,66:Font, cBlack, Microsoft YaHei
		GuiControl,66:Font, vEvAllSearch
	}else{
		Gui,66:Font, cRed, Microsoft YaHei
		GuiControl,66:Font, vEvAllSearch
		GuiControl,66:Font, RunAnyMenuObjPathLV
		Gui,66:Font, cBlack, Microsoft YaHei
	}
return
SetEvDemandSearch:
	Gui,66:Submit, NoHide
	Gosub,SetEvAllSearch
	if(vEvDemandSearch){
		MsgBox,64,Everything按需搜索模式, 只搜索%RunAnyZz%菜单的无路径文件，`n
		(
（不再搜索电脑上所有exe、lnk等后缀文件全路径）加快加载速度`n
想在%RunAnyZz%菜单中的任意后缀文件，都可以无路径运行`n
按需模式可以去掉下面的搜索参数：file:*.exe|*.lnk|*.ahk|*.bat|*.cmd`n
【注意】此设置会影响RunAny所有设置和插件脚本的无路径识别，
不在RunAny.ini菜单内的程序无法自动识别全路径
		)
	}
return
SetMenu2:
	MsgBox,33,开启第2个菜单,确定开启第2个菜单吗？`n会在目录生成RunAny2.ini`n【注意！】`n还原可以删除或重命名RunAny2.ini
	IfMsgBox Ok
	{
		text2=;这里添加第2菜单内容`n-菜单2分类
		FileAppend,%text2%,%iniPath2%
		Gosub,Menu_Edit2
	}
return
SetMenuWinKey:
	GuiControlGet, outPutVar, , vMenuWinKey
	If(outPutVar)
		MsgBox, 48, 提示：, 使用Win+字母热键可能无法取得QQ聊天窗口中文字，`n因为QQ聊天窗口是绘制的特殊窗体
return
SetMenuWinKey2:
	GuiControlGet, outPutVar, , vMenuWinKey2
	If(outPutVar)
		MsgBox, 48, 提示：, 使用Win+字母热键可能无法取得QQ聊天窗口中文字，`n因为QQ聊天窗口是绘制的特殊窗体
return
SetHideMenuTrayIcon:
	Gui,66:Submit, NoHide
	If(vHideMenuTray && vHideMenuTrayIcon){
		MsgBox, 48, 警告！, 已经隐藏菜单中的“RunAny设置”，如果再隐藏任务栏托盘图标后`n
		(
只能通过快捷键来再次打开RunAny设置界面，如果忘记热键的话`n`n需要手动修改 RunAnyConfig.ini 文件取消隐藏图标： HideMenuTrayIcon=0
		)
	}
return
;~;[编辑设置Gui]
;-------------------------------------RunAny热键配置界面-------------------------------------
RunA_Hotkey_Edit:
	Gui, ListView, RunAnyHotkeyLV
	RunRowNumber := LV_GetNext(0, "F")
	if not RunRowNumber
		return
	LV_GetText(RunAHotKey, RunRowNumber, 1)
	LV_GetText(RunAHotKeyText, RunRowNumber, 2)
	LV_GetText(RunAHotKeyVal, RunRowNumber, 3)
	keyV:=StrReplace(RunAHotKeyVal,"Hot")
	winkeyV:=StrReplace(RunAHotKeyVal,"Hot","Win")
	v_keyV:=StrReplace(RunAHotKey,"#")
	v_winkeyV:=InStr(RunAHotKey,"#")
	Gui,key:Destroy
	Gui,key:Default
	Gui,key:+Owner66
	Gui,key:Margin,20,20
	Gui,key:Font,,Microsoft YaHei
	Gui,key:Add,GroupBox,xm-10 y+20 w255 h55,%RunAHotKeyText%：%RunAHotKey%
	Gui,key:Add,Hotkey,xm yp+20 w180 vvkeyV,%v_keyV%
	Gui,key:Add,Checkbox,Checked%v_winkeyV% xm+185 yp+3 vvwinkeyV,Win
	Gui,key:Font
	Gui,key:Add,Button,Default xm+35 y+25 w75 GSaveRunAHotkey,保存
	Gui,key:Add,Button,x+20 w75 GSetCancel,取消
	Gui,key:Show,,配置热键 %RunAny_update_version% %RunAny_update_time%
return
listviewHotkey:
    if A_GuiEvent = DoubleClick
    {
		Gosub,RunA_Hotkey_Edit
    }else if A_GuiEvent = e
	{
		HotKeyFlag:=true
	}else if  A_GuiEvent = R
	{
		Run,https://wyagd001.github.io/zh-cn/docs/KeyList.htm
	}
return
SaveRunAHotkey:
	HotKeyFlag:=true
	Gui,key:Submit, NoHide
	vKeyWinKeyV:=vwinkeyV ? "#" . vkeyV : vkeyV
	Gui,66:Default
	LV_Modify(RunRowNumber,"",vKeyWinKeyV)
	LV_ModifyCol()  ; 根据内容自动调整每列的大小.
	Gui,key:Destroy
return
;-------------------------------------内部关联打开后缀界面-------------------------------------
Open_Ext_Edit:
	Gui, ListView, RunAnyOpenExtLV
	if(openExtItem="编辑"){
		RunRowNumber := LV_GetNext(0, "F")
		if not RunRowNumber
			return
		LV_GetText(openExtName, RunRowNumber, 1)
		LV_GetText(openExtRun, RunRowNumber, 2)
	}
	Gui,SaveExt:Destroy
	Gui,SaveExt:Default
	Gui,SaveExt:+Owner66
	Gui,SaveExt:Margin,20,20
	Gui,SaveExt:Font,,Microsoft YaHei
	Gui,SaveExt:Add, GroupBox,xm y+10 w450 h145,%openExtItem%内部关联后缀打开方式
	Gui,SaveExt:Add, Text, xm+10 y+35 y35 w62, 文件后缀    (空格分隔)
	Gui,SaveExt:Add, Edit, x+5 yp+5 w350 vvopenExtName, %openExtName%
	Gui,SaveExt:Add, Button, xm+5 y+15 w60 GSetOpenExtRun,打开方式软件路径
	Gui,SaveExt:Add, Edit, x+12 yp w350 r3 -WantReturn vvopenExtRun, %openExtRun%
	Gui,SaveExt:Font
	Gui,SaveExt:Add,Button,Default xm+140 y+25 w75 GSaveOpenExt,保存(&Y)
	Gui,SaveExt:Add,Button,x+20 w75 GSetCancel,取消(&C)
	Gui,SaveExt:Show,,%RunAnyZz% - %openExtItem%内部关联后缀打开方式 %RunAny_update_version% %RunAny_update_time%
return
listviewOpenExt:
    if A_GuiEvent = DoubleClick
    {
		openExtItem:="编辑"
		Gosub,Open_Ext_Edit
    }
return
LVOpenExtAdd:
	openExtItem:="新建"
	openExtName:=openExtRun:=""
	Gosub,Open_Ext_Edit
return
LVOpenExtEdit:
	openExtItem:="编辑"
	Gosub,Open_Ext_Edit
return
LVOpenExtRemove:
	Gui, ListView, RunAnyOpenExtLV
	OpenExtFlag:=true
	RunRowNumber := LV_GetNext(0, "F")
	if not RunRowNumber
		return
	LV_Delete(RunRowNumber)
return
SaveOpenExt:
	OpenExtFlag:=true
	Gui,SaveExt:Submit, NoHide
	if(!vopenExtName || !vopenExtRun){
		ToolTip, 请填入文件后缀名和打开方式软件路径,195,35
		SetTimer,RemoveToolTip,3000
		return
	}
	Gui,66:Default
	if(openExtItem="新建"){
		if(openExtIniList[vopenExtRun]){
			Loop % LV_GetCount()
			{
				LV_GetText(openExtNameGet, A_Index, 1)
				LV_GetText(openExtRunGet, A_Index, 2)
				if(vopenExtRun=openExtRunGet){
					LV_Modify(A_Index,"",openExtNameGet . A_Space . vopenExtName,vopenExtRun)
					ToolTip, 已自动合并后缀到相同打开方式中,195,-20
					SetTimer,RemoveToolTip,3000
					break
				}
			}
		}else{
			LV_Add("",vopenExtName,vopenExtRun)
		}
	}else{
		LV_Modify(RunRowNumber,"",vopenExtName,vopenExtRun)
	}
	LV_ModifyCol()  ; 根据内容自动调整每列的大小.
	Gui,SaveExt:Destroy
return
;--------------------------------------菜单变量设置界面--------------------------------------
Menu_Var_Edit:
	Gui, ListView, RunAnyMenuVarLV
	if(menuVarItem="编辑"){
		RunRowNumber := LV_GetNext(0, "F")
		if not RunRowNumber
			return
		LV_GetText(menuVarName, RunRowNumber, 1)
		LV_GetText(menuVarType, RunRowNumber, 2)
		LV_GetText(menuVarVal, RunRowNumber, 3)
	}
	Gui,SaveVar:Destroy
	Gui,SaveVar:Default
	Gui,SaveVar:+Owner66
	Gui,SaveVar:Margin,20,20
	Gui,SaveVar:Font,,Microsoft YaHei
	Gui,SaveVar:Add, GroupBox,xm y+10 w450 h135 vvmenuVarType,%menuVarType%
	Gui,SaveVar:Add, Text, xm+5 y+35 y35 w60,菜单变量名
	Gui,SaveVar:Add, Edit, x+5 yp w350 vvmenuVarName gSetMenuVarVal, %menuVarName%
	Gui,SaveVar:Add, Text, xm+5 y+15 w60,菜单变量值
	Gui,SaveVar:Add, Edit, x+5 yp w350 r3 -WantReturn vvmenuVarVal, %menuVarVal%
	Gui,SaveVar:Font
	Gui,SaveVar:Add,Button,Default xm+140 y+25 w75 GSaveMenuVar,保存(&S)
	Gui,SaveVar:Add,Button,x+20 w75 GSetCancel,取消(&C)
	Gui,SaveVar:Show,,%RunAnyZz% - %menuVarItem%菜单变量和变量值 %RunAny_update_version% %RunAny_update_time%
	if(menuVarType!="用户变量(固定值)")
		Gosub,SetMenuVarVal
return
listviewMenuVar:
    if A_GuiEvent = DoubleClick
    {
		menuVarItem:="编辑"
		Gosub,Menu_Var_Edit
    }
return
LVMenuVarAdd:
	menuVarItem:="新建"
	menuVarName:=menuVarVal:=""
	Gosub,Menu_Var_Edit
return
LVMenuVarEdit:
	menuVarItem:="编辑"
	Gosub,Menu_Var_Edit
return
LVMenuVarRemove:
	Gui, ListView, RunAnyMenuVarLV
	MenuVarFlag:=true
	RunRowNumber := LV_GetNext(0, "F")
	if not RunRowNumber
		return
	LV_Delete(RunRowNumber)
return
SetMenuVarVal:
	Gui,SaveVar:Submit, NoHide
	if(vmenuVarName="")
		return
	if(!RegExMatch(vmenuVarName,"S)^[\p{Han}A-Za-z0-9_]+$")){
		ToolTip, 变量名只能为中文、数字、字母、下划线,195,35
		SetTimer,RemoveToolTip,3000
		return
	}
	try EnvGet, sysMenuVarName, %vmenuVarName%
	if(sysMenuVarName){
		menuVarType:="系统环境变量(动态)"
		GuiControl,, vmenuVarVal, %sysMenuVarName%
		GuiControl,, vmenuVarType, %menuVarType%
		GuiControl,+ReadOnly, vmenuVarVal
	}else{
		if(%vmenuVarName%){
			menuVarType:="RunAny变量(动态)"
			GuiControl,, vmenuVarVal, % %vmenuVarName%
			GuiControl,, vmenuVarType, %menuVarType%
			GuiControl,+ReadOnly, vmenuVarVal
		}else{
			menuVarType:="用户变量(固定值)"
			GuiControl,, vmenuVarType, %menuVarType%
			GuiControl,-ReadOnly, vmenuVarVal
		}
	}
return
SaveMenuVar:
	MenuVarFlag:=true
	Gui,SaveVar:Submit, NoHide
	if(vmenuVarName=""){
		ToolTip, 请填入菜单变量名,195,35
		SetTimer,RemoveToolTip,3000
		return
	}
	if(!RegExMatch(vmenuVarName,"S)^[\p{Han}A-Za-z0-9_]+$")){
		ToolTip, 变量名只能为中文、数字、字母、下划线,195,35
		SetTimer,RemoveToolTip,3000
		return
	}
	Gui,66:Default
	if(menuVarItem="新建"){
		if(MenuVarIniList[vmenuVarName]){
			ToolTip, 已有相同菜单变量名！,195,35
			SetTimer,RemoveToolTip,3000
			return
		}
		LV_Add("",vmenuVarName,menuVarType,vmenuVarVal)
	}else{
		LV_Modify(RunRowNumber,"",vmenuVarName,menuVarType,vmenuVarVal)
	}
	LV_ModifyCol()  ; 根据内容自动调整每列的大小.
	Gui,SaveVar:Destroy
return
;-----------------------------------无路径应用缓存设置界面-----------------------------------
Menu_Obj_Path_Edit:
	Gui, ListView, RunAnyMenuObjPathLV
	if(menuObjPathItem="编辑"){
		RunRowNumber := LV_GetNext(0, "F")
		if not RunRowNumber
			return
		LV_GetText(menuObjPathName, RunRowNumber, 1)
		LV_GetText(menuObjPathVal, RunRowNumber, 2)
	}
	Gui,SavePath:Destroy
	Gui,SavePath:Default
	Gui,SavePath:+Owner66
	Gui,SavePath:Margin,20,20
	Gui,SavePath:Font,,Microsoft YaHei
	Gui,SavePath:Add, GroupBox,xm y+10 w450 h135, 无路径应用缓存
	Gui,SavePath:Add, Text, xm+5 y+35 y35 w60,无路径名
	Gui,SavePath:Add, Edit, x+5 yp w350 vvmenuObjPathName, %menuObjPathName%
	Gui,SavePath:Add, Text, xm+5 y+15 w60,运行全路径
	Gui,SavePath:Add, Edit, x+5 yp w350 r3 -WantReturn vvmenuObjPathVal, %menuObjPathVal%
	Gui,SavePath:Font
	Gui,SavePath:Add,Button,Default xm+140 y+25 w75 GSaveMenuObjPath,保存(&S)
	Gui,SavePath:Add,Button,x+20 w75 GSetCancel,取消(&C)
	Gui,SavePath:Show,,%RunAnyZz% - %menuObjPathItem%菜单无路径应用缓存 %RunAny_update_version% %RunAny_update_time%
return
listviewMenuObjPath:
    if A_GuiEvent = DoubleClick
    {
		menuObjPathItem:="编辑"
		Gosub,Menu_Obj_Path_Edit
    }
return
LVMenuObjPathAdd:
	menuObjPathItem:="新建"
	menuObjPathName:=menuObjPathVal:=""
	Gosub,Menu_Obj_Path_Edit
return
LVMenuObjPathEdit:
	menuObjPathItem:="编辑"
	Gosub,Menu_Obj_Path_Edit
return
LVMenuObjPathRemove:
	Gui, ListView, RunAnyMenuObjPathLV
	MenuObjPathFlag:=true
	DelRowList:=""
	RowNumber:=0
	Loop
	{
		RowNumber := LV_GetNext(RowNumber)  ; 在前一次找到的位置后继续搜索.
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		DelRowList:=RowNumber . ":" . DelRowList
	}
	stringtrimright, DelRowList, DelRowList, 1
	loop, parse, DelRowList, :
		LV_Delete(A_loopfield)
return
LVMenuObjPathSelect:
	Gui, ListView, RunAnyMenuObjPathLV
	LV_Modify(0, "Select Focus")   ; 选择所有.
return
LVMenuObjPathSync:
	Gosub,Ev_Exist
	if(EverythingIsRun()){
		RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\RunAny, ReloadGosub, Settings_Gui
		EvCommandStr:=EverythingNoPathSearchStr()
		Gosub,RunAEvFullPathSync
		ShowTrayTip("","无路径应用缓存已经最新",3,17)
		Gosub,Menu_Reload
	}
return
SaveMenuObjPath:
	MenuObjPathFlag:=true
	Gui,SavePath:Submit, NoHide
	if(vmenuObjPathName=""){
		ToolTip, 请填入无路径应用缓存名,195,35
		SetTimer,RemoveToolTip,3000
		return
	}
	Gui,66:Default
	if(menuObjPathItem="新建"){
		if(MenuObjEv[vmenuObjPathName]){
			ToolTip, 已有相同无路径应用缓存名！,195,35
			SetTimer,RemoveToolTip,3000
			return
		}
		LV_Add("",vmenuObjPathName,vmenuObjPathVal)
	}else{
		LV_Modify(RunRowNumber,"",vmenuObjPathName,vmenuObjPathVal)
	}
	LV_ModifyCol()  ; 根据内容自动调整每列的大小.
	LV_ModifyCol(1, "Sort")  ; 排序
	Gui,SavePath:Destroy
return
;-----------------------------------正则一键直达设置界面-----------------------------------
RunA_One_Key_Edit:
	Gui, ListView, RunAnyOneKeyLV
	if(runAnyOneKeyItem="编辑"){
		RunRowNumber := LV_GetNext(0, "F")
		if not RunRowNumber
			return
		LV_GetText(oneKeyRegex, RunRowNumber, 1)
		LV_GetText(oneKeyName, RunRowNumber, 2)
		LV_GetText(oneKeyStatus, RunRowNumber, 3)
		LV_GetText(oneKeyRegexRun, RunRowNumber, 4)
		oneKeyStatusText:=oneKeyStatus="启用" ? "Green" : ""
		oneKeyStatus:=oneKeyStatus="启用" ? 1 : 0
	}
	Gui,OneKey:Destroy
	Gui,OneKey:Default
	Gui,OneKey:+Owner66
	Gui,OneKey:Margin,20,20
	Gui,OneKey:Font,,Microsoft YaHei
	Gui,OneKey:Add, GroupBox, xm y+10 w450 h230, 选中内容匹配正则表达式后运行
	Gui,OneKey:Add, Text, xm+5 yp+35 y35,直达说明
	Gui,OneKey:Add, Edit, x+10 yp-3 w250 vvoneKeyName, %oneKeyName%
	Gui,OneKey:Add, CheckBox, x+15 yp+3 Checked%oneKeyStatus% vvoneKeyStatus c%oneKeyStatusText%, 启用
	Gui,OneKey:Add, Text, xm+5 y+15,匹配正则
	Gui,OneKey:Add, Edit, x+10 yp w380 r6 -WantReturn vvoneKeyRegex, %oneKeyRegex%
	Gui,OneKey:Add, Button, xm yp+27 w60 GGraphicRegex,图解正则
	Gui,OneKey:Add, Text, xm+5 y+65,直达运行
	Gui,OneKey:Add, Edit, x+10 yp w380 r2 -WantReturn vvoneKeyRegexRun, %oneKeyRegexRun%
	Gui,OneKey:Font
	Gui,OneKey:Add,Button,Default xm+140 y+25 w75 GSaveRunAnyOneKey,保存(&S)
	Gui,OneKey:Add,Button,x+20 w75 GSetCancel,取消(&C)
	Gui,OneKey:Show,,%RunAnyZz% - %runAnyOneKeyItem%正则一键直达 %RunAny_update_version% %RunAny_update_time%
return
listviewRunAnyOneKey:
	if A_GuiEvent = DoubleClick
	{
		runAnyOneKeyItem:="编辑"
		Gosub,RunA_One_Key_Edit
	}
	if (A_GuiEvent = "I"){
		Gui, ListView, RunAnyOneKeyLV
		LV_GetText(oneKeyStatus, A_EventInfo, 3)
		if(errorlevel == "c" && oneKeyStatus!="禁用"){
			RunAnyOneKeyFlag:=true
			LV_Modify(A_EventInfo,"",,,"禁用")
			NYJLV.Color(A_EventInfo,0x999999)
		}else if(errorlevel == "C" && oneKeyStatus!="启用"){
			RunAnyOneKeyFlag:=true
			LV_Modify(A_EventInfo,"",,,"启用")
			NYJLV.Color(A_EventInfo,0x000000)
		}
	}
return
LVRunAnyOneKeyAdd:
	runAnyOneKeyItem:="新建"
	oneKeyRegex:=oneKeyName:=oneKeyStatus:=oneKeyRegexRun:=""
	Gosub,RunA_One_Key_Edit
return
LVRunAnyOneKeyEdit:
	runAnyOneKeyItem:="编辑"
	Gosub,RunA_One_Key_Edit
return
LVRunAnyOneKeyRemove:
	Gui, ListView, RunAnyOneKeyLV
	RunAnyOneKeyFlag:=true
	DelRowList:=""
	RowNumber:=0
	Loop
	{
		RowNumber := LV_GetNext(RowNumber)  ; 在前一次找到的位置后继续搜索.
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		DelRowList:=RowNumber . ":" . DelRowList
		LV_GetText(oneKeyName, RowNumber, 2)
		OneKeyRegexList.Delete(oneKeyName)
	}
	stringtrimright, DelRowList, DelRowList, 1
	loop, parse, DelRowList, :
		LV_Delete(A_loopfield)
return
GraphicRegex:
	Gui,OneKey:Submit, NoHide
	regexper:=RegExReplace(voneKeyRegex,"i)^[imS]+\)")
	Run,% "https://regexper.com/#" SkSub_UrlEncode(regexper)
return
SaveRunAnyOneKey:
	RunAnyOneKeyFlag:=true
	Gui,OneKey:Submit, NoHide
	if(voneKeyName=""){
		ToolTip, 请填入功能说明,300,35
		SetTimer,RemoveToolTip,3000
		return
	}
	if(InStr(voneKeyName,"=")){
		MsgBox, 48, ,一键直达名称不能包含有“=”分割符
		return
	}
	if(runAnyOneKeyItem="新建" && OneKeyRegexList[voneKeyName]){
		ToolTip, 已存在相同的一键直达名称，请修改,300,35
		SetTimer,RemoveToolTip,3000
		return
	}
	Gui,66:Default
	if(runAnyOneKeyItem="新建"){
		LV_Add("Check",voneKeyRegex,voneKeyName,voneKeyStatus ? "启用" : "禁用",voneKeyRegexRun)
	}else{
		LV_Modify(RunRowNumber,voneKeyStatus ? "Check" : "-Check",voneKeyRegex,voneKeyName,voneKeyStatus ? "启用" : "禁用",voneKeyRegexRun)
		LV_ModifyCol(2, "Sort")  ; 排序
	}
	Gui,OneKey:Destroy
return
;~;[在线正则一键直达]
RunA_One_Key_Down:
	Gosub,RunAnyOneKeyOnline
	Gui,OneKeyDown:Destroy
	Gui,OneKeyDown:Default
	Gui,OneKeyDown:+Owner66
	Gui,OneKeyDown:+Resize
	Gui,OneKeyDown:Font, s10, Microsoft YaHei
	Gui,OneKeyDown:Add, Listview, xm w620 r15 grid AltSubmit Checked BackgroundF6F6E8 vRunAnyOneKeyDownLV, 状态|选中内容逐行匹配正则|直达说明|直达运行
	GuiControl,OneKeyDown: -Redraw, RunAnyOneKeyDownLV
	For onekeyName, onekeyVal in OneKeyDownRunList
	{
		runStatus:=runCheck:=""
		if(!OneKeyRegexList[onekeyName] && !GetKeyByVal(OneKeyRegexList,OneKeyDownRegexList[onekeyName])){  ;本地列表未使用在线正则库正则
			runStatus:="未使用"
			runCheck:="Select Check"
		}else if(OneKeyRegexList[onekeyName]!=OneKeyDownRegexList[onekeyName] || OneKeyRunList[onekeyName]!=onekeyVal ){
			runStatus:="可更新"
			runCheck:="Select Check"
		}
		LV_Add(runCheck, runStatus, OneKeyDownRegexList[onekeyName], onekeyName,onekeyName="一键公式计算" ? "内置功能输出结果" : onekeyVal)
	}
	GuiControl,OneKeyDown: +Redraw, RunAnyOneKeyDownLV
	Menu, OneKeyDownMenu, Add,全部勾选, LVRunAnyOneKeyCheck
	Menu, OneKeyDownMenu, Icon,全部勾选, SHELL32.dll,145
	Menu, OneKeyDownMenu, Add,添加勾选的正则一键直达, LVRunAnyOneKeyDown
	Menu, OneKeyDownMenu, Icon,添加勾选的正则一键直达, SHELL32.dll,123
	Gui,OneKeyDown: Menu, OneKeyDownMenu
	LV_ModifyCol()
	LV_ModifyCol(2,170)
	Gui,OneKeyDown:Show, , %RunAnyZz% 在线正则一键直达 %RunAny_update_version% %RunAny_update_time%%AdminMode%
return
LVRunAnyOneKeyCheck:
	Gui, ListView, RunAnyOneKeyDownLV
	LV_Modify(0, "Check Focus")   ; 勾选所有.
return
LVRunAnyOneKeyDown:
	RunAnyOneKeyFlag:=true
	OneKeySameArray:=[]
	Loop
	{
		Gui, OneKeyDown:Default
		RowNumber := LV_GetNext(RowNumber, "Checked")  ; 再找勾选的行
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		LV_GetText(oneKeyStatus, RowNumber, 1)
		LV_GetText(oneKeyRegex, RowNumber, 2)
		LV_GetText(oneKeyName, RowNumber, 3)
		LV_GetText(oneKeyRegexRun, RowNumber, 4)
		if(OneKeyRegexList[onekeyName]=oneKeyRegex && OneKeyRunList[onekeyName]=oneKeyRegexRun){
			OneKeySameArray.Push(oneKeyName)
			continue
		}
		Gui, 66:Default
		Gui, ListView, RunAnyOneKeyLV
		if(oneKeyStatus="可更新"){
			Loop % LV_GetCount()
			{
				LV_GetText(RowRegText, A_Index, 1)
				LV_GetText(RowText, A_Index, 2)
				if(oneKeyName=RowText || oneKeyRegex=RowRegText)
					LV_Modify(A_Index,"Select",oneKeyRegex,oneKeyName,"启用",oneKeyRegexRun)
			}
		}else{
			LV_Add("Select",oneKeyRegex,oneKeyName,"启用",oneKeyRegexRun)
		}
	}
	if(OneKeySameArray.Length()>0){
		TrayTip,无法添加重名的正则一键直达：,% StrListJoin("、",OneKeySameArray),5,2
	}
	Gui,OneKeyDown:Destroy
return
RunAnyOneKeyOnline:
	global OneKeyDownRunList:={}
	global OneKeyDownRegexList:={}
	RunAnyDownDir:=RunAnyGiteePages . "/RunAny"
	if(!rule_check_network(RunAnyGiteePages)){
		RunAnyDownDir:=RunAnyGithubPages . "/RunAny"
		if(!rule_check_network(RunAnyGithubPages)){
			MsgBox,48,,网络异常，无法连接网络读取最新一键直达，请联网后重试或手动输入
			return
		}
	}
	OneKeyIniPath=%A_Temp%\%RunAnyZz%\RunAny_OneKey.ini
	URLDownloadToFile(RunAnyDownDir "/assets/RunAny_OneKey.ini",OneKeyIniPath)
	IfExist,%OneKeyIniPath%
	{
		FileGetSize, OneKeyIniSize, %OneKeyIniPath%
		if(OneKeyIniSize>500){
			IniRead,OneKeyIniVar,%OneKeyIniPath%,OneKey
			Loop, parse, OneKeyIniVar, `n, `r
			{
				varList:=StrSplit(A_LoopField,"=",,2)
				if(RegExMatch(varList[1],".+_Run$")){
					OneKeyDownRunList[RegExReplace(varList[1],"(.+)_Run$","$1")]:=varList[2]
				}
				if(RegExMatch(varList[1],".+_Regex$")){
					OneKeyDownRegexList[RegExReplace(varList[1],"(.+)_Regex$","$1")]:=varList[2]
				}
			}
			return
		}
	}
return
;[RunAny所有菜单运行项]
RunA_MenuObj_Show:
	Gui,MenuObjShow:Destroy
	Gui,MenuObjShow:Default
	Gui,MenuObjShow:+Resize
	Gui,MenuObjShow:Font, s10, Microsoft YaHei
	Gui,MenuObjShow:Add, Listview, xm w1000 r30 grid AltSubmit vRunAnyMenuObjShowLV, 菜单项名|全局热键|菜单运行路径
	RunAnyMenuObjShowImageListID := IL_Create(11)
	Icon_Image_Set(RunAnyMenuObjShowImageListID)
	GuiControl,MenuObjShow: -Redraw, RunAnyMenuObjShowLV
	LV_SetImageList(RunAnyMenuObjShowImageListID)
	for k,v in MenuObj
	{
		if(v="")
			continue
		kname:=k
		if(MenuObjKeyList[k]){
			klist:=StrSplit(k,"`t",,2)
			kname:=klist[1]
		}
		LV_Add(Set_Icon(RunAnyMenuObjShowImageListID,v,false,false,v), kname, MenuObjKeyList[k], v)
	}
	GuiControl,MenuObjShow: +Redraw, RunAnyMenuObjShowLV
	; Gui,MenuObjShow:Add, StatusBar,,% "RunAny菜单项数量总共：" MenuObj.Count()
	LV_ModifyCol()
	LV_ModifyCol(1, 200)
	LV_ModifyCol(1, "Sort")  ; 排序
	Gui,MenuObjShow:Show, , %RunAnyZz% 所有菜单运行项 %RunAny_update_version% %RunAny_update_time%%AdminMode%
return
;--------------------------------------------------------------------------------------------
listviewAdvancedConfig:
	if A_GuiEvent = DoubleClick
	{
		SendInput,{F2}
	}else if A_GuiEvent = e
	{
		AdvancedConfigFlag:=true
	}
return
;[窗口控件控制函数]
GuiControlShow(guiName,controls*){
	For k,v in controls
	{
	GuiControl, %guiName%:Show, %v%
	}
}
GuiControlHide(guiName,controls*){
	For k,v in controls
	{
	GuiControl, %guiName%:Hide, %v%
	}
}
GuiControlSet(guiName,controlName,controlVal:=""){
	GuiControl, %guiName%:, %controlName%, %controlVal%
}
;~;【——🗔窗口事件Gui——】
MenuEditGuiClose:
	if(TVFlag){
		MsgBox,51,菜单树退出,已修改过菜单信息，是否保存修改再退出？
		IfMsgBox Yes
		{
			Gosub,Menu_Save
			Gosub,Menu_Reload
		}
		IfMsgBox No
			Gui, Destroy
	}else{
		Gui, Destroy
	}
return
;[GuiEscape]
MenuEditGuiEscape:
MenuObjShowGuiEscape:
SaveItemGuiEscape:
PluginsManageGuiEscape:
PluginsDownloadGuiEscape:
PluginsLibGuiEscape:
PluginsIconGuiEscape:
RunCtrlManageGuiEscape:
RunCtrlConfigGuiEscape:
RunCtrlFuncGuiEscape:
CtrlRunGuiEscape:
RuleManageGuiEscape:
RuleConfigGuiEscape:
99GuiEscape:
keyGuiEscape:
OneKeyGuiEscape:
OneKeyDownGuiEscape:
SavePathGuiEscape:
SaveExtGuiEscape:
SaveVarGuiEscape:
SetCancel:
	Gui,Destroy
return
;[GuiSize]
MenuEditGuiSize:
MenuObjShowGuiSize:
RuleManageGuiSize:
RunCtrlConfigGuiSize:
RunCtrlFuncGuiSize:
PluginsManageGuiSize:
PluginsDownloadGuiSize:
OneKeyDownGuiSize:
	if A_EventInfo = 1
		return
	GuiControl, Move, RunAnyTV, % "H" . (A_GuiHeight-10) . " W" . (A_GuiWidth - 20)
	GuiControl, Move, RunAnyPluginsLV1, % "H" . (A_GuiHeight * 0.50) . " W" . (A_GuiWidth - 20)
	GuiControl, Move, RunAnyPluginsLV2, % "H" . (A_GuiHeight * 0.49) . " W" . (A_GuiWidth - 20) . " y" . (A_GuiHeight * 0.50 + 10)
	GuiControl, Move, RuleLV, % "H" . (A_GuiHeight-10) . " W" . (A_GuiWidth - 20)
	GuiControl, Move, RunAnyDownLV, % "H" . (A_GuiHeight-10) . " W" . (A_GuiWidth - 20)
	GuiControl, Move, RunAnyOneKeyDownLV, % "H" . (A_GuiHeight-20) . " W" . (A_GuiWidth - 40)
	GuiControl, Move, RunAnyMenuObjShowLV, % "H" . (A_GuiHeight-20) . " W" . (A_GuiWidth - 40)
	GuiControl, Move, FuncGroup, % "H" . (A_GuiHeight-130) . " W" . (A_GuiWidth - 40)
	GuiControl, Move, FuncLV, % "H" . (A_GuiHeight-270) . " W" . (A_GuiWidth - 60)
	GuiControl, Move, vFuncValue, % "H" . (A_GuiHeight-230) . " W" . (A_GuiWidth - 40)
	GuiControl, MoveDraw, vFuncSave, % " X" . (A_GuiWidth * 0.30) . " Y" . (A_GuiHeight - 50)
	GuiControl, MoveDraw, vFuncCancel, % " X" . (A_GuiWidth * 0.30 + 100) . " Y" . (A_GuiHeight - 50)
return
66GuiSize:
	if A_EventInfo = 1
		return
	GuiControl, Move, ConfigTab, % "H" . (A_GuiHeight * 0.88) . " W" . (A_GuiWidth - 20)
	GuiControl, Move, vDisableAppGroup, % "H" . (A_GuiHeight * 0.88 - 395) . " W" . (A_GuiWidth - 40)
	GuiControl, Move, vDisableApp, % "H" . (A_GuiHeight * 0.88 - 435) . " W" . (A_GuiWidth - 60)
	GuiControl, Move, RunAnyHotkeyLV, % "H" . (A_GuiHeight * 0.88 - 214) . " W" . (A_GuiWidth - 60)
	GuiControl, Move, RunAnyMenuVarLV, % "H" . (A_GuiHeight * 0.88 - 121) . " W" . (A_GuiWidth - 60)
	GuiControl, Move, RunAnyMenuObjPathLV, % "H" . (A_GuiHeight * 0.88 - 121) . " W" . (A_GuiWidth - 60)
	GuiControl, Move, vRunAEvFullPathIniDir, % " W" . (A_GuiWidth - 388)
	GuiControl, Move, vEvSetupGroup, % " W" . (A_GuiWidth - 40)
	GuiControl, Move, vEvPath, % " W" . (A_GuiWidth - 120)
	GuiControl, Move, vEvCommandGroup, % "H" . (A_GuiHeight * 0.88 - 248) . " W" . (A_GuiWidth - 40)
	GuiControl, Move, vEvCommand, % "H" . (A_GuiHeight * 0.88 - 408) . " W" . (A_GuiWidth - 60)
	GuiControl, Move, RunAnyOneKeyLV, % " W" . (A_GuiWidth - 40)
	GuiControl, Move, vOneKeyUrlGroup, % " W" . (A_GuiWidth - 40)
	GuiControl, Move, vOneKeyUrl, % " W" . (A_GuiWidth - 60)
	GuiControl, Move, vBrowserPath, % " W" . (A_GuiWidth - 120)
	GuiControl, Move, RunAnyOpenExtLV, % "H" . (A_GuiHeight * 0.88 - 121 ) . " W" . (A_GuiWidth - 60)
	GuiControl, Move, vHotStrGroup, % "H" . (A_GuiHeight * 0.80)
	GuiControl, Move, AdvancedConfigLV, % "H" . (A_GuiHeight * 0.88 - 76) " W" . (A_GuiWidth - 60)
	GuiControl, MoveDraw, vSetOK, % " X" . (A_GuiWidth * 0.30) . " Y" . (A_GuiHeight * 0.92)
	GuiControl, MoveDraw, vSetCancel, % " X" . (A_GuiWidth * 0.30 + 90) . " Y" . (A_GuiHeight * 0.92)
	GuiControl, MoveDraw, vSetReSet, % " X" . (A_GuiWidth * 0.30 + 180) . " Y" . (A_GuiHeight * 0.92)
	GuiControl, MoveDraw, vMenu_Config, % " X" . (A_GuiWidth * 0.30 + 310) . " Y" . (A_GuiHeight * 0.925)
return
SaveItemGuiSize:
	if A_EventInfo = 1
		return
	GuiControl,SaveItem:MoveDraw, vitemName, % "W" . (A_GuiWidth-360)
	GuiControl,SaveItem:MoveDraw, vitemPath, % "H" . (A_GuiHeight-230) . " W" . (A_GuiWidth - 120)
	GuiControl,SaveItem:MoveDraw, vPictureIconAdd,% "x" . (A_GuiWidth-130)
	GuiControl,SaveItem:MoveDraw, vTextIconAdd,% "x" . (A_GuiWidth-150)
	GuiControl,SaveItem:MoveDraw, vTextIconDown,% "x" . (A_GuiWidth-100)
	GuiControl,SaveItem:MoveDraw, vSaveItemSaveBtn,% "x" . (A_GuiWidth / 2 - 100) . " y" . (A_GuiHeight-60)
	GuiControl,SaveItem:MoveDraw, vSaveItemCancelBtn,% "x" . (A_GuiWidth / 2 + 10) . " y" . (A_GuiHeight-60)
	GuiControl,SaveItem:MoveDraw, vStatusBar,% "x30" . " y" . (A_GuiHeight-30)
return
RunCtrlManageGuiSize:
	if A_EventInfo = 1
		return
	GuiControl, Move, RunCtrlListBox, % "H" . (A_GuiHeight-15)
	GuiControl, Move, RunCtrlLV, % "H" . (A_GuiHeight-20) . " W" . (A_GuiWidth - 175)
return
;[GuiContextMenu]
MenuEditGuiContextMenu:
PluginsManageGuiContextMenu:
	If (A_GuiControl = "RunAnyTV") {
		TV_Modify(A_EventInfo, "Select Vis")
		Menu, TVMenu, Show
	}
	If (A_GuiControl = "RunAnyPluginsLV1" || A_GuiControl = "RunAnyPluginsLV2") {
		LV_Modify(A_EventInfo, "Select Vis")
		Menu, LVMenu, Show
	}
return
RunCtrlManageGuiContextMenu:
	If (A_GuiControl = "RunCtrlListBox" || A_GuiControl = "RunCtrlLV") {
		TV_Modify(A_EventInfo, "Select Vis")
		Menu, RunCtrlLVMenu, Show
	}
return
;[GuiDropFiles]  ; 对拖放提供支持.
MenuEditGuiDropFiles:
SaveItemGuiDropFiles:
	Loop, Parse, A_GuiEvent, `n
	{
		SelectedFileName = %A_LoopField%  ; 仅获取首个文件 (如果有多个文件的时候).
		break
	}
	;获取鼠标下面的控件
	MouseGetPos, , , id, control
	WinGetClass, class, ahk_id %id%
	if(control="SysTreeView321"){
		Loop, Parse, A_GuiEvent, `n
		{
			fileID:=TV_Add(Get_Item_Run_Path(A_LoopField),0,Set_Icon(TreeImageListID,A_LoopField))
			TVFlag:=true
		}
	}
	if(control="Edit1"){
		GuiControl,SaveItem:, vitemName, % Get_Item_Run_Path(SelectedFileName)
	}
	if(control="Edit4"){
		GuiControl,SaveItem:, vitemPath, % Get_Item_Run_Path(SelectedFileName)
	}
	Gosub,EditItemPathChange
return
PluginsManageGuiDropFiles:
	MsgBox,33,RunAny新增插件,是否复制脚本文件到插件目录？`n%A_ScriptDir%\%PluginsDir%
	IfMsgBox Ok
	{
		Loop, Parse, A_GuiEvent, `n
		{
			FileCopy, %A_LoopField%, %A_ScriptDir%\%PluginsDir%
		}
		Gosub,Plugins_Gui
	}
return
;TreeView自定义项目颜色
;https://www.autohotkey.com/boards/viewtopic.php?f=6&t=2632
class treeview{
	static list:=[]
	__New(hwnd){
		this.list[hwnd]:=this
		OnMessage(0x4e,"WM_NOTIFY_TV")
		this.hwnd:=hwnd,this.selectcolor:=""
	}
	add(info){
		Gui,TreeView,% this.hwnd
		hwnd:=TV_Add(info.Label,info.parent,info.option)
		if info.fore!=""
			this.control["|" hwnd,"fore"]:=info.fore
		if info.back!=""
			this.control["|" hwnd,"back"]:=info.back
		return hwnd
	}
	modify(info){
		this.control["|" info.hwnd,"fore"]:=info.fore
		this.control["|" info.hwnd,"back"]:=info.back
		WinSet,Redraw,,A
	}
	Remove(hwnd){
		this.control.Remove("|" hwnd)
	}
}
WM_NOTIFY_TV(Param*){
	static list:=[],ll:=""
	control:=""
	if (this:=treeview.list[NumGet(Param.2)])&&(NumGet(Param.2,2*A_PtrSize,"int")=-12){
		stage:=NumGet(Param.2,3*A_PtrSize,"uint")
		if (stage=1)
			return 0x20 ;sets CDRF_NOTIFYITEMDRAW
		if (stage=0x10001&&info:=this.control["|" numget(Param.2,A_PtrSize=4?9*A_PtrSize:7*A_PtrSize,"uint")]){ ;NM_CUSTOMDRAW && Control is in the list
			if info.fore!=""
				NumPut(info.fore,Param.2,A_PtrSize=4?12*A_PtrSize:10*A_PtrSize,"int") ;sets the foreground
			if info.back!=""
				NumPut(info.back,Param.2,A_PtrSize=4?13*A_PtrSize:10.5*A_PtrSize,"int") ;sets the background
		}
		if (this.selectcolor){
			Gui,TreeView,% NumGet(param.2)
			if (NumGet(param.2,9*A_PtrSize)=TV_GetSelection())
				NumPut(this.selectcolor,Param.2,A_PtrSize=4?13*A_PtrSize:10.5*A_PtrSize,"int") ;sets the background
		}
	}
}
;ListView自定义行颜色
;https://www.autohotkey.com/boards/viewtopic.php?f=6&t=3286&p=304384
class ListView{
	static list:=[]
	__New(hwnd){
		this.list[hwnd]:=this
		OnMessage(0x4e,"WM_NOTIFY")
		this.hwnd:=hwnd
		this.control:=[]
	}
	add(options,items*){
		Gui,ListView,% this.hwnd
		for a,b in items{
			if A_Index=1
				item:=LV_Add(options,b)
			Else
				LV_Modify(item,"col" A_Index,b)
		}
	}
	clear(){
		this.control:=[]
	}
	Color(item,fore="",back=""){
		LV_GetText(text,item)
		if fore!=""
			this.Control[text,"fore"]:=fore
		if Back!=""
			this.Control[text,"back"]:=back
	}
}
WM_NOTIFY(Param*){
	Critical
	control:=
	if (this:=ListView.list[NumGet(Param.2)])&&(NumGet(Param.2,2*A_PtrSize,"int")=-12){
		stage:=NumGet(Param.2,3*A_PtrSize,"uint")
		if (stage=1)
			return 0x20 ;sets CDRF_NOTIFYITEMDRAW
		if (stage=0x10001){ ;NM_CUSTOMDRAW && Control is in the list
			index:=numget(Param.2,A_PtrSize=4?9*A_PtrSize:7*A_PtrSize,"uint")
			LV_GetText(text,index+1)
			info:=this.Control[text]
			if info.fore!=""
				NumPut(info.fore,Param.2,A_PtrSize=4?12*A_PtrSize:10*A_PtrSize,"int") ;sets the foreground
			if info.back!=""
				NumPut(info.back,Param.2,A_PtrSize=4?13*A_PtrSize:10.5*A_PtrSize,"int") ;sets the background
		}
	}
}