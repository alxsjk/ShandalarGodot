extends CardScript
## Iceberg — {X}{U}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Iceberg", "{X}{U}{U}", Mtg.CardType.ENCHANTMENT)
	card.oracle("This enchantment enters with X ice counters on it.\n{3}: Put an ice counter on this enchantment.\nRemove an ice counter from this enchantment: Add {C}.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
