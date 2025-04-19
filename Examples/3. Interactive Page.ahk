#Requires AutoHotkey v2

; This example displays a UI with interactive elements. It shows basic
; integrations like pushing data to the page for display, buttons on the page to
; invoke AHK functions, and a simple form submission strategy.

#Include ..\Lib\WebViewToo\Lib\WebViewToo.ahk

g := WebViewGui("Resize")
g.AddTextRoute "index.html", "
(
<!DOCTYPE html>
<html>
<head>
    <style>div { margin-bottom: 0.5em; }</style>
</head>
<body>
    <div>
        Interactive page contents. Hello <span id="username">user</span>!
    </div>
    <div>
        <form onsubmit="submitForm(event)">
            <input type="text" name="toSend" placeholder="text to send"></input>
            <button type="submit">Submit</button>
        </form>
    </div>
    <div>
        <button onclick="ahk.global.button1()">Button 1</button>
        <button onclick="ahk.global.button2()">Button 2</button>
    </div>
    <script type="module">
        // script type="module" so we can use await

        // Set up a form submission function to pass the values to AHK
        window.submitForm = async function(event) {
            event.preventDefault();
            await ahk.global.SubmitForm({
                toSend: event.target.querySelector('[name="toSend"]').value
            });
        }

        // Populate the username element
        const name = await ahk.global.A_UserName;
        document.querySelector('#username').innerText = name;
    </script>
</body>
</html>
)"
g.Navigate "index.html"
g.Show "w800 h600"

Button1() {
    g.ExecuteScriptAsync("alert('hi')")
    MsgBox "You clicked button 1"
}

Button2() {
    MsgBox "You clicked button 2"
}

SubmitForm(data) {
    MsgBox data.toSend
}
