extends CardScript
## Merieke Ri Berit — {W}{U}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Merieke Ri Berit", "{W}{U}{B}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_supertypes(Mtg.Supertype.LEGENDARY)
	card.with_subtypes(["human"])
	card.oracle("Merieke Ri Berit doesn't untap during your untap step.\n{T}: Gain control of target creature for as long as you control Merieke Ri Berit. When Merieke Ri Berit leaves the battlefield or becomes untapped, destroy that creature. It can't be regenerated.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
