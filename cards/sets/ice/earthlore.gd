extends CardScript
## Earthlore — {G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Earthlore", "{G}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant land you control\nTap enchanted land: Target blocking creature gets +1/+2 until end of turn. Activate only if enchanted land is untapped.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
