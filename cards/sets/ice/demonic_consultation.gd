extends CardScript
## Demonic Consultation — {B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Demonic Consultation", "{B}", Mtg.CardType.INSTANT)
	card.oracle("Choose a card name. Exile the top six cards of your library, then reveal cards from the top of your library until you reveal a card with the chosen name. Put that card into your hand and exile all other cards revealed this way.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
