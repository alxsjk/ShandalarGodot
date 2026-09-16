extends CardScript
## Reinforcements — {W} — Instant (common, all).
## Oracle: Put up to three target creature cards from your graveyard on top of your library.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Reinforcements", "{W}", Mtg.CardType.INSTANT)
	c.oracle("Put up to three target creature cards from your graveyard on top of your library.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
