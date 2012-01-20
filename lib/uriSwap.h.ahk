uriSwap(str, action){
    if (action = "e")
    {
        oldformat := a_formatinteger
        SetFormat, integerfast, hex
        
        while (RegexMatch(str, "[^\w\.:\/]", char))
            StringReplace,str,str, % char, % strLen(asc:=asc(char)) < 4 ? RegexReplace(asc, "0x", "0x0") : asc
        
        StringReplace,str,str, 0x, `%, All
        SetFormat, integer, % oldformat
        
        return str
    }
    else if (action = "d")
    {
        while (RegExMatch(str, "((?<=%)[a-f]|(?<=%)[\da-f]{1,2})", hex))
            StringReplace,str,str, % "%" . hex, % chr("0x" . hex)

        return str
    }
}