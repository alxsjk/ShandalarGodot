extends CardScript
## Sengir Autocrat — {3}{B} — Creature — Human (uncommon, hml).
## Oracle: When this creature enters, create three 0/1 black Serf creature tokens.
##         When this creature leaves the battlefield, exile all Serf tokens.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Sengir Autocrat", "{3}{B}", Mtg.CardType.CREATURE)
	c.pt(2, 2)
	c.with_subtypes(["human"])
	c.oracle("When this creature enters, create three 0/1 black Serf creature tokens.\nWhen this creature leaves the battlefield, exile all Serf tokens.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
