extends CardScript
## Aysen Bureaucrats — {1}{W} — Creature — Human Advisor (common, hml).
## Oracle: {T}: Tap target creature with power 2 or less.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Aysen Bureaucrats", "{1}{W}", Mtg.CardType.CREATURE)
	c.pt(1, 1)
	c.with_subtypes(["human","advisor"])
	c.oracle("{T}: Tap target creature with power 2 or less.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
