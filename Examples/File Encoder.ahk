#Requires AutoHotkey v2

; Takes an input file (text or binary like png) and compresses it into an
; AutoHotkey function that will return a `Buffer` with the original file
; contents. This can be used to do things like embed image files into your
; script so they can be loaded later in the web view.

#Include ..\Lib\WebViewToo\Lib\WebViewToo.ahk

; The file to encode
TargetFile := ""

win := WebViewGui()

; Add Skeleton CSS framework
win.AddTextRoute '/normalize.css', Normalize()
win.AddTextRoute '/skeleton.css', Skeleton()

win.AddTextRoute "index.html", "
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
		<div class="four columns">
			<label for="chooseFile">File <span id="chosenFile">...</span></label>
			<button
				id="chooseFile"
				class="u-full-width"
			>Choose File</button>
		</div>
		<div class="four columns">
			<label for="charsPerLine">Characters per Line</label>
			<input
				id="charsPerLine"
				type="number"
				onInput="ahk.global.SetCharsPerLine(event.target.value)"
				value="120"
				class="u-full-width"
			/>
		</div>
		<div class="four columns">
			<label for="linesPerChunk">Lines per Chunk</label>
			<input
				id="linesPerChunk"
				type="number"
				onInput="ahk.global.SetLinesPerChunk(event.target.value)"
				value="100"
				class="u-full-width"
			/>
		</div>
		<button id="convert" class="u-full-width button-primary">Encode</button>
		<textarea
			readonly
			id="output"
			class="u-full-width"
			style="font: 10px monospace; height: 400px; resize: vertical"
		></textarea>
	</div>
</body>
)"
win.AddTextRoute "index.js", "
( ; js
const chooseFile = document.getElementById("chooseFile")
const chosenFile = document.getElementById("chosenFile")
const charsPerLine = document.getElementById("charsPerLine")
const linesPerChunk = document.getElementById("linesPerChunk")
const convert = document.getElementById("convert")
const output = document.getElementById("output")

chooseFile.addEventListener("click", async () => {
	chosenFile.innerText = (await ahk.global.ChooseFile()).split("\\").pop()
})

convert.addEventListener("click", async () => {
	output.value = await ahk.global.Convert(charsPerLine.value, linesPerChunk.value)
})
)"

; Show the page
win.Navigate "https://ahk.localhost/index.html"
win.Show "w800 h600"

ChooseFile() {
	global TargetFile
	return TargetFile := FileSelect()
}

Convert(charsPerLine, linesPerChunk) {
	if !TargetFile
		return ""

	uncompressedBuf := FileRead(TargetFile, "RAW")
	compressedBuf := LZ_Compress(uncompressedBuf)
	b64 := Base64_Encode(compressedBuf)

	b64 := RegExReplace(b64, ".{1," charsPerLine "}", "$0`n")
	b64 := RegExReplace(b64, "(.+\n){1," linesPerChunk "}", "    base64 .= '`n    (`n$0    )'`n")
	b64 := StrReplace(b64, ".=", ":=",,, 1)

	SplitPath(TargetFile,,,, &name)

	return (
		"`n"
		name "() {`n" b64
		'    if !DllCall("Crypt32\CryptStringToBinary", "Str", base64, "UInt", 0, "UInt", 1,`n'
		'        "Ptr", cData := Buffer(' compressedBuf.Size '), "UInt*", cData.Size, "Ptr", 0, "Ptr", 0, "UInt")`n'
		'        throw Error("Failed to convert b64 to binary")`n'
		'    if (r := DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", data := Buffer(' uncompressedBuf.Size '),`n'
		'        "UInt", data.Size, "Ptr", cData, "UInt", cData.Ptr, "UInt*", &cbFinal := 0, "UInt"))`n'
		'        throw Error("Error calling RtlDecompressBuffer", , Format("0x{:08x}", r))`n'
		'    return data`n'
		'}`n'
	)
}

LZ_Compress(data) {
	if (r := DllCall("ntdll\RtlGetCompressionWorkSpaceSize", "UShort", 0x102, "UInt*", &cbwsSize := 0,
		"UInt*", &cfwsSize := 0, "UInt"))
		throw Error("Erorr calling RtlGetCompressionWorkSpaceSize", , Format("0x{:08x}", r))
	cbws := Buffer(cbwsSize)
	cData := Buffer(data.Size * 2)
	if (r := DllCall("ntdll\RtlCompressBuffer", "UShort", 0x102, "Ptr", data, "UInt", data.Size, "Ptr", cData,
		"UInt", cData.Size, "UInt", cfwsSize, "UInt*", &finalSize := 0, "Ptr", cbws, "UInt"))
		throw Error("Error calling RtlCompressBuffer", , Format("0x{:08x}", r))
	cData.Size := finalSize
	return cData
}

Base64_Encode(data) {
	cbts(data, pBase64, &size) => DllCall("Crypt32\CryptBinaryToString", "Ptr", data, "UInt", data.Size,
		"UInt", 0x40000001, "Ptr", pBase64, "UInt*", &size, "UInt")
	if !cbts(data, 0, &size := 0)
		throw Error("Failed to calculate b64 size")
	base64 := Buffer(size * 2)
	if !cbts(data, base64, &size)
		throw Error("Failed to convert to b64")
	return StrGet(base64)
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
