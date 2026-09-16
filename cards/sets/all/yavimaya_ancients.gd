extends CardScript
## Yavimaya Ancients — {3}{G}{G} — Creature — Treefolk (common, all).
## Oracle: {G}: This creature gets +1/-2 until end of turn.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Yavimaya Ancients", "{3}{G}{G}", Mtg.CardType.CREATURE)
	c.pt(2, 7)
	c.with_subtypes(["treefolk"])
	c.oracle("{G}: This creature gets +1/-2 until end of turn.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
