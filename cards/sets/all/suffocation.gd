extends CardScript
## Suffocation — {1}{U} — Instant (uncommon, all).
## Oracle: Cast this spell only if you were dealt damage this turn by a red instant or sorcery spell.
##         Suffocation deals 4 damage to the controller of the last red instant or sorcery spell that dealt damage to you this turn.
##         Draw a card at the beginning of the next turn's upkeep.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Suffocation", "{1}{U}", Mtg.CardType.INSTANT)
	c.oracle("Cast this spell only if you were dealt damage this turn by a red instant or sorcery spell.\nSuffocation deals 4 damage to the controller of the last red instant or sorcery spell that dealt damage to you this turn.\nDraw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
