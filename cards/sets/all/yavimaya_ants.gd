extends CardScript
## Yavimaya Ants — {2}{G}{G} — Creature — Insect (uncommon, all).
## Oracle: Trample, haste
##         Cumulative upkeep {G}{G} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Yavimaya Ants", "{2}{G}{G}", Mtg.CardType.CREATURE)
	c.pt(5, 1)
	c.with_subtypes(["insect"])
	c.with_keywords([Mtg.Keyword.HASTE, Mtg.Keyword.TRAMPLE])
	c.oracle("Trample, haste\nCumulative upkeep {G}{G} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)")
	return load("res://cards/sets/all/_rules.gd").apply(c)
