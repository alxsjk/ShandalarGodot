extends CardScript
## Soldevi Golem — {4} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Soldevi Golem", "{4}", Mtg.CardType.ARTIFACT | Mtg.CardType.CREATURE)
	card.pt(5, 3)
	card.with_subtypes(["golem"])
	card.oracle("This creature doesn't untap during your untap step.\nAt the beginning of your upkeep, you may untap target tapped creature an opponent controls. If you do, untap this creature.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
