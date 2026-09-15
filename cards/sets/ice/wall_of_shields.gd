extends CardScript
## Wall of Shields — {3} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Wall of Shields", "{3}", Mtg.CardType.ARTIFACT | Mtg.CardType.CREATURE)
	card.pt(0, 4)
	card.with_subtypes(["wall"])
	card.with_keywords([Mtg.Keyword.BANDING, Mtg.Keyword.DEFENDER])
	card.oracle("Defender (This creature can't attack.)\nBanding (If any creatures with banding you control are blocking a creature, you divide that creature's combat damage, not its controller, among any of the creatures it's being blocked by.)")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
