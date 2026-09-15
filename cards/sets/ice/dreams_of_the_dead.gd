extends CardScript
## Dreams of the Dead — {3}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Dreams of the Dead", "{3}{U}", Mtg.CardType.ENCHANTMENT)
	card.oracle("{1}{U}: Return target white or black creature card from your graveyard to the battlefield. That creature gains \"Cumulative upkeep {2}.\" If the creature would leave the battlefield, exile it instead of putting it anywhere else. (At the beginning of its controller's upkeep, that player puts an age counter on it, then sacrifices it unless they pay its upkeep cost for each age counter on it.)")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
