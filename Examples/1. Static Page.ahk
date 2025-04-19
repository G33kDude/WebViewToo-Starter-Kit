#Requires AutoHotkey v2

; This example displays a static UI loaded from the local directory. All
; resources, including HTML and Image resources, are loaded from a folder.

#Include ..\Lib\WebViewToo\Lib\WebViewToo.ahk

; Specify any resources from the script directory that need to be available
; when the script is compiled
;@Ahk2Exe-AddResource 1. Static Page.html
;@Ahk2Exe-AddResource Image1.jpg

g := WebViewGui()
g.Navigate "1. Static Page.html"
g.Show "w800 h600"
