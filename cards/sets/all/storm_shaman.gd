extends CardScript
## Storm Shaman — {2}{R} — Creature — Human Cleric Shaman (common, all).
## Oracle: {R}: This creature gets +1/+0 until end of turn.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Storm Shaman", "{2}{R}", Mtg.CardType.CREATURE)
	c.pt(0, 4)
	c.with_subtypes(["human","cleric","shaman"])
	c.oracle("{R}: This creature gets +1/+0 until end of turn.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
