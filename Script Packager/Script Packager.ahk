#Requires AutoHotkey v2

; Takes an input script file and generates a combined script that incorporates
; all other files that were specified by #Include. Offers options to remove
; extraneous whitespace and comments. Note that some included library files may
; contain licensing information that would need to be re-added before the
; combined script can be distributed.

; The file to package
TargetFile := ""

; HTML content for the page
html := "
( ; html
<!doctype html><html>
<head>
	<script type="module" src="./index.js"></script>
	<link rel="stylesheet" href="./normalize.css">
	<link rel="stylesheet" href="./skeleton.css">
	<style>body { margin: 1em; }</style>
</head>
<body>
	<div class="row">
		<div class="six columns">
			<label for="chooseFile">File <span id="chosenFile">...</span></label>
			<button
				id="chooseFile"
				class="u-full-width"
			>Choose File</button>
		</div>
		<div class="six columns">
			<label>
				<input type="checkbox" id="keepComments">
				<span class="label-body">Keep Comments</span>
			</label>
			<label>
				<input type="checkbox" id="keepWhitespace">
				<span class="label-body">Keep Whitespace</span>
			</label>
		</div>
	</div>
	<button id="convert" class="u-full-width button-primary">Package</button>
	<textarea
		readonly
		id="output"
		class="u-full-width"
		style="font: 10px monospace; height: 400px; resize: vertical"
	></textarea>
</body>
</html>
)"

; JavaScript content for the page
script := "
( ; js
const chooseFile = document.getElementById("chooseFile")
const chosenFile = document.getElementById("chosenFile")
const keepComments = document.getElementById("keepComments")
const keepWhitespace = document.getElementById("keepWhitespace")
const convert = document.getElementById("convert")
const output = document.getElementById("output")

chooseFile.addEventListener("click", async () => {
	chosenFile.innerText = (await ahk.global.ChooseFile()).split("\\").pop()
})

convert.addEventListener("click", async () => {
	output.value = await ahk.global.Convert(keepWhitespace.checked, keepComments.checked)
})
)"

win := WebViewTooEx()

; Map ahk.localhost URLs to these resources
win.Route 'ahk.localhost', [
	['/index.html', html],
	['/index.js', script],
	['/normalize.css', Normalize()],
	['/skeleton.css', Skeleton()],
]

; Allow ahk.localhost pages to use AHK variables and functions by direct access
win.AllowGlobalAccessFor 'ahk.localhost'

; Show the page
win.Navigate "https://ahk.localhost/index.html"
win.Show "w800 h600"

ChooseFile() {
	global TargetFile
	return TargetFile := FileSelect(,,, "AutoHotkey Script (*.ahk)")
}

Convert(keepWhitespace, keepComments) {
	if !TargetFile
		return ""

	PreprocessScript(&scriptText := "", TargetFile,,,,, {
		keepWhitespace: keepWhitespace,
		keepComments: keepComments,
	})

	return scriptText
}

