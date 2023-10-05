## 逍遥扩展XiaoYao_plus.ahk

**【功能说明：文件分类、解散文件夹、批量新建文件夹、解压缩功能、ImageMagick功能，ffmpeg功能等，以及可以直接在runany.ini中使用更多的变量】**

**【使用说明：】**
1. 右键RunAny图标“插件管理”，下载插件XiaoYao_plus.ahk和RunAny_ObjReg.ahk
2. 下载后在插件管理点击“自启”按钮设置XiaoYao_plus.ahk为自动启动
3. 复制以下执行项写入RunAny.ini文件保存，然后重启RunAny后打开菜单即可使用
4. ↓ 点击下面展开，复制需要的功能写入RunAny.ini文件

!> **【注意：以下部分功能需要调用第三方软件，请确保你电脑存在所使用功能的第三方软件】**

<details>
<summary>实用功能【点此展开】</summary>

```ini
-实用功能
	;【将当前选中的文件夹下及其子文件夹下所有文件移动到其对应的父目录，并删除原目录（当这个文件夹为空了才会删除）】
	解散文件夹|XiaoYao_plus[RA_plus](%getZz%,,7)
	文件/文件夹批量新建|XiaoYao_plus[Batch_file1]()
	;文件分类功能说明：取文件扩展名创建文件夹，并将文件移入对应文件夹内。
	文件分类|XiaoYao_plus[RA_plus](%getZz%,,14)
	--
	隐藏/显示桌面图标|XiaoYao_plus[HideOrShowDesktop]()
	隐藏/显示任务栏|XiaoYao_plus[ToggleTaskbar]()	
	;生成随机密码功能说明：kind:类型 W大写 w小写 d数字 可以组合 length:长度
	生成随机密码|XiaoYao_plus[RandomPass2]("Wwd",8)
	--
	文字竖排|XiaoYao_plus[Texttest1](%getZz%)
	文字反转|XiaoYao_plus[ReverseString1](%getZz%)
	删除一整行|XiaoYao_plus[RA_plus](%getZz%,,8)
	复制一整行|XiaoYao_plus[RA_plus](%getZz%,,9)
	--
	;当前打开的文档/文件，利用ev快速定位其所在路径
	定位文档路径|XiaoYao_plus[locationpath](%"Everything.exe"%)
	框中文字全选后搜索|XiaoYao_plus[RA_plus](,,1)
	--
	;【托盘悬浮到鼠标位置】
	托盘悬浮|XiaoYao_plus[TaskbarTray2]()
	--
	;将选中文字保存为文本文件[可指定保存路径]，自动抓取选中文字的前面5个字符作为文件名。	
	;选中文字保存txt|XiaoYao_plus[Storetext](%getZz%,"填编辑器路径",填保存路径)	
	选中文字保存txt并编辑|XiaoYao_plus[Storetext](%getZz%,%"notepad.exe"%,%A_Desktop%)	
	--移动到
	;选中单个或多个文件/文件夹移动到目标路径
	;移动到|XiaoYao_plus[movefile1](%getZz%,填目标路径)
	移动到D盘下载|XiaoYao_plus[movefile1](%getZz%,D:\下载)
	移动到桌面|XiaoYao_plus[movefile1](%getZz%,%A_Desktop%)
	移动到文档|XiaoYao_plus[movefile1](%getZz%,%A_MyDocuments%)
	--复制到
	;选中单个或多个文件/文件夹复制到目标路径
	;复制到|XiaoYao_plus[copyfile1](%getZz%,填目标路径)
	复制到D盘下载|XiaoYao_plus[copyfile1](%getZz%,D:\下载)
	复制到桌面|XiaoYao_plus[copyfile1](%getZz%,%A_Desktop%)
	复制到文档|XiaoYao_plus[copyfile1](%getZz%,%A_MyDocuments%)
	--只复制文件夹骨架
	;功能说明：只复制文件夹内部层级结构而不复制文件夹内的文件。注意：仅支持选中文件夹，可多选
	;示例：复制文件夹骨架到|XiaoYao_plus[copyfile2](%getZz%,填目标路径)
	复制文件夹骨架到D盘下载|XiaoYao_plus[copyfile2](%getZz%,D:\下载)
	复制文件夹骨架到桌面|XiaoYao_plus[copyfile2](%getZz%,%A_Desktop%)
	复制文件夹骨架到文档|XiaoYao_plus[copyfile2](%getZz%,%A_MyDocuments%)

```

