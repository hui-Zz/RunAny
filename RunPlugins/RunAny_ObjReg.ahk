/*
【ObjReg插件对象注册工具（不用自启）】
*/
global RunAny_Plugins_Version:="1.0.4"
SplitPath, A_LineFile,,RunAny_ObjReg_Dir
global RunAny_ObjReg:=RunAny_ObjReg_Dir "\RunAny_ObjReg.ini" ;~插件注册配置文件
global objreg:="objreg"
SetTitleMatchMode,2         ;~窗口标题模糊匹配
DetectHiddenWindows,On      ;~显示隐藏窗口
SplitPath, A_ScriptFullPath, name,, ext,nameNotExt
;~[生成插件脚本GUID]
if(!FileExist(RunAny_ObjReg)){
	FileAppend,[%objreg%],%RunAny_ObjReg%
}
IniRead,objGUID,%RunAny_ObjReg%,%objreg%,%nameNotExt%,%A_Space%
if(!objGUID && nameNotExt!="RunAny_ObjReg"){
	objGUID:=CreateGUID()
	IniWrite,%objGUID%,%RunAny_ObjReg%,%objreg%,%nameNotExt%
    Process,Exist,RunAny.exe
	if ErrorLevel
	{
        WinGet, RunAnyPath, ProcessPath, ahk_exe RunAny.exe
        RunAny_Send_WM_COPYDATA("Menu_Reload","RunAny.ahk ahk_class AutoHotkey")
    }
    IfWinExist, RunAny.ahk ahk_class AutoHotkey
    {
        PostMessage, 0x111, 65400,,, RunAny.ahk ahk_class AutoHotkey
    }
}
if(IsObject(RunAnyObj)){
	ObjRegisterActive(RunAnyObj, objGUID)
}

;[注册脚本对象]
ObjRegisterActive(Object, CLSID, Flags:=0) {
    static cookieJar := {}
    if (!CLSID) {
        if (cookie := cookieJar.Remove(Object)) != ""
            DllCall("oleaut32\RevokeActiveObject", "uint", cookie, "ptr", 0)
        return
    }
    if cookieJar[Object]
        throw Exception("Object is already registered", -1)
    VarSetCapacity(_clsid, 16, 0)
    if (hr := DllCall("ole32\CLSIDFromString", "wstr", CLSID, "ptr", &_clsid)) < 0
        throw Exception("Invalid CLSID", -1, CLSID)
    hr := DllCall("oleaut32\RegisterActiveObject"
        , "ptr", &Object, "ptr", &_clsid, "uint", Flags, "uint*", cookie
        , "uint")
    if hr < 0
        throw Exception(format("Error 0x{:x}", hr), -1)
    cookieJar[Object] := cookie
}
;[生成GUID]
CreateGUID()
{
    VarSetCapacity(pguid, 16, 0)
    if !(DllCall("ole32.dll\CoCreateGuid", "ptr", &pguid)) {
        size := VarSetCapacity(sguid, (38 << !!A_IsUnicode) + 1, 0)
        if (DllCall("ole32.dll\StringFromGUID2", "ptr", &pguid, "ptr", &sguid, "int", size))
            return StrGet(&sguid)
    }
    return ""
}
;[AHK脚本间传递消息]
RunAny_Send_WM_COPYDATA(ByRef StringToSend, ByRef TargetScriptTitle)
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