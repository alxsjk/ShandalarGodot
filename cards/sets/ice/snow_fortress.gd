extends CardScript
## Snow Fortress — {5} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Snow Fortress", "{5}", Mtg.CardType.ARTIFACT | Mtg.CardType.CREATURE)
	card.pt(0, 4)
	card.with_subtypes(["wall"])
	card.with_keywords([Mtg.Keyword.DEFENDER])
	card.oracle("Defender (This creature can't attack.)\n{1}: This creature gets +1/+0 until end of turn.\n{1}: This creature gets +0/+1 until end of turn.\n{3}: This creature deals 1 damage to target creature without flying that's attacking you.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
