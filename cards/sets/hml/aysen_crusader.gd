extends CardScript
## Aysen Crusader — {2}{W}{W} — Creature — Human Knight (rare, hml).
## Oracle: Aysen Crusader's power and toughness are each equal to 2 plus the number of Soldiers and Warriors you control.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Aysen Crusader", "{2}{W}{W}", Mtg.CardType.CREATURE)
	c.pt(0, 0)
	c.with_subtypes(["human","knight"])
	c.oracle("Aysen Crusader's power and toughness are each equal to 2 plus the number of Soldiers and Warriors you control.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
