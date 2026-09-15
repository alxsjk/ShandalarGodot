extends CardScript
## Orcish Healer — {R}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Orcish Healer", "{R}{R}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["orc","cleric"])
	card.oracle("{R}{R}, {T}: Target creature can't be regenerated this turn.\n{B}{B}{R}, {T}: Regenerate target black or green creature.\n{R}{G}{G}, {T}: Regenerate target black or green creature.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
