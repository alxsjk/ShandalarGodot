extends CardScript
## Karplusan Giant — {6}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Karplusan Giant", "{6}{R}", Mtg.CardType.CREATURE)
	card.pt(3, 3)
	card.with_subtypes(["giant"])
	card.oracle("Tap an untapped snow land you control: This creature gets +1/+1 until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
