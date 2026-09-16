extends CardScript
## Carrier Pigeons — {3}{W} — Creature — Bird (common, all).
## Oracle: Flying
##         When this creature enters, draw a card at the beginning of the next turn's upkeep.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Carrier Pigeons", "{3}{W}", Mtg.CardType.CREATURE)
	c.pt(1, 1)
	c.with_subtypes(["bird"])
	c.with_keywords([Mtg.Keyword.FLYING])
	c.oracle("Flying\nWhen this creature enters, draw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
