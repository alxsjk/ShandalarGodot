extends CardScript
## Abbey Gargoyles — {2}{W}{W}{W} — Creature — Gargoyle (uncommon, hml).
## Oracle: Flying, protection from red
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Abbey Gargoyles", "{2}{W}{W}{W}", Mtg.CardType.CREATURE)
	c.pt(3, 4)
	c.with_subtypes(["gargoyle"])
	c.with_keywords([Mtg.Keyword.FLYING])
	c.with_protection_from(Mtg.ManaColor.R)
	c.oracle("Flying, protection from red")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
