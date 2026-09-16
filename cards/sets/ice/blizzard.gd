extends CardScript
## Blizzard — {G}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Blizzard", "{G}{G}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Cast this spell only if you control a snow land.\nCumulative upkeep {2} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\nCreatures with flying don't untap during their controllers' untap steps.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
