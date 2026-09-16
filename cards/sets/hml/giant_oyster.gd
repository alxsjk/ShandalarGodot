extends CardScript
## Giant Oyster — {2}{U}{U} — Creature — Oyster (uncommon, hml).
## Oracle: You may choose not to untap this creature during your untap step.
##         {T}: For as long as this creature remains tapped, target tapped creature doesn't untap during its controller's untap step, and at the beginning of each of your draw steps, put a -1/-1 counter on that creature. When this creature leaves the battlefield or becomes untapped, remove all -1/-1 counters from the creature.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Giant Oyster", "{2}{U}{U}", Mtg.CardType.CREATURE)
	c.pt(0, 3)
	c.with_subtypes(["oyster"])
	c.oracle("You may choose not to untap this creature during your untap step.\n{T}: For as long as this creature remains tapped, target tapped creature doesn't untap during its controller's untap step, and at the beginning of each of your draw steps, put a -1/-1 counter on that creature. When this creature leaves the battlefield or becomes untapped, remove all -1/-1 counters from the creature.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
