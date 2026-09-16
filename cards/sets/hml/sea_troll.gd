extends CardScript
## Sea Troll — {2}{U} — Creature — Troll (uncommon, hml).
## Oracle: {U}: Regenerate this creature. Activate only if this creature blocked or was blocked by a blue creature this turn.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Sea Troll", "{2}{U}", Mtg.CardType.CREATURE)
	c.pt(2, 1)
	c.with_subtypes(["troll"])
	c.oracle("{U}: Regenerate this creature. Activate only if this creature blocked or was blocked by a blue creature this turn.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
