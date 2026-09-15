extends CardScript
## Icy Prison — {U}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Icy Prison", "{U}{U}", Mtg.CardType.ENCHANTMENT)
	card.oracle("When this enchantment enters, exile target creature.\nAt the beginning of your upkeep, sacrifice this enchantment unless any player pays {3}.\nWhen this enchantment leaves the battlefield, return the exiled card to the battlefield under its owner's control.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
