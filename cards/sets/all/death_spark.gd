extends CardScript
## Death Spark — {R} — Instant (uncommon, all).
## Oracle: Death Spark deals 1 damage to any target.
##         At the beginning of your upkeep, if this card is in your graveyard with a creature card directly above it, you may pay {1}. If you do, return this card to your hand.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Death Spark", "{R}", Mtg.CardType.INSTANT)
	c.oracle("Death Spark deals 1 damage to any target.\nAt the beginning of your upkeep, if this card is in your graveyard with a creature card directly above it, you may pay {1}. If you do, return this card to your hand.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
