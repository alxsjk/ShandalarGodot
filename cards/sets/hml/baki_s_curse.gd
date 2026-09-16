extends CardScript
## Baki's Curse — {2}{U}{U} — Sorcery (rare, hml).
## Oracle: Baki's Curse deals 2 damage to each creature for each Aura attached to that creature.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Baki's Curse", "{2}{U}{U}", Mtg.CardType.SORCERY)
	c.pt(0, 0)
	c.oracle("Baki's Curse deals 2 damage to each creature for each Aura attached to that creature.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
