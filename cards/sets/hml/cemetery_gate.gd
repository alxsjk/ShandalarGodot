extends CardScript
## Cemetery Gate — {2}{B} — Creature — Wall (common, hml).
## Oracle: Defender (This creature can't attack.)
##         Protection from black
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Cemetery Gate", "{2}{B}", Mtg.CardType.CREATURE)
	c.pt(0, 5)
	c.with_subtypes(["wall"])
	c.with_keywords([Mtg.Keyword.DEFENDER])
	c.with_protection_from(Mtg.ManaColor.B)
	c.oracle("Defender (This creature can't attack.)\nProtection from black")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
