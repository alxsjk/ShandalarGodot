extends CardScript
## Kjeldoran Escort — {2}{W}{W} — Creature — Human Soldier (common, all).
## Oracle: Banding (Any creatures with banding, and up to one without, can attack in a band. Bands are blocked as a group. If any creatures with banding you control are blocking or being blocked by a creature, you divide that creature's combat damage, not its controller, among any of the creatures it's being blocked by or is blocking.)
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Kjeldoran Escort", "{2}{W}{W}", Mtg.CardType.CREATURE)
	c.pt(2, 3)
	c.with_subtypes(["human","soldier"])
	c.with_keywords([Mtg.Keyword.BANDING])
	c.oracle("Banding (Any creatures with banding, and up to one without, can attack in a band. Bands are blocked as a group. If any creatures with banding you control are blocking or being blocked by a creature, you divide that creature's combat damage, not its controller, among any of the creatures it's being blocked by or is blocking.)")
	return load("res://cards/sets/all/_rules.gd").apply(c)
