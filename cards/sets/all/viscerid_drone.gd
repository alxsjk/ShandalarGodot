extends CardScript
## Viscerid Drone — {1}{U} — Creature — Homarid Drone (uncommon, all).
## Oracle: {T}, Sacrifice a creature and a Swamp: Destroy target nonartifact creature. It can't be regenerated.
##         {T}, Sacrifice a creature and a snow Swamp: Destroy target creature. It can't be regenerated.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Viscerid Drone", "{1}{U}", Mtg.CardType.CREATURE)
	c.pt(1, 2)
	c.with_subtypes(["homarid","drone"])
	c.oracle("{T}, Sacrifice a creature and a Swamp: Destroy target nonartifact creature. It can't be regenerated.\n{T}, Sacrifice a creature and a snow Swamp: Destroy target creature. It can't be regenerated.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
