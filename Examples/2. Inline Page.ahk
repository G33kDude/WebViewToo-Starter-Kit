#Requires AutoHotkey v2

; This example displays a static UI where the HTML is inside the AutoHotkey
; script file. Other resources, like images, are still loaded from the local
; directory.


#Include ..\Lib\WebViewToo\Lib\WebViewToo.ahk

; Specify any resources from the script directory that need to be available
; when the script is compiled
;@Ahk2Exe-AddResource Image2.jpg

g := WebViewGui()

g.AddTextRoute "index.css", 'body { font-family: sans-serif; }'
g.AddTextRoute "index.html", "
(
<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" type="text/css" href="index.css">
</head>
<body>
    <p>
        Neutron Star (Kevin M. Gill)<br>
        https://www.flickr.com/photos/kevinmgill/14773475650 (CC BY 2.0)
    </p>
    <img src="Image2.jpg" style="max-width: 100%;">
</body>
</html>
)"

; Because AddText was used, the default working directory browsing was disabled.
; Any files we want to be available must be added manually.
g.AddFileRoute "Image2.jpg"

g.Navigate "index.html"
g.Show "w800 h600"
