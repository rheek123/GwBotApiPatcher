#include <file.au3>

#include "incl\GWA2_Function_Header_Table.au3"
#include "incl\GWA2_Update_Lines.au3"

_OnAutoItErrorRegister("")

Global $UpdateHeaders = True
Global $UpdateOffsets = false
Global $UpdateLines = True

Global $LastFuncDecl = ""
Global $CntHeaderInFunc = 1

Global $gFileName = ""

Global $MissingFunction = false
Global $BrokenFunction = false
Global $includeFound = false
Global $requireAdminFound = false
Global $LastFuncLineNr = 0
Global $requireAdminFoundAt = 0

Global $numErrorsDetected = 0

Global $lastHeader = ""
Global $gwa_header_file_include = '#include "GWA2_Headers.au3"'
Global $FileArrayBak

Local Const $sMessage = "Select the main folder of the bot you want to patch."

; Display an open dialog to select a file.
Local $sFileSelectFolderMain = FileSelectFolder($sMessage, @ScriptDir)
If @error Then
   ; Display the error message.
   MsgBox($MB_SYSTEMMODAL, "", "No folder was selected.")
Else
   ProcessFolder($sFileSelectFolderMain, 1)

   If (Not $BrokenFunction) And ($numErrorsDetected > 0) Then
	  MsgBox ( 1, "Warning!", 'During patching the script encountered ' &$numErrorsDetected& ' functions/headers that could not be handled. The bot is NOT necessarily stable.' &@LF&@LF&'Please check the genererated file "gwa_missing_headers.txt" to see info on the unhandled functions. Post the file (and bot, if possible) on epvp to get help.')
   ElseIf $BrokenFunction
	  MsgBox ( 1, "Error!", 'During patching the script encountered ' &$numErrorsDetected& ' functions/headers that could not be handled and at least of those was CRITICAL. The bot was NOT PATCHED!' &@LF&@LF&'Please check the genererated file "gwa_missing_headers.txt" to see info on the unhandled functions. Post the file (and bot, if possible) on epvp to get help.')
	  Exit
   EndIf

   FileCopy(@ScriptDir & "\incl\GWA2_Headers.au3", $sFileSelectFolderMain & "\", $FC_OVERWRITE)
EndIf



Func ProcessFolder($sFileSelectFolder, $depth)

   Local $aFileList = _FileListToArray($sFileSelectFolder, "*.au3")
   If @error = 1 Then
	  MsgBox($MB_SYSTEMMODAL, "", "Path was invalid.")
	  Exit
   EndIf
   If @error = 4 Then
	  MsgBox($MB_SYSTEMMODAL, "", "No file(s) were found.")
	  Return
   EndIf


   ProgressOn ( "GWA2 Patcher!", "Patching...")
   For $i = 1 To $aFileList[0]
	  ProcessFile($sFileSelectFolder & "\" & $aFileList[$i])
	  ProgressSet ($i/$aFileList[0]*100)
   Next

   If $depth = 0 Then
	  Return
   EndIf

   Local $aFolderList = _FileListToArray($sFileSelectFolder, "*", $FLTA_FOLDERS)
   If @error = 1 Then
	  MsgBox($MB_SYSTEMMODAL, "", "Path was invalid.")
	  Exit
   EndIf
   For $i = 1 To $aFolderList[0]
	  ProcessFolder($sFileSelectFolder & "\" & $aFolderList[$i], $depth - 1)
   Next
EndFunc




Func ProcessFile($FileName)
   $gFileName = $FileName
   ;$FileName = FileOpenDialog("Open", @ScriptDir, "Autoit ()")
   Local $FileArray

   _FileReadToArray($FileName, $FileArray, 1)
   $FileArrayBak=$FileArray

   For $i = 1 To $FileArray[0]
	  CheckFuncDecl($FileArray[$i], $i)
	  CheckInclude($FileArray[$i], $i)

	  If Not CheckValidString($FileArray[$i]) Then ContinueLoop
	  If $UpdateOffsets Then
		 If StringRegExp($FileArray[$i-1], "(\[2\]).*(0x2C)") And StringRegExp($FileArray[$i-2], "(\[1\]).*(0x18)") Then
			$lTemp = UpdateOffsetMulti($FileArray[$i])
			If $lTemp Then
			   ConsoleWrite($FileArray[$i] & ' -> ' & $lTemp & @CRLF)
			   $FileArray[$i] = $lTemp
			   ContinueLoop
			EndIf
		 EndIf
		 $lTemp = UpdateOffset($FileArray[$i])
		 If $lTemp Then
			ConsoleWrite($FileArray[$i] & ' -> ' & $lTemp & @CRLF)
			$FileArray[$i] = $lTemp
			ContinueLoop
		 EndIf
	  EndIf
	  If $UpdateLines Then
		 $lTemp = UpdateLine($FileArray[$i])
		 If $lTemp Then
			ConsoleWrite($FileArray[$i] & ' -> ' & $lTemp & @CRLF)
			$FileArray[$i] = $lTemp
			ContinueLoop
		 EndIf
	  EndIf
	  If $UpdateHeaders Then
		 $lTemp = UpdateHeader($FileArray[$i])
		 If $lTemp Then
			ConsoleWrite($FileArray[$i] & ' -> ' & $lTemp & @CRLF)
			$FileArray[$i] = $lTemp
			ContinueLoop
		 EndIf
	  EndIf
   Next

   If (Not  $BrokenFunction) Then
	  ;$NewFileName = StringTrimRight($FileName, 4) & "_new.au3"
	  $NewFileName = $gFileName
	  _FileWriteFromArray($NewFileName, $FileArray, 1)

	  If (Not $includeFound And $requireAdminFound) Then
		 _FileWriteToLine ( $NewFileName, $requireAdminFoundAt + 1, $gwa_header_file_include)
	  EndIf
   EndIf
EndFunc

#Region Update Functions
;~ Description: Returns true if string is to be processed.
Func CheckValidString($aString)
   If StringInStr($aString, "Func ") Then Return False
   Return True
EndFunc

;~ Description: Saves function name and whole function definition
Func CheckFuncDecl($aString, $aLineNr)
   If StringInStr($aString, "Func") Then

	  If($MissingFunction) Then
		 $numErrorsDetected += 1
		 For $i = $LastFuncLineNr - 1 To $aLineNr
			FileWriteLine ( "gwa_missing_headers.txt", $gFileName & " ("& $i & "): " & $FileArrayBak[$i])
		 Next
		 $MissingFunction = false
		 FileWriteLine ( "gwa_missing_headers.txt", "------------------------------------------")
	  EndIf

	  $LastFuncLineNr = $aLineNr

	  $LastFuncLine = $aString
	  $lStart = StringInStr($aString, "Func ") + 5
	  $lEnd = StringInStr($aString, "(")
	  $LastFuncDecl = StringMid($aString, $lStart, $lEnd - $lStart)
	  $CntHeaderInFunc = 1
   EndIf
EndFunc

;~ Description: Saves function name and whole function definition
Func CheckInclude($aString, $aLine)
   If StringInStr(StringStripWS($aString, 8), StringStripWS($gwa_header_file_include, 8)) Then
	  $includeFound = true
   EndIf
   If StringInStr(StringStripWS($aString, 8), "#RequireAdmin") Then
	  $requireAdminFound = true
   	  $requireAdminFoundAt = $aLine
   EndIf
EndFunc


;~ Description: Adds 0x1 to packet header.
Func UpdateHeader($aString)
   If(StringLeft(StringStripWS($aString, 8), 1) = ";") Then Return	;its a comment, doh

   $lStart = StringInStr($aString, "Sendpacket(")
   If $lStart = 0 Then Return ; no sendpacket, doh

   Local $iRows = UBound($gwa2func_headers, $UBOUND_ROWS) - 1
   For $i = 0 To $iRows
	  If($gwa2func_headers[$i][$gwa2func_fname] = $LastFuncDecl And _
		 ($gwa2func_headers[$i][$gwa2func_occurance] = $CntHeaderInFunc Or _
		  $gwa2func_headers[$i][$gwa2func_occurance] = 0)) Then

		 $lHeaderStart = StringInStr($aString, ",", 0, 1, $lStart) + 1
		 $lHeaderEnd = StringInStr($aString, ",", 0, 1, $lHeaderStart)
		 If $lHeaderEnd = 0 Then
			$lHeaderEnd = StringInStr($aString, ")", 0, 1, $lHeaderStart)
		 EndIf
		 $lHeaderString = StringMid($aString, $lHeaderStart, $lHeaderEnd - $lHeaderStart)

		 Local $areVariableAlready = StringLeft(StringStripWS($lHeaderString, 8), 1) = "$" And StringLeft(StringStripWS($lastHeader, 8), 1) = "$"

		 If(($CntHeaderInFunc > 1) And (StringCompare ( $lHeaderString, $lastHeader) <> 0) And (Not $areVariableAlready) And ($gwa2func_headers[$i][$gwa2func_occurance] = 0)) Then
			$MissingFunction = true
			$BrokenFunction = true
		 EndIf

		 $lastHeader = $lHeaderString
		 $lHeaderString = $gwa2func_headers[$i][$gwa2func_variable]
		 ;$lHeaderString = StringFormat("0x%X", $lHeaderString) ; kudos 4D1
		 $CntHeaderInFunc += 1
		 Return StringLeft($aString, $lHeaderStart) & $lHeaderString & StringRight($aString, StringLen($aString) - $lHeaderEnd + 1)
	  EndIf
   Next

   $MissingFunction = true

EndFunc

;~ Description: Adds 0x64 to offset, if offset array is declared in one line.
Func UpdateOffset($aString)
   $lStart = StringInStr($aString, "0x18,")
   If $lStart = 0 Then Return
   $lStart = StringInStr($aString, "0x2C,", 0, 1, $lStart + 5)
   If $lStart = 0 Then Return
   $lStart += 5
   $lEnd = StringInStr($aString, ",", 0, 1, $lStart) - 1
   If $lEnd < 0 Then
	  $lEnd = StringInStr($aString, "]", 0, 1, $lStart) - 1
   EndIf
   If $lEnd < 0 Then
	  $lEnd = StringLen($aString)
   EndIf
   $lOffset = Int(StringStripWS(StringMid($aString, $lStart, $lEnd - $lStart + 1), 1))
   If $lOffset < 173 Then Return
   $lOffset = $lOffset + 100
   $lOffset = StringFormat("0x%X", $lOffset)
   Return StringLeft($aString, $lStart) & $lOffSet & StringRight($aString, StringLen($aString) - $lEnd)
EndFunc

;~ Description: Adds 0x64 to offset, if offset array is declared using multiple lines.
Func UpdateOffsetMulti($aString)
   $lStart = StringInStr($aString, "=")
   If $lStart = 0 Then Return
   $lStart += 1
   $lOffset = StringStripWS(StringRight($aString, StringLen($aString) - $lStart), 1)
   If $lOffset < 173 Then Return
   $lOffset = Int($lOffset + 100)
   $lOffset = StringFormat("0x%X", $lOffset)
   Return StringLeft($aString, $lStart) & $lOffset
EndFunc

;~ Description: Update whole lines.
Func UpdateLine($aString)
   ; UseHeroSkill
   If StringRegExp($aString, "SetValue\(.UseHeroSkillFunction") Then
	  Return StringLeft($aString, StringInStr($aString, "SetValue") - 1) & "SetValue('UseHeroSkillFunction', '0x' & Hex(GetScannedAddress('ScanUseHeroSkillFunction', -0xA1), 8))" ; kudos 4D1
   EndIf
   If StringInStr($aString, "8B782C8B333BB7") <> 0 Then
	  Return StringLeft($aString, StringInStr($aString, "AddPattern") - 1) & "AddPattern('8D0C765F5E8B')"
   EndIf
   ; DecreaseAttribute
   If StringRegExp($aString, "SetValue\(.DecreaseAttributeFunction") Then
	  Return StringLeft($aString, StringInStr($aString, "SetValue") - 1) & "SetValue('DecreaseAttributeFunction', '0x' & Hex(GetScannedAddress('ScanIncreaseAttributeFunction', -288), 8))"
   EndIf
   ; SendChat
   If StringRegExp(StringStripWS($aString, 8), "DllStructSetData\(\$mSendChat,2") Then
	  Return StringLeft($aString, StringInStr($aString, "DllStruct") - 1) & "DllStructSetData($mSendChat, 2, $HEADER_SEND_CHAT)"
   EndIf
   ; KickHeroesFix (gwapi uses a different function that is compatiblee with the general approach of this patcher, this has to be "maunually" addressed with this fix)
   If StringRegExp(StringStripWS($aString, 8), "If\$aKickHeroesThenSendPacket\(0x8,0x") Then
	  Return StringLeft($aString, StringInStr($aString, "If") - 1) & "If $aKickHeroes Then SendPacket(0x8, $HEADER_HEROES_KICK, 0x26)"
   EndIf
   ; Sendpacket fix for lazy hack (some bots had $aHeader+1 for older header updates. wont work today and breaks the variable headers)
   If StringRegExp(StringStripWS($aString, 8), "DllStructSetData\(\$mPacket,3") Then
	  Return StringLeft($aString, StringInStr($aString, "DllStruct") - 1) & "DllStructSetData($mPacket, 3, $aHeader)"
   EndIf
   ; MaxAttributes
   If StringRegExp(StringStripWS($aString, 8), "DllStructSetData\(\$mMaxAttributes,3") Then
	  Return StringLeft($aString, StringInStr($aString, "DllStruct") - 1) & "DllStructSetData($mMaxAttributes, 3, $HEADER_SET_ATTRIBUTES)"
   EndIf
   If StringRegExp(StringStripWS($aString, 8), "DllStructSetData\(\$mMaxAttributes,5") Then
	  Return StringLeft($aString, StringInStr($aString, "DllStruct") - 1) & "DllStructSetData($mMaxAttributes, 5, $HEADER_MAX_ATTRIBUTES_CONST_5)"
   EndIf
   If StringRegExp(StringStripWS($aString, 8), "DllStructSetData\(\$mMaxAttributes,22") Then
	  Return StringLeft($aString, StringInStr($aString, "DllStruct") - 1) & "DllStructSetData($mMaxAttributes, 22, $HEADER_MAX_ATTRIBUTES_CONST_22)"
   EndIf
   ; SetAttributes
   If StringRegExp(StringStripWS($aString, 8), "DllStructSetData\(\$mSetAttributes,3") Then
	  Return StringLeft($aString, StringInStr($aString, "DllStruct") - 1) & "DllStructSetData($mSetAttributes, 3, $HEADER_SET_ATTRIBUTES)"
   EndIf
   ; $lOffset[3] = 0x4A4
   If $UpdateOffsets And StringInStr(StringStripWS($aString, 8), "[3]=0x4A4") Then
	  Return StringLeft($aString, StringInStr($aString, "$") - 1) & "$lOffset[3] = 0x508"
   EndIf

   Local $iRows = UBound($gwa2_lines, $UBOUND_ROWS) - 1
   For $i = 0 To $iRows
	  Local $a = StringStripWS($aString, 8)
	  Local $b = StringStripWS($gwa2_lines[$i][$gwa2_old_line], 8)
	  If (StringInStr($a, $b) <> 0) Then
		 Local $lAt = StringInStr($aString, StringLeft($gwa2_lines[$i][$gwa2_old_line], 8)) - 1
		 Return StringLeft($aString, $lAt) & $gwa2_lines[$i][$gwa2_new_line]
	  EndIf
   Next

EndFunc
#EndRegion

#Region Autoit UDFs
; #FUNCTION# ====================================================================================================
; Name...........:	_OnAutoItErrorRegister
; Description....:	Registers a function to be called when AutoIt produces a critical error (syntax error usualy).
; Syntax.........:	_OnAutoItErrorRegister( [$sFunction = "" [, $vParams = "" [, $sTitleMsg = -1 [, $sErrorMsgFormat = -1 [, $bUseStdOutMethod = True]]]]])
; Parameters.....:	$sFunction        - [Optional] The name of the user function to call.
;                                                 If this parameter is empty (""), then default (built-in) error message function is called.
;					$vParams          - [Optional] Parameter(s) that passed to $sFunction (default is "" - no parameters).
;					$sTitleMsg        - [Optional] The title of the default error message dialog (used only if $sFunction = "").
;					$sErrorMsgFormat  - [Optional] Formated error message string of the default error message dialog (used only if $sFunction = "").
;					$bUseStdOutMethod - [Optional] Defines the method that will be used to catch AutoIt errors (default is True - use StdOut).
;
; Return values..:	None.
; Author.........:	G.Sandler (CreatoR), www.autoit-script.ru, www.creator-lab.ucoz.ru
; Modified.......:
; Remarks........:	The UDF can not handle crashes that triggered by memory leaks, such as DllCall crashes.
;                   This UDF uses StdOut method by default (it's not compatible with CUI application),
;                    if you don't like it you can set "AutoIt error window catching" method by passing False in $bUseStdOutMethod parameter.
; Related........:
; Link...........:
; Example........:	Yes.
; ===============================================================================================================
Func _OnAutoItErrorRegister($sFunction = "", $vParams = "", $sTitleMsg = -1, $sErrorMsgFormat = -1, $bUseStdOutMethod = True)
	Local $hAutoItWin = __OnAutoItErrorRegister_WinGetHandleByPID(@AutoItPID)
	Local $sText = ControlGetText($hAutoItWin, '', 'Edit1')

	If StringInStr($sText, '/OAER') Then
		ControlSetText($hAutoItWin, '', 'Edit1', StringTrimRight($sText, 5))
		Return
	Else
		Opt("TrayIconHide", 1)
	EndIf

	Local $sErrorMsg = "", $sRunLine, $iPID, $iWinExists

	If $bUseStdOutMethod Then
		$sRunLine = @AutoItExe & ' /ErrorStdOut /AutoIt3ExecuteScript "' & @ScriptFullPath & '"'

		If $CmdLine[0] > 0 Then
			For $i = 1 To $CmdLine[0]
				$sRunLine &= ' ' & $CmdLine[$i]
			Next
		EndIf

		$iPID = Run($sRunLine, @ScriptDir, 0, 2 + 4)

		$hAutoItWin = __OnAutoItErrorRegister_WinWaitByPID($iPID, '[CLASS:AutoIt v3]')
		$sText = ControlGetText($hAutoItWin, '', 'Edit1')
		ControlSetText($hAutoItWin, '', 'Edit1', $sText & '/OAER')

		While 1
			$sErrorMsg &= StdoutRead($iPID)

			If @error Or StderrRead($iPID) = -1 Then
				ExitLoop
			EndIf

			Sleep(10)
		WEnd
	Else
		$sRunLine = @AutoItExe & ' /AutoIt3ExecuteScript "' & @ScriptFullPath & '"'

		If $CmdLine[0] > 0 Then
			For $i = 1 To $CmdLine[0]
				$sRunLine &= ' ' & $CmdLine[$i]
			Next
		EndIf

		$iPID = Run($sRunLine, @ScriptDir, 0, 4)

		Opt("WinWaitDelay", 0)

		$hAutoItWin = __OnAutoItErrorRegister_WinWaitByPID($iPID, '[CLASS:AutoIt v3]')
		$sText = ControlGetText($hAutoItWin, '', 'Edit1')
		ControlSetText($hAutoItWin, '', 'Edit1', $sText & '/OAER')

		$iWinExists = 0

		While ProcessExists($iPID)
			$iWinExists = WinExists("[CLASS:#32770;REGEXPTITLE:.*? Error]", "Line ")

			If $iWinExists Or StderrRead($iPID) = -1 Then
				ExitLoop
			EndIf

			Sleep(10)
		WEnd

		If Not $iWinExists Then
			Exit
		EndIf

		$sErrorMsg = ControlGetText("[CLASS:#32770;REGEXPTITLE:.*? Error]", "Line ", "Static2")
		WinClose("[CLASS:#32770;REGEXPTITLE:.*? Error]", "Line ")
	EndIf

	If $sErrorMsg = "" Then
		Exit
	EndIf

	If $sFunction = "" Then
;~ 		__OnAutoItErrorRegister_ShowDefaultErrorDbgMsg($sTitleMsg, $sErrorMsgFormat, $sErrorMsg, $bUseStdOutMethod)
	Else
		Call($sFunction, $vParams)

		If @error Then
			Call($sFunction)
		EndIf
	EndIf

	Exit
 EndFunc

 Func __OnAutoItErrorRegister_WinGetHandleByPID($iPID, $sTitle = '[CLASS:AutoIt v3]')
	Local $aWinList = WinList($sTitle)

	For $i = 1 To $aWinList[0][0]
		;Hidden and belong to process in $iPID
		If Not BitAND(WinGetState($aWinList[$i][1]), 2) And WinGetProcess($aWinList[$i][1]) = $iPID Then
			Return $aWinList[$i][1]
		EndIf
	Next

	Return 0
EndFunc

Func __OnAutoItErrorRegister_WinWaitByPID($iPID, $sTitle = '[CLASS:AutoIt v3]', $iTimeout = 0)
	Local $iTimer = TimerInit(), $hWin

	While 1
		$hWin = __OnAutoItErrorRegister_WinGetHandleByPID($iPID, $sTitle)

		If $hWin <> 0 Then
			Return $hWin
		EndIf

		If $iTimeout > 0 And TimerDiff($iTimer) >= $iTimeout Then
			ExitLoop
		EndIf

		Sleep(10)
	WEnd

	Return 0
EndFunc
#EndRegion
