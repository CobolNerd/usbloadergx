;Copyright 2012 NeoRame

;Website: http://code.google.com/p/usbloader-gui/
;This software is OSI Certified Open Source Software.
;OSI Certified is a certification mark of the Open Source Initiative.

;This program is free software; you can redistribute it and/or
;modify it under the terms of the GNU General Public License
;as published by the Free Software Foundation; either version 2
;of the License, or (at your option) any later version.

;This program is distributed in the hope that it will be useful,
;but WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;GNU General Public License for more details.

;You should have received a copy of the GNU General Public License
;along with this program; if not, write to the Free Software
;Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

!include InstallerConfig.nsh

;=== Program Details
Name "${NAME2}"
OutFile "${FILENAME}.exe"
InstallDir "\${SHORTNAME}"
Caption "${NAME2} Installer"
VIProductVersion "${VERSION}"
VIAddVersionKey ProductName "${NAME2}"
VIAddVersionKey Comments "For more informations please visit http://code.google.com/p/usbloader-gui/"
VIAddVersionKey CompanyName "${TEAM}"
VIAddVersionKey LegalCopyright "${TEAM}"
VIAddVersionKey FileDescription "${NAME2}"
VIAddVersionKey FileVersion "${VERSION}"
VIAddVersionKey ProductVersion "${VERSION}"
VIAddVersionKey InternalName "${NAME}"
VIAddVersionKey LegalTrademarks "${NAME2} created by ${TEAM}."
VIAddVersionKey OriginalFilename "${FILENAME}.exe"
;VIAddVersionKey PrivateBuild ""
;VIAddVersionKey SpecialBuild ""

;=== Runtime Switches
;SetDatablockOptimize on
;SetCompress off
SetCompressor /SOLID lzma
CRCCheck on
AutoCloseWindow True


;=== Include Modern UI

!include "${NSISDIR}\Contrib\Modern UI 2\MUI2.nsh"
!include "FileFunc.nsh"
!include "MUI_EXTRAPAGES.nsh"
!insertmacro GetOptions
!insertmacro GetDrives
!include "Sections.nsh"
!include "LogicLib.nsh"

;=== General

;Request application privileges for Windows Vista
RequestExecutionLevel user

;=== Interface Settings

!define MUI_ABORTWARNING

;=== Program Icon

Icon "${NAME}.ico"


;=== Icon & Style ===

!define MUI_ICON "${NAME}.ico"
BrandingText "${NAME2} - GUI for Waninkoko�s USB Loader (based on libwiigui)"


;=== Pages

!define MUI_WELCOMEFINISHPAGE_BITMAP ${NAME}.bmp
!define MUI_WELCOMEPAGE_TITLE "${NAME2}"
!define MUI_WELCOMEPAGE_TEXT "$(welcome)"
!insertmacro MUI_PAGE_WELCOME
;!insertmacro MUI_PAGE_LICENSE "${NSISDIR}\Docs\Modern UI\License.txt"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_SHOWREADME http://docs.google.com/View?id=dfwvk5sg_0gksqfcdj&hl=en
!define MUI_FINISHPAGE_TEXT "$(finish)"
;!define MUI_FINISHPAGE_LINK "Please DONATE!"
;!define MUI_FINISHPAGE_LINK_LOCATION https://www.paypal.com/de/cgi-bin/webscr?cmd=_flow&SESSION=E1LIyStPgJANyyD1vAmprj2ztJT3SSowGvCPLlWj9FKXySqqdKYvlS1MLoS&dispatch=5885d80a13c0db1fb6947b0aeae66fdbfb2119927117e3a6ad170b0a66ce6e8a
!insertmacro MUI_PAGE_FINISH

  
;=== Languages


!insertmacro MUI_LANGUAGE "ENGLISH" ;first language is the default language
;!insertmacro MUI_LANGUAGE "CZECH"
;!insertmacro MUI_LANGUAGE "DANISH"
!insertmacro MUI_LANGUAGE "DUTCH"
;!insertmacro MUI_LANGUAGE "FINNISH"
!insertmacro MUI_LANGUAGE "FRENCH"
!insertmacro MUI_LANGUAGE "GERMAN"
;!insertmacro MUI_LANGUAGE "HUNGARIAN"
!insertmacro MUI_LANGUAGE "ITALIAN"
;!insertmacro MUI_LANGUAGE "JAPANESE"
;!insertmacro MUI_LANGUAGE "KOREAN"
;!insertmacro MUI_LANGUAGE "NORWEGIAN"
;!insertmacro MUI_LANGUAGE "POLISH"
;!insertmacro MUI_LANGUAGE "PORTUGUESEBR"
;!insertmacro MUI_LANGUAGE "PORTUGUESE"
;!insertmacro MUI_LANGUAGE "RUSSIAN"
;!insertmacro MUI_LANGUAGE "SIMPCHINESE"
!insertmacro MUI_LANGUAGE "SPANISH"
!insertmacro MUI_LANGUAGE "SWEDISH"
             ;!insertmacro MUI_LANGUAGE "TRADCHINESE"
