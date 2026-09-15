extends CardScript
## Mole Worms — {2}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Mole Worms", "{2}{B}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["worm"])
	card.oracle("You may choose not to untap this creature during your untap step.\n{T}: Tap target land. It doesn't untap during its controller's untap step for as long as this creature remains tapped.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
