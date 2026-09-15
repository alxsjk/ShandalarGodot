extends CardScript
## Naked Singularity — {5} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Naked Singularity", "{5}", Mtg.CardType.ARTIFACT)
	card.oracle("Cumulative upkeep {3} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\nIf tapped for mana, Plains produce {R}, Islands produce {G}, Swamps produce {W}, Mountains produce {U}, and Forests produce {B} instead of any other type.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
