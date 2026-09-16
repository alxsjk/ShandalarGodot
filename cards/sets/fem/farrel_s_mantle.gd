extends CardScript
## Farrel's Mantle — {2}{W} — Enchantment — Aura — (fem, uncommon)
## Oracle: Enchant creature
##         Whenever enchanted creature attacks and isn't blocked, its controller may have it deal damage equal to its power plus 2 to another target creature. If that player does, the attacking creature assigns no combat damage this turn.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Farrel's Mantle", "{2}{W}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant creature\nWhenever enchanted creature attacks and isn't blocked, its controller may have it deal damage equal to its power plus 2 to another target creature. If that player does, the attacking creature assigns no combat damage this turn.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
