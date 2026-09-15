extends CardScript
## Fylgja — {W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Fylgja", "{W}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant creature\nThis Aura enters with four healing counters on it.\nRemove a healing counter from this Aura: Prevent the next 1 damage that would be dealt to enchanted creature this turn.\n{2}{W}: Put a healing counter on this Aura.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
