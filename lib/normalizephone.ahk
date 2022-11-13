/*
function: normalizePhone

description:

returns:
Properly formatted phone

@Modification Date: July 29, 2019
*/

normalizePhone(phone){

	if (regexmatch(phone, "\+?.?(809||829||849)")) {
		regexmatch(phone, "(\+?\d{1})?[\s.-]?\(?(\d{3})?\)?[\s.-]?(\d{3})[\s-.]?(\d{4})", match)
		format := "+1 (" match2 ")-" match3 "-" match4
		res := strlen(match4) > 4 ? "+" regexreplace(phone, "\D", "") : format
	} else
		res := "+1" regexreplace(phone, "\D", "")

	if (strlen(res) < 10) {

		msgbox % "The provided phone number is probably missing some digits.\n Only basic formatting performed."
		res := regexreplace(phone, "\D", "")
	}

	return res
}
