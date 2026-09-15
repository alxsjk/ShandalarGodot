extends CardScript
## Infernal Denizen — {7}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Infernal Denizen", "{7}{B}", Mtg.CardType.CREATURE)
	card.pt(5, 7)
	card.with_subtypes(["demon"])
	card.oracle("At the beginning of your upkeep, sacrifice two Swamps. If you can't, tap this creature, and an opponent may gain control of a creature you control of their choice for as long as this creature remains on the battlefield.\n{T}: Gain control of target creature for as long as this creature remains on the battlefield.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
