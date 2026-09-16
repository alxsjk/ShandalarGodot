extends CardScript
## Adarkar Unicorn — {1}{W}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Adarkar Unicorn", "{1}{W}{W}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["unicorn"])
	card.oracle("{T}: Add {U} or {C}{U}. Spend this mana only to pay cumulative upkeep costs.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
