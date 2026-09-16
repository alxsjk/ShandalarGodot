extends CardScript
## Storm Elemental — {5}{U} — Creature — Elemental (uncommon, all).
## Oracle: Flying
##         {U}, Exile the top card of your library: Tap target creature with flying.
##         {U}, Exile the top card of your library: If the exiled card is a snow land, this creature gets +1/+1 until end of turn.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Storm Elemental", "{5}{U}", Mtg.CardType.CREATURE)
	c.pt(3, 4)
	c.with_subtypes(["elemental"])
	c.with_keywords([Mtg.Keyword.FLYING])
	c.oracle("Flying\n{U}, Exile the top card of your library: Tap target creature with flying.\n{U}, Exile the top card of your library: If the exiled card is a snow land, this creature gets +1/+1 until end of turn.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
