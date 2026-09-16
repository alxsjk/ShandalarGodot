extends CardScript
## Autumn Willow — {4}{G}{G} — Legendary Creature — Avatar (rare, hml).
## Oracle: Shroud (This creature can't be the target of spells or abilities.)
##         {G}: Until end of turn, Autumn Willow can be the target of spells and abilities controlled by target player as though it didn't have shroud.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Autumn Willow", "{4}{G}{G}", Mtg.CardType.CREATURE)
	c.pt(4, 4)
	c.with_supertypes(Mtg.Supertype.LEGENDARY)
	c.with_subtypes(["avatar"])
	c.oracle("Shroud (This creature can't be the target of spells or abilities.)\n{G}: Until end of turn, Autumn Willow can be the target of spells and abilities controlled by target player as though it didn't have shroud.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
