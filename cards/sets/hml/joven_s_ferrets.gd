extends CardScript
## Joven's Ferrets — {G} — Creature — Ferret (common, hml).
## Oracle: Whenever this creature attacks, it gets +0/+2 until end of turn.
##         At end of combat, tap all creatures that blocked this creature this turn. They don't untap during their controller's next untap step.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Joven's Ferrets", "{G}", Mtg.CardType.CREATURE)
	c.pt(1, 1)
	c.with_subtypes(["ferret"])
	c.oracle("Whenever this creature attacks, it gets +0/+2 until end of turn.\nAt end of combat, tap all creatures that blocked this creature this turn. They don't untap during their controller's next untap step.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