;
; Based on code from fincs' Ahk2Exe - https://github.com/fincs/ahk2exe (WTFPL)
;
PreprocessScript(&scriptText, ahkScriptPath, fileList := [], firstScriptDir := "", iOption := 0, derefIncludeVars := unset, options?) {
	NormalizePath(path) {
		cc := DllCall("GetFullPathName", "str", path, "uint", 0, "ptr", 0, "ptr", 0, "uint")
		buf := Buffer(cc * 2)
		DllCall("GetFullPathName", "str", path, "uint", cc, "ptr", buf, "ptr", 0)
		return StrGet(buf)
	}

	IsRealContinuationSection(trimmedLine) {
		loop parse trimmedLine, " `t"
			if !(A_LoopField ~= "i)^Join") && InStr(A_LoopField, ")")
				return false
		return true
	}

	FindLibraryFile(name, ScriptDir) {
		libs := [ScriptDir "\Lib", A_MyDocuments "\AutoHotkey\Lib", A_AhkPath "\..\Lib"] ; TODO: Use target ahk path
		p := InStr(name, "_")
		if p
			name_lib := SubStr(name, 1, p - 1)

		for each, lib in libs {
			file := lib "\" name ".ahk"
			If FileExist(file)
				return file

			if !p
				continue

			file := lib "\" name_lib ".ahk"
			If FileExist(file)
				return file
		}
	}

	DerefIncludePath(path, vars) {
		static SharedVars := Map("A_AhkPath", 1, "A_AppData", 1,
			"A_AppDataCommon", 1, "A_ComputerName", 1, "A_ComSpec", 1,
			"A_Desktop", 1, "A_DesktopCommon", 1, "A_MyDocuments", 1,
			"A_ProgramFiles", 1, "A_Programs", 1, "A_ProgramsCommon", 1,
			"A_Space", 1, "A_StartMenu", 1, "A_StartMenuCommon", 1, "A_Startup", 1,
			"A_StartupCommon", 1, "A_Tab", 1, "A_Temp", 1, "A_UserName", 1,
			"A_WinDir", 1)
		p := StrSplit(path, "%"), path := p[1], n := 2
		while n < p.Length {
			path .= vars.Has(p[n]) ? vars[p[n++]] . p[n++]
				: SharedVars.Has(p[n]) ? %SharedVars[p[n++]]% . p[n++]
					: "%" p[n++]
		}
		return n > p.Length ? path : path "%" p[n]
	}

	options := options ?? {}

	isFirstScript := fileList.Length == 0

	; Stage the environment for processing the file
	SplitPath NormalizePath(ahkScriptPath), &scriptName, &scriptDir
	if isFirstScript {
		fileList.Push(ahkScriptPath)
		scriptText := ""
		firstScriptDir := scriptDir
		tempWD := CTempWD(scriptDir)
		derefIncludeVars := Map(
			"A_IsCompiled", true,
			"A_LineFile", "",
			"A_AhkVersion", A_AhkVersion, ; TODO: use target ahk version
			"A_ScriptFullPath", ahkScriptPath,
			"A_ScriptName", scriptName,
			"A_ScriptDir", scriptDir,
		)
	}
	oldLineFile := derefIncludeVars["A_LineFile"]
	derefIncludeVars["A_LineFile"] := ahkScriptPath
	oldWorkingDir := A_WorkingDir
	SetWorkingDir scriptDir

	if !FileExist(ahkScriptPath) {
		if iOption
			throw Error((isFirstScript ? "Script" : "#include") " file cannot be opened.", , ahkScriptPath)
		else
			return
	}

	inCommentBlock := false, inContinuationSection := false
	Loop read ahkScriptPath {
		trimmedIfNotKeepWhitespace := trimmedLine := Trim(A_LoopReadLine)
		if (options.HasProp('keepWhitespace') && options.keepWhitespace)
			trimmedIfNotKeepWhitespace := A_LoopReadLine

		; Handle comment block contents
		if inCommentBlock {
			if trimmedLine ~= "^\*/|\*/$"
				inCommentBlock := false
			if options.HasProp('keepComments') && options.keepComments
				scriptText .= trimmedIfNotKeepWhitespace "`n"
			continue
		}

		; Handle extraneous text
		if !inContinuationSection {
			if trimmedLine ~= "^;" { ; Single-line comment
				if options.HasProp('keepComments') && options.keepComments
					scriptText .= trimmedIfNotKeepWhitespace "`n"
				continue
			} else if trimmedLine = "" { ; Blank lines
				if options.HasProp('keepWhitespace') && options.keepWhitespace
					scriptText .= A_LoopReadLine "`n"
				continue
			} else if trimmedLine ~= "^/\*" { ; Block comments
				inCommentBlock := !(trimmedLine ~= "\*/$")
				if options.HasProp('keepComments') && options.keepComments
					scriptText .= trimmedIfNotKeepWhitespace "`n"
				continue
			}
		}

		; Enter a continuation section
		if trimmedLine ~= "^\(" && IsRealContinuationSection(SubStr(trimmedLine, 2))
			inContinuationSection := true
		; Or exit a continuation section
		else if trimmedLine ~= "^\)"
			inContinuationSection := false

		if inContinuationSection {
			scriptText .= A_LoopReadLine "`n"
			continue
		}

		; Remove trailing comment
		trimmedLine := RegExReplace(trimmedLine, "\s+;.*$")

		; #Include lines
		if RegExMatch(trimmedLine, "i)^#Include(?<again>Again)?\s*[,\s]\s*(?<file>.*)$", &match) {
			includeFile := Trim(match.file, "`"' `t")
			includeFile := RegExReplace(includeFile, "i)^\*i\s+", , &ignoreErrors)

			; References to embedded scripts have a filename which starts with *
			; and will be handled by the interpreter
			if SubStr(includeFile, 1, 1) = "*" {
				scriptText .= A_LoopReadLine "`n"
				continue
			}
			if RegExMatch(includeFile, "^<(.+)>$", &match) {
				if foundFile := FindLibraryFile(match.1, firstScriptDir)
					includeFile := foundFile
			} else {
				includeFile := DerefIncludePath(includeFile, derefIncludeVars)
				if FileExist(includeFile) ~= "D" {
					SetWorkingDir includeFile
					scriptText .= A_LoopReadLine "`n"
					continue
				}
			}

			includeFile := NormalizePath(includeFile)

			; Determine whether the file is already included
			alreadyIncluded := false
			for k, v in fileList
				if v = includeFile
					alreadyIncluded := true
			until alreadyIncluded

			; Add to the list
			if !alreadyIncluded
				fileList.Push(includeFile)

			; Include the text where applicable
			if !alreadyIncluded || match.again
				PreprocessScript(&scriptText, includeFile, fileList, firstScriptDir, ignoreErrors, derefIncludeVars, options)
			continue
		}

		if !options.HasProp('keepComments') || !options.keepComments
			trimmedIfNotKeepWhitespace := RegExReplace(trimmedIfNotKeepWhitespace, "\s+;.*$")
		scriptText .= trimmedIfNotKeepWhitespace "`n"
	}

	; Restore calling context
	derefIncludeVars["A_LineFile"] := oldLineFile
	SetWorkingDir oldWorkingDir
}

class CTempWD {
	__New(newWD) {
		this.oldWD := A_WorkingDir
		SetWorkingDir newWD
	}
	__Delete() {
		SetWorkingDir this.oldWD
	}
}

;
; normalize.css v8.0.1
; MIT License
; https://github.com/necolas/normalize.css
;
Normalize() => "
(LTrim Join
html{line-height:1.15;-webkit-text-size-adjust:100%}body{margin:0}main{display:block}h1{font-size:2em;margin:.67em 0}hr{
box-sizing:content-box;height:0;overflow:visible}pre{font-family:monospace,monospace;font-size:1em}a{background-color:tr
ansparent}abbr[title]{border-bottom:none;text-decoration:underline;text-decoration:underline dotted}b,strong{font-weight
:bolder}code,kbd,samp{font-family:monospace,monospace;font-size:1em}small{font-size:80%}sub,sup{font-size:75%;line-heigh
t:0;position:relative;vertical-align:baseline}sub{bottom:-.25em}sup{top:-.5em}img{border-style:none}button,input,optgrou
p,select,textarea{font-family:inherit;font-size:100%;line-height:1.15;margin:0}button,input{overflow:visible}button,sele
ct{text-transform:none}[type=button],[type=reset],[type=submit],button{-webkit-appearance:button}[type=button]::-moz-foc
us-inner,[type=reset]::-moz-focus-inner,[type=submit]::-moz-focus-inner,button::-moz-focus-inner{border-style:none;paddi
ng:0}[type=button]:-moz-focusring,[type=reset]:-moz-focusring,[type=submit]:-moz-focusring,button:-moz-focusring{outline
:1px dotted ButtonText}fieldset{padding:.35em .75em .625em}legend{box-sizing:border-box;color:inherit;display:table;max-
width:100%;padding:0;white-space:normal}progress{vertical-align:baseline}textarea{overflow:auto}[type=checkbox],[type=ra
dio]{box-sizing:border-box;padding:0}[type=number]::-webkit-inner-spin-button,[type=number]::-webkit-outer-spin-button{h
eight:auto}[type=search]{-webkit-appearance:textfield;outline-offset:-2px}[type=search]::-webkit-search-decoration{-webk
it-appearance:none}::-webkit-file-upload-button{-webkit-appearance:button;font:inherit}details{display:block}summary{dis
play:list-item}template{display:none}[hidden]{display:none}
)"

;
; Skeleton V2.0.4
; Copyright 2014, Dave Gamache
; www.getskeleton.com
; Free to use under the MIT license.
; http://www.opensource.org/licenses/mit-license.php
; 12/29/2014
;
Skeleton() => "
( LTrim Join
.container{position:relative;width:100%;max-width:960px;margin:0 auto;padding:0 20px;box-sizing:border-box}.column,.colu
mns{width:100%;float:left;box-sizing:border-box}@media (min-width:400px){.container{width:85%;padding:0}}@media (min-wid
th:550px){.container{width:80%}.column,.columns{margin-left:4%}.column:first-child,.columns:first-child{margin-left:0}.o
ne.column,.one.columns{width:4.66666666667%}.two.columns{width:13.3333333333%}.three.columns{width:22%}.four.columns{wid
th:30.6666666667%}.five.columns{width:39.3333333333%}.six.columns{width:48%}.seven.columns{width:56.6666666667%}.eight.c
olumns{width:65.3333333333%}.nine.columns{width:74%}.ten.columns{width:82.6666666667%}.eleven.columns{width:91.333333333
3%}.twelve.columns{width:100%;margin-left:0}.one-third.column{width:30.6666666667%}.two-thirds.column{width:65.333333333
3%}.one-half.column{width:48%}.offset-by-one.column,.offset-by-one.columns{margin-left:8.66666666667%}.offset-by-two.col
umn,.offset-by-two.columns{margin-left:17.3333333333%}.offset-by-three.column,.offset-by-three.columns{margin-left:26%}.
offset-by-four.column,.offset-by-four.columns{margin-left:34.6666666667%}.offset-by-five.column,.offset-by-five.columns{
margin-left:43.3333333333%}.offset-by-six.column,.offset-by-six.columns{margin-left:52%}.offset-by-seven.column,.offset-
by-seven.columns{margin-left:60.6666666667%}.offset-by-eight.column,.offset-by-eight.columns{margin-left:69.3333333333%}
.offset-by-nine.column,.offset-by-nine.columns{margin-left:78%}.offset-by-ten.column,.offset-by-ten.columns{margin-left:
86.6666666667%}.offset-by-eleven.column,.offset-by-eleven.columns{margin-left:95.3333333333%}.offset-by-one-third.column
,.offset-by-one-third.columns{margin-left:34.6666666667%}.offset-by-two-thirds.column,.offset-by-two-thirds.columns{marg
in-left:69.3333333333%}.offset-by-one-half.column,.offset-by-one-half.columns{margin-left:52%}}html{font-size:62.5%}body
{font-size:1.5em;line-height:1.6;font-weight:400;font-family:Raleway,HelveticaNeue,"Helvetica Neue",Helvetica,Arial,sans
-serif;color:#222}h1,h2,h3,h4,h5,h6{margin-top:0;margin-bottom:2rem;font-weight:300}h1{font-size:4rem;line-height:1.2;le
tter-spacing:-.1rem}h2{font-size:3.6rem;line-height:1.25;letter-spacing:-.1rem}h3{font-size:3rem;line-height:1.3;letter-
spacing:-.1rem}h4{font-size:2.4rem;line-height:1.35;letter-spacing:-.08rem}h5{font-size:1.8rem;line-height:1.5;letter-sp
acing:-.05rem}h6{font-size:1.5rem;line-height:1.6;letter-spacing:0}@media (min-width:550px){h1{font-size:5rem}h2{font-si
ze:4.2rem}h3{font-size:3.6rem}h4{font-size:3rem}h5{font-size:2.4rem}h6{font-size:1.5rem}}p{margin-top:0}a{color:#1EAEDB}
a:hover{color:#0FA0CE}.button,button,input[type=button],input[type=reset],input[type=submit]{display:inline-block;height
:38px;padding:0 30px;color:#555;text-align:center;font-size:11px;font-weight:600;line-height:38px;letter-spacing:.1rem;t
ext-transform:uppercase;text-decoration:none;white-space:nowrap;background-color:transparent;border-radius:4px;border:1p
x solid #bbb;cursor:pointer;box-sizing:border-box}.button:focus,.button:hover,button:focus,button:hover,input[type=butto
n]:focus,input[type=button]:hover,input[type=reset]:focus,input[type=reset]:hover,input[type=submit]:focus,input[type=su
bmit]:hover{color:#333;border-color:#888;outline:0}.button.button-primary,button.button-primary,input[type=button].butto
n-primary,input[type=reset].button-primary,input[type=submit].button-primary{color:#FFF;background-color:#33C3F0;border-
color:#33C3F0}.button.button-primary:focus,.button.button-primary:hover,button.button-primary:focus,button.button-primar
y:hover,input[type=button].button-primary:focus,input[type=button].button-primary:hover,input[type=reset].button-primary
:focus,input[type=reset].button-primary:hover,input[type=submit].button-primary:focus,input[type=submit].button-primary:
hover{color:#FFF;background-color:#1EAEDB;border-color:#1EAEDB}input[type=email],input[type=number],input[type=password]
,input[type=search],input[type=tel],input[type=text],input[type=url],select,textarea{height:38px;padding:6px 10px;backgr
ound-color:#fff;border:1px solid #D1D1D1;border-radius:4px;box-shadow:none;box-sizing:border-box}input[type=email],input
[type=number],input[type=password],input[type=search],input[type=tel],input[type=text],input[type=url],textarea{-webkit-
appearance:none;-moz-appearance:none;appearance:none}textarea{min-height:65px;padding-top:6px;padding-bottom:6px}input[t
ype=email]:focus,input[type=number]:focus,input[type=password]:focus,input[type=search]:focus,input[type=tel]:focus,inpu
t[type=text]:focus,input[type=url]:focus,select:focus,textarea:focus{border:1px solid #33C3F0;outline:0}label,legend{dis
play:block;margin-bottom:.5rem;font-weight:600}fieldset{padding:0;border-width:0}input[type=checkbox],input[type=radio]{
display:inline}label>.label-body{display:inline-block;margin-left:.5rem;font-weight:400}ul{list-style:circle inside}ol{l
ist-style:decimal inside}ol,ul{padding-left:0;margin-top:0}ol ol,ol ul,ul ol,ul ul{margin:1.5rem 0 1.5rem 3rem;font-size
:90%}li{margin-bottom:1rem}code{padding:.2rem .5rem;margin:0 .2rem;font-size:90%;white-space:nowrap;background:#F1F1F1;b
order:1px solid #E1E1E1;border-radius:4px}pre>code{display:block;padding:1rem 1.5rem;white-space:pre}td,th{padding:12px 
15px;text-align:left;border-bottom:1px solid #E1E1E1}td:first-child,th:first-child{padding-left:0}td:last-child,th:last-
child{padding-right:0}.button,button{margin-bottom:1rem}fieldset,input,select,textarea{margin-bottom:1.5rem}blockquote,d
l,figure,form,ol,p,pre,table,ul{margin-bottom:2.5rem}.u-full-width{width:100%;box-sizing:border-box}.u-max-full-width{ma
x-width:100%;box-sizing:border-box}.u-pull-right{float:right}.u-pull-left{float:left}hr{margin-top:3rem;margin-bottom:3.
5rem;border-width:0;border-top:1px solid #E1E1E1}.container:after,.row:after,.u-cf{content:"";display:table;clear:both}
)"

#Include ..\WebViewTooEx.ahk
