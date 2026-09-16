extends CardScript
## Aurochs — {3}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Aurochs", "{3}{G}", Mtg.CardType.CREATURE)
	card.pt(2, 3)
	card.with_subtypes(["aurochs"])
	card.with_keywords([Mtg.Keyword.TRAMPLE])
	card.oracle("Trample\nWhenever this creature attacks, it gets +1/+0 until end of turn for each other attacking Aurochs.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
