extends CardScript
## Vibrating Sphere — {4} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Vibrating Sphere", "{4}", Mtg.CardType.ARTIFACT)
	card.oracle("During your turn, creatures you control get +2/+0.\nDuring turns other than yours, creatures you control get -0/-2.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
