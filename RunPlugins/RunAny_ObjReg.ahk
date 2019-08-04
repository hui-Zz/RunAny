/*
【ObjReg插件对象注册工具（不用自启）】
*/
global RunAny_Plugins_Version:="1.0.2"
global RunAny_ObjReg:=A_ScriptDir "\RunAny_ObjReg.ini" ;~插件注册配置文件
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
        Run,%A_ScriptDir%\..\RunAny.exe
    }
    IfWinExist, RunAny.ahk ahk_class AutoHotkey
    {
        PostMessage, 0x111, 65405,,, RunAny.ahk ahk_class AutoHotkey
        Sleep,200
        Run,%A_ScriptDir%\..\RunAny.ahk
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