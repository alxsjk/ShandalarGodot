extends CardScript
## Whip Vine — {2}{G} — Creature — Plant Wall (common, all).
## Oracle: Defender; reach (This creature can block creatures with flying.)
##         You may choose not to untap this creature during your untap step.
##         {T}: Tap target creature with flying blocked by this creature. That creature doesn't untap during its controller's untap step for as long as this creature remains tapped.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Whip Vine", "{2}{G}", Mtg.CardType.CREATURE)
	c.pt(1, 4)
	c.with_subtypes(["plant","wall"])
	c.with_keywords([Mtg.Keyword.DEFENDER, Mtg.Keyword.REACH])
	c.oracle("Defender; reach (This creature can block creatures with flying.)\nYou may choose not to untap this creature during your untap step.\n{T}: Tap target creature with flying blocked by this creature. That creature doesn't untap during its controller's untap step for as long as this creature remains tapped.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
