extends CardScript
## Kjeldoran Warrior — {W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Kjeldoran Warrior", "{W}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["human","warrior"])
	card.with_keywords([Mtg.Keyword.BANDING])
	card.oracle("Banding (Any creatures with banding, and up to one without, can attack in a band. Bands are blocked as a group. If any creatures with banding you control are blocking or being blocked by a creature, you divide that creature's combat damage, not its controller, among any of the creatures it's being blocked by or is blocking.)")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
