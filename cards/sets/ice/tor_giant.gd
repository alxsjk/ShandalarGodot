extends CardScript
## Tor Giant — {3}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Tor Giant", "{3}{R}", Mtg.CardType.CREATURE)
	card.pt(3, 3)
	card.with_subtypes(["giant"])
	card.oracle("")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
