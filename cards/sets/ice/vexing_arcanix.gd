extends CardScript
## Vexing Arcanix — {4} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Vexing Arcanix", "{4}", Mtg.CardType.ARTIFACT)
	card.oracle("{3}, {T}: Target player chooses a card name, then reveals the top card of their library. If that card has the chosen name, that player puts it into their hand. Otherwise, they put it into their graveyard and this artifact deals 2 damage to them.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
