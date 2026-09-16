extends CardScript
## Elvish Spirit Guide — {2}{G} — Creature — Elf Spirit (uncommon, all).
## Oracle: Exile this card from your hand: Add {G}.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Elvish Spirit Guide", "{2}{G}", Mtg.CardType.CREATURE)
	c.pt(2, 2)
	c.with_subtypes(["elf","spirit"])
	c.oracle("Exile this card from your hand: Add {G}.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
