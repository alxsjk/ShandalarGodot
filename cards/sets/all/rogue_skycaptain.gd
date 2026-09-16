extends CardScript
## Rogue Skycaptain — {2}{R} — Creature — Human Rogue Mercenary (rare, all).
## Oracle: Flying
##         At the beginning of your upkeep, put a wage counter on this creature. You may pay {2} for each wage counter on it. If you don't, remove all wage counters from this creature and an opponent gains control of it.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Rogue Skycaptain", "{2}{R}", Mtg.CardType.CREATURE)
	c.pt(3, 4)
	c.with_subtypes(["human","rogue","mercenary"])
	c.with_keywords([Mtg.Keyword.FLYING])
	c.oracle("Flying\nAt the beginning of your upkeep, put a wage counter on this creature. You may pay {2} for each wage counter on it. If you don't, remove all wage counters from this creature and an opponent gains control of it.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
