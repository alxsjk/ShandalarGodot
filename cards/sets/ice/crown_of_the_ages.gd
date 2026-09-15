extends CardScript
## Crown of the Ages — {2} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Crown of the Ages", "{2}", Mtg.CardType.ARTIFACT)
	card.oracle("{4}, {T}: Attach target Aura attached to a creature to another creature.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