</details>
<br>
<details>
<summary>ffmpeg功能【点此展开】</summary>

```ini

-ffmpeg功能
	;【官网下载：https://www.gyan.dev/ffmpeg/builds/，或者去群文件下载单文件ffmpeg.exe】
	;注意：如果发现以下功能不可用，请用everything检查你本地电脑是否存在多个ffmpeg.exe，出现定位错误的问题，或者你可以直接填绝对路径
	;填绝对路径示例：视频格式转换|XiaoYao_plus[ffmpeg](%getZz%,"D:\软件\ffmpeg\ffmpeg.exe",填转换后的视频格式,1)
	;功能1示例：视频格式转换|XiaoYao_plus[ffmpeg](%getZz%,%"ffmpeg.exe"%,填转换后的视频格式,1)
	转mp4|XiaoYao_plus[ffmpeg](%getZz%,%"ffmpeg.exe"%,mp4,1)
	转mkv|XiaoYao_plus[ffmpeg](%getZz%,%"ffmpeg.exe"%,mkv,1)	
	转avi|XiaoYao_plus[ffmpeg](%getZz%,%"ffmpeg.exe"%,avi,1)
	转flv|XiaoYao_plus[ffmpeg](%getZz%,%"ffmpeg.exe"%,flv,1)
	--
	;功能2示例：音频文件音量调整|XiaoYao_plus[ffmpeg](%getZz%,%"ffmpeg.exe"%,填dB值,2)	通常可以将音频的增益范围设置在-60dB到60dB之间
	;注意：仅支持音频文件
	增大15db音量|XiaoYao_plus[ffmpeg](%getZz%,%"ffmpeg.exe"%,15dB,2)
	增大30db音量|XiaoYao_plus[ffmpeg](%getZz%,%"ffmpeg.exe"%,30dB,2)
	减少15db音量|XiaoYao_plus[ffmpeg](%getZz%,%"ffmpeg.exe"%,-15dB,2)
	减少30db音量|XiaoYao_plus[ffmpeg](%getZz%,%"ffmpeg.exe"%,-30dB,2)	
	--
	;功能3示例：音频格式转换|XiaoYao_plus[ffmpeg](%getZz%,%"ffmpeg.exe"%,填转换后的音频格式,3)
	转mp3|XiaoYao_plus[ffmpeg](%getZz%,%"ffmpeg.exe"%,mp3,3)
	转flac|XiaoYao_plus[ffmpeg](%getZz%,%"ffmpeg.exe"%,flac,3)	
	转AAC|XiaoYao_plus[ffmpeg](%getZz%,%"ffmpeg.exe"%,aac,3)
	转WAV|XiaoYao_plus[ffmpeg](%getZz%,%"ffmpeg.exe"%,wav,3)
	--
	;功能4示例：提取视频所有音轨音频
	;注意：最多只能提取到4条音轨，再多的话需要修改插件，或者使用专业的视频编辑软件
	提取视频所有音轨|XiaoYao_plus[ffmpeg](%getZz%,%"ffmpeg.exe"%,,4)
	只提取视频[无声]|XiaoYao_plus[ffmpeg](%getZz%,%"ffmpeg.exe"%,,7)
	;功能5示例：提取视频所有字幕
	;注意：最多只能提取到10条字幕，再多的话需要修改插件，或者使用专业的视频编辑软件
	提取视频所有字幕|XiaoYao_plus[ffmpeg](%getZz%,%"ffmpeg.exe"%,,5)
	--
	转gif|XiaoYao_plus[ffmpeg](%getZz%,%"ffmpeg.exe"%,gif,3)
	视频压缩|XiaoYao_plus[ffmpeg](%getZz%,%"ffmpeg.exe"%,,6)
	视频音频合并|XiaoYao_plus[ffmpeg](%getZz%,%"ffmpeg.exe"%,,8)
	;视频格式转换[重编码]|XiaoYao_plus[RA_plus2](%getZz%,%"ffmpeg.exe"%,-i $1 $2,$1=#path#|$2=#dir#\#nameNoExt#_转换.填转换后的视频格式)
	转mp4[重编码]|XiaoYao_plus[RA_plus2](%getZz%,%"ffmpeg.exe"%,-i $1 $2,$1=#path#|$2=#dir#\#nameNoExt#_转换.mp4)

```

