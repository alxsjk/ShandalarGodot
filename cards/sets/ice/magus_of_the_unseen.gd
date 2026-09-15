extends CardScript
## Magus of the Unseen — {1}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Magus of the Unseen", "{1}{U}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["human","wizard"])
	card.oracle("{1}{U}, {T}: Untap target artifact an opponent controls and gain control of it until end of turn. It gains haste until end of turn. When you lose control of the artifact, tap it.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
