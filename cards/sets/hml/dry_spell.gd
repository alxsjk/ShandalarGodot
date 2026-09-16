extends CardScript
## Dry Spell — {1}{B} — Sorcery (common, hml).
## Oracle: Dry Spell deals 1 damage to each creature and each player.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Dry Spell", "{1}{B}", Mtg.CardType.SORCERY)
	c.pt(0, 0)
	c.oracle("Dry Spell deals 1 damage to each creature and each player.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
