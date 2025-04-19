#Requires AutoHotkey v2

; Run me!

#Include Lib\WebViewToo.ahk

g := WebViewGui("Resize")

g.AddTextRoute "index.html", "
( ; html
<!doctype html>
<html>
<head>
    <link rel="stylesheet" type="text/css" href="index.css">
    <script type="module" src="index.js"></script>
</head>
<body>

<h1>WebViewToo</h1>

<p>
    <code>WebViewGui</code> is a variant of the built-in Gui, so all the normal
    Gui stuff should work. Settings like <code>-Caption</code> and <code
    >+Resize</code> work great out of the box.
</p>
<p>
    The main difference between <code>Gui</code> and <code>WebViewGui</code> is
    that where <code>Gui</code> has methods to add controls to the window, <code
    >WebViewGui</code> as methods to add files and other resources to the
    virtual web environment.
</p>
<p>
    If no files or other resources are added, files will be loaded from the
    working directory by default. When a script is compiled,
    <code>WebViewGui</code> browses the EXE resources by default rather than the
    working directory, so any files added to the exe resources are available in
    that case. Files can be added to the EXE resources using
    <code>;@Ahk2Exe-AddResource</code> or <code>FileInstall</code>.
</p>


<!--
<h2 id="installation-instructions">Browse Documentation</h2>
<a href="//docs.localhost/index.html">Click here to browse the documentation</a>
-->


<h2 id="installation-instructions">Installation Instructions</h2>
<p>Copy the file <code>Dist\WebGui.ahk</code> to your Lib folder at
<code>My Documents\AutoHotkey\Lib</code>. You may need to create the folder if
it does not already exist.</p>


<h2 id="examples">Examples</h2>

<h3 id="1-static-page">1. Static Page</h3>
<p>
    This example displays a static UI loaded from the local directory. All
    resources, including HTML and Image resources, are loaded from a folder.
</p>
<button onclick='ahk.global.Run("\"Examples\\1. Static Page.ahk\"")'>Run Example</button>
<button onclick='ahk.global.Run("edit \"Examples\\1. Static Page.ahk\"")'>Edit Example</button>

<h3 id="2-inline-page">2. Inline Page</h3>
<p>
    This example displays a static UI where the HTML is inside the AutoHotkey
    script file. Other resources, like images, are still loaded from the local
    directory.
</p>
<button onclick='ahk.global.Run("\"Examples\\2. Inline Page.ahk\"")'>Run Example</button>
<button onclick='ahk.global.Run("edit \"Examples\\2. Inline Page.ahk\"")'>Edit Example</button>

<h3 id="3-interactive-page">3. Interactive Page</h3>
<p>
    This example displays a UI with interactive elements. It shows basic
    integrations like pushing data to the page for display, buttons on the page
    to invoke AHK functions, and a simple form submission strategy.
</p>
<button onclick='ahk.global.Run("\"Examples\\3. Interactive Page.ahk\"")'>Run Example</button>
<button onclick='ahk.global.Run("edit \"Examples\\3. Interactive Page.ahk\"")'>Edit Example</button>

<h3 id="4-custom-title-bar">4. Custom Title Bar</h3>
<p>
    This example displays a UI where the system default title bar has been
    disabled and replace with a completely custom title bar implemented in
    HTML and CSS.
</p>
<button onclick='ahk.global.Run("\"Examples\\4. Custom Title Bar.ahk\"")'>Run Example</button>
<button onclick='ahk.global.Run("edit \"Examples\\4. Custom Title Bar.ahk\"")'>Edit Example</button>

<h3 id="5-use-in-regular-gui">5. Use in Regular GUI</h3>
<p>
    This example demonstrates how you can embed WebViewToo as a control on an
    otherwise normal AutoHotkey GUI.
</p>
<button onclick='ahk.global.Run("\"Examples\\5. Use in Regular Gui.ahk\"")'>Run Example</button>
<button onclick='ahk.global.Run("edit \"Examples\\5. Use in Regular Gui.ahk\"")'>Edit Example</button>

<h3 id="6-multiple-pages">6. Multiple Pages</h3>
<p>
    This example demonstrates how you can build a UI that uses multiple HTML
    pages, accessible by tab-style navigation links.
</p>
<button onclick='ahk.global.Run("\"Examples\\6. Multiple Pages.ahk\"")'>Run Example</button>
<button onclick='ahk.global.Run("edit \"Examples\\6. Multiple Pages.ahk\"")'>Edit Example</button>

<h3 id="7-single-page-app">7. Single Page App</h3>
<p>
    This example demonstrates how you can build a UI that simulates the
    experience of having multiple pages, using JavaScript to create a real
    tab-style interface that hides and shows different sections of the UI.
</p>
<button onclick='ahk.global.Run("\"Examples\\7. Single Page App.ahk\"")'>Run Example</button>
<button onclick='ahk.global.Run("edit \"Examples\\7. Single Page App.ahk\"")'>Edit Example</button>

<h3 id="8-inline-resources">8. Inline Resources</h3>
<p>
    This example displays a static UI where the HTML <em>and other non-text
    resources</em> are inside the AutoHotkey script file.
</p>
<button onclick='ahk.global.Run("\"Examples\\8. Inline Resources.ahk\"")'>Run Example</button>
<button onclick='ahk.global.Run("edit \"Examples\\8. Inline Resources.ahk\"")'>Edit Example</button>

<h3 id="9-custom-resource-loading">9. Custom Resource Loading</h3>
<p>
    This example displays a UI where some of the resources are loaded using
    custom script logic. In the other examples, when defining routes to
    resources, those resources (or paths to those resources) are hard-coded into
    the script. In this example, we demonstrate how resources can be supplied
    dynamically at run-time based on the path it was requested from.
</p>
<button onclick='ahk.global.Run("\"Examples\\9. Custom Resource Loading.ahk\"")'>Run Example</button>
<button onclick='ahk.global.Run("edit \"Examples\\9. Custom Resource Loading.ahk\"")'>Edit Example</button>

<h3 id="10-bootstrap">10. Bootstrap</h3>
<p>
    This example displays a UI built using the Bootstrap CSS framework.
</p>
<button onclick='ahk.global.Run("\"Examples\\10. Bootstrap.ahk\"")'>Run Example</button>
<button onclick='ahk.global.Run("edit \"Examples\\10. Bootstrap.ahk\"")'>Edit Example</button>

<h3 id="11-vue">11. Vue Framework</h3>
<p>
    This example displays a UI built using the Vue JavaScript framework, and
    Vuetify component framework.
</p>
<button onclick='ahk.global.Run("\"Examples\\11. Vue Framework.ahk\"")'>Run Example</button>
<button onclick='ahk.global.Run("edit \"Examples\\11. Vue Framework.ahk\"")'>Edit Example</button>

<h3 id="11-vue">12. Semantic UI</h3>
<p>
    This example displays a UI built using the Semantic UI CSS framework.
</p>
<button onclick='ahk.global.Run("\"Examples\\12. Semantic UI.ahk\"")'>Run Example</button>
<button onclick='ahk.global.Run("edit \"Examples\\12. Semantic UI.ahk\"")'>Edit Example</button>

<h3 id="file-encoder">File Encoder</h3>
<p>
    Takes an input file (text or binary like png) and compresses it into an
    AutoHotkey function that will return a <code>Buffer</code> with the original
    file contents. The output function can be used to embed resources like image
    files into your script so they can be loaded later in the web view.
</p>
<button onclick='ahk.global.Run("\"Examples\\File Encoder.ahk\"")'>Run Example</button>
<button onclick='ahk.global.Run("edit \"Examples\\File Encoder.ahk\"")'>Edit Example</button>

<h3 id="script-packager">Script Packager</h3>
<p>
    Takes an input script file and generates a combined script that incorporates
    all other files that were specified by <code>#Include</code>. Offers options
    to remove extraneous whitespace and comments. Note that, if you choose to
    remove comments, you may need to re-add any required licensing information
    comments before the combined script can be legally distributed.
</p>
<button onclick='ahk.global.Run("\"Examples\\Script Packager.ahk\"")'>Run Example</button>
<button onclick='ahk.global.Run("edit \"Examples\\Script Packager.ahk\"")'>Edit Example</button>

</body>
</html>
)"
g.AddTextRoute "index.css", "
( ; css

body { font-family: sans-serif; margin: 1em; }
code { background: #DDD; border-radius: .25em; padding: .1em; }
p { line-height: 1.5em; }

)"

; g.BrowseFolder "Docs", "docs.localhost"

g.Navigate "index.html"
g.Show "w800 h600"