extends CardScript
## Ivory Gargoyle — {4}{W} — Creature — Gargoyle (rare, all).
## Oracle: Flying
##         When this creature dies, return it to the battlefield under its owner's control at the beginning of the next end step and you skip your next draw step.
##         {4}{W}: Exile this creature.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Ivory Gargoyle", "{4}{W}", Mtg.CardType.CREATURE)
	c.pt(2, 2)
	c.with_subtypes(["gargoyle"])
	c.with_keywords([Mtg.Keyword.FLYING])
	c.oracle("Flying\nWhen this creature dies, return it to the battlefield under its owner's control at the beginning of the next end step and you skip your next draw step.\n{4}{W}: Exile this creature.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
