extends CardScript
## Willow Priestess — {2}{G}{G} — Creature — Faerie Druid (rare, hml).
## Oracle: {T}: You may put a Faerie permanent card from your hand onto the battlefield.
##         {2}{G}: Target green creature gains protection from black until end of turn.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Willow Priestess", "{2}{G}{G}", Mtg.CardType.CREATURE)
	c.pt(2, 2)
	c.with_subtypes(["faerie","druid"])
	c.oracle("{T}: You may put a Faerie permanent card from your hand onto the battlefield.\n{2}{G}: Target green creature gains protection from black until end of turn.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
