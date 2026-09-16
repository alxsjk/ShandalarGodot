extends CardScript
## Folk of An-Havva — {G} — Creature — Human (common, hml).
## Oracle: Whenever this creature blocks, it gets +2/+0 until end of turn.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Folk of An-Havva", "{G}", Mtg.CardType.CREATURE)
	c.pt(1, 1)
	c.with_subtypes(["human"])
	c.oracle("Whenever this creature blocks, it gets +2/+0 until end of turn.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
