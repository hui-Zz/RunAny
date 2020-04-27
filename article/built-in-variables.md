# 【Windows系统环境变量】
| 变量名                   | 变量说明                                                     |
| ------------------------ | ------------------------------------------------------------ |
| %AllUsersProfile%        | 局部 返回所有“用户配置文件”的位置。                          |
| %AppData%                | 局部 返回默认情况下应用程序存储数据的位置。                  |
| %ComputerName%           | 系统 返回计算机的名称。                                      |
| %ComSpec%                | 系统 返回命令行解释器可执行程序的准确路径。                  |
| %HomeDrive%              | 系统 返回连接到用户主目录的本地工作站驱动器号。基于主目录值的设置。用户主目录是在“本地用户和组”中指定的。 |
| %HomePath%               | 系统 返回用户主目录的完整路径。基于主目录值的设置。用户主目录是在“本地用户和组”中指定的。 |
| %Number_Of_Processors%   | 系统 指定安装在计算机上的处理器的数目。                      |
| %OS%                     | 系统 返回操作系统的名称。Windows 2000 将操作系统显示为 Windows_NT。 |
| %Path%                   | 系统 指定可执行文件的搜索路径。                              |
| %PathExt%                | 系统 返回操作系统认为可执行的文件扩展名的列表。              |
| %Processor_Architecture% | 系统 返回处理器的芯片体系结构。值: x86，IA64。               |
| %Processor_Identifier%   | 系统 返回处理器说明。                                        |
| %Processor_Level%        | 系统 返回计算机上安装的处理器的型号。                        |
| %Processor_Revision%     | 系统 返回处理器修订号的系统变量。                            |
| %SystemDrive%            | 系统 返回包含 Windows XP 根目录（即系统根目录）的驱动器。    |
| %SystemRoot%             | 系统 返回 Windows XP 根目录的位置。                          |
| %Temp% 或 %TMP%          | 系统和用户 返回对当前登录用户可用的应用程序所使用的默认临时目录。有些应用程序需要 TEMP，而其它应用程序则需要 TMP。 |
| %UserDomain%             | 局部 返回包含用户帐户的域的名称。                            |
| %UserName%               | 局部 返回当前登录的用户的名称。                              |
| %UserProfile%            | 局部 返回当前用户的配置文件的位置。                          |
| %WinDir%                 | 系统 返回操作系统目录的位置。                                |

--------------------------------------------------------------------------------------------

# 【RunAny变量】

### [特殊字符](https://wyagd001.github.io/zh-cn/docs/Variables.htm#特殊字符)

