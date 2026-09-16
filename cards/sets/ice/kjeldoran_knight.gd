extends CardScript
## Kjeldoran Knight — {W}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Kjeldoran Knight", "{W}{W}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["human","knight"])
	card.with_keywords([Mtg.Keyword.BANDING])
	card.oracle("Banding (Any creatures with banding, and up to one without, can attack in a band. Bands are blocked as a group. If any creatures with banding you control are blocking or being blocked by a creature, you divide that creature's combat damage, not its controller, among any of the creatures it's being blocked by or is blocking.)\n{1}{W}: This creature gets +1/+0 until end of turn.\n{W}{W}: This creature gets +0/+2 until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
