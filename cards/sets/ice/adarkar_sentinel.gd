extends CardScript
## Adarkar Sentinel — {5} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Adarkar Sentinel", "{5}", Mtg.CardType.ARTIFACT | Mtg.CardType.CREATURE)
	card.pt(3, 3)
	card.with_subtypes(["soldier"])
	card.oracle("{1}: This creature gets +0/+1 until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
