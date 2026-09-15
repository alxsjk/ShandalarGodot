extends CardScript
## Giant Trap Door Spider — {1}{R}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Giant Trap Door Spider", "{1}{R}{G}", Mtg.CardType.CREATURE)
	card.pt(2, 3)
	card.with_subtypes(["spider"])
	card.oracle("{1}{R}{G}, {T}: Exile this creature and target creature without flying that's attacking you.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
