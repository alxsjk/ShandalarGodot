extends CardScript
## Renewal — {2}{G} — Sorcery (common, hml).
## Oracle: As an additional cost to cast this spell, sacrifice a land.
##         Search your library for a basic land card, put that card onto the battlefield, then shuffle.
##         Draw a card at the beginning of the next turn's upkeep.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Renewal", "{2}{G}", Mtg.CardType.SORCERY)
	c.pt(0, 0)
	c.oracle("As an additional cost to cast this spell, sacrifice a land.\nSearch your library for a basic land card, put that card onto the battlefield, then shuffle.\nDraw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
