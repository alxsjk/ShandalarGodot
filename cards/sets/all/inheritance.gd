extends CardScript
## Inheritance — {W} — Enchantment (uncommon, all).
## Oracle: Whenever a creature dies, you may pay {3}. If you do, draw a card.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Inheritance", "{W}", Mtg.CardType.ENCHANTMENT)
	c.oracle("Whenever a creature dies, you may pay {3}. If you do, draw a card.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