;!insertmacro MUI_LANGUAGE "TURKISH"

!include LangFiles\LANG_ENGLISH.nsh
!include LangFiles\LANG_GERMAN.nsh
!include LangFiles\LANG_FRENCH.nsh
!include LangFiles\LANG_DUTCH.nsh
!include LangFiles\LANG_ITALIAN.nsh
!include LangFiles\LANG_SPANISH.nsh
!include LangFiles\LANG_SWEDISH.nsh
         ;!include LangFiles\LANG_TRADCHINESE.nsh
;!include LangFiles\LANG.nsh

;===Reserve Files
  
  ;If you are using solid compression, files that are required before
  ;the actual installation should be stored first in the data block,
  ;because this will make your installer start faster.
  
  ;insertmacro MUI_RESERVEFILE_LANGDLL


;=== Installer Sections

Section "USB Loader GX" SecMain
;SectionIn RO

  
  AddSize "2832"
  SetOutPath "$INSTDIR"
  NSISdl::download http://usbloader-gui.googlecode.com/svn/branches/updates/icon.png icon.png
  NSISdl::download http://usbloader-gui.googlecode.com/svn/branches/updates/meta.xml meta.xml
  NSISdl::download http://usbloader-gui.googlecode.com/svn/branches/updates/update_dol.txt rev.txt
  Pop $0
  StrCmp $0 success success
    SetDetailsView show
    DetailPrint "download failed: $0"
    Abort
  success:  

  Push 1 ;line number to read from
  Push "$INSTDIR\rev.txt" ;text file to read
   Call ReadFileLine
  Pop $0 ;output string (read from file.txt)

  CreateDirectory "$INSTDIR\..\..\images"
  CreateDirectory "$INSTDIR\..\..\images\disc"
  CreateDirectory "$INSTDIR\..\..\config"
  CreateDirectory "$INSTDIR\..\..\config\language"
  CreateDirectory "$INSTDIR\..\..\config\backgroundmusic"
  CreateDirectory "$INSTDIR\..\..\codes"
  CreateDirectory "$INSTDIR\..\..\txtcodes"

SectionEnd

SectionGroup "$(DESC_Op_Lang)" SecOptional1
 Section "!$(DESC_SD)" g2o1
  AddSize "0"
	SetOutPath $INSTDIR\..\..\config
	;File /r "readMii.txt"
	Push "$INSTDIR\..\..\config\GXGlobal.cfg" ; file to modify
	Push "language_path" ; string that a line must begin with *WS Sensitive*
	Push "" ; string to replace whole line with
	Call ReplaceLineStr
	Push "$INSTDIR\..\..\config\GXGlobal.cfg" ; file to modify
	Push " language_path" ; string that a line must begin with *WS Sensitive*
	Push "" ; string to replace whole line with
	Call ReplaceLineStr
	FileOpen $4 "$INSTDIR\..\..\config\GXGlobal.cfg" a
	FileSeek $4 0 END
	FileWrite $4 "$\r$\n" ; we write a new line
	FileWrite $4 "language_path = SD:/config/language/"
	FileClose $4 ; and close the file  
 SectionEnd

 Section /o "!$(DESC_USB)" g2o2
  AddSize "0"
	SetOutPath $INSTDIR\..\..\config
	;File /r "readMii.txt"
	Push "$INSTDIR\..\..\config\GXGlobal.cfg" ; file to modify
	Push "language_path" ; string that a line must begin with *WS Sensitive*
	Push "" ; string to replace whole line with
	Call ReplaceLineStr
	Push "$INSTDIR\..\..\config\GXGlobal.cfg" ; file to modify
	Push " language_path" ; string that a line must begin with *WS Sensitive*
	Push "" ; string to replace whole line with
	Call ReplaceLineStr
	FileOpen $4 "$INSTDIR\..\..\config\GXGlobal.cfg" a
	FileSeek $4 0 END
	FileWrite $4 "$\r$\n" ; we write a new line
	FileWrite $4 "language_path = USB:/config/language/"
	FileClose $4 ; and close the file  
 SectionEnd

 Section /o "Czech" g1o19
  AddSize "14"
  SetOutPath "$INSTDIR\..\..\config\language"
  NSISdl::download http://usbloader-gui.googlecode.com/svn/trunk/Languages/czech.lang czech.lang
  Pop $0
  StrCmp $0 success success
    SetDetailsView show
    DetailPrint "download failed: $0"
    Abort
  success:
  Push 1 ;line number to read from
  Push "$INSTDIR\rev.txt" ;text file to read
   Call ReadFileLine
  Pop $0 ;output string (read from file.txt)
