;****************************
;* 【RunCtrl网络规则函数库】 *
;****************************
global RunAny_Plugins_Version:="1.0.0"
#NoTrayIcon             ;~不显示托盘图标
#Persistent             ;~让脚本持久运行
#SingleInstance,Force   ;~运行替换旧实例
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
#Include %A_ScriptDir%\RunAny_ObjReg.ahk
#Include <JSON>

class RunAnyObj {

	;返回当前外网ip地址
	rule_ip_external(){
		jsonData:=get_ip_api()
		return jsonData.query
	}
	;返回当前ip地址定位的国家名
	rule_ip_country(){
		jsonData:=get_ip_api()
		return jsonData.country
	}
	;返回当前ip地址定位的国家代码
	rule_ip_countryCode(){
		jsonData:=get_ip_api()
		return jsonData.countryCode
	}
	;返回当前ip地址定位的省缩写
	rule_ip_region(){
		jsonData:=get_ip_api()
		return jsonData.region
	}
	;返回当前ip地址定位的省名
	rule_ip_regionName(){
		jsonData:=get_ip_api()
		return jsonData.regionName
	}
	;返回当前ip地址定位的城市名
	rule_ip_city(){
		jsonData:=get_ip_api()
		return jsonData.city
	}
	;返回当前ip地址定位的纬度
	rule_ip_lat(){
		jsonData:=get_ip_api()
		return jsonData.lat
	}
	;返回当前ip地址定位的经度
	rule_ip_lon(){
		jsonData:=get_ip_api()
		return jsonData.lon
	}
	;返回当前ip地址定位的时区
	rule_ip_timezone(){
		jsonData:=get_ip_api()
		return jsonData.timezone
	}
	/*
	验证ip地址的网络运营商
	isp 验证的运营商名，如中国电信：China Telecom、中国移动：China Mobile、中国联通：China United
	*/
	rule_ip_isp(isp=""){
		if(!isp)
			return false
		jsonData:=get_ip_api()
		return InStr(jsonData.isp,isp) ? true : false
	}


;══════════════════════════大括号以上是RunAny菜单调用的函数══════════════════════════

}

;════════════════════════════以下是脚本自己调用依赖的函数════════════════════════════

/*
通过第三方接口获取IP地址等信息 @hui-Zz
query、country、countryCode、regionName、region、city、lat、lon、timezone、isp
外网ip、国家、国家代码、地区、地区代码、城市、纬度、经度、时区、运营商
*/
get_ip_api(){
	if(!IsObject(JSON))
		return false
	;~ 测试网络连接
	lpszUrl:="http://www.ip-api.com"
	network:=DllCall("Wininet.dll\InternetCheckConnection", "Ptr", &lpszUrl, "UInt", 0x1, "UInt", 0x0, "Int")
	if(!network)
		return false
	apiUrl=http://ip-api.com/json
	sendStr:=apiUrl
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", sendStr)
	try {
		whr.Send()
	} catch {
		TrayTip,,验证IP地址异常，可能是网络已断开或接口失效,3,1
	}
	responseStr:= whr.ResponseText
	if(responseStr)
		jsonData:=JSON.Load(responseStr)
	return jsonData
}


;独立使用RunAnyObj菜单内函数方式
; F2::
; 	RunAnyObj.rule_ip_city()
; return