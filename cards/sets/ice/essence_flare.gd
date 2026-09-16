extends CardScript
## Essence Flare — {U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Essence Flare", "{U}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant creature\nEnchanted creature gets +2/+0.\nAt the beginning of the upkeep of enchanted creature's controller, put a -0/-1 counter on that creature.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
