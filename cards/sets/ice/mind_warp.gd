extends CardScript
## Mind Warp — {X}{3}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Mind Warp", "{X}{3}{B}", Mtg.CardType.SORCERY)
	card.oracle("Look at target player's hand and choose X cards from it. That player discards those cards.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
