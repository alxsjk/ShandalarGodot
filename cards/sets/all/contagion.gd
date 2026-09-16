extends CardScript
## Contagion — {3}{B}{B} — Instant (uncommon, all).
## Oracle: You may pay 1 life and exile a black card from your hand rather than pay this spell's mana cost.
##         Distribute two -2/-1 counters among one or two target creatures.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Contagion", "{3}{B}{B}", Mtg.CardType.INSTANT)
	c.oracle("You may pay 1 life and exile a black card from your hand rather than pay this spell's mana cost.\nDistribute two -2/-1 counters among one or two target creatures.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
