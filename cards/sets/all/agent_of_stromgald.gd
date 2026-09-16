extends CardScript
## Agent of Stromgald — {R} — Creature — Human Knight (common, all).
## Oracle: {R}: Add {B}.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Agent of Stromgald", "{R}", Mtg.CardType.CREATURE)
	c.pt(1, 1)
	c.with_subtypes(["human","knight"])
	c.oracle("{R}: Add {B}.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
