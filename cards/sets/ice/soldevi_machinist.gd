extends CardScript
## Soldevi Machinist — {1}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Soldevi Machinist", "{1}{U}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["human","wizard","artificer"])
	card.oracle("{T}: Add {C}{C}. Spend this mana only to activate abilities of artifacts.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
