extends CardScript
## Illusionary Terrain — {U}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Illusionary Terrain", "{U}{U}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Cumulative upkeep {2} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\nAs this enchantment enters, choose two basic land types.\nBasic lands of the first chosen type are the second chosen type.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
