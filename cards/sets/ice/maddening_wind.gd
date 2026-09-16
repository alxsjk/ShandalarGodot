extends CardScript
## Maddening Wind — {2}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Maddening Wind", "{2}{G}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant creature\nCumulative upkeep {G} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\nAt the beginning of the upkeep of enchanted creature's controller, this Aura deals 2 damage to that player.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
