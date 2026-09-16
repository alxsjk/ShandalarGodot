extends CardScript
## Nature's Lore — {1}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Nature's Lore", "{1}{G}", Mtg.CardType.SORCERY)
	card.oracle("Search your library for a Forest card, put that card onto the battlefield, then shuffle.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
