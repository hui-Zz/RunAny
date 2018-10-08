/*
【RunAny函数注册工具】
*/
global RunAny_Plugins_Version:="1.0.0"
global RunAny_ObjReg:="RunAny_ObjReg.ini" ;~插件注册配置文件
global objreg:="objreg"
SplitPath, A_ScriptFullPath, name,, ext,nameNotExt
;~[生成插件脚本GUID]
if(!FileExist(RunAny_ObjReg)){
	FileAppend,[%objreg%],%RunAny_ObjReg%
}
IniRead,objGUID,%RunAny_ObjReg%,%objreg%,%nameNotExt%,%A_Space%
if(!objGUID){
	objGUID:=CreateGUID()
	IniWrite,%objGUID%,%RunAny_ObjReg%,%objreg%,%nameNotExt%
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