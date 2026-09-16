extends CardScript
## Urza's Engine — {5} — Artifact Creature — Juggernaut (uncommon, all).
## Oracle: Trample
##         {3}: This creature gains banding until end of turn. (Any creatures with banding, and up to one without, can attack in a band. Bands are blocked as a group. If any creatures with banding you control are blocking or being blocked by a creature, you divide that creature's combat damage, not its controller, among any of the creatures it's being blocked by or is blocking.)
##         {3}: Attacking creatures banded with this creature gain trample until end of turn.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Urza's Engine", "{5}", Mtg.CardType.CREATURE | Mtg.CardType.ARTIFACT)
	c.pt(1, 5)
	c.with_subtypes(["juggernaut"])
	c.with_keywords([Mtg.Keyword.TRAMPLE])
	c.oracle("Trample\n{3}: This creature gains banding until end of turn. (Any creatures with banding, and up to one without, can attack in a band. Bands are blocked as a group. If any creatures with banding you control are blocking or being blocked by a creature, you divide that creature's combat damage, not its controller, among any of the creatures it's being blocked by or is blocking.)\n{3}: Attacking creatures banded with this creature gain trample until end of turn.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
