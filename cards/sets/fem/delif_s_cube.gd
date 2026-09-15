extends CardScript
## Delif's Cube — {1} — Artifact — (fem, rare)
## Oracle: {2}, {T}: This turn, when target creature you control attacks and isn't blocked, it assigns no combat damage this turn and you put a cube counter on this artifact.
##         {2}, Remove a cube counter from this artifact: Regenerate target creature.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Delif's Cube", "{1}", Mtg.CardType.ARTIFACT)
	card.oracle("{2}, {T}: This turn, when target creature you control attacks and isn't blocked, it assigns no combat damage this turn and you put a cube counter on this artifact.\n{2}, Remove a cube counter from this artifact: Regenerate target creature.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