FileOpen $4 "$INSTDIR\..\..\config\GXGlobal.cfg" a
	FileSeek $4 0 END
	FileWrite $4 "czech.lang"
	FileClose $4 ; and close the file  
 SectionEnd

 Section /o "Danish" g1o2
  AddSize "13"
  SetOutPath "$INSTDIR\..\..\config\language"
  NSISdl::download http://usbloader-gui.googlecode.com/svn/trunk/Languages/danish.lang danish.lang
  Pop $0
  StrCmp $0 success success
    SetDetailsView show
    DetailPrint "download failed: $0"
    Abort
  success:
  Push 1 ;line number to read from
  Push "$INSTDIR\rev.txt" ;text file to read
   Call ReadFileLine
  Pop $0 ;output string (read from file.txt)
FileOpen $4 "$INSTDIR\..\..\config\GXGlobal.cfg" a
	FileSeek $4 0 END
	FileWrite $4 "danish.lang"
	FileClose $4 ; and close the file  
 SectionEnd

 Section /o "Dutch" g1o3
  AddSize "14"
  SetOutPath "$INSTDIR\..\..\config\language"
  NSISdl::download http://usbloader-gui.googlecode.com/svn/trunk/Languages/dutch.lang dutch.lang
  Pop $0
  StrCmp $0 success success
    SetDetailsView show
    DetailPrint "download failed: $0"
    Abort
  success:
  Push 1 ;line number to read from
  Push "$INSTDIR\rev.txt" ;text file to read
   Call ReadFileLine
  Pop $0 ;output string (read from file.txt)  
FileOpen $4 "$INSTDIR\..\..\config\GXGlobal.cfg" a
	FileSeek $4 0 END
	FileWrite $4 "dutch.lang"
	FileClose $4 ; and close the file
 SectionEnd

 Section /o "English" g1o4
  AddSize "9"
  SetOutPath "$INSTDIR\..\..\config\language"
  NSISdl::download http://usbloader-gui.googlecode.com/svn/trunk/Languages/english.lang english.lang
  Pop $0
  StrCmp $0 success success
    SetDetailsView show
    DetailPrint "download failed: $0"
    Abort
  success:
  Push 1 ;line number to read from
  Push "$INSTDIR\rev.txt" ;text file to read
   Call ReadFileLine
  Pop $0 ;output string (read from file.txt)  
FileOpen $4 "$INSTDIR\..\..\config\GXGlobal.cfg" a
	FileSeek $4 0 END
	FileWrite $4 "english.lang"
	FileClose $4 ; and close the file
 SectionEnd

 Section /o "Finnish" g1o5
  AddSize "13"
  SetOutPath "$INSTDIR\..\..\config\language"
  NSISdl::download http://usbloader-gui.googlecode.com/svn/trunk/Languages/finnish.lang finnish.lang
  Pop $0
  StrCmp $0 success success
    SetDetailsView show
    DetailPrint "download failed: $0"
    Abort
  success:
  Push 1 ;line number to read from
  Push "$INSTDIR\rev.txt" ;text file to read
   Call ReadFileLine
  Pop $0 ;output string (read from file.txt)  
FileOpen $4 "$INSTDIR\..\..\config\GXGlobal.cfg" a
	FileSeek $4 0 END
	FileWrite $4 "finnish.lang"
	FileClose $4 ; and close the file
 SectionEnd

 Section /o "French" g1o6
  AddSize "14"
  SetOutPath "$INSTDIR\..\..\config\language"
  NSISdl::download http://usbloader-gui.googlecode.com/svn/trunk/Languages/french.lang french.lang
  Pop $0
  StrCmp $0 success success
    SetDetailsView show
    DetailPrint "download failed: $0"
    Abort
  success:
  Push 1 ;line number to read from
  Push "$INSTDIR\rev.txt" ;text file to read
   Call ReadFileLine
  Pop $0 ;output string (read from file.txt)  
FileOpen $4 "$INSTDIR\..\..\config\GXGlobal.cfg" a
	FileSeek $4 0 END
	FileWrite $4 "french.lang"
	FileClose $4 ; and close the file
 SectionEnd

 Section /o "German" g1o1
  AddSize "14"
  SetOutPath "$INSTDIR\..\..\config\language"
  NSISdl::download http://usbloader-gui.googlecode.com/svn/trunk/Languages/german.lang german.lang
  Pop $0
  StrCmp $0 success success
    SetDetailsView show
    DetailPrint "download failed: $0"
    Abort
  success:
  Push 1 ;line number to read from
  Push "$INSTDIR\rev.txt" ;text file to read
   Call ReadFileLine
  Pop $0 ;output string (read from file.txt)
