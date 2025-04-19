#Requires AutoHotkey v2

; This example displays a UI where some of the resources are loaded using custom
; script logic. In the other examples, when defining routes to resources, those
; resources (or paths to those resources) are hard-coded into the script. In
; this example, we demonstrate how resources can be supplied dynamically at
; run-time based on the path it was requested from.

#Include ..\Lib\WebViewToo\Lib\WebViewToo.ahk

g := WebViewGui("Resize")

g.AddTextRoute "index.html", "
( ; html
<!doctype html><html>
<head>
	<script type="module" src="./index.js"></script>
	<style>div { margin-bottom: 0.5em }</style>
</head>
<body>
	<div>Hello <span id="username"></span>!<br></div>
	<div>
		<input type="text" id="requestPath" value="someValue">
		<button id="dynamicRequest">Dynamic Request</button>
	</div>
	<div>
		<a href="//helpfile.localhost/docs/index.htm">Go to help file</a>
	</div>
	<div>
		Access resource from file:
		<pre></pre>
	</div>
</body>
)"

g.AddTextRoute "index.js", "
( ; js
document.querySelector("#dynamicRequest").addEventListener("click", (event) => {
	fetch("/api/" + encodeURIComponent(document.querySelector("#requestPath").value))
})

const response = await fetch("/api/name")
const name = await response.text()
document.querySelector("#username").innerText = name

document.querySelector("pre").innerText = await (await fetch("/script.ahk")).text()
)"

; Resource from file
g.AddFileRoute A_ScriptFullPath, '/script.ahk'

; Dynamic callback
g.AddRoute '/api/*', (uri) => MsgBox('Request for ' uri.Path)

; Resource generated at runtime
g.AddRoute '/api/name', (uri) => A_UserName

; Map helpfile.localhost URLs to the contents of AutoHotkey.chm
g.AddRoute "**", loadFromChm, "helpfile.localhost"

; Inject our own modifications to the CHM
g.Control.wv.add_NavigationCompleted FixChm

; Show the page
g.Navigate "index.html"
g.Show "w800 h600"


NormalizePath(path) {
	cc := DllCall("GetFullPathName", "str", path, "uint", 0, "ptr", 0, "ptr", 0, "uint")
	buf := Buffer(cc * 2)
	DllCall("GetFullPathName", "str", path, "uint", cc, "ptr", buf, "ptr", 0)
	return StrGet(buf)
}

loadFromChm(uri) {
	static chmPath := NormalizePath(A_AhkPath "\..\AutoHotkey.chm")
	static xhr := ComObject("MSXML2.XMLHTTP.3.0")
	xhr.open("GET", "ms-its:" chmPath "::" uri.Path, True)
	try {
		xhr.send()
		rBody := xhr.responseBody
		return WebView2.CreateMemStream(NumGet(ComObjValue(rBody), 8+A_PtrSize, "Ptr"), rBody.MaxIndex())
	}
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
