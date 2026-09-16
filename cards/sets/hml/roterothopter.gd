extends CardScript
## Roterothopter — {1} — Artifact Creature — Thopter (common, hml).
## Oracle: Flying
##         {2}: This creature gets +1/+0 until end of turn. Activate no more than twice each turn.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Roterothopter", "{1}", Mtg.CardType.CREATURE | Mtg.CardType.ARTIFACT)
	c.pt(0, 2)
	c.with_subtypes(["thopter"])
	c.with_keywords([Mtg.Keyword.FLYING])
	c.oracle("Flying\n{2}: This creature gets +1/+0 until end of turn. Activate no more than twice each turn.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
