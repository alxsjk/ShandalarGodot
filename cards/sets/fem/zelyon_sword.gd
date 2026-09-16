extends CardScript
## Zelyon Sword — {3} — Artifact — (fem, rare)
## Oracle: You may choose not to untap this artifact during your untap step.
##         {3}, {T}: Target creature gets +2/+0 for as long as this artifact remains tapped.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Zelyon Sword", "{3}", Mtg.CardType.ARTIFACT)
	card.oracle("You may choose not to untap this artifact during your untap step.\n{3}, {T}: Target creature gets +2/+0 for as long as this artifact remains tapped.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
