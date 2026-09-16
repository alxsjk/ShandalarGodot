extends CardScript
## Phyrexian Portal — {3} — Artifact (rare, all).
## Oracle: {3}: If your library has ten or more cards in it, target opponent looks at the top ten cards of your library and separates them into two face-down piles. Exile one of those piles. Search the other pile for a card, put it into your hand, then shuffle the rest of that pile into your library.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Phyrexian Portal", "{3}", Mtg.CardType.ARTIFACT)
	c.oracle("{3}: If your library has ten or more cards in it, target opponent looks at the top ten cards of your library and separates them into two face-down piles. Exile one of those piles. Search the other pile for a card, put it into your hand, then shuffle the rest of that pile into your library.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