</details>
<br>
<details>
<summary>ImageMagick功能【点此展开】</summary>

```ini

-ImageMagick功能
	;【官网：https://imagemagick.org/script/download.php#windows】
	;功能1示例：图片转格式|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,填转换后的图片格式,1)
	图片转jpg|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,jpg,1)
	图片转png|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,png,1)
	图片转webp|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,webp,1)
	png转ico|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,ico,1)
	--
	;功能2示例：图片体积压缩|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,填压缩比例数值,2) 
	图片体积压缩75%|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,75,2)
	图片体积压缩100%|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,100,2)
	;功能示例：无损缩放|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,填缩放比例,3) 
	无损放大到200%|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,200%,8)
	无损缩小到50%|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,50%,8)
	--
	;功能3示例：图片旋转|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,填需要旋转的角度,3) 
	图片旋转90度|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,90,3) 
	图片旋转180度|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,180,3)
	图片旋转270度|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,270,3)
	;功能示例：图片旋转|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,填旋转的方向,3) 
	水平镜像翻转|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,-flop,13) 
	垂直镜像翻转|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,-flip,13)
	--
	;功能4示例：拼接图片
	垂直拼接[弹框版]|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,,10) 
	水平拼接[弹框版]|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,,11) 
	高级拼接[弹框版]|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,,18)
	--
	;注意：在执行这些命令之前，请确保剪贴板中包含有效的图片，剪贴板中的内容不是一张图片，或者剪贴板为空，上述命令可能会失败。
	;功能5示例：剪贴板图片保存|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,填保存路径,5) 
	剪贴板图片保存[桌面]|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,%A_Desktop%,5) 
	剪贴板图片保存[下载]|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,D:\下载,5) 
	--
	;功能6示例：高级拼接|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,填拼接格式,6) 
	高级拼接5x5|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,5x5,6) 
	高级拼接3x1|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,3x1,6) 
	高级拼接2x5|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,2x5,6) 
	--
	;功能7示例：生成缩略图|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,填缩略图比例,7) 
	生成缩略图200x200|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,200x200,7) 
	生成缩略图100x100|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,200x200,7) 
	--
	尺寸调整[弹框版]|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,,12)
	;功能8示例：调整图片尺寸|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,填图片尺寸比例,8)
	尺寸800x600|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,800x600,8)
	;你也可以根据需要只指定一个维度，另一个维度将会按照相应的比例进行调整。例如，如果你只想指定宽度为800像素，而高度则按比例自动调整
	尺寸800x|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,800x,8)
	;同样地，你也可以只指定高度，而宽度则按比例自动调整。
	尺寸x600|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,x600,8)
	;如果希望强制将图像拉伸到指定尺寸，可以在尺寸参数后添加感叹号（!）
	尺寸800x600!|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,800x600!,8)
	--
	图片生成GIF|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,500,17) 
	图片生成pdf|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,,15) 
	--
	透明转白色背景jpg|XiaoYao_plus[ImageMagick](%getZz%,%"magick.exe"%,jpg,9)
	裁剪空白部分|XiaoYao_plus[RA_plus2](%getZz%,%"magick.exe"%,convert $1 -trim $2,$1=#path#|$2=#dir#\#nameNoExt#_-trim.#ext#)
	删除exif信息|XiaoYao_plus[RA_plus2](%getZz%,%"magick.exe"%,convert $1 -strip $2,$1=#path#|$2=#dir#\#nameNoExt#_-strip.#ext#) 
	变黑白|XiaoYao_plus[RA_plus2](%getZz%,%"magick.exe"%,convert -monochrome $1 $2,$1=#path#|$2=#dir#\#nameNoExt#_black.#ext#) 
	黑白图像|XiaoYao_plus[RA_plus2](%getZz%,%"magick.exe"%,convert $1 -type grayscale $2,$1=#path#|$2=#dir#\#nameNoExt#_black.#ext#)
	50%二值化处理|XiaoYao_plus[RA_plus2](%getZz%,%"magick.exe"%,convert $1 -threshold 50% $2,$1=#path#|$2=#dir#\#nameNoExt#_threshold.#ext#)
	--
	;加边框示例：convert -mattecolor "#000000" -frame 30x30 yourname.jpg rememberyou.png
	;其中，"#000000"是边框的颜色，边框的大小为30x30
	加边框|XiaoYao_plus[RA_plus2](%getZz%,%"magick.exe"%,convert -mattecolor "#000000" -frame 30x30  $1 $2,$1=#path#|$2=#dir#\#nameNoExt#_边框.#ext#)
	;生成分辨率为 340x313 像素的图片，并在缺失的部分使用白色背景填充
	生成固定尺寸图|XiaoYao_plus[RA_plus2](%getZz%,%"magick.exe"%,convert $1 -resize 340x313 -background white -gravity center -extent 340x313 $2,$1=#path#|$2=#dir#\#nameNoExt#_固定尺寸.#ext#)
	;在图片的下方(south)插入一个高度为 27 像素的空白区域（splice），最后在这个空白区域内以黑色文本显示指定的文本内容; 图片下方是(north)
	加文件名称水印|XiaoYao_plus[RA_plus2](%getZz%,%"magick.exe"%,convert $1 -background white -fill black -pointsize 20 -gravity south -splice 0x27 -annotate +0+5 "$3" $2,$1=#path#|$2=#dir#\#nameNoExt#_-文字水印.#ext#|$3=#nameNoExt#)
	剪贴板图片替换选中文件|XiaoYao_plus[RA_plus2](%getZz%,%"magick.exe"%,clipboard: $1,$1=#path#)

```

