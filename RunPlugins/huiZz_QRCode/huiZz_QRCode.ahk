;***************************
;* 【ObjReg二维码脚本{}】  *
;*               by hui-Zz *
;***************************
global RunAny_Plugins_Version:="1.0.0"
#NoTrayIcon             ;~不显示托盘图标
#Persistent             ;~让脚本持久运行
#SingleInstance,Force   ;~运行替换旧实例
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
#Include %A_ScriptDir%\..\RunAny_ObjReg.ahk

class RunAnyObj {
	;[二维码生成]
	;参数说明：getZz：选中的文本内容
	qr_code(getZz){
		global
		GUI,pic:Destroy
		GUI,pic:Add,Picture,w400 h-1 hwndhimage gSaveAs,% f:=this.GEN_QR_CODE(getZz)
		GUI,pic:Show,w420 h420,点击保存图片 Esc关闭
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
	GEN_QR_CODE(string,file="")
	{
	  sFile := strlen(file) ? file : A_Temp "\" A_NowUTC ".png"
	  DllCall( A_ScriptDir "\quricol" A_PtrSize * 8 ".dll\GeneratePNG","str", sFile , "str", string, "int", 4, "int", 2, "int", 0)
	  Return sFile
	}
}

;独立使用方式
;F1::
	;RunAnyObj.qr_code("【ObjReg二维码脚本】")
;return