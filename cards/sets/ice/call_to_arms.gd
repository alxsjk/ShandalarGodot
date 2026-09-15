extends CardScript
## Call to Arms — {1}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Call to Arms", "{1}{W}", Mtg.CardType.ENCHANTMENT)
	card.oracle("As this enchantment enters, choose a color and an opponent.\nWhite creatures get +1/+1 as long as the chosen color is the most common color among nontoken permanents the chosen player controls but isn't tied for most common.\nWhen the chosen color isn't the most common color among nontoken permanents the chosen player controls or is tied for most common, sacrifice this enchantment.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