</details>
<br>
<details>
<summary>cpdf功能【点此展开】</summary>

```ini

-cpdf功能
	;【官网：https://www.coherentpdf.com/】
	合并所选PDF|XiaoYao_plus[RA_plus2](%getZz%,%"cpdf.exe"%,-merge -remove-duplicate-fonts $1 -o $2,$1=#path#|$2=#dir#\合并_%A_YYYY%%A_MM%%A_DD%_%A_Hour%%A_Min%%A_Sec%.pdf,1)
	以文件名为书签合并所选PDF|XiaoYao_plus[RA_plus2](%getZz%,%"cpdf.exe"%,-merge $1 -remove-duplicate-fonts -merge-add-bookmarks -o $2,$1=#path#|$2=#dir#\文件名标签_%A_YYYY%%A_MM%%A_DD%_%A_Hour%%A_Min%%A_Sec%.pdf,1)
	以元标题为书签合并所选PDF|XiaoYao_plus[RA_plus2](%getZz%,%"cpdf.exe"%,-merge $1 -remove-duplicate-fonts -merge-add-bookmarks -merge-add-bookmarks-use-titles -o $2,$1=#path#|$2=#dir#\元标题标签_%A_YYYY%%A_MM%%A_DD%_%A_Hour%%A_Min%%A_Sec%.pdf,1)
	--
	PDF页面缩放到纵向A4|XiaoYao_plus[RA_plus2](%getZz%,%"cpdf.exe"%,-scale-to-fit a4portrait $1 -scale-to-fit-scale 1 -o $2,$1=#path#|$2=#dir#\#nameNoExt#_纵向A4.pdf)
	PDF页面缩放到横向A4|XiaoYao_plus[RA_plus2](%getZz%,%"cpdf.exe"%,-scale-to-fit a4landscape $1 -scale-to-fit-scale 1 -o $2,$1=#path#|$2=#dir#\#nameNoExt#_横向A4.pdf)
	PDF旋转90度|XiaoYao_plus[RA_plus2](%getZz%,%"cpdf.exe"%,-rotate-contents 90 $1 -o $2,$1=#path#|$2=#dir#\#nameNoExt#_旋转90.pdf)
	--
	按页拆分PDF|XiaoYao_plus[RA_plus2](%getZz%,%"cpdf.exe"%,$1 -split -o $2,$1=#path#|$2=#dir#\#nameNoExt#_页拆分%%%.pdf)
	;按书签拆分PDF，将拆分后的每个文件，文件名为书签标签
	按书签拆分PDF|XiaoYao_plus[RA_plus2](%getZz%,%"cpdf.exe"%,-split-bookmarks 0 $1 -utf8 -o $2,$1=#path#|$2=#dir#\@B.pdf)
	;拆分偶数页，并设置每隔多少页生成一个文件
	只拆分偶数页|XiaoYao_plus[RA_plus2Box](%getZz%,%"cpdf.exe"%,$1 even AND -split -chunk $3 -o $2,$1=#path#|$2=#dir#\#nameNoExt#_偶数页%%%.pdf,请设置每隔多少页生成一个文件,$3)
	只拆分奇数页|XiaoYao_plus[RA_plus2Box](%getZz%,%"cpdf.exe"%,$1 odd AND -split -chunk $3 -o $2,$1=#path#|$2=#dir#\#nameNoExt#_奇数页%%%.pdf,请设置每隔多少页生成一个文件,$3)
	每隔多少页拆分|XiaoYao_plus[RA_plus2Box](%getZz%,%"cpdf.exe"%,-split $1 -o $2 -chunk $3,$1=#path#|$2=#dir#\#nameNoExt#_%%%.pdf,请设置每隔多少页生成一个文件,$3)
	;示例：提取第5页，弹框里填 5
	;提取第2到第5页，弹框里填 2-5；
	;提取第1页、第5页、第7页，就用“,”隔开，弹框里填 1,5,7 
	只提取第几页|XiaoYao_plus[RA_plus2Box](%getZz%,%"cpdf.exe"%,$1 $3 -o $2,$1=#path#|$2=#dir#\#nameNoExt#_特定拆分.pdf,请设置要提取第几页内容,$3)
	--
	PDF添加页码|XiaoYao_plus[RA_plus2](%getZz%,%"cpdf.exe"%,-add-text " %Page /%EndPage" -top 100pt -font "Times-Roman" -font-size 20 $1 -o $2,$1=#path#|$2=#dir#\#nameNoExt#_添加页码.pdf)
	压缩PDF|XiaoYao_plus[RA_plus2](%getZz%,%"cpdf.exe"%,-squeeze $1 -o $2,$1=#path#|$2=#dir#\#nameNoExt#_压缩.pdf)
	删除书签|XiaoYao_plus[RA_plus2](%getZz%,%"cpdf.exe"%,-merge -remove-duplicate-fonts $1 -o $2,$1=#path#|$2=#dir#\合并_%A_YYYY%%A_MM%%A_DD%_%A_Hour%%A_Min%%A_Sec%.pdf)
	添加水印|XiaoYao_plus[RA_plus2Box](%getZz%,%"cpdf.exe"%,-stamp-on "$3" $1 -o $2,$1=#path#|$2=#dir#\#nameNoExt#_水印.pdf,请设置需要添加的水印文件路径,$3)
	移除内嵌字体|XiaoYao_plus[RA_plus2](%getZz%,%"cpdf.exe"%,-remove-fonts $1 -o $2,$1=#path#|$2=#dir#\#nameNoExt#_内嵌字体移除.pdf)
	--
	;使用128bit对PDF加密，设置所有者密码和用户密码
	加密PDF|XiaoYao_plus[RA_plus2Box](%getZz%,%"cpdf.exe"%,-encrypt 128bit $3 xiaoyao $1 -o $2,$1=#path#|$2=#dir#\#nameNoExt#_加密.pdf,请设置加密密码,$3)
	解密PDF|XiaoYao_plus[RA_plus2Box](%getZz%,%"cpdf.exe"%,-decrypt $1 owner=$3 -o $2,$1=#path#|$2=#dir#\#nameNoExt#_解密.pdf,请设置加密密码,$3)	

```
</details>
<br>
<details>
<summary>其他功能【点此展开】</summary>

