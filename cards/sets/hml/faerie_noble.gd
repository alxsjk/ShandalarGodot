extends CardScript
## Faerie Noble — {2}{G} — Creature — Faerie Noble (rare, hml).
## Oracle: Flying
##         Other Faerie creatures you control get +0/+1.
##         {T}: Other Faerie creatures you control get +1/+0 until end of turn.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Faerie Noble", "{2}{G}", Mtg.CardType.CREATURE)
	c.pt(1, 2)
	c.with_subtypes(["faerie","noble"])
	c.with_keywords([Mtg.Keyword.FLYING])
	c.oracle("Flying\nOther Faerie creatures you control get +0/+1.\n{T}: Other Faerie creatures you control get +1/+0 until end of turn.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
