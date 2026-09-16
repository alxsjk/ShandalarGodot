extends CardScript
## Soraya the Falconer — {1}{W}{W} — Legendary Creature — Human (rare, hml).
## Oracle: Bird creatures get +1/+1.
##         {1}{W}: Target Bird creature gains banding until end of turn. (Any creatures with banding, and up to one without, can attack in a band. Bands are blocked as a group. If any creatures with banding a player controls are blocking or being blocked by a creature, that player divides that creature's combat damage, not its controller, among any of the creatures it's being blocked by or is blocking.)
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Soraya the Falconer", "{1}{W}{W}", Mtg.CardType.CREATURE)
	c.pt(2, 2)
	c.with_supertypes(Mtg.Supertype.LEGENDARY)
	c.with_subtypes(["human"])
	c.oracle("Bird creatures get +1/+1.\n{1}{W}: Target Bird creature gains banding until end of turn. (Any creatures with banding, and up to one without, can attack in a band. Bands are blocked as a group. If any creatures with banding a player controls are blocking or being blocked by a creature, that player divides that creature's combat damage, not its controller, among any of the creatures it's being blocked by or is blocking.)")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
