/*
function: normalizeText

description:
This function strips text from unwanted characters and returns a properly formatted Text and
provides some specific dominican address fixes.

The normalization process is done in steps.
This is to make sure everything that is not needed is removed completely
because if we try to remove all in one step it will have troubles with
text that has mixed removable characters.

returns:
Clean and title cased text.

@Modification Date: July 29, 2019
*/
normalizeText(value){

	/*
	remove accented characters
	*/
	accnt := { "á" : "a"
		, "é" : "e"
		, "í" : "i"
		, "ó" : "o"
		, "ú" : "u"
		, "Á" : "A"
		, "É" : "E"
		, "Í" : "I"
		, "Ó" : "O"
		, "Ú" : "U"}

	for k,v in accnt
		if (instr(value, k))
			value := RegexReplace(value, k, v)

	/*
	remove period at the end because this is not a sentence
	*/
	value := regexreplace(value, "\.$")

	/*
	trim leading/trailing spaces
	*/
	value := regexreplace(value, "^\s+|\s+$")

	/*
	convert multiple spaces in to single spaces
	*/
	value := regexreplace(value, "\s+", a_space)

	/*
	clean address abbreviations
	*/
	value := regexreplace(value, "i)Esquina", "Esq.")
	value := regexreplace(value, "i)(C(\/|\\)|\b(Cll\.?)\b)\s?", "Calle ")
	value := regexreplace(value, "i)(\bNo\.?\b|Numero)\s?(\d+)", "#$2")
	value := regexreplace(value, "i)\bPiso\b", "Nivel")
	value := regexreplace(value, "i)residencial\s", "Res. ")
	value := regexreplace(value, "i)Ensanche\s", "Ens. ")
	value := regexreplace(value, "i)\b(Edificio|Edif\.?)\b", "Edf. ")
	value := regexreplace(value, "i)(\bav\.\b|avenida|\bave\.\b)\s?", "Av. ")
	value := regexreplace(value, "i)av\s", "Av. ")
	value := regexreplace(value, "i)(Apartamento|\bapto\.?\b|\bapart\.?\b)", "Apt. ")
	value := regexreplace(value, "i)(distrito nacional|sto\.?\s?dgo\.?|(\bd\.?\s?n\.?\b|\bs\.?\s?d\.?\b)\W)", "Santo Domingo")

	/*
	remove special non meaningful and non printable characters
	*/
	value := regexreplace(value, "[^a-zA-Z0-9ñÑ\-\s\.\'\#]")


	/*
	convert to proper case
	*/
	value := format("{1:T}", value)
	value := regexreplace(value, "i)\b(i{1,3})\b", "$U1")
	value := regexreplace(value, "i)\b(de la|de los|del|de|y|a)\b", "$L1")

	return value

}
