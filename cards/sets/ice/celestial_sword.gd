extends CardScript
## Celestial Sword — {6} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Celestial Sword", "{6}", Mtg.CardType.ARTIFACT)
	card.oracle("{3}, {T}: Target creature you control gets +3/+3 until end of turn. Its controller sacrifices it at the beginning of the next end step.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
