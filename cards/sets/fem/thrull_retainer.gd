extends CardScript
## Thrull Retainer — {B} — Enchantment — Aura — (fem, uncommon)
## Oracle: Enchant creature
##         Enchanted creature gets +1/+1.
##         Sacrifice this Aura: Regenerate enchanted creature.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Thrull Retainer", "{B}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant creature\nEnchanted creature gets +1/+1.\nSacrifice this Aura: Regenerate enchanted creature.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
