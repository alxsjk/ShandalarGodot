extends CardScript
## Wall of Kelp — {U}{U} — Creature — Plant Wall (rare, hml).
## Oracle: Defender (This creature can't attack.)
##         {U}{U}, {T}: Create a 0/1 blue Plant Wall creature token with defender named Kelp.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Wall of Kelp", "{U}{U}", Mtg.CardType.CREATURE)
	c.pt(0, 3)
	c.with_subtypes(["plant","wall"])
	c.with_keywords([Mtg.Keyword.DEFENDER])
	c.oracle("Defender (This creature can't attack.)\n{U}{U}, {T}: Create a 0/1 blue Plant Wall creature token with defender named Kelp.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
