extends CardScript
## Soldevi Heretic — {2}{U} — Creature — Human Cleric (common, all).
## Oracle: {W}, {T}: Prevent the next 2 damage that would be dealt to target creature this turn. Target opponent may draw a card.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Soldevi Heretic", "{2}{U}", Mtg.CardType.CREATURE)
	c.pt(2, 2)
	c.with_subtypes(["human","cleric"])
	c.oracle("{W}, {T}: Prevent the next 2 damage that would be dealt to target creature this turn. Target opponent may draw a card.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
