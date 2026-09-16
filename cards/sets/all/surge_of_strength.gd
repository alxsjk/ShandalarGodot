extends CardScript
## Surge of Strength — {R}{G} — Instant (uncommon, all).
## Oracle: As an additional cost to cast this spell, discard a red or green card.
##         Target creature gains trample and gets +X/+0 until end of turn, where X is that creature's mana value.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Surge of Strength", "{R}{G}", Mtg.CardType.INSTANT)
	c.oracle("As an additional cost to cast this spell, discard a red or green card.\nTarget creature gains trample and gets +X/+0 until end of turn, where X is that creature's mana value.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
