extends CardScript
## Abyssal Specter — {2}{B}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Abyssal Specter", "{2}{B}{B}", Mtg.CardType.CREATURE)
	card.pt(2, 3)
	card.with_subtypes(["specter"])
	card.with_keywords([Mtg.Keyword.FLYING])
	card.oracle("Flying\nWhenever this creature deals damage to a player, that player discards a card.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
