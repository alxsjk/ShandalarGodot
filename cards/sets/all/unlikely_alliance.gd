extends CardScript
## Unlikely Alliance — {1}{W} — Enchantment (uncommon, all).
## Oracle: {1}{W}: Target nonattacking, nonblocking creature gets +0/+2 until end of turn.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Unlikely Alliance", "{1}{W}", Mtg.CardType.ENCHANTMENT)
	c.oracle("{1}{W}: Target nonattacking, nonblocking creature gets +0/+2 until end of turn.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
