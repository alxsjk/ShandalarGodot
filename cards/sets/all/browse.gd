extends CardScript
## Browse — {2}{U}{U} — Enchantment (uncommon, all).
## Oracle: {2}{U}{U}: Look at the top five cards of your library, put one of them into your hand, and exile the rest.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Browse", "{2}{U}{U}", Mtg.CardType.ENCHANTMENT)
	c.oracle("{2}{U}{U}: Look at the top five cards of your library, put one of them into your hand, and exile the rest.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
