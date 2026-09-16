extends CardScript
## Spirit Shield — {3} — Artifact — (fem, rare)
## Oracle: You may choose not to untap this artifact during your untap step.
##         {2}, {T}: Target creature gets +0/+2 for as long as this artifact remains tapped.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Spirit Shield", "{3}", Mtg.CardType.ARTIFACT)
	card.oracle("You may choose not to untap this artifact during your untap step.\n{2}, {T}: Target creature gets +0/+2 for as long as this artifact remains tapped.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
