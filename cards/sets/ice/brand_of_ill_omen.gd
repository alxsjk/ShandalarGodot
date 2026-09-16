extends CardScript
## Brand of Ill Omen — {3}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Brand of Ill Omen", "{3}{R}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant creature\nCumulative upkeep {R} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\nEnchanted creature's controller can't cast creature spells.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
