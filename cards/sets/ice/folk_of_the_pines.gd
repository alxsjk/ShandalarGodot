extends CardScript
## Folk of the Pines — {4}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Folk of the Pines", "{4}{G}", Mtg.CardType.CREATURE)
	card.pt(2, 5)
	card.with_subtypes(["dryad"])
	card.oracle("{1}{G}: This creature gets +1/+0 until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
