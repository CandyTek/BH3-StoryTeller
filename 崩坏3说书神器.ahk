;〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓
#SingleInstance, Force			; 脚本单实例
#NoEnv							; 不检查空变量是否为环境变量
#KeyHistory, 0					; 记录的历史按键数
SetBatchLines,   -1				; 脚本性能优化 / 最佳化为-1
SetMouseDelay,   -1				; 每次鼠标移动或点击后的延时
SetKeyDelay,      1				; 每次鼠标模拟按键后的延时
SetWinDelay,     -1				; 设置窗口的移动缩放无延迟
SetControlDelay, -1				; 窗口控件修改的延时
SetDefaultMouseSpeed, 0			; 鼠标移动命令的速度
CoordMode, ToolTip, Screen		; Tooltip 按屏幕坐标来显示
SendMode, Input					; send sendInput同义,提升速度和可靠性
SetWorkingDir, %A_ScriptDir%	; 设置脚本工作目录
ListLines, Off					; 忽略记录运行，提高性能
FileEncoding , UTF-8			; 为文件操作方法，设置默认编码
OnExit, SaveIni
; #NoTrayIcon					; 不显示托盘图标
OnMessage(0x201, "WM_LBUTTONDOWN")	; 使Gui允许空白处拖动
Menu Tray, Icon, shell32.dll, 270	; 修改Gui图标及托盘图标
if !(A_IsAdmin || InStr(DllCall("GetCommandLine", "str"), ".exe"" /r"))	; 脚本以管理员启动
	Run % "*RunAs " (s:=A_IsCompiled ? "" : A_AhkPath " /r ") """" A_ScriptFullPath """" (s ? "" : " /r")

;〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓
;〓〓 初始操作

; 配置文件路径
PREF_INI:=A_ScriptDir "/" A_ScriptName ".ini"
; 读取上次窗口的位置
IniRead, WindowX, %PREF_INI%, Pref, window_x,1
IniRead, WindowY, %PREF_INI%, Pref, window_y,1
IniRead, Continute, %PREF_INI%, Pref, continute,1
NonNull(WindowX,1)
NonNull(WindowY,1)
if(WindowX<0)
	WindowX=100
if(WindowY<0)
	WindowY=100

; 控件位置大小变量
DrawerX:=8
DrawerY:=8

DrawerH:=48
DrawerW:=224

bw1:=224
bh1:=48

Global Now_Tell_Line = 1

; 读取和谐词语，到数组
FileRead, Words, 和谐词语.txt
HarmoniousWordsArr1:=[]
HarmoniousWordsArr2:=[]
; 正式说书 的句子数组
TellStoryArr:=[]
Loop, Parse, Words, `n, `r
{
	; 为空则跳过
	if(A_LoopField=""){
		Continue
	}
	if(tempIndex:=InStr(A_LoopField, "=")){
		; MsgBox, % Substr(A_LoopField,1,tempIndex-1) " is " Substr(A_LoopField,tempIndex+1)
		; 添加到数组
		HarmoniousWordsArr1.Push(Substr(A_LoopField,1,tempIndex-1))
		HarmoniousWordsArr2.Push(Substr(A_LoopField,tempIndex+1))
	}
}
;〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓
;〓〓 软件窗口区

Gui, EditorGUI:New, +HwndEditorGUIHwnd -MaximizeBox +Resize
; 更改字体
Gui,Font, s11 w700, 微软雅黑
; 添加抽屉栏，按钮
Gui,EditorGUI:Add, Button, x-1 y-1 w%bw1% h%bh1% gBtnPasteAndSave,		% "1. 粘贴此处并备份　"
Gui,EditorGUI:Add, Button, xp y+-1 w%bw1% h%bh1% gBtnHarmoniousWords,	% "2. 和谐不雅用语　　"
Gui,EditorGUI:Add, Button, xp y+-1 w%bw1% h%bh1% gBtnRemoveBlank,		% "3. 去除行首行末空白"
Gui,EditorGUI:Add, Button, xp y+-1 w%bw1% h%bh1% gBtnSplitText,			% "4. 文本分隔40字符　"
Gui,EditorGUI:Add, Button, xp y+-1 w%bw1% h%bh1% gBtnRemoveCommaAtTheEnd,% "5. 去除行末逗号句号"
Gui,EditorGUI:Add, Button, xp y+-1 w%bw1% h%bh1% gBtnRemoveBlankLine,	% "6. 去除空行　　　　"

Gui,Font, s11 Norm, 微软雅黑
Gui,EditorGUI:Add, Button, xp y+24 w%bw1% h%bh1% gBtnReadBkText, --载入备份　
Gui,EditorGUI:Add, Button, xp y+-1 w%bw1% h%bh1% gBtnRemoveLineBreak, --去除换行符

Gui,EditorGUI:Add, Button, xp y+24 w%bw1% h%bh1% gBtnInputLine, 【开始说书】(Ctrl + Q)
Gui,EditorGUI:Add, Button, xp y+-1 w%bw1% h%bh1%, 自动说书(未完善)
Gui,EditorGUI:Add, Button, xp y+-1 w%bw1% h%bh1%, 从光标处继续说书(未完善)

