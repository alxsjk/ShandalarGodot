extends CardScript
## Game of Chaos — {R}{R}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.
## SIMPLIFIED: at most 30 flips in one resolution, to keep repeated
## doubling within the engine's integer range. All earlier choices and
## outcomes are unchanged. See docs/simplified-cards.md.

func build() -> CardData:
	var card := CardData.new("Game of Chaos", "{R}{R}{R}", Mtg.CardType.SORCERY)
	card.oracle("Flip a coin. If you win the flip, you gain 1 life and target opponent loses 1 life, and you decide whether to flip again. If you lose the flip, you lose 1 life and that opponent gains 1 life, and that player decides whether to flip again. Double the life stakes with each flip.")
	card.oracle(card.oracle_text + "\nDigital safety adaptation: at most 30 coin flips per resolution.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
