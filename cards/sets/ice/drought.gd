extends CardScript
## Drought — {2}{W}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Drought", "{2}{W}{W}", Mtg.CardType.ENCHANTMENT)
	card.oracle("At the beginning of your upkeep, sacrifice this enchantment unless you pay {W}{W}.\nSpells cost an additional \"Sacrifice a Swamp\" to cast for each black mana symbol in their mana costs.\nActivated abilities cost an additional \"Sacrifice a Swamp\" to activate for each black mana symbol in their activation costs.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
