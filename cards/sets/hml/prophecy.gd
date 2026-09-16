extends CardScript
## Prophecy — {W} — Sorcery (common, hml).
## Oracle: Reveal the top card of target opponent's library. If it's a land, you gain 1 life. Then that player shuffles.
##         Draw a card at the beginning of the next turn's upkeep.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Prophecy", "{W}", Mtg.CardType.SORCERY)
	c.pt(0, 0)
	c.oracle("Reveal the top card of target opponent's library. If it's a land, you gain 1 life. Then that player shuffles.\nDraw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
