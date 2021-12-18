;****************************
;* 【汉字转拼音】 *
;作者：kazhafeizhale
;地址：https://gitee.com/kazhafeizhale/py
/*示例
    msgbox,% "自动化脚本: " ChToPy.allspell_muti("逍遥模拟器")
    msgbox,% "自动化脚本: " ChToPy.initials_muti("逍遥模拟器")
    ;非多音接口
    msgbox,% "自动化脚本: " ChToPy.allspell("逍遥模拟器")
    msgbox,% "自动化脚本: " ChToPy.initials("逍遥模拟器")
*/
;****************************
class ChToPy {
    static LOG4AHK_G_MY_DLL_USE_MAP := {"cpp2ahk.dll" : {"chinese_convert_pinyin_initials" : 0, "chinese_convert_pinyin_allspell" : 0,"chinese_convert_pinyin_allspell_muti" : 0, "chinese_convert_pinyin_initials_muti" : 0}, "is_load" : 0}
    static is_dll_load := false
    static _ := this.log4ahk_load_all_dll_path()
    log4ahk_load_all_dll_path()
    {
        local
        SplitPath,A_LineFile,,dir
        path := ""
        lib_path := dir
        if(A_IsCompiled)
        {
            path := A_PtrSize == 4 ? A_ScriptDir . "\lib\ChToPy_dll_32\" : A_ScriptDir . "\lib\ChToPy_dll_64\"
            lib_path := A_ScriptDir . "\lib"
        }
        else
        {
            path := (A_PtrSize == 4) ? dir . "\ChToPy_dll_32\" : dir . "\ChToPy_dll_64\"
        }
        dllcall("SetDllDirectory", "Str", path)
        for k,v in this.LOG4AHK_G_MY_DLL_USE_MAP
        {
            for k1, v1 in v 
            {
                this.LOG4AHK_G_MY_DLL_USE_MAP[k][k1] := DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", k, "Ptr"), "AStr", k1, "Ptr")
            }
        }
        this.is_dll_load := true
    }
    allspell(in_str)
    {
        if(this.is_dll_load == false)
        {
            this.log4ahk_load_all_dll_path()
        }
        out_str := ""
        VarSetCapacity(out_str,0)
        VarSetCapacity(out_str,4000)

        py_StrPutVar(in_str, buf, "CP0")
        rtn := DllCall(this.LOG4AHK_G_MY_DLL_USE_MAP["cpp2ahk.dll"]["chinese_convert_pinyin_allspell"],"Str", buf, "Str", out_str,"Cdecl Int")
        rtn := StrGet(&out_str, 4000,"UTF-8")
        return rtn
    }
    allspell_muti(in_str)
    {
        if(this.is_dll_load == false)
        {
            this.log4ahk_load_all_dll_path()
        }
        out_str := ""
        VarSetCapacity(out_str,0)
        VarSetCapacity(out_str,4000)

        py_StrPutVar(in_str, buf, "UTF-16")
        rtn := DllCall(this.LOG4AHK_G_MY_DLL_USE_MAP["cpp2ahk.dll"]["chinese_convert_pinyin_allspell_muti"],"Str", buf, "Str", out_str,"Cdecl Int")
        rtn := StrGet(&out_str, 4000,"UTF-8")
        return rtn
    }
    initials_muti(in_str)
    {
        if(this.is_dll_load == false)
        {
            this.log4ahk_load_all_dll_path()
        }
        out_str := ""
        VarSetCapacity(out_str,0)
        VarSetCapacity(out_str,4000)

        py_StrPutVar(in_str, buf, "UTF-16")
        rtn := DllCall(this.LOG4AHK_G_MY_DLL_USE_MAP["cpp2ahk.dll"]["chinese_convert_pinyin_initials_muti"],"Str", buf, "Str", out_str,"Cdecl Int")
        rtn := StrGet(&out_str, 4000,"UTF-8")
        return rtn
    }
    initials(in_str)
    {
        if(this.is_dll_load == false)
        {
            this.log4ahk_load_all_dll_path()
        }
        out_str := ""
        VarSetCapacity(out_str,0)
        VarSetCapacity(out_str,4000)

        py_StrPutVar(in_str, buf, "CP0")
        rtn := DllCall(this.LOG4AHK_G_MY_DLL_USE_MAP["cpp2ahk.dll"]["chinese_convert_pinyin_initials"],"Str", buf, "Str", out_str,"Cdecl Int")
        rtn := StrGet(&out_str, 4000,"UTF-8")
        return rtn
    }
}

py_StrPutVar(string, ByRef var, encoding)
{
    ; 确定容量.
    VarSetCapacity( var, StrPut(string, encoding)
        ; StrPut 返回字符数, 但 VarSetCapacity 需要字节数.
        * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) )
    ; 复制或转换字符串.
    return StrPut(string, &var, encoding)
}