FileOpen $4 "$INSTDIR\..\..\config\GXGlobal.cfg" a
	FileSeek $4 0 END
	FileWrite $4 "german.lang"
	FileClose $4 ; and close the file  
 SectionEnd

 Section /o "Hungarian" g1o20
  AddSize "14"
  SetOutPath "$INSTDIR\..\..\config\language"
  NSISdl::download http://usbloader-gui.googlecode.com/svn/trunk/Languages/hungarian.lang hungarian.lang
  Pop $0
  StrCmp $0 success success
    SetDetailsView show
    DetailPrint "download failed: $0"
    Abort
  success:
  Push 1 ;line number to read from
  Push "$INSTDIR\rev.txt" ;text file to read
   Call ReadFileLine
  Pop $0 ;output string (read from file.txt)
FileOpen $4 "$INSTDIR\..\..\config\GXGlobal.cfg" a
	FileSeek $4 0 END
	FileWrite $4 "hungarian.lang"
	FileClose $4 ; and close the file  
 SectionEnd

 Section /o "Italian" g1o7
  AddSize "14"
  SetOutPath "$INSTDIR\..\..\config\language"
  NSISdl::download http://usbloader-gui.googlecode.com/svn/trunk/Languages/italian.lang italian.lang
  Pop $0
  StrCmp $0 success success
    SetDetailsView show
    DetailPrint "download failed: $0"
    Abort
  success:
  Push 1 ;line number to read from
  Push "$INSTDIR\rev.txt" ;text file to read
   Call ReadFileLine
  Pop $0 ;output string (read from file.txt)  
FileOpen $4 "$INSTDIR\..\..\config\GXGlobal.cfg" a
	FileSeek $4 0 END
	FileWrite $4 "italian.lang"
	FileClose $4 ; and close the file
 SectionEnd

 Section /o "Japanese" g1o8
  AddSize "16"
  SetOutPath "$INSTDIR\..\..\config\language"
  NSISdl::download http://usbloader-gui.googlecode.com/svn/trunk/Languages/japanese.lang japanese.lang
  Pop $0
  StrCmp $0 success success
    SetDetailsView show
    DetailPrint "download failed: $0"
    Abort
  success:
  Push 1 ;line number to read from
  Push "$INSTDIR\rev.txt" ;text file to read
   Call ReadFileLine
  Pop $0 ;output string (read from file.txt)  
FileOpen $4 "$INSTDIR\..\..\config\GXGlobal.cfg" a
	FileSeek $4 0 END
	FileWrite $4 "japanese.lang"
	FileClose $4 ; and close the file
 SectionEnd

 Section /o "Korean" g1o9
  AddSize "13"
  SetOutPath "$INSTDIR\..\..\config\language"
  NSISdl::download http://usbloader-gui.googlecode.com/svn/trunk/Languages/korean.lang korean.lang
  Pop $0
  StrCmp $0 success success
    SetDetailsView show
    DetailPrint "download failed: $0"
    Abort
  success:
  Push 1 ;line number to read from
  Push "$INSTDIR\rev.txt" ;text file to read
   Call ReadFileLine
  Pop $0 ;output string (read from file.txt)  
FileOpen $4 "$INSTDIR\..\..\config\GXGlobal.cfg" a
	FileSeek $4 0 END
	FileWrite $4 "korean.lang"
	FileClose $4 ; and close the file
 SectionEnd

 Section /o "Norwegian" g1o10
  AddSize "14"
  SetOutPath "$INSTDIR\..\..\config\language"
  NSISdl::download http://usbloader-gui.googlecode.com/svn/trunk/Languages/norwegian.lang norwegian.lang
  Pop $0
  StrCmp $0 success success
    SetDetailsView show
    DetailPrint "download failed: $0"
    Abort
  success:
  Push 1 ;line number to read from
  Push "$INSTDIR\rev.txt" ;text file to read
   Call ReadFileLine
  Pop $0 ;output string (read from file.txt)  
FileOpen $4 "$INSTDIR\..\..\config\GXGlobal.cfg" a
	FileSeek $4 0 END
	FileWrite $4 "norwegian.lang"
	FileClose $4 ; and close the file
 SectionEnd

 Section /o "Polish" g1o21
  AddSize "14"
  SetOutPath "$INSTDIR\..\..\config\language"
  NSISdl::download http://usbloader-gui.googlecode.com/svn/trunk/Languages/polish.lang polish.lang
  Pop $0
  StrCmp $0 success success
    SetDetailsView show
    DetailPrint "download failed: $0"
    Abort
  success:
  Push 1 ;line number to read from
  Push "$INSTDIR\rev.txt" ;text file to read
   Call ReadFileLine
  Pop $0 ;output string (read from file.txt)  
