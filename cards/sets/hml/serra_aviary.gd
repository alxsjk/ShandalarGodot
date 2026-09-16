extends CardScript
## Serra Aviary — {3}{W} — World Enchantment (rare, hml).
## Oracle: Creatures with flying get +1/+1.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Serra Aviary", "{3}{W}", Mtg.CardType.ENCHANTMENT)
	c.pt(0, 0)
	c.with_supertypes(Mtg.Supertype.WORLD)
	c.oracle("Creatures with flying get +1/+1.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
