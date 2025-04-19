#Requires AutoHotkey v2

; This example displays a UI where the system default title bar has been
; disabled and replace with a completely custom title bar implemented in HTML
; and CSS.

#Include ..\Lib\WebViewToo\Lib\WebViewToo.ahk

g := WebViewGui("Resize -Caption")
g.AddTextRoute "index.html", "
(
<!DOCTYPE html>
<html>
<head>
    <style>
        html, body { margin: 0; padding: 0; font-family: sans-serif; }
        body { display: flex; flex-direction: column; width: 100vw; height: 100vh; }
        header { display: flex; color: white; background: gray; user-select: none; }
        header > * { padding: 5px; }
        header > span { flex-grow: 1; -webkit-app-region: drag; }
        .title-btn { cursor: pointer; font-family: Webdings; font-size: 11pt; }
        .title-btn:hover { background: rgba(0, 0, 0, .2); }
        .title-btn-close:hover { background: #dc3545; }
        .title-btn-restore { display: none; }
        body.ahk-maximized .title-btn-restore { display: block; }
        body.ahk-maximized .title-btn-maximize { display: none; }
        main { overflow: auto; flex: 1; padding: 0.5em; }
        main > div { margin-bottom: 0.5em; }
    </style>
</head>
<body>
    <header>
        <span>Custom Title Bar</span>
        <div class='title-btn title-btn-minimize' onclick="ahk.gui.Minimize()">0</div>
        <div class='title-btn title-btn-maximize' onclick='ahk.gui.Maximize()'>1</div>
        <div class='title-btn title-btn-restore' onclick='ahk.gui.Restore()'>2</div>
        <div class='title-btn title-btn-close' onclick="ahk.gui.Hide()">r</div>
    </header>

    <main>
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
    </main>

    <!-- script type="module" so we can use await -->
    <script type="module">
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
    MsgBox "You clicked button 1"
}

Button2() {
    MsgBox "You clicked button 2"
}

SubmitForm(data) {
    MsgBox data.toSend
}
