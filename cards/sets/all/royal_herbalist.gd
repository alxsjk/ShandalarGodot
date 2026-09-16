extends CardScript
## Royal Herbalist — {W} — Creature — Human Cleric (common, all).
## Oracle: {2}, Exile the top card of your library: You gain 1 life.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Royal Herbalist", "{W}", Mtg.CardType.CREATURE)
	c.pt(1, 1)
	c.with_subtypes(["human","cleric"])
	c.oracle("{2}, Exile the top card of your library: You gain 1 life.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
