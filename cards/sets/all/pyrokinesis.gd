extends CardScript
## Pyrokinesis — {4}{R}{R} — Instant (uncommon, all).
## Oracle: You may exile a red card from your hand rather than pay this spell's mana cost.
##         Pyrokinesis deals 4 damage divided as you choose among any number of target creatures.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Pyrokinesis", "{4}{R}{R}", Mtg.CardType.INSTANT)
	c.oracle("You may exile a red card from your hand rather than pay this spell's mana cost.\nPyrokinesis deals 4 damage divided as you choose among any number of target creatures.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
