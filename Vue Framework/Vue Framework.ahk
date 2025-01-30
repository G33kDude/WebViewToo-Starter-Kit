#Requires AutoHotkey v2

global startingStore := Map(
	"name", A_UserName
)

win := WebViewTooEx(,,, True)

win.Route 'ahk.localhost', A_WorkingDir

win.AllowGlobalAccessFor 'ahk.localhost'

win.Navigate "https://ahk.localhost/index.html"
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

#Include ..\WebViewTooEx.ahk
