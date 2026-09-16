extends CardScript
## Soldevi Sage — {1}{U} — Creature — Human Wizard (common, all).
## Oracle: {T}, Sacrifice two lands: Draw three cards, then discard one of them.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Soldevi Sage", "{1}{U}", Mtg.CardType.CREATURE)
	c.pt(1, 1)
	c.with_subtypes(["human","wizard"])
	c.oracle("{T}, Sacrifice two lands: Draw three cards, then discard one of them.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
