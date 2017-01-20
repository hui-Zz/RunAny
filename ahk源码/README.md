# 使用Everything.dll获取程序路径失效

64位系统+64位Everything+某些AHK版本来运行RunAny.ahk可能会获取程序路径失效(编译后的RunAny.exe无此情况)

此时可以尝试修改脚本中的global everyDLL:="Everything64.dll"来正常获取程序路径