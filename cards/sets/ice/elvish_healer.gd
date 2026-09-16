extends CardScript
## Elvish Healer — {2}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Elvish Healer", "{2}{W}", Mtg.CardType.CREATURE)
	card.pt(1, 2)
	card.with_subtypes(["elf","cleric"])
	card.oracle("{T}: Prevent the next 1 damage that would be dealt to any target this turn. If it's a green creature, prevent the next 2 damage instead.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
