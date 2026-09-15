extends CardScript
## Tidal Flats — {U} — Enchantment — (fem, common)
## Oracle: {U}{U}: For each attacking creature without flying, its controller may pay {1}. If that player doesn't, creatures you control blocking that creature gain first strike until end of turn.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Tidal Flats", "{U}", Mtg.CardType.ENCHANTMENT)
	card.oracle("{U}{U}: For each attacking creature without flying, its controller may pay {1}. If that player doesn't, creatures you control blocking that creature gain first strike until end of turn.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
