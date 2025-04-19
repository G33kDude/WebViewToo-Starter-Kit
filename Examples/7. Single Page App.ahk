#Requires AutoHotkey v2

; This example demonstrates how you can build a UI that simulates the experience
; of having multiple pages, using JavaScript to create a real tab-style
; interface that hides and shows different sections of the UI.

#Include ..\Lib\WebViewToo\Lib\WebViewToo.ahk

; Specify any resources from the script directory that need to be available
; when the script is compiled
;@Ahk2Exe-AddResource Image1.jpg
;@Ahk2Exe-AddResource Image2.jpg
;@Ahk2Exe-AddResource Image3.jpg

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

        nav { background: gray; padding: 0 5px; -webkit-app-region: drag; display: flex; }
        nav > a {
            user-select: none;
            margin-right: 5px; padding: 5px;
            -webkit-app-region: no-drag;
            background-color: silver;
            color: black;
            text-decoration: none;
            border-radius: 5px 5px 0 0;
            cursor: pointer;
        }
        nav > a.active { background: white; }

        main { overflow: auto; flex: 1; padding: 0.5em; }
        main > div { margin-bottom: 0.5em; }

        img { max-width: 100%; border-radius: 0.25em; margin: 0.5em 0; }
    </style>
</head>
<body>
    <header>
        <span>Page 1</span>
        <div class='title-btn title-btn-minimize' onclick="ahk.gui.Minimize()">0</div>
        <div class='title-btn title-btn-maximize' onclick='ahk.gui.Maximize()'>1</div>
        <div class='title-btn title-btn-restore' onclick='ahk.gui.Restore()'>2</div>
        <div class='title-btn title-btn-close' onclick="ahk.gui.Hide()">r</div>
    </header>
    <nav>
        <a onclick="navigate(event, 'page1')" class="active">Page 1</a>
        <a onclick="navigate(event, 'page2')">Page 2</a>
        <a onclick="navigate(event, 'page3')">Page 3</a>
    </nav>

    <main>
        <div class="page" id="page1">
            <p>
                Superfluid in Neutron Star's Core (NASA, Chandra, Hubble, 02/23/11)<br>
                Credit: X-ray: NASA/CXC/xx; Optical: NASA/STScI; Illustration: NASA/CXC/M.Weiss<br>
                https://www.flickr.com/photos/nasamarshall/5474156466/in/photostream/ (CC BY-NC 2.0)
            </p>
            <img src="Image1.jpg" alt="False color galaxy with artist's illustration of neutron star">
        </div>
        <div class="page" id="page2" style="display: none;">
            <p>
                Neutron Star (Kevin M. Gill)<br>
                https://www.flickr.com/photos/kevinmgill/14773475650 (CC BY 2.0)
            </p>
            <img src="Image2.jpg" alt="Artist's rendition of Neutron star">
        </div>
        <div class="page" id="page3" style="display: none;">
            <p>
                Artist's impression of merging neutron stars (University of Warwick/Mark Garlick)<br>
                https://www.eso.org/public/images/eso1733s/ (CC BY 4.0)
            </p>
            <img src="Image3.jpg" alt="Artist's impression of merging neutron stars">
        </div>
    </main>

    <script>
        function navigate(event, pageId) {
            // Change the title bar to say the new page name
            document.querySelector('header > span').innerText = event.target.innerText;

            // Update the nav links to highlight the active page
            document.querySelectorAll("nav > a").forEach(e => e.classList.remove('active'));
            event.target.classList.add('active');

            // Show the new page contents
            document.querySelectorAll(".page").forEach(e => e.style.display = 'none');
            document.getElementById(pageId).style.display = 'block';
        }
    </script>
</body>
</html>
)"

; Because AddText was used, the default working directory browsing was disabled.
; Any files we want to be available must be added manually.
g.AddFileRoute "Image1.jpg"
g.AddFileRoute "Image2.jpg"
g.AddFileRoute "Image3.jpg"

g.Navigate "index.html"
g.Show "w800 h600"
