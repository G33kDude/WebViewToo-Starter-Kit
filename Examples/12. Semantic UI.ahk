#Requires AutoHotkey v2

; This example displays a UI built using the Semantic UI CSS framework.

#Include ..\Lib\WebViewToo.ahk

g := WebViewGui("Resize -Caption")
g.AddTextRoute "index.html", "
(
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.4.1/semantic.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.4.1/semantic.min.js"></script>
    <style>
        body {
            padding: 0;
            margin: 0;
            display: flex;
            height: 100vh;
        }

        header {
            display: flex; position: fixed;
            color: white; background: #2185d0;
            user-select: none; width: 100vw;
        }
        header > * { padding: 5px; }
        header > span { flex-grow: 1; -webkit-app-region: drag; }
        header > div {
            cursor: pointer; font-family: Webdings;
            padding-left: 1em; padding-right: 1em;
        }
        header > div:hover { background: #1678c2; }
        header > div:last-child:hover { background: #dc3545; }
        header > div:nth-last-child(2) { display: none; }
        body.ahk-maximized header > div:nth-last-child(2) { display: block; }
        body.ahk-maximized header > div:nth-last-child(3) { display: none; }

        .sidebar {
            width: 100px;
            padding-top: 40px;
            position: fixed;
            height: 100%;
        }
        .sidebar > .ui.menu { width: 100%; }

        main {
            margin-left: 100px;
            padding: 20px;
            width: calc(100% - 100px);
            padding-top: 50px;
        }
    </style>
</head>
<body>
    <header>
        <span>Semantic UI</span>
        <div onclick="ahk.gui.Minimize()">0</div>
        <div onclick="ahk.gui.Maximize()">1</div>
        <div onclick="ahk.gui.Restore()">2</div>
        <div onclick="ahk.gui.Hide()">r</div>
    </header>

    <nav class="sidebar">
        <div class="ui secondary vertical pointing menu">
            <a class="item active" data-tab="buttons">Buttons</a>
            <a class="item" data-tab="forms">Forms</a>
            <a class="item" data-tab="modals">Modals</a>
            <a class="item" data-tab="tables">Tables</a>
        </div>
    </nav>

    <main>
        <div class="ui tab active" data-tab="buttons">
            <h3 class="ui header">Buttons</h3>
            <button onclick="ahk.global.MsgBox('Button 1')" class="ui button">Default</button>
            <button onclick="ahk.global.MsgBox('Button 2')" class="ui primary button">Primary</button>
            <button onclick="ahk.global.MsgBox('Button 3')" class="ui secondary button">Secondary</button>
        </div>

        <div class="ui tab" data-tab="forms">
            <h3 class="ui header">Forms</h3>
            <form class="ui form">
                <div class="field">
                    <label>Name</label>
                    <input type="text" placeholder="Enter name">
                </div>
                <button class="ui button" type="submit">Submit</button>
            </form>
        </div>

        <div class="ui tab" data-tab="modals">
            <h3 class="ui header">Modals</h3>
            <button class="ui button" id="show-modal">Show Modal</button>
            <div class="ui modal">
                <div class="header">Modal Title</div>
                <div class="content">
                    <p>This is a simple modal window.</p>
                </div>
                <div class="actions">
                    <button class="ui button" id="hide-modal">Close</button>
                </div>
            </div>
        </div>

        <div class="ui tab" data-tab="tables">
            <h3 class="ui header">Tables</h3>
            <table class="ui celled table">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Age</th>
                        <th>Job</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>John</td>
                        <td>30</td>
                        <td>Developer</td>
                    </tr>
                    <tr>
                        <td>Jane</td>
                        <td>28</td>
                        <td>Designer</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </main>

    <script>
        $('.menu .item').tab();
        $('#show-modal').click(function() {
            $('.ui.modal').modal('show');
        });
        $('#hide-modal').click(function() {
            $('.ui.modal').modal('hide');
        });
    </script>
</body>
</html>
)"
g.Navigate "index.html"
g.Show "w800 h600"
