extends CardScript
## Caribou Range — {2}{W}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Caribou Range", "{2}{W}{W}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant land you control\nEnchanted land has \"{W}{W}, {T}: Create a 0/1 white Caribou creature token.\"\nSacrifice a Caribou token: You gain 1 life.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