```ini
-docto格式转换功能
	;【官网：https://github.com/tobya/DocTo】
	文档转txt|XiaoYao_plus[RA_plus2](%getZz%,%"docto.exe"%,-f $1 -O $2 -T wdFormatText,$1=#path#|$2=#dir#\#nameNoExt#_text.txt)
	文档转pdf|XiaoYao_plus[RA_plus2](%getZz%,%"docto.exe"%,-f $1 -O $2 -T wdFormatPDF,$1=#path#|$2=#dir#\#nameNoExt#_PDF.pdf)
	文档转doc|XiaoYao_plus[RA_plus2](%getZz%,%"docto.exe"%,-f $1 -O $2 -T wdFormatDocumentDefault,$1=#path#|$2=#dir#\#nameNoExt#_Document.doc)
-Bandizip功能
	;【官网：https://cn.bandisoft.com/bandizip/】
		Bz智能解压|XiaoYao_plus[RA_plus](%getZz%,%"Bandizip.exe"%,1001)
		Bz解压(非智能)|XiaoYao_plus[RA_plus](%getZz%,%"Bandizip.exe"%,1002)
		Bz压缩|XiaoYao_plus[RA_plus](%getZz%,%"Bandizip.exe"%,1003)
		Bz分别压缩|XiaoYao_plus[RA_plus](%getZz%,%"Bandizip.exe"%,1004)

-7zip功能
		;【官网：https://www.7-zip.org/】
		7z解压|XiaoYao_plus[RA_plus](%getZz%,%"7z.exe"%,4003)
		7z压缩|XiaoYao_plus[RA_plus](%getZz%,%"7z.exe"%,4004)
		7z分别压缩|XiaoYao_plus[RA_plus](%getZz%,%"7z.exe"%,4005)
		--
		;【官网：https://meta.appinn.net/t/topic/33555】
		7z解压[扩展版]|XiaoYao_plus[RA_plus](%getZz%,%"SmartZip.exe"%,4001)
		7z压缩[扩展版]|XiaoYao_plus[RA_plus](%getZz%,%"SmartZip.exe"%,4002)

-ReNamer功能
	;【官网：https://www.den4b.com/products/renamer】
		添加到已打开|XiaoYao_plus[ReNamer](%getZz%,%"ReNamer.exe"%,,1)
		--
		;填到指定预设|XiaoYao_plus[ReNamer](%getZz%,%"ReNamer.exe"%,填预设名称,2)
		每30个文件建文件夹|XiaoYao_plus[ReNamer](%getZz%,%"ReNamer.exe"%,序列号改名每30个文件创建文件夹.rnp,2)
		缩短文件名长度|XiaoYao_plus[ReNamer](%getZz%,%"ReNamer.exe"%,缩短文件名.rnp,3)
		添加已阅标签|XiaoYao_plus[ReNamer](%getZz%,%"ReNamer.exe"%,已阅.rnp,4)

-Snipaste功能
	;【官网：https://zh.snipaste.com/】
		sinp截图|XiaoYao_plus[RA_plus]("%getZz%",%"Snipaste.exe"%,2001)
		sinp选中图片贴图|XiaoYao_plus[RA_plus]("%getZz%",%"Snipaste.exe"%,2002)
		截图后贴图|XiaoYao_plus[RA_plus]("%getZz%",%"Snipaste.exe"%,2003)
		全屏截图放剪切板|XiaoYao_plus[RA_plus]("%getZz%",%"Snipaste.exe"%,2004)
		截图放快速文件夹|XiaoYao_plus[RA_plus]("%getZz%",%"Snipaste.exe"%,2005)
		纯文本贴图|XiaoYao_plus[RA_plus]("%getZz%",%"Snipaste.exe"%,2006)
		白板|XiaoYao_plus[RA_plus]("%getZz%",%"Snipaste.exe"%,2007)

-BCompare文件比较功能
	;【下载地址：https://www.ghxi.com/beyondcompare.html】
	比较[选中文字与剪切板文字]|XiaoYao_plus[bcompare](%getZz%,%"BCompare.exe"%,1)
	比较[选中的两个文件/文件夹]|XiaoYao_plus[bcompare](%getZz%,%"BCompare.exe"%,2)	

-IObitUnlocker解除占用功能
	;【下载地址：https://www.ghxi.com/iobitunlocker.html/comment-page-1】
		解锁[#]|XiaoYao_plus[RA_plus](%getZz%,%"IObitUnlocker.exe"%,5001)
		删除[#]|XiaoYao_plus[RA_plus](%getZz%,%"IObitUnlocker.exe"%,5002)
		复制到D下载[#]|XiaoYao_plus[RA_plus](%getZz%,%"IObitUnlocker.exe"%,5003)
		移动到D下载[#]|XiaoYao_plus[RA_plus](%getZz%,%"IObitUnlocker.exe"%,5004)

```
</details>
<br>
<details>
<summary>功能测试【点此展开】</summary>

