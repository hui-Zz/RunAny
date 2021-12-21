## 1. 无法获取QQ聊天内容问题解决

使用<kbd>Win</kbd>+<kbd>字母</kbd>热键无法取得QQ聊天窗口内容

**原因**：因为QQ聊天窗口是绘制的特殊窗体，不是Windows系统常见控件，所以目前无法用AHK的<kbd>Win</kbd>+热键去获取其内容

**解决**：换一个其他的比如<kbd>Alt</kbd>+<kbd>字母</kbd>、<kbd>Ctrl</kbd>+<kbd>字母</kbd>、<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>字母</kbd>之类就正常了

---


## 2. RunAny菜单无法消失问题解决

#### Win10 1709版本使用<kbd>Win</kbd>+<kbd>`</kbd>热键显示RunAny菜单后，菜单不消失

**原因**：因为1709系统对<kbd>Win</kbd>+热键的控制，导致出现菜单后需要点一下菜单中的内容才会关闭菜单

**解决**：不升级系统的情况下，更换RunAny的热键，不带有Win键

#### 极少情况下在Win10中安装360安全卫士导致RunAny菜单无法消失

**原因**：目前尚未清楚是360安全卫士哪项设置导致，欢迎告知

**解决**：卸载360安全卫士后菜单恢复正常

---


## 3. 在Total Command，Directory Opus中RunAny没有获取到选中文件

**原因**：因某些不明配置原因，导致在TC、DO中按<kbd>Ctrl</kbd>+<kbd>C</kbd>复制文件速度变慢，没在短时间给RunAny文件信息误判断为无选中文件

**解决**：手动修改RunAny配置`RunAnyConfig.ini`，使用隐藏配置延长等待复制时间：  
**（RunAny5.7.5版本后默认自动会在高级配置中添加此配置，另外在电脑为固态硬盘时可有效减少此情况的发生）**

> 在[Config]下另起一行添加 <br>
> ClipWaitApp（在什么应用界面延长等待复制时间, 多个逗号分隔） <br>
> ClipWaitTime（最长等待复制的时间（2秒）大概在1.5秒以上可以稳定获取到）

```ini
ClipWaitApp=TotalCMD64.exe
ClipWaitTime=1.5
```

---


## 4. ~~开机后RunAny加载慢和RunAny调用Everything缓慢问题~~

鼠标移动到任务栏托盘图标后显示，调用Everything搜索应用全路径时间过长：
![RunAny调用Everything缓慢问题](/assets/images/faq/RunAny调用Everything缓慢问题.png)

**原因**：因Everything正在索引、或是数据库在不同磁盘导致读写缓慢等原因。（可以开机后马上尝试能不能用Everything来验证）

**解决**：
- 在Everything搜索框中搜索“Everything”，查看`Everything.exe`和文件`Everything.db`是否不在同一硬盘  
在Everything窗口最上面菜单的“工具”——“选项”——找到选中左边的“索引”——修改右边的数据库路径到`Everything.exe`同一硬盘，加快读写速度

- 若计算机中文件过多导致的Everything创建索引缓慢，则需要尽量减少Everything设置中的 索引磁盘、文件夹、文件属性等

#### [（使用RunAny v5.7.8 新功能：无路径应用缓存可有效解决）](/change-log?id=✅新增【runany无路径应用缓存机制】)

---

## 5. RunAny热字符串功能失效：由 AutoHotkey 1.1.30 导致

**解决**：
- 使用 AutoHotkey `1.1.28` 老版本  
- 或升级至 AutoHotkey `1.1.31` 及以上版本

---

## 6. Line Text: case "a":out.="`a" Error: This line does not contain a recognized action

**原因**：RunAny 5.7.7及之前的 AutoHotkey 版本为 1.1.28，不支持Switch case语法

**解决**：
- RunAny升级至 `5.7.8` 及以上版本
- 使用AutoHotkey的用户升级AHK至 `1.1.31` 及以上版本

---

## 7. 0x800401F3 - 无效的类字符串 `ComObjCreate("HTMLfile")`
![HTMLfile](/assets/images/faq/HTMLfile.png ':size=577x585')

**原因**：是360安全卫士、电脑管家……等等 启用 **默认浏览器锁定** 开关后 导致  
一旦锁定浏览器，安全卫士就会阻止任何软件去调用浏览器相关的一些功能  
而 `一键计算` 和 `huiZz_Text.ahk` 里面 中文转换为URI编码 等功能是需要依赖 `HTMLfile` 来完成功能的

**解决**：
关闭360安全卫士、电脑管家……等等的 **默认浏览器锁定** 的开关

---

## 8. Could not close the previous instance of this script. Keep waiting?

**原因**：上一个RunAny.ahk仍在后台运行，无法关闭（没有权限关闭）
- 比如：已经使用了`任务计划管理员启动RunAny`，又使用了普通权限 开机启动 或 第三方软件启动`RunAny`
- 同一个`RunAny.ahk`多次启动，会先关闭老的进程再启动新的`RunAny.ahk`
- 但如果老的`RunAny.ahk`是由管理员权限运行，而新的`RunAny.ahk`是普通权限，就会无法关闭，出现此弹窗

**解决**：
- **`RunAny`只保留一处开机启动**
- **`RunAny`多次运行权限一致，都是用管理员权限运行，或都是普通权限运行**

---

## 9. Critical Error:  Invalid memory read/write.

**原因**：往RunAny菜单的空分类中插入菜单项导致错误

**解决**：不要在RunAny菜单中使用空分类，更不要在空分类后面添加`|后缀或软件类名`

---
