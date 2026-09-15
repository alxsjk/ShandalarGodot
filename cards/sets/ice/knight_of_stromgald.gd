extends CardScript
## Knight of Stromgald — {B}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Knight of Stromgald", "{B}{B}", Mtg.CardType.CREATURE)
	card.pt(2, 1)
	card.with_subtypes(["human","knight"])
	card.with_protection_from(Mtg.ManaColor.W)
	card.oracle("Protection from white\n{B}: This creature gains first strike until end of turn.\n{B}{B}: This creature gets +1/+0 until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
