# Project: SlitScanGenerator (https://github.com/jkriege2/SlitScanGenerator)
# Copyright (c) 2018-2019, Jan Krieger <jan@jkrieger.de>
#
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.


!include "MUI.nsh"

!define EXE_BUILD_NAME "@CMAKE_PROJECT_NAME@.exe"
!define EXE_INSTALL_NAME "@PROJECT_LONGNAME@.exe"
!define APP_LONGNAME "@PROJECT_LONGNAME@_@PROJECT_BITNESS@bit"
!define APP_VERSION "@PROJECT_VERSION@, @PROJECT_BITNESS@bit"

!define DIST_DIR "@CMAKE_INSTALL_PREFIX@"
!define SOURCE_DIR "@CMAKE_SOURCE_DIR@"

Name "${APP_LONGNAME}"
OutFile "@PROJECT_LONGNAME@-@PROJECT_VERSION@-@PROJECT_BITNESS@bit_Setup.exe"
!define ORGANISATION_NAME "Jan Krieger"
InstallDir "$PROGRAMFILES@PROJECT_BITNESS@\${APP_LONGNAME}"
!define APP_REGISTRY_KEY "Software\${APP_LONGNAME}"
!define UNINSTALL_REGISTRY_KEY "${APP_LONGNAME}"
InstallDirRegKey HKLM "${APP_REGISTRY_KEY}" ""
SetCompressor /SOLID lzma

# Request admin privileges
RequestExecutionLevel admin

# Variables
Var StartMenuFolder

# Interface Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${SOURCE_DIR}\resources\installer-icon.ico"
#!define MUI_HEADERIMAGE_BITMAP "${SOURCE_DIR}\installer_win\installer-header.bmp" # Size: 150x57
#
#!define MUI_UNWELCOMEFINISHPAGE_BITMAP "${SOURCE_DIR}\installer_win\uninstaller-welcome.bmp"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${SOURCE_DIR}\LICENSE.txt"
!insertmacro MUI_PAGE_DIRECTORY
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "${APP_LONGNAME}"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKLM"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${APP_REGISTRY_KEY}"
!define START_MENU_REGISTRY_VALUE "${APP_LONGNAME} Start Menu Folder"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${START_MENU_REGISTRY_VALUE}"
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_RUN "$INSTDIR\${EXE_INSTALL_NAME}"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

# Languages
!insertmacro MUI_LANGUAGE "English"

#==
# Installation
#==
Section Install
  SetOutPath "$INSTDIR"

  File "${SOURCE_DIR}\LICENSE.txt"

  # App files
  File "/oname=${EXE_INSTALL_NAME}" "${DIST_DIR}\${EXE_BUILD_NAME}"

  # DLLs
  File "${DIST_DIR}\*.dll"

  # Qt Plugins
  SetOutPath "$INSTDIR\iconengines"
  File "${DIST_DIR}\iconengines\*.*"
  SetOutPath "$INSTDIR\imageformats"
  File "${DIST_DIR}\imageformats\*.*"
  SetOutPath "$INSTDIR\platforms"
  File "${DIST_DIR}\platforms\*.*"
  SetOutPath "$INSTDIR\styles"
  File "${DIST_DIR}\styles\*.*"
  SetOutPath "$INSTDIR\translations"
  File "${DIST_DIR}\translations\*.*"
  
  # Uninstaller
  WriteRegStr HKLM "${APP_REGISTRY_KEY}" "" $INSTDIR
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  !define UNINSTALL_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTALL_REGISTRY_KEY}"
  WriteRegStr HKLM "${UNINSTALL_KEY}" "DisplayName" "${APP_LONGNAME}"
  WriteRegStr HKLM "${UNINSTALL_KEY}" "UninstallString" "$INSTDIR\Uninstall.exe"
  WriteRegStr HKLM "${UNINSTALL_KEY}" "QuietUninstallString" "$INSTDIR\Uninstall.exe /S"
  WriteRegStr HKLM "${UNINSTALL_KEY}" "DisplayIcon" "$INSTDIR\${EXE_INSTALL_NAME}"
  WriteRegStr HKLM "${UNINSTALL_KEY}" "DisplayVersion" "${APP_VERSION}"
  WriteRegStr HKLM "${UNINSTALL_KEY}" "Publisher" "${ORGANISATION_NAME}"

  # Menu folder
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
    CreateShortCut "$SMPROGRAMS\$StartMenuFolder\${APP_LONGNAME}.lnk" "$INSTDIR\${EXE_INSTALL_NAME}"
    CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Uninstall${APP_LONGNAME}.lnk" "$INSTDIR\Uninstall.exe"
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

#==
# Uninstallation
#==
Section Uninstall
  Delete "$INSTDIR\LICENCE"

  # Delete all files in InstallDir
  Delete "$INSTDIR\*.*"

    # Qt Plugins
    Delete "$INSTDIR\imageformats\*.*"
    RMDir "$INSTDIR\imageformats"
    Delete "$INSTDIR\platforms\*.*"
    RMDir "$INSTDIR\platforms"
    Delete "$INSTDIR\iconengines\*.*"
    RMDir "$INSTDIR\iconengines"
    Delete "$INSTDIR\styles\*.*"
    RMDir "$INSTDIR\styles"
    Delete "$INSTDIR\translations\*.*"
    RMDir "$INSTDIR\translations"
  # Menu folder
  !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
  Delete "$SMPROGRAMS\$StartMenuFolder\${APP_LONGNAME}.lnk"
  Delete "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk"
  RMDir "$SMPROGRAMS\$StartMenuFolder"

  # Uninstaller
  Delete "$INSTDIR\Uninstall.exe"
  RMDir "$INSTDIR"
  DeleteRegKey /ifempty HKLM "${APP_REGISTRY_KEY}"
  DeleteRegKey /ifempty HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTALL_REGISTRY_KEY}"
SectionEnd


