extends CardScript
## Headstone — {1}{B} — Instant (common, hml).
## Oracle: Exile target card from a graveyard.
##         Draw a card at the beginning of the next turn's upkeep.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Headstone", "{1}{B}", Mtg.CardType.INSTANT)
	c.pt(0, 0)
	c.oracle("Exile target card from a graveyard.\nDraw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
