extends CardScript
## Tinder Wall — {G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Tinder Wall", "{G}", Mtg.CardType.CREATURE)
	card.pt(0, 3)
	card.with_subtypes(["plant","wall"])
	card.with_keywords([Mtg.Keyword.DEFENDER])
	card.oracle("Defender (This creature can't attack.)\nSacrifice this creature: Add {R}{R}.\n{R}, Sacrifice this creature: It deals 2 damage to target creature it's blocking.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
