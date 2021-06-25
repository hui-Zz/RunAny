class JSON
{
class Load extends JSON.Functor
{
Call(self, text, reviver:="")
{
this.rev := IsObject(reviver) ? reviver : false
this.keys := this.rev ? {} : false
static q := Chr(34)
, json_value := q . "{[01234567890-tfn"
, json_value_or_array_closing := q . "{[]01234567890-tfn"
, object_key_or_object_closing := q . "}"
key := ""
is_key := false
root := {}
stack := [root]
next := json_value
pos := 0
while ((ch := SubStr(text, ++pos, 1)) != "") {
if InStr(" `t`r`n", ch)
continue
if !InStr(next, ch, 1)
this.ParseError(next, text, pos)
holder := stack[1]
is_array := holder.IsArray
if InStr(",:", ch) {
next := (is_key := !is_array && ch == ",") ? q : json_value
} else if InStr("}]", ch) {
ObjRemoveAt(stack, 1)
next := stack[1]==root ? "" : stack[1].IsArray ? ",]" : ",}"
} else {
if InStr("{[", ch) {
static json_array := Func("Array").IsBuiltIn || ![].IsArray ? {IsArray: true} : 0
(ch == "{")
? ( is_key := true
, value := {}
, next := object_key_or_object_closing )
: ( value := json_array ? new json_array : []
, next := json_value_or_array_closing )
ObjInsertAt(stack, 1, value)
if (this.keys)
this.keys[value] := []
} else {
if (ch == q) {
i := pos
while (i := InStr(text, q,, i+1)) {
value := StrReplace(SubStr(text, pos+1, i-pos-1), "\\", "\u005c")
static ss_end := A_AhkVersion<"2" ? 0 : -1
if (SubStr(value, ss_end) != "\")
break
}
if (!i)
this.ParseError("'", text, pos)
value := StrReplace(value,    "\/",  "/")
, value := StrReplace(value, "\" . q,    q)
, value := StrReplace(value,    "\b", "`b")
, value := StrReplace(value,    "\f", "`f")
, value := StrReplace(value,    "\n", "`n")
, value := StrReplace(value,    "\r", "`r")
, value := StrReplace(value,    "\t", "`t")
pos := i
i := 0
while (i := InStr(value, "\",, i+1)) {
if !(SubStr(value, i+1, 1) == "u")
this.ParseError("\", text, pos - StrLen(SubStr(value, i+1)))
uffff := Abs("0x" . SubStr(value, i+2, 4))
if (A_IsUnicode || uffff < 0x100)
value := SubStr(value, 1, i-1) . Chr(uffff) . SubStr(value, i+6)
}
if (is_key) {
key := value, next := ":"
continue
}
} else {
value := SubStr(text, pos, i := RegExMatch(text, "[\]\},\s]|$",, pos)-pos)
static number := "number"
if value is %number%
value += 0
else if (value == "true" || value == "false")
value := %value% + 0
else if (value == "null")
value := ""
else
this.ParseError(next, text, pos, i)
pos += i-1
}
next := holder==root ? "" : is_array ? ",]" : ",}"
}
is_array? key := ObjPush(holder, value) : holder[key] := value
if (this.keys && this.keys.HasKey(holder))
this.keys[holder].Push(key)
}
}
return this.rev ? this.Walk(root, "") : root[""]
}
ParseError(expect, text, pos, len:=1)
{
static q := Chr(34)
line := StrSplit(SubStr(text, 1, pos), "`n", "`r").Length()
col := pos - InStr(text, "`n",, -(StrLen(text)-pos+1))
msg := Format("{1}`n`nLine:`t{2}`nCol:`t{3}`nChar:`t{4}"
,     (expect == "")      ? "Extra data"
: (expect == "'")     ? "Unterminated string starting at"
: (expect == "\")     ? "Invalid \escape"
: (expect == ":")     ? "Expecting ':' delimiter"
: (expect == q)       ? "Expecting object key enclosed in double quotes"
: (expect == q . "}") ? "Expecting object key enclosed in double quotes or object closing '}'"
: (expect == ",}")    ? "Expecting ',' delimiter or object closing '}'"
: (expect == ",]")    ? "Expecting ',' delimiter or array closing ']'"
: InStr(expect, "]")  ? "Expecting JSON value or array closing ']'"
:                       "Expecting JSON value(string, number, true, false, null, object or array)"
, line, col, pos)
static offset := A_AhkVersion<"2" ? -3 : -4
throw Exception(msg, offset, SubStr(text, pos, len))
}
Walk(holder, key)
{
value := holder[key]
if IsObject(value) {
for i, k in this.keys[value] {
v := this.Walk.Call(this, value, k)
if (v != JSON.Undefined)
value[k] := v
else
ObjDelete(value, k)
}
}
return this.rev.Call(holder, key, value)
}
}
class Dump extends JSON.Functor
{
Call(self, value, replacer:="", space:="")
{
this.rep := IsObject(replacer) ? replacer : ""
this.gap := ""
if (space) {
static integer := "integer"
if space is %integer%
Loop, % ((n := Abs(space))>10 ? 10 : n)
this.gap .= " "
else
this.gap := SubStr(space, 1, 10)
this.indent := "`n"
}
return this.Str({"": value}, "")
}
Str(holder, key)
{
value := holder[key]
if (this.rep)
value := this.rep.Call(holder, key, ObjHasKey(holder, key) ? value : JSON.Undefined)
if IsObject(value) {
static type := A_AhkVersion<"2" ? "" : Func("Type")
if (type ? type.Call(value) == "Object" : ObjGetCapacity(value) != "") {
if (this.gap) {
stepback := this.indent
this.indent .= this.gap
}
is_array := value.IsArray
if (!is_array) {
for i in value
is_array := i == A_Index
until !is_array
}
str := ""
if (is_array) {
Loop, % value.Length() {
if (this.gap)
str .= this.indent
v := this.Str(value, A_Index)
str .= (v != "") ? v . "," : "null,"
}
} else {
colon := this.gap ? ": " : ":"
for k in value {
v := this.Str(value, k)
if (v != "") {
if (this.gap)
str .= this.indent
str .= this.Quote(k) . colon . v . ","
}
}
}
if (str != "") {
str := RTrim(str, ",")
if (this.gap)
str .= stepback
}
if (this.gap)
this.indent := stepback
return is_array ? "[" . str . "]" : "{" . str . "}"
}
} else
return ObjGetCapacity([value], 1)=="" ? value : this.Quote(value)
}
Quote(string)
{
static q := Chr(34)
if (string != "") {
string := StrReplace(string,  "\",    "\\")
, string := StrReplace(string,    q, "\" . q)
, string := StrReplace(string, "`b",    "\b")
, string := StrReplace(string, "`f",    "\f")
, string := StrReplace(string, "`n",    "\n")
, string := StrReplace(string, "`r",    "\r")
, string := StrReplace(string, "`t",    "\t")
static rx_escapable := A_AhkVersion<"2" ? "O)[^\x20-\x7e]" : "[^\x20-\x7e]"
while RegExMatch(string, rx_escapable, m)
string := StrReplace(string, m.Value, Format("\u{1:04x}", Ord(m.Value)))
}
return q . string . q
}
}
Undefined[]
{
get {
static empty := {}, vt_empty := ComObject(0, &empty, 1)
return vt_empty
}
}
class Functor
{
__Call(method, args*)
{
if IsObject(method)
return (new this).Call(method, args*)
else if (method == "")
return (new this).Call(args*)
}
}
}