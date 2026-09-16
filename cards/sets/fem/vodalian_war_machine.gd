extends CardScript
## Vodalian War Machine — {1}{U}{U} — Creature — Wall — 0/4 — (fem, rare)
## Oracle: Defender (This creature can't attack.)
##         Tap an untapped Merfolk you control: This creature can attack this turn as though it didn't have defender.
##         Tap an untapped Merfolk you control: This creature gets +2/+1 until end of turn.
##         When this creature dies, destroy all Merfolk tapped this turn to pay for its abilities.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Vodalian War Machine", "{1}{U}{U}", Mtg.CardType.CREATURE)
	card.pt(0, 4)
	card.with_subtypes(["wall"])
	card.with_keywords([Mtg.Keyword.DEFENDER])
	card.oracle("Defender (This creature can't attack.)\nTap an untapped Merfolk you control: This creature can attack this turn as though it didn't have defender.\nTap an untapped Merfolk you control: This creature gets +2/+1 until end of turn.\nWhen this creature dies, destroy all Merfolk tapped this turn to pay for its abilities.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
