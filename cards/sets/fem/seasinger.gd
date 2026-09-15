extends CardScript
## Seasinger — {1}{U}{U} — Creature — Merfolk — 0/1 — (fem, uncommon)
## Oracle: When you control no Islands, sacrifice this creature.
##         You may choose not to untap this creature during your untap step.
##         {T}: Gain control of target creature whose controller controls an Island for as long as you control this creature and this creature remains tapped.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Seasinger", "{1}{U}{U}", Mtg.CardType.CREATURE)
	card.pt(0, 1)
	card.with_subtypes(["merfolk"])
	card.oracle("When you control no Islands, sacrifice this creature.\nYou may choose not to untap this creature during your untap step.\n{T}: Gain control of target creature whose controller controls an Island for as long as you control this creature and this creature remains tapped.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
