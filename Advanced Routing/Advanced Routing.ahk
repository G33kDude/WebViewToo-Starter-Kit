#Requires AutoHotkey v2

; Demonstrates advanced usage of the routing functions of WebViewTooEx, to load
; resources from a variety of places like Strings, Buffers, Files, Directories,
; CHM Files, and dynamic generation.

; HTML content for the page
html := "
( ; html
<!doctype html><html>
<head>
	<script type="module" src="./index.js"></script>
	<style>div { margin-bottom: 0.5em }</style>
</head>
<body>
	<div><img src="./image.png" /></div>
	<div>Hello <span id="username"></span>!<br></div>
	<div>
		<input type="text" id="requestPath" value="someValue">
		<button id="dynamicRequest">Dynamic Request</button>
	</div>
	<div><button onClick="ahk.global.Callback()">Direct global access</button></div>
	<div>
		<a href="//bootstrap.localhost/index.html">Go to Bootstrap example</a>
		<a href="//helpfile.localhost/docs/index.htm">Go to help file</a>
	</div>
	<div>
		Access resource from file:
		<pre></pre>
	</div>
</body>
)"

; JavaScript content for the page
script := "
( ; js
document.querySelector("#dynamicRequest").addEventListener("click", (event) => {
	fetch("/api/" + encodeURIComponent(document.querySelector("#requestPath").value))
})

const response = await fetch("/api/name")
const name = await response.text()
document.querySelector("#username").innerText = name

document.querySelector("pre").innerText = await (await fetch("/script.ahk")).text()
)"

win := WebViewTooEx()

; Map ahk.localhost URLs to these resources
win.Route 'ahk.localhost', [
	; Resource from string
	['/index.html', html],
	['/index.js', script],

	; Resource from Base64
	['/image.png', image()],

	; Resource from file
	['/script.ahk', FileRead(A_ScriptFullPath, "RAW")],

	; Resource generated at runtime
	['/api/name', (uri) => A_UserName],

	; Dynamic callback
	['/api/*', (uri) => MsgBox('Request for ' String(uri))],
]

; Allow ahk.localhost pages to use AHK variables and functions by direct access
win.AllowGlobalAccessFor 'ahk.localhost'

; Map bootstrap.localhost URLs to the Pages folder
win.Route 'bootstrap.localhost', '..\WebViewToo\Pages'

; Map helpfile.localhost URLs to the contents of AutoHotkey.chm
win.Route 'helpfile.localhost', A_AhkPath "\..\AutoHotkey.chm"

; Inject our own modifications to the CHM
win.NavigationCompleted FixChm

; Show the page
win.Navigate "https://ahk.localhost/index.html"
win.Show

Callback(p*) {
	MsgBox "Direct callback"
}


/**
 * This function forces the help file to show the offline toolbar instead of the
 * online toolbar.
 *
 * Normally, the help file JavaScript does not detect that it is being used
 * offline when it is loaded in WebView2. By injecting some of our own
 * JavaScript, we can force it to show the offline toolbar instead of the online
 * toolbar. We do not want to actually tell it that it is running inside a chm
 * environment though, because that enables some compatibility changes that will
 * actually reduce compatibility with the WebView2 renderer.
 *
 * @param ICoreWebView2 {WebView2.Core}
 * @param args {WebView2.NavigationCompletedEventArgs}
 */
FixChm(ICoreWebView2, Args) {
	if !(ICoreWebView2.source ~= "^https://helpfile.localhost/")
		return
	ICoreWebView2.ExecuteScriptAsync("
	(
	$(document).ready(() => {
		const online = $('#head .h-tools.online')
		const chm = $('#head .h-tools.chm')
		const oldModifyTools = structure.modifyTools
		structure.modifyTools = (relPath, equivPath) => {
			oldModifyTools(relPath, equivPath)
			online.hide().removeClass('visible')
			chm.show().addClass('visible')
		}
		online.hide().removeClass('visible')
		chm.show().addClass('visible')
	})
	)")
}

#Include image.ahk
#Include ..\WebViewTooEx.ahk
