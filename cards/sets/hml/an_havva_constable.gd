extends CardScript
## An-Havva Constable — {1}{G}{G} — Creature — Human (rare, hml).
## Oracle: An-Havva Constable's toughness is equal to 1 plus the number of green creatures on the battlefield.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("An-Havva Constable", "{1}{G}{G}", Mtg.CardType.CREATURE)
	c.pt(2, 0)
	c.with_subtypes(["human"])
	c.oracle("An-Havva Constable's toughness is equal to 1 plus the number of green creatures on the battlefield.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
