#Warn                        ;~启用每种警告并将它们显示到消息框中。
#NoEnv                       ;~不检查空变量为环境变量
#WinActivateForce            ;~强制激活窗口
#SingleInstance,Force        ;~运行替换旧实例
ListLines,Off                ;~不显示最近执行的脚本行
SendMode,Input               ;~使用更速度和可靠方式发送键鼠点击
SetBatchLines,-1             ;~脚本全速执行(默认10ms)
SetControlDelay,0            ;~控件修改命令自动延时(默认20)
SetTitleMatchMode,2          ;~窗口标题模糊匹配
CoordMode,Menu,Window        ;~坐标相对活动窗口
SetWorkingDir,%A_ScriptDir%  ;~脚本当前工作目录
global OneKeyRegexList:={}
global OneKeyRunList:={}

WinGet, RunAnyPath, ProcessPath, ahk_exe RunAny.exe
SplitPath, RunAnyPath, exeName, exeDir, ext, name_no_ext

RunAnyConfig:=A_ScriptDir "\RunAnyConfig.ini"
if(!FileExist(RunAnyConfig)){
	RunAnyConfig:=exeDir
}
if(!FileExist(RunAnyConfig)){
	Msgbox,16,没有找到RunAny！,请把脚本放入RunAny目录运行 或 在RunAny启动时运行该脚本。
	return
}
;读取旧配置
IniRead,OneKeyVar,%RunAnyConfig%,OneKey
if(!OneKeyVar){
	Msgbox,你没有设置过正则一键直达，直接使用最新版RunAny即可。
	return
}
Loop, parse, OneKeyVar, `n, `r
{
	R_LoopField=%A_LoopField%
	if(R_LoopField="")
		continue
	varList:=StrSplit(R_LoopField,"=",,2)
	if(varList[1]="")
		continue
	itemList:=StrSplit(varList[1],"|",,2)
	OneKeyRunList[itemList[1]]:=itemList[2]
	OneKeyRegexList[itemList[1]]:=varList[2]
}
;保存为新配置格式
IniWrite, delete=1, %RunAnyConfig%, OneKey
IniDelete, %RunAnyConfig%, OneKey, delete
For name, regex in OneKeyRegexList
{
	IniWrite,%regex%,%RunAnyConfig%,OneKey,%name%_Regex
	IniWrite,% OneKeyRunList[name],%RunAnyConfig%,OneKey,%name%_Run
}
if(FileExist(RunAnyPath)){
	Run,%RunAnyPath%
}
Msgbox,转换保存一键直达新配置格式成功！