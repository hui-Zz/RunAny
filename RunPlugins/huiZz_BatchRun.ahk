;****************************
;* 【ObjReg批量自定义运行】 *
;****************************
global RunAny_Plugins_Version:="1.1.1"
#NoTrayIcon             ;~不显示托盘图标
#Persistent             ;~让脚本持久运行
#SingleInstance,Force   ;~运行替换旧实例
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
#Include %A_ScriptDir%\RunAny_ObjReg.ahk

class RunAnyObj {
	;[批量自定义运行]
	;保存到RunAny.ini为：批量运行|huiZz_BatchRun[batch_run](%getZz%)
	batch_run(getZz){
		;在这里添加你要批量运行或搜索的东西 %getZz%：选中的文本或文件
		;Run,D:\Users\OneDrive\Apps\Zz\TotalCMD64\Tools\Everything.exe -search "%getZz%"
		Run,https://www.baidu.com/s?wd=%getZz%
		Run,https://www.google.com/search?q=%getZz%&gws_rd=ssl
	}
	;[多软件打开选中多文件]
	;保存到RunAny.ini为：多软件打开|huiZz_BatchRun[multi_open](%getZz%,"notepad.exe","wordpad.exe")
	;多软件无路径打开|huiZz_BatchRun[multi_open](%getZz%,%"notepad2.exe"%,%"sublime_text.exe"%)
	multi_open(getZz,programs*){
		Loop, parse, getZz, `n, `r
		{
			S_LoopField=%A_LoopField%
			if(S_LoopField=""){
				continue
			}
			for i,p in programs
			{
				Run,%p% "%S_LoopField%"
			}
		}
	}

;══════════════════════════大括号以上是RunAny菜单调用的函数══════════════════════════

}

;════════════════════════════以下是脚本自己调用依赖的函数════════════════════════════

;独立使用方式
;F1::
	;RunAnyObj.batch_run("参数")
;return