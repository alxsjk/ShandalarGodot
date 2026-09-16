extends CardScript
## Hail Storm — {1}{G}{G} — Instant (uncommon, all).
## Oracle: Hail Storm deals 2 damage to each attacking creature and 1 damage to you and each creature you control.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Hail Storm", "{1}{G}{G}", Mtg.CardType.INSTANT)
	c.oracle("Hail Storm deals 2 damage to each attacking creature and 1 damage to you and each creature you control.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
