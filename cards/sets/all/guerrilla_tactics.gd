extends CardScript
## Guerrilla Tactics — {1}{R} — Instant (common, all).
## Oracle: Guerrilla Tactics deals 2 damage to any target.
##         When a spell or ability an opponent controls causes you to discard this card, it deals 4 damage to any target.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Guerrilla Tactics", "{1}{R}", Mtg.CardType.INSTANT)
	c.oracle("Guerrilla Tactics deals 2 damage to any target.\nWhen a spell or ability an opponent controls causes you to discard this card, it deals 4 damage to any target.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
