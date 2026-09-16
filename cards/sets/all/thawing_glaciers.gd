extends CardScript
## Thawing Glaciers —  — Land (rare, all).
## Oracle: This land enters tapped.
##         {1}, {T}: Search your library for a basic land card, put that card onto the battlefield tapped, then shuffle. Return this land to its owner's hand at the beginning of the next cleanup step.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.
## SIMPLIFIED: cleanup returns the land without a response window.
## See docs/simplified-cards.md; the shared handler also exposes this in-game.

func build() -> CardData:
	var c := CardData.new("Thawing Glaciers", "", Mtg.CardType.LAND)
	c.oracle("This land enters tapped.\n{1}, {T}: Search your library for a basic land card, put that card onto the battlefield tapped, then shuffle. Return this land to its owner's hand at the beginning of the next cleanup step.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
