extends CardScript
## Gorilla Berserkers — {3}{G}{G} — Creature — Ape Berserker (common, all).
## Oracle: Trample; rampage 2 (Whenever this creature becomes blocked, it gets +2/+2 until end of turn for each creature blocking it beyond the first.)
##         This creature can't be blocked except by three or more creatures.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Gorilla Berserkers", "{3}{G}{G}", Mtg.CardType.CREATURE)
	c.pt(2, 3)
	c.with_subtypes(["ape","berserker"])
	c.with_keywords([Mtg.Keyword.TRAMPLE])
	c.oracle("Trample; rampage 2 (Whenever this creature becomes blocked, it gets +2/+2 until end of turn for each creature blocking it beyond the first.)\nThis creature can't be blocked except by three or more creatures.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
