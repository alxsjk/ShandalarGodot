extends CardScript
## Chaos Harlequin — {2}{R}{R} — Creature — Human (rare, all).
## Oracle: {R}: Exile the top card of your library. If that card is a land card, this creature gets -4/-0 until end of turn. Otherwise, this creature gets +2/+0 until end of turn.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Chaos Harlequin", "{2}{R}{R}", Mtg.CardType.CREATURE)
	c.pt(2, 4)
	c.with_subtypes(["human"])
	c.oracle("{R}: Exile the top card of your library. If that card is a land card, this creature gets -4/-0 until end of turn. Otherwise, this creature gets +2/+0 until end of turn.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
