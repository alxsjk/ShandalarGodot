extends CardScript
## Nature's Wrath — {4}{G}{G} — Enchantment (rare, all).
## Oracle: At the beginning of your upkeep, sacrifice this enchantment unless you pay {G}.
##         Whenever a player puts an Island or blue permanent onto the battlefield, that player sacrifices an Island or blue permanent of their choice.
##         Whenever a player puts a Swamp or black permanent onto the battlefield, that player sacrifices a Swamp or black permanent of their choice.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Nature's Wrath", "{4}{G}{G}", Mtg.CardType.ENCHANTMENT)
	c.oracle("At the beginning of your upkeep, sacrifice this enchantment unless you pay {G}.\nWhenever a player puts an Island or blue permanent onto the battlefield, that player sacrifices an Island or blue permanent of their choice.\nWhenever a player puts a Swamp or black permanent onto the battlefield, that player sacrifices a Swamp or black permanent of their choice.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
