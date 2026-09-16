extends CardScript
## Reef Pirates — {1}{U}{U} — Creature — Zombie Pirate (common, hml).
## Oracle: Whenever this creature deals damage to an opponent, that player mills a card.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Reef Pirates", "{1}{U}{U}", Mtg.CardType.CREATURE)
	c.pt(2, 2)
	c.with_subtypes(["zombie","pirate"])
	c.oracle("Whenever this creature deals damage to an opponent, that player mills a card.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
