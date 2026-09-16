extends CardScript
## Coral Reef — {U}{U} — Enchantment (common, hml).
## Oracle: This enchantment enters with four polyp counters on it.
##         Sacrifice an Island: Put two polyp counters on this enchantment.
##         {U}, Tap an untapped blue creature you control, Remove a polyp counter from this enchantment: Put a +0/+1 counter on target creature.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Coral Reef", "{U}{U}", Mtg.CardType.ENCHANTMENT)
	c.pt(0, 0)
	c.oracle("This enchantment enters with four polyp counters on it.\nSacrifice an Island: Put two polyp counters on this enchantment.\n{U}, Tap an untapped blue creature you control, Remove a polyp counter from this enchantment: Put a +0/+1 counter on target creature.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
