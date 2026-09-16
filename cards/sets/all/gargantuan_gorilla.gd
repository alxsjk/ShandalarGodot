extends CardScript
## Gargantuan Gorilla — {4}{G}{G}{G} — Creature — Ape (rare, all).
## Oracle: At the beginning of your upkeep, you may sacrifice a Forest. If you sacrifice a snow Forest this way, this creature gains trample until end of turn. If you don't sacrifice a Forest, sacrifice this creature and it deals 7 damage to you.
##         {T}: This creature deals damage equal to its power to another target creature. That creature deals damage equal to its power to this creature.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Gargantuan Gorilla", "{4}{G}{G}{G}", Mtg.CardType.CREATURE)
	c.pt(7, 7)
	c.with_subtypes(["ape"])
	c.oracle("At the beginning of your upkeep, you may sacrifice a Forest. If you sacrifice a snow Forest this way, this creature gains trample until end of turn. If you don't sacrifice a Forest, sacrifice this creature and it deals 7 damage to you.\n{T}: This creature deals damage equal to its power to another target creature. That creature deals damage equal to its power to this creature.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