```ini
-功能测试
	百度搜索选中文件|XiaoYao_plus[RA_plus](%getZz%,,2)	
	;【添加选中的exe程序到开机启动项】	
	添加到开机自启|XiaoYao_plus[RA_plus](%getZz%,,3)
	;【使用Everything在当前目录中搜索文件】
	ev搜当前目录|XiaoYao_plus[RA_plus](,%"Everything.exe"%,11)		
	;【在当前当前窗口目录打开命令行窗口】
	当前目录打开CMD|XiaoYao_plus[RA_plus](,,10)
	;【创建以今天日期为文件夹名的新文件夹，在桌面上无效】
	创建日期文件夹|XiaoYao_plus[RA_plus](,,13)	
```

</details>

脚本内函数名   RunAny菜单实现功能
RA_plus2     直接在runany.ini中使用更多的变量

比如：命令参数示例：magick convert -quality 100 "E:\test\3.png" -resize (50%) "E:\test\5.png" 

将上述命令填到runany.ini，可以这样写：

`缩小50%|XiaoYao_plus[RA_plus2](%getZz%,%"magick.exe"%,convert $1 -resize (50%) $2,$1=#path#|$2=#dir#\#nameNoExt#_s50.#ext#,0) `

参数注释：
- 第一个,：getZz 表示选中的内容（选中多个文件则依次执行）
- 第二个,：magick.exe表示软件名
- 第三个,：命令$开头的表示变量
- 第四个,：是要替换的变量 用$1 $2 之间用|隔开
  - #path# 表示选中的图片路径 E:\test\3.png 
  - #dir# 图片目录 E:\test 
  - #nameNoExt# 文件名不带后缀 
  - #ext# 文件后缀
- 第五个,：参数为是否处理批量文件
  - 批处理为0时, 根据传入的文件路径个数, 执行多次运行命令, 上面示例则是执行多次 magick convert
  - 批处理为1时, 只执行一次运行命令, 传入多个文件文件路径会被合并成变量#path#
