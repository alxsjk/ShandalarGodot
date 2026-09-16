extends CardScript
## Tourach's Gate — {1}{B}{B} — Enchantment — Aura — (fem, rare)
## Oracle: Enchant land you control
##         Sacrifice a Thrull: Put three time counters on this Aura.
##         At the beginning of your upkeep, remove a time counter from this Aura. If there are no time counters on this Aura, sacrifice it.
##         Tap enchanted land: Attacking creatures you control get +2/-1 until end of turn. Activate only if enchanted land is untapped.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Tourach's Gate", "{1}{B}{B}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant land you control\nSacrifice a Thrull: Put three time counters on this Aura.\nAt the beginning of your upkeep, remove a time counter from this Aura. If there are no time counters on this Aura, sacrifice it.\nTap enchanted land: Attacking creatures you control get +2/-1 until end of turn. Activate only if enchanted land is untapped.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
