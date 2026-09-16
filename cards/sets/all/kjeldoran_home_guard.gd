extends CardScript
## Kjeldoran Home Guard — {3}{W} — Creature — Human Soldier (uncommon, all).
## Oracle: At end of combat, if this creature attacked or blocked this combat, put a -0/-1 counter on this creature and create a 0/1 white Deserter creature token.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Kjeldoran Home Guard", "{3}{W}", Mtg.CardType.CREATURE)
	c.pt(1, 6)
	c.with_subtypes(["human","soldier"])
	c.oracle("At end of combat, if this creature attacked or blocked this combat, put a -0/-1 counter on this creature and create a 0/1 white Deserter creature token.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
