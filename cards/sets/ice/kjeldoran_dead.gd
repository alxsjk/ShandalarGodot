extends CardScript
## Kjeldoran Dead — {B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Kjeldoran Dead", "{B}", Mtg.CardType.CREATURE)
	card.pt(3, 1)
	card.with_subtypes(["skeleton"])
	card.oracle("When this creature enters, sacrifice a creature.\n{B}: Regenerate this creature.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
