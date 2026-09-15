extends CardScript
## Tidal Influence — {2}{U} — Enchantment — (fem, uncommon)
## Oracle: Cast this spell only if no permanents named Tidal Influence are on the battlefield.
##         This enchantment enters with a tide counter on it.
##         At the beginning of your upkeep, put a tide counter on this enchantment.
##         As long as there is exactly one tide counter on this enchantment, all blue creatures get -2/-0.
##         As long as there are exactly three tide counters on this enchantment, all blue creatures get +2/+0.
##         Whenever there are four or more tide counters on this enchantment, remove all tide counters from it.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Tidal Influence", "{2}{U}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Cast this spell only if no permanents named Tidal Influence are on the battlefield.\nThis enchantment enters with a tide counter on it.\nAt the beginning of your upkeep, put a tide counter on this enchantment.\nAs long as there is exactly one tide counter on this enchantment, all blue creatures get -2/-0.\nAs long as there are exactly three tide counters on this enchantment, all blue creatures get +2/+0.\nWhenever there are four or more tide counters on this enchantment, remove all tide counters from it.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
