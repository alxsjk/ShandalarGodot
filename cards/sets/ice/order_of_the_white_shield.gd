extends CardScript
## Order of the White Shield — {W}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Order of the White Shield", "{W}{W}", Mtg.CardType.CREATURE)
	card.pt(2, 1)
	card.with_subtypes(["human","knight"])
	card.with_protection_from(Mtg.ManaColor.B)
	card.oracle("Protection from black\n{W}: This creature gains first strike until end of turn.\n{W}{W}: This creature gets +1/+0 until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
