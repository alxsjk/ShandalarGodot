extends CardScript
## Burnout — {1}{R} — Instant (uncommon, all).
## Oracle: Counter target instant spell if it's blue.
##         Draw a card at the beginning of the next turn's upkeep.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Burnout", "{1}{R}", Mtg.CardType.INSTANT)
	c.oracle("Counter target instant spell if it's blue.\nDraw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
