extends CardScript
## Leeches — {1}{W}{W} — Sorcery (rare, hml).
## Oracle: Target player loses all poison counters. Leeches deals that much damage to that player.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Leeches", "{1}{W}{W}", Mtg.CardType.SORCERY)
	c.pt(0, 0)
	c.oracle("Target player loses all poison counters. Leeches deals that much damage to that player.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