FileOpen $4 "$INSTDIR\..\..\config\GXGlobal.cfg" a
	FileSeek $4 0 END
	FileWrite $4 "polish.lang"
	FileClose $4 ; and close the file
 SectionEnd

 Section /o "Portuguese_br" g1o11
  AddSize "14"
  SetOutPath "$INSTDIR\..\..\config\language"
  NSISdl::download http://usbloader-gui.googlecode.com/svn/trunk/Languages/portuguese_br.lang portuguese_br.lang
  Pop $0
  StrCmp $0 success success
    SetDetailsView show
    DetailPrint "download failed: $0"
    Abort
  success:
  Push 1 ;line number to read from
  Push "$INSTDIR\rev.txt" ;text file to read
   Call ReadFileLine
  Pop $0 ;output string (read from file.txt)  
FileOpen $4 "$INSTDIR\..\..\config\GXGlobal.cfg" a
	FileSeek $4 0 END
	FileWrite $4 "portuguese_br.lang"
	FileClose $4 ; and close the file
 SectionEnd

 Section /o "Portuguese_pt" g1o12
  AddSize "15"
  SetOutPath "$INSTDIR\..\..\config\language"
  NSISdl::download http://usbloader-gui.googlecode.com/svn/trunk/Languages/portuguese_pt.lang portuguese_pt.lang
  Pop $0
  StrCmp $0 success success
    SetDetailsView show
    DetailPrint "download failed: $0"
    Abort
  success:
  Push 1 ;line number to read from
  Push "$INSTDIR\rev.txt" ;text file to read
   Call ReadFileLine
  Pop $0 ;output string (read from file.txt)  
FileOpen $4 "$INSTDIR\..\..\config\GXGlobal.cfg" a
	FileSeek $4 0 END
	FileWrite $4 "portuguese_pt.lang"
	FileClose $4 ; and close the file
 SectionEnd

 Section /o "Russian" g1o13
  AddSize "16"
  SetOutPath "$INSTDIR\..\..\config\language"
  NSISdl::download http://usbloader-gui.googlecode.com/svn/trunk/Languages/russian.lang russian.lang
  Pop $0
  StrCmp $0 success success
    SetDetailsView show
    DetailPrint "download failed: $0"
    Abort
  success:
  Push 1 ;line number to read from
  Push "$INSTDIR\rev.txt" ;text file to read
   Call ReadFileLine
  Pop $0 ;output string (read from file.txt)  
FileOpen $4 "$INSTDIR\..\..\config\GXGlobal.cfg" a
	FileSeek $4 0 END
	FileWrite $4 "russian.lang"
	FileClose $4 ; and close the file
 SectionEnd

 Section /o "S.Chinese" g1o14
  AddSize "12"
  SetOutPath "$INSTDIR\..\..\config\language"
  NSISdl::download http://usbloader-gui.googlecode.com/svn/trunk/Languages/schinese.lang schinese.lang
  Pop $0
  StrCmp $0 success success
    SetDetailsView show
    DetailPrint "download failed: $0"
    Abort
  success:
  Push 1 ;line number to read from
  Push "$INSTDIR\rev.txt" ;text file to read
   Call ReadFileLine
  Pop $0 ;output string (read from file.txt)  
FileOpen $4 "$INSTDIR\..\..\config\GXGlobal.cfg" a
	FileSeek $4 0 END
	FileWrite $4 "schinese.lang"
	FileClose $4 ; and close the file
 SectionEnd

 Section /o "T.Chinese" g1o15
  AddSize "13"
  SetOutPath "$INSTDIR\..\..\config\language"
  NSISdl::download http://usbloader-gui.googlecode.com/svn/trunk/Languages/tchinese.lang tchinese.lang
  Pop $0
  StrCmp $0 success success
    SetDetailsView show
    DetailPrint "download failed: $0"
    Abort
  success:
  Push 1 ;line number to read from
  Push "$INSTDIR\rev.txt" ;text file to read
   Call ReadFileLine
  Pop $0 ;output string (read from file.txt)  
