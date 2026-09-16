extends CardScript
## Wall of Lava — {1}{R}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Wall of Lava", "{1}{R}{R}", Mtg.CardType.CREATURE)
	card.pt(1, 3)
	card.with_subtypes(["wall"])
	card.with_keywords([Mtg.Keyword.DEFENDER])
	card.oracle("Defender (This creature can't attack.)\n{R}: This creature gets +1/+1 until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
