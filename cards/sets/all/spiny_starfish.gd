extends CardScript
## Spiny Starfish — {2}{U} — Creature — Starfish (uncommon, all).
## Oracle: {U}: Regenerate this creature.
##         At the beginning of each end step, if this creature regenerated this turn, create a 0/1 blue Starfish creature token for each time it regenerated this turn.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Spiny Starfish", "{2}{U}", Mtg.CardType.CREATURE)
	c.pt(0, 1)
	c.with_subtypes(["starfish"])
	c.oracle("{U}: Regenerate this creature.\nAt the beginning of each end step, if this creature regenerated this turn, create a 0/1 blue Starfish creature token for each time it regenerated this turn.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
