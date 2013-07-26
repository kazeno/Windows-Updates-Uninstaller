; Windows Updates Uninstaller Utility
;
; @author: Rinku Kazeno <development@kazeno.co>
; @license: WTFPL v2
; @website: https://bitbucket.org/kazenoco/windows-updates-uninstaller-utility

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
Version = 0.9a	; Program version

; Get the list of installed Hotfixes from a temporal text file created by WMIC
FilePath := A_ScriptDir . "\WindowsUpdatesUninstallUtilityHotfixList.txt"
ListUtil := "wmic qfe list brief /format:texttablewsys >" . """" . FilePath . """"
RunWait, %comspec% /c %ListUtil%

FileReadLine, Headers, %FilePath%, 1
StringGetPos, DescCol, Headers, Description
StringGetPos, IdCol, Headers, HotFixID
StringGetPos, DateCol, Headers, InstalledOn

Gui, Add, Text, vTopText, Please select the Windows Updates to uninstall:
Gui, Add, ListView, Checked W400 H320 X270 Y6 vListview HwndLvw, HotFixID|Description|Install Date
LV_ModifyCol(1, "100 Right")
LV_ModifyCol(2, "179 Right")
LV_ModifyCol(3, "100 Right")
Gui, Add, Text, X270 Y334, version: %Version%
Gui, Add, Button, X50 Y330 vCancel, Cancel
Gui, Add, Button, X130 Y330 gUninstall vUninstall, Uninstall Selected
Gui, Add, Link, X574 Y334, <a href="https://bitbucket.org/kazenoco/windows-updates-uninstaller-utility">Visit Official Website</a>

Rows := 0
Loop, read, %FilePath%
{
	if (SubStr(A_LoopReadLine, DescCol+1, StrLen("Description")) = "Description" or SubStr(A_LoopReadLine, DescCol+1, StrLen("Service Pack")) = "Service Pack") {
		Continue
	}
	Fix := Trim(SubStr(A_LoopReadLine, IdCol+1, 10))
	Desc := Trim(SubStr(A_LoopReadLine, DescCol+1, 16))
	Date := Trim(SubStr(A_LoopReadLine, DateCol+1, 10))
	
	; Reformat date for easy sorting
	StringSplit, DateArray, Date, /]
	Month := SubStr("0" . DateArray1, -1, 2)
	Day := SubStr("0" . DateArray2, -1, 2)
	NewDate := DateArray3 . "/" . Month . "/" . Day
	
	CheckVar := "Check vCheckBox" . Fix
	LV_Add(CheckVar, Fix, Desc, NewDate)
}

FileDelete %FilePath%			;Delete the temporal text file
Gui, Show ,W680 H360, Windows Updates Uninstaller Utility

return


Uninstall:
	RowNumber = 0
	Loop {			; get checked updates into array
		RowNumber := LV_GetNext(RowNumber, "Checked")
		if not RowNumber
			break
		LV_GetText(CheckBox%A_Index%, RowNumber, 1)
		Rows := A_Index
	}
	if not Rows {
		MsgBox, No Windows Updates selected
		return
	}
	GuiControl, Disable, Listview
	GuiControl, Disable, Uninstall
	GuiControl, , TopText, Uninstalling Update:
	Gui, Add, Text, X40 Y120 vHotfixText w100, 
	Gui, Add, Text, X120 Y120 vNumText w100 Right, 
	Gui, Add, Progress, vProgressBar cGreen BackgroundGray w200 X30 Y150
	Loop, %Rows% {
		StringReplace, HotfixId, CheckBox%A_Index%, KB
		GuiControl, , HotfixText, % CheckBox%A_Index%
		GuiControl, , NumText, % "(" . A_Index . " of " . Rows . ")"
		GuiControl,, ProgressBar, % (Rows*A_Index)/100
		;RunWait, calc.exe
		RunWait, wusa.exe /kb:%HotfixId% /uninstall /quiet /norestart
	}
	GuiControl, Hide , TopText
	GuiControl, Hide , HotfixText
	GuiControl, Hide , NumText
	GuiControl, Hide , ProgressBar
	GuiControl, Hide , Uninstall
	GuiControl, Hide , Cancel
	Gui, Flash
	Gui, Add, Text, X10 Y150 w250 vDoneText Center, Your selected updates should have been uninstalled now
	Gui, Add, Button, X120 Y300 vClose, Close
return

GuiClose:
ButtonCancel:
ButtonClose:
	ExitApp
return
