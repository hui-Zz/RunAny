# 【RA搜索框：快捷使用文本功能列表、后缀应用列表、百度等网址】

## 一.使用方法：
1. 下载安装【RunAny】 https://hui-zz.gitee.io/runany/#/
2. 将【tong_SearchBar.ahk】、【Lib】添加至【RunAny】的【RunPlugins】文件夹，在RunAny中【开启】并设置为【自启】
    Lib文件夹存放的是汉字转拼音功能
3. 打开RunAny.ini或RunAny2.ini文件，添加以下内容，可自定义快捷键，下列是shift+D开启
    `RA搜索栏	+d|RunAny_SearchBar[toggle_searchBar]()`
4. 使用3中快捷键开启

## 二.使用说明：
1. 当候选项当候选项剩下一个时，自动填充 is_auto_fill，可关闭
2. 加号可移动搜索框
3. 双击提示框可执行
4. 有候选项是回车执行第一个
5. 可以选择是否自动为大写，is_auto_CapsLock ，可关闭
6. 自动填充后是否禁用一段时间输入，Edit_stop_time，可选择

## 三.快捷键说明：
1. tab键正序切换功能，右shift逆序切换功能
2. alt快速选择第1个候选项，alt+1、2、3。。。9分别快速选择第1-9对应候选项
3. Delete快速清空
4. 上下键快速选择提示框

## 四.添加功能说明：
1. 【自定义样式】Radio_names中添加对应功能名称
2. 【自定义样式】RA_suffix、RA_menu在Radio_names中的对应位置，如未调整顺序则为默认
3. 【单选框对应功能】中按序号添加对应功能

---

# 【更新说明】
## v1.0.3: 2021年12月
	1. 添加拼音搜索和首字母搜索(基于kazhafeizhale的ChToPy脚本),同时RA菜单项值匹配菜单项名称，不再匹配路径
	2. 不再使用onMessage.ahk

