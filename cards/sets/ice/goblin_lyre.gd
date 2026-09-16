extends CardScript
## Goblin Lyre — {3} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Goblin Lyre", "{3}", Mtg.CardType.ARTIFACT)
	card.oracle("Sacrifice this artifact: Flip a coin. If you win the flip, this artifact deals damage to target opponent or planeswalker equal to the number of creatures you control. If you lose the flip, this artifact deals damage to you equal to the number of creatures that opponent or that planeswalker's controller controls.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
