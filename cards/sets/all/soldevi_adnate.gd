extends CardScript
## Soldevi Adnate — {1}{B} — Creature — Human Cleric (common, all).
## Oracle: {T}, Sacrifice a black or artifact creature: Add an amount of {B} equal to the sacrificed creature's mana value.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Soldevi Adnate", "{1}{B}", Mtg.CardType.CREATURE)
	c.pt(1, 2)
	c.with_subtypes(["human","cleric"])
	c.oracle("{T}, Sacrifice a black or artifact creature: Add an amount of {B} equal to the sacrificed creature's mana value.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
