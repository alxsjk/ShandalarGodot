extends CardScript
## Force of Will — {3}{U}{U} — Instant (uncommon, all).
## Oracle: You may pay 1 life and exile a blue card from your hand rather than pay this spell's mana cost.
##         Counter target spell.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Force of Will", "{3}{U}{U}", Mtg.CardType.INSTANT)
	c.oracle("You may pay 1 life and exile a blue card from your hand rather than pay this spell's mana cost.\nCounter target spell.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
