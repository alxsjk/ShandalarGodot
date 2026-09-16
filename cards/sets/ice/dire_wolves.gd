extends CardScript
## Dire Wolves — {2}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Dire Wolves", "{2}{G}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["wolf"])
	card.oracle("This creature has banding as long as you control a Plains. (Any creatures with banding, and up to one without, can attack in a band. Bands are blocked as a group. If any creatures with banding you control are blocking or being blocked by a creature, you divide that creature's combat damage, not its controller, among any of the creatures it's being blocked by or is blocking.)")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
