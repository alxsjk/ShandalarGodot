extends CardScript
## An-Havva Inn — {1}{G}{G} — Sorcery (uncommon, hml).
## Oracle: You gain X plus 1 life, where X is the number of green creatures on the battlefield.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("An-Havva Inn", "{1}{G}{G}", Mtg.CardType.SORCERY)
	c.pt(0, 0)
	c.oracle("You gain X plus 1 life, where X is the number of green creatures on the battlefield.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
