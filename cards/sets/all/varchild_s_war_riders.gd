extends CardScript
## Varchild's War-Riders — {1}{R} — Creature — Human Warrior (rare, all).
## Oracle: Cumulative upkeep—Have an opponent create a 1/1 red Survivor creature token. (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)
##         Trample; rampage 1 (Whenever this creature becomes blocked, it gets +1/+1 until end of turn for each creature blocking it beyond the first.)
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Varchild's War-Riders", "{1}{R}", Mtg.CardType.CREATURE)
	c.pt(3, 4)
	c.with_subtypes(["human","warrior"])
	c.with_keywords([Mtg.Keyword.TRAMPLE])
	c.oracle("Cumulative upkeep—Have an opponent create a 1/1 red Survivor creature token. (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\nTrample; rampage 1 (Whenever this creature becomes blocked, it gets +1/+1 until end of turn for each creature blocking it beyond the first.)")
	return load("res://cards/sets/all/_rules.gd").apply(c)
