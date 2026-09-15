extends CardScript
## General Jarkeld — {3}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("General Jarkeld", "{3}{W}", Mtg.CardType.CREATURE)
	card.pt(1, 2)
	card.with_supertypes(Mtg.Supertype.LEGENDARY)
	card.with_subtypes(["human","soldier"])
	card.oracle("{T}: Choose two target blocked attacking creatures. If each of those creatures could be blocked by all creatures that the other is blocked by, each creature that's blocking exactly one of those attacking creatures stops blocking it and is blocking the other attacking creature. Activate only during the declare blockers step.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
