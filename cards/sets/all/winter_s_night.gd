extends CardScript
## Winter's Night — {R}{G}{W} — World Enchantment (rare, all).
## Oracle: Whenever a player taps a snow land for mana, that player adds one mana of any type that land produced. That land doesn't untap during its controller's next untap step.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Winter's Night", "{R}{G}{W}", Mtg.CardType.ENCHANTMENT)
	c.supertypes |= Mtg.Supertype.WORLD
	c.oracle("Whenever a player taps a snow land for mana, that player adds one mana of any type that land produced. That land doesn't untap during its controller's next untap step.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
