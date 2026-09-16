extends CardScript
## Aether Storm — {3}{U} — Enchantment (uncommon, hml).
## Oracle: Creature spells can't be cast.
##         Pay 4 life: Destroy this enchantment. It can't be regenerated. Any player may activate this ability.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Aether Storm", "{3}{U}", Mtg.CardType.ENCHANTMENT)
	c.pt(0, 0)
	c.oracle("Creature spells can't be cast.\nPay 4 life: Destroy this enchantment. It can't be regenerated. Any player may activate this ability.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
