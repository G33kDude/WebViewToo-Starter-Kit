#Requires AutoHotkey v2

; This example demonstrates how you can embed WebViewToo as a control on an
; otherwise normal AutoHotkey GUI.

#Include ..\Lib\WebViewToo.ahk

g := Gui("Resize")
g.MarginX := 5, g.MarginY := 5
g.AddEdit "w700 h20 vAddress", "file:///" A_WorkingDir
g.AddButton "yp w95 h20 vGo", "Go"
WebViewCtrl g, "xm w800 h600 vWebControl"
g["WebControl"].Navigate("data:text/html,Use the GO button to browse")
g.OnEvent "Size", Size
g.Show

g["Go"].OnEvent("Click", Go)

Go(btn, info) {
    btn.gui["WebControl"].Navigate(
        btn.gui["Address"].value
    )
}

Size(GuiObj, MinMax, Width, Height) {
    g["Address"].Move(,, Width - 110)
    g["Go"].Move(Width - 105)
    g["WebControl"].Move(,, Width - 10, Height - 35)
}