FileOpen $4 "$INSTDIR\..\..\config\GXGlobal.cfg" a
	FileSeek $4 0 END
	FileWrite $4 "tchinese.lang"
	FileClose $4 ; and close the file
 SectionEnd

 Section /o "Spanish" g1o16
  AddSize "14"
  SetOutPath "$INSTDIR\..\..\config\language"
  NSISdl::download http://usbloader-gui.googlecode.com/svn/trunk/Languages/spanish.lang spanish.lang
  Pop $0
  StrCmp $0 success success
    SetDetailsView show
    DetailPrint "download failed: $0"
    Abort
  success:
  Push 1 ;line number to read from
  Push "$INSTDIR\rev.txt" ;text file to read
   Call ReadFileLine
  Pop $0 ;output string (read from file.txt)  
FileOpen $4 "$INSTDIR\..\..\config\GXGlobal.cfg" a
	FileSeek $4 0 END
	FileWrite $4 "spanish.lang"
	FileClose $4 ; and close the file
 SectionEnd

 Section /o "Swedish" g1o17
  AddSize "13"
  SetOutPath "$INSTDIR\..\..\config\language"
  NSISdl::download http://usbloader-gui.googlecode.com/svn/trunk/Languages/swedish.lang swedish.lang
  Pop $0
  StrCmp $0 success success
    SetDetailsView show
    DetailPrint "download failed: $0"
    Abort
  success:
  Push 1 ;line number to read from
  Push "$INSTDIR\rev.txt" ;text file to read
   Call ReadFileLine
  Pop $0 ;output string (read from file.txt)  
FileOpen $4 "$INSTDIR\..\..\config\GXGlobal.cfg" a
	FileSeek $4 0 END
	FileWrite $4 "swedish.lang"
	FileClose $4 ; and close the file
 SectionEnd

 Section /o "Turkish" g1o18
  AddSize "13"
  SetOutPath "$INSTDIR\..\..\config\language"
  NSISdl::download http://usbloader-gui.googlecode.com/svn/trunk/Languages/turkish.lang turkish.lang
  Pop $0
  StrCmp $0 success success
    SetDetailsView show
    DetailPrint "download failed: $0"
    Abort
  success:
  Push 1 ;line number to read from
  Push "$INSTDIR\rev.txt" ;text file to read
   Call ReadFileLine
  Pop $0 ;output string (read from file.txt) 
FileOpen $4 "$INSTDIR\..\..\config\GXGlobal.cfg" a
	FileSeek $4 0 END
	FileWrite $4 "turkish.lang"
	FileClose $4 ; and close the file
 SectionEnd
SectionGroupEnd

Section /o  "$(DESC_Op_Chan)" SecOptional3
  
  CreateDirectory "$INSTDIR\..\..\wad"
  
  AddSize "4773"
  SetOutPath "$INSTDIR\..\..\wad"
  NSISdl::download http://www.techjawa.com/usbloadergx/dat4inst.zip dat4inst.zip
  Pop $0
  StrCmp $0 success success
    SetDetailsView show
    DetailPrint "download failed: $0"
    Abort
  success:  
  ZipDLL::extractall "$INSTDIR\..\..\wad\dat4inst.zip" "$INSTDIR\..\..\wad"
  Delete "$INSTDIR\..\..\wad\dat4inst.zip"

  Push 1 ;line number to read from
  Push "$INSTDIR\rev.txt" ;text file to read
   Call ReadFileLine
  Pop $0 ;output string (read from file.txt)

SectionEnd

;Section /o  "$(DESC_DB)" SecOptional2
;  
;  AddSize "114"
;  SetOutPath "$INSTDIR\..\..\config"
;  NSISdl::download http://wiitdb.com/wiitdb/pub/wiitdb.zip wiitdb.zip
;  Pop $0
;  StrCmp $0 success success
;    SetDetailsView show
;    DetailPrint "download failed: $0"
;    Abort
;  success:  
;
;  Push 1 ;line number to read from
;  Push "$INSTDIR\rev.txt" ;text file to read
;   Call ReadFileLine
;  Pop $0 ;output string (read from file.txt)
;
;SectionEnd

Section /o  "$(DESC_Cheats)" SecOptional4
  
  AddSize "15"
  SetOutPath "$INSTDIR\..\..\txtcodes"
  NSISdl::download http://usbloader-gui.googlecode.com/files/txtcodes.zip txtcodes.zip
  Pop $0
  StrCmp $0 success success
    SetDetailsView show
    DetailPrint "download failed: $0"
    Abort
  success:  
  ZipDLL::extractall "$INSTDIR\..\..\txtcodes\txtcodes.zip" "$INSTDIR\..\..\txtcodes"
  Delete "$INSTDIR\..\..\txtcodes\txtcodes.zip"

  Push 1 ;line number to read from
  Push "$INSTDIR\rev.txt" ;text file to read
   Call ReadFileLine
  Pop $0 ;output string (read from file.txt)

SectionEnd