| A_Space | 此变量包含单个空格字符. 请参阅 [AutoTrim](https://wyagd001.github.io/zh-cn/docs/commands/AutoTrim.htm) 了解详情. |
| ------- | ------------------------------------------------------------ |
| A_Tab   | 此变量包含单个 tab 字符. 请参阅 [AutoTrim](https://wyagd001.github.io/zh-cn/docs/commands/AutoTrim.htm) 了解详情. |

### [脚本属性](https://wyagd001.github.io/zh-cn/docs/Variables.htm#prop)

| 1, 2, 3 等                                                   | 每当启动带命令行参数的脚本时, 会自动创建这些变量. 可以像普通变量一样修改和引用它们(例如: %1%), 但不能在[表达式](https://wyagd001.github.io/zh-cn/docs/Variables.htm#Expressions)中直接引用. 变量 %0% 包含了命令行参数的数目(如果没有则为 0). 需了解详情请参阅[命令行参数](https://wyagd001.github.io/zh-cn/docs/Scripts.htm#cmd). |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| A_Args [[v1.1.27+\]](https://wyagd001.github.io/zh-cn/docs/AHKL_ChangeLog.htm#v1.1.27.00) | **读/写:** 包含一个命令行参数[数组](https://wyagd001.github.io/zh-cn/docs/Objects.htm#Usage_Simple_Arrays). 有关详细信息, 请参阅[向脚本传递命令行参数](https://wyagd001.github.io/zh-cn/docs/Scripts.htm#cmd). |
| A_WorkingDir                                                 | 脚本当前工作目录, 这是脚本访问文件的默认路径. 除非是根目录, 否则路径末尾不包含反斜杠. 两个示例: C:\ 和 C:\My Documents. 使用 [SetWorkingDir](https://wyagd001.github.io/zh-cn/docs/commands/SetWorkingDir.htm) 可以改变当前工作目录. |
| A_ScriptDir                                                  | 当前脚本所在目录的绝对路径. 不包含最后的反斜杠(根目录同样如此). |
| A_ScriptName                                                 | 当前脚本的文件名称, 不含路径, 例如 MyScript.ahk.             |
| A_ScriptFullPath                                             | 当前脚本的完整路径, 例如 C:\My Documents\My Script.ahk       |
| A_ScriptHwnd [[v1.1.01+\]](https://wyagd001.github.io/zh-cn/docs/AHKL_ChangeLog.htm#v1.1.01.00) | 脚本的隐藏[主窗口](https://wyagd001.github.io/zh-cn/docs/Program.htm#main-window)的唯一 ID(HWND/句柄). |
| A_LineNumber                                                 | 当前脚本中正在执行的行所在的行号(或其 [#Include 文件](https://wyagd001.github.io/zh-cn/docs/commands/_Include.htm)的行号). 这个行号与 [ListLines](https://wyagd001.github.io/zh-cn/docs/commands/ListLines.htm) 显示的一致; 它可以用在报告错误的时候, 例如: `MsgBox Could not write to log file (line number %A_LineNumber%)`.<br/><br/>由于[已编译脚本](https://wyagd001.github.io/zh-cn/docs/Scripts.htm#ahk2exe)已经把它所有的 [#Include 文件](https://wyagd001.github.io/zh-cn/docs/commands/_Include.htm)合并成一个大脚本, 所以它的行号可能与它在未编译模式运行时不一样. |
| A_LineFile                                                   | [A_LineNumber](https://wyagd001.github.io/zh-cn/docs/Variables.htm#LineNumber) 所属文件的完整路径和名称, 除非当前行属于未编译脚本的某个 [#Include 文件](https://wyagd001.github.io/zh-cn/docs/commands/_Include.htm), 否则它将和 [A_ScriptFullPath](https://wyagd001.github.io/zh-cn/docs/Variables.htm#ScriptFullPath) 相同. |
| A_ThisFunc [[v1.0.46.16+\]](https://wyagd001.github.io/zh-cn/docs/ChangeLogHelp.htm#v1.0.46.16) | 当前正在执行的[自定义函数](https://wyagd001.github.io/zh-cn/docs/Functions.htm)的名称(没有则为空); 例如: MyFunction. 另请参阅: [IsFunc()](https://wyagd001.github.io/zh-cn/docs/commands/IsFunc.htm) |
| A_ThisLabel [[v1.0.46.16+\]](https://wyagd001.github.io/zh-cn/docs/ChangeLogHelp.htm#v1.0.46.16) | 当前正在执行的[标签](https://wyagd001.github.io/zh-cn/docs/misc/Labels.htm)(子程序) 的名称(没有则为空); 例如: MyLabel. 每当脚本执行 [Gosub](https://wyagd001.github.io/zh-cn/docs/commands/Gosub.htm)/[Return](https://wyagd001.github.io/zh-cn/docs/commands/Return.htm) 或 [Goto](https://wyagd001.github.io/zh-cn/docs/commands/Goto.htm) 时会更新此变量的值. 执行自动调用的标签时也会更新此变量的值, 例如[计时器](https://wyagd001.github.io/zh-cn/docs/commands/SetTimer.htm), [GUI 线程](https://wyagd001.github.io/zh-cn/docs/commands/Gui.htm#DefaultWin), [菜单项](https://wyagd001.github.io/zh-cn/docs/commands/Menu.htm), [热键](https://wyagd001.github.io/zh-cn/docs/Hotkeys.htm), [热字串](https://wyagd001.github.io/zh-cn/docs/Hotstrings.htm), [OnClipboardChange](https://wyagd001.github.io/zh-cn/docs/misc/Clipboard.htm#OnClipboardChange) 和 [OnExit](https://wyagd001.github.io/zh-cn/docs/commands/OnExit.htm). 不过, 当执行从前面的语句"进入"一个标签时不会更新 A_ThisLabel 的值, 即此时它还是保持原来的值. 另请参阅: [A_ThisHotkey](https://wyagd001.github.io/zh-cn/docs/Variables.htm#ThisHotkey) 和 [IsLabel()](https://wyagd001.github.io/zh-cn/docs/commands/IsLabel.htm) |
| A_AhkVersion                                                 | 在 [1.0.22] 之前的版本, 此变量为空. 否则, 它包含了运行当前脚本的 AutoHotkey 主程序的版本号, 例如 1.0.22. 在[已编译脚本](https://wyagd001.github.io/zh-cn/docs/Scripts.htm#ahk2exe)中, 它包含了原来编译时使用的主程序的版本号. 格式化的版本号使得脚本可以使用 > 或 >= 来检查 A_AhkVersion 是否大于某个最小的版本号, 例如: `if A_AhkVersion >= 1.0.25.07`. |
| A_AhkPath                                                    | 对于未编译脚本: 实际运行当前脚本的 EXE 文件的完整路径和名称. 例如: C:\Program Files\AutoHotkey\AutoHotkey.exe <br/>对于[已编译脚本](https://wyagd001.github.io/zh-cn/docs/Scripts.htm#ahk2exe): 除了通过注册表条目 *HKLM\SOFTWARE\AutoHotkey\InstallDir* 获取 AutoHotkey 目录外, 其他的和上面相同. 如果找不到这个注册表条目, 则 A_AhkPath 为空. |
| A_IsUnicode                                                  | 当字符串为 Unicode(16 位) 时值为 1, 字符串为 ANSI(8 位) 时为空字符串(这会被视为 [false](https://wyagd001.github.io/zh-cn/docs/Variables.htm#Boolean)). 字符串的格式取决于用来运行当前脚本的 AutoHotkey.exe, 如果为已编译脚本, 则取决于用来编译它的主程序.<br/><br/>对于 [[v1.1.06\]](https://wyagd001.github.io/zh-cn/docs/AHKL_ChangeLog.htm#v1.1.06.00) 之前的 ANSI 可执行文件, A_IsUnicode 没有定义; 也就是说, 脚本可以给它赋值, 并且尝试读取它可能会触发 [UseUnsetGlobal 警告](https://wyagd001.github.io/zh-cn/docs/commands/_Warn.htm). 在以后的版本中, 它始终是定义的并且是只读的. |
| A_IsCompiled                                                 | 如果当前运行的脚本为[已编译的 EXE ](https://wyagd001.github.io/zh-cn/docs/Scripts.htm#ahk2exe)时, 此变量值为 1, 否则为空字符串(这会被视为 [false](https://wyagd001.github.io/zh-cn/docs/Variables.htm#Boolean)).<br/><br/>对于 [[v1.1.06\]](https://wyagd001.github.io/zh-cn/docs/AHKL_ChangeLog.htm#v1.1.06.00) 之前的未编译脚本, A_IsCompiled 没有定义; 也就是说, 脚本可以给它赋值, 并且尝试读取它可能会触发 [UseUnsetGlobal 警告](https://wyagd001.github.io/zh-cn/docs/commands/_Warn.htm). 在以后的版本中, 它始终是定义的并且是只读的. |
| A_ExitReason                                                 | 最近一次要求脚本终止的原因. 除非脚本含有 [OnExit](https://wyagd001.github.io/zh-cn/docs/commands/OnExit.htm) 子程序并且此子程序当前正在运行或被退出尝试至少调用过一次, 否则此变量为空. 请参阅 [OnExit](https://wyagd001.github.io/zh-cn/docs/commands/OnExit.htm) 了解详情. |

### [日期和时间](https://wyagd001.github.io/zh-cn/docs/Variables.htm#date)

| A_YYYY      | 4 位数表示的当前年份(例如 2004). 与 A_Year 含义相同.<br/><br/>**注意:** 要获取符合您区域设置和语言的格式化时间或日期, 请使用 `FormatTime, OutputVar`(时间和长日期) 或 `FormatTime, OutputVar,, LongDate`(获取长格式日期). |
| ----------- | ------------------------------------------------------------ |
| A_MM        | 2 位数表示的当前月份(01-12). 与 A_Mon 含义相同.              |
| A_DD        | 2 位数表示的当前月份的日期(01-31). 与 A_MDay 含义相同.       |
| A_MMMM      | 使用当前用户语言表示的当前月份的全称, 例如 July              |
| A_MMM       | 使用当前用户语言表示的当前月份的简称, 例如 Jul               |
| A_DDDD      | 使用当前用户语言表示的当前星期几的全称, 例如 Sunday          |
| A_DDD       | 使用当前用户语言表示的当前星期几的简称, 例如 Sun             |
| A_WDay      | 1 位数表示的当前星期经过的天数(1-7). 在所有区域设置中 1 都表示星期天. |
| A_YDay      | 当前年份中经过的天数(1-366). 不会使用零对变量的值进行填充, 例如会获取到 9, 而不是 009. 要对变量的值进行零填充, 请使用: `FormatTime, OutputVar, , YDay0`. |
| A_YWeek     | 符合 ISO 8601 标准的当前的年份和周数(例如 200453). 要分离年份和周数, 请使用 `Year := SubStr(A_YWeek, 1, 4)` 和 `Week := SubStr(A_YWeek, -1)`. A_YWeek 的准确定义为: 如果含有 1 月 1 日的星期有四天以上在新年里, 则它被认为是新年的第一个星期. 否则, 它为前一年的最后一个星期, 而下一星期为新年的第一星期. |
| A_Hour      | 在 24 小时制(例如, 17 表示 5pm) 中 2 位数表示的当前小时数(00-23). 要获取带 AM/PM 提示的 12 小时制的时间, 请参照此例: `FormatTime, OutputVar, , h:mm:ss tt` |
| A_Min       | 2 位数表示的当前分钟数(00-59).                               |
| A_Sec       | 2 位数表示的当前秒数(00-59).                                 |
| A_MSec      | 3 位数表示的当前毫秒数(000-999). 要移除前导零, 请参照此例: `Milliseconds := A_MSec + 0`. |
| A_Now       | [YYYYMMDDHH24MISS](https://wyagd001.github.io/zh-cn/docs/commands/FileSetTime.htm#YYYYMMDD) 格式的当前本地时间.<br/><br/>**注意**: 使用 [EnvAdd](https://wyagd001.github.io/zh-cn/docs/commands/EnvAdd.htm) 和 [EnvSub](https://wyagd001.github.io/zh-cn/docs/commands/EnvSub.htm) 可以对日期和时间进行计算. 此外, 使用 [FormatTime](https://wyagd001.github.io/zh-cn/docs/commands/FormatTime.htm) 可以根据您的区域设置或选项来格式化日期和/或时间. |
| A_NowUTC    | [YYYYMMDDHH24MISS](https://wyagd001.github.io/zh-cn/docs/commands/FileSetTime.htm#YYYYMMDD) 格式的当前的协调世界时(UTC). UTC 本质上和格林威治标准时间(GMT) 一致. |
| A_TickCount | 计算机启动后经过的毫秒数, 最多为 49.7 天. 通过把 A_TickCount 保存到变量中, 经过一段时间后从最近的 A_TickCount 值中减去那个变量, 可以计算出所经过的时间. 如果您需要比 A_TickCount 的 10ms 更高的精确度, 请使用 [QueryPerformanceCounter()](https://wyagd001.github.io/zh-cn/docs/commands/DllCall.htm#QPC)(高精度计时器). |

### [脚本设置](https://wyagd001.github.io/zh-cn/docs/Variables.htm#settings)

| A_IsSuspended                                                | 当脚本[挂起时](https://wyagd001.github.io/zh-cn/docs/commands/Suspend.htm)值为 1, 否则为 0. |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| A_IsPaused [[v1.0.48+\]](https://wyagd001.github.io/zh-cn/docs/ChangeLogHelp.htm#v1.0.48.00) | 当紧随当前线程的[线程](https://wyagd001.github.io/zh-cn/docs/misc/Threads.htm)被[暂停](https://wyagd001.github.io/zh-cn/docs/commands/Pause.htm)时值为 1. 否则为 0. |
| A_IsCritical [[v1.0.48+\]](https://wyagd001.github.io/zh-cn/docs/ChangeLogHelp.htm#v1.0.48.00) | [当前线程](https://wyagd001.github.io/zh-cn/docs/misc/Threads.htm)的 [Critical](https://wyagd001.github.io/zh-cn/docs/commands/Critical.htm) 设置关闭时值为 0. 否则它包含大于零的整数, 即 Critical 使用的[消息检查频率](https://wyagd001.github.io/zh-cn/docs/commands/Critical.htm#Interval). 因为 `Critical 0` 关闭了当前线程的关键性, 所以 Critical 的当前状态可以这样来保存和恢复: `Old_IsCritical := A_IsCritical`, 后来执行 `Critical %Old_IsCritical%`. |
| A_BatchLines                                                 | (同义于 A_NumBatchLines) 由 [SetBatchLines](https://wyagd001.github.io/zh-cn/docs/commands/SetBatchLines.htm) 设置的当前值. 例如: 200 或 10ms(取决于格式). |
| A_ListLines [[v1.1.28+\]](https://wyagd001.github.io/zh-cn/docs/AHKL_ChangeLog.htm#v1.1.28.00) | [ListLines](https://wyagd001.github.io/zh-cn/docs/commands/ListLines.htm) 激活时值为 1. 否则为 0. |
| A_TitleMatchMode                                             | 由 [SetTitleMatchMode](https://wyagd001.github.io/zh-cn/docs/commands/SetTitleMatchMode.htm) 设置的当前模式: 1, 2, 3 或 RegEx. |
| A_TitleMatchModeSpeed                                        | 由 [SetTitleMatchMode](https://wyagd001.github.io/zh-cn/docs/commands/SetTitleMatchMode.htm) 设置的当前匹配速度(fast 或 slow). |
| A_DetectHiddenWindows                                        | 由 [DetectHiddenWindows](https://wyagd001.github.io/zh-cn/docs/commands/DetectHiddenWindows.htm) 设置的当前模式(On 或 Off). |
| A_DetectHiddenText                                           | 由 [DetectHiddenText](https://wyagd001.github.io/zh-cn/docs/commands/DetectHiddenText.htm) 设置的当前模式(On 或 Off). |
| A_AutoTrim                                                   | 由 [AutoTrim](https://wyagd001.github.io/zh-cn/docs/commands/AutoTrim.htm) 设置的当前模式(On 或 Off). |
| A_StringCaseSense                                            | 由 [StringCaseSense](https://wyagd001.github.io/zh-cn/docs/commands/StringCaseSense.htm) 设置的当前模式(On, Off 或 Locale). |
| A_FileEncoding                                               | [[v1.0.90+\]](https://wyagd001.github.io/zh-cn/docs/AHKL_ChangeLog.htm#L46): 包含了多个命令使用的默认编码; 请参阅 [FileEncoding](https://wyagd001.github.io/zh-cn/docs/commands/FileEncoding.htm). |
| A_FormatInteger                                              | 由 [SetFormat](https://wyagd001.github.io/zh-cn/docs/commands/SetFormat.htm) 设置的当前整数格式(H 或 D). [[v1.0.90+\]:](https://wyagd001.github.io/zh-cn/docs/AHKL_ChangeLog.htm#L42) 此变量还可能为小写字母 h. |
| A_FormatFloat                                                | 由 [SetFormat](https://wyagd001.github.io/zh-cn/docs/commands/SetFormat.htm) 设置的当前浮点数格式. |
| A_SendMode                                                   | [[v1.1.23+\]:](https://wyagd001.github.io/zh-cn/docs/AHKL_ChangeLog.htm#v1.1.23.00) 由 [SendMode](https://wyagd001.github.io/zh-cn/docs/commands/SendMode.htm) 设置的当前模式字符串(可能的值为: Event, Input, Play 或 InputThenPlay). |
| A_SendLevel                                                  | [[v1.1.23+\]:](https://wyagd001.github.io/zh-cn/docs/AHKL_ChangeLog.htm#v1.1.23.00) 当前 [SendLevel](https://wyagd001.github.io/zh-cn/docs/commands/SendLevel.htm) 的设置(可能的值为: 0 到 100 之间的整数, 包括 0 和 100). |
| A_StoreCapsLockMode                                          | [[v1.1.23+\]:](https://wyagd001.github.io/zh-cn/docs/AHKL_ChangeLog.htm#v1.1.23.00) 由 [SetStoreCapsLockMode](https://wyagd001.github.io/zh-cn/docs/commands/SetStoreCapslockMode.htm) 设置的当前模式字符串(可能的值为: On 或 Off). |
| A_KeyDelay A_KeyDuration                                     | 由 [SetKeyDelay](https://wyagd001.github.io/zh-cn/docs/commands/SetKeyDelay.htm) 设置的当前延迟(总是十进制数, 不是十六进制). A_KeyDuration 依赖 [[v1.1.23+\]](https://wyagd001.github.io/zh-cn/docs/AHKL_ChangeLog.htm#v1.1.23.00) . |
| A_KeyDelayPlay A_KeyDurationPlay                             | 表示由 [SetKeyDelay](https://wyagd001.github.io/zh-cn/docs/commands/SetKeyDelay.htm) 设置 [SendPlay](https://wyagd001.github.io/zh-cn/docs/commands/Send.htm#SendPlayDetail) 模式的延迟或持续时间(总是十进制数, 不是十六进制). 依赖 [[v1.1.23+\]](https://wyagd001.github.io/zh-cn/docs/AHKL_ChangeLog.htm#v1.1.23.00). |
| A_WinDelay                                                   | 由 [SetWinDelay](https://wyagd001.github.io/zh-cn/docs/commands/SetWinDelay.htm) 设置的当前延迟(总是十进制数, 不是十六进制). |
| A_ControlDelay                                               | 由 [SetControlDelay](https://wyagd001.github.io/zh-cn/docs/commands/SetControlDelay.htm) 设置的当前延迟(总是十进制数, 不是十六进制). |
| A_MouseDelay A_MouseDelayPlay                                | 由 [SetMouseDelay](https://wyagd001.github.io/zh-cn/docs/commands/SetMouseDelay.htm) 设置的当前延迟(总是十进制数, 不是十六进制). A_MouseDelay 表示传统的 SendEvent 模式, 而 A_MouseDelayPlay 则表示 [SendPlay](https://wyagd001.github.io/zh-cn/docs/commands/Send.htm#SendPlayDetail). A_MouseDelayPlay 依赖 [[v1.1.23+\]](https://wyagd001.github.io/zh-cn/docs/AHKL_ChangeLog.htm#v1.1.23.00). |
| A_DefaultMouseSpeed                                          | 由 [SetDefaultMouseSpeed](https://wyagd001.github.io/zh-cn/docs/commands/SetDefaultMouseSpeed.htm) 设置的当前速度(总是十进制数, 不是十六进制). |
| A_CoordModeToolTip A_CoordModePixel A_CoordModeMouse A_CoordModeCaret A_CoordModeMenu | [[v1.1.23+\]:](https://wyagd001.github.io/zh-cn/docs/AHKL_ChangeLog.htm#v1.1.23.00) [CoordMode](https://wyagd001.github.io/zh-cn/docs/commands/CoordMode.htm) 的当前设置值的字符串. (可能的值为: Window, Client 或 Screen) |
| A_RegView                                                    | [[v1.1.08+\]:](https://wyagd001.github.io/zh-cn/docs/AHKL_ChangeLog.htm#v1.1.08.00) 由 [SetRegView](https://wyagd001.github.io/zh-cn/docs/commands/SetRegView.htm) 设置的当前注册表视图. |
| A_IconHidden                                                 | [托盘图标](https://wyagd001.github.io/zh-cn/docs/Program.htm#tray-icon)当前隐藏时值为 1, 否则为 0. 此图标可以使用 [#NoTrayIcon](https://wyagd001.github.io/zh-cn/docs/commands/_NoTrayIcon.htm) 或 [Menu](https://wyagd001.github.io/zh-cn/docs/commands/Menu.htm) 命令进行隐藏. |
| A_IconTip                                                    | 如果使用 `Menu, Tray, Tip` 为[托盘图标](https://wyagd001.github.io/zh-cn/docs/Program.htm#tray-icon)指定了自定义的工具提示时, 变量的值为这个提示的文本, 否则为空. |
| A_IconFile                                                   | 如果使用 `Menu, tray, icon` 指定了自定义的[托盘图标](https://wyagd001.github.io/zh-cn/docs/Program.htm#tray-icon)时, 变量的值为图标文件的完整路径和名称, 否则为空. |
| A_IconNumber                                                 | 当 A_IconFile 为空时此变量为空. 否则, 它的值为 A_IconFile 中的图标编号(通常为 1). |

### [用户空闲时间](https://wyagd001.github.io/zh-cn/docs/Variables.htm#用户空闲时间)

| A_TimeIdle                                                   | 从系统最后一次接收到键盘, 鼠标或其他输入后所经过的毫秒数. 这可以用来判断用户是否离开. 用户的物理输入和由 **任何** 程序或脚本生成的模拟输入(例如 [Send](https://wyagd001.github.io/zh-cn/docs/commands/Send.htm) 或 [MouseMove](https://wyagd001.github.io/zh-cn/docs/commands/MouseMove.htm) 命令)会让此变量重置为零. 由于此变量的值趋向于以 10 的增量增加, 所以不应该判断它是否等于另一个值. 相反, 应该检查此变量是否大于或小于另一个值. 例如: `IfGreater, A_TimeIdle, 600000, MsgBox, The last keyboard or mouse activity was at least 10 minutes ago`. |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| A_TimeIdlePhysical                                           | 与上面类似, 但在安装了相应的钩子([键盘](https://wyagd001.github.io/zh-cn/docs/commands/_InstallKeybdHook.htm)或[鼠标](https://wyagd001.github.io/zh-cn/docs/commands/_InstallMouseHook.htm)) 后会忽略模拟的键击和/或鼠标点击; 即此变量仅反应物理事件. (这样避免了由于模拟键击和鼠标点击而误以为用户存在.) 如果两种钩子都没有安装, 则此变量等同于 A_TimeIdle. 如果仅安装了一种钩子, 那么仅此类型的物理输入才会对 A_TimeIdlePhysical 起作用(另一种/未安装钩子的输入, 包括物理的和模拟的, 都会被忽略). |
| A_TimeIdleKeyboard [[v1.1.28+\]](https://wyagd001.github.io/zh-cn/docs/AHKL_ChangeLog.htm#v1.1.28.00) | 如果安装了[键盘钩子](https://wyagd001.github.io/zh-cn/docs/commands/_InstallKeybdHook.htm), 这是自系统上次接收物理键盘输入以来所经过的毫秒数. 否则, 这个变量就等于 A_TimeIdle. |
| A_TimeIdleMouse [[v1.1.28+\]](https://wyagd001.github.io/zh-cn/docs/AHKL_ChangeLog.htm#v1.1.28.00) | 如果安装了[鼠标钩子](https://wyagd001.github.io/zh-cn/docs/commands/_InstallMouseHook.htm), 这是自系统上次收到物理鼠标输入以来所经过的毫秒数. 否则, 这个变量就等于 A_TimeIdle. |

### [操作系统和用户信息](https://wyagd001.github.io/zh-cn/docs/Variables.htm#os)

| ComSpec [[v1.0.43.08+\]](https://wyagd001.github.io/zh-cn/docs/ChangeLogHelp.htm#Older_Changes) A_ComSpec [[v1.1.28+\]](https://wyagd001.github.io/zh-cn/docs/AHKL_ChangeLog.htm#v1.1.28.00) | 此变量的值与系统环境变量 ComSpec 一样. 常与 [Run/RunWait](https://wyagd001.github.io/zh-cn/docs/commands/Run.htm) 一起使用. 例如:`C:\Windows\system32\cmd.exe` |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| A_Temp [[v1.0.43.09+\]](https://wyagd001.github.io/zh-cn/docs/ChangeLogHelp.htm#Older_Changes) | 存放临时文件的文件夹的完整路径和名称. 它的值从下列的其中一个位置获取(按顺序): 1) [环境变量](https://wyagd001.github.io/zh-cn/docs/Concepts.htm#environment-variables) TMP, TEMP 或 USERPROFILE; 2) Windows 目录. 例如:`C:\Users\系统用户名\AppData\Local\Temp` |
| A_OSType                                                     | 正在运行的操作系统类型. 由于 AutoHotkey 1.1 仅支持基于 NT 的操作系统, 所以此变量总是为 WIN32_NT. 旧版本的 AutoHotkey 运行在 Windows 95/98/ME 时会返回 WIN32_WINDOWS. |
| A_OSVersion                                                  | 下列字符串中的一个(如果存在): WIN_7 [[需要 v1.0.90+\]](https://wyagd001.github.io/zh-cn/docs/AHKL_ChangeLog.htm#L42), WIN_8 [[需要 v1.1.08+\]](https://wyagd001.github.io/zh-cn/docs/AHKL_ChangeLog.htm#v1.1.08.00), WIN_8.1 [[需要 v1.1.15+\]](https://wyagd001.github.io/zh-cn/docs/AHKL_ChangeLog.htm#v1.1.15.00), WIN_VISTA, WIN_2003, WIN_XP, WIN_2000.在 AutoHotKey 的可执行文件或编译后的脚本属性里应用兼容性设置会让操作系统报告不同的版本号, 该版本号由 A_OSVersion 反映.[[v1.1.20+\]:](https://wyagd001.github.io/zh-cn/docs/AHKL_ChangeLog.htm#v1.1.20.00) 如果系统版本没有被识别成上述版本, 会返回一个"major.minor.build"形式的字符串. 例如, `10.0.14393` 为 Windows 10 build 14393, 也称为 1607 版. |
| A_Is64bitOS                                                  | [[v1.1.08+\]:](https://wyagd001.github.io/zh-cn/docs/AHKL_ChangeLog.htm#v1.1.08.00) 当操作系统为 64 位则值为 1(真), 为 32 位则为 0(假). |
| A_PtrSize                                                    | [[v1.0.90+\]:](https://wyagd001.github.io/zh-cn/docs/AHKL_ChangeLog.htm#L42) 包含指针的大小值, 单位为字节. 值为 4(32 位) 或 8(64 位), 取决于运行当前脚本的执行程序的类型. |
| A_Language                                                   | 当前系统的默认语言, 值为[这些 4 位数字编码](https://wyagd001.github.io/zh-cn/docs/misc/Languages.htm)的其中一个. |
| A_ComputerName                                               | 在网络上看到的计算机名称.                                    |
| A_UserName                                                   | 运行当前脚本的用户的登录名.                                  |
| A_WinDir                                                     | Windows 目录. 例如: `C:\Windows`                             |
| A_ProgramFiles 或 ProgramFiles                               | Program Files 目录(例如 `C:\Program Files` 或者 `C:\Program Files (x86)`). 一般来说和 *ProgramFiles* [环境变量](https://wyagd001.github.io/zh-cn/docs/Concepts.htm#environment-variables)一样.<br/><br/>在 [64 位系统](https://wyagd001.github.io/zh-cn/docs/Variables.htm#Is64bitOS)(非 32 位系统) 上适用:<br/>● 如果可执行文件(EXE) 以 32 位脚本运行的时候, A_ProgramFiles 返回路径为 "Program Files (x86)" 目录<br/>● 对于 32 位的进程, *ProgramW6432* 环境变量指向 64 位 Program Files 目录. 在 Windows 7 和更高版本上, 对于 64 位的进程也是这样设置的<br/>● 而 *ProgramFiles(x86)* 环境变量指向 32 位 Program Files 目录.[1.0.43.08+]: 前缀 A_ 可以省略, 这样有助于自然过渡到 [#NoEnv](https://wyagd001.github.io/zh-cn/docs/commands/_NoEnv.htm). |
| A_AppData [[v1.0.43.09+\]](https://wyagd001.github.io/zh-cn/docs/ChangeLogHelp.htm#Older_Changes) | 当前用户的应用程序数据文件夹的完整路径和名称. 例如:`C:\Users\系统用户名\Application Data` |
| A_AppDataCommon [[v1.0.43.09+\]](https://wyagd001.github.io/zh-cn/docs/ChangeLogHelp.htm#Older_Changes) | 所有用户的应用程序数据文件夹的完整路径和名称. 例如:`C:\ProgramData` |
| A_Desktop                                                    | 当前用户的桌面文件夹的完整路径和名称. 例如:`C:\Users\系统用户名\Desktop` |
| A_DesktopCommon                                              | 所有用户的桌面文件夹的完整路径和名称. 例如:`C:\Users\Public\Desktop` |
| A_StartMenu                                                  | 当前用户的开始菜单文件夹的完整路径和名称. 例如:`C:\Users\系统用户名\AppData\Roaming\Microsoft\Windows\Start Menu` |
| A_StartMenuCommon                                            | 所有用户的开始菜单文件夹的完整路径和名称. 例如:`C:\ProgramData\Microsoft\Windows\Start Menu` |
| A_Programs                                                   | 当前用户的开始菜单中程序文件夹的完整路径和名称. 例如:`C:\Users\系统用户名\AppData\Roaming\Microsoft\Windows\Start Menu\Programs` |
| A_ProgramsCommon                                             | 所有用户的开始菜单中程序文件夹的完整路径和名称. 例如:`C:\ProgramData\Microsoft\Windows\Start Menu\Programs` |
| A_Startup                                                    | 当前用户的开始菜单中启动文件夹的完整路径和名称. 例如:`C:\Users\系统用户名\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup` |
| A_StartupCommon                                              | 所有用户的开始菜单中启动文件夹的完整路径和名称. 例如:`C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup` |
| A_MyDocuments                                                | 当前用户 "我的文档" 文件夹的完整路径和名称. 与大多数类似变量不同, 当此文件夹为驱动器的根目录时, 此变量的值不包含最后的反斜杠(例如, 它的值是 `M:` 而不是 `M:\`). 例如:`C:\Users\系统用户名\Documents` |
| A_IsAdmin                                                    | 如果当前用户有管理员权限, 则此变量的值为 1. 否则为 0.要使脚本以管理员权限重新启动(或显示提示向用户请求管理员权限), 请使用 [Run *RunAs](https://wyagd001.github.io/zh-cn/docs/commands/Run.htm#RunAs). 但是请注意, 以管理员权限运行脚本会导致脚本启动的所有程序也以管理员权限运行. 对于可能的替代方案, 请参阅[常见问题(FAQ)](https://wyagd001.github.io/zh-cn/docs/FAQ.htm#uac). |
| A_ScreenWidth A_ScreenHeight                                 | 主监视器的宽度和高度, 单位为像素(例如 1024 和 768).要获取多显示器系统中其他显示器的尺寸, 请使用 [SysGet](https://wyagd001.github.io/zh-cn/docs/commands/SysGet.htm).要获取整个桌面(即使它横跨多个显示器)的宽度和高度, 请使用下面的例子:`SysGet, VirtualWidth, 78 SysGet, VirtualHeight, 79 `此外, 使用 [SysGet](https://wyagd001.github.io/zh-cn/docs/commands/SysGet.htm) 可以获取显示器的工作区域, 它比显示器的整个区域小, 因为它不包括任务栏和其他注册的桌面工具栏. |
| A_ScreenDPI [[v1.1.11+\]](https://wyagd001.github.io/zh-cn/docs/AHKL_ChangeLog.htm#v1.1.11.00) | 在屏幕宽度上每逻辑英寸的像素数. 在多显示器的系统中, 这个值对于所有的显示器都是一样的. 在大多数系统中该值为 96; 它取决于系统文本大小(DPI) 设置. 另请参阅 [Gui -DPIScale](https://wyagd001.github.io/zh-cn/docs/commands/Gui.htm#DPIScale). |
| A_IPAddress1 到 4                                            | 计算机中前 4 个网卡的 IP 地址.                               |

### [杂项](https://wyagd001.github.io/zh-cn/docs/Variables.htm#杂项)

| A_Cursor          | 当前显示的鼠标光标类型. 其值为下列单词的其中一个: AppStarting(程序启动, 后台运行--箭头+等待), Arrow(箭头, 正常选择--标准光标), Cross(十字, 精确选择), Help(帮助, 帮助选择--箭头+问号), IBeam(工字光标, 文本选择--输入), Icon, No(No, 不可用--圆圈加反斜杠), Size, SizeAll(所有尺寸,移动--四向箭头), SizeNESW(东南和西北尺寸, 沿对角线调整 2--双箭头指向东南和西北), SizeNS(南北尺寸, 垂直调整--双箭头指向南北), SizeNWSE(西北和东南尺寸, 沿对角线调整 1--双箭头指向西北和东南), SizeWE(东西尺寸, 水平调整--双箭头指向东西), UpArrow(向上箭头, 候选--指向上的箭头), Wait(等待, 忙--沙漏或圆圈), Unknown(未知). 与 size 指针类型一起的首字母表示方向, 例如 NESW = NorthEast(东北)+SouthWest(西南). 手型指针(点击和抓取) 属于 Unknown 类别. |
| ----------------- | ------------------------------------------------------------ |
| A_CaretX A_CaretY | 当前光标(文本插入点) 的 X 和 Y 坐标. 如果没有使用 [CoordMode](https://wyagd001.github.io/zh-cn/docs/commands/CoordMode.htm) 使得坐标相对于整个屏幕, 默认坐标相对于活动窗口. 如果没有活动窗口或无法确定文本插入点的位置, 则这两个变量为空.下面这个脚本可以让您在四处移动文本插入点时, 查看显示在自动更新工具提示上的当前位置. 注意在某些窗口(例如某些版本的 MS Word) 会不管文本插入点的实际位置如何都报告同样的位置.`#Persistent SetTimer, WatchCaret, 100 return WatchCaret:  ToolTip, X%A_CaretX% Y%A_CaretY%, A_CaretX, A_CaretY - 20 return ` |
| Clipboard         | **可读取/写入:** 操作系统剪贴板的内容, 可以从中读取或写入内容. 请参阅[剪贴板](https://wyagd001.github.io/zh-cn/docs/misc/Clipboard.htm)章节. |
| ClipboardAll      | **可读取/写入:** 剪贴板中的完整内容(包含格式和文本). 请参阅 [ClipboardAll](https://wyagd001.github.io/zh-cn/docs/misc/Clipboard.htm#ClipboardAll). |
| ErrorLevel        | **可读取/写入:** 请参阅 [ErrorLevel](https://wyagd001.github.io/zh-cn/docs/misc/ErrorLevel.htm). |
| A_LastError       | 操作系统 GetLastError() 函数或最近 COM 对象调用返回的结果. 要了解详情, 请参阅 [DllCall()](https://wyagd001.github.io/zh-cn/docs/commands/DllCall.htm#LastError) 和 [Run/RunWait](https://wyagd001.github.io/zh-cn/docs/commands/Run.htm#LastError). |
| True <br/> False        | 包含 1 和 0. 它们可以用来使脚本更具可读性. 有关详细信息, 请参阅[布尔值](https://wyagd001.github.io/zh-cn/docs/Concepts.htm#boolean). |