Gui,EditorGUI:Add, Button, xp y+4 w%bw1% h%bh1%, 帮助
Gui,EditorGUI:Add, Button, xp y+-1 w%bw1% h%bh1% gGotoGithub, 1.0 Beta1(2023-05-27)
Gui,EditorGUI:Add, Button, xp y+-1 w%bw1% h%bh1% gGotoGithub, By 小华

; 添加编辑框
Gui,EditorGUI:Add, Edit, vMyEdit1 x223 y0 w372 h307 +Multi

Gui, EditorGUI:Show,% "w894 h713 x" WindowX " y" WindowY, 崩坏3说书神器 v1.0 Beta1
return
;〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓
;〓〓 按钮事件区

;〓〓 按钮事件，和谐词语
BtnHarmoniousWords:
; 获取编辑框文本
GuiControlGet, MainText, EditorGUI: , MyEdit1
; 遍历和谐数组，逐个替换词语
for index, element in HarmoniousWordsArr1
{
	MainText:=StrReplace(MainText,element,HarmoniousWordsArr2[index])
}
; 修改编辑框文本
GuiControl,Text, MyEdit1,%MainText%
return

;〓〓 按钮事件，文本分隔
BtnSplitText:
; pattern := "(.{1,40}[，。！？；”…》’~—])(?=.{0,39}(?:$|[，。！？；”…》’~—]))"
pattern := "(.{1,39}[，。！？；：”…》】」）、’—~\.,!?>\-'""])"
SetGuiEditText1(RegExReplace(GetGuiEditText1(), pattern, "$1`n"))
return

;〓〓 按钮事件，去除首尾空白
BtnRemoveBlank:
; formatted_text := RegExReplace(GetGuiEditText1(), "(^|\n)[\s\x{3000}]+|[\s\x{3000}]+(\n|$)","`n")
formatted_text := RegExReplace(GetGuiEditText1(), "m`a)^[\s\x{3000}]+|[\s\x{3000}]+$","`n")
SetGuiEditText1(formatted_text)
return

;〓〓 按钮事件，去除行尾逗号句号
BtnRemoveCommaAtTheEnd:
SetGuiEditText1(RegExReplace(GetGuiEditText1(),"[，。,\.]+(\n)","$1"))
return

;〓〓 按钮事件，去除换行符
BtnRemoveLineBreak:
SetGuiEditText1(RegExReplace(GetGuiEditText1(),"\n",""))
return

;〓〓 按钮事件，去除空行
BtnRemoveBlankLine:
tempText:=RegExReplace(GetGuiEditText1(),"(\n)[\s\x{3000}]+\n","$1")
SetGuiEditText1(RegExReplace(tempText,"\n\n","`n"))
return

;〓〓 按钮事件，粘贴并备份
BtnPasteAndSave:
SetGuiEditText1(Clipboard)
file := FileOpen("文本存档备份.txt", "w")
file.Write(Clipboard)
file.Close()
return

;〓〓 按钮事件，载入备份
BtnReadBkText:
FileRead, OutputVar, 文本存档备份.txt
SetGuiEditText1(OutputVar)
return

;〓〓 按钮事件，从第几行开始说书
BtnInputLine:
InputBox, UserInput, 从第...行开始, , , 185, 108
if(!ErrorLevel){
	If UserInput is number
	{
		Now_Tell_Line:=UserInput
		tempText:=GetGuiEditText1()
		TellStoryArr:=[]
		Loop, Parse, tempText, `n, `r
		{
			TellStoryArr.Push(A_LoopField)
		}

	}
}
return

;〓〓 按钮事件，前往项目地址
GotoGithub:
run,https://github.com/HolyshitOvO/BH3-StoryTeller
return

;〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓
;〓〓 其他事件区

<^q::
{
	Clipboard:=TellStoryArr[Now_Tell_Line]
	Now_Tell_Line++
	send,^v
	sleep,50
	send,{enter}
	sleep,2000
	Return
}

; Gui事件，当窗口关闭时
EditorGUIGuiClose:
; 获取当前窗口位置，保存到配置文件，供下次窗口打开时调用
WinGetPos,oX,oY,,,ahk_id %EditorGUIHwnd%
IniWrite, %oX%, %PREF_INI%, Pref, window_x
IniWrite, %oY%, %PREF_INI%, Pref, window_y
; 退出脚本
ExitApp
return


; Gui事件，当窗口大小改变时
EditorGUIGuiSize:
if (ErrorLevel = 1)	; 窗口被最小化了
		return	; 否则,窗口大小被更改或最大化

; 计算编辑框应更改的大小
edit1w:=A_GuiWidth-220
edit1h:=A_GuiHeight+1
GuiControl, EditorGUI:Move, MyEdit1, W%edit1w% H%edit1h%
return


SaveIni:
ExitApp
;〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓


; 允许Gui窗口空白处可拖动
WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
	PostMessage 0xA1, 2
}
; 获取编辑框文本
GetGuiEditText1() {
	global EditorGUI,MyEdit1
	GuiControlGet, MainText, EditorGUI: , MyEdit1
	Return MainText
}
; 编辑框文本
SetGuiEditText1(text1:="") {
	global EditorGUI,MyEdit1
	GuiControl,Text, MyEdit1,%text1%
}
; 加载库文件，防止空变量
#include <NonNull>