uriSwap(str, action){
    if (action = "e")
    {
        oldformat := a_formatinteger
        SetFormat, integer, hex
        loop, parse, str
            e_str := regexreplace(e_str := hx_str .= RegexReplace(a_loopfield, "[^\w\.]", asc(a_loopfield))
            , "0x", "%")
        SetFormat, integer, % oldformat
        return e_str
    }
    else if (action = "d")
    {
        Loop
        {
            if !RegExMatch(str, "((?<=%)[a-f]|(?<=%)[\da-f]{1,2})", hex)
                break
            d_str := regexreplace(str,"%" . hex, chr("0x" . hex))
        }
        return d_str
    }
}