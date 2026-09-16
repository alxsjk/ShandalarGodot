extends CardScript
## Lim-Dûl's High Guard — {1}{B}{B} — Creature — Skeleton (common, all).
## Oracle: First strike
##         {1}{B}: Regenerate this creature.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Lim-Dûl's High Guard", "{1}{B}{B}", Mtg.CardType.CREATURE)
	c.pt(2, 1)
	c.with_subtypes(["skeleton"])
	c.with_keywords([Mtg.Keyword.FIRST_STRIKE])
	c.oracle("First strike\n{1}{B}: Regenerate this creature.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
