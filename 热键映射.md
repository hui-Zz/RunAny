## 热键映射

**有了RunAny左键右鼠不是梦，左边有大量未使用快捷组合键，利用好这些键，左手再也不用移到键盘的右边😁**

![RunAny短语和热键映射功能](/assets/images/RunAny短语和热键映射功能.gif)

映射空闲的组合键转变为常用键功能，如：

- 映射 左手的<kbd>Shift</kbd>+`空格键`<kbd>Space</kbd>  转变成 => `回车键`<kbd>Enter</kbd> 的功能
- 映射 左手的<kbd>Shift</kbd>+`大小写键`<kbd>CapsLock</kbd>  转变成 => `删除键`<kbd>Delete</kbd> 的功能

> RunAny.ini文件写入
<PRE>
左手回车&#9<+Space|{Enter}::
左手删除&#9LShift & CapsLock|{Delete}::
退格删除&#9CapsLock & Tab|{BackSpace}::
激活上个标签&#9LCtrl & CapsLock|^+{Tab}::
</PRE>

> `<`代表左边 `>`代表右边
> 
> 前面加`L`也代表左边 前面加`R`也代表右边
> 
> `^`代表Ctrl键 `!`代表Alt键 `#`代表Win键 `+`代表Shift键
> 
> `{Enter}`回车键 `{CapsLock}`是大小写键 `{BackSpace}`是退格键 `{Space}`是空格键 `{Tab}`是制表符键
> 
> `{Down}`方向下键 `{Up}`方向上键 `{Left}`方向左键 `{Right}`方向右键

?> 了解更多AHK热键文档：https://wyagd001.github.io/zh-cn/docs/Hotkeys.htm

## Vim映射模式，左Alt键辅助方案

<PRE>
--vim
&#9方向↓&#9&#60;!j|{Down}::
&#9方向↑&#9&#60;!k|{Up}::
&#9方向←&#9&#60;!h|{Left}::
&#9方向→&#9&#60;!l|{Right}::
&#9跳转左边单词&#9&#60;!n|^{Left}::
&#9跳转右边单词&#9&#60;!m|^{Right}::
&#9跳转行首&#9&#60;!,|{Home}::
&#9跳转行末&#9&#60;!.|{End}::
&#9跳转顶部&#9&#60;!i|^{Home}::
&#9跳转底部&#9&#60;!u|^{End}::
&#9---
&#9向↓选中&#9&#60;!+j|+{Down}::
&#9向↑选中&#9&#60;!+k|+{Up}::
&#9向←选中&#9&#60;!+h|+{Left}::
&#9向→选中&#9&#60;!+l|+{Right}::
&#9跳转选中左边单词&#9&#60;!+n|^+{Left}::
&#9跳转选中右边单词&#9&#60;!+m|^+{Right}::
&#9跳转选中到行首&#9&#60;!+,|+{Home}::
&#9跳转选中到行末&#9&#60;!+.|+{End}::
&#9跳转选中到顶部&#9&#60;!+i|^+{Home}::
&#9跳转选中到底部&#9&#60;!+u|^+{End}::
</PRE>