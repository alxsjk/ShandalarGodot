extends CardScript
## Chub Toad — {2}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Chub Toad", "{2}{G}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["frog"])
	card.oracle("Whenever this creature blocks or becomes blocked, it gets +2/+2 until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
