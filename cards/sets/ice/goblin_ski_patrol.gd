extends CardScript
## Goblin Ski Patrol — {1}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Goblin Ski Patrol", "{1}{R}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["goblin"])
	card.oracle("{1}{R}: This creature gets +2/+0 and gains flying. Its controller sacrifices it at the beginning of the next end step. Activate only once and only if you control a snow Mountain.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
