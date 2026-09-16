extends CardScript
## Koskun Falls — {2}{B}{B} — World Enchantment (rare, hml).
## Oracle: At the beginning of your upkeep, sacrifice this enchantment unless you tap an untapped creature you control.
##         Creatures can't attack you unless their controller pays {2} for each creature they control that's attacking you.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Koskun Falls", "{2}{B}{B}", Mtg.CardType.ENCHANTMENT)
	c.pt(0, 0)
	c.with_supertypes(Mtg.Supertype.WORLD)
	c.oracle("At the beginning of your upkeep, sacrifice this enchantment unless you tap an untapped creature you control.\nCreatures can't attack you unless their controller pays {2} for each creature they control that's attacking you.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
