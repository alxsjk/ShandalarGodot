extends CardScript
## Abbey Matron — {2}{W} — Creature — Human Cleric (common, hml).
## Oracle: {W}, {T}: This creature gets +0/+3 until end of turn.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Abbey Matron", "{2}{W}", Mtg.CardType.CREATURE)
	c.pt(1, 3)
	c.with_subtypes(["human","cleric"])
	c.oracle("{W}, {T}: This creature gets +0/+3 until end of turn.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
