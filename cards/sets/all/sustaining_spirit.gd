extends CardScript
## Sustaining Spirit — {1}{W} — Creature — Angel Spirit (rare, all).
## Oracle: Cumulative upkeep {1}{W} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)
##         Damage that would reduce your life total to less than 1 reduces it to 1 instead.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Sustaining Spirit", "{1}{W}", Mtg.CardType.CREATURE)
	c.pt(0, 3)
	c.with_subtypes(["angel","spirit"])
	c.oracle("Cumulative upkeep {1}{W} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\nDamage that would reduce your life total to less than 1 reduces it to 1 instead.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
