extends CardScript
## Elvish Bard — {3}{G}{G} — Creature — Elf Shaman Bard (uncommon, all).
## Oracle: All creatures able to block this creature do so.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Elvish Bard", "{3}{G}{G}", Mtg.CardType.CREATURE)
	c.pt(2, 4)
	c.with_subtypes(["elf","shaman","bard"])
	c.oracle("All creatures able to block this creature do so.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
