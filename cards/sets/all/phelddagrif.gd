extends CardScript
## Phelddagrif — {1}{G}{W}{U} — Legendary Creature — Phelddagrif (rare, all).
## Oracle: {G}: Phelddagrif gains trample until end of turn. Target opponent creates a 1/1 green Hippo creature token.
##         {W}: Phelddagrif gains flying until end of turn. Target opponent gains 2 life.
##         {U}: Return Phelddagrif to its owner's hand. Target opponent may draw a card.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Phelddagrif", "{1}{G}{W}{U}", Mtg.CardType.CREATURE)
	c.pt(4, 4)
	c.with_subtypes(["phelddagrif"])
	c.supertypes |= Mtg.Supertype.LEGENDARY
	c.oracle("{G}: Phelddagrif gains trample until end of turn. Target opponent creates a 1/1 green Hippo creature token.\n{W}: Phelddagrif gains flying until end of turn. Target opponent gains 2 life.\n{U}: Return Phelddagrif to its owner's hand. Target opponent may draw a card.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
