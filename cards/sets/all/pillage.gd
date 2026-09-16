extends CardScript
## Pillage — {1}{R}{R} — Sorcery (uncommon, all).
## Oracle: Destroy target artifact or land. It can't be regenerated.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Pillage", "{1}{R}{R}", Mtg.CardType.SORCERY)
	c.oracle("Destroy target artifact or land. It can't be regenerated.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
