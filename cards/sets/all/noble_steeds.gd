extends CardScript
## Noble Steeds — {2}{W} — Enchantment (common, all).
## Oracle: {1}{W}: Target creature gains first strike until end of turn.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Noble Steeds", "{2}{W}", Mtg.CardType.ENCHANTMENT)
	c.oracle("{1}{W}: Target creature gains first strike until end of turn.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
