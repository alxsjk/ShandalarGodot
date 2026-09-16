extends CardScript
## Halls of Mist — no mana cost — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Halls of Mist", "", Mtg.CardType.LAND)
	card.oracle("Cumulative upkeep {1} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\nCreatures that attacked during their controller's last turn can't attack.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
