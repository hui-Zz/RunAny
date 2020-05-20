![RunAny_huiZz_Text变量命名功能](/assets/images/RunAny_huiZz_Text变量命名功能.gif)

# 独立运行插件脚本
| 插件文件            | 插件分类       | 插件功能                 |
| ------------------- | -------------- | ------------------------ |
| huiZz_MButton.ahk   | 独立功能插件   | 鼠标中键任意位置拖拽窗口 |
| huiZz_RestTime.ahk  | 独立功能插件   | 定时提醒休息时间         |
| RunAny_Menu.ahk     | RunAny辅助插件 | 透明化RunAny菜单主体     |
| huiZz_InputEnCn.ahk | 独立功能插件   | 自定义程序自动中英输入法  |

# ObjReg插件脚本嵌入RunAny菜单
以下ObjReg插件需要先下载RunAny_ObjReg.ahk，注册到RunAny之后实现功能

| 插件文件           | 插件功能                     |
| ------------------ | ---------------------------- |
| [huiZz_Window.ahk](/plugins-list?id=huizz_window窗口操作脚本窗口函数ini)   | ObjReg窗口操作脚本           |
| [huizz_System.ahk](/plugins-list?id=huizz_system系统操作脚本系统函数ini)   | ObjReg系统操作脚本           |
| [huizz_Text.ahk](/plugins-list?id=huizz_text文本操作脚本文本函数ini)     | ObjReg文本操作脚本           |
| [huiZz_QRCode.ahk](/plugins-list?id=huizz_qrcode二维码脚本)   | ObjReg二维码脚本{}           |
| huiZz_BatchRun.ahk | ObjReg批量自定义运行         |
| huiZz_Work.ahk     | ObjReg工作相关脚本           |

---

## huiZz_Window窗口操作脚本[窗口函数.ini]

| 脚本内函数名           | RunAny菜单实现功能                     |
| ---------------------- | -------------------------------------- |
| win_center_zz          | 窗口居中                               |
| win_size_zz            | 窗口按指定分辨率或屏幕百分比例改变大小 |
| win_move_size_zz       | 窗口改变大小并移动                     |
| win_top_zz             | 窗口置顶、取消置顶                     |
| win_movie_zz           | 窗口移至边角置顶观影                   |
| win_transparent_top_zz | 窗口置顶时透明，第二次还原             |
| win_transparency_zz    | 按量透明、不透明                       |
| win_max_zz             | 窗口最大化并隐藏标题栏，第二次还原     |
| win_close_zz           | 当前窗口关闭                           |
| win_kill_zz            | 当前窗口进程结束                       |
| win_folder_zz          | 打开当前窗口进程所在目录               |

## huiZz_System系统操作脚本[系统函数.ini]

| 脚本内函数名           | RunAny菜单实现功能                             |
| ---------------------- | ---------------------------------------------- |
| system_hidefile_zz     | 显示或不显示 系统文件和隐藏文件                |
| system_regedit_zz      | 根据选中注册表路径，直接打开注册表定位         |
| system_ip_zz           | 获取本地IP地址显示并放入剪贴板或输出           |
| system_ping_zz         | Ping选中的IP地址                              |
| system_explorer_zz     | 重启桌面进程                                  |
| system_file_path_zz    | 复制选中文件路径、名称、后缀、快捷方式指向路径 |
| system_create_shortcut | 创建快捷方式到桌面                             |
| system_sound_volume    | 控制系统音量增减                               |
| system_runas_zz        | 管理员权限运行选中目标                         |

## huiZz_Text文本操作脚本[文本函数.ini]

| 脚本内函数名       | 函数功能               |
| ------------------ | ---------------------- |
| text_merge_zz      | 文本多行合并           |
| text_replace_zz    | 文本替换               |
| text_format_zz     | 文本格式化             |
| text_format_md_zz  | Markdown格式化         |
| text_var_name_zz   | 变量命名               |
| text_sort_zz       | 文本排序               |
| text_magnet_zz     | 便捷运行磁力链接       |
| text_edit_zz       | 选中文字编辑           |
| text_compare_zz    | 选中文本比较剪贴板     |
| text_seq_num_zz    | 批量添加序号           |
| text_remove_repeat | 文本删除重复行保留顺序 |
| text_cn2_zz        | 中文数字互转           |
| text_encode_zz     | 文本编码转换           |
| encrypt、decrypt   | 文本加密解密           |
| google_translate   | 文本谷歌翻译           |

## huiZz_Text文本操作脚本实现功能

| Markdown                     | 变量命名                   | 替换               | 排序                 | 其它               |
| ---------------------------- | -------------------------- | ------------------ | -------------------- | ------------------ |
| 标题# ##                     | 1骆驼命名                  | 去除空格           | 排序不区分大小写     | 选中文字编辑       |
| \*\*加粗\*\*                 | 2帕斯卡命名                | 多行合并空格分隔   | 排序区分大小写       | 选中文本比较剪贴板 |
| \*斜体\*                     | 3下划线命名                | 多行合并逗号分隔   | 排序数字             | 便捷运行磁力链接   |
| \`代码行\`                   | 4横杠命名                  | 替换逗号为空格     | 排序逆向             | 便捷替换粘贴       |
| \<u\>下划线\</u\>            | 5常量命名                  | 替换逗号为换行     | 排序随机             | uri转中文          |
| \~\~删除线\~\~               | 6包名命名                  | 替换空格为换行     | 排序路径最后文件名   | 中文转uri          |
| \>引用                       | 7空格命名                  | 替换分号为换行     | 排序去重不区分大小写 | unicode转中文      |
| 无序列表\*+-                 | 8网络路径命名              | 删除重复行保留顺序 | 排序去重区分大小写   | 中文转unicode      |
| 待办列表-[]、完成列表-[x]    | 9文件路径命名              |                    | 排序逗号分隔         | 文本加密解密       |
| 数字序号、中文序号           | 转大写、转小写、首字母大写 |                    | 排序空格分隔         | 文本谷歌翻译       |
| 序号转中文数字、转阿拉伯数字 | 转整数、两位小数           |                    |                      |                    |

## huiZz_QRCode二维码脚本

| 脚本内函数名 | RunAny菜单实现功能 |
| ------------ | ------------------ |
| qr_code      | 二维码生成         |


