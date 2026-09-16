extends CardScript
## Goblin Snowman — {3}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Goblin Snowman", "{3}{R}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["goblin"])
	card.oracle("Whenever this creature blocks, prevent all combat damage that would be dealt to and dealt by it this turn.\n{T}: This creature deals 1 damage to target creature it's blocking.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
