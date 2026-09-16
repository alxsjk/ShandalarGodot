extends CardScript
## Energy Storm — {1}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Energy Storm", "{1}{W}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Cumulative upkeep {1} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\nPrevent all damage that would be dealt by instant and sorcery spells.\nCreatures with flying don't untap during their controllers' untap steps.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
