;***************************
;* 【ObjReg二维码脚本{}】  *
;*               by hui-Zz *
;***************************
global RunAny_Plugins_Version:="1.1.1"
#NoTrayIcon             ;~不显示托盘图标
#Persistent             ;~让脚本持久运行
#SingleInstance,Force   ;~运行替换旧实例
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
#Include %A_ScriptDir%\..\RunAny_ObjReg.ahk

class RunAnyObj {
	;[二维码生成]
	;参数说明：getZz：选中的文本内容
	;在RunAny.ini中使用：二维码生成|huiZz_QRCode[qr_code](%getZz%)
	qr_code(getZz){
		global
		if(StrLen(getZz) < 200){
			picHeight:=400
		}else if(StrLen(getZz) <= 600){
			picHeight:=StrLen(getZz) + 200
		}else if(StrLen(getZz) > 600){
			picHeight:=A_ScreenHeight-50
		}
		guiWH:=picHeight+20
		GUI,pic:Destroy
		GUI,pic:Add,Picture,w-1 h%picHeight% hwndhimage gSaveAs,% f:=GEN_QR_CODE(getZz)
		GUI,pic:Show,w%guiWH% h%guiWH%,点击保存图片 Esc关闭
		return
		SaveAs:
		  Fileselectfile,nf,s16,,另存为,PNG图片(*.png)
		  If not strlen(nf)
			return
		  nf := RegExMatch(nf,"i)\.png") ? nf : nf ".png"
		  FileMove,%f%,%nf%,1
		return
		PICGUIEscape:
		PICGUIClose:
		  GUI,pic:Destroy
		return
	}

;══════════════════════════大括号以上是RunAny菜单调用的函数══════════════════════════

}

;════════════════════════════以下是脚本自己调用依赖的函数════════════════════════════

GEN_QR_CODE(string,file="")
{
	sFile := strlen(file) ? file : A_Temp "\" A_NowUTC ".png"
	DllCall( A_ScriptDir "\quricol" A_PtrSize * 8 ".dll\GeneratePNG","str", sFile , "str", string, "int", 4, "int", 2, "int", 0)
	Return sFile
}

;独立使用方式
;F1::
	;RunAnyObj.qr_code("【ObjReg二维码脚本】")
;return