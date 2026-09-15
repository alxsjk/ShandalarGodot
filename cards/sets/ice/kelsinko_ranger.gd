extends CardScript
## Kelsinko Ranger — {W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Kelsinko Ranger", "{W}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["human","ranger"])
	card.oracle("{1}{W}: Target green creature gains first strike until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
