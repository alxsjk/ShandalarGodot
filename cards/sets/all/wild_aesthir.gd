extends CardScript
## Wild Aesthir — {2}{W} — Creature — Bird (common, all).
## Oracle: Flying, first strike
##         {W}{W}: This creature gets +2/+0 until end of turn. Activate only once each turn.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Wild Aesthir", "{2}{W}", Mtg.CardType.CREATURE)
	c.pt(1, 1)
	c.with_subtypes(["bird"])
	c.with_keywords([Mtg.Keyword.FLYING, Mtg.Keyword.FIRST_STRIKE])
	c.oracle("Flying, first strike\n{W}{W}: This creature gets +2/+0 until end of turn. Activate only once each turn.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
