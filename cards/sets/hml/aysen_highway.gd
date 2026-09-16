extends CardScript
## Aysen Highway — {3}{W}{W}{W} — Enchantment (rare, hml).
## Oracle: White creatures have plainswalk. (They can't be blocked as long as defending player controls a Plains.)
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Aysen Highway", "{3}{W}{W}{W}", Mtg.CardType.ENCHANTMENT)
	c.pt(0, 0)
	c.oracle("White creatures have plainswalk. (They can't be blocked as long as defending player controls a Plains.)")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
