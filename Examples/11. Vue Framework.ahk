#Requires AutoHotkey v2

; This example displays a UI built using the Vue JavaScript framework, and
; Vuetify component framework.

#Include ..\Lib\WebViewToo.ahk

global startingStore := Map(
	"name", A_UserName
)

win := WebViewGui("Resize -Caption")

win.BrowseFolder "11. Vue Framework"
win.Navigate "index.html"
win.Show "w800 h600"

WebButtonClickEvent(button) {
	MsgBox "You clicked the " button " button"
}

FormSubmit(formData) {
	MsgBox(
		"Email: " formData.email "`n"
		"Password: " formData.password "`n"
		"Address: " formData.address "`n"
		"Address2: " formData.address2 "`n"
		"City: " formData.city "`n"
		"State: " formData.state "`n"
		"Zip: " formData.zip "`n"
		"Check: " formData.check "`n"
	)
}
