extends CardScript
## Diseased Vermin — {2}{B} — Creature — Rat (uncommon, all).
## Oracle: Whenever this creature deals combat damage to a player, put an infection counter on it.
##         At the beginning of your upkeep, this creature deals X damage to target opponent previously dealt damage by it, where X is the number of infection counters on it.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Diseased Vermin", "{2}{B}", Mtg.CardType.CREATURE)
	c.pt(1, 1)
	c.with_subtypes(["rat"])
	c.oracle("Whenever this creature deals combat damage to a player, put an infection counter on it.\nAt the beginning of your upkeep, this creature deals X damage to target opponent previously dealt damage by it, where X is the number of infection counters on it.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
