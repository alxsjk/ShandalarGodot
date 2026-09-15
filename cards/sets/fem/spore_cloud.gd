extends CardScript
## Spore Cloud — {1}{G}{G} — Instant — (fem, common)
## Oracle: Tap all blocking creatures. Prevent all combat damage that would be dealt this turn. Each attacking creature and each blocking creature doesn't untap during its controller's next untap step.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Spore Cloud", "{1}{G}{G}", Mtg.CardType.INSTANT)
	card.oracle("Tap all blocking creatures. Prevent all combat damage that would be dealt this turn. Each attacking creature and each blocking creature doesn't untap during its controller's next untap step.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
