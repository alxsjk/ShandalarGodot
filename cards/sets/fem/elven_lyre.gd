extends CardScript
## Elven Lyre — {2} — Artifact — (fem, rare)
## Oracle: {1}, {T}, Sacrifice this artifact: Target creature gets +2/+2 until end of turn.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Elven Lyre", "{2}", Mtg.CardType.ARTIFACT)
	card.oracle("{1}, {T}, Sacrifice this artifact: Target creature gets +2/+2 until end of turn.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
