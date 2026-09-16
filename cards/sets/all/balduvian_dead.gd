extends CardScript
## Balduvian Dead — {3}{B} — Creature — Zombie (uncommon, all).
## Oracle: {2}{R}, Exile a creature card from your graveyard: Create a 3/1 black and red Graveborn creature token with haste. Sacrifice it at the beginning of the next end step.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Balduvian Dead", "{3}{B}", Mtg.CardType.CREATURE)
	c.pt(2, 3)
	c.with_subtypes(["zombie"])
	c.oracle("{2}{R}, Exile a creature card from your graveyard: Create a 3/1 black and red Graveborn creature token with haste. Sacrifice it at the beginning of the next end step.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