SectionGroup "!$(DESC_clean)" SecOptional5
  Section /o  "$(DESC_Folder1)" SecOptional6  
    Delete $INSTDIR\..\..\images\*.*
    Push 1 ;line number to read from
    Push "$INSTDIR\rev.txt" ;text file to read
     Call ReadFileLine
    Pop $0 ;output string (read from file.txt)
  SectionEnd
  Section /o  "$(DESC_Folder2)" SecOptional7  
    AddSize "0"
    Delete $INSTDIR\..\..\images\disc\*.*
    Push 1 ;line number to read from
    Push "$INSTDIR\rev.txt" ;text file to read
     Call ReadFileLine
    Pop $0 ;output string (read from file.txt)
  SectionEnd
SectionGroupEnd

;=== Installer Functions/ Variables

Var FOUNDRMTPATH

Function .onInit
!insertmacro MUI_LANGDLL_DISPLAY


;StrCpy $1 ${g1o4} ; Group 1 - Option 1 is selected by default
;StrCpy $2 ${g1o4} ; Group 2 - Option 1 is selected by default
;StrCpy $3 ${g1o1} ; Group 2 - Option 1 is selected by default

        ${Switch} $LANGUAGE
	${Case} ${LANG_CZECH}
           !insertmacro SelectSection ${g1o19}
	${Break}
	${Case} ${LANG_DANISH}
           !insertmacro SelectSection ${g1o2}
	${Break}
	${Case} ${LANG_DUTCH}
           !insertmacro SelectSection ${g1o3}
	${Break}
	${Case} ${LANG_ENGLISH}
           !insertmacro SelectSection ${g1o4}
	${Break}
	${Case} ${LANG_FINNISH}
           !insertmacro SelectSection ${g1o5}
	${Break}
	${Case} ${LANG_FRENCH}
           !insertmacro SelectSection ${g1o6}
	${Break}
	${Case} ${LANG_GERMAN}
           !insertmacro SelectSection ${g1o1}
	${Break}
	${Case} ${LANG_HUNGARIAN}
           !insertmacro SelectSection ${g1o20}
	${Break}
	${Case} ${LANG_ITALIAN}
           !insertmacro SelectSection ${g1o7}
	${Break}
	${Case} ${LANG_JAPANESE}
           !insertmacro SelectSection ${g1o8}
	${Break}
	${Case} ${LANG_KOREAN}
           !insertmacro SelectSection ${g1o9}
	${Break}
	${Case} ${LANG_NORWEGIAN}
           !insertmacro SelectSection ${g1o10}
	${Break}
	${Case} ${LANG_POLISH}
           !insertmacro SelectSection ${g1o21}
	${Break}
	${Case} ${LANG_PORTUGUESEBR}
           !insertmacro SelectSection ${g1o11}
	${Break}
	${Case} ${LANG_PORTUGUESE}
           !insertmacro SelectSection ${g1o12}
	${Break}
	${Case} ${LANG_RUSSIAN}
           !insertmacro SelectSection ${g1o13}
	${Break}
	${Case} ${LANG_SIMPCHINESE}
           !insertmacro SelectSection ${g1o14}
	${Break}
	${Case} ${LANG_SPANISH}
           !insertmacro SelectSection ${g1o16}
	${Break}
	${Case} ${LANG_SWEDISH}
           !insertmacro SelectSection ${g1o17}
	${Break}
	;${Case} ${LANG_TRADCHINESE}
         ;  !insertmacro SelectSection ${g1o15}
	;${Break}
	${Case} ${LANG_TURKISH}
           !insertmacro SelectSection ${g1o18}
	${Break}
	${EndSwitch}

	;StrCpy $FOUNDRMTPATH ''

	${GetOptions} "$CMDLINE" "/DESTINATION=" $R0

	IfErrors CheckLegacyDestination
		StrCpy $INSTDIR "$R0${SHORTNAME}"
		Goto InitDone

	CheckLegacyDestination:
		ClearErrors
		${GetOptions} "$CMDLINE" "-o" $R0
		IfErrors NoDestination
			StrCpy $INSTDIR "$R0${SHORTNAME}"
			Goto InitDone

	NoDestination:
		ClearErrors
		${GetDrives} "HDD+FDD" GetDrivesCallBack
		StrCmp $FOUNDRMTPATH "" DefaultDestination
			StrCpy $INSTDIR "$FOUNDRMTPATH\${SHORTNAME}"
			Goto InitDone
		
	DefaultDestination:
		StrCpy $INSTDIR "$9\apps\${SHORTNAME}"

	InitDone:
FunctionEnd

