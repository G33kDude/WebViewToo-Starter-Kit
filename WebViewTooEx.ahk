
#Include WebViewToo\Lib\WebViewToo.ahk
#Include Uri.ahk

class WebViewTooEx extends WebViewToo {

	/** List of hosts allowed to access names in AHK's global scope */
	_allowGlobalHosts := Map()

	__New(p*) {
		super.__New(p*)

		; Add handler for installing the `ahk.global` accessor proxy into the
		; JavaScript environment.
		this.NavigationStarting(InstallGlobal)
		InstallGlobal(ICoreWebView2, Args) {
			static proxy := { __Get: (this, name, *) => %name% }
			if this._allowGlobalHosts.Has(Uri(Args.Uri).getHost()) {
				try ICoreWebView2.AddHostObjectToScript("global", proxy)
			} else {
				try ICoreWebView2.RemoveHostObjectFromScript("global")
			}
		}
	}

	Route(host, routes) {
		NormalizePath(path) {
			cc := DllCall("GetFullPathName", "str", path, "uint", 0, "ptr", 0, "ptr", 0, "uint")
			buf := Buffer(cc*2)
			DllCall("GetFullPathName", "str", path, "uint", cc, "ptr", buf, "ptr", 0)
			return StrGet(buf)
		}

		if routes is String && FileExist(routes) ~= "D" {
			this.SetVirtualHostNameToFolderMapping host, NormalizePath(routes), WebView2.HOST_RESOURCE_ACCESS_KIND.ALLOW
			return
		}

		if routes is String && routes ~= "\.chm$" && FileExist(routes) ~= "A" {
			tryLoad(path, uri) {
				static xhr := ComObject("MSXML2.XMLHTTP.3.0")
				xhr.open("GET", "ms-its:" NormalizePath(path) "::" uri.getPath(), True)
				try {
					xhr.send()
					rBody := xhr.responseBody
					return WebView2.CreateMemStream(NumGet(ComObjValue(rBody), 8+A_PtrSize, "Ptr"), rBody.MaxIndex())
				}
			}
			routes := [['/**', tryLoad.Bind(routes)]]
		}

		fullReg := ""
		for route in routes {
			pattern := "^(\Q" StrReplace(route[1], "\E", "\E\\E\Q") "\E)$(?C" A_Index ":Callout)"
			pattern := StrReplace(pattern, "**", "\E.{0,}?\Q")
			pattern := StrReplace(pattern, "*", "\E[^\/\\]{0,}?\Q")
			fullReg .= "|" pattern
		}
		fullReg := "S)" SubStr(fullReg, 2)
		this.AddWebResourceRequestedFilter("https://" host "/*", 0)
		this.WebResourceRequested(CreateWebpageFromWebResource)
		CreateWebpageFromWebResource(ICoreWebView2, Args) {
			parsed := Uri(Args.Request.Uri)
			if parsed.getHost() != host
				return

			path := parsed.getPath()

			res := RegExMatch(path, fullReg)
			if !IsSet(target)
				return

			callout(match, num, pos, haystack, needle) {
				target := routes[num][2]
				return -1
			}

			if target is Object && !(target is Buffer)
				try target := target(parsed)

			if target is Buffer {
				stream := WebView2.CreateMemStream(target)
				Args.Response := ICoreWebView2.Environment.CreateWebResourceResponse(stream, 200, "OK", "")
				return
			}

			if target is String {
				headers := ""
				if path ~= "\.js$"
					headers .= "Content-Type: text/javascript;"
				stream := WebView2.CreateTextStream(target)
				Args.Response := ICoreWebView2.Environment.CreateWebResourceResponse(stream, 200, "OK", headers)
				return
			}

			if target is WebView2.Stream {
				Args.Response := ICoreWebView2.Environment.CreateWebResourceResponse(target, 200, "OK", "")
				return
			}
		}
	}

	AllowGlobalAccessFor(host) => this._allowGlobalHosts[host] := true
}