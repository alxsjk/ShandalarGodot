extends CardScript
## Altar of Bone — {G}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Altar of Bone", "{G}{W}", Mtg.CardType.SORCERY)
	card.oracle("As an additional cost to cast this spell, sacrifice a creature.\nSearch your library for a creature card, reveal it, put it into your hand, then shuffle.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