Function GetDrivesCallBack

	;=== Skip usual floppy letters
	StrCmp $8 "FDD" "" CheckForRMTPath
	StrCmp $8 "CDROM" End
	StrCmp $9 "A:\" End
	StrCmp $9 "B:\" End
	
	CheckForRMTPath:
		${If} ${FileExists} "$9apps" 
			StrCpy $FOUNDRMTPATH "$9apps"
		${Else}
			StrCpy $FOUNDRMTPATH "$9apps"
            ${EndIf} 
	End:
		Push $0
FunctionEnd

Function ReadFileLine
Exch $0 ;file
Exch
Exch $1 ;line number
Push $2
Push $3
 
  FileOpen $2 $0 r
 StrCpy $3 0
 
Loop:
 IntOp $3 $3 + 1
  ClearErrors
  FileRead $2 $0
  IfErrors +2
 StrCmp $3 $1 0 loop
  FileClose $2
 
Pop $3
Pop $2
Pop $1
Exch $0
FunctionEnd

;=== Descriptions and Lang Strings

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecMain} $(DESC_SecMain)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecOptional1} $(DESC_SecOptional1)
    ;!insertmacro MUI_DESCRIPTION_TEXT ${SecOptional2} $(DESC_SecOptional2)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecOptional3} $(DESC_SecOptional3)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecOptional4} $(DESC_SecOptional4)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecOptional5} $(DESC_SecOptional5)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecOptional6} $(DESC_SecOptional6)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecOptional7} $(DESC_SecOptional7)
    !insertmacro MUI_DESCRIPTION_TEXT ${g2o1} $(DESC_SD_Des)
    !insertmacro MUI_DESCRIPTION_TEXT ${g2o2} $(DESC_USB_Des)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;=== RadioButtons

Function .onSelChange

${If} ${SectionIsSelected} ${SecOptional1}
    !insertmacro UnSelectSection ${SecOptional1}
    !insertmacro SelectSection $1
    !insertmacro SelectSection $2
  ${Else}
  !insertmacro StartRadioButtons $1
    !insertmacro RadioButton ${g1o1}
    !insertmacro RadioButton ${g1o2}
    !insertmacro RadioButton ${g1o3}
    !insertmacro RadioButton ${g1o4}
    !insertmacro RadioButton ${g1o5}
    !insertmacro RadioButton ${g1o6}
    !insertmacro RadioButton ${g1o7}
    !insertmacro RadioButton ${g1o8}
    !insertmacro RadioButton ${g1o9}
    !insertmacro RadioButton ${g1o10}
    !insertmacro RadioButton ${g1o11}
    !insertmacro RadioButton ${g1o12}
    !insertmacro RadioButton ${g1o13}
    !insertmacro RadioButton ${g1o14}
    !insertmacro RadioButton ${g1o15}
    !insertmacro RadioButton ${g1o16}
    !insertmacro RadioButton ${g1o17}
    !insertmacro RadioButton ${g1o18}
    !insertmacro RadioButton ${g1o19}
    !insertmacro RadioButton ${g1o20}
    !insertmacro RadioButton ${g1o21}
  !insertmacro EndRadioButtons
  !insertmacro StartRadioButtons $2
    !insertmacro RadioButton ${g2o1}
    !insertmacro RadioButton ${g2o2}
  !insertmacro EndRadioButtons
  ${EndIf}

FunctionEnd

;==== CFG Edit

Function ReplaceLineStr
 Exch $R0 ; string to replace that whole line with
 Exch
 Exch $R1 ; string that line should start with
 Exch
 Exch 2
 Exch $R2 ; file
 Push $R3 ; file handle
 Push $R4 ; temp file
 Push $R5 ; temp file handle
 Push $R6 ; global
 Push $R7 ; input string length
 Push $R8 ; line string length
 Push $R9 ; global
 
  StrLen $R7 $R1
 
  GetTempFileName $R4
 
  FileOpen $R5 $R4 w
  FileOpen $R3 $R2 r
 
  ReadLoop:
  ClearErrors
   FileRead $R3 $R6
    IfErrors Done
 
   StrLen $R8 $R6
   StrCpy $R9 $R6 $R7 -$R8
   StrCmp $R9 $R1 0 +3
 
    FileWrite $R5 "$R0"
    Goto ReadLoop
 
    FileWrite $R5 $R6
    Goto ReadLoop
 
  Done:
 
  FileClose $R3
  FileClose $R5
 
  SetDetailsPrint none
   Delete $R2
   Rename $R4 $R2
  SetDetailsPrint both
 
 Pop $R9
 Pop $R8
 Pop $R7
 Pop $R6
 Pop $R5
 Pop $R4
 Pop $R3
 Pop $R2
 Pop $R1
 Pop $R0
FunctionEnd
