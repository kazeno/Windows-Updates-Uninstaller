; Windows Updates Uninstaller Utility
;
; @author: Rinku Kazeno <development@kazeno.co>
; @version: 0.4a

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

FilePath := A_ScriptDir . "\WindowsUpdatesUninstallUtilityHotfixList.txt"
ListUtil := "wmic qfe list brief /format:texttablewsys >" . """" . FilePath . """"
RunWait, %comspec% /c %ListUtil%
FileReadLine, Headers, %FilePath%, 1
StringGetPos, DescCol, Headers, Description
StringGetPos, IdCol, Headers, HotFixID

Gui, Add, Text,, Please select the Windows Updates to uninstall:
Gui, Add, ListBox, W560 H420 X200 vListbox, |
Gui, Add, Button, X430 Y450, Cancel
Gui, Add, Button, X530 Y450, Next >

Loop, read, %FilePath%
{
	if (SubStr(A_LoopReadLine, DescCol+1, StrLen("Description")) = "Description" or SubStr(A_LoopReadLine, DescCol+1, StrLen("Service Pack")) = "Service Pack") {
		Continue
	}
	Fix := Trim(SubStr(A_LoopReadLine, IdCol+1, 10))
	GuiControl, , Listbox, %Fix%
}

;GuiControl, , Listbox, %Headers%
FileDelete %FilePath%
Gui, Show ,W800 H480, Windows Updates Uninstaller Utility
; wmic qfe list brief /format:texttablewsys > D:\hotfix.txt


;GuiClose:
;ExitApp