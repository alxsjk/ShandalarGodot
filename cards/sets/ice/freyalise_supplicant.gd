extends CardScript
## Freyalise Supplicant — {1}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Freyalise Supplicant", "{1}{G}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["human","cleric"])
	card.oracle("{T}, Sacrifice a red or white creature: This creature deals damage to any target equal to half the sacrificed creature's power, rounded down.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
