extends CardScript
## Primal Order — {2}{G}{G} — Enchantment (rare, hml).
## Oracle: At the beginning of each player's upkeep, this enchantment deals damage to that player equal to the number of nonbasic lands they control.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Primal Order", "{2}{G}{G}", Mtg.CardType.ENCHANTMENT)
	c.pt(0, 0)
	c.oracle("At the beginning of each player's upkeep, this enchantment deals damage to that player equal to the number of nonbasic lands they control.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
