extends CardScript
## Balduvian War-Makers — {4}{R} — Creature — Human Barbarian (common, all).
## Oracle: Haste
##         Rampage 1 (Whenever this creature becomes blocked, it gets +1/+1 until end of turn for each creature blocking it beyond the first.)
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Balduvian War-Makers", "{4}{R}", Mtg.CardType.CREATURE)
	c.pt(3, 3)
	c.with_subtypes(["human","barbarian"])
	c.with_keywords([Mtg.Keyword.HASTE])
	c.oracle("Haste\nRampage 1 (Whenever this creature becomes blocked, it gets +1/+1 until end of turn for each creature blocking it beyond the first.)")
	return load("res://cards/sets/all/_rules.gd").apply(c)
