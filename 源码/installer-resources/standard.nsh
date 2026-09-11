!include "${BUILD_RESOURCES_DIR}\ui.nsh"
!include "${BUILD_RESOURCES_DIR}\options.nsh"

!macro customInit
  ${IfNot} ${AtLeastWin10}
    MessageBox MB_OK|MB_ICONEXCLAMATION "此安装包需要 Windows 10 或 Windows 11。"
    SetErrorLevel 1
    Quit
  ${EndIf}
  StrCpy $lineDogDesktopChoice ${BST_CHECKED}
  StrCpy $lineDogStartupChoice ${BST_CHECKED}
!macroend
