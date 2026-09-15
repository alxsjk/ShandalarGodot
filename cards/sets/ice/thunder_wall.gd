extends CardScript
## Thunder Wall — {1}{U}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Thunder Wall", "{1}{U}{U}", Mtg.CardType.CREATURE)
	card.pt(0, 2)
	card.with_subtypes(["wall"])
	card.with_keywords([Mtg.Keyword.FLYING, Mtg.Keyword.DEFENDER])
	card.oracle("Defender (This creature can't attack.)\nFlying\n{U}: This creature gets +1/+1 until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
