extends CardScript
## Mesa Falcon — {1}{W} — Creature — Bird (common, hml).
## Oracle: Flying
##         {1}{W}: This creature gets +0/+1 until end of turn.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Mesa Falcon", "{1}{W}", Mtg.CardType.CREATURE)
	c.pt(1, 1)
	c.with_subtypes(["bird"])
	c.with_keywords([Mtg.Keyword.FLYING])
	c.oracle("Flying\n{1}{W}: This creature gets +0/+1 until end of turn.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
