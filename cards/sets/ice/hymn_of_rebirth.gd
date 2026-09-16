extends CardScript
## Hymn of Rebirth — {3}{G}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Hymn of Rebirth", "{3}{G}{W}", Mtg.CardType.SORCERY)
	card.oracle("Put target creature card from a graveyard onto the battlefield under your control.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
