extends CardScript
## Arenson's Aura — {2}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Arenson's Aura", "{2}{W}", Mtg.CardType.ENCHANTMENT)
	card.oracle("{W}, Sacrifice an enchantment: Destroy target enchantment.\n{3}{U}{U}: Counter target enchantment spell.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
