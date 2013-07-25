; Windows Updates Uninstaller Utility
;
; @author: Rinku Kazeno <development@kazeno.co>
; @website: https://bitbucket.org/kazenoco/windows-updates-uninstaller-utility
; @version: 0.5a

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
Version = "0.5a"	; Program version

; Get the list of installed Hotfixes from a temporal text file created by WMIC
FilePath := A_ScriptDir . "\WindowsUpdatesUninstallUtilityHotfixList.txt"
ListUtil := "wmic qfe list brief /format:texttablewsys >" . """" . FilePath . """"
RunWait, %comspec% /c %ListUtil%

FileReadLine, Headers, %FilePath%, 1
StringGetPos, DescCol, Headers, Description
StringGetPos, IdCol, Headers, HotFixID
StringGetPos, DateCol, Headers, InstalledOn

Gui, Add, Text,, Please select the Windows Updates to uninstall:
Gui, Add, ListView, Checked W400 H320 X270 Y6 vListview +Hdr, HotFixID|Description|Install Date
LV_ModifyCol(1, "100 Right")
LV_ModifyCol(2, "179 Right")
LV_ModifyCol(3, "100 Right")
Gui, Add, Button, X50 Y330, Cancel
Gui, Add, Button, X160 Y330, Uninstall >
Gui, Add, Link, X574 Y334, <a href="https://bitbucket.org/kazenoco/windows-updates-uninstaller-utility">Visit Official Website</a>

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
	
	LV_Add("Check", Fix, Desc, NewDate)
}

;GuiControl, , Listview, %Headers%
FileDelete %FilePath%			;Delete the temporal text file
Gui, Show ,W680 H360, Windows Updates Uninstaller Utility
; wmic qfe list brief /format:texttablewsys > D:\hotfix.txt


;GuiClose:
;ExitApp