extends CardScript
## Clockwork Steed — {4} — Artifact Creature — Horse (common, hml).
## Oracle: This creature enters with four +1/+0 counters on it.
##         This creature can't be blocked by artifact creatures.
##         At end of combat, if this creature attacked or blocked this combat, remove a +1/+0 counter from it.
##         {X}, {T}: Put up to X +1/+0 counters on this creature. This ability can't cause the total number of +1/+0 counters on this creature to be greater than four. Activate only during your upkeep.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Clockwork Steed", "{4}", Mtg.CardType.CREATURE | Mtg.CardType.ARTIFACT)
	c.pt(0, 3)
	c.with_subtypes(["horse"])
	c.oracle("This creature enters with four +1/+0 counters on it.\nThis creature can't be blocked by artifact creatures.\nAt end of combat, if this creature attacked or blocked this combat, remove a +1/+0 counter from it.\n{X}, {T}: Put up to X +1/+0 counters on this creature. This ability can't cause the total number of +1/+0 counters on this creature to be greater than four. Activate only during your upkeep.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
