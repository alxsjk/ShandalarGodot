extends CardScript
## Broken Visage — {4}{B} — Instant (rare, hml).
## Oracle: Destroy target nonartifact attacking creature. It can't be regenerated. Create a black Spirit creature token. Its power is equal to that creature's power and its toughness is equal to that creature's toughness. Sacrifice the token at the beginning of the next end step.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Broken Visage", "{4}{B}", Mtg.CardType.INSTANT)
	c.pt(0, 0)
	c.oracle("Destroy target nonartifact attacking creature. It can't be regenerated. Create a black Spirit creature token. Its power is equal to that creature's power and its toughness is equal to that creature's toughness. Sacrifice the token at the beginning of the next end step.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
