extends CardScript
## Feast or Famine — {3}{B} — Instant (common, all).
## Oracle: Choose one —
##         • Create a 2/2 black Zombie creature token.
##         • Destroy target nonartifact, nonblack creature. It can't be regenerated.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Feast or Famine", "{3}{B}", Mtg.CardType.INSTANT)
	c.oracle("Choose one —\n• Create a 2/2 black Zombie creature token.\n• Destroy target nonartifact, nonblack creature. It can't be regenerated.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
