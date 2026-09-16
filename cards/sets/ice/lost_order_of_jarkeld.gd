extends CardScript
## Lost Order of Jarkeld — {2}{W}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Lost Order of Jarkeld", "{2}{W}{W}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["human","knight"])
	card.oracle("As this creature enters, choose an opponent.\nLost Order of Jarkeld's power and toughness are each equal to 1 plus the number of creatures the chosen player controls.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
