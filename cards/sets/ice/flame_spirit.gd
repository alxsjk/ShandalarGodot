extends CardScript
## Flame Spirit — {4}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Flame Spirit", "{4}{R}", Mtg.CardType.CREATURE)
	card.pt(2, 3)
	card.with_subtypes(["elemental","spirit"])
	card.oracle("{R}: This creature gets +1/+0 until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
