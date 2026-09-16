extends CardScript
## Snowblind — {3}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Snowblind", "{3}{G}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant creature\nEnchanted creature gets -X/-Y. If that creature is attacking, X is the number of snow lands defending player controls. Otherwise, X is the number of snow lands its controller controls. Y is equal to X or to enchanted creature's toughness minus 1, whichever is smaller.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
