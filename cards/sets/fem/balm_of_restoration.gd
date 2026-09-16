extends CardScript
## Balm of Restoration — {2} — Artifact — (fem, rare)
## Oracle: {1}, {T}, Sacrifice this artifact: Choose one —
##         • You gain 2 life.
##         • Prevent the next 2 damage that would be dealt to any target this turn.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Balm of Restoration", "{2}", Mtg.CardType.ARTIFACT)
	card.oracle("{1}, {T}, Sacrifice this artifact: Choose one —\n• You gain 2 life.\n• Prevent the next 2 damage that would be dealt to any target this turn.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
