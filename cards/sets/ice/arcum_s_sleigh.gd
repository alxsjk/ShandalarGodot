extends CardScript
## Arcum's Sleigh — {1} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Arcum's Sleigh", "{1}", Mtg.CardType.ARTIFACT)
	card.oracle("{2}, {T}: Target creature gains vigilance until end of turn. Activate only during combat and only if defending player controls a snow land.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
