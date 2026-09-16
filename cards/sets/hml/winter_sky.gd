extends CardScript
## Winter Sky — {R} — Sorcery (rare, hml).
## Oracle: Flip a coin. If you win the flip, Winter Sky deals 1 damage to each creature and each player. If you lose the flip, each player draws a card.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Winter Sky", "{R}", Mtg.CardType.SORCERY)
	c.pt(0, 0)
	c.oracle("Flip a coin. If you win the flip, Winter Sky deals 1 damage to each creature and each player. If you lose the flip, each player draws a card.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
