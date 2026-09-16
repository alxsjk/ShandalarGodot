extends CardScript
## Mystic Decree — {2}{U}{U} — World Enchantment (rare, hml).
## Oracle: All creatures lose flying and islandwalk.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Mystic Decree", "{2}{U}{U}", Mtg.CardType.ENCHANTMENT)
	c.pt(0, 0)
	c.with_supertypes(Mtg.Supertype.WORLD)
	c.oracle("All creatures lose flying and islandwalk.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
