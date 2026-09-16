extends CardScript
## Goblin Grenade — {R} — Sorcery — (fem, common)
## Oracle: As an additional cost to cast this spell, sacrifice a Goblin.
##         Goblin Grenade deals 5 damage to any target.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Goblin Grenade", "{R}", Mtg.CardType.SORCERY)
	card.oracle("As an additional cost to cast this spell, sacrifice a Goblin.\nGoblin Grenade deals 5 damage to any target.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
