extends CardScript
## Root Spider — {3}{G} — Creature — Spider (uncommon, hml).
## Oracle: Whenever this creature blocks, it gets +1/+0 and gains first strike until end of turn.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Root Spider", "{3}{G}", Mtg.CardType.CREATURE)
	c.pt(2, 2)
	c.with_subtypes(["spider"])
	c.oracle("Whenever this creature blocks, it gets +1/+0 and gains first strike until end of turn.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
