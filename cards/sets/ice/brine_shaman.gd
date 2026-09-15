extends CardScript
## Brine Shaman — {1}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Brine Shaman", "{1}{B}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["human","cleric","shaman"])
	card.oracle("{T}, Sacrifice a creature: Target creature gets +2/+2 until end of turn.\n{1}{U}{U}, Sacrifice a creature: Counter target creature spell.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
