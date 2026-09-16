extends CardScript
## Elvish Ranger — {2}{G} — Creature — Elf Ranger (common, all).
## Oracle: (No rules text.)
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Elvish Ranger", "{2}{G}", Mtg.CardType.CREATURE)
	c.pt(4, 1)
	c.with_subtypes(["elf","ranger"])
	c.oracle("")
	return load("res://cards/sets/all/_rules.gd").apply(c)
