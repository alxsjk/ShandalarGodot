extends CardScript
## Kjeldoran Frostbeast — {3}{G}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Kjeldoran Frostbeast", "{3}{G}{W}", Mtg.CardType.CREATURE)
	card.pt(2, 4)
	card.with_subtypes(["elemental","beast"])
	card.oracle("At end of combat, destroy all creatures blocking or blocked by this creature.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
