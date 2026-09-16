extends CardScript
## Kaysa — {3}{G}{G} — Legendary Creature — Elf Druid (rare, all).
## Oracle: Green creatures you control get +1/+1.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Kaysa", "{3}{G}{G}", Mtg.CardType.CREATURE)
	c.pt(2, 3)
	c.with_subtypes(["elf","druid"])
	c.supertypes |= Mtg.Supertype.LEGENDARY
	c.oracle("Green creatures you control get +1/+1.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
