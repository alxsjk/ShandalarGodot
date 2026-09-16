extends CardScript
## Seasoned Tactician — {2}{W} — Creature — Human Advisor (uncommon, all).
## Oracle: {3}, Exile the top four cards of your library: The next time a source of your choice would deal damage to you this turn, prevent that damage.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Seasoned Tactician", "{2}{W}", Mtg.CardType.CREATURE)
	c.pt(1, 3)
	c.with_subtypes(["human","advisor"])
	c.oracle("{3}, Exile the top four cards of your library: The next time a source of your choice would deal damage to you this turn, prevent that damage.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
