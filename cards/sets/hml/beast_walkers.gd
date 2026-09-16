extends CardScript
## Beast Walkers — {1}{W}{W} — Creature — Human Beast Soldier (rare, hml).
## Oracle: {G}: This creature gains banding until end of turn. (Any creatures with banding, and up to one without, can attack in a band. Bands are blocked as a group. If any creatures with banding you control are blocking or being blocked by a creature, you divide that creature's combat damage, not its controller, among any of the creatures it's being blocked by or is blocking.)
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Beast Walkers", "{1}{W}{W}", Mtg.CardType.CREATURE)
	c.pt(2, 2)
	c.with_subtypes(["human","beast","soldier"])
	c.oracle("{G}: This creature gains banding until end of turn. (Any creatures with banding, and up to one without, can attack in a band. Bands are blocked as a group. If any creatures with banding you control are blocking or being blocked by a creature, you divide that creature's combat damage, not its controller, among any of the creatures it's being blocked by or is blocking.)")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
