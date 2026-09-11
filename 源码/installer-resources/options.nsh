!ifndef LINE_DOG_RUN_KEY
  !define LINE_DOG_RUN_KEY "Software\Microsoft\Windows\CurrentVersion\Run"
!endif

!ifndef BUILD_UNINSTALLER
  Var lineDogDesktopChoice
  Var lineDogStartupChoice
  Var lineDogDesktopControl
  Var lineDogStartupControl

  ; Apply the old English folder-name migration after install scope selection.
  !macro customInstallMode
    !define MUI_PAGE_CUSTOMFUNCTION_LEAVE LineDogNormalizeDirectory
  !macroend

  !macro customPageAfterChangeDir
    Page custom LineDogOptionsCreate LineDogOptionsLeave

    Function LineDogNormalizeDirectory
      !insertmacro GetDParameter $R0
      ${If} $R0 == ""
        ${GetFileName} "$INSTDIR" $R0
        ${If} $R0 == "LineDog"
          ${GetParent} "$INSTDIR" $R0
          StrCpy $INSTDIR "$R0\线条小狗"
        ${EndIf}
      ${EndIf}
    FunctionEnd

    Function LineDogOptionsCreate
      !insertmacro MUI_HEADER_TEXT "安装选项" "选择桌面快捷方式和开机自动启动。"
      nsDialogs::Create 1018
      Pop $0
      ${If} $0 == error
        Abort
      ${EndIf}
      ${NSD_CreateCheckbox} 0u 15u 100% 16u "创建桌面快捷方式"
      Pop $lineDogDesktopControl
      ${NSD_SetState} $lineDogDesktopControl $lineDogDesktopChoice
      ${NSD_CreateCheckbox} 0u 48u 100% 16u "开机自动启动"
      Pop $lineDogStartupControl
      ${NSD_SetState} $lineDogStartupControl $lineDogStartupChoice
      ${NSD_CreateLabel} 12u 70u 90% 34u "登录 Windows 后自动启动线条小狗。两个选项均默认勾选，可以按需取消。"
      Pop $0
      nsDialogs::Show
    FunctionEnd

    Function LineDogOptionsLeave
      ${NSD_GetState} $lineDogDesktopControl $lineDogDesktopChoice
      ${NSD_GetState} $lineDogStartupControl $lineDogStartupChoice
    FunctionEnd
  !macroend

  !macro customInstall
    ${If} $lineDogDesktopChoice == ${BST_CHECKED}
      ClearErrors
      CreateShortCut "$newDesktopLink" "$appExe" "" "$appExe" 0 "" "" "线条小狗桌面萌宠"
      ${If} ${Errors}
        MessageBox MB_OK|MB_ICONEXCLAMATION "桌面快捷方式创建失败，仍可从开始菜单启动线条小狗。" /SD IDOK
      ${Else}
        WinShell::SetLnkAUMI "$newDesktopLink" "${APP_ID}"
      ${EndIf}
    ${Else}
      Delete "$newDesktopLink"
    ${EndIf}
    ${If} $lineDogStartupChoice == ${BST_CHECKED}
      WriteRegStr SHELL_CONTEXT "${LINE_DOG_RUN_KEY}" "线条小狗" '$\"$appExe$\"'
    ${Else}
      DeleteRegValue SHELL_CONTEXT "${LINE_DOG_RUN_KEY}" "线条小狗"
    ${EndIf}
    System::Call 'Shell32::SHChangeNotify(i 0x8000000, i 0, i 0, i 0)'
  !macroend
!endif

!macro customUnInstall
  ReadRegStr $0 SHELL_CONTEXT "${LINE_DOG_RUN_KEY}" "线条小狗"
  ${If} $0 == '$\"$INSTDIR\${APP_EXECUTABLE_FILENAME}$\"'
    DeleteRegValue SHELL_CONTEXT "${LINE_DOG_RUN_KEY}" "线条小狗"
  ${EndIf}
!macroend
