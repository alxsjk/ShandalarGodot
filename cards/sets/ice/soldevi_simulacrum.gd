extends CardScript
## Soldevi Simulacrum — {4} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Soldevi Simulacrum", "{4}", Mtg.CardType.ARTIFACT | Mtg.CardType.CREATURE)
	card.pt(2, 4)
	card.with_subtypes(["soldier"])
	card.oracle("Cumulative upkeep {1} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\n{1}: This creature gets +1/+0 until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
