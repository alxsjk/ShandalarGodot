extends CardScript
## Pestilence Rats — {2}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Pestilence Rats", "{2}{B}", Mtg.CardType.CREATURE)
	card.pt(0, 3)
	card.with_subtypes(["rat"])
	card.oracle("Pestilence Rats's power is equal to the number of other Rats on the battlefield. (For example, as long as there are two other Rats on the battlefield, Pestilence Rats's power and toughness are 2/3.)")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
