extends CardScript
## Errand of Duty — {1}{W} — Instant (common, all).
## Oracle: Create a 1/1 white Knight creature token with banding. (Any creatures with banding, and up to one without, can attack in a band. Bands are blocked as a group. If any creatures with banding you control are blocking or being blocked by a creature, you divide that creature's combat damage, not its controller, among any of the creatures it's being blocked by or is blocking.)
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Errand of Duty", "{1}{W}", Mtg.CardType.INSTANT)
	c.oracle("Create a 1/1 white Knight creature token with banding. (Any creatures with banding, and up to one without, can attack in a band. Bands are blocked as a group. If any creatures with banding you control are blocking or being blocked by a creature, you divide that creature's combat damage, not its controller, among any of the creatures it's being blocked by or is blocking.)")
	return load("res://cards/sets/all/_rules.gd").apply(c)
