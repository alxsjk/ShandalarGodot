extends CardScript
## Runed Arch — {3} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Runed Arch", "{3}", Mtg.CardType.ARTIFACT)
	card.oracle("This artifact enters tapped.\n{X}, {T}, Sacrifice this artifact: X target creatures with power 2 or less can't be blocked this turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
