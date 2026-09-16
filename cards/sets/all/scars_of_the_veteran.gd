extends CardScript
## Scars of the Veteran — {4}{W} — Instant (uncommon, all).
## Oracle: You may exile a white card from your hand rather than pay this spell's mana cost.
##         Prevent the next 7 damage that would be dealt to any target this turn. If it's a creature, put a +0/+1 counter on it for each 1 damage prevented this way at the beginning of the next end step.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Scars of the Veteran", "{4}{W}", Mtg.CardType.INSTANT)
	c.oracle("You may exile a white card from your hand rather than pay this spell's mana cost.\nPrevent the next 7 damage that would be dealt to any target this turn. If it's a creature, put a +0/+1 counter on it for each 1 damage prevented this way at the beginning of the next end step.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
