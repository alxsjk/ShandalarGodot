extends CardScript
## Merseine — {2}{U}{U} — Enchantment — Aura — (fem, common)
## Oracle: Enchant creature
##         This Aura enters with three net counters on it.
##         Enchanted creature doesn't untap during its controller's untap step if this Aura has a net counter on it.
##         Pay enchanted creature's mana cost: Remove a net counter from this Aura. Only the controller of the enchanted creature may activate this ability.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Merseine", "{2}{U}{U}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant creature\nThis Aura enters with three net counters on it.\nEnchanted creature doesn't untap during its controller's untap step if this Aura has a net counter on it.\nPay enchanted creature's mana cost: Remove a net counter from this Aura. Only the controller of the enchanted creature may activate this ability.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
