extends CardScript
## Despotic Scepter — {1} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Despotic Scepter", "{1}", Mtg.CardType.ARTIFACT)
	card.oracle("{T}: Destroy target permanent you own. It can't be regenerated.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
