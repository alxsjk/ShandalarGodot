extends CardScript
## Dwarven Sea Clan — {2}{R} — Creature — Dwarf (rare, hml).
## Oracle: {T}: Choose target attacking or blocking creature whose controller controls an Island. This creature deals 2 damage to that creature at end of combat. Activate only before the end of combat step.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Dwarven Sea Clan", "{2}{R}", Mtg.CardType.CREATURE)
	c.pt(1, 1)
	c.with_subtypes(["dwarf"])
	c.oracle("{T}: Choose target attacking or blocking creature whose controller controls an Island. This creature deals 2 damage to that creature at end of combat. Activate only before the end of combat step.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
