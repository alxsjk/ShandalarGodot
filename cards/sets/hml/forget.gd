extends CardScript
## Forget — {U}{U} — Sorcery (rare, hml).
## Oracle: Target player discards two cards, then draws as many cards as they discarded this way.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Forget", "{U}{U}", Mtg.CardType.SORCERY)
	c.pt(0, 0)
	c.oracle("Target player discards two cards, then draws as many cards as they discarded this way.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
