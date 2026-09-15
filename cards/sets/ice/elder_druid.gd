extends CardScript
## Elder Druid — {3}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Elder Druid", "{3}{G}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["elf","cleric","druid"])
	card.oracle("{3}{G}, {T}: You may tap or untap target artifact, creature, or land.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
